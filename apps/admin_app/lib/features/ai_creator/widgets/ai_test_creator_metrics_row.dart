import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// AI Test Creator Metrics Row
/// Displays 5 responsive statistics cards powered by the unified [AdminMetricCard]
/// from the Rankearn design system.
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
        title: 'Tests Generated',
        value: _formatNumber(testsGenerated),
        growth: '+28%',
        isGrowthPositive: true,
        subtitle: '+27 this month',
        icon: Icons.description_rounded,
        color: const Color(0xFF3B82F6),
        sparklineData: const [20.0, 40.0, 35.0, 65.0, 50.0, 85.0, 100.0],
      ),
      (
        title: 'Questions Created',
        value: _formatNumber(questionsCreated),
        growth: '+18%',
        isGrowthPositive: true,
        subtitle: '+2,458 this month',
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF10B981),
        sparklineData: const [15.0, 35.0, 30.0, 60.0, 55.0, 80.0, 100.0],
      ),
      (
        title: 'Saved Tests',
        value: _formatNumber(savedTests),
        growth: '+32%',
        isGrowthPositive: true,
        subtitle: '+17 this month',
        icon: Icons.folder_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: const [30.0, 40.0, 50.0, 45.0, 70.0, 85.0, 100.0],
      ),
      (
        title: 'Times Used',
        value: _formatNumber(timesUsed),
        growth: '+22%',
        isGrowthPositive: true,
        subtitle: '+582 this month',
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFF8B5CF6),
        sparklineData: const [20.0, 30.0, 45.0, 60.0, 50.0, 80.0, 100.0],
      ),
      (
        title: 'Avg Creation Time',
        value: avgCreationTime,
        growth: '-8%',
        isGrowthPositive: true, // Faster time is positive
        subtitle: '-3 sec faster',
        icon: Icons.timer_rounded,
        color: const Color(0xFFEF4444),
        sparklineData: const [100.0, 85.0, 90.0, 70.0, 60.0, 50.0, 40.0],
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
