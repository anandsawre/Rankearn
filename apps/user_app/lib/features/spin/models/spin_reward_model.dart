import 'package:flutter/material.dart';

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

  /// The 8 canonical rewards from the Rankearn Spin & Win reference image.
  /// Ordered clockwise starting from Top (12 o'clock):
  /// 0: 100 Coins (Cream)
  /// 1: 50 Coins (Green)
  /// 2: Rank Booster (Cream)
  /// 3: Surprise Gift (Green)
  /// 4: 10 Coins (Cream)
  /// 5: 500 Coins (Green)
  /// 6: 200 Coins (Cream)
  /// 7: Extra Attempt (Green)
  static const List<SpinRewardItem> defaultRewards = [
    // 0. Top (12 o'clock)
    SpinRewardItem(
      id: 'reward_100_coins',
      title: '100',
      subtitle: 'Coins',
      coins: 100,
      type: SpinRewardType.coins,
      badgeText: '+100',
      description: '100 Bonus Coins added to your Rankearn wallet!',
      cardTint: Color(0xFFFEF3C7),
      accentColor: Color(0xFFF59E0B),
    ),
    // 1. Top-Right (1:30)
    SpinRewardItem(
      id: 'reward_50_coins',
      title: '50',
      subtitle: 'Coins',
      coins: 50,
      type: SpinRewardType.coins,
      badgeText: '+50',
      description: '50 Bonus Coins credited to practice tests!',
      cardTint: Color(0xFFFEF9C3),
      accentColor: Color(0xFFEAB308),
    ),
    // 2. Right (3 o'clock)
    SpinRewardItem(
      id: 'reward_rank_booster',
      title: 'Rank',
      subtitle: 'Booster',
      coins: 0,
      type: SpinRewardType.rankBooster,
      badgeText: '2X PTS',
      description:
          'Rank Booster active! 2X leaderboard score on your next 3 tests.',
      cardTint: Color(0xFFFFFBEB),
      accentColor: Color(0xFFD97706),
    ),
    // 3. Bottom-Right (4:30)
    SpinRewardItem(
      id: 'reward_surprise_gift',
      title: 'Surprise',
      subtitle: 'Gift',
      coins: 150,
      type: SpinRewardType.surpriseGift,
      badgeText: 'MYSTERY',
      description:
          'Surprise Mystery Box! Unlocked 150 Coins + VIP Test Pass discount.',
      cardTint: Color(0xFFFFE4E6),
      accentColor: Color(0xFFF43F5E),
    ),
    // 4. Bottom (6 o'clock)
    SpinRewardItem(
      id: 'reward_10_coins',
      title: '10',
      subtitle: 'Coins',
      coins: 10,
      type: SpinRewardType.coins,
      badgeText: '+10',
      description: '10 Bonus Coins to keep your streak glowing!',
      cardTint: Color(0xFFFEF3C7),
      accentColor: Color(0xFFF59E0B),
    ),
    // 5. Bottom-Left (7:30)
    SpinRewardItem(
      id: 'reward_500_coins',
      title: '500',
      subtitle: 'Coins',
      coins: 500,
      type: SpinRewardType.coins,
      badgeText: 'JACKPOT',
      description: 'Mega Jackpot! 500 Coins added straight to your balance.',
      cardTint: Color(0xFFFEF3C7),
      accentColor: Color(0xFFF59E0B),
    ),
    // 6. Left (9 o'clock)
    SpinRewardItem(
      id: 'reward_200_coins',
      title: '200',
      subtitle: 'Coins',
      coins: 200,
      type: SpinRewardType.coins,
      badgeText: '+200',
      description: '200 Coins! Enter live battle tournaments for free.',
      cardTint: Color(0xFFFEF3C7),
      accentColor: Color(0xFFF59E0B),
    ),
    // 7. Top-Left (10:30)
    SpinRewardItem(
      id: 'reward_extra_attempt',
      title: 'Extra',
      subtitle: 'Attempt',
      coins: 0,
      type: SpinRewardType.extraAttempt,
      badgeText: '1 PASS',
      description: '1 Free Test Re-attempt pass added to your inventory.',
      cardTint: Color(0xFFE0F2FE),
      accentColor: Color(0xFF0284C7),
    ),
  ];

  /// List of 8 unique showcase cards matching the bottom section of reference
  /// (Sorted by progression: 10, 50, 100, 200, 500, Rank Booster, Extra Attempt, Surprise Gift)
  static const List<SpinRewardItem> showcaseList = [
    SpinRewardItem(
      id: 'showcase_10',
      title: '10',
      subtitle: 'Coins',
      coins: 10,
      type: SpinRewardType.coins,
      badgeText: '10',
      description: '10 Coins',
      cardTint: Color(0xFFFEF3C7),
      accentColor: Color(0xFFF59E0B),
    ),
    SpinRewardItem(
      id: 'showcase_50',
      title: '50',
      subtitle: 'Coins',
      coins: 50,
      type: SpinRewardType.coins,
      badgeText: '50',
      description: '50 Coins',
      cardTint: Color(0xFFFEF9C3),
      accentColor: Color(0xFFEAB308),
    ),
    SpinRewardItem(
      id: 'showcase_100',
      title: '100',
      subtitle: 'Coins',
      coins: 100,
      type: SpinRewardType.coins,
      badgeText: '100',
      description: '100 Coins',
      cardTint: Color(0xFFFEF3C7),
      accentColor: Color(0xFFF59E0B),
    ),
    SpinRewardItem(
      id: 'showcase_200',
      title: '200',
      subtitle: 'Coins',
      coins: 200,
      type: SpinRewardType.coins,
      badgeText: '200',
      description: '200 Coins',
      cardTint: Color(0xFFFEF3C7),
      accentColor: Color(0xFFF59E0B),
    ),
    SpinRewardItem(
      id: 'showcase_500',
      title: '500',
      subtitle: 'Coins',
      coins: 500,
      type: SpinRewardType.coins,
      badgeText: '500',
      description: '500 Coins',
      cardTint: Color(0xFFFEF3C7),
      accentColor: Color(0xFFF59E0B),
    ),
    SpinRewardItem(
      id: 'showcase_rank_booster',
      title: 'Rank',
      subtitle: 'Booster',
      coins: 0,
      type: SpinRewardType.rankBooster,
      badgeText: '2X',
      description: 'Rank Booster',
      cardTint: Color(0xFFFFFBEB),
      accentColor: Color(0xFFD97706),
    ),
    SpinRewardItem(
      id: 'showcase_extra_attempt',
      title: 'Extra',
      subtitle: 'Attempt',
      coins: 0,
      type: SpinRewardType.extraAttempt,
      badgeText: '1 PASS',
      description: 'Extra Attempt',
      cardTint: Color(0xFFE0F2FE),
      accentColor: Color(0xFF0284C7),
    ),
    SpinRewardItem(
      id: 'showcase_surprise_gift',
      title: 'Surprise',
      subtitle: 'Gift',
      coins: 150,
      type: SpinRewardType.surpriseGift,
      badgeText: 'GIFT',
      description: 'Surprise Gift',
      cardTint: Color(0xFFFFE4E6),
      accentColor: Color(0xFFF43F5E),
    ),
  ];
}

/// State model tracking user's daily spin allowance and cooldown
class SpinStateModel {
  final int spinsUsedToday;
  final int maxSpinsPerDay;
  final DateTime nextResetTime;
  final bool isEligible;

  const SpinStateModel({
    required this.spinsUsedToday,
    this.maxSpinsPerDay = 3,
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
