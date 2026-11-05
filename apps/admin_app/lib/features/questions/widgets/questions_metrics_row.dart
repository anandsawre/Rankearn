import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Questions Metrics Row
/// Displays 5 responsive statistics cards powered by the unified [AdminMetricCard]
/// from the Rankearn design system.
class QuestionsMetricsRow extends StatelessWidget {
  final int totalQuestions;
  final int activeQuestions;
  final int draftQuestions;
  final int archivedQuestions;
  final int questionSets;

  const QuestionsMetricsRow({
    super.key,
    this.totalQuestions = 9842,
    this.activeQuestions = 8936,
    this.draftQuestions = 542,
    this.archivedQuestions = 364,
    this.questionSets = 128,
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
        title: 'Total Questions',
        value: _formatNumber(totalQuestions),
        growth: '+15%',
        isGrowthPositive: true,
        subtitle: '+1,280 this month',
        icon: Icons.question_mark_rounded,
        color: const Color(0xFF3B82F6),
        sparklineData: const [20.0, 24.0, 22.0, 28.0, 35.0, 42.0, 48.0],
      ),
      (
        title: 'Active Questions',
        value: _formatNumber(activeQuestions),
        growth: '+18%',
        isGrowthPositive: true,
        subtitle: '+1,324 this month',
        icon: Icons.check_rounded,
        color: const Color(0xFF10B981),
        sparklineData: const [18.0, 22.0, 26.0, 30.0, 36.0, 40.0, 42.0],
      ),
      (
        title: 'Draft Questions',
        value: _formatNumber(draftQuestions),
        growth: '-12%',
        isGrowthPositive: false,
        subtitle: '-84 this month',
        icon: Icons.description_outlined,
        color: const Color(0xFFF59E0B),
        sparklineData: const [8.0, 7.0, 9.0, 6.0, 5.0, 4.0, 4.0],
      ),
      (
        title: 'Archived Questions',
        value: _formatNumber(archivedQuestions),
        growth: '+6%',
        isGrowthPositive: true,
        subtitle: '+21 this month',
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF8B5CF6),
        sparklineData: const [2.0, 2.0, 2.0, 3.0, 2.0, 2.0, 2.0],
      ),
      (
        title: 'Question Sets',
        value: _formatNumber(questionSets),
        growth: '+22%',
        isGrowthPositive: true,
        subtitle: '+23 this month',
        icon: Icons.layers_rounded,
        color: const Color(0xFFEF4444),
        sparklineData: const [10.0, 12.0, 15.0, 14.0, 18.0, 20.0, 22.0],
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
