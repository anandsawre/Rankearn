import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

enum UserNavTab {
  home,
  tests,
  live,
  battle,
  rewards,
  profile,
  // Backward compatibility aliases & new routes
  earn,
  spin,
  wallet,
  leaderboard,
  categories,
}

/// Rankearn Mobile Bottom Navigation Bar (6 Tabs)
/// Supports standard dashboard navigation and leaderboard context navigation
class AppBottomNav extends StatelessWidget {
  final UserNavTab currentTab;
  final ValueChanged<UserNavTab> onTabSelected;
  final List<(UserNavTab, IconData, String)>? customItems;

  const AppBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.customItems,
  });

  bool _isSelected(UserNavTab tab) {
    if (currentTab == tab) {
      return true;
    }
    if (tab == UserNavTab.live && currentTab == UserNavTab.earn) {
      return true;
    }
    if (tab == UserNavTab.rewards && currentTab == UserNavTab.spin) {
      return true;
    }
    if (tab == UserNavTab.tests && currentTab == UserNavTab.categories) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final defaultDashboardItems = [
      (UserNavTab.home, Icons.home_rounded, 'Home'),
      (UserNavTab.tests, Icons.feed_outlined, 'Tests'),
      (UserNavTab.live, Icons.sensors_rounded, 'Live'),
      (UserNavTab.battle, Icons.sports_kabaddi_rounded, 'Battle'),
      (UserNavTab.rewards, Icons.card_giftcard_rounded, 'Rewards'),
      (UserNavTab.profile, Icons.person_outline_rounded, 'Profile'),
    ];

    final leaderboardItems = [
      (UserNavTab.home, Icons.home_rounded, 'Home'),
      (UserNavTab.categories, Icons.grid_view_rounded, 'Categories'),
      (UserNavTab.tests, Icons.feed_outlined, 'Tests'),
      (UserNavTab.live, Icons.sensors_rounded, 'Live'),
      (UserNavTab.leaderboard, Icons.emoji_events_rounded, 'Leaderboard'),
      (UserNavTab.rewards, Icons.card_giftcard_rounded, 'Rewards'),
    ];

    final walletItems = [
      (UserNavTab.home, Icons.home_rounded, 'Home'),
      (UserNavTab.categories, Icons.grid_view_rounded, 'Categories'),
      (UserNavTab.tests, Icons.feed_outlined, 'Tests'),
      (UserNavTab.live, Icons.sensors_rounded, 'Live'),
      (UserNavTab.leaderboard, Icons.emoji_events_rounded, 'Leaderboard'),
      (UserNavTab.wallet, Icons.account_balance_wallet_rounded, 'Wallet'),
    ];

    final items =
        customItems ??
        (currentTab == UserNavTab.wallet
            ? walletItems
            : (currentTab == UserNavTab.leaderboard
                  ? leaderboardItems
                  : defaultDashboardItems));

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < 30 || constraints.maxWidth < 60) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 68,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.borderSubtle, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.map((item) {
                final isSelected = _isSelected(item.$1);
                final activeColor = AppColors.brandGreen;
                final inactiveColor = AppColors.textSecondary;

                return Expanded(
                  child: InkWell(
                    onTap: () => onTabSelected(item.$1),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6F8EF),
                                  borderRadius: AppRadii.borderPill,
                                ),
                                child: Icon(item.$2, color: activeColor, size: 22),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Icon(item.$2, color: inactiveColor, size: 22),
                              ),
                            const SizedBox(height: 2),
                            Text(
                              item.$3,
                              style: TextStyle(
                                color: isSelected ? activeColor : inactiveColor,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
