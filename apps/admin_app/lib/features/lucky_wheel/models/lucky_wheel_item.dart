import 'package:flutter/material.dart';

enum WheelRewardType {
  coins(
    label: 'Coins',
    color: Color(0xFFFF9F0A),
    backgroundColor: Color(0xFFFFF7ED),
    icon: Icons.monetization_on_rounded,
  ),
  cashback(
    label: 'Cashback',
    color: Color(0xFF10B981),
    backgroundColor: Color(0xFFECFDF5),
    icon: Icons.account_balance_wallet_rounded,
  ),
  discount(
    label: 'Discount',
    color: Color(0xFF6B4EFF),
    backgroundColor: Color(0xFFEEF0FF),
    icon: Icons.local_offer_rounded,
  ),
  gift(
    label: 'Gift',
    color: Color(0xFFF04483),
    backgroundColor: Color(0xFFFDF2F8),
    icon: Icons.card_giftcard_rounded,
  ),
  product(
    label: 'Product',
    color: Color(0xFF2587F8),
    backgroundColor: Color(0xFFEFF6FF),
    icon: Icons.inventory_2_rounded,
  ),
  noPrize(
    label: 'No Prize',
    color: Color(0xFF64748B),
    backgroundColor: Color(0xFFF1F5F9),
    icon: Icons.sentiment_dissatisfied_rounded,
  );

  final String label;
  final Color color;
  final Color backgroundColor;
  final IconData icon;

  const WheelRewardType({
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.icon,
  });

  static WheelRewardType fromString(String val) {
    for (final t in WheelRewardType.values) {
      if (t.label.toLowerCase() == val.toLowerCase() || t.name.toLowerCase() == val.toLowerCase()) {
        return t;
      }
    }
    return WheelRewardType.coins;
  }
}

enum WheelCampaignStatus {
  active(
    label: 'Active',
    color: Color(0xFF10B981),
    backgroundColor: Color(0xFFECFDF5),
  ),
  scheduled(
    label: 'Scheduled',
    color: Color(0xFF2587F8),
    backgroundColor: Color(0xFFEFF6FF),
  ),
  completed(
    label: 'Completed',
    color: Color(0xFF059669),
    backgroundColor: Color(0xFFECFDF5),
  ),
  paused(
    label: 'Paused',
    color: Color(0xFFFF9F0A),
    backgroundColor: Color(0xFFFFF7ED),
  ),
  draft(
    label: 'Draft',
    color: Color(0xFF64748B),
    backgroundColor: Color(0xFFF1F5F9),
  );

  final String label;
  final Color color;
  final Color backgroundColor;

  const WheelCampaignStatus({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  static WheelCampaignStatus fromString(String val) {
    for (final s in WheelCampaignStatus.values) {
      if (s.label.toLowerCase() == val.toLowerCase() || s.name.toLowerCase() == val.toLowerCase()) {
        return s;
      }
    }
    return WheelCampaignStatus.active;
  }
}

class WheelRewardSegment {
  final String label;
  final WheelRewardType rewardType;
  final int rewardValue;
  final int probability; // Weight or percentage
  final Color color;
  final bool isActive;

  const WheelRewardSegment({
    required this.label,
    required this.rewardType,
    required this.rewardValue,
    required this.probability,
    required this.color,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'reward_type': rewardType.name,
        'reward_value': rewardValue,
        'probability': probability,
        'color': color.toARGB32(),
        'is_active': isActive,
      };

  factory WheelRewardSegment.fromJson(Map<String, dynamic> json) {
    return WheelRewardSegment(
      label: json['label'] as String? ?? 'Reward',
      rewardType: WheelRewardType.fromString(json['reward_type'] as String? ?? 'coins'),
      rewardValue: (json['reward_value'] as num?)?.toInt() ?? 0,
      probability: (json['probability'] as num?)?.toInt() ?? 10,
      color: json['color'] != null ? Color((json['color'] as num).toInt()) : const Color(0xFF5636F5),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class LuckyWheelCampaignItem {
  final String id;
  final int rowNumber;
  final String title;
  final String subtitle;
  final WheelRewardType rewardType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalSpins;
  final int participants;
  final WheelCampaignStatus status;
  final String createdBy;
  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;
  final int spinCost;
  final int dailyLimit;
  final int campaignLimit;
  final List<WheelRewardSegment> slices;

  const LuckyWheelCampaignItem({
    required this.id,
    required this.rowNumber,
    required this.title,
    required this.subtitle,
    required this.rewardType,
    required this.startDate,
    required this.endDate,
    required this.totalSpins,
    required this.participants,
    required this.status,
    required this.createdBy,
    this.iconData = Icons.donut_large_rounded,
    this.iconColor = const Color(0xFF5636F5),
    this.iconBgColor = const Color(0xFFEEF0FF),
    this.spinCost = 10,
    this.dailyLimit = 3,
    this.campaignLimit = 10,
    this.slices = const [],
  });

  LuckyWheelCampaignItem copyWith({
    String? title,
    String? subtitle,
    WheelRewardType? rewardType,
    DateTime? startDate,
    DateTime? endDate,
    int? totalSpins,
    int? participants,
    WheelCampaignStatus? status,
    String? createdBy,
    int? spinCost,
    int? dailyLimit,
    int? campaignLimit,
    List<WheelRewardSegment>? slices,
  }) {
    return LuckyWheelCampaignItem(
      id: id,
      rowNumber: rowNumber,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      rewardType: rewardType ?? this.rewardType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalSpins: totalSpins ?? this.totalSpins,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      iconData: iconData,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      spinCost: spinCost ?? this.spinCost,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      campaignLimit: campaignLimit ?? this.campaignLimit,
      slices: slices ?? this.slices,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'reward_type': rewardType.name,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'total_spins': totalSpins,
        'participants': participants,
        'status': status.name,
        'created_by': createdBy,
        'spin_cost': spinCost,
        'daily_limit': dailyLimit,
        'campaign_limit': campaignLimit,
      };

  factory LuckyWheelCampaignItem.fromJson(Map<String, dynamic> json, int index) {
    return LuckyWheelCampaignItem(
      id: json['id'] as String? ?? 'wheel-$index',
      rowNumber: index + 1,
      title: json['title'] as String? ?? 'Lucky Wheel Campaign',
      subtitle: json['subtitle'] as String? ?? 'Spin and win rewards',
      rewardType: WheelRewardType.fromString(json['reward_type'] as String? ?? 'coins'),
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String) ?? DateTime(2026, 10, 1)
          : DateTime(2026, 10, 1),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String) ?? DateTime(2026, 10, 31)
          : DateTime(2026, 10, 31),
      totalSpins: (json['total_spins'] as num?)?.toInt() ?? 0,
      participants: (json['participants'] as num?)?.toInt() ?? 0,
      status: WheelCampaignStatus.fromString(json['status'] as String? ?? 'active'),
      createdBy: json['created_by'] as String? ?? 'Admin',
      spinCost: (json['spin_cost'] as num?)?.toInt() ?? 10,
      dailyLimit: (json['daily_limit'] as num?)?.toInt() ?? 3,
      campaignLimit: (json['campaign_limit'] as num?)?.toInt() ?? 10,
    );
  }
}

class WheelSpinRecord {
  final String id;
  final String campaignId;
  final String campaignTitle;
  final String userName;
  final String userAvatar;
  final String rewardLabel;
  final WheelRewardType rewardType;
  final int rewardValue;
  final DateTime timestamp;
  final String status;
  final String transactionId;

  const WheelSpinRecord({
    required this.id,
    required this.campaignId,
    required this.campaignTitle,
    required this.userName,
    required this.userAvatar,
    required this.rewardLabel,
    required this.rewardType,
    required this.rewardValue,
    required this.timestamp,
    required this.status,
    required this.transactionId,
  });
}

class WheelActivityItem {
  final String id;
  final String title;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const WheelActivityItem({
    required this.id,
    required this.title,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

/// The 7 primary reference items from the Lucky Wheel Management screenshot
final List<LuckyWheelCampaignItem> kDefaultLuckyWheelCampaigns = [
  LuckyWheelCampaignItem(
    id: 'wheel-camp-001',
    rowNumber: 1,
    title: 'Daily Spin Rewards',
    subtitle: 'Win coins, cashback and more',
    rewardType: WheelRewardType.coins,
    startDate: DateTime(2026, 10, 18, 10, 0),
    endDate: DateTime(2026, 10, 31, 23, 59),
    totalSpins: 12450,
    participants: 5240,
    status: WheelCampaignStatus.active,
    createdBy: 'Admin',
    iconData: Icons.donut_large_rounded,
    iconColor: const Color(0xFF5636F5),
    iconBgColor: const Color(0xFFEEF0FF),
  ),
  LuckyWheelCampaignItem(
    id: 'wheel-camp-002',
    rowNumber: 2,
    title: 'Festive Mega Spin',
    subtitle: 'Special rewards for festival',
    rewardType: WheelRewardType.cashback,
    startDate: DateTime(2026, 10, 15, 9, 0),
    endDate: DateTime(2026, 10, 30, 23, 59),
    totalSpins: 18230,
    participants: 6820,
    status: WheelCampaignStatus.active,
    createdBy: 'Admin',
    iconData: Icons.celebration_rounded,
    iconColor: const Color(0xFFFF9F0A),
    iconBgColor: const Color(0xFFFFF7ED),
  ),
  LuckyWheelCampaignItem(
    id: 'wheel-camp-003',
    rowNumber: 3,
    title: 'New User Bonus Spin',
    subtitle: 'Exclusive for new users',
    rewardType: WheelRewardType.gift,
    startDate: DateTime(2026, 10, 10, 0, 0),
    endDate: DateTime(2026, 12, 31, 23, 59),
    totalSpins: 8450,
    participants: 4120,
    status: WheelCampaignStatus.scheduled,
    createdBy: 'Admin',
    iconData: Icons.card_giftcard_rounded,
    iconColor: const Color(0xFFF04483),
    iconBgColor: const Color(0xFFFDF2F8),
  ),
  LuckyWheelCampaignItem(
    id: 'wheel-camp-004',
    rowNumber: 4,
    title: 'Weekend Lucky Draw',
    subtitle: 'Spin and win big rewards',
    rewardType: WheelRewardType.discount,
    startDate: DateTime(2026, 10, 8, 10, 0),
    endDate: DateTime(2026, 10, 12, 23, 59),
    totalSpins: 6780,
    participants: 2940,
    status: WheelCampaignStatus.completed,
    createdBy: 'Admin',
    iconData: Icons.stars_rounded,
    iconColor: const Color(0xFF6B4EFF),
    iconBgColor: const Color(0xFFEEF0FF),
  ),
  LuckyWheelCampaignItem(
    id: 'wheel-camp-005',
    rowNumber: 5,
    title: 'Exam Prep Spin',
    subtitle: 'Special rewards for students',
    rewardType: WheelRewardType.coins,
    startDate: DateTime(2026, 10, 5, 10, 0),
    endDate: DateTime(2026, 10, 25, 23, 59),
    totalSpins: 14320,
    participants: 5680,
    status: WheelCampaignStatus.completed,
    createdBy: 'Admin',
    iconData: Icons.school_rounded,
    iconColor: const Color(0xFF10B981),
    iconBgColor: const Color(0xFFECFDF5),
  ),
  LuckyWheelCampaignItem(
    id: 'wheel-camp-006',
    rowNumber: 6,
    title: 'Mega Reward Spin',
    subtitle: 'High value rewards campaign',
    rewardType: WheelRewardType.product,
    startDate: DateTime(2026, 10, 1, 10, 0),
    endDate: DateTime(2026, 10, 20, 23, 59),
    totalSpins: 9450,
    participants: 3860,
    status: WheelCampaignStatus.active,
    createdBy: 'Admin',
    iconData: Icons.diamond_rounded,
    iconColor: const Color(0xFF2587F8),
    iconBgColor: const Color(0xFFEFF6FF),
  ),
  LuckyWheelCampaignItem(
    id: 'wheel-camp-007',
    rowNumber: 7,
    title: 'Referral Spin',
    subtitle: 'Spin for referring friends',
    rewardType: WheelRewardType.cashback,
    startDate: DateTime(2026, 9, 28, 10, 0),
    endDate: DateTime(2026, 10, 15, 23, 59),
    totalSpins: 8640,
    participants: 3120,
    status: WheelCampaignStatus.paused,
    createdBy: 'Admin',
    iconData: Icons.group_add_rounded,
    iconColor: const Color(0xFFF43F5E),
    iconBgColor: const Color(0xFFFFF1F2),
  ),
];

/// The 5 reference Recent Activity items from the screenshot
final List<WheelActivityItem> kDefaultWheelActivities = [
  WheelActivityItem(
    id: 'act-1',
    title: 'New spin: Rahul Sharma won 50 coins',
    timeAgo: '5 minutes ago',
    icon: Icons.monetization_on_rounded,
    iconColor: const Color(0xFF10B981),
    iconBgColor: const Color(0xFFECFDF5),
  ),
  WheelActivityItem(
    id: 'act-2',
    title: 'Campaign created: Festive Mega Spin',
    timeAgo: '25 minutes ago',
    icon: Icons.calendar_today_rounded,
    iconColor: const Color(0xFFFF9F0A),
    iconBgColor: const Color(0xFFFFF7ED),
  ),
  WheelActivityItem(
    id: 'act-3',
    title: 'Reward given: ₹50 cashback',
    timeAgo: '1 hour ago',
    icon: Icons.card_giftcard_rounded,
    iconColor: const Color(0xFFF04483),
    iconBgColor: const Color(0xFFFDF2F8),
  ),
  WheelActivityItem(
    id: 'act-4',
    title: 'Campaign updated: Daily Spin Rewards',
    timeAgo: '3 hours ago',
    icon: Icons.edit_note_rounded,
    iconColor: const Color(0xFF5636F5),
    iconBgColor: const Color(0xFFEEF0FF),
  ),
  WheelActivityItem(
    id: 'act-5',
    title: 'Campaign paused: Referral Spin',
    timeAgo: '5 hours ago',
    icon: Icons.pause_circle_rounded,
    iconColor: const Color(0xFFEF4444),
    iconBgColor: const Color(0xFFFEF2F2),
  ),
];

/// Spins trend 7-day data
class WheelSpinsTrendDay {
  final String dateLabel;
  final int count;
  final double heightRatio;

  const WheelSpinsTrendDay({
    required this.dateLabel,
    required this.count,
    required this.heightRatio,
  });
}

final List<WheelSpinsTrendDay> kDefaultSpinsTrend = [
  WheelSpinsTrendDay(dateLabel: 'Oct 12', count: 2500, heightRatio: 0.18),
  WheelSpinsTrendDay(dateLabel: 'Oct 13', count: 3800, heightRatio: 0.28),
  WheelSpinsTrendDay(dateLabel: 'Oct 14', count: 5200, heightRatio: 0.38),
  WheelSpinsTrendDay(dateLabel: 'Oct 15', count: 9100, heightRatio: 0.58),
  WheelSpinsTrendDay(dateLabel: 'Oct 16', count: 12800, heightRatio: 0.75),
  WheelSpinsTrendDay(dateLabel: 'Oct 17', count: 15200, heightRatio: 0.85),
  WheelSpinsTrendDay(dateLabel: 'Oct 18', count: 18230, heightRatio: 1.00),
];

/// Reward Type Distribution Donut data
class WheelRewardDistributionItem {
  final String label;
  final int count;
  final int percentage;
  final Color color;

  const WheelRewardDistributionItem({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
  });
}

final List<WheelRewardDistributionItem> kDefaultRewardDistribution = [
  WheelRewardDistributionItem(
    label: 'Coins',
    count: 6,
    percentage: 32,
    color: const Color(0xFF2587F8),
  ),
  WheelRewardDistributionItem(
    label: 'Cashback',
    count: 4,
    percentage: 24,
    color: const Color(0xFFFF9F0A),
  ),
  WheelRewardDistributionItem(
    label: 'Discount',
    count: 3,
    percentage: 16,
    color: const Color(0xFF5636F5),
  ),
  WheelRewardDistributionItem(
    label: 'Gift',
    count: 2,
    percentage: 12,
    color: const Color(0xFFF04483),
  ),
  WheelRewardDistributionItem(
    label: 'Product',
    count: 2,
    percentage: 10,
    color: const Color(0xFF06B6D4),
  ),
  WheelRewardDistributionItem(
    label: 'Others',
    count: 1,
    percentage: 6,
    color: const Color(0xFF94A3B8),
  ),
];
