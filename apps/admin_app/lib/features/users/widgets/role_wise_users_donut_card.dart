import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class RoleWiseUsersDonutCard extends StatelessWidget {
  final bool fillHeight;
  final int totalUsers;
  final List<DonutSlice> slices;
  final bool isLoading;
  final VoidCallback? onViewAll;

  const RoleWiseUsersDonutCard({
    super.key,
    this.fillHeight = false,
    this.totalUsers = 0,
    this.slices = const [],
    this.isLoading = false,
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
      height: fillHeight ? null : 210,
      chartSize: 92,
      strokeWidth: 13.5,
      strokeCap: StrokeCap.round,
      isLoading: isLoading,
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
                    color: Color(0xFF6B4EFF),
                  ),
                ),
              ),
            ),
      slices: slices,
    );
  }
}
