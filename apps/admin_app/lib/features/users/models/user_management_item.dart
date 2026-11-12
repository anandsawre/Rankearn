import 'package:flutter/material.dart';

/// User Role
enum UserRole {
  student('Student', Color(0xFF0284C7), Color(0xFFE0F2FE)),
  premium('Premium', Color(0xFF7C3AED), Color(0xFFEDE9FE)),
  teacher('Teacher', Color(0xFFF59E0B), Color(0xFFFEF3C7)),
  moderator('Moderator', Color(0xFF10B981), Color(0xFFD1FAE5)),
  admin('Admin', Color(0xFFEC4899), Color(0xFFFCE7F3));

  final String label;
  final Color color;
  final Color bgColor;

  const UserRole(this.label, this.color, this.bgColor);

  static UserRole fromString(String? val) {
    if (val == null) return UserRole.student;
    final lower = val.toLowerCase().trim();
    if (lower == 'premium') return UserRole.premium;
    if (lower == 'teacher') return UserRole.teacher;
    if (lower == 'moderator' || lower == 'support') return UserRole.moderator;
    if (lower == 'admin' || lower == 'superadmin') return UserRole.admin;
    return UserRole.student;
  }

  /// Maps UI tier to `public.app_role` enum (`'user' | 'support' | 'admin'`).
  String get dbRoleName {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.moderator:
        return 'support';
      case UserRole.student:
      case UserRole.premium:
      case UserRole.teacher:
        return 'user';
    }
  }
}

/// User Account Status
enum UserStatus {
  active('Active', Color(0xFF10B981), Color(0xFFECFDF5)),
  inactive('Inactive', Color(0xFFF59E0B), Color(0xFFFFFBEB)),
  blocked('Blocked', Color(0xFFF43F5E), Color(0xFFFFF1F2));

  final String label;
  final Color color;
  final Color bgColor;

  const UserStatus(this.label, this.color, this.bgColor);

  /// Maps to `public.profiles.status` CHECK constraint (`'active' | 'suspended' | 'banned'`).
  String get dbStatusValue {
    switch (this) {
      case UserStatus.active:
        return 'active';
      case UserStatus.inactive:
        return 'suspended';
      case UserStatus.blocked:
        return 'banned';
    }
  }

  static UserStatus fromString(String? val) {
    if (val == null) return UserStatus.active;
    final lower = val.toLowerCase().trim();
    if (lower == 'inactive' || lower == 'suspended') return UserStatus.inactive;
    if (lower == 'blocked' || lower == 'banned') return UserStatus.blocked;
    return UserStatus.active;
  }
}

/// Domain model for Users Management list item
class UserManagementItem {
  final String id;
  final int rowNumber;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;
  final int enrollmentsCount;
  final int testsAttemptedCount;
  final int coins;
  final String lastActive;
  final DateTime? lastActiveAt;
  final UserStatus status;
  final DateTime joinedAt;

  const UserManagementItem({
    required this.id,
    required this.rowNumber,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.role,
    this.enrollmentsCount = 0,
    this.testsAttemptedCount = 0,
    this.coins = 0,
    this.lastActive = '—',
    this.lastActiveAt,
    this.status = UserStatus.active,
    required this.joinedAt,
  });

  String get joinedDateFormatted {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[joinedAt.month - 1]} ${joinedAt.day.toString().padLeft(2, '0')}, ${joinedAt.year}';
  }

  UserManagementItem copyWith({
    String? id,
    int? rowNumber,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    int? enrollmentsCount,
    int? testsAttemptedCount,
    int? coins,
    String? lastActive,
    DateTime? lastActiveAt,
    UserStatus? status,
    DateTime? joinedAt,
  }) {
    return UserManagementItem(
      id: id ?? this.id,
      rowNumber: rowNumber ?? this.rowNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      enrollmentsCount: enrollmentsCount ?? this.enrollmentsCount,
      testsAttemptedCount: testsAttemptedCount ?? this.testsAttemptedCount,
      coins: coins ?? this.coins,
      lastActive: lastActive ?? this.lastActive,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  /// Columns matching `public.profiles` SQL schema for safe UPDATE/UPSERT.
  Map<String, dynamic> toProfileUpdateMap() {
    return {
      'name': name,
      'phone': phone,
      if (avatarUrl != null) 'profile_photo_url': avatarUrl,
      'subscription_status': role == UserRole.premium ? 'premium' : 'free',
      'status': status.dbStatusValue,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  factory UserManagementItem.fromMap(
    Map<String, dynamic> map, [
    int index = 1,
    UserRole? resolvedRole,
    int? enrollmentsCount,
    int? testsAttemptedCount,
    DateTime? latestActivityAt,
  ]) {
    final rawSub = map['subscription_status']?.toString().toLowerCase().trim();
    final roleStr = map['role']?.toString();
    final derivedRole = resolvedRole ??
        (roleStr != null && roleStr.isNotEmpty
            ? UserRole.fromString(roleStr)
            : (rawSub == 'premium' ? UserRole.premium : UserRole.student));

    final statusStr = map['status']?.toString();
    final created = map['created_at'] != null
        ? DateTime.tryParse(map['created_at'].toString())?.toLocal() ?? DateTime.now()
        : DateTime.now();

    final activityTimestamp = latestActivityAt ??
        (map['last_active_at'] != null
            ? DateTime.tryParse(map['last_active_at'].toString())?.toLocal()
            : (map['updated_at'] != null
                ? DateTime.tryParse(map['updated_at'].toString())?.toLocal()
                : created));

    return UserManagementItem(
      id: map['id']?.toString() ?? 'usr-$index',
      rowNumber: index,
      name: map['name']?.toString() ?? 'User',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString(),
      avatarUrl: map['profile_photo_url']?.toString(),
      role: derivedRole,
      enrollmentsCount:
          enrollmentsCount ?? (map['enrollments_count'] as num?)?.toInt() ?? 0,
      testsAttemptedCount:
          testsAttemptedCount ?? (map['tests_attempted_count'] as num?)?.toInt() ?? 0,
      coins: (map['coins'] as num?)?.toInt() ?? 0,
      lastActive: _formatLastActive(activityTimestamp),
      lastActiveAt: activityTimestamp,
      status: UserStatus.fromString(statusStr),
      joinedAt: created,
    );
  }

  static String _formatLastActive(DateTime? dt) {
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 2) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}
