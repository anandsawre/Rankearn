import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/live_poll_model.dart';

class LiveResultsPanel extends StatelessWidget {
  final LivePollData pollData;
  final ValueChanged<bool> onAutoRefreshChanged;
  final VoidCallback onEndPoll;
  final VoidCallback onPauseResumePoll;
  final VoidCallback onRestartPoll;
  final VoidCallback onShowResult;
  final VoidCallback onShare;
  final VoidCallback onDownload;
  final VoidCallback onFullscreen;

  const LiveResultsPanel({
    super.key,
    required this.pollData,
    required this.onAutoRefreshChanged,
    required this.onEndPoll,
    required this.onPauseResumePoll,
    required this.onRestartPoll,
    required this.onShowResult,
    required this.onShare,
    required this.onDownload,
    required this.onFullscreen,
  });

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. TOP CARD: LIVE RESULTS + DONUT CHART
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.pollCard,
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.pollCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Bar chart icon + Title + Auto Refresh switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bar_chart_rounded, color: AppColors.pollPurplePrimary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Live Results',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        'Auto Refresh',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Switch(
                        value: pollData.autoRefresh,
                        activeThumbColor: AppColors.pollPurplePrimary,
                        activeTrackColor: AppColors.pollPurpleBorder,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: onAutoRefreshChanged,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Donut Chart with Centered Total Votes
              Center(
                child: SizedBox(
                  width: 170,
                  height: 170,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(170, 170),
                        painter: _LivePollDonutPainter(
                          options: pollData.options,
                          totalVotes: pollData.totalVotes,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatNumber(pollData.totalVotes),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Total Votes',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Option Breakdown List
              Column(
                children: pollData.options.map((opt) {
                  final pct = pollData.getPercentage(opt).round();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        // Color Indicator Pill / Dot
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: opt.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Label badge (A, B, C...)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: opt.color.withAlpha(25),
                            borderRadius: AppRadii.badge,
                          ),
                          child: Text(
                            opt.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: opt.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Option Text
                        Expanded(
                          child: Text(
                            opt.text,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Percentage
                        Text(
                          '$pct%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Count
                        SizedBox(
                          width: 48,
                          child: Text(
                            _formatNumber(opt.votes),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. BOTTOM CARD: POLL CONTROLS
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.pollCard,
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.pollCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Gear icon + Title
              const Row(
                children: [
                  Icon(Icons.settings_rounded, color: AppColors.pollPurplePrimary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Poll Controls',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action Buttons Row: End Poll, Pause/Resume, Restart
              Row(
                children: [
                  // End Poll (Red)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onEndPoll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.button,
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.stop_rounded, size: 16),
                      label: const Text(
                        'End Poll',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Pause / Resume (Orange)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onPauseResumePoll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.button,
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(
                        pollData.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        size: 16,
                      ),
                      label: Text(
                        pollData.isPaused ? 'Resume' : 'Pause',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Restart (Purple)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onRestartPoll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pollPurplePrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.button,
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text(
                        'Restart',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Bottom 4 Action Icon Buttons Grid
              Row(
                children: [
                  _buildSubActionButton(
                    icon: Icons.bar_chart_rounded,
                    label: 'Show Result',
                    onTap: onShowResult,
                  ),
                  const SizedBox(width: 8),
                  _buildSubActionButton(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    onTap: onShare,
                  ),
                  const SizedBox(width: 8),
                  _buildSubActionButton(
                    icon: Icons.download_rounded,
                    label: 'Download',
                    onTap: onDownload,
                  ),
                  const SizedBox(width: 8),
                  _buildSubActionButton(
                    icon: Icons.fullscreen_rounded,
                    label: 'Fullscreen',
                    onTap: onFullscreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.button,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: AppRadii.button,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Donut Painter rendering slices matching the screenshot with rounded gaps
class _LivePollDonutPainter extends CustomPainter {
  final List<LivePollOption> options;
  final int totalVotes;

  const _LivePollDonutPainter({
    required this.options,
    required this.totalVotes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 14;
    final strokeWidth = 24.0;

    if (totalVotes == 0 || options.isEmpty) {
      final basePaint = Paint()
        ..color = AppColors.borderSubtle
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, basePaint);
      return;
    }

    final gap = 0.04; // rad gap between slices
    double startAngle = -math.pi / 2;

    for (final opt in options) {
      final sweepAngle = (opt.votes / totalVotes) * (2 * math.pi);
      if (sweepAngle <= 0) continue;

      final paint = Paint()
        ..color = opt.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final actualSweep = math.max(0.01, sweepAngle - gap);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + (gap / 2),
        actualSweep,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _LivePollDonutPainter oldDelegate) {
    return oldDelegate.totalVotes != totalVotes ||
        oldDelegate.options.length != options.length;
  }
}

