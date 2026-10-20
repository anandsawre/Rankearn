import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class RoleWiseUsersDonutCard extends StatelessWidget {
  final bool fillHeight;
  final int totalUsers;
  final VoidCallback? onViewAll;

  const RoleWiseUsersDonutCard({
    super.key,
    this.fillHeight = false,
    this.totalUsers = 12458,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return AppDonutChartCard(
      title: 'Role Wise Users',
      icon: Icons.pie_chart_rounded,
      iconBg: const Color(0xFF8B5CF6),
      totalCount: totalUsers,
      totalLabel: 'Total',
      fillHeight: fillHeight,
      height: fillHeight ? null : 195,
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
              color: Color(0xFF6B4EFF),
            ),
          ),
        ),
      ),
      slices: const [
        DonutSlice(
          label: 'Students',
          percentage: 72,
          count: 8972,
          color: Color(0xFF2587F8),
        ),
        DonutSlice(
          label: 'Premium',
          percentage: 18,
          count: 2241,
          color: Color(0xFF7C3AED),
        ),
        DonutSlice(
          label: 'Teachers',
          percentage: 5,
          count: 623,
          color: Color(0xFFF59E0B),
        ),
        DonutSlice(
          label: 'Moderators',
          percentage: 3,
          count: 374,
          color: Color(0xFF10B981),
        ),
        DonutSlice(
          label: 'Others',
          percentage: 2,
          count: 248,
          color: Color(0xFFEC4899),
        ),
      ],
    );
  }
}
