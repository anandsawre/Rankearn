import 'package:flutter/material.dart';
import 'app_metric_card.dart';
import 'test_metric_card.dart';

/// 4 Statistics Cards row for the Rewards Tab
/// (My Coins, Daily Streak, My Rank, Total Earned).
/// Powered by the unified [AppMetricsRow] engine.
class RewardMetricsRow extends StatelessWidget {
  final String myCoins;
  final String dailyStreak;
  final String myRank;
  final String totalEarned;
  final VoidCallback? onMyCoinsTap;
  final VoidCallback? onDailyStreakTap;
  final VoidCallback? onMyRankTap;
  final VoidCallback? onTotalEarnedTap;

  const RewardMetricsRow({
    super.key,
    this.myCoins = '1,250',
    this.dailyStreak = '7 Days',
    this.myRank = '#1256',
    this.totalEarned = '12,500',
    this.onMyCoinsTap,
    this.onDailyStreakTap,
    this.onMyRankTap,
    this.onTotalEarnedTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppMetricsRow(
      breakpoint: 640,
      spacing: 8,
      cards: [
        TestMetricCard(
          icon: Icons.monetization_on_rounded,
          label: 'My Coins',
          value: myCoins,
          accentColor: const Color(0xFFF59E0B),
          backgroundColor: const Color(0xFFFFFBEB),
          onTap: onMyCoinsTap,
        ),
        TestMetricCard(
          icon: Icons.local_fire_department_rounded,
          label: 'Daily Streak',
          value: dailyStreak,
          accentColor: const Color(0xFFF97316),
          backgroundColor: const Color(0xFFFFF7ED),
          onTap: onDailyStreakTap,
        ),
        TestMetricCard(
          icon: Icons.workspace_premium_rounded,
          label: 'My Rank',
          value: myRank,
          accentColor: const Color(0xFFEAB308),
          backgroundColor: const Color(0xFFFEFCE8),
          onTap: onMyRankTap,
        ),
        TestMetricCard(
          icon: Icons.card_giftcard_rounded,
          label: 'Total Earned',
          value: totalEarned,
          accentColor: const Color(0xFFF43F5E),
          backgroundColor: const Color(0xFFFFF1F2),
          onTap: onTotalEarnedTap,
        ),
      ],
    );
  }
}
