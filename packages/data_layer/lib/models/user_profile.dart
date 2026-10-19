/// User Profile Domain Model
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePhotoUrl;
  final String? examPreparingFor;
  final String? state;
  final int coins;
  final int totalEarned;
  final int totalSpent;
  final double withdrawableBalance;
  final List<String> badges;
  final String subscriptionStatus;
  final DateTime? subscriptionEndDate;
  final bool isLeaderboardEligible;
  final DateTime? lastSpinDate;
  final String? referralCode;
  final String? referredBy;
  final String status;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePhotoUrl,
    this.examPreparingFor,
    this.state,
    this.coins = 0,
    this.totalEarned = 0,
    this.totalSpent = 0,
    this.withdrawableBalance = 0.0,
    this.badges = const [],
    this.subscriptionStatus = 'free',
    this.subscriptionEndDate,
    this.isLeaderboardEligible = false,
    this.lastSpinDate,
    this.referralCode,
    this.referredBy,
    this.status = 'active',
    required this.createdAt,
  });

  bool get isPro =>
      subscriptionStatus == 'premium' &&
      (subscriptionEndDate == null || subscriptionEndDate!.isAfter(DateTime.now()));

  bool get isActive => status == 'active';

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'User',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString(),
      profilePhotoUrl: map['profile_photo_url']?.toString(),
      examPreparingFor: map['exam_preparing_for']?.toString(),
      state: map['state']?.toString(),
      coins: (map['coins'] as num?)?.toInt() ?? 0,
      totalEarned: (map['total_earned'] as num?)?.toInt() ?? 0,
      totalSpent: (map['total_spent'] as num?)?.toInt() ?? 0,
      withdrawableBalance: (map['withdrawable_balance'] as num?)?.toDouble() ?? 0.0,
      badges: (map['badges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      subscriptionStatus: map['subscription_status']?.toString() ?? 'free',
      subscriptionEndDate: map['subscription_end_date'] != null
          ? DateTime.tryParse(map['subscription_end_date'].toString())
          : null,
      isLeaderboardEligible: map['is_leaderboard_eligible'] == true,
      lastSpinDate: map['last_spin_date'] != null
          ? DateTime.tryParse(map['last_spin_date'].toString())
          : null,
      referralCode: map['referral_code']?.toString(),
      referredBy: map['referred_by']?.toString(),
      status: map['status']?.toString() ?? 'active',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_photo_url': profilePhotoUrl,
      'exam_preparing_for': examPreparingFor,
      'state': state,
      'coins': coins,
      'total_earned': totalEarned,
      'total_spent': totalSpent,
      'withdrawable_balance': withdrawableBalance,
      'badges': badges,
      'subscription_status': subscriptionStatus,
      'subscription_end_date': subscriptionEndDate?.toIso8601String(),
      'is_leaderboard_eligible': isLeaderboardEligible,
      'last_spin_date': lastSpinDate?.toIso8601String(),
      'referral_code': referralCode,
      'referred_by': referredBy,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? name,
    String? phone,
    String? profilePhotoUrl,
    String? examPreparingFor,
    String? state,
    int? coins,
    int? totalEarned,
    int? totalSpent,
    double? withdrawableBalance,
    String? subscriptionStatus,
    DateTime? subscriptionEndDate,
    bool? isLeaderboardEligible,
    DateTime? lastSpinDate,
    String? status,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      examPreparingFor: examPreparingFor ?? this.examPreparingFor,
      state: state ?? this.state,
      coins: coins ?? this.coins,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
      withdrawableBalance: withdrawableBalance ?? this.withdrawableBalance,
      badges: badges,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      isLeaderboardEligible: isLeaderboardEligible ?? this.isLeaderboardEligible,
      lastSpinDate: lastSpinDate ?? this.lastSpinDate,
      referralCode: referralCode,
      referredBy: referredBy,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
