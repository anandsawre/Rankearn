import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Categories Metrics Row
/// Displays 5 responsive statistics cards powered by the unified [AdminMetricCard]
/// from the Rankearn design system.
class CategoriesMetricsRow extends StatelessWidget {
  final int totalCategories;
  final int activeCategories;
  final int draftCategories;
  final int archivedCategories;
  final int totalSubjects;

  const CategoriesMetricsRow({
    super.key,
    this.totalCategories = 48,
    this.activeCategories = 42,
    this.draftCategories = 4,
    this.archivedCategories = 2,
    this.totalSubjects = 128,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (
        title: 'Total Exams',
        value: totalCategories.toString(),
        growth: '+12%',
        isGrowthPositive: true,
        subtitle: '+6 this month',
        icon: Icons.explore_rounded,
        color: const Color(0xFF3B82F6),
        sparklineData: const [20.0, 24.0, 22.0, 28.0, 35.0, 42.0, 48.0],
      ),
      (
        title: 'Published Exams',
        value: activeCategories.toString(),
        growth: '+10%',
        isGrowthPositive: true,
        subtitle: '+5 this month',
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF10B981),
        sparklineData: const [18.0, 22.0, 26.0, 30.0, 36.0, 40.0, 42.0],
      ),
      (
        title: 'Draft Exams',
        value: draftCategories.toString(),
        growth: '-20%',
        isGrowthPositive: false,
        subtitle: '-1 this month',
        icon: Icons.edit_note_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: const [8.0, 7.0, 9.0, 6.0, 5.0, 4.0, 4.0],
      ),
      (
        title: 'Archived Exams',
        value: archivedCategories.toString(),
        growth: '+0%',
        isGrowthPositive: true,
        subtitle: '0 this month',
        icon: Icons.archive_rounded,
        color: const Color(0xFF8B5CF6),
        sparklineData: const [2.0, 2.0, 2.0, 3.0, 2.0, 2.0, 2.0],
      ),
      (
        title: 'Total Subjects',
        value: totalSubjects.toString(),
        growth: '+18%',
        isGrowthPositive: true,
        subtitle: '+20 this month',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFEF4444),
        sparklineData: const [12.0, 15.0, 14.0, 18.0, 20.0, 24.0, 28.0],
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
