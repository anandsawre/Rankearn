import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import '../../wallet/components/wallet_modals.dart';
import 'battle_result_screen.dart';

/// Screen Two: Live Arena / Quiz Battle Screen
/// Features live player vs opponent card with crown, circular timer,
/// question card, and 4 answer options (A, B, C, D) with tap submission.
class LiveArenaScreen extends StatefulWidget {
  final BattleSession initialSession;
  final int userCoins;
  final UserProfile userProfile;
  final void Function(int coinsDelta)? onCoinUpdate;
  final double botAccuracy;

  const LiveArenaScreen({
    super.key,
    required this.initialSession,
    required this.userCoins,
    required this.userProfile,
    this.onCoinUpdate,
    this.botAccuracy = 0.65,
  });

  @override
  State<LiveArenaScreen> createState() => _LiveArenaScreenState();
}

class _LiveArenaScreenState extends State<LiveArenaScreen> {
  final BattleRepository _repository = BattleRepository();

  late BattleSession _session;
  int _currentRound = 1; // Starts on Round 1 of 5
  int _playerScore = 0;
  int _opponentScore = 0;
  final List<bool?> _playerRounds = [null, null, null, null, null];
  final List<bool?> _opponentRounds = [null, null, null, null, null];

  int? _selectedOption;
  bool _isAnswerLocked = false;
  bool _isHindi = true;

  int _turnSeconds = 15; // 15 seconds per question
  Timer? _countdownTimer;
  Timer? _submitDelayTimer;
  Timer? _reviewDelayTimer;
  Timer? _liveSyncTimer;
  Timer? _waitOpponentTimer;
  bool _isWaitingForOpponent = false;
  int _waitSecondsRemaining = 45;

  bool get _isRealOpponent {
    final oppId = _session.opponent.id;
    return oppId.isNotEmpty && oppId != 'p_bot' && oppId != 'p_opponent';
  }

  @override
  void initState() {
    super.initState();
    _session = widget.initialSession;
    _startTurnTimer();
    if (_isRealOpponent) {
      _startLiveOpponentSync();
    }
  }

  void _startLiveOpponentSync() {
    _liveSyncTimer?.cancel();
    _liveSyncTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted || _isWaitingForOpponent) return;
      final row = await _repository.fetchBattleState(battleId: _session.id);
      if (!mounted || row == null) return;
      _applyRemoteOpponentScore(row);
    });
  }

  void _applyRemoteOpponentScore(Map<String, dynamic> row) {
    final creatorId = row['creator_id']?.toString() ?? '';
    final isCreator = creatorId == widget.userProfile.id;
    final remoteOppScore = isCreator
        ? (row['opponent_score'] as num?)?.toInt() ?? 0
        : (row['creator_score'] as num?)?.toInt() ?? 0;
    if (remoteOppScore != _opponentScore && mounted) {
      setState(() => _opponentScore = remoteOppScore);
    }
  }

  void _startTurnTimer() {
    _countdownTimer?.cancel();
    _turnSeconds = 15;
    _isAnswerLocked = false;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_turnSeconds > 1) {
        setState(() => _turnSeconds--);
      } else {
        _countdownTimer?.cancel();
        _handleTimeExpired();
      }
    });
  }

  void _handleTimeExpired() {
    if (!_isAnswerLocked) {
      // Time expired without selection
      _submitCurrentAnswer(timedOut: true);
    }
  }

  void _onOptionSelected(int index) {
    if (_isAnswerLocked) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedOption = index;
    });
    _submitCurrentAnswer();
  }

  void _submitCurrentAnswer({bool timedOut = false}) {
    if (_isAnswerLocked) return;

    _countdownTimer?.cancel();
    setState(() {
      _isAnswerLocked = true;
    });

    final currentQ = _session.questions.isNotEmpty
        ? _session.questions[(_currentRound - 1).clamp(0, _session.questions.length - 1)]
        : _session.currentQuestion;

    final durationSeconds = 15.0 - _turnSeconds.toDouble();

    // Server-authoritative integrity check
    final validation = !timedOut && _selectedOption != null
        ? _repository.validateAnswerIntegrity(
            selectedOption: _selectedOption!,
            correctOption: currentQ.correctAnswer,
            answerDurationSeconds: durationSeconds,
          )
        : null;

    bool isCorrect = false;
    int pointsWon = 0;
    if (!timedOut && validation is Success<Map<String, dynamic>>) {
      isCorrect = validation.data['is_correct'] as bool? ?? false;
      if (isCorrect) {
        pointsWon = validation.data['score_awarded'] as int? ?? 10;
      }
    }

    // For bot matches, simulate opponent choice; for real 2-player matches, sync live score to Supabase
    final bool opponentCorrect = !_isRealOpponent &&
        !timedOut &&
        (math.Random().nextDouble() < widget.botAccuracy);
    final int opponentPoints = opponentCorrect ? 10 : 0;

    _submitDelayTimer?.cancel();
    _submitDelayTimer = Timer(const Duration(milliseconds: 700), () async {
      if (!mounted) return;

      if (isCorrect) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.vibrate();
      }

      setState(() {
        _playerScore += pointsWon;
        if (!_isRealOpponent) {
          _opponentScore += opponentPoints;
        }

        final roundIdx = (_currentRound - 1).clamp(0, 4);
        _playerRounds[roundIdx] = isCorrect;
        if (!_isRealOpponent) {
          _opponentRounds[roundIdx] = opponentCorrect;
        }
      });

      if (_isRealOpponent) {
        final synced = await _repository.syncPlayerScore(
          battleId: _session.id,
          userId: widget.userProfile.id,
          score: _playerScore,
        );
        if (synced != null && mounted) {
          _applyRemoteOpponentScore(synced);
        }
      }

      // Advance round or complete match after brief review delay
      _reviewDelayTimer?.cancel();
      _reviewDelayTimer = Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;

        if (_currentRound < _session.totalRounds) {
          setState(() {
            _currentRound++;
            _selectedOption = null;
            _session = _session.copyWith(currentRound: _currentRound);
          });
          _startTurnTimer();
        } else {
          _finishBattle();
        }
      });
    });
  }

  Future<void> _finishBattle() async {
    _countdownTimer?.cancel();
    _liveSyncTimer?.cancel();

    if (!_isRealOpponent) {
      await _completeWithScores(
        myFinalScore: _playerScore,
        oppFinalScore: _opponentScore,
        alreadyRecordedInDb: false,
      );
      return;
    }

    // Real 2-player match: synchronize completion via Supabase `battles`
    final finalized = await _repository.finalizeRealBattle(
      battleId: _session.id,
      userId: widget.userProfile.id,
      myScore: _playerScore,
    );
    if (!mounted) return;

    if (finalized != null &&
        (finalized['status'] ?? '').toString().toLowerCase() == 'completed') {
      await _finishFromBattleRow(finalized);
      return;
    }

    // First player to finish -> wait for opponent to finish (up to 45s safety timeout)
    setState(() {
      _isWaitingForOpponent = true;
      _waitSecondsRemaining = 45;
    });

    _waitOpponentTimer?.cancel();
    _waitOpponentTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_waitSecondsRemaining <= 1) {
        timer.cancel();
        final forced = await _repository.finalizeRealBattle(
          battleId: _session.id,
          userId: widget.userProfile.id,
          myScore: _playerScore,
          forceComplete: true,
        );
        if (!mounted) return;
        if (forced != null) {
          await _finishFromBattleRow(forced);
        } else {
          await _completeWithScores(
            myFinalScore: _playerScore,
            oppFinalScore: _opponentScore,
            alreadyRecordedInDb: true,
          );
        }
        return;
      }

      setState(() => _waitSecondsRemaining--);

      // Poll every 2 seconds (or on even ticks)
      if (_waitSecondsRemaining % 2 == 0) {
        final row = await _repository.fetchBattleState(battleId: _session.id);
        if (!mounted || row == null) return;
        _applyRemoteOpponentScore(row);
        if ((row['status'] ?? '').toString().toLowerCase() == 'completed') {
          timer.cancel();
          await _finishFromBattleRow(row);
        }
      }
    });
  }

  Future<void> _finishFromBattleRow(Map<String, dynamic> row) async {
    final creatorId = row['creator_id']?.toString() ?? '';
    final isCreator = creatorId == widget.userProfile.id;
    final creatorScore = (row['creator_score'] as num?)?.toInt() ?? 0;
    final opponentScore = (row['opponent_score'] as num?)?.toInt() ?? 0;

    final myFinalScore = isCreator ? creatorScore : opponentScore;
    final oppFinalScore = isCreator ? opponentScore : creatorScore;

    await _completeWithScores(
      myFinalScore: myFinalScore,
      oppFinalScore: oppFinalScore,
      alreadyRecordedInDb: true,
    );
  }

  Future<void> _completeWithScores({
    required int myFinalScore,
    required int oppFinalScore,
    required bool alreadyRecordedInDb,
  }) async {
    final isWin = myFinalScore > oppFinalScore;
    final isDraw = myFinalScore == oppFinalScore;
    final prizeCoins = isWin
        ? (_session.entryFee * 2)
        : (isDraw ? _session.entryFee : 0);

    final result = BattleResult(
      isVictory: isWin,
      isDraw: isDraw,
      isDefeat: !isWin && !isDraw,
      playerName: widget.userProfile.name.isEmpty ? 'Player' : widget.userProfile.name,
      playerScore: myFinalScore,
      playerAvatarUrl: widget.userProfile.profilePhotoUrl,
      opponentName: _session.opponent.name,
      opponentScore: oppFinalScore,
      opponentRank: _session.opponent.rank,
      opponentAvatarUrl: _session.opponent.avatarUrl,
      coinsWon: prizeCoins,
      message: isWin
          ? 'You defeated ${_session.opponent.name} in 1v1 Battle! 🏆'
          : (isDraw
              ? 'Honorable match! You tied with ${_session.opponent.name}.'
              : 'Good effort! Practice more and rematch ${_session.opponent.name}.'),
    );

    if (prizeCoins > 0) {
      if (isWin) HapticFeedback.heavyImpact();
      widget.onCoinUpdate?.call(prizeCoins);
    }

    if (alreadyRecordedInDb) {
      // Credit only this user's own winnings / draw refund without overwriting the battles row
      if (isWin && prizeCoins > 0) {
        await _repository.distributeBattleWinnings(
          userId: widget.userProfile.id,
          coinsWon: prizeCoins,
          battleId: _session.id,
          battleTitle: 'Battle vs ${_session.opponent.name}',
        );
      } else if (isDraw && _session.entryFee > 0) {
        await _repository.refundBattleEntryFee(
          userId: widget.userProfile.id,
          entryFee: _session.entryFee,
          battleId: _session.id,
          reason: 'Draw',
        );
      }
    } else {
      await _repository.recordBattleOutcome(
        battleId: _session.id,
        userId: widget.userProfile.id,
        result: result,
        entryFee: _session.entryFee,
      );
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BattleResultScreen(
          result: result,
          userCoins: widget.userCoins + prizeCoins,
          profile: widget.userProfile,
          entryFee: _session.entryFee,
          onCoinUpdate: widget.onCoinUpdate,
        ),
      ),
    );
  }

  Future<void> _promptLeaveBattle() async {
    final shouldLeave = await BattleLeaveDialog.show(context, entryFee: _session.entryFee);
    if (shouldLeave == true && mounted) {
      _countdownTimer?.cancel();
      _liveSyncTimer?.cancel();
      _waitOpponentTimer?.cancel();
      // Entry fee is forfeited
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _submitDelayTimer?.cancel();
    _reviewDelayTimer?.cancel();
    _liveSyncTimer?.cancel();
    _waitOpponentTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _session.currentQuestion;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          await _promptLeaveBattle();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F8FF),
        appBar: BattleAppBar(
          coins: widget.userCoins,
          onBack: _promptLeaveBattle,
          onAddCoins: () {
            WalletModals.showBuyCoinsModal(
              context,
              profile: widget.userProfile,
            );
          },
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: AppSpacing.pagePadding(context, top: 14, bottom: 14),
                child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Dual Player Scoreboard with 3D VS & Circular Timer
                        BattleVersusCard(
                          playerName: widget.userProfile.name.isEmpty ? 'Vikram Singh' : widget.userProfile.name,
                          playerScore: _playerScore,
                          playerRounds: _playerRounds,
                          isPlayerLeading: _playerScore > _opponentScore,
                          playerAvatarUrl: widget.userProfile.profilePhotoUrl,
                          opponentName: _session.opponent.name,
                          opponentScore: _opponentScore,
                          opponentRounds: _opponentRounds,
                          isOpponentLeading: _opponentScore > _playerScore,
                          opponentAvatarUrl: _session.opponent.avatarUrl,
                          remainingSeconds: _turnSeconds,
                          totalTurnSeconds: 15,
                        ),
                        const SizedBox(height: 16),

                        if (_isWaitingForOpponent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppRadii.borderLg,
                              border: Border.all(color: AppColors.battleBorder),
                              boxShadow: AppShadows.subtle,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Color(0xFF00B96B),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Waiting for ${_session.opponent.name} to finish...',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.battleNavy,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Your Score: $_playerScore pts • Auto-resolving in ${_waitSecondsRemaining}s',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.battleSecondaryText,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          // 2. Round Bar & Question Card Surface
                        BattleQuestionCard(
                          currentRound: _currentRound,
                          totalRounds: _session.totalRounds,
                          stakeCoins: _session.entryFee,
                          subject: currentQ.subject,
                          questionText: currentQ.getDisplayText(_isHindi),
                          isHindi: _isHindi,
                          onLanguageChanged: (val) => setState(() => _isHindi = val),
                        ),
                        const SizedBox(height: 18),

                        // 3. Four Vertically Stacked Answer Option Tiles (A, B, C, D)
                        ...() {
                          final displayOptions = currentQ.getDisplayOptions(_isHindi);
                          return List.generate(displayOptions.length, (index) {
                            const letters = ['A', 'B', 'C', 'D'];
                            final letter = index < letters.length ? letters[index] : '$index';
                            final text = displayOptions[index];

                          AnswerTileState tileState = AnswerTileState.defaultState;
                          if (_isAnswerLocked) {
                            if (index == currentQ.correctAnswer) {
                              tileState = AnswerTileState.correct;
                            } else if (index == _selectedOption) {
                              tileState = AnswerTileState.incorrect;
                            } else {
                              tileState = AnswerTileState.disabled;
                            }
                          } else if (_selectedOption == index) {
                            tileState = AnswerTileState.selected;
                          }

                          return AnswerOptionTile(
                            letter: letter,
                            text: text,
                            state: tileState,
                            onTap: () => _onOptionSelected(index),
                          );
                        });
                        }(),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
            },
          ),
        ),
      ),
    );
  }
}
