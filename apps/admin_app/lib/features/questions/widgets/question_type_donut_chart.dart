import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Question Type Distribution Donut Chart Card
/// Powered by the centralized, reusable [AppDonutChartCard].
class QuestionTypeDonutChartCard extends StatelessWidget {
  final bool fillHeight;
  final int totalCount;

  const QuestionTypeDonutChartCard({
    super.key,
    this.fillHeight = false,
    this.totalCount = 9842,
  });

  @override
  Widget build(BuildContext context) {
    return AppDonutChartCard(
      title: 'Question Type Distribution',
      icon: Icons.pie_chart_rounded,
      iconBg: const Color(0xFF3B82F6),
      totalCount: totalCount,
      totalLabel: 'Total',
      fillHeight: fillHeight,
      height: fillHeight ? null : 145,
      chartSize: 92,
      strokeWidth: 13.5,
      strokeCap: StrokeCap.round,
      slices: const [
        DonutSlice(label: 'MCQ', percentage: 68, color: Color(0xFF3B82F6)),
        DonutSlice(label: 'True/False', percentage: 12, color: Color(0xFF8B5CF6)),
        DonutSlice(label: 'Fill in the Blanks', percentage: 8, color: Color(0xFFF59E0B)),
        DonutSlice(label: 'Match the Following', percentage: 6, color: Color(0xFF06B6D4)),
        DonutSlice(label: 'Assertion & Reason', percentage: 4, color: Color(0xFFEC4899)),
        DonutSlice(label: 'Subjective', percentage: 2, color: Color(0xFF94A3B8)),
      ],
    );
  }
}
