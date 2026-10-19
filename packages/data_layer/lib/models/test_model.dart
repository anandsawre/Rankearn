/// Test Series & Contest Domain Model
class TestModel {
  final String id;
  final String title;
  final String? examCategoryId;
  final String? categoryId;
  final String testMode; // 'mock' | 'sectional' | 'previous-year' | 'tournament'
  final int durationMinutes;
  final int totalQuestions;
  final double negativeMarking;
  final bool isPremium;
  final bool isProOnly;
  final int unlockPriceCoins;
  final String status;
  final bool isTournament;
  final int entryFeeCoins;
  final int totalParticipants;
  final DateTime? scheduledStartTime;
  final DateTime? scheduledEndTime;
  final bool isResultDeclared;
  final String? syllabus;

  const TestModel({
    required this.id,
    required this.title,
    this.examCategoryId,
    this.categoryId,
    this.testMode = 'mock',
    required this.durationMinutes,
    this.totalQuestions = 0,
    this.negativeMarking = 0.0,
    this.isPremium = false,
    this.isProOnly = false,
    this.unlockPriceCoins = 0,
    this.status = 'published',
    this.isTournament = false,
    this.entryFeeCoins = 0,
    this.totalParticipants = 0,
    this.scheduledStartTime,
    this.scheduledEndTime,
    this.isResultDeclared = false,
    this.syllabus,
  });

  bool get isLive {
    if (!isTournament) return true;
    final now = DateTime.now();
    if (scheduledStartTime != null && now.isBefore(scheduledStartTime!)) return false;
    if (scheduledEndTime != null && now.isAfter(scheduledEndTime!)) return false;
    return true;
  }

  bool get isUpcoming {
    if (!isTournament || scheduledStartTime == null) return false;
    return DateTime.now().isBefore(scheduledStartTime!);
  }

  bool get isPast {
    if (!isTournament || scheduledEndTime == null) return false;
    return DateTime.now().isAfter(scheduledEndTime!);
  }

  factory TestModel.fromMap(Map<String, dynamic> map) {
    return TestModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Test Series',
      examCategoryId: map['exam_category_id']?.toString(),
      categoryId: map['category_id']?.toString(),
      testMode: map['test_mode']?.toString() ?? 'mock',
      durationMinutes: (map['duration_minutes'] as num?)?.toInt() ?? 60,
      totalQuestions: (map['total_questions'] as num?)?.toInt() ?? 0,
      negativeMarking: (map['negative_marking'] as num?)?.toDouble() ?? 0.0,
      isPremium: map['is_premium'] == true,
      isProOnly: map['is_pro_only'] == true,
      unlockPriceCoins: (map['unlock_price_coins'] as num?)?.toInt() ?? 0,
      status: map['status']?.toString() ?? 'published',
      isTournament: map['is_tournament'] == true,
      entryFeeCoins: (map['entry_fee_coins'] as num?)?.toInt() ?? 0,
      totalParticipants: (map['total_participants'] as num?)?.toInt() ?? 0,
      scheduledStartTime: map['scheduled_start_time'] != null
          ? DateTime.tryParse(map['scheduled_start_time'].toString())
          : null,
      scheduledEndTime: map['scheduled_end_time'] != null
          ? DateTime.tryParse(map['scheduled_end_time'].toString())
          : null,
      isResultDeclared: map['is_result_declared'] == true,
      syllabus: map['syllabus']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'exam_category_id': examCategoryId,
      'category_id': categoryId,
      'test_mode': testMode,
      'duration_minutes': durationMinutes,
      'total_questions': totalQuestions,
      'negative_marking': negativeMarking,
      'is_premium': isPremium,
      'is_pro_only': isProOnly,
      'unlock_price_coins': unlockPriceCoins,
      'status': status,
      'is_tournament': isTournament,
      'entry_fee_coins': entryFeeCoins,
      'total_participants': totalParticipants,
      'scheduled_start_time': scheduledStartTime?.toIso8601String(),
      'scheduled_end_time': scheduledEndTime?.toIso8601String(),
      'is_result_declared': isResultDeclared,
      'syllabus': syllabus,
    };
  }
}
