import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';

enum UserNavTab { home, tests, earn, spin, wallet, profile }

/// Rankearn Mobile Bottom Navigation Bar (6 Tabs)
/// Direct parity with `apps/user/src/App.tsx:1385-1410`.
class AppBottomNav extends StatelessWidget {
  final UserNavTab currentTab;
  final ValueChanged<UserNavTab> onTabSelected;

  const AppBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (UserNavTab.home, Icons.home_rounded, 'Home'),
      (UserNavTab.tests, Icons.menu_book_rounded, 'Tests'),
      (UserNavTab.earn, Icons.currency_rupee_rounded, 'Earn'),
      (UserNavTab.spin, Icons.rotate_right_rounded, 'Spin'),
      (UserNavTab.wallet, Icons.account_balance_wallet_rounded, 'Wallet'),
      (UserNavTab.profile, Icons.person_rounded, 'Profile'),
    ];

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.background.withAlpha(240),
        border: const Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F00B16A),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            final isSelected = currentTab == item.$1;
            final color = isSelected ? AppColors.brandPrimary : AppColors.textSecondary;

            return Expanded(
              child: InkWell(
                onTap: () => onTabSelected(item.$1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.$2, color: color, size: 22),
                    const SizedBox(height: 3),
                    Text(
                      item.$3,
                      style: AppTypography.bodySmall.copyWith(
                        color: color,
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
