import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Test Series Metrics Row
/// Displays 5 responsive statistics cards matching the reference image.
class TestSeriesMetricsRow extends StatelessWidget {
  final int totalTestSeries;
  final int publishedCount;
  final int draftsCount;
  final int totalTests;
  final int totalEnrollments;

  const TestSeriesMetricsRow({
    super.key,
    required this.totalTestSeries,
    required this.publishedCount,
    required this.draftsCount,
    required this.totalTests,
    required this.totalEnrollments,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final isMedium = constraints.maxWidth >= 600 && constraints.maxWidth < 900;

        if (isWide) {
          return Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Test Series',
                  value: totalTestSeries.toString(),
                  badgeText: '↑ +12%',
                  isBadgePositive: true,
                  subtitle: '+5 this month',
                  icon: Icons.description_rounded,
                  iconColor: const Color(0xFF2563EB),
                  sparklineColor: const Color(0xFF2563EB),
                  bgTint: const Color(0xFFF8FAFC),
                  sparklinePoints: const [0.2, 0.4, 0.35, 0.6, 0.55, 0.8, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'Published',
                  value: publishedCount.toString(),
                  badgeText: '↑ +15%',
                  isBadgePositive: true,
                  subtitle: '+6 this month',
                  icon: Icons.assignment_turned_in_rounded,
                  iconColor: const Color(0xFF059669),
                  sparklineColor: const Color(0xFF059669),
                  bgTint: const Color(0xFFF8FAFC),
                  sparklinePoints: const [0.15, 0.3, 0.25, 0.5, 0.45, 0.75, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'Drafts',
                  value: draftsCount.toString(),
                  badgeText: '↓ -25%',
                  isBadgePositive: false,
                  subtitle: '-1 this month',
                  icon: Icons.edit_note_rounded,
                  iconColor: const Color(0xFFD97706),
                  sparklineColor: const Color(0xFFD97706),
                  bgTint: const Color(0xFFF8FAFC),
                  sparklinePoints: const [0.3, 0.45, 0.4, 0.6, 0.55, 0.85, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'Total Tests',
                  value: totalTests.toString(),
                  badgeText: '↑ +10%',
                  isBadgePositive: true,
                  subtitle: '+65 this month',
                  icon: Icons.emoji_events_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  sparklineColor: const Color(0xFF7C3AED),
                  bgTint: const Color(0xFFF8FAFC),
                  sparklinePoints: const [0.25, 0.4, 0.35, 0.65, 0.6, 0.8, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'Total Enrollments',
                  value: _formatNumber(totalEnrollments),
                  badgeText: '↑ +22%',
                  isBadgePositive: true,
                  subtitle: '+2,248 this month',
                  icon: Icons.people_alt_rounded,
                  iconColor: const Color(0xFFE11D48),
                  sparklineColor: const Color(0xFFE11D48),
                  bgTint: const Color(0xFFF8FAFC),
                  sparklinePoints: const [0.2, 0.35, 0.3, 0.55, 0.5, 0.8, 1.0],
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
                    child: _MetricCard(
                      title: 'Total Test Series',
                      value: totalTestSeries.toString(),
                      badgeText: '↑ +12%',
                      isBadgePositive: true,
                      subtitle: '+5 this month',
                      icon: Icons.description_rounded,
                      iconColor: const Color(0xFF2563EB),
                      sparklineColor: const Color(0xFF2563EB),
                      bgTint: const Color(0xFFF8FAFC),
                      sparklinePoints: const [0.2, 0.4, 0.35, 0.6, 0.55, 0.8, 1.0],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      title: 'Published',
                      value: publishedCount.toString(),
                      badgeText: '↑ +15%',
                      isBadgePositive: true,
                      subtitle: '+6 this month',
                      icon: Icons.assignment_turned_in_rounded,
                      iconColor: const Color(0xFF059669),
                      sparklineColor: const Color(0xFF059669),
                      bgTint: const Color(0xFFF8FAFC),
                      sparklinePoints: const [0.15, 0.3, 0.25, 0.5, 0.45, 0.75, 1.0],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      title: 'Drafts',
                      value: draftsCount.toString(),
                      badgeText: '↓ -25%',
                      isBadgePositive: false,
                      subtitle: '-1 this month',
                      icon: Icons.edit_note_rounded,
                      iconColor: const Color(0xFFD97706),
                      sparklineColor: const Color(0xFFD97706),
                      bgTint: const Color(0xFFF8FAFC),
                      sparklinePoints: const [0.3, 0.45, 0.4, 0.6, 0.55, 0.85, 1.0],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Total Tests',
                      value: totalTests.toString(),
                      badgeText: '↑ +10%',
                      isBadgePositive: true,
                      subtitle: '+65 this month',
                      icon: Icons.emoji_events_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      sparklineColor: const Color(0xFF7C3AED),
                      bgTint: const Color(0xFFF8FAFC),
                      sparklinePoints: const [0.25, 0.4, 0.35, 0.65, 0.6, 0.8, 1.0],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      title: 'Total Enrollments',
                      value: _formatNumber(totalEnrollments),
                      badgeText: '↑ +22%',
                      isBadgePositive: true,
                      subtitle: '+2,248 this month',
                      icon: Icons.people_alt_rounded,
                      iconColor: const Color(0xFFE11D48),
                      sparklineColor: const Color(0xFFE11D48),
                      bgTint: const Color(0xFFF8FAFC),
                      sparklinePoints: const [0.2, 0.35, 0.3, 0.55, 0.5, 0.8, 1.0],
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Mobile stack
          return Column(
            children: [
              _MetricCard(
                title: 'Total Test Series',
                value: totalTestSeries.toString(),
                badgeText: '↑ +12%',
                isBadgePositive: true,
                subtitle: '+5 this month',
                icon: Icons.description_rounded,
                iconColor: const Color(0xFF2563EB),
                sparklineColor: const Color(0xFF2563EB),
                bgTint: const Color(0xFFF8FAFC),
                sparklinePoints: const [0.2, 0.4, 0.35, 0.6, 0.55, 0.8, 1.0],
              ),
              const SizedBox(height: 8),
              _MetricCard(
                title: 'Published',
                value: publishedCount.toString(),
                badgeText: '↑ +15%',
                isBadgePositive: true,
                subtitle: '+6 this month',
                icon: Icons.assignment_turned_in_rounded,
                iconColor: const Color(0xFF059669),
                sparklineColor: const Color(0xFF059669),
                bgTint: const Color(0xFFF8FAFC),
                sparklinePoints: const [0.15, 0.3, 0.25, 0.5, 0.45, 0.75, 1.0],
              ),
              const SizedBox(height: 8),
              _MetricCard(
                title: 'Drafts',
                value: draftsCount.toString(),
                badgeText: '↓ -25%',
                isBadgePositive: false,
                subtitle: '-1 this month',
                icon: Icons.edit_note_rounded,
                iconColor: const Color(0xFFD97706),
                sparklineColor: const Color(0xFFD97706),
                bgTint: const Color(0xFFF8FAFC),
                sparklinePoints: const [0.3, 0.45, 0.4, 0.6, 0.55, 0.85, 1.0],
              ),
              const SizedBox(height: 8),
              _MetricCard(
                title: 'Total Tests',
                value: totalTests.toString(),
                badgeText: '↑ +10%',
                isBadgePositive: true,
                subtitle: '+65 this month',
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFF7C3AED),
                sparklineColor: const Color(0xFF7C3AED),
                bgTint: const Color(0xFFF8FAFC),
                sparklinePoints: const [0.25, 0.4, 0.35, 0.65, 0.6, 0.8, 1.0],
              ),
              const SizedBox(height: 8),
              _MetricCard(
                title: 'Total Enrollments',
                value: _formatNumber(totalEnrollments),
                badgeText: '↑ +22%',
                isBadgePositive: true,
                subtitle: '+2,248 this month',
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xFFE11D48),
                sparklineColor: const Color(0xFFE11D48),
                bgTint: const Color(0xFFF8FAFC),
                sparklinePoints: const [0.2, 0.35, 0.3, 0.55, 0.5, 0.8, 1.0],
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String badgeText;
  final bool isBadgePositive;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color sparklineColor;
  final Color bgTint;
  final List<double> sparklinePoints;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.badgeText,
    required this.isBadgePositive,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.sparklineColor,
    required this.bgTint,
    required this.sparklinePoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Icon Container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withAlpha(60),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 8),

          // Title, Value + Badge, Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isBadgePositive
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isBadgePositive
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Smooth Sparkline Graph
          SizedBox(
            width: 34,
            height: 24,
            child: CustomPaint(
              painter: _SparklinePainter(
                points: sparklinePoints,
                color: sparklineColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _SparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

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
        final cx1 = (prevX + x) / 2;
        path.cubicTo(cx1, prevY, cx1, y, x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}
