import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Scope of the leaderboard rankings
enum LeaderboardScope { global, friends, myState }

/// Time frame for ranking calculations
enum LeaderboardPeriod { allTime, weekly, monthly }

/// User achievement / tier badge
enum LeaderboardBadgeTier { legend, master, expert, pro, advanced }

/// Typed Domain Model representing a ranked user on the Rankearn Leaderboard
class LeaderboardUserEntry {
  final int rank;
  final String userId;
  final String name;
  final String state;
  final String? avatarUrl;
  final int level;
  final int testsCompleted;
  final int winRate; // percentage 0 - 100
  final int coinsEarned;
  final LeaderboardBadgeTier badgeTier;
  final bool isVerified;
  final bool isCurrentUser;
  final Color avatarBgColor;

  const LeaderboardUserEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.state,
    this.avatarUrl,
    required this.level,
    required this.testsCompleted,
    required this.winRate,
    required this.coinsEarned,
    required this.badgeTier,
    this.isVerified = false,
    this.isCurrentUser = false,
    this.avatarBgColor = AppColors.avatarPastelBlue,
  });

  /// Canonical badge display details
  String get badgeLabel => switch (badgeTier) {
    LeaderboardBadgeTier.legend => 'Legend',
    LeaderboardBadgeTier.master => 'Master',
    LeaderboardBadgeTier.expert => 'Expert',
    LeaderboardBadgeTier.pro => 'Pro',
    LeaderboardBadgeTier.advanced => 'Advanced',
  };

  IconData get badgeIcon => switch (badgeTier) {
    LeaderboardBadgeTier.legend => Icons.workspace_premium_rounded,
    LeaderboardBadgeTier.master => Icons.military_tech_rounded,
    LeaderboardBadgeTier.expert => Icons.star_rounded,
    LeaderboardBadgeTier.pro => Icons.shield_rounded,
    LeaderboardBadgeTier.advanced => Icons.diamond_rounded,
  };

  Color get badgeColor => switch (badgeTier) {
    LeaderboardBadgeTier.legend => AppColors.leaderboardBronze,
    LeaderboardBadgeTier.master => AppColors.brandPurple,
    LeaderboardBadgeTier.expert => AppColors.brandOrange,
    LeaderboardBadgeTier.pro => AppColors.brandBlue,
    LeaderboardBadgeTier.advanced => AppColors.infoBlue,
  };

  Color get badgeBgColor => switch (badgeTier) {
    LeaderboardBadgeTier.legend => AppColors.coinGoldLight,
    LeaderboardBadgeTier.master => AppColors.brandPurpleLight,
    LeaderboardBadgeTier.expert => AppColors.brandOrangeLight,
    LeaderboardBadgeTier.pro => AppColors.brandBlueLight,
    LeaderboardBadgeTier.advanced => AppColors.infoBlueLight,
  };

  /// Reference dataset matching the Rankearn Leaderboard screenshots precisely
  static const List<LeaderboardUserEntry> defaultEntries = [
    // 1. Top Gold Podium
    LeaderboardUserEntry(
      rank: 1,
      userId: 'usr_rohit_01',
      name: 'Rohit Kumar',
      state: 'Bihar',
      level: 28,
      testsCompleted: 1250,
      winRate: 92,
      coinsEarned: 25600,
      badgeTier: LeaderboardBadgeTier.legend,
      isVerified: true,
      avatarBgColor: AppColors.avatarPastelRed,
    ),
    // 2. Silver Podium
    LeaderboardUserEntry(
      rank: 2,
      userId: 'usr_anjali_02',
      name: 'Anjali Verma',
      state: 'Uttar Pradesh',
      level: 26,
      testsCompleted: 1180,
      winRate: 88,
      coinsEarned: 22400,
      badgeTier: LeaderboardBadgeTier.master,
      isVerified: true,
      avatarBgColor: AppColors.avatarPastelPurple,
    ),
    // 3. Bronze Podium
    LeaderboardUserEntry(
      rank: 3,
      userId: 'usr_saurabh_03',
      name: 'Saurabh Yadav',
      state: 'Maharashtra',
      level: 24,
      testsCompleted: 980,
      winRate: 85,
      coinsEarned: 20100,
      badgeTier: LeaderboardBadgeTier.expert,
      isVerified: true,
      avatarBgColor: AppColors.avatarPastelGreen,
    ),
    // 4. Rank 4
    LeaderboardUserEntry(
      rank: 4,
      userId: 'usr_priya_04',
      name: 'Priya Singh',
      state: 'Delhi',
      level: 22,
      testsCompleted: 860,
      winRate: 82,
      coinsEarned: 18300,
      badgeTier: LeaderboardBadgeTier.expert,
      avatarBgColor: AppColors.avatarPastelPink,
    ),
    // 5. Rank 5
    LeaderboardUserEntry(
      rank: 5,
      userId: 'usr_amit_05',
      name: 'Amit Verma',
      state: 'Rajasthan',
      level: 21,
      testsCompleted: 790,
      winRate: 80,
      coinsEarned: 16800,
      badgeTier: LeaderboardBadgeTier.pro,
      avatarBgColor: AppColors.avatarPastelIndigo,
    ),
    // 6. Rank 6
    LeaderboardUserEntry(
      rank: 6,
      userId: 'usr_neha_06',
      name: 'Neha Sharma',
      state: 'Madhya Pradesh',
      level: 20,
      testsCompleted: 760,
      winRate: 78,
      coinsEarned: 15400,
      badgeTier: LeaderboardBadgeTier.pro,
      avatarBgColor: AppColors.avatarPastelYellow,
    ),
    // 7. Rank 7 - Current Authenticated User (Vikram Singh)
    LeaderboardUserEntry(
      rank: 7,
      userId: 'usr_vikram_70',
      name: 'Vikram Singh',
      state: 'Bihar',
      level: 19,
      testsCompleted: 720,
      winRate: 76,
      coinsEarned: 14200,
      badgeTier: LeaderboardBadgeTier.pro,
      isCurrentUser: true,
      avatarBgColor: AppColors.avatarPastelGreen,
    ),
    // 8. Rank 8
    LeaderboardUserEntry(
      rank: 8,
      userId: 'usr_rahul_08',
      name: 'Rahul Patel',
      state: 'Gujarat',
      level: 18,
      testsCompleted: 690,
      winRate: 74,
      coinsEarned: 13800,
      badgeTier: LeaderboardBadgeTier.pro,
      avatarBgColor: AppColors.avatarPastelOrange,
    ),
    // 9. Rank 9
    LeaderboardUserEntry(
      rank: 9,
      userId: 'usr_sneha_09',
      name: 'Sneha Gupta',
      state: 'Uttar Pradesh',
      level: 17,
      testsCompleted: 640,
      winRate: 72,
      coinsEarned: 12600,
      badgeTier: LeaderboardBadgeTier.advanced,
      avatarBgColor: AppColors.avatarPastelPink,
    ),
    // 10. Rank 10
    LeaderboardUserEntry(
      rank: 10,
      userId: 'usr_karan_10',
      name: 'Karan Mehta',
      state: 'Karnataka',
      level: 17,
      testsCompleted: 610,
      winRate: 70,
      coinsEarned: 11900,
      badgeTier: LeaderboardBadgeTier.advanced,
      avatarBgColor: AppColors.avatarPastelSky,
    ),
  ];
}
