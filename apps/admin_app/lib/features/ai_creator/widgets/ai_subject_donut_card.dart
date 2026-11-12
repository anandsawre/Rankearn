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
  final bool isLoading;

  const AiSubjectDonutCard({
    super.key,
    this.totalCount = 0,
    this.onViewAll,
    this.height,
    this.fillHeight = false,
    this.slices = const [],
    this.isLoading = false,
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
      isLoading: isLoading,
      height: height ?? (fillHeight ? null : 210),
      fillHeight: fillHeight,
      chartSize: 92,
      strokeWidth: 13.5,
      strokeCap: StrokeCap.round,
      trailingHeader: onViewAll == null
          ? null
          : MouseRegion(
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
