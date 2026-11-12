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
        gradientColors: const [AppColors.liveRedDark, AppColors.liveRed],
        maxWidth: 440,
        actions: [
          AppModalDialog.cancelButton(ctx),
          AppModalDialog.primaryButton(
            backgroundColor: AppColors.liveRedDark,
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              widget.onSessionEnded?.call();
            },
            child: const Text(
              'Confirm End',
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
        child: Text(
          'Ending the session will calculate final scores and publish the leaderboard to all participants.',
          style: AppTypography.bodySmall.copyWith(fontSize: 13, color: AppColors.textSecondary, height: 1.45),
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
      maxWidth: 680,
      scrollable: true,
      actions: [
        AppModalDialog.secondaryButton(
          onPressed: _endSession,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stop_circle_outlined, size: 16, color: AppColors.liveRed),
              SizedBox(width: 6),
              Text(
                'End Session',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  color: AppColors.liveRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        AppModalDialog.secondaryButton(
          onPressed: _togglePause,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                size: 16,
                color: _isPaused ? AppColors.brandGreen : AppModalDialog.defaultPrimaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                _isPaused ? 'Resume' : 'Pause',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  color: _isPaused ? AppColors.brandGreen : AppModalDialog.defaultPrimaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        AppModalDialog.primaryButton(
          onPressed: _currentQ < totalQ ? _nextQuestion : null,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.skip_next_rounded, size: 16),
              SizedBox(width: 6),
              Text(
                'Next Question',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
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
                  color: AppColors.brandBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Serving Question',
                  value: '$_currentQ / $totalQ',
                  icon: Icons.help_outline_rounded,
                  color: AppModalDialog.defaultPrimaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Question Timer',
                  value: '${_secondsLeft}s',
                  icon: Icons.timer_outlined,
                  color: _secondsLeft < 10 ? AppColors.liveRed : AppColors.brandOrange,
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
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppModalDialog.defaultPrimaryColor),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Responses Distribution
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: AppRadii.cardSubtle,
              border: Border.all(color: AppColors.border),
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
                          color: AppColors.brandGreenLight,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.check_rounded, color: AppColors.brandGreenDark, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$_correctAnswers Correct', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.brandGreenDark)),
                          const Text('Submitted answers', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
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
                          color: AppColors.liveRedSubtle,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.close_rounded, color: AppColors.liveRedDark, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$_incorrectAnswers Incorrect', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.liveRedDark)),
                          const Text('Submitted answers', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
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
        color: AppColors.surfaceSubtle,
        borderRadius: AppRadii.cardSubtle,
        border: Border.all(color: AppColors.border),
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
