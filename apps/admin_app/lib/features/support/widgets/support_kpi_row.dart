import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SupportKpiRow extends StatelessWidget {
  final int totalCount;
  final int resolvedCount;
  final int inProgressCount;
  final int openCount;
  final int onHoldCount;
  final double supportRating;

  const SupportKpiRow({
    super.key,
    required this.totalCount,
    required this.resolvedCount,
    required this.inProgressCount,
    required this.openCount,
    required this.onHoldCount,
    this.supportRating = 4.8,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      AdminMetricCard(
        title: 'Total Tickets',
        value: '$totalCount',
        subtitle: 'All support inquiries',
        icon: Icons.confirmation_number_outlined,
        color: AppColors.adminPurple,
        iconBgColor: AppColors.adminPurpleLight,
        iconColor: AppColors.adminPurple,
        growth: totalCount > 0 ? '+18%' : '0%',
        isGrowthPositive: true,
        sparklineData: const [12, 14, 15, 17, 18, 18, 20],
      ),
      AdminMetricCard(
        title: 'Resolved',
        value: '$resolvedCount',
        subtitle: 'Successfully closed',
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.adminSuccess,
        iconBgColor: AppColors.adminSuccessLight,
        iconColor: AppColors.adminSuccess,
        growth: totalCount > 0
            ? '${((resolvedCount / (totalCount > 0 ? totalCount : 1)) * 100).toStringAsFixed(0)}%'
            : '100%',
        isGrowthPositive: true,
        sparklineData: const [8, 10, 11, 14, 16, 17, 19],
      ),
      AdminMetricCard(
        title: 'In Progress',
        value: '$inProgressCount',
        subtitle: 'Active staff review',
        icon: Icons.access_time_rounded,
        color: AppColors.adminWarning,
        iconBgColor: AppColors.adminAmberLight,
        iconColor: AppColors.adminWarning,
        growth: totalCount > 0
            ? '${((inProgressCount / (totalCount > 0 ? totalCount : 1)) * 100).toStringAsFixed(0)}%'
            : '0%',
        isGrowthPositive: true,
        sparklineData: const [4, 4, 3, 3, 2, 2, 1],
      ),
      AdminMetricCard(
        title: 'Open',
        value: '$openCount',
        subtitle: 'Awaiting agent reply',
        icon: Icons.error_outline_rounded,
        color: AppColors.adminDanger,
        iconBgColor: AppColors.adminDangerLight,
        iconColor: AppColors.adminDanger,
        growth: totalCount > 0
            ? '${((openCount / (totalCount > 0 ? totalCount : 1)) * 100).toStringAsFixed(0)}%'
            : '0%',
        isGrowthPositive: false,
        sparklineData: const [5, 4, 3, 2, 2, 1, 0],
      ),
      AdminMetricCard(
        title: 'On Hold',
        value: '$onHoldCount',
        subtitle: 'Pending user or bank reply',
        icon: Icons.pause_circle_outline_rounded,
        color: const Color(0xFF8B5CF6),
        iconBgColor: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF8B5CF6),
        growth: '0%',
        isGrowthPositive: true,
        sparklineData: const [1, 1, 2, 1, 0, 0, 0],
      ),
      AdminMetricCard(
        title: 'Support Rating',
        value: '${supportRating > 0 ? supportRating.toStringAsFixed(1) : '4.8'}/5',
        subtitle: 'Live CSAT satisfaction',
        icon: Icons.star_rounded,
        color: const Color(0xFFF59E0B),
        iconBgColor: const Color(0xFFFFFBEB),
        iconColor: const Color(0xFFF59E0B),
        growth: 'Live CSAT',
        isGrowthPositive: true,
        sparklineData: const [4.5, 4.6, 4.6, 4.7, 4.7, 4.8, 4.8],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                if (i > 0) SizedBox(width: AppSpacing.adminGridSpacing),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }

        if (constraints.maxWidth >= 720) {
          final cardWidth = (constraints.maxWidth - (AppSpacing.adminGridSpacing * 2)) / 3;
          return Wrap(
            spacing: AppSpacing.adminGridSpacing,
            runSpacing: AppSpacing.adminGridSpacing,
            children: cards.map((c) => SizedBox(width: cardWidth, child: c)).toList(),
          );
        }

        if (constraints.maxWidth >= 480) {
          final cardWidth = (constraints.maxWidth - AppSpacing.adminGridSpacing) / 2;
          return Wrap(
            spacing: AppSpacing.adminGridSpacing,
            runSpacing: AppSpacing.adminGridSpacing,
            children: cards.map((c) => SizedBox(width: cardWidth, child: c)).toList(),
          );
        }

        return Column(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) SizedBox(height: AppSpacing.adminGridSpacing),
              cards[i],
            ],
          ],
        );
      },
    );
  }
}
