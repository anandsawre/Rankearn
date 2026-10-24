import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// The 4 Profile Statistics Cards:
/// 1. My Coins (Gold tint)
/// 2. Tests Attempted (Mint green tint)
/// 3. Average Score (Pink/Rose tint)
/// 4. Badges Earned (Purple tint)
///
/// Built strictly with the centralized [AppMetricsRow] and [TestMetricCard] design system components,
/// ensuring 100% visual parity and typography matching Dashboard and Tests tabs.
class ProfileStatsGrid extends StatelessWidget {
  final int coins;
  final int testsAttempted;
  final int averageScore;
  final int badgesEarned;
  final VoidCallback? onCoinsTap;
  final VoidCallback? onTestsTap;
  final VoidCallback? onScoreTap;
  final VoidCallback? onBadgesTap;
  final bool isDesktop;

  const ProfileStatsGrid({
    super.key,
    required this.coins,
    this.testsAttempted = 28,
    this.averageScore = 78,
    this.badgesEarned = 12,
    this.onCoinsTap,
    this.onTestsTap,
    this.onScoreTap,
    this.onBadgesTap,
    this.isDesktop = false,
  });

  String _formatCoins(int amount) {
    if (amount >= 1000) {
      final s = amount.toString();
      final lastThree = s.substring(s.length - 3);
      final otherNumbers = s.substring(0, s.length - 3);
      return otherNumbers.isNotEmpty ? '$otherNumbers,$lastThree' : lastThree;
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AppMetricsRow(
      breakpoint: isDesktop ? 540 : 640,
      spacing: 12,
      cards: [
        TestMetricCard(
          icon: Icons.monetization_on_rounded,
          label: 'My Coins',
          value: _formatCoins(coins > 0 ? coins : 1250),
          accentColor: AppColors.coinGold,
          backgroundColor: AppColors.coinGoldLight,
          onTap: onCoinsTap,
          showChevron: true,
        ),
        TestMetricCard(
          icon: Icons.bar_chart_rounded,
          label: 'Tests Attempted',
          value: '$testsAttempted',
          accentColor: AppColors.brandGreen,
          backgroundColor: AppColors.brandGreenLight,
          onTap: onTestsTap,
          showChevron: false,
        ),
        TestMetricCard(
          icon: Icons.track_changes_rounded,
          label: 'Average Score',
          value: '$averageScore%',
          accentColor: AppColors.errorRose,
          backgroundColor: AppColors.errorRoseLight,
          onTap: onScoreTap,
          showChevron: true,
        ),
        TestMetricCard(
          icon: Icons.emoji_events_rounded,
          label: 'Badges Earned',
          value: '$badgesEarned',
          accentColor: AppColors.brandPurple,
          backgroundColor: AppColors.brandPurpleLight,
          onTap: onBadgesTap,
          showChevron: true,
        ),
      ],
    );
  }
}
