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
    this.totalCount = 0,
    this.slices = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AppDonutChartCard(
      title: 'Subject Wise Test Series',
      icon: Icons.pie_chart_rounded,
      iconBg: const Color(0xFF3B82F6),
      totalCount: totalCount,
      totalLabel: 'Total',
      slices: slices.isEmpty
          ? const [DonutSlice(label: 'No Data', percentage: 100, color: Color(0xFFCBD5E1))]
          : slices,
      height: height,
      fillHeight: fillHeight,
      chartSize: 92,
      strokeWidth: 13.5,
      strokeCap: StrokeCap.round,
    );
  }
}
