import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Test Difficulty Distribution Card
/// Powered by the centralized, reusable [AppDonutChartCard] from design_system.
class AiDifficultyDonutCard extends StatelessWidget {
  final int totalCount;
  final VoidCallback? onViewAll;
  final List<DonutSlice> slices;
  final double? height;
  final bool fillHeight;

  const AiDifficultyDonutCard({
    super.key,
    this.totalCount = 124,
    this.onViewAll,
    this.height,
    this.fillHeight = false,
    this.slices = const [
      DonutSlice(label: 'Easy', percentage: 32, color: Color(0xFF10B981), count: 40),
      DonutSlice(label: 'Medium', percentage: 48, color: Color(0xFFFF9F0A), count: 60),
      DonutSlice(label: 'Hard', percentage: 20, color: Color(0xFFF0445F), count: 24),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return AppDonutChartCard(
      title: 'Test Difficulty Distribution',
      icon: Icons.speed_rounded,
      iconBg: const Color(0xFF2587F8),
      totalCount: totalCount,
      totalLabel: 'Total',
      slices: slices,
      height: height ?? (fillHeight ? null : 185),
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
              color: Color(0xFF2587F8),
            ),
          ),
        ),
      ),
    );
  }
}
