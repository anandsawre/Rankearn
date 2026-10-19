import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/typography.dart';

enum AdminNavTab {
  overview,
  tests,
  users,
  patterns,
  aiCreator,
  finance,
  contests,
  banners,
  notifications,
  wheel,
  leaderboard,
  referrals,
  posts,
  support,
  feedback,
  battleQs,
  polls,
  settings,
}

/// Rankearn Desktop Admin Sidebar Navigation Rail (18 Tabs)
/// Direct parity with `apps/admin/src/App.tsx:16-35`.
class AdminSidebar extends StatelessWidget {
  final AdminNavTab currentTab;
  final ValueChanged<AdminNavTab> onTabSelected;
  final VoidCallback? onLogout;

  const AdminSidebar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      (AdminNavTab.overview, Icons.dashboard_outlined, 'Overview'),
      (AdminNavTab.tests, Icons.menu_book_outlined, 'Test Series'),
      (AdminNavTab.users, Icons.people_outline, 'Users'),
      (AdminNavTab.patterns, Icons.layers_outlined, 'Exam Patterns'),
      (AdminNavTab.aiCreator, Icons.psychology_outlined, 'AI Test Creator'),
      (AdminNavTab.finance, Icons.currency_rupee, 'Finance'),
      (AdminNavTab.contests, Icons.emoji_events_outlined, 'Contests'),
      (AdminNavTab.banners, Icons.image_outlined, 'Banners'),
      (AdminNavTab.notifications, Icons.notifications_none, 'Notifications'),
      (AdminNavTab.wheel, Icons.rotate_right, 'Lucky Wheel'),
      (AdminNavTab.leaderboard, Icons.bar_chart_outlined, 'Leaderboard'),
      (AdminNavTab.referrals, Icons.card_giftcard_outlined, 'Referrals'),
      (AdminNavTab.posts, Icons.article_outlined, 'Updates'),
      (AdminNavTab.support, Icons.chat_bubble_outline, 'Support Chat'),
      (AdminNavTab.feedback, Icons.star_outline, 'Give Feedback'),
      (AdminNavTab.battleQs, Icons.sports_kabaddi, 'Battle Questions'),
      (AdminNavTab.polls, Icons.poll_outlined, 'Community Polls'),
      (AdminNavTab.settings, Icons.settings_outlined, 'Settings'),
    ];

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: navItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 3),
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = currentTab == item.$1;

                return InkWell(
                  onTap: () => onTabSelected(item.$1),
                  borderRadius: AppRadii.borderMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.brandPrimaryLight : Colors.transparent,
                      borderRadius: AppRadii.borderMd,
                      border: isSelected
                          ? Border.all(color: AppColors.brandPrimary.withAlpha(80), width: 1)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.$2,
                          size: 20,
                          color: isSelected ? AppColors.brandPrimary : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.$3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleSmall.copyWith(
                              fontSize: 13,
                              color: isSelected ? AppColors.brandPrimaryDark : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          if (onLogout != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                onTap: onLogout,
                borderRadius: AppRadii.borderMd,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: const Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.errorRose, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: AppColors.errorRose,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
