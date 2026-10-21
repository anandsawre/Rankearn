import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// AI Test Creator Metrics Row
/// Displays 5 responsive statistics cards with cubic Bezier sparklines and trend pills matching the reference image.
class AiTestCreatorMetricsRow extends StatelessWidget {
  final int testsGenerated;
  final int questionsCreated;
  final int savedTests;
  final int timesUsed;
  final String avgCreationTime;

  const AiTestCreatorMetricsRow({
    super.key,
    this.testsGenerated = 124,
    this.questionsCreated = 12580,
    this.savedTests = 68,
    this.timesUsed = 3245,
    this.avgCreationTime = '34 sec',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;
        final isMedium = constraints.maxWidth >= 600 && constraints.maxWidth < 960;

        if (isWide) {
          return Row(
            children: [
              Expanded(
                child: _AiMetricCard(
                  title: 'Tests Generated',
                  value: _formatNumber(testsGenerated),
                  badgeText: '↑ +28%',
                  isBadgePositive: true,
                  subtitle: '+27 this month',
                  icon: Icons.description_rounded,
                  iconColor: const Color(0xFF5636F5),
                  sparklineColor: const Color(0xFF5636F5),
                  sparklinePoints: const [0.2, 0.4, 0.35, 0.65, 0.5, 0.85, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AiMetricCard(
                  title: 'Questions Created',
                  value: _formatNumber(questionsCreated),
                  badgeText: '↑ +18%',
                  isBadgePositive: true,
                  subtitle: '+2,458 this month',
                  icon: Icons.check_circle_rounded,
                  iconColor: const Color(0xFF10B981),
                  sparklineColor: const Color(0xFF10B981),
                  sparklinePoints: const [0.15, 0.35, 0.3, 0.6, 0.55, 0.8, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AiMetricCard(
                  title: 'Saved Tests',
                  value: _formatNumber(savedTests),
                  badgeText: '↑ +32%',
                  isBadgePositive: true,
                  subtitle: '+17 this month',
                  icon: Icons.folder_rounded,
                  iconColor: const Color(0xFFFF9F0A),
                  sparklineColor: const Color(0xFFFF9F0A),
                  sparklinePoints: const [0.3, 0.4, 0.5, 0.45, 0.7, 0.85, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AiMetricCard(
                  title: 'Times Used',
                  value: _formatNumber(timesUsed),
                  badgeText: '↑ +22%',
                  isBadgePositive: true,
                  subtitle: '+582 this month',
                  icon: Icons.people_rounded,
                  iconColor: const Color(0xFF2587F8),
                  sparklineColor: const Color(0xFF2587F8),
                  sparklinePoints: const [0.2, 0.3, 0.5, 0.4, 0.65, 0.85, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AiMetricCard(
                  title: 'Avg. Creation Time (AI Speed)',
                  value: avgCreationTime,
                  badgeText: '↓ -40%',
                  isBadgePositive: true, // Lower creation time is positive in AI speed
                  subtitle: 'Faster than last month',
                  icon: Icons.track_changes_rounded,
                  iconColor: const Color(0xFFF04483),
                  sparklineColor: const Color(0xFF10B981),
                  sparklinePoints: const [0.9, 0.8, 0.6, 0.55, 0.4, 0.25, 0.1],
                ),
              ),
            ],
          );
        } else if (isMedium) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _AiMetricCard(
                      title: 'Tests Generated',
                      value: _formatNumber(testsGenerated),
                      badgeText: '↑ +28%',
                      isBadgePositive: true,
                      subtitle: '+27 this month',
                      icon: Icons.description_rounded,
                      iconColor: const Color(0xFF5636F5),
                      sparklineColor: const Color(0xFF5636F5),
                      sparklinePoints: const [0.2, 0.4, 0.35, 0.65, 0.5, 0.85, 1.0],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AiMetricCard(
                      title: 'Questions Created',
                      value: _formatNumber(questionsCreated),
                      badgeText: '↑ +18%',
                      isBadgePositive: true,
                      subtitle: '+2,458 this month',
                      icon: Icons.check_circle_rounded,
                      iconColor: const Color(0xFF10B981),
                      sparklineColor: const Color(0xFF10B981),
                      sparklinePoints: const [0.15, 0.35, 0.3, 0.6, 0.55, 0.8, 1.0],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _AiMetricCard(
                      title: 'Saved Tests',
                      value: _formatNumber(savedTests),
                      badgeText: '↑ +32%',
                      isBadgePositive: true,
                      subtitle: '+17 this month',
                      icon: Icons.folder_rounded,
                      iconColor: const Color(0xFFFF9F0A),
                      sparklineColor: const Color(0xFFFF9F0A),
                      sparklinePoints: const [0.3, 0.4, 0.5, 0.45, 0.7, 0.85, 1.0],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AiMetricCard(
                      title: 'Times Used',
                      value: _formatNumber(timesUsed),
                      badgeText: '↑ +22%',
                      isBadgePositive: true,
                      subtitle: '+582 this month',
                      icon: Icons.people_rounded,
                      iconColor: const Color(0xFF2587F8),
                      sparklineColor: const Color(0xFF2587F8),
                      sparklinePoints: const [0.2, 0.3, 0.5, 0.4, 0.65, 0.85, 1.0],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _AiMetricCard(
                title: 'Avg. Creation Time (AI Speed)',
                value: avgCreationTime,
                badgeText: '↓ -40%',
                isBadgePositive: true,
                subtitle: 'Faster than last month',
                icon: Icons.track_changes_rounded,
                iconColor: const Color(0xFFF04483),
                sparklineColor: const Color(0xFF10B981),
                sparklinePoints: const [0.9, 0.8, 0.6, 0.55, 0.4, 0.25, 0.1],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _AiMetricCard(
                title: 'Tests Generated',
                value: _formatNumber(testsGenerated),
                badgeText: '↑ +28%',
                isBadgePositive: true,
                subtitle: '+27 this month',
                icon: Icons.description_rounded,
                iconColor: const Color(0xFF5636F5),
                sparklineColor: const Color(0xFF5636F5),
                sparklinePoints: const [0.2, 0.4, 0.35, 0.65, 0.5, 0.85, 1.0],
              ),
              const SizedBox(height: 10),
              _AiMetricCard(
                title: 'Questions Created',
                value: _formatNumber(questionsCreated),
                badgeText: '↑ +18%',
                isBadgePositive: true,
                subtitle: '+2,458 this month',
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF10B981),
                sparklineColor: const Color(0xFF10B981),
                sparklinePoints: const [0.15, 0.35, 0.3, 0.6, 0.55, 0.8, 1.0],
              ),
              const SizedBox(height: 10),
              _AiMetricCard(
                title: 'Saved Tests',
                value: _formatNumber(savedTests),
                badgeText: '↑ +32%',
                isBadgePositive: true,
                subtitle: '+17 this month',
                icon: Icons.folder_rounded,
                iconColor: const Color(0xFFFF9F0A),
                sparklineColor: const Color(0xFFFF9F0A),
                sparklinePoints: const [0.3, 0.4, 0.5, 0.45, 0.7, 0.85, 1.0],
              ),
              const SizedBox(height: 10),
              _AiMetricCard(
                title: 'Times Used',
                value: _formatNumber(timesUsed),
                badgeText: '↑ +22%',
                isBadgePositive: true,
                subtitle: '+582 this month',
                icon: Icons.people_rounded,
                iconColor: const Color(0xFF2587F8),
                sparklineColor: const Color(0xFF2587F8),
                sparklinePoints: const [0.2, 0.3, 0.5, 0.4, 0.65, 0.85, 1.0],
              ),
              const SizedBox(height: 10),
              _AiMetricCard(
                title: 'Avg. Creation Time (AI Speed)',
                value: avgCreationTime,
                badgeText: '↓ -40%',
                isBadgePositive: true,
                subtitle: 'Faster than last month',
                icon: Icons.track_changes_rounded,
                iconColor: const Color(0xFFF04483),
                sparklineColor: const Color(0xFF10B981),
                sparklinePoints: const [0.9, 0.8, 0.6, 0.55, 0.4, 0.25, 0.1],
              ),
            ],
          );
        }
      },
    );
  }

  static String _formatNumber(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final len = s.length;
      final part1 = s.substring(0, len - 3);
      final part2 = s.substring(len - 3);
      return '$part1,$part2';
    }
    return n.toString();
  }
}

class _AiMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String badgeText;
  final bool isBadgePositive;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color sparklineColor;
  final List<double> sparklinePoints;

  const _AiMetricCard({
    required this.title,
    required this.value,
    required this.badgeText,
    required this.isBadgePositive,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.sparklineColor,
    required this.sparklinePoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3EAF7), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Icon on the Left
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 9),

          // 2. Info to the right of the icon: Title, Value + Badge, Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Value and Trend Badge
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101A3A),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isBadgePositive
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isBadgePositive
                                ? const Color(0xFFA7F3D0)
                                : const Color(0xFFFECDD3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isBadgePositive
                                ? const Color(0xFF059669)
                                : const Color(0xFFE11D48),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),

                // Subtitle
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 3. Sparkline on the Far Right
          const SizedBox(width: 4),
          SizedBox(
            width: 38,
            height: 20,
            child: CustomPaint(
              painter: _AiSparklinePainter(
                color: sparklineColor,
                points: sparklinePoints,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiSparklinePainter extends CustomPainter {
  final Color color;
  final List<double> points;

  _AiSparklinePainter({required this.color, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final dx = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final x = i * dx;
      final y = size.height - (points[i] * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * dx;
        final prevY = size.height - (points[i - 1] * size.height);
        final cx1 = prevX + (dx / 2);
        final cy1 = prevY;
        final cx2 = prevX + (dx / 2);
        final cy2 = y;
        path.cubicTo(cx1, cy1, cx2, cy2, x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AiSparklinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.points != points;
}
