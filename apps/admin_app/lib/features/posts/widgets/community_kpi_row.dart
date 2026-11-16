import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Horizontal KPI Row for Community Post Management screen.
/// Follows the Dashboard / Overview tab horizontal layout with [AdminMetricCard].
class CommunityKpiRow extends StatelessWidget {
  final String totalMembers;
  final String growth;
  final String totalPosts;
  final String totalComments;

  const CommunityKpiRow({
    super.key,
    this.totalMembers = '45,280',
    this.growth = '+12%',
    this.totalPosts = '142',
    this.totalComments = '6,842',
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;
    final isTablet = screenWidth >= 650 && screenWidth < 1100;

    final cards = [
      AdminMetricCard(
        title: 'Total Members',
        value: totalMembers,
        subtitle: 'Registered platform users',
        icon: Icons.groups_rounded,
        color: AppColors.adminPurple,
        growth: '+12.4%',
        isGrowthPositive: true,
        sparklineData: const [25, 34, 45, 52, 68, 75, 92],
      ),
      AdminMetricCard(
        title: 'Growth (7 Days)',
        value: growth,
        subtitle: 'Active weekly gain',
        icon: Icons.trending_up_rounded,
        color: AppColors.adminSuccess,
        growth: '+12.0%',
        isGrowthPositive: true,
        sparklineData: const [10, 14, 18, 22, 28, 35, 42],
      ),
      AdminMetricCard(
        title: 'Total Posts',
        value: totalPosts,
        subtitle: 'Published discussions',
        icon: Icons.article_outlined,
        color: AppColors.adminBlue,
        growth: '+8.5%',
        isGrowthPositive: true,
        sparklineData: const [40, 52, 60, 78, 90, 115, 142],
      ),
      AdminMetricCard(
        title: 'Total Comments',
        value: totalComments,
        subtitle: 'Learner responses',
        icon: Icons.chat_bubble_outline_rounded,
        color: AppColors.adminWarning,
        growth: '+15.2%',
        isGrowthPositive: true,
        sparklineData: const [30, 40, 50, 62, 70, 85, 98],
      ),
    ];

    if (isDesktop) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 14),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }

    if (isTablet) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: cards
            .map((c) => SizedBox(
                  width: (screenWidth - 48 - 12) / 2,
                  child: c,
                ))
            .toList(),
      );
    }

    return Column(
      children: cards
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: c,
              ))
          .toList(),
    );
  }
}
