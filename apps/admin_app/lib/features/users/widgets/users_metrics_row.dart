import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Users Metrics Row displaying 5 live statistics cards powered by [AdminMetricCard].
class UsersMetricsRow extends StatelessWidget {
  final int totalUsers;
  final int activeUsers;
  final int newUsersThisMonth;
  final int inactiveUsers;
  final int premiumUsers;
  final bool isLoading;

  final String totalGrowth;
  final bool totalPositive;
  final List<double>? totalSparkline;

  final String activeGrowth;
  final bool activePositive;
  final List<double>? activeSparkline;

  final String newUsersGrowth;
  final bool newUsersPositive;
  final List<double>? newUsersSparkline;

  final String inactiveGrowth;
  final bool inactivePositive;
  final List<double>? inactiveSparkline;

  final String premiumGrowth;
  final bool premiumPositive;
  final List<double>? premiumSparkline;

  const UsersMetricsRow({
    super.key,
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.newUsersThisMonth = 0,
    this.inactiveUsers = 0,
    this.premiumUsers = 0,
    this.isLoading = false,
    this.totalGrowth = '',
    this.totalPositive = true,
    this.totalSparkline,
    this.activeGrowth = '',
    this.activePositive = true,
    this.activeSparkline,
    this.newUsersGrowth = '',
    this.newUsersPositive = true,
    this.newUsersSparkline,
    this.inactiveGrowth = '',
    this.inactivePositive = false,
    this.inactiveSparkline,
    this.premiumGrowth = '',
    this.premiumPositive = true,
    this.premiumSparkline,
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
        value: isLoading ? '—' : _formatNumber(totalUsers),
        growth: isLoading ? '' : totalGrowth,
        isGrowthPositive: totalPositive,
        subtitle: isLoading ? 'Loading profiles...' : 'Registered profiles',
        icon: Icons.person_rounded,
        color: const Color(0xFF3B82F6),
        sparklineData: totalSparkline,
      ),
      (
        title: 'Active Users',
        value: isLoading ? '—' : _formatNumber(activeUsers),
        growth: isLoading ? '' : activeGrowth,
        isGrowthPositive: activePositive,
        subtitle: isLoading ? 'Loading status...' : 'Active accounts',
        icon: Icons.how_to_reg_rounded,
        color: const Color(0xFF10B981),
        sparklineData: activeSparkline,
      ),
      (
        title: 'New Users (This Month)',
        value: isLoading ? '—' : _formatNumber(newUsersThisMonth),
        growth: isLoading ? '' : newUsersGrowth,
        isGrowthPositive: newUsersPositive,
        subtitle: isLoading ? 'Loading signups...' : 'Joined in current month',
        icon: Icons.person_add_alt_1_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: newUsersSparkline,
      ),
      (
        title: 'Inactive / Blocked',
        value: isLoading ? '—' : _formatNumber(inactiveUsers),
        growth: isLoading ? '' : inactiveGrowth,
        isGrowthPositive: inactivePositive,
        subtitle: isLoading ? 'Loading restricted...' : 'Suspended or banned',
        icon: Icons.person_off_rounded,
        color: const Color(0xFF8B5CF6),
        sparklineData: inactiveSparkline,
      ),
      (
        title: 'Premium Users',
        value: isLoading ? '—' : _formatNumber(premiumUsers),
        growth: isLoading ? '' : premiumGrowth,
        isGrowthPositive: premiumPositive,
        subtitle: isLoading ? 'Loading plans...' : 'Active premium status',
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFFEF4444),
        sparklineData: premiumSparkline,
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
