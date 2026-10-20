import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class CategoryWiseTestsDonutCard extends StatelessWidget {
  final bool fillHeight;
  final int totalTests;

  const CategoryWiseTestsDonutCard({
    super.key,
    this.fillHeight = false,
    this.totalTests = 320,
  });

  @override
  Widget build(BuildContext context) {
    return AppDonutChartCard(
      title: 'Category Wise Test Series',
      icon: Icons.pie_chart_rounded,
      iconBg: const Color(0xFF8B5CF6),
      totalCount: totalTests,
      totalLabel: 'Total',
      fillHeight: fillHeight,
      height: fillHeight ? null : 195,
      chartSize: 92,
      strokeWidth: 13.5,
      strokeCap: StrokeCap.round,
      slices: const [
        DonutSlice(label: 'Competitive Exams', percentage: 28, color: Color(0xFF3B82F6)),
        DonutSlice(label: 'School Education', percentage: 18, color: Color(0xFF8B5CF6)),
        DonutSlice(label: 'State Level Exams', percentage: 15, color: Color(0xFFF59E0B)),
        DonutSlice(label: 'Entrance Exams', percentage: 14, color: Color(0xFF06B6D4)),
        DonutSlice(label: 'Skill Development', percentage: 10, color: Color(0xFF10B981)),
        DonutSlice(label: 'General Awareness', percentage: 9, color: Color(0xFFEC4899)),
        DonutSlice(label: 'Practice & Mock', percentage: 6, color: Color(0xFFF43F5E)),
      ],
    );
  }
}
