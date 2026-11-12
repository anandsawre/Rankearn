import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// AI Test Creator Metrics Row
/// Displays 5 responsive live KPI cards powered by [AdminMetricCard].
class AiTestCreatorMetricsRow extends StatelessWidget {
  final int testsGenerated;
  final int questionsCreated;
  final int savedTests;
  final int timesUsed;
  final String avgCreationTime;
  final bool isLoading;

  final String testsGrowth;
  final bool testsPositive;
  final List<double>? testsSparkline;

  final String questionsGrowth;
  final bool questionsPositive;
  final List<double>? questionsSparkline;

  final String savedGrowth;
  final bool savedPositive;
  final List<double>? savedSparkline;

  final String usageGrowth;
  final bool usagePositive;
  final List<double>? usageSparkline;

  final List<double>? speedSparkline;

  const AiTestCreatorMetricsRow({
    super.key,
    this.testsGenerated = 0,
    this.questionsCreated = 0,
    this.savedTests = 0,
    this.timesUsed = 0,
    this.avgCreationTime = '—',
    this.isLoading = false,
    this.testsGrowth = '',
    this.testsPositive = true,
    this.testsSparkline,
    this.questionsGrowth = '',
    this.questionsPositive = true,
    this.questionsSparkline,
    this.savedGrowth = '',
    this.savedPositive = true,
    this.savedSparkline,
    this.usageGrowth = '',
    this.usagePositive = true,
    this.usageSparkline,
    this.speedSparkline,
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
        value: isLoading ? '—' : _formatNumber(testsGenerated),
        growth: isLoading ? '' : testsGrowth,
        isGrowthPositive: testsPositive,
        subtitle: isLoading ? 'Loading tests...' : 'AI generated tests',
        icon: Icons.description_rounded,
        color: const Color(0xFF3B82F6),
        sparklineData: testsSparkline,
      ),
      (
        title: 'Questions Created',
        value: isLoading ? '—' : _formatNumber(questionsCreated),
        growth: isLoading ? '' : questionsGrowth,
        isGrowthPositive: questionsPositive,
        subtitle: isLoading ? 'Counting questions...' : 'Total generated questions',
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF10B981),
        sparklineData: questionsSparkline,
      ),
      (
        title: 'Saved Tests',
        value: isLoading ? '—' : _formatNumber(savedTests),
        growth: isLoading ? '' : savedGrowth,
        isGrowthPositive: savedPositive,
        subtitle: isLoading ? 'Loading saved...' : 'Published or saved papers',
        icon: Icons.folder_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: savedSparkline,
      ),
      (
        title: 'Times Used',
        value: isLoading ? '—' : _formatNumber(timesUsed),
        growth: isLoading ? '' : usageGrowth,
        isGrowthPositive: usagePositive,
        subtitle: isLoading ? 'Loading usage...' : 'Student attempts recorded',
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFF8B5CF6),
        sparklineData: usageSparkline,
      ),
      (
        title: 'Avg. Creation Time (AI Speed)',
        value: isLoading ? '—' : avgCreationTime,
        growth: '',
        isGrowthPositive: true,
        subtitle: isLoading ? 'Measuring latency...' : 'Average generation duration',
        icon: Icons.timer_rounded,
        color: const Color(0xFFEF4444),
        sparklineData: speedSparkline,
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
