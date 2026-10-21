import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Quiz Category Distribution Card
/// Powered by the centralized, reusable [AppDonutChartCard] from the design system.
class LiveQuizCategoryDonutCard extends StatelessWidget {
  final int totalCount;
  final VoidCallback? onViewAll;
  final List<DonutSlice> slices;
  final double? height;
  final bool fillHeight;

  const LiveQuizCategoryDonutCard({
    super.key,
    this.totalCount = 128,
    this.onViewAll,
    this.height,
    this.fillHeight = false,
    this.slices = const [
      DonutSlice(label: 'Railway', percentage: 22, color: Color(0xFF2587F8), count: 28),
      DonutSlice(label: 'General Science', percentage: 18, color: Color(0xFF6B4EFF), count: 23),
      DonutSlice(label: 'Mathematics', percentage: 15, color: Color(0xFFF04483), count: 19),
      DonutSlice(label: 'Current Affairs', percentage: 14, color: Color(0xFFFF9F0A), count: 18),
      DonutSlice(label: 'Reasoning', percentage: 12, color: Color(0xFF00C48C), count: 15),
      DonutSlice(label: 'Biology', percentage: 10, color: Color(0xFF10B981), count: 13),
      DonutSlice(label: 'Mixed', percentage: 9, color: Color(0xFFFBC531), count: 12),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return AppDonutChartCard(
      title: 'Quiz Category Distribution',
      icon: Icons.pie_chart_rounded,
      iconBg: const Color(0xFF6B4EFF),
      totalCount: totalCount,
      totalLabel: 'Total',
      slices: slices,
      height: height ?? (fillHeight ? null : 195),
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
