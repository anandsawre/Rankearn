import 'package:flutter/material.dart';

/// Supported reward types on the Lucky Wheel
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
      if (t.label.toLowerCase() == val.toLowerCase() ||
          t.name.toLowerCase() == val.toLowerCase()) {
        return t;
      }
    }
    return WheelRewardType.coins;
  }
}

/// Status of a Lucky Wheel Campaign
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
      if (s.label.toLowerCase() == val.toLowerCase() ||
          s.name.toLowerCase() == val.toLowerCase()) {
        return s;
      }
    }
    return WheelCampaignStatus.active;
  }
}

/// Single slice/segment on the wheel
class WheelRewardSegment {
  final String id;
  final String campaignId;
  final String label;
  final WheelRewardType rewardType;
  final int rewardValue;
  final int probability; // 0..100 percentage weight
  final Color color;
  final bool isActive;

  const WheelRewardSegment({
    this.id = '',
    this.campaignId = '',
    required this.label,
    required this.rewardType,
    required this.rewardValue,
    required this.probability,
    required this.color,
    this.isActive = true,
  });

  Map<String, dynamic> toJson({String? forCampaignId}) => {
        if (id.isNotEmpty) 'id': id,
        'campaign_id': forCampaignId ?? campaignId,
        'label': label,
        'reward_type': rewardType.name,
        'reward_value': rewardValue,
        'probability': probability,
        'slice_color': color.toARGB32(),
        'is_active': isActive,
      };

  factory WheelRewardSegment.fromJson(Map<String, dynamic> json) {
    Color parsedColor = const Color(0xFF10B981);
    if (json['slice_color'] != null) {
      parsedColor = Color((json['slice_color'] as num).toInt());
    } else if (json['color'] != null) {
      parsedColor = Color((json['color'] as num).toInt());
    }

    return WheelRewardSegment(
      id: json['id'] as String? ?? '',
      campaignId: json['campaign_id'] as String? ?? '',
      label: json['label'] as String? ?? 'Reward',
      rewardType: WheelRewardType.fromString(
        json['reward_type'] as String? ?? 'coins',
      ),
      rewardValue: (json['reward_value'] as num?)?.toInt() ?? 0,
      probability: (json['probability'] as num?)?.toInt() ?? 10,
      color: parsedColor,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  WheelRewardSegment copyWith({
    String? id,
    String? campaignId,
    String? label,
    WheelRewardType? rewardType,
    int? rewardValue,
    int? probability,
    Color? color,
    bool? isActive,
  }) {
    return WheelRewardSegment(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      label: label ?? this.label,
      rewardType: rewardType ?? this.rewardType,
      rewardValue: rewardValue ?? this.rewardValue,
      probability: probability ?? this.probability,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Authoritative Lucky Wheel Campaign Model
class LuckyWheelCampaignModel {
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
  final int spinCost;
  final int dailyLimit;
  final int campaignLimit;
  final List<WheelRewardSegment> slices;

  const LuckyWheelCampaignModel({
    required this.id,
    this.rowNumber = 1,
    required this.title,
    required this.subtitle,
    required this.rewardType,
    required this.startDate,
    required this.endDate,
    required this.totalSpins,
    required this.participants,
    required this.status,
    required this.createdBy,
    this.spinCost = 10,
    this.dailyLimit = 5,
    this.campaignLimit = 10,
    this.slices = const [],
  });

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

  factory LuckyWheelCampaignModel.fromJson(
    Map<String, dynamic> json, [
    int index = 0,
    List<WheelRewardSegment> segments = const [],
  ]) {
    return LuckyWheelCampaignModel(
      id: json['id'] as String? ?? 'wheel-$index',
      rowNumber: index + 1,
      title: json['title'] as String? ?? 'Daily Spin Rewards',
      subtitle: json['subtitle'] as String? ?? 'Win coins and rewards',
      rewardType: WheelRewardType.fromString(
        json['reward_type'] as String? ?? 'coins',
      ),
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String) ??
              DateTime.now().add(const Duration(days: 14))
          : DateTime.now().add(const Duration(days: 14)),
      totalSpins: (json['total_spins'] as num?)?.toInt() ?? 0,
      participants: (json['participants'] as num?)?.toInt() ?? 0,
      status: WheelCampaignStatus.fromString(
        json['status'] as String? ?? 'active',
      ),
      createdBy: json['created_by'] as String? ?? 'Admin',
      spinCost: (json['spin_cost'] as num?)?.toInt() ?? 10,
      dailyLimit: (json['daily_limit'] as num?)?.toInt() ?? 5,
      campaignLimit: (json['campaign_limit'] as num?)?.toInt() ?? 10,
      slices: segments,
    );
  }

  LuckyWheelCampaignModel copyWith({
    String? id,
    int? rowNumber,
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
    return LuckyWheelCampaignModel(
      id: id ?? this.id,
      rowNumber: rowNumber ?? this.rowNumber,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      rewardType: rewardType ?? this.rewardType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalSpins: totalSpins ?? this.totalSpins,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      spinCost: spinCost ?? this.spinCost,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      campaignLimit: campaignLimit ?? this.campaignLimit,
      slices: slices ?? this.slices,
    );
  }
}

/// Result of an Authoritative Server Spin
class WheelSpinResult {
  final bool isSuccess;
  final String spinId;
  final String sliceId;
  final String rewardLabel;
  final String rewardType;
  final int rewardValue;
  final String transactionId;
  final int remainingDailySpins;
  final int targetIndex;
  final String? errorMessage;

  const WheelSpinResult({
    required this.isSuccess,
    this.spinId = '',
    this.sliceId = '',
    required this.rewardLabel,
    required this.rewardType,
    required this.rewardValue,
    this.transactionId = '',
    this.remainingDailySpins = 0,
    required this.targetIndex,
    this.errorMessage,
  });

  factory WheelSpinResult.fromJson(
    Map<String, dynamic> json, {
    required int targetIndex,
  }) {
    return WheelSpinResult(
      isSuccess: json['status'] == 'success' || json['status'] == 'credited',
      spinId: json['spin_id'] as String? ?? '',
      sliceId: json['slice_id'] as String? ?? '',
      rewardLabel: json['reward_label'] as String? ?? '50 Coins',
      rewardType: json['reward_type'] as String? ?? 'coins',
      rewardValue: (json['reward_value'] as num?)?.toInt() ?? 50,
      transactionId: json['transaction_id'] as String? ?? '',
      remainingDailySpins:
          (json['remaining_daily_spins'] as num?)?.toInt() ?? 0,
      targetIndex: targetIndex,
      errorMessage: json['message'] as String?,
    );
  }

  factory WheelSpinResult.failure(String message) {
    return WheelSpinResult(
      isSuccess: false,
      rewardLabel: '',
      rewardType: '',
      rewardValue: 0,
      targetIndex: 0,
      errorMessage: message,
    );
  }
}

