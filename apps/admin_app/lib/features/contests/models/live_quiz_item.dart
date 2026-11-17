import 'package:flutter/material.dart';
import '../../tests/models/test_series_item.dart';

enum LiveQuizStatus {
  liveNow,
  completed,
  scheduled,
  ongoing,
  draft,
}

class LiveQuizItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime startTime;
  final int durationMinutes;
  final int participantsCount;
  final LiveQuizStatus status;
  final String createdByName;
  final String? createdByAvatar;
  final String? thumbnailUrl;
  final int questionsCount;
  final int rewardCoins;
  final int currentQuestionIndex;
  final int totalQuestions;
  final int entryFeeCoins;
  final bool isArchived;

  const LiveQuizItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startTime,
    required this.durationMinutes,
    required this.participantsCount,
    required this.status,
    this.createdByName = 'Admin',
    this.createdByAvatar,
    this.thumbnailUrl,
    this.questionsCount = 20,
    this.rewardCoins = 500,
    this.entryFeeCoins = 0,
    this.currentQuestionIndex = 1,
    this.totalQuestions = 20,
    this.isArchived = false,
  });

  LiveQuizItem copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? startTime,
    int? durationMinutes,
    int? participantsCount,
    LiveQuizStatus? status,
    String? createdByName,
    String? createdByAvatar,
    String? thumbnailUrl,
    int? questionsCount,
    int? rewardCoins,
    int? entryFeeCoins,
    int? currentQuestionIndex,
    int? totalQuestions,
    bool? isArchived,
  }) {
    return LiveQuizItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      participantsCount: participantsCount ?? this.participantsCount,
      status: status ?? this.status,
      createdByName: createdByName ?? this.createdByName,
      createdByAvatar: createdByAvatar ?? this.createdByAvatar,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      questionsCount: questionsCount ?? this.questionsCount,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      entryFeeCoins: entryFeeCoins ?? this.entryFeeCoins,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  // --- Category Color Tokens ---
  static Color getCategoryBgColor(String category) {
    switch (category.toLowerCase().trim()) {
      case 'railway':
        return const Color(0xFFEFF6FF); // Light blue
      case 'general science':
      case 'science':
        return const Color(0xFFF3F0FF); // Light purple
      case 'mathematics':
      case 'maths':
        return const Color(0xFFFFF1F2); // Light pink
      case 'current affairs':
        return const Color(0xFFFFF7ED); // Light orange
      case 'reasoning':
        return const Color(0xFFECFEFF); // Light cyan
      case 'biology':
        return const Color(0xFFF0FDF4); // Light green
      case 'mixed':
      default:
        return const Color(0xFFF8FAFC); // Neutral slate
    }
  }

  static Color getCategoryTextColor(String category) {
    switch (category.toLowerCase().trim()) {
      case 'railway':
        return const Color(0xFF2563EB); // Vibrant blue
      case 'general science':
      case 'science':
        return const Color(0xFF7C3AED); // Vibrant purple
      case 'mathematics':
      case 'maths':
        return const Color(0xFFE11D48); // Vibrant rose/pink
      case 'current affairs':
        return const Color(0xFFD97706); // Vibrant orange/amber
      case 'reasoning':
        return const Color(0xFF0891B2); // Vibrant cyan
      case 'biology':
        return const Color(0xFF059669); // Vibrant emerald green
      case 'mixed':
      default:
        return const Color(0xFF475569); // Slate grey
    }
  }

  static Color getCategoryBorderColor(String category) {
    switch (category.toLowerCase().trim()) {
      case 'railway':
        return const Color(0xFFBFDBFE);
      case 'general science':
      case 'science':
        return const Color(0xFFDDD6FE);
      case 'mathematics':
      case 'maths':
        return const Color(0xFFFECDD3);
      case 'current affairs':
        return const Color(0xFFFED7AA);
      case 'reasoning':
        return const Color(0xFFA5F3FC);
      case 'biology':
        return const Color(0xFFA7F3D0);
      case 'mixed':
      default:
        return const Color(0xFFE2E8F0);
    }
  }

  // --- Dynamic Computed Status based on Start Time & Duration ---
  LiveQuizStatus get computedStatus {
    if (status == LiveQuizStatus.draft) return LiveQuizStatus.draft;
    if (status == LiveQuizStatus.completed) return LiveQuizStatus.completed;

    final now = DateTime.now();
    final localStart = startTime.toLocal();
    final localEnd = localStart.add(Duration(minutes: durationMinutes));

    if (now.isBefore(localStart)) {
      return LiveQuizStatus.scheduled;
    } else if (now.isAfter(localEnd)) {
      return LiveQuizStatus.completed;
    } else {
      return LiveQuizStatus.liveNow;
    }
  }

  // --- Status Color & Label Helpers ---
  String get statusLabel {
    switch (computedStatus) {
      case LiveQuizStatus.liveNow:
        return 'Live Now';
      case LiveQuizStatus.completed:
        return 'Completed';
      case LiveQuizStatus.scheduled:
        return 'Scheduled';
      case LiveQuizStatus.ongoing:
        return 'Ongoing';
      case LiveQuizStatus.draft:
        return 'Draft';
    }
  }

  Color get statusBgColor {
    switch (computedStatus) {
      case LiveQuizStatus.liveNow:
        return const Color(0xFFEFF6FF); // Soft blue background
      case LiveQuizStatus.completed:
        return const Color(0xFFDCFCE7); // Soft green
      case LiveQuizStatus.scheduled:
        return const Color(0xFFF3E8FF); // Soft purple
      case LiveQuizStatus.ongoing:
        return const Color(0xFFFEF3C7); // Soft amber
      case LiveQuizStatus.draft:
        return const Color(0xFFF1F5F9); // Soft slate
    }
  }

  Color get statusTextColor {
    switch (computedStatus) {
      case LiveQuizStatus.liveNow:
        return const Color(0xFF2563EB); // Blue
      case LiveQuizStatus.completed:
        return const Color(0xFF15803D); // Green
      case LiveQuizStatus.scheduled:
        return const Color(0xFF7E22CE); // Purple
      case LiveQuizStatus.ongoing:
        return const Color(0xFFD97706); // Amber
      case LiveQuizStatus.draft:
        return const Color(0xFF475569); // Slate
    }
  }

  Color get statusBorderColor {
    switch (computedStatus) {
      case LiveQuizStatus.liveNow:
        return const Color(0xFFBFDBFE);
      case LiveQuizStatus.completed:
        return const Color(0xFF86EFAC);
      case LiveQuizStatus.scheduled:
        return const Color(0xFFD8B4FE);
      case LiveQuizStatus.ongoing:
        return const Color(0xFFFDE68A);
      case LiveQuizStatus.draft:
        return const Color(0xFFCBD5E1);
    }
  }

  TestSeriesItem toTestSeriesItem() {
    return TestSeriesItem(
      id: id,
      title: title,
      description: description,
      subject: category,
      examCategoryId: category.toLowerCase(),
      testMode: 'mock',
      totalTests: 1,
      durationMinutes: durationMinutes,
      totalQuestions: questionsCount,
      negativeMarking: 0.25,
      isPremium: entryFeeCoins > 0,
      priceInr: entryFeeCoins,
      isTournament: false,
      entryFeeCoins: entryFeeCoins,
      scheduledStartTime: startTime,
      scheduledEndTime: startTime.add(Duration(minutes: durationMinutes)),
      enrollments: participantsCount,
      status: status == LiveQuizStatus.draft
          ? TestSeriesStatus.draft
          : TestSeriesStatus.published,
      createdAt: startTime,
      icon: Icons.podcasts_rounded,
      iconColor: const Color(0xFF5636F5),
    );
  }

  static List<LiveQuizItem> get sampleItems => const <LiveQuizItem>[];
}
