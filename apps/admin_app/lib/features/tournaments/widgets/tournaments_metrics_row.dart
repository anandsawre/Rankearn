import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Tournaments Metrics Row
/// Displays 5 responsive statistics cards powered by the unified [AdminMetricCard]
/// from the Rankearn design system.
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
        title: 'Total Tournaments',
        value: totalTournaments.toString(),
        growth: '+26%',
        isGrowthPositive: true,
        subtitle: '+5 this month',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFF3B82F6),
        sparklineData: const [20.0, 40.0, 35.0, 65.0, 50.0, 85.0, 100.0],
      ),
      (
        title: 'Total Participants',
        value: _formatNumber(totalParticipants),
        growth: '+32%',
        isGrowthPositive: true,
        subtitle: '+2,184 this month',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF10B981),
        sparklineData: const [15.0, 35.0, 30.0, 60.0, 55.0, 80.0, 100.0],
      ),
      (
        title: 'Completed',
        value: completedTournaments.toString(),
        growth: '+14%',
        isGrowthPositive: true,
        subtitle: '+2 this month',
        icon: Icons.check_circle_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: const [30.0, 40.0, 50.0, 45.0, 70.0, 85.0, 100.0],
      ),
      (
        title: 'Ongoing',
        value: ongoingTournaments.toString(),
        growth: '+200%',
        isGrowthPositive: true,
        subtitle: '+2 this month',
        icon: Icons.play_circle_fill_rounded,
        color: const Color(0xFF8B5CF6),
        sparklineData: const [10.0, 20.0, 15.0, 30.0, 25.0, 60.0, 100.0],
      ),
      (
        title: 'Upcoming',
        value: upcomingTournaments.toString(),
        growth: '+25%',
        isGrowthPositive: true,
        subtitle: '+1 this month',
        icon: Icons.calendar_month_rounded,
        color: const Color(0xFFEF4444),
        sparklineData: const [20.0, 30.0, 45.0, 40.0, 55.0, 70.0, 100.0],
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
