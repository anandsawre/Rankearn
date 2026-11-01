import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/live_quiz_item.dart';

/// Live Session Monitoring Dashboard Dialog
/// Displays real-time quiz session status, participants, current question, and session controls.
class LiveNowDashboardDialog extends StatefulWidget {
  final LiveQuizItem item;
  final VoidCallback? onSessionEnded;

  const LiveNowDashboardDialog({
    super.key,
    required this.item,
    this.onSessionEnded,
  });

  @override
  State<LiveNowDashboardDialog> createState() => _LiveNowDashboardDialogState();
}

class _LiveNowDashboardDialogState extends State<LiveNowDashboardDialog> {
  late int _currentQ;
  late int _connectedUsers;
  int _secondsLeft = 45;
  bool _isPaused = false;
  Timer? _timer;
  int _correctAnswers = 1420;
  int _incorrectAnswers = 430;

  @override
  void initState() {
    super.initState();
    _currentQ = widget.item.currentQuestionIndex;
    _connectedUsers = widget.item.participantsCount > 0 ? widget.item.participantsCount : 1240;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isPaused && mounted) {
        setState(() {
          if (_secondsLeft > 0) {
            _secondsLeft--;
          } else {
            _nextQuestion();
          }
        });
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQ < widget.item.totalQuestions) {
        _currentQ++;
        _secondsLeft = 45;
        _correctAnswers = (_correctAnswers * 1.05).toInt().clamp(500, 3000);
        _incorrectAnswers = (_incorrectAnswers * 0.95).toInt().clamp(200, 1500);
      }
    });
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  void _endSession() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => AppModalDialog(
        title: 'End Live Quiz Session?',
        subtitle: 'Final score computation & leaderboard publication',
        iconData: Icons.stop_circle_outlined,
        gradientColors: const [Color(0xFFDC2626), Color(0xFFEF4444)],
        maxWidth: 440,
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              widget.onSessionEnded?.call();
            },
            child: const Text('Confirm End', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
        child: const Text(
          'Ending the session will calculate final scores and publish the leaderboard to all participants.',
          style: TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.45),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalQ = widget.item.totalQuestions;
    final progress = _currentQ / totalQ;

    return AppModalDialog(
      title: widget.item.title,
      subtitle: 'LIVE NOW • Real-time Session Monitor (${widget.item.category})',
      iconData: Icons.podcasts_rounded,
      gradientColors: const [Color(0xFFDC2626), Color(0xFFEF4444)],
      maxWidth: 680,
      scrollable: true,
      actions: [
        OutlinedButton.icon(
          onPressed: _endSession,
          icon: const Icon(Icons.stop_circle_outlined, size: 16, color: Color(0xFFEF4444)),
          label: const Text('End Session', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700, fontSize: 12.5)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFFCA5A5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _togglePause,
          icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 16),
          label: Text(_isPaused ? 'Resume' : 'Pause', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isPaused ? const Color(0xFF10B981) : const Color(0xFFFF9F0A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 0,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _currentQ < totalQ ? _nextQuestion : null,
          icon: const Icon(Icons.skip_next_rounded, size: 16),
          label: const Text('Next Question', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5636F5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 0,
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Metric Cards Row
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Connected Users',
                  value: _connectedUsers.toString(),
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF2587F8),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Serving Question',
                  value: '$_currentQ / $totalQ',
                  icon: Icons.help_outline_rounded,
                  color: const Color(0xFF5636F5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Question Timer',
                  value: '${_secondsLeft}s',
                  icon: Icons.timer_outlined,
                  color: _secondsLeft < 10 ? const Color(0xFFEF4444) : const Color(0xFFFF9F0A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Session Progress (Question $_currentQ of $totalQ)',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5636F5)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Responses Distribution
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.check_rounded, color: Color(0xFF16A34A), size: 16),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$_correctAnswers Correct', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                          const Text('Submitted answers', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.close_rounded, color: Color(0xFFDC2626), size: 16),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$_incorrectAnswers Incorrect', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
                          const Text('Submitted answers', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                const SizedBox(height: 1),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
