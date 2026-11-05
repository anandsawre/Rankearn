import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Lucky Wheel Metrics Row
/// Displays 5 responsive statistics cards powered by the unified [AdminMetricCard]
/// from the Rankearn design system.
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
        title: 'Total Campaigns',
        value: _formatNumber(totalCampaigns),
        growth: '+28%',
        isGrowthPositive: true,
        subtitle: '+4 this month',
        icon: Icons.track_changes_rounded,
        color: const Color(0xFF3B82F6),
        sparklineData: const [20.0, 40.0, 35.0, 65.0, 50.0, 85.0, 100.0],
      ),
      (
        title: 'Total Participants',
        value: _formatNumber(totalParticipants),
        growth: '+32%',
        isGrowthPositive: true,
        subtitle: '+5,842 this month',
        icon: Icons.group_rounded,
        color: const Color(0xFF10B981),
        sparklineData: const [15.0, 35.0, 30.0, 60.0, 55.0, 80.0, 100.0],
      ),
      (
        title: 'Total Rewards Given',
        value: '₹ ${_formatNumber(totalRewardsGiven)}',
        growth: '+18%',
        isGrowthPositive: true,
        subtitle: '+2,210 this month',
        icon: Icons.card_giftcard_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: const [30.0, 40.0, 50.0, 45.0, 70.0, 85.0, 100.0],
      ),
      (
        title: 'Active Campaigns',
        value: _formatNumber(activeCampaigns),
        growth: '+25%',
        isGrowthPositive: true,
        subtitle: '+1 this month',
        icon: Icons.play_circle_fill_rounded,
        color: const Color(0xFF8B5CF6),
        sparklineData: const [10.0, 25.0, 20.0, 40.0, 35.0, 70.0, 100.0],
      ),
      (
        title: 'Total Spins',
        value: _formatNumber(totalSpins),
        growth: '+35%',
        isGrowthPositive: true,
        subtitle: '+12,450 this month',
        icon: Icons.rotate_right_rounded,
        color: const Color(0xFFEF4444),
        sparklineData: const [15.0, 30.0, 25.0, 50.0, 45.0, 80.0, 100.0],
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
