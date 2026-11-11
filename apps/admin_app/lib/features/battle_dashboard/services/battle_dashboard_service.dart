import 'package:flutter/foundation.dart';
import 'package:data_layer/data_layer.dart';
import '../models/battle_dashboard_models.dart';

class BattleTimeSeriesData {
  final List<String> labels;
  final List<double> values;
  final int? highlightedIndex;
  final String? tooltipValue;

  const BattleTimeSeriesData({
    this.labels = const [],
    this.values = const [],
    this.highlightedIndex,
    this.tooltipValue,
  });
}

class BattleReportSummary {
  final int totalMatches;
  final int totalCoinVolume;
  final int platformRakeCoins;
  final double completionRatePct;
  final int oneVsOneMatches;
  final int multiplayerMatches;
  final int customRoomsCount;
  final List<({String windowLabel, int matchCount})> topPeakWindows;
  final List<BattleItem> filteredBattles;

  const BattleReportSummary({
    required this.totalMatches,
    required this.totalCoinVolume,
    required this.platformRakeCoins,
    required this.completionRatePct,
    required this.oneVsOneMatches,
    required this.multiplayerMatches,
    required this.customRoomsCount,
    required this.topPeakWindows,
    required this.filteredBattles,
  });
}

class BattleDashboardService extends ChangeNotifier {
  static final BattleDashboardService _instance = BattleDashboardService._internal();
  factory BattleDashboardService() => _instance;
  BattleDashboardService._internal();

  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  bool _hasDbConnection = SupabaseConfig.isInitialized;
  bool _hasPersistedSettings = false;
  String? _errorMessage;
  DateTime? _lastSyncedAt;

  List<BattleItem> _battles = [];
  final List<OngoingRoomItem> _ongoingRooms = [];
  List<PlayerBattleRecord> _players = [];
  List<Map<String, dynamic>> _auditLogs = [];
  BattleSettingsData _settings = const BattleSettingsData();

  int _battleQuestionsCount = 0;
  Map<String, int> _questionTopicCounts = {};
  int _totalBattleWinPayouts = 0;

  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;
  bool get hasDbConnection => _hasDbConnection;
  bool get hasPersistedSettings => _hasPersistedSettings;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  List<BattleItem> get battles => List.unmodifiable(_battles);
  List<OngoingRoomItem> get ongoingRooms => List.unmodifiable(_ongoingRooms);
  List<PlayerBattleRecord> get players => List.unmodifiable(_players);
  List<Map<String, dynamic>> get auditLogs => List.unmodifiable(_auditLogs);
  BattleSettingsData get settings => _settings;

  int get battleQuestionsCount => _battleQuestionsCount;
  Map<String, int> get questionTopicCounts => Map.unmodifiable(_questionTopicCounts);
  int get totalBattleWinPayouts => _totalBattleWinPayouts;

  // ==========================================
  // DERIVED REAL METRICS (NO HARDCODED COUNTS)
  // ==========================================
  int get liveBattlesCount => _battles.where((b) => b.status == BattleStatus.live).length;
  int get waitingBattlesCount => _battles.where((b) => b.status == BattleStatus.waiting).length;
  int get completedBattlesCount => _battles.where((b) => b.status == BattleStatus.completed).length;
  int get cancelledBattlesCount => _battles.where((b) => b.status == BattleStatus.cancelled).length;

  int get oneVsOneCount => _battles.where((b) => b.type == BattleType.oneVOne).length;
  int get multiplayerCount => _battles.where((b) => b.type == BattleType.multiplayer).length;
  int get activeRoomsCount => _ongoingRooms.length;

  int get activePlayersCount =>
      _players.where((p) => p.status.toLowerCase() == 'active').length;

  int get todayJoinedPlayersCount {
    final now = DateTime.now();
    return _players.where((p) => _isSameLocalDay(p.joinedAt, now)).length;
  }

  int get todayBattlesCount {
    final now = DateTime.now();
    return _battles.where((b) => _isSameLocalDay(b.createdAt, now)).length;
  }

  int get todayParticipantsCount {
    final now = DateTime.now();
    final ids = <String>{};
    for (final b in _battles) {
      if (_isSameLocalDay(b.createdAt, now)) {
        for (final p in b.participants) {
          ids.add(p.id);
        }
      }
    }
    return ids.length;
  }

  double get completionRatePct {
    final closed = completedBattlesCount + cancelledBattlesCount;
    if (closed == 0) return 0;
    return (completedBattlesCount / closed) * 100;
  }

  List<double> get sevenDayPlayersSparkline =>
      _buildDailySparkline(_players.map((p) => p.joinedAt));

  List<double> get sevenDayBattlesSparkline =>
      _buildDailySparkline(_battles.map((b) => b.createdAt));

  String get playersGrowthLabel => _computeTodayVsYesterdayGrowth(
        _players.map((p) => p.joinedAt),
      );

  String get battlesGrowthLabel => _computeTodayVsYesterdayGrowth(
        _battles.map((b) => b.createdAt),
      );

  String get participantsGrowthLabel {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final todayIds = <String>{};
    final yesterdayIds = <String>{};
    for (final b in _battles) {
      if (_isSameLocalDay(b.createdAt, now)) {
        todayIds.addAll(b.participants.map((p) => p.id));
      } else if (_isSameLocalDay(b.createdAt, yesterday)) {
        yesterdayIds.addAll(b.participants.map((p) => p.id));
      }
    }
    return _formatDayDelta(todayIds.length, yesterdayIds.length);
  }

  BattleTimeSeriesData buildActivityChartSeries() {
    if (_battles.isEmpty) {
      return const BattleTimeSeriesData();
    }

    // Group battles by local calendar day over the last 7 days so the chart
    // always reflects genuine historical & today's activity from Supabase.
    final now = DateTime.now();
    final labels = <String>[];
    final values = <double>[];
    int peakIndex = 0;
    double peakValue = -1;

    for (int offset = 6; offset >= 0; offset--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: offset));
      final participants = <String>{};
      for (final b in _battles) {
        if (_isSameLocalDay(b.createdAt, day)) {
          participants.addAll(b.participants.map((p) => p.id));
        }
      }
      final count = participants.length.toDouble();
      labels.add(offset == 0 ? 'Today' : '${_monthShort(day.month)} ${day.day}');
      values.add(count);
      if (count >= peakValue) {
        peakValue = count;
        peakIndex = values.length - 1;
      }
    }

    final activeNow = _battles
        .where((b) => b.status == BattleStatus.live || b.status == BattleStatus.waiting)
        .expand((b) => b.participants.map((p) => p.id))
        .toSet()
        .length;

    return BattleTimeSeriesData(
      labels: labels,
      values: values,
      highlightedIndex: peakValue > 0 ? peakIndex : null,
      tooltipValue: activeNow > 0
          ? '$activeNow Active Now'
          : (peakValue > 0 ? '${peakValue.toInt()} Players' : null),
    );
  }

  BattleReportSummary buildReportSummary(String timeRange) {
    final now = DateTime.now();
    DateTime? cutoff;
    if (timeRange == 'Today') {
      cutoff = DateTime(now.year, now.month, now.day);
    } else if (timeRange == 'Last 7 Days') {
      cutoff = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    } else if (timeRange == 'Last 30 Days') {
      cutoff = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
    }

    final filtered = _battles.where((b) {
      if (cutoff == null) return true;
      return !b.createdAt.toLocal().isBefore(cutoff);
    }).toList();

    int totalCoinVolume = 0;
    int estimatedPaidOut = 0;
    int completed = 0;
    int cancelled = 0;
    int oneVsOne = 0;
    int multiplayer = 0;
    int rooms = 0;

    final hourlyCounts = <int, int>{};

    for (final b in filtered) {
      final playerSeats = b.participants.length > 1 ? b.participants.length : 1;
      final pot = b.entryFee * playerSeats;
      totalCoinVolume += pot;

      if (b.status == BattleStatus.completed) {
        completed++;
        estimatedPaidOut += b.winnerId != null ? b.prizePool : pot;
      } else if (b.status == BattleStatus.cancelled) {
        cancelled++;
        estimatedPaidOut += pot; // cancelled matches refund entry fees
      }

      switch (b.type) {
        case BattleType.oneVOne:
          oneVsOne++;
          break;
        case BattleType.multiplayer:
          multiplayer++;
          break;
        case BattleType.room:
          rooms++;
          break;
      }

      final hour = b.createdAt.toLocal().hour;
      hourlyCounts[hour] = (hourlyCounts[hour] ?? 0) + 1;
    }

    final closed = completed + cancelled;
    final completionRate = closed == 0 ? 0.0 : (completed / closed) * 100.0;
    final rake = (totalCoinVolume - estimatedPaidOut).clamp(0, totalCoinVolume);

    final sortedHours = hourlyCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final peakWindows = sortedHours.take(3).map((e) {
      return (
        windowLabel: '${_formatHour(e.key)} - ${_formatHour((e.key + 1) % 24)}',
        matchCount: e.value,
      );
    }).toList();

    return BattleReportSummary(
      totalMatches: filtered.length,
      totalCoinVolume: totalCoinVolume,
      platformRakeCoins: rake,
      completionRatePct: completionRate,
      oneVsOneMatches: oneVsOne,
      multiplayerMatches: multiplayer,
      customRoomsCount: rooms,
      topPeakWindows: peakWindows,
      filteredBattles: filtered,
    );
  }

  String buildCsvReport(String timeRange) {
    final summary = buildReportSummary(timeRange);
    final buffer = StringBuffer();
    buffer.writeln(
      'battle_id,type,status,entry_fee,prize_pool,creator_id,opponent_id,winner_id,created_at,completed_at',
    );
    for (final b in summary.filteredBattles) {
      buffer.writeln(
        [
          _csvEscape(b.id),
          _csvEscape(b.type.label),
          _csvEscape(b.status.label),
          b.entryFee,
          b.prizePool,
          _csvEscape(b.creatorId ?? ''),
          _csvEscape(b.opponentId ?? ''),
          _csvEscape(b.winnerId ?? ''),
          _csvEscape(b.createdAt.toUtc().toIso8601String()),
          _csvEscape(b.completedAt?.toUtc().toIso8601String() ?? ''),
        ].join(','),
      );
    }
    return buffer.toString();
  }

  // ==========================================
  // LIVE SUPABASE FETCH
  // ==========================================
  Future<void> ensureLoaded() async {
    if (_hasLoadedOnce || _isLoading) return;
    await refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      _hasDbConnection = false;
      _isLoading = false;
      _hasLoadedOnce = true;
      _errorMessage = 'Database connection is not initialized.';
      notifyListeners();
      return;
    }

    _hasDbConnection = true;

    try {
      final results = await Future.wait<dynamic>([
        client
            .from('battles')
            .select(
              'id, creator_id, opponent_id, entry_fee, status, winner_id, creator_score, opponent_score, created_at, completed_at',
            )
            .order('created_at', ascending: false)
            .limit(500),
        client
            .from('profiles')
            .select(
              'id, name, email, profile_photo_url, coins, status, ban_reason, ban_until, created_at',
            )
            .order('created_at', ascending: false)
            .limit(500),
        client
            .from('battle_questions')
            .select('id, topic')
            .limit(1000),
        client
            .from('wallet_transactions')
            .select('id, user_id, amount, type, category, reference_id, title, created_at')
            .inFilter('category', ['battle_win', 'battle_refund'])
            .order('created_at', ascending: false)
            .limit(200),
        client
            .from('app_configs')
            .select('key, value, updated_at')
            .inFilter('key', ['battle_settings', 'battle_admin_audit_logs']),
      ]);

      final battleRows = List<Map<String, dynamic>>.from(results[0] as List);
      final profileRows = List<Map<String, dynamic>>.from(results[1] as List);
      final questionRows = List<Map<String, dynamic>>.from(results[2] as List);
      final walletRows = List<Map<String, dynamic>>.from(results[3] as List);
      final configRows = List<Map<String, dynamic>>.from(results[4] as List);

      // Parse persisted configs first so prizeMultiplier & auditLogs are accurate.
      BattleSettingsData loadedSettings = const BattleSettingsData();
      bool hasSavedSettings = false;
      List<Map<String, dynamic>> loadedAuditLogs = [];

      for (final row in configRows) {
        final key = row['key']?.toString();
        final value = row['value'];
        if (key == 'battle_settings' && value is Map) {
          loadedSettings = BattleSettingsData.fromJson(
            Map<String, dynamic>.from(value),
          );
          hasSavedSettings = true;
        } else if (key == 'battle_admin_audit_logs' && value is Map) {
          final entries = value['logs'];
          if (entries is List) {
            loadedAuditLogs = entries
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          }
        }
      }

      // Parse question bank summary.
      final topicCounts = <String, int>{};
      for (final q in questionRows) {
        final topic = (q['topic']?.toString().trim().isNotEmpty ?? false)
            ? q['topic'].toString().trim()
            : 'General';
        topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
      }

      final defaultSubject = topicCounts.length == 1
          ? topicCounts.keys.first
          : (topicCounts.isEmpty ? 'General' : 'Mixed Topics');

      // Index profiles by id.
      final profileMap = <String, Map<String, dynamic>>{};
      for (final p in profileRows) {
        final id = p['id']?.toString();
        if (id != null && id.isNotEmpty) {
          profileMap[id] = p;
        }
      }

      // Index actual battle_win payouts by reference_id.
      final payoutByBattleId = <String, int>{};
      int totalWinPayouts = 0;
      for (final tx in walletRows) {
        if (tx['category']?.toString() == 'battle_win') {
          final amount = (tx['amount'] as num?)?.toInt() ?? 0;
          totalWinPayouts += amount;
          final refId = tx['reference_id']?.toString();
          if (refId != null && refId.isNotEmpty) {
            payoutByBattleId[refId] = (payoutByBattleId[refId] ?? 0) + amount;
          }
        }
      }

      // Build battles + per-player battle stats.
      final playerTotalBattles = <String, int>{};
      final playerWins = <String, int>{};
      final playerLosses = <String, int>{};

      final parsedBattles = battleRows.map((row) {
        final id = row['id']?.toString() ?? '';
        final creatorId = row['creator_id']?.toString() ?? '';
        final opponentId = row['opponent_id']?.toString();
        final winnerId = row['winner_id']?.toString();
        final entryFee = (row['entry_fee'] as num?)?.toInt() ?? 0;
        final creatorScore = (row['creator_score'] as num?)?.toInt() ?? 0;
        final opponentScore = (row['opponent_score'] as num?)?.toInt() ?? 0;
        final status = _parseDbStatus(row['status']?.toString());
        final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '') ??
            DateTime.now();
        final completedAt = row['completed_at'] != null
            ? DateTime.tryParse(row['completed_at'].toString())
            : null;

        final participants = <BattleParticipant>[];
        if (creatorId.isNotEmpty) {
          final cp = profileMap[creatorId];
          final cName = (cp?['name']?.toString().trim().isNotEmpty ?? false)
              ? cp!['name'].toString()
              : _shortId(creatorId);
          final cAvatar = cp?['profile_photo_url']?.toString() ?? '';
          participants.add(
            BattleParticipant(
              id: creatorId,
              name: cName,
              avatarUrl: cAvatar,
              score: creatorScore,
              rank: (opponentId != null && opponentScore > creatorScore) ? 2 : 1,
              correctAnswers: creatorScore,
            ),
          );

          playerTotalBattles[creatorId] = (playerTotalBattles[creatorId] ?? 0) + 1;
          if (status == BattleStatus.completed && winnerId != null && winnerId.isNotEmpty) {
            if (winnerId == creatorId) {
              playerWins[creatorId] = (playerWins[creatorId] ?? 0) + 1;
            } else {
              playerLosses[creatorId] = (playerLosses[creatorId] ?? 0) + 1;
            }
          }
        }

        if (opponentId != null && opponentId.isNotEmpty) {
          final op = profileMap[opponentId];
          final oName = (op?['name']?.toString().trim().isNotEmpty ?? false)
              ? op!['name'].toString()
              : _shortId(opponentId);
          final oAvatar = op?['profile_photo_url']?.toString() ?? '';
          participants.add(
            BattleParticipant(
              id: opponentId,
              name: oName,
              avatarUrl: oAvatar,
              score: opponentScore,
              rank: opponentScore > creatorScore ? 1 : 2,
              correctAnswers: opponentScore,
            ),
          );

          playerTotalBattles[opponentId] = (playerTotalBattles[opponentId] ?? 0) + 1;
          if (status == BattleStatus.completed && winnerId != null && winnerId.isNotEmpty) {
            if (winnerId == opponentId) {
              playerWins[opponentId] = (playerWins[opponentId] ?? 0) + 1;
            } else {
              playerLosses[opponentId] = (playerLosses[opponentId] ?? 0) + 1;
            }
          }
        }

        final prizePool = payoutByBattleId[id] ??
            (entryFee * loadedSettings.prizeMultiplier).round();

        final creatorName = participants.isNotEmpty ? participants.first.name : 'Player';
        final title = participants.length >= 2
            ? '$creatorName vs ${participants[1].name}'
            : '$creatorName (Queue)';

        return BattleItem(
          id: id,
          title: title,
          type: BattleType.oneVOne,
          status: status,
          subject: defaultSubject,
          category: '1 vs 1 Arena',
          participants: participants,
          totalPlayers: participants.length,
          maxPlayers: 2,
          entryFee: entryFee,
          prizePool: prizePool,
          currentQuestion: 0,
          totalQuestions: questionRows.length,
          createdAt: createdAt,
          completedAt: completedAt,
          creatorId: creatorId,
          opponentId: opponentId,
          winnerId: winnerId,
        );
      }).toList();

      // Build player battle records sorted by activity/wins/coins.
      final parsedPlayers = profileRows.map((p) {
        final id = p['id']?.toString() ?? '';
        final total = playerTotalBattles[id] ?? 0;
        final wins = playerWins[id] ?? 0;
        final losses = playerLosses[id] ?? 0;
        final winRate = total == 0 ? 0 : ((wins / total) * 100).round();
        final coins = (p['coins'] as num?)?.toInt() ?? 0;
        final status = p['status']?.toString() ?? 'active';
        final joinedAt = DateTime.tryParse(p['created_at']?.toString() ?? '') ??
            DateTime.now();
        final banUntil = p['ban_until'] != null
            ? DateTime.tryParse(p['ban_until'].toString())
            : null;

        return PlayerBattleRecord(
          id: id,
          username: (p['name']?.toString().trim().isNotEmpty ?? false)
              ? p['name'].toString()
              : 'User ${_shortId(id)}',
          email: p['email']?.toString() ?? '',
          avatarUrl: p['profile_photo_url']?.toString() ?? '',
          rank: total > 0 ? 'Pending Rank' : 'Unranked',
          totalBattles: total,
          wins: wins,
          losses: losses,
          winRate: winRate,
          coins: coins,
          status: status,
          banReason: p['ban_reason']?.toString(),
          banUntil: banUntil,
          joinedAt: joinedAt,
        );
      }).toList();

      // Assign deterministic leaderboard ranks based on wins & total battles.
      parsedPlayers.sort((a, b) {
        final cmpWins = b.wins.compareTo(a.wins);
        if (cmpWins != 0) return cmpWins;
        final cmpBattles = b.totalBattles.compareTo(a.totalBattles);
        if (cmpBattles != 0) return cmpBattles;
        return b.coins.compareTo(a.coins);
      });

      final rankedPlayers = <PlayerBattleRecord>[];
      for (int i = 0; i < parsedPlayers.length; i++) {
        final p = parsedPlayers[i];
        rankedPlayers.add(
          p.copyWith(rank: p.totalBattles > 0 ? '#${i + 1}' : 'No Matches'),
        );
      }

      _battles = parsedBattles;
      _players = rankedPlayers;
      _settings = loadedSettings;
      _hasPersistedSettings = hasSavedSettings;
      _auditLogs = loadedAuditLogs;
      _battleQuestionsCount = questionRows.length;
      _questionTopicCounts = topicCounts;
      _totalBattleWinPayouts = totalWinPayouts;
      _lastSyncedAt = DateTime.now();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to sync battle data from Supabase: $e';
    } finally {
      _isLoading = false;
      _hasLoadedOnce = true;
      notifyListeners();
    }
  }

  // ==========================================
  // LIVE SUPABASE MUTATIONS (DB-FIRST)
  // ==========================================
  Future<void> createOneVOneBattle({
    required String creatorId,
    String? opponentId,
    required int entryFee,
  }) async {
    final client = _requireClient();
    final hasOpponent = opponentId != null && opponentId.isNotEmpty;
    final id = 'btl_${DateTime.now().millisecondsSinceEpoch}';

    await client.from('battles').insert({
      'id': id,
      'creator_id': creatorId,
      if (hasOpponent) 'opponent_id': opponentId,
      'entry_fee': entryFee,
      'status': hasOpponent ? 'active' : 'waiting',
      'creator_score': 0,
      'opponent_score': 0,
    });

    await _appendAuditLog(
      action: 'Battle Created',
      details: 'Created 1v1 battle $id (fee: $entryFee coins)',
    );
    await refresh();
  }

  Future<void> startSingleBattle(String battleId) async {
    final client = _requireClient();
    await client
        .from('battles')
        .update({'status': 'active'})
        .eq('id', battleId);

    await _appendAuditLog(
      action: 'Started Battle',
      details: 'Moved battle $battleId to active status',
    );
    await refresh();
  }

  Future<void> completeSingleBattle(
    String battleId, {
    String? winnerId,
    required String reason,
  }) async {
    final client = _requireClient();
    await client.from('battles').update({
      'status': 'completed',
      if (winnerId != null && winnerId.isNotEmpty) 'winner_id': winnerId,
      'completed_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', battleId);

    await _appendAuditLog(
      action: 'Completed Battle',
      details: 'Completed battle $battleId — Reason: $reason',
    );
    await refresh();
  }

  Future<void> cancelSingleBattle(String battleId, String reason) async {
    final client = _requireClient();
    await client.from('battles').update({
      'status': 'cancelled',
      'completed_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', battleId);

    await _appendAuditLog(
      action: 'Cancelled Battle',
      details: 'Cancelled battle $battleId — Reason: $reason',
    );
    await refresh();
  }

  Future<int> startAllWaiting() async {
    final client = _requireClient();
    final waitingIds = _battles
        .where((b) => b.status == BattleStatus.waiting && (b.opponentId?.isNotEmpty ?? false))
        .map((b) => b.id)
        .toList();
    if (waitingIds.isEmpty) return 0;

    await client
        .from('battles')
        .update({'status': 'active'})
        .inFilter('id', waitingIds);

    await _appendAuditLog(
      action: 'Bulk Start',
      details: 'Started ${waitingIds.length} matched waiting battles',
    );
    await refresh();
    return waitingIds.length;
  }

  Future<int> completeAllActive(String reason) async {
    final client = _requireClient();
    final activeIds = _battles
        .where((b) => b.status == BattleStatus.live)
        .map((b) => b.id)
        .toList();
    if (activeIds.isEmpty) return 0;

    await client.from('battles').update({
      'status': 'completed',
      'completed_at': DateTime.now().toUtc().toIso8601String(),
    }).inFilter('id', activeIds);

    await _appendAuditLog(
      action: 'Bulk Complete',
      details: 'Completed ${activeIds.length} active battles — Reason: $reason',
    );
    await refresh();
    return activeIds.length;
  }

  Future<int> cancelAllOpen(String reason) async {
    final client = _requireClient();
    final openIds = _battles
        .where((b) => b.status == BattleStatus.live || b.status == BattleStatus.waiting)
        .map((b) => b.id)
        .toList();
    if (openIds.isEmpty) return 0;

    await client.from('battles').update({
      'status': 'cancelled',
      'completed_at': DateTime.now().toUtc().toIso8601String(),
    }).inFilter('id', openIds);

    await _appendAuditLog(
      action: 'Force Cancel Open',
      details: 'Cancelled ${openIds.length} open battles — Reason: $reason',
    );
    await refresh();
    return openIds.length;
  }

  Future<void> updatePlayerModeration({
    required String playerId,
    required String status, // 'active', 'suspended', 'banned'
    DateTime? banUntil,
    required String reason,
  }) async {
    final client = _requireClient();
    if (status != 'active' && status != 'suspended' && status != 'banned') {
      throw ArgumentError('Invalid profile status: $status');
    }

    await client.from('profiles').update({
      'status': status,
      'ban_reason': status == 'active' ? null : reason,
      'ban_until': status == 'active' ? null : banUntil?.toUtc().toIso8601String(),
    }).eq('id', playerId);

    await _appendAuditLog(
      action: 'Player Moderation',
      details: 'Set player $playerId status to "$status" — Reason: $reason',
    );
    await refresh();
  }

  Future<void> updateSettings(BattleSettingsData newSettings) async {
    final client = _requireClient();
    await client.from('app_configs').upsert({
      'key': 'battle_settings',
      'value': newSettings.toJson(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });

    _settings = newSettings;
    _hasPersistedSettings = true;
    await _appendAuditLog(
      action: 'Updated Battle Settings',
      details:
          'Timeout: ${newSettings.matchmakingTimeout}s, Prize Multiplier: ${newSettings.prizeMultiplier}x, Maintenance: ${newSettings.maintenanceMode}',
    );
    notifyListeners();
  }

  Future<void> broadcastMessage(
    String title,
    String message,
    String targetSegment,
  ) async {
    final client = _requireClient();
    final safeSegment = _normalizeNotificationSegment(targetSegment);
    final id = 'notif_battle_${DateTime.now().millisecondsSinceEpoch}';

    await client.from('notifications').insert({
      'id': id,
      'user_id': 'global',
      'title': title,
      'message': message,
      'type': 'info',
      'target_segment': safeSegment,
    });

    await _appendAuditLog(
      action: 'Broadcast Alert',
      details: 'Sent "$title" to $safeSegment ($id)',
    );
    notifyListeners();
  }

  Future<void> _appendAuditLog({
    required String action,
    required String details,
  }) async {
    final now = DateTime.now();
    final timestamp =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    _auditLogs = [
      {
        'time': timestamp,
        'action': action,
        'details': details,
      },
      ..._auditLogs,
    ].take(50).toList();

    final client = SupabaseConfig.clientSafe;
    if (client != null) {
      try {
        await client.from('app_configs').upsert({
          'key': 'battle_admin_audit_logs',
          'value': {'logs': _auditLogs},
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (_) {
        // Primary DB mutation succeeded; audit config table may be restricted by RLS.
      }
    }
  }

  dynamic _requireClient() {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      throw StateError('Database connection is not initialized.');
    }
    return client;
  }

  // ==========================================
  // TEST INJECTION HELPERS (NO FAKE FALLBACK)
  // ==========================================
  @visibleForTesting
  void configureForTest({
    List<BattleItem>? battles,
    List<PlayerBattleRecord>? players,
    BattleSettingsData? settings,
    List<Map<String, dynamic>>? auditLogs,
    int battleQuestionsCount = 0,
    Map<String, int>? questionTopicCounts,
    bool hasDbConnection = true,
    bool hasPersistedSettings = false,
    String? errorMessage,
    bool isLoading = false,
  }) {
    _battles = List.from(battles ?? const []);
    _players = List.from(players ?? const []);
    _settings = settings ?? const BattleSettingsData();
    _auditLogs = List.from(auditLogs ?? const []);
    _battleQuestionsCount = battleQuestionsCount;
    _questionTopicCounts = Map.from(questionTopicCounts ?? const {});
    _hasDbConnection = hasDbConnection;
    _hasPersistedSettings = hasPersistedSettings;
    _errorMessage = errorMessage;
    _isLoading = isLoading;
    _hasLoadedOnce = true;
    _lastSyncedAt = hasDbConnection ? DateTime.now() : null;
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest() {
    _isLoading = false;
    _hasLoadedOnce = false;
    _hasDbConnection = SupabaseConfig.isInitialized;
    _hasPersistedSettings = false;
    _errorMessage = null;
    _lastSyncedAt = null;
    _battles = [];
    _players = [];
    _auditLogs = [];
    _settings = const BattleSettingsData();
    _battleQuestionsCount = 0;
    _questionTopicCounts = {};
    _totalBattleWinPayouts = 0;
    notifyListeners();
  }

  // ==========================================
  // PRIVATE UTILS
  // ==========================================
  BattleStatus _parseDbStatus(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'active':
        return BattleStatus.live;
      case 'completed':
        return BattleStatus.completed;
      case 'cancelled':
        return BattleStatus.cancelled;
      case 'waiting':
      default:
        return BattleStatus.waiting;
    }
  }

  String _normalizeNotificationSegment(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('1 vs 1') || lower.contains('one_v_one')) {
      return 'one_v_one';
    }
    if (lower.contains('tournament')) {
      return 'tournament';
    }
    if (lower.contains('vip')) {
      return 'vip';
    }
    return 'all';
  }

  bool _isSameLocalDay(DateTime a, DateTime b) {
    final al = a.toLocal();
    final bl = b.toLocal();
    return al.year == bl.year && al.month == bl.month && al.day == bl.day;
  }

  List<double> _buildDailySparkline(Iterable<DateTime> timestamps) {
    final now = DateTime.now();
    final counts = List<double>.filled(7, 0);
    for (final ts in timestamps) {
      final local = ts.toLocal();
      final dayDiff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(local.year, local.month, local.day))
          .inDays;
      if (dayDiff >= 0 && dayDiff < 7) {
        counts[6 - dayDiff] += 1;
      }
    }
    return counts;
  }

  String _computeTodayVsYesterdayGrowth(Iterable<DateTime> timestamps) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    int today = 0;
    int prev = 0;
    for (final ts in timestamps) {
      if (_isSameLocalDay(ts, now)) {
        today++;
      } else if (_isSameLocalDay(ts, yesterday)) {
        prev++;
      }
    }
    return _formatDayDelta(today, prev);
  }

  String _formatDayDelta(int today, int yesterday) {
    if (today == 0 && yesterday == 0) return '';
    if (yesterday == 0) return '+$today';
    final pct = (((today - yesterday) / yesterday) * 100).round();
    return pct >= 0 ? '+$pct%' : '$pct%';
  }

  String _shortId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 8)}…';
  }

  String _monthShort(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(m - 1).clamp(0, 11)];
  }

  String _formatHour(int h24) {
    final hour12 = h24 % 12 == 0 ? 12 : h24 % 12;
    final period = h24 >= 12 ? 'PM' : 'AM';
    return '$hour12:00 $period';
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
