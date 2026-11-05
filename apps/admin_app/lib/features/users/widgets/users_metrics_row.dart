import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Users Metrics Row displaying 5 horizontal metric cards powered by the unified
/// [AdminMetricCard] from the Rankearn design system.
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
    final metrics = [
      (
        title: 'Total Users',
        value: _formatNumber(totalUsers),
        growth: '+22%',
        isGrowthPositive: true,
        subtitle: '+2,248 this month',
        icon: Icons.person_rounded,
        color: const Color(0xFF3B82F6),
        sparklineData: const [20.0, 24.0, 22.0, 28.0, 35.0, 42.0, 48.0],
      ),
      (
        title: 'Active Users',
        value: _formatNumber(activeUsers),
        growth: '+18%',
        isGrowthPositive: true,
        subtitle: '+1,524 this month',
        icon: Icons.how_to_reg_rounded,
        color: const Color(0xFF10B981),
        sparklineData: const [18.0, 22.0, 26.0, 30.0, 36.0, 40.0, 42.0],
      ),
      (
        title: 'New Users (This Month)',
        value: _formatNumber(newUsersThisMonth),
        growth: '+40%',
        isGrowthPositive: true,
        subtitle: '+378 this month',
        icon: Icons.person_add_alt_1_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: const [10.0, 14.0, 18.0, 22.0, 28.0, 32.0, 40.0],
      ),
      (
        title: 'Inactive Users',
        value: _formatNumber(inactiveUsers),
        growth: '-8%',
        isGrowthPositive: false,
        subtitle: '-92 this month',
        icon: Icons.person_off_rounded,
        color: const Color(0xFF8B5CF6),
        sparklineData: const [14.0, 12.0, 15.0, 11.0, 9.0, 8.0, 6.0],
      ),
      (
        title: 'Premium Users',
        value: _formatNumber(premiumUsers),
        growth: '+15%',
        isGrowthPositive: true,
        subtitle: '+412 this month',
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFFEF4444),
        sparklineData: const [16.0, 18.0, 20.0, 24.0, 26.0, 30.0, 35.0],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth > 1100
            ? (constraints.maxWidth - (16 * 4)) / 5
            : constraints.maxWidth > 700
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: metrics.map((m) {
            return AdminMetricCard(
              width: cardWidth,
              title: m.title,
              value: m.value,
              growth: m.growth,
              isGrowthPositive: m.isGrowthPositive,
              subtitle: m.subtitle,
              icon: m.icon,
              color: m.color,
              sparklineData: m.sparklineData,
            );
          }).toList(),
        );
      },
    );
  }
}
