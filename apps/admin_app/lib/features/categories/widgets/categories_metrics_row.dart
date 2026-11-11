import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Categories & Exams Metrics Row
/// Displays 5 responsive live statistics cards powered by [AdminMetricCard]
/// with real database counts, 7-day trends, and sparklines.
class CategoriesMetricsRow extends StatelessWidget {
  final int totalExams;
  final int publishedExams;
  final int hiddenExams;
  final int linkedTests;
  final int totalSubjects;
  final bool isLoading;

  final String totalGrowth;
  final bool totalPositive;
  final List<double>? totalSparkline;

  final String publishedGrowth;
  final bool publishedPositive;
  final List<double>? publishedSparkline;

  final String hiddenGrowth;
  final bool hiddenPositive;
  final List<double>? hiddenSparkline;

  final String testsGrowth;
  final bool testsPositive;
  final List<double>? testsSparkline;

  final String subjectsGrowth;
  final bool subjectsPositive;
  final List<double>? subjectsSparkline;

  const CategoriesMetricsRow({
    super.key,
    this.totalExams = 0,
    this.publishedExams = 0,
    this.hiddenExams = 0,
    this.linkedTests = 0,
    this.totalSubjects = 0,
    this.isLoading = false,
    this.totalGrowth = '',
    this.totalPositive = true,
    this.totalSparkline,
    this.publishedGrowth = '',
    this.publishedPositive = true,
    this.publishedSparkline,
    this.hiddenGrowth = '',
    this.hiddenPositive = true,
    this.hiddenSparkline,
    this.testsGrowth = '',
    this.testsPositive = true,
    this.testsSparkline,
    this.subjectsGrowth = '',
    this.subjectsPositive = true,
    this.subjectsSparkline,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (
        title: 'Total Exams',
        value: isLoading ? '—' : _formatNumber(totalExams),
        growth: isLoading ? '' : totalGrowth,
        isGrowthPositive: totalPositive,
        subtitle: isLoading ? 'Loading exams...' : 'Target exams configured',
        icon: Icons.explore_rounded,
        color: const Color(0xFF3B82F6),
        sparklineData: totalSparkline,
      ),
      (
        title: 'Published Exams',
        value: isLoading ? '—' : _formatNumber(publishedExams),
        growth: isLoading ? '' : publishedGrowth,
        isGrowthPositive: publishedPositive,
        subtitle: isLoading ? 'Loading status...' : 'Visible to students',
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF10B981),
        sparklineData: publishedSparkline,
      ),
      (
        title: 'Draft Exams',
        value: isLoading ? '—' : _formatNumber(hiddenExams),
        growth: isLoading ? '' : hiddenGrowth,
        isGrowthPositive: hiddenPositive,
        subtitle: isLoading ? 'Loading drafts...' : 'Hidden / unpublished',
        icon: Icons.edit_note_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: hiddenSparkline,
      ),
      (
        title: 'Linked Tests',
        value: isLoading ? '—' : _formatNumber(linkedTests),
        growth: isLoading ? '' : testsGrowth,
        isGrowthPositive: testsPositive,
        subtitle: isLoading ? 'Loading tests...' : 'Active test series',
        icon: Icons.assignment_turned_in_rounded,
        color: const Color(0xFF8B5CF6),
        sparklineData: testsSparkline,
      ),
      (
        title: 'Total Subjects',
        value: isLoading ? '—' : _formatNumber(totalSubjects),
        growth: isLoading ? '' : subjectsGrowth,
        isGrowthPositive: subjectsPositive,
        subtitle: isLoading ? 'Loading subjects...' : 'Curriculum subjects',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFEF4444),
        sparklineData: subjectsSparkline,
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
      return '${s.substring(0, len - 3)},${s.substring(len - 3)}';
    }
    return n.toString();
  }
}
