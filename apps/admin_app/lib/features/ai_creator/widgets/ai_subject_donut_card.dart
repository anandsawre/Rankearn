import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Subject Wise Test Distribution Card
/// Powered by the centralized, reusable [AppDonutChartCard] from design_system.
class AiSubjectDonutCard extends StatelessWidget {
  final int totalCount;
  final VoidCallback? onViewAll;
  final List<DonutSlice> slices;
  final double? height;
  final bool fillHeight;

  const AiSubjectDonutCard({
    super.key,
    this.totalCount = 124,
    this.onViewAll,
    this.height,
    this.fillHeight = false,
    this.slices = const [
      DonutSlice(label: 'General Science', percentage: 24, color: Color(0xFF2587F8), count: 30),
      DonutSlice(label: 'Mathematics', percentage: 20, color: Color(0xFF06B6D4), count: 25),
      DonutSlice(label: 'Reasoning', percentage: 18, color: Color(0xFF5636F5), count: 22),
      DonutSlice(label: 'Current Affairs', percentage: 14, color: Color(0xFFFF9F0A), count: 17),
      DonutSlice(label: 'Chemistry', percentage: 10, color: Color(0xFFF04483), count: 12),
      DonutSlice(label: 'Biology', percentage: 8, color: Color(0xFF10B981), count: 10),
      DonutSlice(label: 'Others', percentage: 6, color: Color(0xFF94A3B8), count: 8),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return AppDonutChartCard(
      title: 'Subject Wise Test Distribution',
      icon: Icons.pie_chart_rounded,
      iconBg: const Color(0xFF5636F5),
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
              color: Color(0xFF5636F5),
            ),
          ),
        ),
      ),
    );
  }
}
