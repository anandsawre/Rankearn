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
  // Backward compatibility aliases
  earn,
  spin,
  wallet,
}

/// Rankearn Mobile Bottom Navigation Bar (6 Tabs)
/// Direct parity with the Rankearn Home Dashboard reference design.
class AppBottomNav extends StatelessWidget {
  final UserNavTab currentTab;
  final ValueChanged<UserNavTab> onTabSelected;

  const AppBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  bool _isSelected(UserNavTab tab) {
    if (currentTab == tab) return true;
    if (tab == UserNavTab.live && currentTab == UserNavTab.earn) return true;
    if (tab == UserNavTab.rewards && (currentTab == UserNavTab.spin || currentTab == UserNavTab.wallet)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (UserNavTab.home, Icons.home_rounded, 'Home'),
      (UserNavTab.tests, Icons.feed_outlined, 'Tests'),
      (UserNavTab.live, Icons.sensors_rounded, 'Live'),
      (UserNavTab.battle, Icons.sports_kabaddi_rounded, 'Battle'),
      (UserNavTab.rewards, Icons.card_giftcard_rounded, 'Rewards'),
      (UserNavTab.profile, Icons.person_outline_rounded, 'Profile'),
    ];

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
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
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
