import 'package:flutter/material.dart';

enum TournamentStatus {
  upcoming,
  ongoing,
  completed,
  archived,
}

extension TournamentStatusExt on TournamentStatus {
  String get label {
    switch (this) {
      case TournamentStatus.upcoming:
        return 'Upcoming';
      case TournamentStatus.ongoing:
        return 'Ongoing';
      case TournamentStatus.completed:
        return 'Completed';
      case TournamentStatus.archived:
        return 'Archived';
    }
  }

  Color get color {
    switch (this) {
      case TournamentStatus.upcoming:
        return const Color(0xFF6B4EFF);
      case TournamentStatus.ongoing:
        return const Color(0xFFFF9F0A);
      case TournamentStatus.completed:
        return const Color(0xFF10B981);
      case TournamentStatus.archived:
        return const Color(0xFF64748B);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TournamentStatus.upcoming:
        return const Color(0xFFF3F0FF);
      case TournamentStatus.ongoing:
        return const Color(0xFFFFFBEB);
      case TournamentStatus.completed:
        return const Color(0xFFECFDF5);
      case TournamentStatus.archived:
        return const Color(0xFFF1F5F9);
    }
  }

  static TournamentStatus fromString(String val) {
    switch (val.toLowerCase().trim()) {
      case 'ongoing':
      case 'live':
        return TournamentStatus.ongoing;
      case 'completed':
      case 'ended':
        return TournamentStatus.completed;
      case 'archived':
      case 'cancelled':
        return TournamentStatus.archived;
      case 'upcoming':
      case 'scheduled':
      default:
        return TournamentStatus.upcoming;
    }
  }
}

class TournamentItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final int entryFee;
  final int participants;
  final TournamentStatus status;
  final int prizePool;
  final Color thumbnailBg;
  final IconData thumbnailIcon;
  final String? imageAsset;
  final int maxParticipants;
  final String description;

  const TournamentItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.entryFee,
    required this.participants,
    required this.status,
    required this.prizePool,
    this.thumbnailBg = const Color(0xFF5636F5),
    this.thumbnailIcon = Icons.emoji_events_rounded,
    this.imageAsset,
    this.maxParticipants = 10000,
    this.description = '',
  });

  TournamentItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int? entryFee,
    int? participants,
    TournamentStatus? status,
    int? prizePool,
    Color? thumbnailBg,
    IconData? thumbnailIcon,
    String? imageAsset,
    int? maxParticipants,
    String? description,
  }) {
    return TournamentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      entryFee: entryFee ?? this.entryFee,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      prizePool: prizePool ?? this.prizePool,
      thumbnailBg: thumbnailBg ?? this.thumbnailBg,
      thumbnailIcon: thumbnailIcon ?? this.thumbnailIcon,
      imageAsset: imageAsset ?? this.imageAsset,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      description: description ?? this.description,
    );
  }

  TournamentStatus get computedStatus {
    if (status == TournamentStatus.archived) return TournamentStatus.archived;
    if (status == TournamentStatus.completed) return TournamentStatus.completed;

    final now = DateTime.now();
    final localStart = startDate.toLocal();
    final localEnd = endDate.toLocal();

    if (now.isBefore(localStart)) {
      return TournamentStatus.upcoming;
    } else if (now.isAfter(localEnd)) {
      return TournamentStatus.completed;
    } else {
      return TournamentStatus.ongoing;
    }
  }

  factory TournamentItem.fromSupabase(Map<String, dynamic> map) {
    final title = map['title']?.toString() ?? 'Tournament Quiz';
    final subtitle = (map['syllabus'] ?? map['description'])?.toString() ?? 'Competitive Quiz Tournament';
    final category = (map['category_id'] ?? map['category'])?.toString() ?? 'General Science';

    final durationMins = (map['duration_minutes'] as num?)?.toInt() ?? 60;

    DateTime start = DateTime.now().add(const Duration(days: 2));
    if (map['scheduled_start_time'] != null) {
      final parsed = DateTime.tryParse(map['scheduled_start_time'].toString());
      if (parsed != null) start = parsed.toLocal();
    }

    DateTime end = start.add(Duration(minutes: durationMins));
    if (map['scheduled_end_time'] != null) {
      final parsed = DateTime.tryParse(map['scheduled_end_time'].toString());
      if (parsed != null) end = parsed.toLocal();
    }

    final entryFee = (map['entry_fee_coins'] is num)
        ? (map['entry_fee_coins'] as num).toInt()
        : 0;

    final participants = (map['total_participants'] is num)
        ? (map['total_participants'] as num).toInt()
        : 0;

    final rawPrize = (map['prize_pool_coins'] is num)
        ? (map['prize_pool_coins'] as num).toInt()
        : ((map['prize_pool'] is num)
            ? (map['prize_pool'] as num).toInt()
            : (entryFee * 10 > 0 ? entryFee * 10 : 10000));

    final statusStr = (map['status'] ?? '').toString().toLowerCase();
    TournamentStatus status = TournamentStatus.upcoming;
    if (statusStr == 'draft' || statusStr == 'archived') {
      status = TournamentStatus.archived;
    } else {
      final now = DateTime.now();
      if (now.isBefore(start)) {
        status = TournamentStatus.upcoming;
      } else if (now.isAfter(end)) {
        status = TournamentStatus.completed;
      } else {
        status = TournamentStatus.ongoing;
      }
    }

    return TournamentItem(
      id: map['id']?.toString() ?? '',
      title: title,
      subtitle: subtitle,
      category: category,
      startDate: start,
      endDate: end,
      entryFee: entryFee,
      participants: participants,
      status: status,
      prizePool: rawPrize,
      thumbnailBg: _getCategoryColor(category),
      thumbnailIcon: _getCategoryIcon(category),
      maxParticipants: (map['max_participants'] is num) ? (map['max_participants'] as num).toInt() : 10000,
      description: subtitle,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'title': title,
      'syllabus': subtitle.isNotEmpty ? subtitle : description,
      'category_id': category,
      'scheduled_start_time': startDate.toUtc().toIso8601String(),
      'scheduled_end_time': endDate.toUtc().toIso8601String(),
      'entry_fee_coins': entryFee,
      'total_participants': participants,
      'status': status == TournamentStatus.archived ? 'draft' : 'published',
      'is_tournament': true,
      'test_mode': 'tournament',
      'max_participants': maxParticipants,
      'duration_minutes': endDate.difference(startDate).inMinutes > 0
          ? endDate.difference(startDate).inMinutes
          : 60,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  static Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase().trim()) {
      case 'railway':
        return const Color(0xFF2587F8);
      case 'general science':
        return const Color(0xFF6B4EFF);
      case 'mathematics':
        return const Color(0xFFF04483);
      case 'current affairs':
        return const Color(0xFFFF9F0A);
      case 'state level':
        return const Color(0xFF00C48C);
      case 'reasoning':
        return const Color(0xFF06B6D4);
      case 'biology':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF5636F5);
    }
  }

  static IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase().trim()) {
      case 'railway':
        return Icons.train_rounded;
      case 'general science':
        return Icons.science_rounded;
      case 'mathematics':
        return Icons.calculate_rounded;
      case 'current affairs':
        return Icons.newspaper_rounded;
      case 'state level':
        return Icons.account_balance_rounded;
      case 'reasoning':
        return Icons.psychology_rounded;
      case 'biology':
        return Icons.biotech_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  /// 7 Pixel-accurate mock tournaments matching the reference specification
  static List<TournamentItem> get mockTournaments => [
    TournamentItem(
      id: 'tour_001',
      title: 'RRB Technician Grand Quiz',
      subtitle: 'All India Live Quiz Tournament',
      category: 'Railway',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 2, hours: 2)),
      entryFee: 0,
      participants: 3240,
      status: TournamentStatus.upcoming,
      prizePool: 50000,
      thumbnailBg: const Color(0xFF1E40AF),
      thumbnailIcon: Icons.train_rounded,
    ),
    TournamentItem(
      id: 'tour_002',
      title: 'General Science Champion',
      subtitle: 'Science Special Tournament',
      category: 'General Science',
      startDate: DateTime.now().subtract(const Duration(minutes: 30)),
      endDate: DateTime.now().add(const Duration(hours: 1)),
      entryFee: 10,
      participants: 2120,
      status: TournamentStatus.ongoing,
      prizePool: 25000,
      thumbnailBg: const Color(0xFF7C3AED),
      thumbnailIcon: Icons.science_rounded,
    ),
    TournamentItem(
      id: 'tour_003',
      title: 'Maths Master Tournament',
      subtitle: 'Speed & Accuracy Challenge',
      category: 'Mathematics',
      startDate: DateTime(2026, 10, 18, 17, 0),
      endDate: DateTime(2026, 10, 18, 19, 0),
      entryFee: 0,
      participants: 4850,
      status: TournamentStatus.completed,
      prizePool: 30000,
      thumbnailBg: const Color(0xFFE11D48),
      thumbnailIcon: Icons.calculate_rounded,
    ),
    TournamentItem(
      id: 'tour_004',
      title: 'Current Affairs Cup',
      subtitle: 'Daily Current Affairs Quiz',
      category: 'Current Affairs',
      startDate: DateTime(2026, 10, 15, 20, 0),
      endDate: DateTime(2026, 10, 15, 21, 30),
      entryFee: 5,
      participants: 1940,
      status: TournamentStatus.completed,
      prizePool: 15000,
      thumbnailBg: const Color(0xFFD97706),
      thumbnailIcon: Icons.newspaper_rounded,
    ),
    TournamentItem(
      id: 'tour_005',
      title: 'Bihar State Mega Quiz',
      subtitle: 'Bihar Special Tournament',
      category: 'State Level',
      startDate: DateTime(2026, 10, 12, 19, 0),
      endDate: DateTime(2026, 10, 12, 21, 0),
      entryFee: 20,
      participants: 2680,
      status: TournamentStatus.completed,
      prizePool: 40000,
      thumbnailBg: const Color(0xFF059669),
      thumbnailIcon: Icons.account_balance_rounded,
    ),
    TournamentItem(
      id: 'tour_006',
      title: 'Reasoning Challenge',
      subtitle: 'Logic & Reasoning Quiz',
      category: 'Reasoning',
      startDate: DateTime(2026, 10, 10, 18, 30),
      endDate: DateTime(2026, 10, 10, 20, 0),
      entryFee: 10,
      participants: 980,
      status: TournamentStatus.archived,
      prizePool: 10000,
      thumbnailBg: const Color(0xFF0891B2),
      thumbnailIcon: Icons.psychology_rounded,
    ),
    TournamentItem(
      id: 'tour_007',
      title: 'Biology Battle',
      subtitle: 'Cell & Human Biology Quiz',
      category: 'Biology',
      startDate: DateTime(2026, 10, 5, 19, 0),
      endDate: DateTime(2026, 10, 5, 20, 30),
      entryFee: 0,
      participants: 640,
      status: TournamentStatus.archived,
      prizePool: 5000,
      thumbnailBg: const Color(0xFF10B981),
      thumbnailIcon: Icons.biotech_rounded,
    ),
  ];
}
