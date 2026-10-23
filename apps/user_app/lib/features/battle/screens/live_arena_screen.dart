import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'battle_result_screen.dart';

/// Screen B: 1v1 Live Arena Quiz Battle Dashboard
/// Direct responsive parity with Reference Image 2:
/// - Desktop: Stadium-themed versus header spanning the top, 3-column dashboard:
///   - Left: Question Palette with Answered/Current/Not Answered states & Surrender Battle action.
///   - Center: Question card, 2x2 or stacked answer choices with selection indicator, and Submit Answer action.
///   - Right: Round & timer quick status, Battle Info rewards, Players Online, and Recent Battles activity.
/// - Mobile: Fluid single-column responsive layout preserving all statistics and interactive controls.
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
  int _currentRound = 4; // Starts on Round 4 of 5 matching Reference Image 2
  int _playerScore = 10;
  int _opponentScore = 0;
  final List<bool?> _playerRounds = [true, true, true, null, null];
  final List<bool?> _opponentRounds = [false, null, null, null, null];
  final Set<int> _answeredIndices = {0, 1, 2};

  int? _selectedOption = 2; // Option C (Skin) pre-selected matching Reference Image 2
  bool _isAnswerLocked = false;
  bool _isSubmitting = false;

  int _turnSeconds = 12; // 12 seconds countdown matching Reference Image 2
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
    _isSubmitting = false;

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
      _submitCurrentAnswer(timedOut: true);
    }
  }

  void _onOptionSelected(int index) {
    if (_isAnswerLocked) return;
    setState(() {
      _selectedOption = index;
    });
  }

  void _submitCurrentAnswer({bool timedOut = false}) {
    if (_isAnswerLocked) return;

    _countdownTimer?.cancel();
    setState(() {
      _isAnswerLocked = true;
      _isSubmitting = true;
    });

    final currentQ = _session.currentQuestion;
    final isCorrect = !timedOut && _selectedOption == currentQ.correctAnswer;
    final opponentCorrect = (_currentRound % 2 == 1);

    _submitDelayTimer?.cancel();
    _submitDelayTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        if (isCorrect) _playerScore += 10;
        if (opponentCorrect) _opponentScore += 10;

        final roundIdx = (_currentRound - 1).clamp(0, 4);
        _playerRounds[roundIdx] = isCorrect;
        _opponentRounds[roundIdx] = opponentCorrect;
        _answeredIndices.add(_currentRound - 1);
      });

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
          ? 'You defeated ${_session.opponent.name} (Rank ${_session.opponent.rank}) in 1v1 Battle! 🏆'
          : (isDraw
              ? 'Honorable match! You tied with ${_session.opponent.name}.'
              : 'Good effort! Rematch ${_session.opponent.name} to climb the ranks.'),
    );

    widget.onCoinUpdate?.call(isWin ? coinsWon : -_session.entryFee);

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
      _submitDelayTimer?.cancel();
      _reviewDelayTimer?.cancel();
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
        backgroundColor: const Color(0xFFF0F7FF),
        appBar: AppHeader(
          coins: widget.userCoins,
          userName: widget.userProfile.name.isEmpty ? 'Vikram Singh' : widget.userProfile.name,
          currentTab: UserNavTab.battle,
          unreadNotifications: 3,
          showMenuButton: false,
          onMenuTap: _promptLeaveBattle,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 960;
              final isTablet = constraints.maxWidth >= 650 && !isDesktop;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 28 : (isTablet ? 18 : 12),
                  vertical: isDesktop ? 20 : 12,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Stadium Versus Header (Spans across top)
                        StadiumVersusBanner(
                          playerName: widget.userProfile.name.isEmpty ? 'Vikram Singh' : widget.userProfile.name,
                          playerScore: _playerScore,
                          playerRounds: _playerRounds,
                          isPlayerLeading: _playerScore >= _opponentScore,
                          opponentName: _session.opponent.name,
                          opponentScore: _opponentScore,
                          opponentRank: _session.opponent.rank.isNotEmpty ? _session.opponent.rank : 'Rank #3421',
                          opponentRounds: _opponentRounds,
                          isOpponentLeading: _opponentScore > _playerScore,
                        ),
                        const SizedBox(height: 18),

                        // 2. Responsive Content Body
                        if (isDesktop)
                          _buildDesktopThreeColumn(currentQ)
                        else
                          _buildMobileStacked(currentQ),
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

  /// Desktop Three-Column Layout: Left (Palette), Center (Question/Answers), Right (Stats/Info)
  Widget _buildDesktopThreeColumn(BattleQuestion currentQ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Question Palette & Surrender Action
        SizedBox(
          width: 220,
          child: QuestionPaletteCard(
            totalQuestions: 20,
            currentQuestionIndex: _currentRound - 1,
            answeredIndices: _answeredIndices,
            onSurrender: _promptLeaveBattle,
            entryFee: _session.entryFee,
          ),
        ),
        const SizedBox(width: 18),

        // Center Column: Question Card & 2x2 Answer Grid
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question Card
              BattleQuestionCard(
                currentRound: _currentRound,
                totalRounds: _session.totalRounds,
                stakeCoins: _session.entryFee,
                subject: currentQ.subject,
                timeLimitSeconds: _turnSeconds,
                questionText: currentQ.questionText,
              ),
              const SizedBox(height: 16),

              // Answer Choices in 2x2 Grid (Desktop Reference Image 2)
              Row(
                children: [
                  Expanded(child: _buildAnswerTile(currentQ, 0, 'A')),
                  const SizedBox(width: 14),
                  Expanded(child: _buildAnswerTile(currentQ, 1, 'B')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildAnswerTile(currentQ, 2, 'C')),
                  const SizedBox(width: 14),
                  Expanded(child: _buildAnswerTile(currentQ, 3, 'D')),
                ],
              ),
              const SizedBox(height: 20),

              // Submit Answer Button
              BattlePrimaryButton(
                label: 'Submit Answer',
                icon: Icons.send_rounded,
                isEnabled: _selectedOption != null && !_isAnswerLocked,
                isLoading: _isSubmitting,
                onPressed: () => _submitCurrentAnswer(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),

        // Right Column: Quick Status, Battle Info, Online Players, Recent Battles
        SizedBox(
          width: 290,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BattleQuickStatusCardsRow(
                currentRound: _currentRound,
                totalRounds: _session.totalRounds,
                remainingSeconds: _turnSeconds,
                stakeCoins: _session.entryFee,
              ),
              const SizedBox(height: 14),
              BattleInfoCard(
                winReward: _session.entryFee,
                correctReward: 10,
                wrongReward: 0,
              ),
              const SizedBox(height: 14),
              const PlayersOnlineCard(count: '2,468'),
              const SizedBox(height: 14),
              const RecentBattlesCard(),
            ],
          ),
        ),
      ],
    );
  }

  /// Mobile Stacked Layout
  Widget _buildMobileStacked(BattleQuestion currentQ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quick Status Row
        BattleQuickStatusCardsRow(
          currentRound: _currentRound,
          totalRounds: _session.totalRounds,
          remainingSeconds: _turnSeconds,
          stakeCoins: _session.entryFee,
        ),
        const SizedBox(height: 14),

        // Question Card
        BattleQuestionCard(
          currentRound: _currentRound,
          totalRounds: _session.totalRounds,
          stakeCoins: _session.entryFee,
          subject: currentQ.subject,
          timeLimitSeconds: _turnSeconds,
          questionText: currentQ.questionText,
        ),
        const SizedBox(height: 14),

        // 4 Answer Options (Stacked on mobile)
        ...List.generate(currentQ.options.length, (index) {
          const letters = ['A', 'B', 'C', 'D'];
          final letter = index < letters.length ? letters[index] : '$index';
          return _buildAnswerTile(currentQ, index, letter);
        }),
        const SizedBox(height: 16),

        // Submit Answer Button
        BattlePrimaryButton(
          label: 'Submit Answer',
          icon: Icons.send_rounded,
          isEnabled: _selectedOption != null && !_isAnswerLocked,
          isLoading: _isSubmitting,
          onPressed: () => _submitCurrentAnswer(),
        ),
        const SizedBox(height: 20),

        // Question Palette (Collapsible / Compact)
        QuestionPaletteCard(
          totalQuestions: 20,
          currentQuestionIndex: _currentRound - 1,
          answeredIndices: _answeredIndices,
          onSurrender: _promptLeaveBattle,
          entryFee: _session.entryFee,
        ),
        const SizedBox(height: 16),

        // Battle Info & Activity
        BattleInfoCard(
          winReward: _session.entryFee,
          correctReward: 10,
          wrongReward: 0,
        ),
        const SizedBox(height: 14),
        const PlayersOnlineCard(count: '2,468'),
        const SizedBox(height: 14),
        const RecentBattlesCard(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAnswerTile(BattleQuestion currentQ, int index, String letter) {
    final text = index < currentQ.options.length ? currentQ.options[index] : '';

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
  }
}
