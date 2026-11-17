import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Quiz Category Distribution Card
/// Powered by the centralized, reusable [AppDonutChartCard] from the design system.
/// Displays genuine database category distribution or clean empty state.
class LiveQuizCategoryDonutCard extends StatelessWidget {
  final int totalCount;
  final VoidCallback? onViewAll;
  final List<DonutSlice> slices;
  final double? height;
  final bool fillHeight;

  const LiveQuizCategoryDonutCard({
    super.key,
    this.totalCount = 0,
    this.onViewAll,
    this.height,
    this.fillHeight = false,
    this.slices = const [],
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSlices = slices.isNotEmpty
        ? slices
        : const [
            DonutSlice(
              label: 'None',
              percentage: 100,
              color: Color(0xFFE2E8F0),
              count: 0,
            ),
          ];

    return AppDonutChartCard(
      title: 'Quiz Category Distribution',
      icon: Icons.pie_chart_rounded,
      iconBg: const Color(0xFF6B4EFF),
      totalCount: totalCount,
      totalLabel: 'Total',
      slices: effectiveSlices,
      height: height ?? (fillHeight ? null : 195),
      fillHeight: fillHeight,
      chartSize: 92,
      strokeWidth: 13.5,
      strokeCap: StrokeCap.round,
      trailingHeader: onViewAll != null
          ? MouseRegion(
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
            )
          : null,
    );
  }
}
