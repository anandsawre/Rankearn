import 'package:flutter/material.dart';

/// Filter categories for backend reward tasks
enum TaskCategory {
  all,
  daily,
  weekly,
  special,
  achievements,
}

/// Action type for daily / weekly reward tasks
enum RewardTaskActionType {
  goNow,
  progressPill,
  claim,
  completed,
}

/// Task model representing a single daily or special task
class RewardTaskModel {
  final String id;
  final String title;
  final String description;
  final int coinsReward;
  final TaskCategory category;
  final RewardTaskActionType actionType;
  final int currentProgress;
  final int targetProgress;
  final String progressText;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isCompleted;
  final bool isClaimed;

  const RewardTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coinsReward,
    required this.category,
    required this.actionType,
    required this.currentProgress,
    required this.targetProgress,
    required this.progressText,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  RewardTaskModel copyWith({
    bool? isCompleted,
    bool? isClaimed,
    int? currentProgress,
  }) {
    return RewardTaskModel(
      id: id,
      title: title,
      description: description,
      coinsReward: coinsReward,
      category: category,
      actionType: actionType,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress,
      progressText: progressText,
      icon: icon,
      iconBgColor: iconBgColor,
      iconColor: iconColor,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

/// Weekly goal task model
class WeeklyRewardTaskModel {
  final String id;
  final String title;
  final int current;
  final int target;
  final String unit;
  final int coinsReward;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isPercent;

  const WeeklyRewardTaskModel({
    required this.id,
    required this.title,
    required this.current,
    required this.target,
    this.unit = '',
    required this.coinsReward,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.isPercent = false,
  });

  double get progressRatio => target == 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
  String get progressString => isPercent ? '$current/$target%' : '$current/$target';
}

/// Overall Rewards Summary Statistics
class RewardSummaryStatsModel {
  final int myCoins;
  final int dailyStreakDays;
  final int myRank;
  final int totalEarned;

  const RewardSummaryStatsModel({
    this.myCoins = 1250,
    this.dailyStreakDays = 7,
    this.myRank = 1256,
    this.totalEarned = 12500,
  });
}
