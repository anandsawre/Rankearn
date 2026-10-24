import 'package:design_system/design_system.dart';
import '../models/leaderboard_model.dart';
import 'package:data_layer/data_layer.dart';

/// Authoritative Leaderboard Service
/// Provides filtered rankings, scope queries, and current user ranking stats.
class LeaderboardService {
  LeaderboardService._();

  /// Retrieve leaderboard entries based on scope and period
  static Future<List<LeaderboardUserEntry>> getLeaderboard({
    LeaderboardScope scope = LeaderboardScope.global,
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
    String? subject,
    String currentUserId = 'usr_vikram_70',
  }) async {
    // Simulate real backend latency
    await Future.delayed(const Duration(milliseconds: 50));

    final base = List<LeaderboardUserEntry>.from(
      LeaderboardUserEntry.defaultEntries,
    );

    switch (scope) {
      case LeaderboardScope.global:
        return _applyPeriodFilter(base, period);

      case LeaderboardScope.friends:
        // Friends filter returns subset of trusted connections
        final friendsIds = {
          'usr_rohit_01',
          'usr_anjali_02',
          'usr_vikram_70',
          'usr_amit_05',
        };
        final friends = base
            .where((e) => friendsIds.contains(e.userId))
            .toList();
        return _recalculateRanks(_applyPeriodFilter(friends, period));

      case LeaderboardScope.myState:
        // State filter returns users in current user's state (Bihar)
        final stateUsers = base.where((e) => e.state == 'Bihar').toList();
        return _recalculateRanks(_applyPeriodFilter(stateUsers, period));
    }
  }

  static List<LeaderboardUserEntry> _applyPeriodFilter(
    List<LeaderboardUserEntry> list,
    LeaderboardPeriod period,
  ) {
    switch (period) {
      case LeaderboardPeriod.allTime:
        return list;

      case LeaderboardPeriod.weekly:
        // Scale coins and tests for current active week
        return list.map((e) {
          final factor = 0.22;
          return LeaderboardUserEntry(
            rank: e.rank,
            userId: e.userId,
            name: e.name,
            state: e.state,
            level: e.level,
            testsCompleted: (e.testsCompleted * factor).round(),
            winRate: e.winRate,
            coinsEarned: (e.coinsEarned * factor).round(),
            badgeTier: e.badgeTier,
            isVerified: e.isVerified,
            isCurrentUser: e.isCurrentUser,
            avatarBgColor: e.avatarBgColor,
          );
        }).toList();

      case LeaderboardPeriod.monthly:
        // Scale coins and tests for current month
        return list.map((e) {
          final factor = 0.58;
          return LeaderboardUserEntry(
            rank: e.rank,
            userId: e.userId,
            name: e.name,
            state: e.state,
            level: e.level,
            testsCompleted: (e.testsCompleted * factor).round(),
            winRate: e.winRate,
            coinsEarned: (e.coinsEarned * factor).round(),
            badgeTier: e.badgeTier,
            isVerified: e.isVerified,
            isCurrentUser: e.isCurrentUser,
            avatarBgColor: e.avatarBgColor,
          );
        }).toList();
    }
  }

  static List<LeaderboardUserEntry> _recalculateRanks(
    List<LeaderboardUserEntry> list,
  ) {
    final sorted = List<LeaderboardUserEntry>.from(list)
      ..sort((a, b) => b.coinsEarned.compareTo(a.coinsEarned));

    return List.generate(sorted.length, (i) {
      final item = sorted[i];
      return LeaderboardUserEntry(
        rank: i + 1,
        userId: item.userId,
        name: item.name,
        state: item.state,
        level: item.level,
        testsCompleted: item.testsCompleted,
        winRate: item.winRate,
        coinsEarned: item.coinsEarned,
        badgeTier: item.badgeTier,
        isVerified: item.isVerified,
        isCurrentUser: item.isCurrentUser,
        avatarBgColor: item.avatarBgColor,
      );
    });
  }

  /// Get top 3 weekly performers for desktop sidebar
  static List<LeaderboardUserEntry> getTop3Weekly() {
    return LeaderboardUserEntry.defaultEntries.take(3).toList();
  }

  /// Resolve current user entry from active profile
  static LeaderboardUserEntry getCurrentUserEntry(UserProfile profile) {
    return LeaderboardUserEntry(
      rank: 7,
      userId: profile.id,
      name: profile.name,
      state: profile.state?.split(',').first.trim() ?? 'Bihar',
      level: 19,
      testsCompleted: 720,
      winRate: 76,
      coinsEarned: 14200,
      badgeTier: LeaderboardBadgeTier.pro,
      isCurrentUser: true,
      avatarBgColor: AppColors.leaderboardMintBg,
    );
  }
}
