import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class CommunityOverviewPanel extends StatelessWidget {
  final VoidCallback onViewAsUser;
  final VoidCallback onManageComments;
  final VoidCallback onPinnedPosts;
  final VoidCallback onScheduledPosts;
  final VoidCallback onPostAnalytics;

  const CommunityOverviewPanel({
    super.key,
    required this.onViewAsUser,
    required this.onManageComments,
    required this.onPinnedPosts,
    required this.onScheduledPosts,
    required this.onPostAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Community Overview (Tokenized KPI Cards in 2x2 Grid)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.adminCardBackground,
            borderRadius: AppRadii.adminCard,
            border: Border.all(color: AppColors.adminBorder),
            boxShadow: AppShadows.adminCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart_rounded, size: 20, color: AppColors.adminPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Community Overview',
                      style: AppTypography.adminCardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2x2 Grid of Tokenized Admin KPI Cards
              Row(
                children: const [
                  Expanded(
                    child: AdminKpiCard(
                      icon: Icons.groups_rounded,
                      iconColor: AppColors.adminPurple,
                      iconBgColor: AppColors.adminPurpleLight,
                      value: '45,280',
                      label: 'Total Members',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: AdminKpiCard(
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.adminSuccess,
                      iconBgColor: AppColors.adminSuccessLight,
                      value: '+12%',
                      label: 'Growth (7 Days)',
                      growth: '+12%',
                      isGrowthPositive: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Expanded(
                    child: AdminKpiCard(
                      icon: Icons.article_outlined,
                      iconColor: AppColors.adminBlue,
                      iconBgColor: AppColors.adminBlueLight,
                      value: '142',
                      label: 'Total Posts',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: AdminKpiCard(
                      icon: Icons.chat_bubble_outline_rounded,
                      iconColor: AppColors.adminWarning,
                      iconBgColor: AppColors.adminAmberLight,
                      value: '6,842',
                      label: 'Total Comments',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. Quick Actions
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.adminCardBackground,
            borderRadius: AppRadii.adminCard,
            border: Border.all(color: AppColors.adminBorder),
            boxShadow: AppShadows.adminCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on_rounded, size: 20, color: AppColors.adminPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Quick Actions',
                      style: AppTypography.adminCardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _buildActionTile(
                icon: Icons.visibility_outlined,
                title: 'View as User',
                color: AppColors.adminPurple,
                onTap: onViewAsUser,
              ),
              const SizedBox(height: 8),

              _buildActionTile(
                icon: Icons.forum_outlined,
                title: 'Manage Comments',
                badge: '24',
                badgeColor: AppColors.adminDanger,
                color: AppColors.adminSky,
                onTap: onManageComments,
              ),
              const SizedBox(height: 8),

              _buildActionTile(
                icon: Icons.push_pin_outlined,
                title: 'Pinned Posts',
                badge: '3',
                badgeColor: AppColors.adminPurple,
                color: AppColors.adminPurple,
                onTap: onPinnedPosts,
              ),
              const SizedBox(height: 8),

              _buildActionTile(
                icon: Icons.calendar_month_outlined,
                title: 'Scheduled Posts',
                badge: '5',
                badgeColor: AppColors.adminWarning,
                color: AppColors.adminWarning,
                onTap: onScheduledPosts,
              ),
              const SizedBox(height: 8),

              _buildActionTile(
                icon: Icons.insights_rounded,
                title: 'Post Analytics',
                color: AppColors.adminSuccess,
                onTap: onPostAnalytics,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? badge,
    Color? badgeColor,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.adminControl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.adminBackground,
          borderRadius: AppRadii.adminControl,
          border: Border.all(color: AppColors.adminBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: AppTypography.adminTablePrimary.copyWith(fontSize: 12),
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.adminPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.adminSecondaryText),
          ],
        ),
      ),
    );
  }
}
