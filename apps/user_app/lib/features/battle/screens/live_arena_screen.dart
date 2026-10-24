import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
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
  int _currentRound = 4; // Starts on Round 4 of 5
  int _playerScore = 10;
  int _opponentScore = 0;
  final List<bool?> _playerRounds = [true, false, true, null, null];
  final List<bool?> _opponentRounds = [false, false, false, null, null];

  int? _selectedOption;
  bool _isAnswerLocked = false;

  int _turnSeconds = 12; // 12 seconds
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
    _turnSeconds = 12;
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

    final currentQ = _session.currentQuestion;
    final isCorrect = !timedOut && _selectedOption == currentQ.correctAnswer;

    // Simulate opponent choice (e.g. 50% realistic success)
    final opponentCorrect = (_currentRound % 2 == 1);

    _submitDelayTimer?.cancel();
    _submitDelayTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      setState(() {
        if (isCorrect) _playerScore += 10;
        if (opponentCorrect) _opponentScore += 10;

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
    final coinsWon = isWin ? _session.entryFee : 0;

    final result = BattleResult(
      isVictory: isWin,
      isDraw: isDraw,
      isDefeat: !isWin && !isDraw,
      playerName: widget.userProfile.name.isEmpty ? 'Vikram Singh' : widget.userProfile.name,
      playerScore: _playerScore,
      opponentName: _session.opponent.name,
      opponentScore: _opponentScore,
      opponentRank: _session.opponent.rank,
      coinsWon: isWin ? _session.entryFee : 0,
      message: isWin
          ? 'You defeated ${_session.opponent.name} in 1v1 Battle! 🏆'
          : (isDraw
              ? 'Honorable match! You tied with ${_session.opponent.name}.'
              : 'Good effort! Practice more and rematch ${_session.opponent.name}.'),
    );

    // Apply coin delta to user wallet
    widget.onCoinUpdate?.call(isWin ? coinsWon : -_session.entryFee);

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
          userCoins: widget.userCoins + (isWin ? coinsWon : -_session.entryFee),
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
      widget.onCoinUpdate?.call(-_session.entryFee);
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
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
