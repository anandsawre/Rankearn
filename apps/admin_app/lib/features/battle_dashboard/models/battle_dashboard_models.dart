import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

enum BattleType {
  oneVOne,
  multiplayer,
  room,
}

extension BattleTypeExtension on BattleType {
  String get label {
    switch (this) {
      case BattleType.oneVOne:
        return '1 vs 1';
      case BattleType.multiplayer:
        return 'Multiplayer';
      case BattleType.room:
        return 'Room';
    }
  }

  Color get color {
    switch (this) {
      case BattleType.oneVOne:
        return AppColors.battleAdminPurple;
      case BattleType.multiplayer:
        return AppColors.coinGold;
      case BattleType.room:
        return AppColors.brandBlue;
    }
  }

  Color get bgColor {
    switch (this) {
      case BattleType.oneVOne:
        return AppColors.brandPurpleLight;
      case BattleType.multiplayer:
        return AppColors.coinGoldLight;
      case BattleType.room:
        return AppColors.brandBlueLight;
    }
  }
}

enum BattleStatus {
  waiting,
  live,
  paused,
  completed,
  cancelled,
}

extension BattleStatusExtension on BattleStatus {
  String get label {
    switch (this) {
      case BattleStatus.waiting:
        return 'Waiting';
      case BattleStatus.live:
        return 'Live';
      case BattleStatus.paused:
        return 'Paused';
      case BattleStatus.completed:
        return 'Completed';
      case BattleStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case BattleStatus.live:
        return AppColors.liveRed;
      case BattleStatus.waiting:
        return AppColors.warning;
      case BattleStatus.paused:
        return AppColors.brandOrange;
      case BattleStatus.completed:
        return AppColors.brandGreen;
      case BattleStatus.cancelled:
        return AppColors.textMuted;
    }
  }
}

class BattleParticipant {
  final String id;
  final String name;
  final String avatarUrl;
  final int score;
  final int rank;
  final int correctAnswers;
  final bool isConnected;

  const BattleParticipant({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.score = 0,
    this.rank = 1,
    this.correctAnswers = 0,
    this.isConnected = true,
  });

  BattleParticipant copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    int? score,
    int? rank,
    int? correctAnswers,
    bool? isConnected,
  }) {
    return BattleParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      score: score ?? this.score,
      rank: rank ?? this.rank,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class BattleItem {
  final String id;
  final String title;
  final BattleType type;
  final BattleStatus status;
  final String subject;
  final String category;
  final List<BattleParticipant> participants;
  final int totalPlayers;
  final int maxPlayers;
  final int timeRemainingSeconds;
  final int totalDurationSeconds;
  final int entryFee;
  final int prizePool;
  final String? roomName;
  final String? roomCode;
  final int currentQuestion;
  final int totalQuestions;
  final DateTime createdAt;

  const BattleItem({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.subject,
    required this.category,
    required this.participants,
    required this.totalPlayers,
    required this.maxPlayers,
    required this.timeRemainingSeconds,
    required this.totalDurationSeconds,
    required this.entryFee,
    required this.prizePool,
    this.roomName,
    this.roomCode,
    this.currentQuestion = 1,
    this.totalQuestions = 5,
    required this.createdAt,
  });

  String get formattedTimeLeft {
    final m = (timeRemainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (timeRemainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  BattleItem copyWith({
    String? id,
    String? title,
    BattleType? type,
    BattleStatus? status,
    String? subject,
    String? category,
    List<BattleParticipant>? participants,
    int? totalPlayers,
    int? maxPlayers,
    int? timeRemainingSeconds,
    int? totalDurationSeconds,
    int? entryFee,
    int? prizePool,
    String? roomName,
    String? roomCode,
    int? currentQuestion,
    int? totalQuestions,
    DateTime? createdAt,
  }) {
    return BattleItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      subject: subject ?? this.subject,
      category: category ?? this.category,
      participants: participants ?? this.participants,
      totalPlayers: totalPlayers ?? this.totalPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      timeRemainingSeconds: timeRemainingSeconds ?? this.timeRemainingSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      entryFee: entryFee ?? this.entryFee,
      prizePool: prizePool ?? this.prizePool,
      roomName: roomName ?? this.roomName,
      roomCode: roomCode ?? this.roomCode,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class OngoingRoomItem {
  final String id;
  final String name;
  final String code;
  final int currentPlayers;
  final int maxPlayers;
  final String subject;
  final BattleStatus status;
  final int entryFee;
  final int prizePool;

  const OngoingRoomItem({
    required this.id,
    required this.name,
    required this.code,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.subject,
    required this.status,
    required this.entryFee,
    required this.prizePool,
  });

  OngoingRoomItem copyWith({
    String? id,
    String? name,
    String? code,
    int? currentPlayers,
    int? maxPlayers,
    String? subject,
    BattleStatus? status,
    int? entryFee,
    int? prizePool,
  }) {
    return OngoingRoomItem(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      subject: subject ?? this.subject,
      status: status ?? this.status,
      entryFee: entryFee ?? this.entryFee,
      prizePool: prizePool ?? this.prizePool,
    );
  }
}

class PlayerBattleRecord {
  final String id;
  final String username;
  final String avatarUrl;
  final String rank;
  final int totalBattles;
  final int wins;
  final int losses;
  final int winRate;
  final int coins;
  final String status; // active, restricted, suspended
  final DateTime joinedAt;

  const PlayerBattleRecord({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.rank,
    required this.totalBattles,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.coins,
    required this.status,
    required this.joinedAt,
  });

  PlayerBattleRecord copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? rank,
    int? totalBattles,
    int? wins,
    int? losses,
    int? winRate,
    int? coins,
    String? status,
    DateTime? joinedAt,
  }) {
    return PlayerBattleRecord(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rank: rank ?? this.rank,
      totalBattles: totalBattles ?? this.totalBattles,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      winRate: winRate ?? this.winRate,
      coins: coins ?? this.coins,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

class BattleSettingsData {
  final int matchmakingTimeout;
  final double botAccuracy;
  final bool botFallback;
  final int minEntryFee;
  final int maxEntryFee;
  final double prizeMultiplier;
  final int defaultQuestions;
  final int defaultQuestionTime;
  final int maxRoomCapacity;
  final double speedCheckThreshold;
  final bool maintenanceMode;

  const BattleSettingsData({
    this.matchmakingTimeout = 10,
    this.botAccuracy = 0.65,
    this.botFallback = true,
    this.minEntryFee = 10,
    this.maxEntryFee = 500,
    this.prizeMultiplier = 1.8,
    this.defaultQuestions = 5,
    this.defaultQuestionTime = 10,
    this.maxRoomCapacity = 100,
    this.speedCheckThreshold = 1.2,
    this.maintenanceMode = false,
  });

  BattleSettingsData copyWith({
    int? matchmakingTimeout,
    double? botAccuracy,
    bool? botFallback,
    int? minEntryFee,
    int? maxEntryFee,
    double? prizeMultiplier,
    int? defaultQuestions,
    int? defaultQuestionTime,
    int? maxRoomCapacity,
    double? speedCheckThreshold,
    bool? maintenanceMode,
  }) {
    return BattleSettingsData(
      matchmakingTimeout: matchmakingTimeout ?? this.matchmakingTimeout,
      botAccuracy: botAccuracy ?? this.botAccuracy,
      botFallback: botFallback ?? this.botFallback,
      minEntryFee: minEntryFee ?? this.minEntryFee,
      maxEntryFee: maxEntryFee ?? this.maxEntryFee,
      prizeMultiplier: prizeMultiplier ?? this.prizeMultiplier,
      defaultQuestions: defaultQuestions ?? this.defaultQuestions,
      defaultQuestionTime: defaultQuestionTime ?? this.defaultQuestionTime,
      maxRoomCapacity: maxRoomCapacity ?? this.maxRoomCapacity,
      speedCheckThreshold: speedCheckThreshold ?? this.speedCheckThreshold,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
    );
  }
}

