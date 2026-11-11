import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Questions Metrics Row
/// Displays 5 responsive live statistics cards powered by [AdminMetricCard]
/// with real database counts, 7-day growth percentages, and sparklines.
class QuestionsMetricsRow extends StatelessWidget {
  final int totalQuestions;
  final int activeQuestions;
  final int draftQuestions;
  final int archivedQuestions;
  final int questionSets;
  final bool isLoading;

  final String totalGrowth;
  final bool totalPositive;
  final List<double>? totalSparkline;

  final String activeGrowth;
  final bool activePositive;
  final List<double>? activeSparkline;

  final String draftGrowth;
  final bool draftPositive;
  final List<double>? draftSparkline;

  final String archivedGrowth;
  final bool archivedPositive;
  final List<double>? archivedSparkline;

  final String setsGrowth;
  final bool setsPositive;
  final List<double>? setsSparkline;

  const QuestionsMetricsRow({
    super.key,
    this.totalQuestions = 0,
    this.activeQuestions = 0,
    this.draftQuestions = 0,
    this.archivedQuestions = 0,
    this.questionSets = 0,
    this.isLoading = false,
    this.totalGrowth = '',
    this.totalPositive = true,
    this.totalSparkline,
    this.activeGrowth = '',
    this.activePositive = true,
    this.activeSparkline,
    this.draftGrowth = '',
    this.draftPositive = true,
    this.draftSparkline,
    this.archivedGrowth = '',
    this.archivedPositive = true,
    this.archivedSparkline,
    this.setsGrowth = '',
    this.setsPositive = true,
    this.setsSparkline,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (
        title: 'Total Questions',
        value: isLoading ? '—' : _formatNumber(totalQuestions),
        growth: isLoading ? '' : totalGrowth,
        isGrowthPositive: totalPositive,
        subtitle: isLoading ? 'Loading bank...' : 'All bank questions',
        icon: Icons.help_outline_rounded,
        color: const Color(0xFF3B82F6),
        sparklineData: totalSparkline,
      ),
      (
        title: 'Active Questions',
        value: isLoading ? '—' : _formatNumber(activeQuestions),
        growth: isLoading ? '' : activeGrowth,
        isGrowthPositive: activePositive,
        subtitle: isLoading ? 'Loading status...' : 'Published & ready',
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF10B981),
        sparklineData: activeSparkline,
      ),
      (
        title: 'Draft Questions',
        value: isLoading ? '—' : _formatNumber(draftQuestions),
        growth: isLoading ? '' : draftGrowth,
        isGrowthPositive: draftPositive,
        subtitle: isLoading ? 'Loading drafts...' : 'Linked to draft tests',
        icon: Icons.edit_note_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: draftSparkline,
      ),
      (
        title: 'Archived Questions',
        value: isLoading ? '—' : _formatNumber(archivedQuestions),
        growth: isLoading ? '' : archivedGrowth,
        isGrowthPositive: archivedPositive,
        subtitle: isLoading ? 'Loading archive...' : 'Linked to archived tests',
        icon: Icons.archive_outlined,
        color: const Color(0xFF8B5CF6),
        sparklineData: archivedSparkline,
      ),
      (
        title: 'Question Sets',
        value: isLoading ? '—' : _formatNumber(questionSets),
        growth: isLoading ? '' : setsGrowth,
        isGrowthPositive: setsPositive,
        subtitle: isLoading ? 'Loading sets...' : 'Test series pools',
        icon: Icons.layers_rounded,
        color: const Color(0xFFEF4444),
        sparklineData: setsSparkline,
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
