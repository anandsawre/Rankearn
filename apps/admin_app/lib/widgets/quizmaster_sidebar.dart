import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class QuizMasterSidebar extends StatelessWidget {
  final AdminNavTab currentTab;
  final ValueChanged<AdminNavTab> onTabSelected;
  final VoidCallback? onLogout;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  const QuizMasterSidebar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.onLogout,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final width = isCollapsed ? 76.0 : 252.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Sidebar Top Header
          Container(
            height: 58,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (!isCollapsed)
                  const Text(
                    'NAVIGATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.2,
                    ),
                  ),
                if (onToggleCollapse != null)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: Icon(
                      isCollapsed
                          ? Icons.menu_open_rounded
                          : Icons.menu_rounded,
                      color: const Color(0xFF64748B),
                      size: 20,
                    ),
                    tooltip: isCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
                    onPressed: onToggleCollapse,
                  ),
              ],
            ),
          ),

          // Scrollable List of All 18 Tabs
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              children: [
                _buildSectionHeader('CORE MODULES'),
                _buildNavItem(
                  tab: AdminNavTab.overview,
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                ),
                _buildNavItem(
                  tab: AdminNavTab.tests,
                  icon: Icons.menu_book_outlined,
                  label: 'Test Series',
                ),
                _buildNavItem(
                  tab: AdminNavTab.users,
                  icon: Icons.people_outline_rounded,
                  label: 'Users Management',
                ),
                _buildNavItem(
                  tab: AdminNavTab.patterns,
                  icon: Icons.layers_outlined,
                  label: 'Exam Patterns',
                ),
                _buildNavItem(
                  tab: AdminNavTab.aiCreator,
                  icon: Icons.psychology_outlined,
                  label: 'AI Test Creator',
                  badgeText: 'AI',
                  badgeColor: const Color(0xFF6366F1),
                ),

                const SizedBox(height: 10),
                _buildSectionHeader('LIVE & COMMUNITY'),
                _buildNavItem(
                  tab: AdminNavTab.contests,
                  icon: Icons.podcasts_rounded,
                  label: 'Live Quiz & Contests',
                  badgeText: 'LIVE',
                  badgeColor: const Color(0xFFEF4444),
                ),
                _buildNavItem(
                  tab: AdminNavTab.leaderboard,
                  icon: Icons.emoji_events_outlined,
                  label: 'Tournaments',
                ),
                _buildNavItem(
                  tab: AdminNavTab.wheel,
                  icon: Icons.rotate_right_rounded,
                  label: 'Lucky Wheel',
                ),
                _buildNavItem(
                  tab: AdminNavTab.polls,
                  icon: Icons.poll_outlined,
                  label: 'Community Polls',
                ),
                _buildNavItem(
                  tab: AdminNavTab.posts,
                  icon: Icons.article_outlined,
                  label: 'Updates & Posts',
                ),
                _buildNavItem(
                  tab: AdminNavTab.battleQs,
                  icon: Icons.sports_kabaddi_rounded,
                  label: 'Battle Questions',
                ),

                const SizedBox(height: 10),
                _buildSectionHeader('FINANCE & GROWTH'),
                _buildNavItem(
                  tab: AdminNavTab.finance,
                  icon: Icons.currency_rupee_rounded,
                  label: 'Finance & Top-ups',
                ),
                _buildNavItem(
                  tab: AdminNavTab.referrals,
                  icon: Icons.card_giftcard_outlined,
                  label: 'Referrals Engine',
                ),
                _buildNavItem(
                  tab: AdminNavTab.banners,
                  icon: Icons.image_outlined,
                  label: 'Promo Banners',
                ),
                _buildNavItem(
                  tab: AdminNavTab.notifications,
                  icon: Icons.notifications_none_rounded,
                  label: 'Push Notifications',
                  badgeText: '3',
                  badgeColor: const Color(0xFFEF4444),
                ),

                const SizedBox(height: 10),
                _buildSectionHeader('SYSTEM & SUPPORT'),
                _buildNavItem(
                  tab: AdminNavTab.support,
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Support Chat',
                ),
                _buildNavItem(
                  tab: AdminNavTab.feedback,
                  icon: Icons.star_outline_rounded,
                  label: 'User Feedback',
                ),
                _buildNavItem(
                  tab: AdminNavTab.settings,
                  icon: Icons.settings_outlined,
                  label: 'Platform Settings',
                ),
              ],
            ),
          ),

          // Bottom Sign Out
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          if (onLogout != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: InkWell(
                onTap: onLogout,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCollapsed ? 0 : 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: isCollapsed
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      if (!isCollapsed) ...[
                        const SizedBox(width: 10),
                        const Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    if (isCollapsed) {
      return const SizedBox(height: 4);
    }
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required AdminNavTab tab,
    required IconData icon,
    required String label,
    String? badgeText,
    Color? badgeColor,
  }) {
    final isSelected = currentTab == tab;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => onTabSelected(tab),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : 12,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: const Color(0xFFC7D2FE), width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF64748B),
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFF334155),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badgeText != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? const Color(0xFF4F46E5)).withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: badgeColor ?? const Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
