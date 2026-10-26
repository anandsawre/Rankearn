import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Tournaments Metrics Row
/// Displays 5 responsive statistics cards with sparklines and trend pills matching the reference image.
class TournamentsMetricsRow extends StatelessWidget {
  final int totalTournaments;
  final int totalParticipants;
  final int completedTournaments;
  final int ongoingTournaments;
  final int upcomingTournaments;

  const TournamentsMetricsRow({
    super.key,
    this.totalTournaments = 24,
    this.totalParticipants = 12450,
    this.completedTournaments = 16,
    this.ongoingTournaments = 3,
    this.upcomingTournaments = 5,
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
                child: _TournamentsMetricCard(
                  title: 'Total Tournaments',
                  value: totalTournaments.toString(),
                  badgeText: '↑ +26%',
                  isBadgePositive: true,
                  subtitle: '+5 this month',
                  icon: Icons.emoji_events_rounded,
                  iconColor: const Color(0xFF6B4EFF),
                  sparklineColor: const Color(0xFF6B4EFF),
                  sparklinePoints: const [0.2, 0.4, 0.35, 0.65, 0.5, 0.85, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TournamentsMetricCard(
                  title: 'Total Participants',
                  value: _formatNumber(totalParticipants),
                  badgeText: '↑ +32%',
                  isBadgePositive: true,
                  subtitle: '+2,184 this month',
                  icon: Icons.people_alt_rounded,
                  iconColor: const Color(0xFF2587F8),
                  sparklineColor: const Color(0xFF2587F8),
                  sparklinePoints: const [0.15, 0.35, 0.3, 0.6, 0.55, 0.8, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TournamentsMetricCard(
                  title: 'Completed',
                  value: completedTournaments.toString(),
                  badgeText: '↑ +14%',
                  isBadgePositive: true,
                  subtitle: '+2 this month',
                  icon: Icons.check_circle_rounded,
                  iconColor: const Color(0xFF00C48C),
                  sparklineColor: const Color(0xFF00C48C),
                  sparklinePoints: const [0.3, 0.4, 0.5, 0.45, 0.7, 0.85, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TournamentsMetricCard(
                  title: 'Ongoing',
                  value: ongoingTournaments.toString(),
                  badgeText: '↑ +200%',
                  isBadgePositive: true,
                  subtitle: '+2 this month',
                  icon: Icons.access_time_rounded,
                  iconColor: const Color(0xFFFF9F0A),
                  sparklineColor: const Color(0xFFFF9F0A),
                  sparklinePoints: const [0.1, 0.3, 0.25, 0.5, 0.45, 0.9, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TournamentsMetricCard(
                  title: 'Upcoming',
                  value: upcomingTournaments.toString(),
                  badgeText: '↑ +25%',
                  isBadgePositive: true,
                  subtitle: '+1 this month',
                  icon: Icons.calendar_month_rounded,
                  iconColor: const Color(0xFFF04483),
                  sparklineColor: const Color(0xFFF04483),
                  sparklinePoints: const [0.2, 0.3, 0.4, 0.55, 0.5, 0.8, 1.0],
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
                    child: _TournamentsMetricCard(
                      title: 'Total Tournaments',
                      value: totalTournaments.toString(),
                      badgeText: '↑ +26%',
                      isBadgePositive: true,
                      subtitle: '+5 this month',
                      icon: Icons.emoji_events_rounded,
                      iconColor: const Color(0xFF6B4EFF),
                      sparklineColor: const Color(0xFF6B4EFF),
                      sparklinePoints: const [0.2, 0.4, 0.35, 0.65, 0.5, 0.85, 1.0],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TournamentsMetricCard(
                      title: 'Total Participants',
                      value: _formatNumber(totalParticipants),
                      badgeText: '↑ +32%',
                      isBadgePositive: true,
                      subtitle: '+2,184 this month',
                      icon: Icons.people_alt_rounded,
                      iconColor: const Color(0xFF2587F8),
                      sparklineColor: const Color(0xFF2587F8),
                      sparklinePoints: const [0.15, 0.35, 0.3, 0.6, 0.55, 0.8, 1.0],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _TournamentsMetricCard(
                      title: 'Completed',
                      value: completedTournaments.toString(),
                      badgeText: '↑ +14%',
                      isBadgePositive: true,
                      subtitle: '+2 this month',
                      icon: Icons.check_circle_rounded,
                      iconColor: const Color(0xFF00C48C),
                      sparklineColor: const Color(0xFF00C48C),
                      sparklinePoints: const [0.3, 0.4, 0.5, 0.45, 0.7, 0.85, 1.0],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TournamentsMetricCard(
                      title: 'Ongoing',
                      value: ongoingTournaments.toString(),
                      badgeText: '↑ +200%',
                      isBadgePositive: true,
                      subtitle: '+2 this month',
                      icon: Icons.access_time_rounded,
                      iconColor: const Color(0xFFFF9F0A),
                      sparklineColor: const Color(0xFFFF9F0A),
                      sparklinePoints: const [0.1, 0.3, 0.25, 0.5, 0.45, 0.9, 1.0],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TournamentsMetricCard(
                      title: 'Upcoming',
                      value: upcomingTournaments.toString(),
                      badgeText: '↑ +25%',
                      isBadgePositive: true,
                      subtitle: '+1 this month',
                      icon: Icons.calendar_month_rounded,
                      iconColor: const Color(0xFFF04483),
                      sparklineColor: const Color(0xFFF04483),
                      sparklinePoints: const [0.2, 0.3, 0.4, 0.55, 0.5, 0.8, 1.0],
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _TournamentsMetricCard(
                title: 'Total Tournaments',
                value: totalTournaments.toString(),
                badgeText: '↑ +26%',
                isBadgePositive: true,
                subtitle: '+5 this month',
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFF6B4EFF),
                sparklineColor: const Color(0xFF6B4EFF),
                sparklinePoints: const [0.2, 0.4, 0.35, 0.65, 0.5, 0.85, 1.0],
              ),
              const SizedBox(height: 8),
              _TournamentsMetricCard(
                title: 'Total Participants',
                value: _formatNumber(totalParticipants),
                badgeText: '↑ +32%',
                isBadgePositive: true,
                subtitle: '+2,184 this month',
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xFF2587F8),
                sparklineColor: const Color(0xFF2587F8),
                sparklinePoints: const [0.15, 0.35, 0.3, 0.6, 0.55, 0.8, 1.0],
              ),
              const SizedBox(height: 8),
              _TournamentsMetricCard(
                title: 'Completed',
                value: completedTournaments.toString(),
                badgeText: '↑ +14%',
                isBadgePositive: true,
                subtitle: '+2 this month',
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF00C48C),
                sparklineColor: const Color(0xFF00C48C),
                sparklinePoints: const [0.3, 0.4, 0.5, 0.45, 0.7, 0.85, 1.0],
              ),
              const SizedBox(height: 8),
              _TournamentsMetricCard(
                title: 'Ongoing',
                value: ongoingTournaments.toString(),
                badgeText: '↑ +200%',
                isBadgePositive: true,
                subtitle: '+2 this month',
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFFFF9F0A),
                sparklineColor: const Color(0xFFFF9F0A),
                sparklinePoints: const [0.1, 0.3, 0.25, 0.5, 0.45, 0.9, 1.0],
              ),
              const SizedBox(height: 8),
              _TournamentsMetricCard(
                title: 'Upcoming',
                value: upcomingTournaments.toString(),
                badgeText: '↑ +25%',
                isBadgePositive: true,
                subtitle: '+1 this month',
                icon: Icons.calendar_month_rounded,
                iconColor: const Color(0xFFF04483),
                sparklineColor: const Color(0xFFF04483),
                sparklinePoints: const [0.2, 0.3, 0.4, 0.55, 0.5, 0.8, 1.0],
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

class _TournamentsMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String badgeText;
  final bool isBadgePositive;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color sparklineColor;
  final List<double> sparklinePoints;

  const _TournamentsMetricCard({
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
          // Circular Icon Container on Left
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withAlpha(65),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 8),

          // Title, Value + Badge, Subtitle (to the right of the icon)
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
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: isBadgePositive
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: isBadgePositive
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
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

          // Smooth Sparkline Graph on Far Right
          SizedBox(
            width: 42,
            height: 24,
            child: CustomPaint(
              painter: _TournamentsSparklinePainter(
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

class _TournamentsSparklinePainter extends CustomPainter {
  final Color color;
  final List<double> points;

  _TournamentsSparklinePainter({required this.color, required this.points});

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
      final y = size.height - (points[i] * size.height * 0.85);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * dx;
        final prevY = size.height - (points[i - 1] * size.height * 0.85);
        final cx = (prevX + x) / 2;
        path.cubicTo(cx, prevY, cx, y, x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TournamentsSparklinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.points != points;
}
