import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Live Quiz Metrics Row
/// Displays 5 responsive statistics cards powered by the unified [AdminMetricCard]
/// from the Rankearn design system.
class LiveQuizMetricsRow extends StatelessWidget {
  final int totalLiveQuiz;
  final int totalParticipants;
  final int completedQuiz;
  final int ongoingQuiz;
  final int totalRewardsGiven;

  const LiveQuizMetricsRow({
    super.key,
    this.totalLiveQuiz = 128,
    this.totalParticipants = 24892,
    this.completedQuiz = 106,
    this.ongoingQuiz = 3,
    this.totalRewardsGiven = 12450,
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
        title: 'Total Live Quiz',
        value: totalLiveQuiz.toString(),
        growth: '+18%',
        isGrowthPositive: true,
        subtitle: '+20 this month',
        icon: Icons.podcasts_rounded,
        color: const Color(0xFF3B82F6),
        sparklineData: const [20.0, 40.0, 35.0, 65.0, 50.0, 85.0, 100.0],
      ),
      (
        title: 'Total Participants',
        value: _formatNumber(totalParticipants),
        growth: '+32%',
        isGrowthPositive: true,
        subtitle: '+5,842 this month',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF10B981),
        sparklineData: const [15.0, 35.0, 30.0, 60.0, 55.0, 80.0, 100.0],
      ),
      (
        title: 'Completed Quiz',
        value: completedQuiz.toString(),
        growth: '+15%',
        isGrowthPositive: true,
        subtitle: '+14 this month',
        icon: Icons.check_circle_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: const [25.0, 40.0, 35.0, 70.0, 60.0, 90.0, 100.0],
      ),
      (
        title: 'Ongoing Quiz',
        value: ongoingQuiz.toString(),
        growth: '-25%',
        isGrowthPositive: false,
        subtitle: '-1 this month',
        icon: Icons.access_time_filled_rounded,
        color: const Color(0xFF8B5CF6),
        sparklineData: const [60.0, 75.0, 50.0, 65.0, 40.0, 50.0, 30.0],
      ),
      (
        title: 'Total Rewards Given',
        value: _formatNumber(totalRewardsGiven),
        growth: '+22%',
        isGrowthPositive: true,
        subtitle: '+2,210 this month',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFEF4444),
        sparklineData: const [20.0, 35.0, 30.0, 55.0, 50.0, 85.0, 100.0],
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
