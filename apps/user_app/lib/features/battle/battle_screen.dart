import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class BattleQuestion {
  final String questionText;
  final List<String> options;
  final int correctAnswer;

  const BattleQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });
}

class BattleScreen extends StatefulWidget {
  final String playerName;
  final String opponentName;
  final int entryFeeCoins;
  final VoidCallback onExit;
  final void Function(int coinsDelta)? onMatchFinished;

  const BattleScreen({
    super.key,
    this.playerName = 'You',
    this.opponentName = 'Rahul K. (Rank 4)',
    this.entryFeeCoins = 20,
    required this.onExit,
    this.onMatchFinished,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final List<BattleQuestion> _questions = const [
    BattleQuestion(
      questionText: 'Which planet is known as the Red Planet in our solar system?',
      options: ['Venus', 'Mars', 'Jupiter', 'Mercury'],
      correctAnswer: 1,
    ),
    BattleQuestion(
      questionText: 'What is the capital of Bihar?',
      options: ['Gaya', 'Patna', 'Muzaffarpur', 'Bhagalpur'],
      correctAnswer: 1,
    ),
    BattleQuestion(
      questionText: 'Who composed the National Anthem of India?',
      options: ['Bankim Chandra Chatterjee', 'Rabindranath Tagore', 'Sarojini Naidu', 'Subhas Chandra Bose'],
      correctAnswer: 1,
    ),
    BattleQuestion(
      questionText: 'Which is the largest organ in the human body?',
      options: ['Liver', 'Heart', 'Skin', 'Lungs'],
      correctAnswer: 2,
    ),
    BattleQuestion(
      questionText: 'In which year did India gain Independence?',
      options: ['1942', '1945', '1947', '1950'],
      correctAnswer: 2,
    ),
  ];

  int _currentQuestionIndex = 0;
  int _playerScore = 0;
  int _opponentScore = 0;
  int _turnSeconds = 15;
  Timer? _timer;
  int? _selectedOption;
  bool _isAnswerLocked = false;
  bool _isMatchOver = false;

  @override
  void initState() {
    super.initState();
    _startTurnTimer();
  }

  void _startTurnTimer() {
    _timer?.cancel();
    _turnSeconds = 15;
    _selectedOption = null;
    _isAnswerLocked = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_turnSeconds > 1) {
        setState(() => _turnSeconds--);
      } else {
        _timer?.cancel();
        _handleTurnTimeout();
      }
    });
  }

  void _handleTurnTimeout() {
    if (!_isAnswerLocked) {
      _advanceQuestion();
    }
  }

  void _submitAnswer(int optionIndex) {
    if (_isAnswerLocked) return;

    final q = _questions[_currentQuestionIndex];
    final isCorrect = optionIndex == q.correctAnswer;

    // Simulate realistic opponent response
    final opponentCorrect = (optionIndex % 2 == 0); // 50% opponent accuracy

    setState(() {
      _selectedOption = optionIndex;
      _isAnswerLocked = true;
      if (isCorrect) _playerScore += 10;
      if (opponentCorrect) _opponentScore += 10;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _advanceQuestion();
    });
  }

  void _advanceQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
      _startTurnTimer();
    } else {
      _timer?.cancel();
      _finishMatch();
    }
  }

  void _finishMatch() {
    setState(() => _isMatchOver = true);
    final isWin = _playerScore > _opponentScore;
    final coinsDelta = isWin ? widget.entryFeeCoins * 2 : 0;
    widget.onMatchFinished?.call(isWin ? coinsDelta : -widget.entryFeeCoins);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isMatchOver) {
      return _buildVictoryScreen();
    }

    final q = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('1v1 Live Arena ⚔️'),
        backgroundColor: AppColors.brandPrimary,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            _timer?.cancel();
            widget.onExit();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            children: [
              // Player vs Opponent Arena Scoreboard
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.borderLg,
                  boxShadow: AppShadows.subtle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    // Player Card
                    Expanded(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.brandPrimaryLight,
                            child: Icon(Icons.person, color: AppColors.brandPrimary, size: 28),
                          ),
                          const SizedBox(height: 6),
                          Text(widget.playerName, style: AppTypography.titleSmall, maxLines: 1),
                          Text('$_playerScore pts', style: const TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
                    ),

                    // Central VS Badge & Timer
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.errorRose,
                            borderRadius: AppRadii.borderPill,
                          ),
                          child: const Text('VS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _turnSeconds <= 5 ? AppColors.errorRoseLight : AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: _turnSeconds <= 5 ? AppColors.errorRose : AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$_turnSeconds',
                            style: TextStyle(
                              color: _turnSeconds <= 5 ? AppColors.errorRose : AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Opponent Card
                    Expanded(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: Color(0xFFFEE2E2),
                            child: Icon(Icons.person_outline, color: Color(0xFFDC2626), size: 28),
                          ),
                          const SizedBox(height: 6),
                          Text(widget.opponentName, style: AppTypography.titleSmall, maxLines: 1),
                          Text('$_opponentScore pts', style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Round ${_currentQuestionIndex + 1} of ${_questions.length}', style: AppTypography.bodySmall),
                  Text('Stake: ${widget.entryFeeCoins} Coins', style: const TextStyle(color: AppColors.coinGold, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
                minHeight: 6,
              ),
              const SizedBox(height: 20),

              // Question Card
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Text(
                  q.questionText,
                  style: AppTypography.titleLarge.copyWith(fontSize: 17, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Fast-action options
              Expanded(
                child: ListView.builder(
                  itemCount: q.options.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedOption == index;
                    final isCorrect = q.correctAnswer == index;

                    Color bg = Colors.white;
                    Color borderCol = AppColors.border;
                    Color textCol = AppColors.textPrimary;

                    if (_isAnswerLocked) {
                      if (isCorrect) {
                        bg = AppColors.brandPrimaryLight;
                        borderCol = AppColors.brandPrimary;
                        textCol = AppColors.brandPrimaryDark;
                      } else if (isSelected) {
                        bg = AppColors.errorRoseLight;
                        borderCol = AppColors.errorRose;
                        textCol = AppColors.errorRose;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: _isAnswerLocked ? null : () => _submitAnswer(index),
                        borderRadius: AppRadii.borderMd,
                        child: AnimatedContainer(
                          duration: AppMotion.shortDuration,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: AppRadii.borderMd,
                            border: Border.all(color: borderCol, width: 1.5),
                            boxShadow: isSelected ? AppShadows.subtle : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: bg,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: borderCol),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: textCol),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  q.options[index],
                                  style: TextStyle(color: textCol, fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVictoryScreen() {
    final isWin = _playerScore > _opponentScore;
    final isTie = _playerScore == _opponentScore;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isWin ? AppColors.coinGoldLight : AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isWin ? Icons.emoji_events : (isTie ? Icons.handshake : Icons.sentiment_dissatisfied),
                  size: 60,
                  color: isWin ? AppColors.coinGold : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isWin ? 'VICTORY! 🏆' : (isTie ? 'MATCH TIED! 🤝' : 'DEFEAT! 💔'),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                isWin
                  ? 'You defeated ${widget.opponentName} in 1v1 Battle!'
                  : 'Better preparation next time. Review your questions and re-match.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Final Score summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.borderLg,
                  boxShadow: AppShadows.subtle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(widget.playerName, style: AppTypography.titleSmall),
                        Text('$_playerScore pts', style: const TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.w900, fontSize: 20)),
                      ],
                    ),
                    const Text('VS', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                    Column(
                      children: [
                        Text(widget.opponentName, style: AppTypography.titleSmall),
                        Text('$_opponentScore pts', style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w900, fontSize: 20)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              AppButton(
                label: 'Return to Hub',
                width: 220,
                onPressed: widget.onExit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
