import 'package:flutter/material.dart';

/// Status of a Test Series
enum TestSeriesStatus {
  published,
  draft,
  archived;

  String get label {
    switch (this) {
      case TestSeriesStatus.published:
        return 'Published';
      case TestSeriesStatus.draft:
        return 'Draft';
      case TestSeriesStatus.archived:
        return 'Archived';
    }
  }

  static TestSeriesStatus fromString(String val) {
    final lower = val.toLowerCase().trim();
    if (lower == 'published') return TestSeriesStatus.published;
    if (lower == 'draft') return TestSeriesStatus.draft;
    if (lower == 'archived') return TestSeriesStatus.archived;
    return TestSeriesStatus.published;
  }
}

/// Domain Model for Rankearn Test Series Management
class TestSeriesItem {
  final String id;
  final String title;
  final String description;
  final String subject;
  final int totalTests;
  final int totalQuestions;
  final int priceInr;
  final int enrollments;
  final TestSeriesStatus status;
  final DateTime createdAt;
  final IconData icon;
  final Color iconColor;

  const TestSeriesItem({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.totalTests,
    required this.totalQuestions,
    required this.priceInr,
    required this.enrollments,
    required this.status,
    required this.createdAt,
    required this.icon,
    required this.iconColor,
  });

  TestSeriesItem copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    int? totalTests,
    int? totalQuestions,
    int? priceInr,
    int? enrollments,
    TestSeriesStatus? status,
    DateTime? createdAt,
    IconData? icon,
    Color? iconColor,
  }) {
    return TestSeriesItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      totalTests: totalTests ?? this.totalTests,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      priceInr: priceInr ?? this.priceInr,
      enrollments: enrollments ?? this.enrollments,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'syllabus': description,
      'category_id': subject,
      'total_questions': totalQuestions,
      'unlock_price_coins': priceInr,
      'total_participants': enrollments,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TestSeriesItem.fromMap(Map<String, dynamic> map, int fallbackIndex) {
    final statusStr = map['status']?.toString() ?? 'published';
    final sub = map['category_id']?.toString() ??
        map['exam_category_id']?.toString() ??
        'General Science';

    final (icon, color) = _getIconAndColorForSubject(sub, fallbackIndex);

    return TestSeriesItem(
      id: map['id']?.toString() ?? 'ts-$fallbackIndex',
      title: map['title']?.toString() ?? 'Test Series #$fallbackIndex',
      description: map['syllabus']?.toString() ??
          map['description']?.toString() ??
          'Complete test series with solutions',
      subject: sub,
      totalTests: (map['duration_minutes'] as num?)?.toInt() ?? 20,
      totalQuestions: (map['total_questions'] as num?)?.toInt() ?? 2000,
      priceInr: (map['unlock_price_coins'] as num?)?.toInt() ?? 149,
      enrollments: (map['total_participants'] as num?)?.toInt() ?? 1200,
      status: TestSeriesStatus.fromString(statusStr),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime(2026, 10, 10)
          : DateTime(2026, 10, 10),
      icon: icon,
      iconColor: color,
    );
  }

  static (IconData, Color) _getIconAndColorForSubject(String subject, int index) {
    final lower = subject.toLowerCase();
    if (lower.contains('science')) {
      return (Icons.science_rounded, const Color(0xFF6366F1));
    } else if (lower.contains('math')) {
      return (Icons.calculate_rounded, const Color(0xFFF43F5E));
    } else if (lower.contains('reasoning')) {
      return (Icons.lightbulb_rounded, const Color(0xFFF59E0B));
    } else if (lower.contains('current') || lower.contains('affairs') || lower.contains('gk')) {
      return (Icons.public_rounded, const Color(0xFF0284C7));
    } else if (lower.contains('chemistry')) {
      return (Icons.biotech_rounded, const Color(0xFFA855F7));
    } else if (lower.contains('biology')) {
      return (Icons.eco_rounded, const Color(0xFF10B981));
    } else {
      return (Icons.settings_suggest_rounded, const Color(0xFF06B6D4));
    }
  }

  /// Initial reference dataset matching the screenshot exactly
  static List<TestSeriesItem> get referenceData => [
        TestSeriesItem(
          id: 'ts-1',
          title: 'RRB Technician Grade 3',
          description: 'Complete test series with detailed solutions',
          subject: 'General Science',
          totalTests: 20,
          totalQuestions: 2000,
          priceInr: 199,
          enrollments: 3245,
          status: TestSeriesStatus.published,
          createdAt: DateTime(2026, 10, 10),
          icon: Icons.science_rounded,
          iconColor: const Color(0xFF6366F1),
        ),
        TestSeriesItem(
          id: 'ts-2',
          title: 'Railway Maths Practice Series',
          description: 'Topic wise and full length tests',
          subject: 'Mathematics',
          totalTests: 25,
          totalQuestions: 2500,
          priceInr: 149,
          enrollments: 2891,
          status: TestSeriesStatus.published,
          createdAt: DateTime(2026, 10, 8),
          icon: Icons.calculate_rounded,
          iconColor: const Color(0xFFF43F5E),
        ),
        TestSeriesItem(
          id: 'ts-3',
          title: 'Reasoning Special Series',
          description: 'Based on latest exam pattern',
          subject: 'Reasoning',
          totalTests: 20,
          totalQuestions: 2000,
          priceInr: 149,
          enrollments: 1985,
          status: TestSeriesStatus.published,
          createdAt: DateTime(2026, 10, 5),
          icon: Icons.lightbulb_rounded,
          iconColor: const Color(0xFFF59E0B),
        ),
        TestSeriesItem(
          id: 'ts-4',
          title: 'Current Affairs Monthly Series',
          description: 'Monthly current affairs tests',
          subject: 'Current Affairs',
          totalTests: 12,
          totalQuestions: 1200,
          priceInr: 99,
          enrollments: 1542,
          status: TestSeriesStatus.published,
          createdAt: DateTime(2026, 10, 1),
          icon: Icons.public_rounded,
          iconColor: const Color(0xFF0284C7),
        ),
        TestSeriesItem(
          id: 'ts-5',
          title: 'Chemistry Practice Series',
          description: 'Chapter wise tests with solutions',
          subject: 'Chemistry',
          totalTests: 18,
          totalQuestions: 1800,
          priceInr: 129,
          enrollments: 1238,
          status: TestSeriesStatus.draft,
          createdAt: DateTime(2026, 9, 28),
          icon: Icons.biotech_rounded,
          iconColor: const Color(0xFFA855F7),
        ),
        TestSeriesItem(
          id: 'ts-6',
          title: 'Biology Marathon Series',
          description: 'Complete biology test series',
          subject: 'Biology',
          totalTests: 15,
          totalQuestions: 1500,
          priceInr: 129,
          enrollments: 980,
          status: TestSeriesStatus.published,
          createdAt: DateTime(2026, 9, 25),
          icon: Icons.eco_rounded,
          iconColor: const Color(0xFF10B981),
        ),
        TestSeriesItem(
          id: 'ts-7',
          title: 'Full Syllabus Mock Test Series',
          description: 'Complete syllabus with previous year pattern',
          subject: 'Mixed',
          totalTests: 30,
          totalQuestions: 3000,
          priceInr: 249,
          enrollments: 1610,
          status: TestSeriesStatus.published,
          createdAt: DateTime(2026, 9, 20),
          icon: Icons.settings_suggest_rounded,
          iconColor: const Color(0xFF06B6D4),
        ),
      ];
}
