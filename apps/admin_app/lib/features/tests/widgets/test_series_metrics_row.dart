import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Test Series Metrics Row
/// Displays 5 responsive statistics cards powered by the unified [AdminMetricCard]
/// from the Rankearn design system to ensure 100% UI consistency across the admin panel.
class TestSeriesMetricsRow extends StatelessWidget {
  final int totalTestSeries;
  final int publishedCount;
  final int draftsCount;
  final int totalTests;
  final int totalEnrollments;

  const TestSeriesMetricsRow({
    super.key,
    required this.totalTestSeries,
    required this.publishedCount,
    required this.draftsCount,
    required this.totalTests,
    required this.totalEnrollments,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (
        title: 'Total Test Series',
        value: totalTestSeries.toString(),
        growth: '+12%',
        isGrowthPositive: true,
        subtitle: 'All active series',
        icon: Icons.description_rounded,
        color: const Color(0xFF3B82F6),
        sparklineData: const [10.0, 12.0, 11.5, 14.0, 16.0, 18.0, 22.0],
      ),
      (
        title: 'Published',
        value: publishedCount.toString(),
        growth: '+15%',
        isGrowthPositive: true,
        subtitle: 'Live for students',
        icon: Icons.assignment_turned_in_rounded,
        color: const Color(0xFF10B981),
        sparklineData: const [8.0, 9.0, 8.5, 11.0, 12.0, 13.5, 16.0],
      ),
      (
        title: 'Drafts',
        value: draftsCount.toString(),
        growth: '-25%',
        isGrowthPositive: false,
        subtitle: 'Pending review',
        icon: Icons.edit_note_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: const [14.0, 13.0, 12.0, 10.0, 9.0, 8.0, 6.0],
      ),
      (
        title: 'Total Tests',
        value: totalTests.toString(),
        growth: '+10%',
        isGrowthPositive: true,
        subtitle: 'Available test papers',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFF8B5CF6),
        sparklineData: const [12.0, 14.0, 13.5, 16.0, 17.5, 20.0, 24.0],
      ),
      (
        title: 'Total Enrollments',
        value: _formatNumber(totalEnrollments),
        growth: '+22%',
        isGrowthPositive: true,
        subtitle: 'Active student attempts',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFFEF4444),
        sparklineData: const [14.0, 15.5, 18.0, 17.5, 21.0, 25.0, 30.0],
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
