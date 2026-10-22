import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import '../models/reward_models.dart';

/// Repository for the Rewards Tab providing task data, summary metrics, and claims.
class RewardRepository {
  Future<Result<RewardSummaryStatsModel>> getRewardStats({
    required int userCoins,
    required int totalEarned,
  }) async {
    // In production, syncs with Supabase profile and streak records
    return Success(RewardSummaryStatsModel(
      myCoins: userCoins > 0 ? userCoins : 1250,
      dailyStreakDays: 7,
      myRank: 1256,
      totalEarned: totalEarned > 0 ? totalEarned : 12500,
    ));
  }

  Future<Result<List<RewardTaskModel>>> getDailyTasks() async {
    // Reference Tasks:
    // 1. Attempt 1 Test (+50, Go Now ->)
    // 2. Score 70% or above (+75, Go Now ->)
    // 3. Watch 1 Educational Video (+30, 0/1)
    // 4. Refer 1 Friend (+100, 0/1)
    final tasks = [
      const RewardTaskModel(
        id: 'daily_1',
        title: 'Attempt 1 Test',
        description: 'Complete any test (Mock, Chapter or Daily)',
        coinsReward: 50,
        category: TaskCategory.daily,
        actionType: RewardTaskActionType.goNow,
        currentProgress: 0,
        targetProgress: 1,
        progressText: '0/1',
        icon: Icons.description_rounded,
        iconBgColor: Color(0xFF10B981), // Emerald green
        iconColor: Colors.white,
      ),
      const RewardTaskModel(
        id: 'daily_2',
        title: 'Score 70% or above',
        description: 'Get 70% or more in any test',
        coinsReward: 75,
        category: TaskCategory.daily,
        actionType: RewardTaskActionType.goNow,
        currentProgress: 0,
        targetProgress: 1,
        progressText: '0/1',
        icon: Icons.track_changes_rounded,
        iconBgColor: Color(0xFF8B5CF6), // Purple
        iconColor: Colors.white,
      ),
      const RewardTaskModel(
        id: 'daily_3',
        title: 'Watch 1 Educational Video',
        description: 'Watch complete video from Learn section',
        coinsReward: 30,
        category: TaskCategory.daily,
        actionType: RewardTaskActionType.progressPill,
        currentProgress: 0,
        targetProgress: 1,
        progressText: '0/1',
        icon: Icons.play_arrow_rounded,
        iconBgColor: Color(0xFFEF4444), // Red
        iconColor: Colors.white,
      ),
      const RewardTaskModel(
        id: 'daily_4',
        title: 'Refer 1 Friend',
        description: 'Invite a friend to join Rankearn',
        coinsReward: 100,
        category: TaskCategory.daily,
        actionType: RewardTaskActionType.progressPill,
        currentProgress: 0,
        targetProgress: 1,
        progressText: '0/1',
        icon: Icons.share_rounded,
        iconBgColor: Color(0xFF2587F8), // Blue
        iconColor: Colors.white,
      ),
    ];
    return Success(tasks);
  }

  Future<Result<List<WeeklyRewardTaskModel>>> getWeeklyTasks() async {
    // Reference Weekly Tasks:
    // 1. Attempt 10 Tests (0/10, +300)
    // 2. Maintain 70% Avg Score (0/70%, +500)
    // 3. Refer 5 Friends (0/5, +500)
    final tasks = [
      const WeeklyRewardTaskModel(
        id: 'weekly_1',
        title: 'Attempt 10 Tests',
        current: 0,
        target: 10,
        coinsReward: 300,
        icon: Icons.bar_chart_rounded,
        iconBgColor: Color(0xFFECFDF5),
        iconColor: Color(0xFF10B981),
      ),
      const WeeklyRewardTaskModel(
        id: 'weekly_2',
        title: 'Maintain 70% Avg Score',
        current: 0,
        target: 70,
        isPercent: true,
        coinsReward: 500,
        icon: Icons.star_rounded,
        iconBgColor: Color(0xFFFFFBEB),
        iconColor: Color(0xFFF59E0B),
      ),
      const WeeklyRewardTaskModel(
        id: 'weekly_3',
        title: 'Refer 5 Friends',
        current: 0,
        target: 5,
        coinsReward: 500,
        icon: Icons.groups_rounded,
        iconBgColor: Color(0xFFEFF6FF),
        iconColor: Color(0xFF2587F8),
      ),
    ];
    return Success(tasks);
  }
}
