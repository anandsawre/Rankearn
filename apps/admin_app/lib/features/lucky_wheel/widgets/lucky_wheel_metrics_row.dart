import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Lucky Wheel Metrics Row
/// Displays 5 responsive statistics cards matching the reference image.
class LuckyWheelMetricsRow extends StatelessWidget {
  final int totalCampaigns;
  final int totalParticipants;
  final int totalRewardsGiven;
  final int activeCampaigns;
  final int totalSpins;

  const LuckyWheelMetricsRow({
    super.key,
    this.totalCampaigns = 18,
    this.totalParticipants = 24560,
    this.totalRewardsGiven = 12450,
    this.activeCampaigns = 5,
    this.totalSpins = 78320,
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
                child: _WheelMetricCard(
                  title: 'Total Campaigns',
                  value: _formatNumber(totalCampaigns),
                  badgeText: '↑ +28%',
                  isBadgePositive: true,
                  subtitle: '+4 this month',
                  icon: Icons.track_changes_rounded,
                  iconColor: const Color(0xFF5636F5),
                  sparklineColor: const Color(0xFF5636F5),
                  sparklinePoints: const [0.2, 0.4, 0.35, 0.65, 0.5, 0.85, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _WheelMetricCard(
                  title: 'Total Participants',
                  value: _formatNumber(totalParticipants),
                  badgeText: '↑ +32%',
                  isBadgePositive: true,
                  subtitle: '+5,842 this month',
                  icon: Icons.group_rounded,
                  iconColor: const Color(0xFF2587F8),
                  sparklineColor: const Color(0xFF2587F8),
                  sparklinePoints: const [0.15, 0.35, 0.3, 0.6, 0.55, 0.8, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _WheelMetricCard(
                  title: 'Total Rewards Given',
                  value: _formatNumber(totalRewardsGiven),
                  badgeText: '↑ +18%',
                  isBadgePositive: true,
                  subtitle: '+2,210 this month',
                  icon: Icons.card_giftcard_rounded,
                  iconColor: const Color(0xFF10B981),
                  sparklineColor: const Color(0xFF10B981),
                  sparklinePoints: const [0.3, 0.4, 0.5, 0.45, 0.7, 0.85, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _WheelMetricCard(
                  title: 'Active Campaigns',
                  value: _formatNumber(activeCampaigns),
                  badgeText: '↑ +25%',
                  isBadgePositive: true,
                  subtitle: '+1 this month',
                  icon: Icons.poll_rounded,
                  iconColor: const Color(0xFFFF9F0A),
                  sparklineColor: const Color(0xFFFF9F0A),
                  sparklinePoints: const [0.2, 0.3, 0.5, 0.4, 0.65, 0.85, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _WheelMetricCard(
                  title: 'Total Spins',
                  value: _formatNumber(totalSpins),
                  badgeText: '↑ +22%',
                  isBadgePositive: true,
                  subtitle: '+12,450 this month',
                  icon: Icons.groups_rounded,
                  iconColor: const Color(0xFFF04483),
                  sparklineColor: const Color(0xFFF04483),
                  sparklinePoints: const [0.25, 0.45, 0.4, 0.7, 0.6, 0.88, 1.0],
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
                    child: _WheelMetricCard(
                      title: 'Total Campaigns',
                      value: _formatNumber(totalCampaigns),
                      badgeText: '↑ +28%',
                      isBadgePositive: true,
                      subtitle: '+4 this month',
                      icon: Icons.track_changes_rounded,
                      iconColor: const Color(0xFF5636F5),
                      sparklineColor: const Color(0xFF5636F5),
                      sparklinePoints: const [0.2, 0.4, 0.35, 0.65, 0.5, 0.85, 1.0],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _WheelMetricCard(
                      title: 'Total Participants',
                      value: _formatNumber(totalParticipants),
                      badgeText: '↑ +32%',
                      isBadgePositive: true,
                      subtitle: '+5,842 this month',
                      icon: Icons.group_rounded,
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
                    child: _WheelMetricCard(
                      title: 'Total Rewards Given',
                      value: _formatNumber(totalRewardsGiven),
                      badgeText: '↑ +18%',
                      isBadgePositive: true,
                      subtitle: '+2,210 this month',
                      icon: Icons.card_giftcard_rounded,
                      iconColor: const Color(0xFF10B981),
                      sparklineColor: const Color(0xFF10B981),
                      sparklinePoints: const [0.3, 0.4, 0.5, 0.45, 0.7, 0.85, 1.0],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _WheelMetricCard(
                      title: 'Active Campaigns',
                      value: _formatNumber(activeCampaigns),
                      badgeText: '↑ +25%',
                      isBadgePositive: true,
                      subtitle: '+1 this month',
                      icon: Icons.poll_rounded,
                      iconColor: const Color(0xFFFF9F0A),
                      sparklineColor: const Color(0xFFFF9F0A),
                      sparklinePoints: const [0.2, 0.3, 0.5, 0.4, 0.65, 0.85, 1.0],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _WheelMetricCard(
                title: 'Total Spins',
                value: _formatNumber(totalSpins),
                badgeText: '↑ +22%',
                isBadgePositive: true,
                subtitle: '+12,450 this month',
                icon: Icons.groups_rounded,
                iconColor: const Color(0xFFF04483),
                sparklineColor: const Color(0xFFF04483),
                sparklinePoints: const [0.25, 0.45, 0.4, 0.7, 0.6, 0.88, 1.0],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _WheelMetricCard(
                title: 'Total Campaigns',
                value: _formatNumber(totalCampaigns),
                badgeText: '↑ +28%',
                isBadgePositive: true,
                subtitle: '+4 this month',
                icon: Icons.track_changes_rounded,
                iconColor: const Color(0xFF5636F5),
                sparklineColor: const Color(0xFF5636F5),
                sparklinePoints: const [0.2, 0.4, 0.35, 0.65, 0.5, 0.85, 1.0],
              ),
              const SizedBox(height: 10),
              _WheelMetricCard(
                title: 'Total Participants',
                value: _formatNumber(totalParticipants),
                badgeText: '↑ +32%',
                isBadgePositive: true,
                subtitle: '+5,842 this month',
                icon: Icons.group_rounded,
                iconColor: const Color(0xFF2587F8),
                sparklineColor: const Color(0xFF2587F8),
                sparklinePoints: const [0.15, 0.35, 0.3, 0.6, 0.55, 0.8, 1.0],
              ),
              const SizedBox(height: 10),
              _WheelMetricCard(
                title: 'Total Rewards Given',
                value: _formatNumber(totalRewardsGiven),
                badgeText: '↑ +18%',
                isBadgePositive: true,
                subtitle: '+2,210 this month',
                icon: Icons.card_giftcard_rounded,
                iconColor: const Color(0xFF10B981),
                sparklineColor: const Color(0xFF10B981),
                sparklinePoints: const [0.3, 0.4, 0.5, 0.45, 0.7, 0.85, 1.0],
              ),
              const SizedBox(height: 10),
              _WheelMetricCard(
                title: 'Active Campaigns',
                value: _formatNumber(activeCampaigns),
                badgeText: '↑ +25%',
                isBadgePositive: true,
                subtitle: '+1 this month',
                icon: Icons.poll_rounded,
                iconColor: const Color(0xFFFF9F0A),
                sparklineColor: const Color(0xFFFF9F0A),
                sparklinePoints: const [0.2, 0.3, 0.5, 0.4, 0.65, 0.85, 1.0],
              ),
              const SizedBox(height: 10),
              _WheelMetricCard(
                title: 'Total Spins',
                value: _formatNumber(totalSpins),
                badgeText: '↑ +22%',
                isBadgePositive: true,
                subtitle: '+12,450 this month',
                icon: Icons.groups_rounded,
                iconColor: const Color(0xFFF04483),
                sparklineColor: const Color(0xFFF04483),
                sparklinePoints: const [0.25, 0.45, 0.4, 0.7, 0.6, 0.88, 1.0],
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

class _WheelMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String badgeText;
  final bool isBadgePositive;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color sparklineColor;
  final List<double> sparklinePoints;

  const _WheelMetricCard({
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
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
                            height: 1.1,
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
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 3. Decorative Cubic Bezier Sparkline on the far right
          SizedBox(
            width: 48,
            height: 26,
            child: CustomPaint(
              painter: _SparklinePainter(
                points: sparklinePoints,
                lineColor: sparklineColor,
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
  final Color lineColor;

  const _SparklinePainter({
    required this.points,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final stepX = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - (points[i] * size.height * 0.85) - size.height * 0.05;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height - (points[i - 1] * size.height * 0.85) - size.height * 0.05;
        final cX1 = prevX + stepX * 0.5;
        final cY1 = prevY;
        final cX2 = prevX + stepX * 0.5;
        final cY2 = y;
        path.cubicTo(cX1, cY1, cX2, cY2, x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => false;
}
