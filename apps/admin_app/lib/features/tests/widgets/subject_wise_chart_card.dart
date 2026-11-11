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
  final bool isLoading;

  const SubjectWiseChartCard({
    super.key,
    this.height,
    this.fillHeight = false,
    this.totalCount = 0,
    this.slices = const [],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppDonutChartCard(
      title: 'Subject Wise Test Series',
      icon: Icons.pie_chart_rounded,
      iconBg: AppColors.brandBlue,
      totalCount: totalCount,
      totalLabel: 'Total',
      slices: slices,
      isLoading: isLoading,
      height: height,
      fillHeight: fillHeight,
      chartSize: 100,
      strokeWidth: 15.0,
      strokeCap: StrokeCap.round,
    );
  }
}
