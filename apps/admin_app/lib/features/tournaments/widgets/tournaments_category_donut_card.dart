import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Tournament Category Distribution Card
/// Powered by the centralized, reusable [AppDonutChartCard] from the design system.
class TournamentsCategoryDonutCard extends StatelessWidget {
  final int totalCount;
  final VoidCallback? onViewAll;
  final List<DonutSlice> slices;
  final double? height;
  final bool fillHeight;

  const TournamentsCategoryDonutCard({
    super.key,
    this.totalCount = 24,
    this.onViewAll,
    this.height,
    this.fillHeight = false,
    this.slices = const [
      DonutSlice(label: 'Railway', percentage: 28, color: Color(0xFF2587F8), count: 7),
      DonutSlice(label: 'General Science', percentage: 18, color: Color(0xFF6B4EFF), count: 4),
      DonutSlice(label: 'Mathematics', percentage: 15, color: Color(0xFFF04483), count: 4),
      DonutSlice(label: 'Current Affairs', percentage: 12, color: Color(0xFFFF9F0A), count: 3),
      DonutSlice(label: 'State Level', percentage: 10, color: Color(0xFF00C48C), count: 2),
      DonutSlice(label: 'Reasoning', percentage: 8, color: Color(0xFF06B6D4), count: 2),
      DonutSlice(label: 'Biology', percentage: 6, color: Color(0xFF10B981), count: 2),
      DonutSlice(label: 'Others', percentage: 3, color: Color(0xFFFBC531), count: 1),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return AppDonutChartCard(
      title: 'Tournament Category Distribution',
      icon: Icons.pie_chart_rounded,
      iconBg: const Color(0xFF6B4EFF),
      totalCount: totalCount,
      totalLabel: 'Total',
      slices: slices,
      height: height ?? (fillHeight ? null : 205),
      fillHeight: fillHeight,
      chartSize: 92,
      strokeWidth: 13.5,
      strokeCap: StrokeCap.round,
      trailingHeader: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onViewAll,
          child: const Text(
            'View All',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B4EFF),
            ),
          ),
        ),
      ),
    );
  }
}
