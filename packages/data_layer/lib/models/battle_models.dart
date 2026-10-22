/// Domain models for the 1v1 Quiz Battle system.
class BattleStatsModel {
  final int playersOnline;
  final int battlesPlayed;
  final int yourWins;
  final int winRatePercent;

  const BattleStatsModel({
    this.playersOnline = 2468,
    this.battlesPlayed = 12540,
    this.yourWins = 186,
    this.winRatePercent = 72,
  });

  factory BattleStatsModel.fromJson(Map<String, dynamic> json) {
    return BattleStatsModel(
      playersOnline: json['players_online'] as int? ?? 2468,
      battlesPlayed: json['battles_played'] as int? ?? 12540,
      yourWins: json['your_wins'] as int? ?? 186,
      winRatePercent: json['win_rate_percent'] as int? ?? 72,
    );
  }

  Map<String, dynamic> toJson() => {
        'players_online': playersOnline,
        'battles_played': battlesPlayed,
        'your_wins': yourWins,
        'win_rate_percent': winRatePercent,
      };
}

class BattlePlayerModel {
  final int rank;
  final String id;
  final String name;
  final int score;
  final String? avatarUrl;

  const BattlePlayerModel({
    required this.rank,
    required this.id,
    required this.name,
    required this.score,
    this.avatarUrl,
  });

  factory BattlePlayerModel.fromJson(Map<String, dynamic> json) {
    return BattlePlayerModel(
      rank: json['rank'] as int? ?? 1,
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Player',
      score: json['score'] as int? ?? 0,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'id': id,
        'name': name,
        'score': score,
        'avatar_url': avatarUrl,
      };
}

class BattleMissionModel {
  final String id;
  final String title;
  final String iconKey;
  final int currentProgress;
  final int targetProgress;
  final int rewardCoins;
  final bool isClaimed;

  const BattleMissionModel({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.currentProgress,
    required this.targetProgress,
    required this.rewardCoins,
    this.isClaimed = false,
  });

  BattleMissionModel copyWith({
    String? id,
    String? title,
    String? iconKey,
    int? currentProgress,
    int? targetProgress,
    int? rewardCoins,
    bool? isClaimed,
  }) {
    return BattleMissionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      iconKey: iconKey ?? this.iconKey,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  factory BattleMissionModel.fromJson(Map<String, dynamic> json) {
    return BattleMissionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      iconKey: json['icon_key'] as String? ?? 'swords',
      currentProgress: json['current_progress'] as int? ?? 0,
      targetProgress: json['target_progress'] as int? ?? 1,
      rewardCoins: json['reward_coins'] as int? ?? 100,
      isClaimed: json['is_claimed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'icon_key': iconKey,
        'current_progress': currentProgress,
        'target_progress': targetProgress,
        'reward_coins': rewardCoins,
        'is_claimed': isClaimed,
      };
}

class BattleHistoryItemModel {
  final String id;
  final String opponentName;
  final String dateString;
  final String result; // 'Won', 'Lost', 'Draw'
  final int myScore;
  final int opponentScore;
  final int coinsDelta;
  final String battleType;

  const BattleHistoryItemModel({
    required this.id,
    required this.opponentName,
    required this.dateString,
    required this.result,
    required this.myScore,
    required this.opponentScore,
    required this.coinsDelta,
    required this.battleType,
  });

  factory BattleHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return BattleHistoryItemModel(
      id: json['id'] as String? ?? '',
      opponentName: json['opponent_name'] as String? ?? 'Opponent',
      dateString: json['date_string'] as String? ?? 'Today',
      result: json['result'] as String? ?? 'Won',
      myScore: json['my_score'] as int? ?? 0,
      opponentScore: json['opponent_score'] as int? ?? 0,
      coinsDelta: json['coins_delta'] as int? ?? 0,
      battleType: json['battle_type'] as String? ?? 'Quick Battle',
    );
  }
}
