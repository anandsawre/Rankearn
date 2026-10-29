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
    if (lower == 'moderator') return UserRole.moderator;
    if (lower == 'admin' || lower == 'superadmin') return UserRole.admin;
    return UserRole.student;
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

  static UserStatus fromString(String? val) {
    if (val == null) return UserStatus.active;
    final lower = val.toLowerCase().trim();
    if (lower == 'inactive') return UserStatus.inactive;
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
  final String lastActive; // e.g. 'Online now', '5 minutes ago', '1 hour ago'
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
    this.lastActive = 'Online now',
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_photo_url': avatarUrl,
      'role': role.name,
      'enrollments_count': enrollmentsCount,
      'tests_attempted_count': testsAttemptedCount,
      'coins': coins,
      'last_active_at': lastActiveAt?.toIso8601String(),
      'status': status.name,
      'created_at': joinedAt.toIso8601String(),
    };
  }

  factory UserManagementItem.fromMap(Map<String, dynamic> map, [int index = 1]) {
    final roleStr = map['role']?.toString();
    final statusStr = map['status']?.toString();
    final created = map['created_at'] != null
        ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime(2026, 10, 18)
        : DateTime(2026, 10, 18);

    return UserManagementItem(
      id: map['id']?.toString() ?? 'usr-$index',
      rowNumber: index,
      name: map['name']?.toString() ?? 'Candidate User',
      email: map['email']?.toString() ?? 'user@rankearn.in',
      phone: map['phone']?.toString(),
      avatarUrl: map['profile_photo_url']?.toString(),
      role: UserRole.fromString(roleStr),
      enrollmentsCount: (map['enrollments_count'] as num?)?.toInt() ?? 0,
      testsAttemptedCount: (map['tests_attempted_count'] as num?)?.toInt() ?? 0,
      coins: (map['coins'] as num?)?.toInt() ?? 0,
      lastActive: _formatLastActive(map['last_active_at']),
      lastActiveAt: map['last_active_at'] != null ? DateTime.tryParse(map['last_active_at'].toString()) : null,
      status: UserStatus.fromString(statusStr),
      joinedAt: created,
    );
  }

  static String _formatLastActive(dynamic raw) {
    if (raw == null) return 'Online now';
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return 'Online now';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 2) return 'Online now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}

/// Baseline Reference Users corresponding to the 7 visible table rows in reference specification
final List<UserManagementItem> kReferenceUsers = [
  UserManagementItem(
    id: 'usr-1',
    rowNumber: 1,
    name: 'Rahul Sharma',
    email: 'rahul.sharma@example.com',
    phone: '+91 98765 43210',
    role: UserRole.student,
    enrollmentsCount: 12,
    testsAttemptedCount: 48,
    coins: 1250,
    lastActive: 'Online now',
    status: UserStatus.active,
    joinedAt: DateTime(2026, 10, 18),
  ),
  UserManagementItem(
    id: 'usr-2',
    rowNumber: 2,
    name: 'Priya Verma',
    email: 'priya.verma@example.com',
    phone: '+91 98765 43211',
    role: UserRole.student,
    enrollmentsCount: 8,
    testsAttemptedCount: 32,
    coins: 450,
    lastActive: '5 minutes ago',
    status: UserStatus.active,
    joinedAt: DateTime(2026, 10, 17),
  ),
  UserManagementItem(
    id: 'usr-3',
    rowNumber: 3,
    name: 'Amit Kumar',
    email: 'amit.kumar@example.com',
    phone: '+91 98765 43212',
    role: UserRole.premium,
    enrollmentsCount: 28,
    testsAttemptedCount: 124,
    coins: 3800,
    lastActive: '1 hour ago',
    status: UserStatus.active,
    joinedAt: DateTime(2026, 10, 16),
  ),
  UserManagementItem(
    id: 'usr-4',
    rowNumber: 4,
    name: 'Neha Singh',
    email: 'neha.singh@example.com',
    phone: '+91 98765 43213',
    role: UserRole.student,
    enrollmentsCount: 5,
    testsAttemptedCount: 18,
    coins: 200,
    lastActive: '3 hours ago',
    status: UserStatus.active,
    joinedAt: DateTime(2026, 10, 15),
  ),
  UserManagementItem(
    id: 'usr-5',
    rowNumber: 5,
    name: 'Vikash Yadav',
    email: 'vikash.yadav@example.com',
    phone: '+91 98765 43214',
    role: UserRole.student,
    enrollmentsCount: 15,
    testsAttemptedCount: 62,
    coins: 750,
    lastActive: '6 hours ago',
    status: UserStatus.inactive,
    joinedAt: DateTime(2026, 10, 14),
  ),
  UserManagementItem(
    id: 'usr-6',
    rowNumber: 6,
    name: 'Anjali Patel',
    email: 'anjali.patel@example.com',
    phone: '+91 98765 43215',
    role: UserRole.premium,
    enrollmentsCount: 22,
    testsAttemptedCount: 96,
    coins: 2400,
    lastActive: '1 day ago',
    status: UserStatus.active,
    joinedAt: DateTime(2026, 10, 13),
  ),
  UserManagementItem(
    id: 'usr-7',
    rowNumber: 7,
    name: 'Saurabh Gupta',
    email: 'saurabh.gupta@example.com',
    phone: '+91 98765 43216',
    role: UserRole.student,
    enrollmentsCount: 0,
    testsAttemptedCount: 0,
    coins: 0,
    lastActive: '2 days ago',
    status: UserStatus.blocked,
    joinedAt: DateTime(2026, 10, 12),
  ),
  // Additional users to support full pagination and realistic filtering (totaling 12,458 count)
  ...List.generate(43, (i) {
    final idx = i + 8;
    final names = [
      'Rohan Gupta', 'Kavita Roy', 'Manoj Tiwari', 'Pooja Hegde', 'Deepak Verma',
      'Divya Sharma', 'Arjun Kapoor', 'Swati Deshmukh', 'Karan Johar', 'Sunita Rao',
      'Nikhil Nair', 'Ritu Saxena', 'Gaurav Sen', 'Meera Rajput', 'Vivek Oberoi',
    ];
    final name = names[i % names.length] + (idx > 22 ? ' ($idx)' : '');
    final isPremium = idx % 4 == 0;
    final isInactive = idx % 7 == 0;
    final isBlocked = idx == 48;
    return UserManagementItem(
      id: 'usr-$idx',
      rowNumber: idx,
      name: name,
      email: '${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '.')}$idx@example.com',
      phone: '+91 98765 ${43220 + idx}',
      role: isPremium ? UserRole.premium : (idx % 10 == 0 ? UserRole.teacher : UserRole.student),
      enrollmentsCount: (idx * 3) % 40,
      testsAttemptedCount: (idx * 11) % 150,
      coins: (idx * 175) % 3500,
      lastActive: idx % 3 == 0 ? 'Online now' : '${(idx % 12) + 1} hours ago',
      status: isBlocked ? UserStatus.blocked : (isInactive ? UserStatus.inactive : UserStatus.active),
      joinedAt: DateTime(2026, 10, 11).subtract(Duration(days: idx)),
    );
  }),
];
