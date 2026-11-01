import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_layer/data_layer.dart';

class MultiplayerArenaScreen extends StatefulWidget {
  final String arenaTitle;
  final String subject;
  final int totalPlayers;
  final int entryFee;
  final int prizePool;
  final UserProfile profile;
  final int userCoins;
  final void Function(int coinsDelta)? onCoinUpdate;

  const MultiplayerArenaScreen({
    super.key,
    required this.arenaTitle,
    required this.subject,
    this.totalPlayers = 50,
    this.entryFee = 50,
    this.prizePool = 2250,
    required this.profile,
    required this.userCoins,
    this.onCoinUpdate,
  });

  @override
  State<MultiplayerArenaScreen> createState() => _MultiplayerArenaScreenState();
}

class _MultiplayerArenaScreenState extends State<MultiplayerArenaScreen> {
  final BattleRepository _repository = BattleRepository();
  List<BattleQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _userRank = 12;
  int _turnSeconds = 15;
  int? _selectedOption;
  bool _isAnswerLocked = false;
  Timer? _turnTimer;
  Timer? _rankShiftTimer;

  // Live competitors leaderboard
  final List<Map<String, dynamic>> _leaderboard = [
    {'rank': 1, 'name': 'Aditya Sharma', 'score': 45, 'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100'},
    {'rank': 2, 'name': 'Sneha Rao', 'score': 40, 'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100'},
    {'rank': 3, 'name': 'Karan Verma', 'score': 38, 'avatar': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=100'},
    {'rank': 4, 'name': 'Pooja Singh', 'score': 35, 'avatar': 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=100'},
    {'rank': 5, 'name': 'Rahul Nair', 'score': 32, 'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100'},
  ];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startSimulatedLeaderboardShifts();
  }

  Future<void> _loadQuestions() async {
    final res = await _repository.getLiveBattleQuestions();
    if (res is Success<List<BattleQuestion>> && mounted) {
      setState(() {
        _questions = res.data;
        _startQuestionTimer();
      });
    }
  }

  void _startQuestionTimer() {
    _turnTimer?.cancel();
    _turnSeconds = 15;
    _isAnswerLocked = false;
    _selectedOption = null;

    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_turnSeconds > 1) {
        setState(() => _turnSeconds--);
      } else {
        _turnTimer?.cancel();
        _handleTimeExpired();
      }
    });
  }

  void _startSimulatedLeaderboardShifts() {
    _rankShiftTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        for (var p in _leaderboard) {
          p['score'] = (p['score'] as int) + (timer.tick % 2 == 0 ? 5 : 0);
        }
        _leaderboard.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
        for (int i = 0; i < _leaderboard.length; i++) {
          _leaderboard[i]['rank'] = i + 1;
        }
      });
    });
  }

  void _handleTimeExpired() {
    if (!_isAnswerLocked) {
      _submitAnswer(timedOut: true);
    }
  }

  void _onOptionTap(int index) {
    if (_isAnswerLocked) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedOption = index);
    _submitAnswer();
  }

  void _submitAnswer({bool timedOut = false}) {
    if (_isAnswerLocked) return;
    _turnTimer?.cancel();
    setState(() => _isAnswerLocked = true);

    final q = _questions[_currentQuestionIndex];
    final isCorrect = !timedOut && _selectedOption == q.correctAnswer;

    if (isCorrect) {
      HapticFeedback.mediumImpact();
      _score += 15;
      _userRank = (_userRank - 2).clamp(1, widget.totalPlayers);
    } else {
      HapticFeedback.vibrate();
      _userRank = (_userRank + 1).clamp(1, widget.totalPlayers);
    }

    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
        });
        _startQuestionTimer();
      } else {
        _showTournamentResults();
      }
    });
  }

  void _showTournamentResults() {
    final isTopThree = _userRank <= 3;
    final coinsWon = isTopThree
        ? (_userRank == 1 ? (widget.prizePool * 0.5).toInt() : (widget.prizePool * 0.25).toInt())
        : 0;

    if (coinsWon > 0) {
      HapticFeedback.heavyImpact();
      widget.onCoinUpdate?.call(coinsWon);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isTopThree ? Icons.emoji_events_rounded : Icons.military_tech_rounded,
              color: isTopThree ? const Color(0xFFF59E0B) : const Color(0xFF64748B),
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              isTopThree ? 'Podium Finish! 🏆' : 'Match Completed',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Final Rank: #$_userRank / ${widget.totalPlayers}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 4),
            Text(
              'Total Score: $_score Points',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED)),
            ),
            const SizedBox(height: 14),
            if (coinsWon > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: Color(0xFF16A34A)),
                    const SizedBox(width: 8),
                    Text(
                      '+$coinsWon Coins Won!',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF16A34A), fontSize: 15),
                    ),
                  ],
                ),
              )
            else
              const Text(
                'Top 3 winners take home the prize pool. Practice more and conquer the next arena!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Return to Battle Hub'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    _rankShiftTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F8FF),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
      );
    }

    final q = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.arenaTitle,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            ),
            Text(
              '${widget.subject} • ${widget.totalPlayers} Contestants Live',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFEF4444)),
                const SizedBox(width: 4),
                Text(
                  '${_turnSeconds}s',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFEF4444), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Rank Strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA855F7)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Color(0x337C3AED), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Text(
                        widget.profile.name.isNotEmpty ? widget.profile.name[0].toUpperCase() : 'U',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF7C3AED)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.profile.name.isNotEmpty ? widget.profile.name : 'Vikram Singh',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          Text(
                            'Score: $_score Points',
                            style: const TextStyle(color: Color(0xFFE9D5FF), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Rank #$_userRank',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Question Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QUESTION ${_currentQuestionIndex + 1} OF ${_questions.length}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
                  ),
                  Text(
                    'Pool: ${widget.prizePool} Coins',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Question Surface Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
                  ],
                ),
                child: Text(
                  q.questionText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.35),
                ),
              ),
              const SizedBox(height: 16),

              // Options
              ...List.generate(q.options.length, (idx) {
                final optionText = q.options[idx];
                final isSelected = _selectedOption == idx;
                final isCorrectOption = idx == q.correctAnswer;

                Color tileBg = Colors.white;
                Color borderCol = const Color(0xFFE2E8F0);
                Color textCol = const Color(0xFF1E293B);

                if (_isAnswerLocked) {
                  if (isSelected && isCorrectOption) {
                    tileBg = const Color(0xFFDCFCE7);
                    borderCol = const Color(0xFF16A34A);
                    textCol = const Color(0xFF15803D);
                  } else if (isSelected && !isCorrectOption) {
                    tileBg = const Color(0xFFFEE2E2);
                    borderCol = const Color(0xFFEF4444);
                    textCol = const Color(0xFFB91C1C);
                  } else if (isCorrectOption) {
                    tileBg = const Color(0xFFDCFCE7);
                    borderCol = const Color(0xFF16A34A);
                    textCol = const Color(0xFF15803D);
                  }
                } else if (isSelected) {
                  tileBg = const Color(0xFFF3E8FF);
                  borderCol = const Color(0xFF7C3AED);
                  textCol = const Color(0xFF7C3AED);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => _onOptionTap(idx),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: tileBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderCol, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: borderCol.withValues(alpha: 0.2),
                            child: Text(
                              String.fromCharCode(65 + idx),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: textCol),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              optionText,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textCol),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Live Top 5 Leaderboard Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.leaderboard_rounded, size: 18, color: Color(0xFF7C3AED)),
                        SizedBox(width: 8),
                        Text(
                          'Live Arena Leaderboard',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(_leaderboard.length, (index) {
                      final p = _leaderboard[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              '#${p['rank']}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color: index == 0
                                    ? const Color(0xFFF59E0B)
                                    : (index == 1 ? const Color(0xFF94A3B8) : const Color(0xFFB45309)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                p['name'] as String,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                              ),
                            ),
                            Text(
                              '${p['score']} pts',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF7C3AED)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
