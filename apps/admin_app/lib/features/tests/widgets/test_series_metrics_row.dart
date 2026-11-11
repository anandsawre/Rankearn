import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Test Series Metrics Row
/// Displays 5 responsive live statistics cards powered by [AdminMetricCard]
/// with real database aggregates, growth rates, and sparklines.
class TestSeriesMetricsRow extends StatelessWidget {
  final int totalTestSeries;
  final int publishedCount;
  final int draftsCount;
  final int totalTests;
  final int totalEnrollments;
  final bool isLoading;

  final String totalSeriesGrowth;
  final bool totalSeriesPositive;
  final List<double>? totalSeriesSparkline;

  final String publishedGrowth;
  final bool publishedPositive;
  final List<double>? publishedSparkline;

  final String draftsGrowth;
  final bool draftsPositive;
  final List<double>? draftsSparkline;

  final String questionsGrowth;
  final bool questionsPositive;
  final List<double>? questionsSparkline;

  final String enrollmentsGrowth;
  final bool enrollmentsPositive;
  final List<double>? enrollmentsSparkline;

  const TestSeriesMetricsRow({
    super.key,
    required this.totalTestSeries,
    required this.publishedCount,
    required this.draftsCount,
    required this.totalTests,
    required this.totalEnrollments,
    this.isLoading = false,
    this.totalSeriesGrowth = '',
    this.totalSeriesPositive = true,
    this.totalSeriesSparkline,
    this.publishedGrowth = '',
    this.publishedPositive = true,
    this.publishedSparkline,
    this.draftsGrowth = '',
    this.draftsPositive = true,
    this.draftsSparkline,
    this.questionsGrowth = '',
    this.questionsPositive = true,
    this.questionsSparkline,
    this.enrollmentsGrowth = '',
    this.enrollmentsPositive = true,
    this.enrollmentsSparkline,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (
        title: 'Total Test Series',
        value: isLoading ? '—' : _formatNumber(totalTestSeries),
        growth: isLoading ? '' : totalSeriesGrowth,
        isGrowthPositive: totalSeriesPositive,
        subtitle: isLoading ? 'Loading series...' : 'All database series',
        icon: Icons.description_rounded,
        color: AppColors.brandBlue,
        sparklineData: totalSeriesSparkline,
      ),
      (
        title: 'Published',
        value: isLoading ? '—' : _formatNumber(publishedCount),
        growth: isLoading ? '' : publishedGrowth,
        isGrowthPositive: publishedPositive,
        subtitle: isLoading ? 'Loading status...' : 'Live for students',
        icon: Icons.assignment_turned_in_rounded,
        color: AppColors.brandGreen,
        sparklineData: publishedSparkline,
      ),
      (
        title: 'Drafts',
        value: isLoading ? '—' : _formatNumber(draftsCount),
        growth: isLoading ? '' : draftsGrowth,
        isGrowthPositive: draftsPositive,
        subtitle: isLoading ? 'Loading drafts...' : 'Pending review',
        icon: Icons.edit_note_rounded,
        color: AppColors.coinGold,
        sparklineData: draftsSparkline,
      ),
      (
        title: 'Total Tests',
        value: isLoading ? '—' : _formatNumber(totalTests),
        growth: isLoading ? '' : questionsGrowth,
        isGrowthPositive: questionsPositive,
        subtitle: isLoading ? 'Loading papers...' : 'Available test papers',
        icon: Icons.emoji_events_rounded,
        color: AppColors.battleAdminPurple,
        sparklineData: questionsSparkline,
      ),
      (
        title: 'Total Enrollments',
        value: isLoading ? '—' : _formatNumber(totalEnrollments),
        growth: isLoading ? '' : enrollmentsGrowth,
        isGrowthPositive: enrollmentsPositive,
        subtitle: isLoading ? 'Loading attempts...' : 'Student attempts & joins',
        icon: Icons.people_alt_rounded,
        color: AppColors.liveRed,
        sparklineData: enrollmentsSparkline,
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
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}
