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
  final String? examCategoryId;
  final String testMode;
  final int totalTests;
  final int durationMinutes;
  final int totalQuestions;
  final double negativeMarking;
  final String? topic;
  final bool isPremium;
  final int priceInr; // unlock_price_coins
  final bool isTournament;
  final int entryFeeCoins;
  final int prizePoolCoins;
  final DateTime? scheduledStartTime;
  final DateTime? scheduledEndTime;
  final int enrollments;
  final TestSeriesStatus status;
  final DateTime createdAt;
  final IconData icon;
  final Color iconColor;

  num get prizePoolInRupees => prizePoolCoins > 0 ? (prizePoolCoins / 20) : 0;

  const TestSeriesItem({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    this.examCategoryId = 'bpsc',
    this.testMode = 'mock',
    this.totalTests = 1,
    this.durationMinutes = 60,
    required this.totalQuestions,
    this.negativeMarking = 0.25,
    this.topic,
    this.isPremium = false,
    required this.priceInr,
    this.isTournament = false,
    this.entryFeeCoins = 0,
    this.prizePoolCoins = 1500,
    this.scheduledStartTime,
    this.scheduledEndTime,
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
    String? examCategoryId,
    String? testMode,
    int? totalTests,
    int? durationMinutes,
    int? totalQuestions,
    double? negativeMarking,
    String? topic,
    bool? isPremium,
    int? priceInr,
    bool? isTournament,
    int? entryFeeCoins,
    int? prizePoolCoins,
    DateTime? scheduledStartTime,
    DateTime? scheduledEndTime,
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
      examCategoryId: examCategoryId ?? this.examCategoryId,
      testMode: testMode ?? this.testMode,
      totalTests: totalTests ?? this.totalTests,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      negativeMarking: negativeMarking ?? this.negativeMarking,
      topic: topic ?? this.topic,
      isPremium: isPremium ?? this.isPremium,
      priceInr: priceInr ?? this.priceInr,
      isTournament: isTournament ?? this.isTournament,
      entryFeeCoins: entryFeeCoins ?? this.entryFeeCoins,
      prizePoolCoins: prizePoolCoins ?? this.prizePoolCoins,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
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
      'test_mode': testMode,
      'duration_minutes': durationMinutes > 0 ? durationMinutes : (totalTests > 0 ? totalTests : 60),
      'total_questions': totalQuestions,
      'negative_marking': negativeMarking,
      'is_premium': isPremium,
      'unlock_price_coins': priceInr,
      'is_tournament': isTournament,
      'entry_fee_coins': entryFeeCoins,
      'prize_pool_coins': prizePoolCoins,
      'scheduled_start_time': scheduledStartTime?.toIso8601String(),
      'scheduled_end_time': scheduledEndTime?.toIso8601String(),
      'total_participants': enrollments,
      'status': status.name,
      'exam_category_id': (examCategoryId != null && examCategoryId!.isNotEmpty) ? examCategoryId : null,
      'category_id': subject.isNotEmpty ? subject : null,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TestSeriesItem.fromMap(
    Map<String, dynamic> map,
    int fallbackIndex, {
    String? resolvedSubject,
    int? actualQuestionsCount,
    int? actualEnrollments,
  }) {
    final statusStr = map['status']?.toString() ?? 'published';
    final examCat = map['exam_category_id']?.toString();
    final mode = map['test_mode']?.toString() ?? 'mock';
    final rawSub = resolvedSubject?.trim().isNotEmpty == true
        ? resolvedSubject!.trim()
        : (map['category']?.toString().trim().isNotEmpty == true
            ? map['category'].toString().trim()
            : map['category_id']?.toString().trim());
    final sub = (rawSub != null && rawSub.isNotEmpty) ? rawSub : 'General';
    final dur = (map['duration_minutes'] as num?)?.toInt() ?? 0;
    final storedQuestions = (map['total_questions'] as num?)?.toInt() ?? 0;
    final storedEnrollments = (map['total_participants'] as num?)?.toInt() ?? 0;
    final effectiveQuestions = (actualQuestionsCount != null && actualQuestionsCount > storedQuestions)
        ? actualQuestionsCount
        : storedQuestions;
    final effectiveEnrollments = (actualEnrollments != null && actualEnrollments > storedEnrollments)
        ? actualEnrollments
        : storedEnrollments;

    final (icon, color) = _getIconAndColorForSubject(sub, fallbackIndex);

    final rawPrize = (map['prize_pool_coins'] as num?)?.toInt() ??
        ((map['prize_pool'] as num?) != null ? ((map['prize_pool'] as num).toInt() * 20) : 1500);

    return TestSeriesItem(
      id: map['id']?.toString() ?? 'ts-$fallbackIndex',
      title: map['title']?.toString() ?? 'Untitled Test Series',
      description: map['syllabus']?.toString() ?? map['description']?.toString() ?? '',
      subject: sub,
      examCategoryId: examCat,
      testMode: mode,
      totalTests: (map['total_tests'] as num?)?.toInt() ?? dur,
      durationMinutes: dur > 0 ? dur : 60,
      totalQuestions: effectiveQuestions,
      negativeMarking: (map['negative_marking'] as num?)?.toDouble() ?? 0.25,
      isPremium: map['is_premium'] == true,
      priceInr: (map['unlock_price_coins'] as num?)?.toInt() ?? 0,
      isTournament: map['is_tournament'] == true,
      entryFeeCoins: (map['entry_fee_coins'] as num?)?.toInt() ?? 0,
      prizePoolCoins: rawPrize,
      scheduledStartTime: map['scheduled_start_time'] != null
          ? DateTime.tryParse(map['scheduled_start_time'].toString())?.toLocal()
          : null,
      scheduledEndTime: map['scheduled_end_time'] != null
          ? DateTime.tryParse(map['scheduled_end_time'].toString())?.toLocal()
          : null,
      enrollments: effectiveEnrollments,
      status: TestSeriesStatus.fromString(statusStr),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
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
}
