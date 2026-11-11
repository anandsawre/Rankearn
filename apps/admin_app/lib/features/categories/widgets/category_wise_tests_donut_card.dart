import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class CategoryWiseTestsDonutCard extends StatelessWidget {
  final bool fillHeight;
  final int totalTests;
  final List<DonutSlice> slices;
  final bool isLoading;

  const CategoryWiseTestsDonutCard({
    super.key,
    this.fillHeight = false,
    this.totalTests = 0,
    this.slices = const [],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppDonutChartCard(
      title: 'Exam Wise Test Series',
      icon: Icons.pie_chart_rounded,
      iconBg: const Color(0xFF8B5CF6),
      totalCount: totalTests,
      totalLabel: 'Total',
      fillHeight: fillHeight,
      height: fillHeight ? null : 210,
      chartSize: 92,
      strokeWidth: 13.5,
      strokeCap: StrokeCap.round,
      isLoading: isLoading,
      slices: slices,
    );
  }
}
