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
        // 1. Community Overview
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.adminCard,
            border: Border.all(color: AppColors.adminBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart_rounded, size: 20, color: AppColors.adminPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Community Overview', style: AppTypography.adminCardTitle, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2x2 Grid of stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatTile(
                      icon: Icons.groups_rounded,
                      iconBg: AppColors.adminPurpleLight,
                      iconColor: AppColors.adminPurple,
                      value: '45,280',
                      label: 'Total Members',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatTile(
                      icon: Icons.trending_up_rounded,
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: AppColors.adminSuccess,
                      value: '+12%',
                      label: 'Growth (7 Days)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatTile(
                      icon: Icons.article_outlined,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      value: '142',
                      label: 'Total Posts',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      iconBg: const Color(0xFFFFFBEB),
                      iconColor: const Color(0xFFF59E0B),
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
            color: Colors.white,
            borderRadius: AppRadii.adminCard,
            border: Border.all(color: AppColors.adminBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on_rounded, size: 20, color: AppColors.adminPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Quick Actions', style: AppTypography.adminCardTitle, overflow: TextOverflow.ellipsis),
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
                color: const Color(0xFF0284C7),
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
                badgeColor: const Color(0xFFF59E0B),
                color: const Color(0xFFF59E0B),
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

  Widget _buildStatTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.adminBackground,
        borderRadius: AppRadii.adminControl,
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.adminPrimaryText),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.adminSecondaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.adminPrimaryText),
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
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
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

