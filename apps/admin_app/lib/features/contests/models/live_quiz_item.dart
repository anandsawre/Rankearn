import 'package:flutter/material.dart';

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

  static List<LiveQuizItem> get sampleItems {
    return [
      LiveQuizItem(
        id: 'lq-001',
        title: 'RRB Technician Mega Quiz',
        description: 'Live quiz for RRB Technician',
        category: 'Railway',
        startTime: DateTime(2026, 10, 18, 19, 0),
        durationMinutes: 60,
        participantsCount: 1240,
        status: LiveQuizStatus.completed,
        createdByName: 'Admin',
        rewardCoins: 1500,
        questionsCount: 30,
      ),
      LiveQuizItem(
        id: 'lq-002',
        title: 'General Science Live Quiz',
        description: 'Science special live quiz',
        category: 'General Science',
        startTime: DateTime(2026, 10, 17, 20, 0),
        durationMinutes: 45,
        participantsCount: 980,
        status: LiveQuizStatus.completed,
        createdByName: 'Admin',
        rewardCoins: 1000,
        questionsCount: 25,
      ),
      LiveQuizItem(
        id: 'lq-003',
        title: 'Maths Challenge Live',
        description: 'Speed and accuracy test',
        category: 'Mathematics',
        startTime: DateTime(2026, 10, 16, 19, 30),
        durationMinutes: 30,
        participantsCount: 1850,
        status: LiveQuizStatus.completed,
        createdByName: 'Admin',
        rewardCoins: 2000,
        questionsCount: 20,
      ),
      LiveQuizItem(
        id: 'lq-004',
        title: 'Current Affairs Live Quiz',
        description: 'Daily current affairs',
        category: 'Current Affairs',
        startTime: DateTime.now().subtract(const Duration(minutes: 15)),
        durationMinutes: 45,
        participantsCount: 2340,
        status: LiveQuizStatus.liveNow,
        createdByName: 'Admin',
        rewardCoins: 2500,
        questionsCount: 25,
        currentQuestionIndex: 12,
      ),
      LiveQuizItem(
        id: 'lq-005',
        title: 'Reasoning Power Quiz',
        description: 'Logic and reasoning test',
        category: 'Reasoning',
        startTime: DateTime.now().add(const Duration(days: 1)),
        durationMinutes: 60,
        participantsCount: 1120,
        status: LiveQuizStatus.scheduled,
        createdByName: 'Admin',
        rewardCoins: 1200,
        questionsCount: 30,
      ),
      LiveQuizItem(
        id: 'lq-006',
        title: 'Biology Live Quiz',
        description: 'Cell & Human Biology',
        category: 'Biology',
        startTime: DateTime(2026, 10, 13, 18, 30),
        durationMinutes: 45,
        participantsCount: 860,
        status: LiveQuizStatus.completed,
        createdByName: 'Admin',
        rewardCoins: 1000,
        questionsCount: 25,
      ),
      LiveQuizItem(
        id: 'lq-007',
        title: 'Mixed Topics Grand Quiz',
        description: 'Full syllabus live quiz',
        category: 'Mixed',
        startTime: DateTime(2026, 10, 12, 20, 0),
        durationMinutes: 60,
        participantsCount: 3450,
        status: LiveQuizStatus.ongoing,
        createdByName: 'Admin',
        rewardCoins: 5000,
        questionsCount: 40,
        currentQuestionIndex: 18,
      ),
    ];
  }
}
