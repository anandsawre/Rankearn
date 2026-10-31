import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';

/// Enum representing the 4 functional categories of rewards on the wheel
enum SpinRewardType { coins, rankBooster, extraAttempt, surpriseGift }

/// Model representing a single segment on the wheel and a card in the Possible Rewards showcase.
class SpinRewardItem {
  final String id;
  final String title;
  final String subtitle;
  final int coins;
  final SpinRewardType type;
  final String badgeText;
  final String description;
  final Color cardTint;
  final Color accentColor;

  const SpinRewardItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coins,
    required this.type,
    required this.badgeText,
    required this.description,
    required this.cardTint,
    required this.accentColor,
  });

  /// Factory creating SpinRewardItem from a dynamic database WheelRewardSegment
  factory SpinRewardItem.fromSegment(WheelRewardSegment segment, int index) {
    SpinRewardType type;
    int coins = 0;
    String badgeText = '';
    String description = '';
    Color cardTint = const Color(0xFFFEF3C7);
    Color accentColor = segment.color;

    final lower = segment.label.toLowerCase();
    if (lower.contains('coin')) {
      type = SpinRewardType.coins;
      coins = segment.rewardValue > 0 ? segment.rewardValue : 50;
      badgeText = '+$coins';
      description = '$coins Bonus Coins added to your Rankearn wallet!';
      cardTint = const Color(0xFFFEF3C7);
      accentColor = const Color(0xFFF59E0B);
    } else if (lower.contains('booster') || lower.contains('rank')) {
      type = SpinRewardType.rankBooster;
      badgeText = '2X PTS';
      description = 'Rank Booster active! 2X leaderboard score on next tests.';
      cardTint = const Color(0xFFFFFBEB);
      accentColor = const Color(0xFFD97706);
    } else if (lower.contains('extra') ||
        lower.contains('attempt') ||
        lower.contains('re-spin')) {
      type = SpinRewardType.extraAttempt;
      badgeText = '1 PASS';
      description = 'Free Test Re-attempt pass added to your inventory.';
      cardTint = const Color(0xFFE0F2FE);
      accentColor = const Color(0xFF0284C7);
    } else {
      type = SpinRewardType.surpriseGift;
      coins = segment.rewardValue;
      badgeText = 'MYSTERY';
      description = '${segment.label} unlocked in your rewards vault!';
      cardTint = const Color(0xFFFFE4E6);
      accentColor = const Color(0xFFF43F5E);
    }

    final parts = segment.label.trim().split(' ');
    final title = parts.isNotEmpty ? parts.first : segment.label;
    final subtitle = parts.length > 1 ? parts.sublist(1).join(' ') : 'Reward';

    return SpinRewardItem(
      id: segment.id.isNotEmpty ? segment.id : 'slice_$index',
      title: title,
      subtitle: subtitle,
      coins: coins,
      type: type,
      badgeText: badgeText,
      description: description,
      cardTint: cardTint,
      accentColor: accentColor,
    );
  }

  /// The 8 canonical rewards from the Rankearn Spin & Win reference image.
  /// Ordered clockwise starting from Top (12 o'clock):
  /// 0: 100 Coins (Cream)
  /// 1: 50 Coins (Green)
  /// 2: Rank Booster (Cream)
  /// 3: Surprise Gift (Green)
  /// 4: 10 Coins (Cream)
  static const List<SpinRewardItem> defaultRewards = [];
  static const List<SpinRewardItem> showcaseList = [];
}

/// State model tracking user's daily spin allowance and cooldown
class SpinStateModel {
  final int spinsUsedToday;
  final int maxSpinsPerDay;
  final DateTime nextResetTime;
  final bool isEligible;

  const SpinStateModel({
    required this.spinsUsedToday,
    this.maxSpinsPerDay = 5,
    required this.nextResetTime,
    this.isEligible = true,
  });

  int get spinsRemaining =>
      (maxSpinsPerDay - spinsUsedToday).clamp(0, maxSpinsPerDay);
  bool get hasSpinsLeft => spinsRemaining > 0;

  Duration get remainingCooldown {
    final now = DateTime.now();
    if (now.isAfter(nextResetTime)) return Duration.zero;
    return nextResetTime.difference(now);
  }

  String get formattedCooldown {
    final diff = remainingCooldown;
    if (diff == Duration.zero) return 'Ready Now!';
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  SpinStateModel copyWith({
    int? spinsUsedToday,
    int? maxSpinsPerDay,
    DateTime? nextResetTime,
    bool? isEligible,
  }) {
    return SpinStateModel(
      spinsUsedToday: spinsUsedToday ?? this.spinsUsedToday,
      maxSpinsPerDay: maxSpinsPerDay ?? this.maxSpinsPerDay,
      nextResetTime: nextResetTime ?? this.nextResetTime,
      isEligible: isEligible ?? this.isEligible,
    );
  }
}
