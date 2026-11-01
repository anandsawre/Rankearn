import 'dart:async';
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

  const LiveArenaScreen({
    super.key,
    required this.initialSession,
    required this.userCoins,
    required this.userProfile,
    this.onCoinUpdate,
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

  int _turnSeconds = 15; // 15 seconds per question
  Timer? _countdownTimer;
  Timer? _submitDelayTimer;
  Timer? _reviewDelayTimer;

  @override
  void initState() {
    super.initState();
    _session = widget.initialSession;
    _startTurnTimer();
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

    // Simulate opponent choice (realistic 60% probability)
    final opponentCorrect = (_currentRound % 2 == 1 && !timedOut) || (_currentRound == 2);
    final opponentPoints = opponentCorrect ? 10 : 0;

    _submitDelayTimer?.cancel();
    _submitDelayTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      if (isCorrect) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.vibrate();
      }

      setState(() {
        _playerScore += pointsWon;
        _opponentScore += opponentPoints;

        final roundIdx = (_currentRound - 1).clamp(0, 4);
        _playerRounds[roundIdx] = isCorrect;
        _opponentRounds[roundIdx] = opponentCorrect;
      });

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
    final isWin = _playerScore > _opponentScore;
    final isDraw = _playerScore == _opponentScore;
    final prizeCoins = isWin
        ? (_session.entryFee * 2)
        : (isDraw ? _session.entryFee : 0);

    final result = BattleResult(
      isVictory: isWin,
      isDraw: isDraw,
      isDefeat: !isWin && !isDraw,
      playerName: widget.userProfile.name.isEmpty ? 'Vikram Singh' : widget.userProfile.name,
      playerScore: _playerScore,
      opponentName: _session.opponent.name,
      opponentScore: _opponentScore,
      opponentRank: _session.opponent.rank,
      coinsWon: prizeCoins,
      message: isWin
          ? 'You defeated ${_session.opponent.name} in 1v1 Battle! 🏆'
          : (isDraw
              ? 'Honorable match! You tied with ${_session.opponent.name}.'
              : 'Good effort! Practice more and rematch ${_session.opponent.name}.'),
    );

    // Apply winnings to user wallet (Entry fee was already deducted on entry)
    if (prizeCoins > 0) {
      if (isWin) HapticFeedback.heavyImpact();
      widget.onCoinUpdate?.call(prizeCoins);
    }

    // Persist to backend
    await _repository.recordBattleOutcome(
      userId: widget.userProfile.id,
      result: result,
      entryFee: _session.entryFee,
    );

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
      // Entry fee is forfeited
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _submitDelayTimer?.cancel();
    _reviewDelayTimer?.cancel();
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
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Dual Player Scoreboard with 3D VS & Circular Timer
                        BattleVersusCard(
                          playerName: widget.userProfile.name.isEmpty ? 'Vikram Singh' : widget.userProfile.name,
                          playerScore: _playerScore,
                          playerRounds: _playerRounds,
                          isPlayerLeading: _playerScore > _opponentScore,
                          opponentName: _session.opponent.name,
                          opponentScore: _opponentScore,
                          opponentRounds: _opponentRounds,
                          isOpponentLeading: _opponentScore > _playerScore,
                          remainingSeconds: _turnSeconds,
                          totalTurnSeconds: 15,
                        ),
                        const SizedBox(height: 16),

                        // 2. Round Bar & Question Card Surface
                        BattleQuestionCard(
                          currentRound: _currentRound,
                          totalRounds: _session.totalRounds,
                          stakeCoins: _session.entryFee,
                          subject: currentQ.subject,
                          questionText: currentQ.questionText,
                        ),
                        const SizedBox(height: 18),

                        // 3. Four Vertically Stacked Answer Option Tiles (A, B, C, D)
                        ...List.generate(currentQ.options.length, (index) {
                          const letters = ['A', 'B', 'C', 'D'];
                          final letter = index < letters.length ? letters[index] : '$index';
                          final text = currentQ.options[index];

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
                        }),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
