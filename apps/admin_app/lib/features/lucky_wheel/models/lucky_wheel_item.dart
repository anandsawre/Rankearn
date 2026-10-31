import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';

export 'package:data_layer/models/lucky_wheel_models.dart'
    show WheelRewardType, WheelCampaignStatus, WheelRewardSegment;

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
    this.dailyLimit = 5,
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
      dailyLimit: (json['daily_limit'] as num?)?.toInt() ?? 5,
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
