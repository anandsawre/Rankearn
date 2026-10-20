import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

typedef SubjectSlice = DonutSlice;

/// Subject Wise Test Series Donut Chart Card
/// Powered by the centralized, reusable [AppDonutChartCard].
class SubjectWiseChartCard extends StatelessWidget {
  final double? height;
  final bool fillHeight;
  final int totalCount;
  final List<DonutSlice> slices;

  const SubjectWiseChartCard({
    super.key,
    this.height,
    this.fillHeight = false,
    this.totalCount = 42,
    this.slices = const [
      DonutSlice(label: 'General Science', percentage: 24, color: Color(0xFF3B82F6)),
      DonutSlice(label: 'Mathematics', percentage: 20, color: Color(0xFF8B5CF6)),
      DonutSlice(label: 'Reasoning', percentage: 18, color: Color(0xFFF59E0B)),
      DonutSlice(label: 'Current Affairs', percentage: 14, color: Color(0xFF06B6D4)),
      DonutSlice(label: 'Chemistry', percentage: 10, color: Color(0xFFEC4899)),
      DonutSlice(label: 'Biology', percentage: 8, color: Color(0xFFEA580C)),
      DonutSlice(label: 'Others', percentage: 6, color: Color(0xFF94A3B8)),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return AppDonutChartCard(
      title: 'Subject Wise Test Series',
      icon: Icons.pie_chart_rounded,
      iconBg: const Color(0xFF3B82F6),
      totalCount: totalCount,
      totalLabel: 'Total',
      slices: slices,
      height: height,
      fillHeight: fillHeight,
      chartSize: 92,
      strokeWidth: 13.5,
      strokeCap: StrokeCap.round,
    );
  }
}
