import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Subject Wise Questions Donut Chart Card
/// Powered by [AppDonutChartCard] with live database counts and slices.
class QuestionTypeDonutChartCard extends StatelessWidget {
  final bool fillHeight;
  final int totalCount;
  final List<DonutSlice> slices;
  final bool isLoading;

  const QuestionTypeDonutChartCard({
    super.key,
    this.fillHeight = false,
    this.totalCount = 0,
    this.slices = const [],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppDonutChartCard(
      title: 'Subject Wise Questions',
      icon: Icons.pie_chart_rounded,
      iconBg: const Color(0xFF8B5CF6),
      totalCount: totalCount,
      totalLabel: 'Total',
      fillHeight: fillHeight,
      height: fillHeight ? null : 210,
      chartSize: 92,
      strokeWidth: 14.0,
      strokeCap: StrokeCap.round,
      isLoading: isLoading,
      slices: slices,
    );
  }
}
