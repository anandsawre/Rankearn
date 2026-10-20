import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Users Metrics Row displaying 5 horizontal metric cards
/// Layout: Icon on the Left, Title/Value/Badge/Subtext on the right of the icon, Sparkline on the far right.
class UsersMetricsRow extends StatelessWidget {
  final int totalUsers;
  final int activeUsers;
  final int newUsersThisMonth;
  final int inactiveUsers;
  final int premiumUsers;

  const UsersMetricsRow({
    super.key,
    this.totalUsers = 12458,
    this.activeUsers = 9836,
    this.newUsersThisMonth = 1324,
    this.inactiveUsers = 1298,
    this.premiumUsers = 3842,
  });

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write(',');
        count = 0;
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final cards = [
          _UserMetricCardData(
            icon: Icons.person_rounded,
            iconBg: const Color(0xFF0084FF),
            title: 'Total Users',
            value: _formatNumber(totalUsers),
            badgeText: '+22%',
            badgePositive: true,
            subtext: '+2,248 this month',
            sparklineColor: const Color(0xFF0084FF),
            sparklineData: [20, 24, 22, 28, 35, 42, 48],
          ),
          _UserMetricCardData(
            icon: Icons.how_to_reg_rounded,
            iconBg: const Color(0xFF10B981),
            title: 'Active Users',
            value: _formatNumber(activeUsers),
            badgeText: '+18%',
            badgePositive: true,
            subtext: '+1,524 this month',
            sparklineColor: const Color(0xFF10B981),
            sparklineData: [18, 22, 26, 30, 36, 40, 42],
          ),
          _UserMetricCardData(
            icon: Icons.person_add_alt_1_rounded,
            iconBg: const Color(0xFFF59E0B),
            title: 'New Users (This Month)',
            value: _formatNumber(newUsersThisMonth),
            badgeText: '+40%',
            badgePositive: true,
            subtext: '+378 this month',
            sparklineColor: const Color(0xFFF59E0B),
            sparklineData: [10, 14, 18, 22, 28, 32, 40],
          ),
          _UserMetricCardData(
            icon: Icons.person_off_rounded,
            iconBg: const Color(0xFF8B5CF6),
            title: 'Inactive Users',
            value: _formatNumber(inactiveUsers),
            badgeText: '-12%',
            badgePositive: false,
            subtext: '-176 this month',
            sparklineColor: const Color(0xFF8B5CF6),
            sparklineData: [25, 22, 20, 18, 16, 14, 12],
          ),
          _UserMetricCardData(
            icon: Icons.workspace_premium_rounded,
            iconBg: const Color(0xFFF43F5E),
            title: 'Premium Users',
            value: _formatNumber(premiumUsers),
            badgeText: '+28%',
            badgePositive: true,
            subtext: '+832 this month',
            sparklineColor: const Color(0xFFF43F5E),
            sparklineData: [15, 20, 25, 30, 38, 44, 52],
          ),
        ];

        if (width >= 1050) {
          return Row(
            children: cards.asMap().entries.map((entry) {
              final idx = entry.key;
              final data = entry.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: idx == 0 ? 0 : 7,
                    right: idx == cards.length - 1 ? 0 : 7,
                  ),
                  child: _buildCard(data),
                ),
              );
            }).toList(),
          );
        } else if (width >= 650) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cards
                .map((c) => SizedBox(
                      width: (width - 24) / 2,
                      child: _buildCard(c),
                    ))
                .toList(),
          );
        } else {
          return Column(
            children: cards
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                    child: _buildCard(c),
                  ))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildCard(_UserMetricCardData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Icon Container on Left
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(data.icon, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 10),

          // 2. Text & Data on the Right of Icon
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Value + Badge Row
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        data.value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101A3A),
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: data.badgePositive
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              data.badgePositive
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              size: 8.5,
                              color: data.badgePositive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF43F5E),
                            ),
                            const SizedBox(width: 1),
                            Text(
                              data.badgeText,
                              style: TextStyle(
                                fontSize: 9.0,
                                fontWeight: FontWeight.w700,
                                color: data.badgePositive
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF43F5E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),

                // Subtext
                Text(
                  data.subtext,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 3. Sparkline on far right
          const SizedBox(width: 4),
          SizedBox(
            width: 32,
            height: 20,
            child: CustomPaint(
              painter: _UsersSparklinePainter(
                data: data.sparklineData,
                color: data.sparklineColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMetricCardData {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String value;
  final String badgeText;
  final bool badgePositive;
  final String subtext;
  final Color sparklineColor;
  final List<double> sparklineData;

  const _UserMetricCardData({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.badgeText,
    required this.badgePositive,
    required this.subtext,
    required this.sparklineColor,
    required this.sparklineData,
  });
}

class _UsersSparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _UsersSparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minVal) / range) * (size.height - 4) - 2;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _UsersSparklinePainter oldDelegate) => false;
}
