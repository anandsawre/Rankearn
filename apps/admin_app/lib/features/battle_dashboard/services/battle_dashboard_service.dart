import 'dart:async';
import 'package:flutter/material.dart';
import '../models/battle_dashboard_models.dart';

class BattleDashboardService extends ChangeNotifier {
  static final BattleDashboardService _instance = BattleDashboardService._internal();
  factory BattleDashboardService() => _instance;

  BattleDashboardService._internal() {
    _initSampleData();
    _startLiveTimer();
  }

  Timer? _timer;

  // KPI Metrics
  int activePlayers = 12840;
  double activePlayersGrowth = 12.0;

  int total1v1Battles = 4326;
  double total1v1Growth = 18.0;

  int multiplayerBattles = 682;
  double multiplayerGrowth = 9.0;

  int activeRooms = 316;

  int overallWinRate = 91;
  double overallWinRateGrowth = 3.0;

  // Today Summary
  int today1v1Count = 3120;
  double today1v1Growth = 20.0;

  int todayMultiplayerCount = 682;
  double todayMultiplayerGrowth = 9.0;

  int todayRoomsCreated = 316;
  double todayRoomsGrowth = 14.0;

  int todayTotalPlayers = 8742;
  double todayTotalPlayersGrowth = 16.0;

  // Active filter
  String currentFilter = 'All'; // 'All', '1 vs 1', 'Multiplayer', 'Rooms'
  String searchQuery = '';
  String? selectedStatus;

  // Real-time Battles
  List<BattleItem> _battles = [];
  List<BattleItem> get battles => _battles;

  // Ongoing Rooms
  List<OngoingRoomItem> _ongoingRooms = [];
  List<OngoingRoomItem> get ongoingRooms => _ongoingRooms;

  // Players
  List<PlayerBattleRecord> _players = [];
  List<PlayerBattleRecord> get players => _players;

  // Settings
  BattleSettingsData settings = const BattleSettingsData();

  // Audit Logs
  final List<Map<String, dynamic>> auditLogs = [];

  void _initSampleData() {
    _battles = [
      BattleItem(
        id: 'B1V92841',
        title: 'Science Super Clash',
        type: BattleType.oneVOne,
        status: BattleStatus.live,
        subject: 'General Science',
        category: 'RRB / SSC',
        participants: const [
          BattleParticipant(
            id: 'u1',
            name: 'Rohit Kumar',
            avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&auto=format&fit=crop&q=80',
            score: 140,
            rank: 1,
            correctAnswers: 3,
          ),
          BattleParticipant(
            id: 'u2',
            name: 'Amit Verma',
            avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=100&auto=format&fit=crop&q=80',
            score: 110,
            rank: 2,
            correctAnswers: 2,
          ),
        ],
        totalPlayers: 2,
        maxPlayers: 2,
        timeRemainingSeconds: 156, // 02:36
        totalDurationSeconds: 300,
        entryFee: 50,
        prizePool: 90,
        currentQuestion: 3,
        totalQuestions: 5,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      BattleItem(
        id: 'BM77320',
        title: 'Reasoning Grand Blitz',
        type: BattleType.multiplayer,
        status: BattleStatus.live,
        subject: 'Reasoning',
        category: 'General Aptitude',
        participants: const [
          BattleParticipant(
            id: 'u3',
            name: 'Aakash Roy',
            avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=100&auto=format&fit=crop&q=80',
            score: 260,
            rank: 1,
            correctAnswers: 4,
          ),
          BattleParticipant(
            id: 'u4',
            name: 'Sneha Patel',
            avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80',
            score: 240,
            rank: 2,
            correctAnswers: 4,
          ),
        ],
        totalPlayers: 10,
        maxPlayers: 10,
        timeRemainingSeconds: 310, // 05:10
        totalDurationSeconds: 600,
        entryFee: 20,
        prizePool: 180,
        currentQuestion: 5,
        totalQuestions: 10,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      BattleItem(
        id: 'RM20916',
        title: 'RRB-Tech Room',
        type: BattleType.room,
        status: BattleStatus.live,
        subject: 'Mathematics',
        category: 'Railway Recruitment',
        roomName: 'RRB-Tech Room',
        roomCode: 'RM20916',
        participants: const [
          BattleParticipant(
            id: 'u5',
            name: 'Devendra K',
            avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&auto=format&fit=crop&q=80',
            score: 320,
            rank: 1,
            correctAnswers: 5,
          ),
          BattleParticipant(
            id: 'u6',
            name: 'Kavita Joshi',
            avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&auto=format&fit=crop&q=80',
            score: 300,
            rank: 2,
            correctAnswers: 5,
          ),
        ],
        totalPlayers: 24,
        maxPlayers: 50,
        timeRemainingSeconds: 504, // 08:24
        totalDurationSeconds: 900,
        entryFee: 10,
        prizePool: 240,
        currentQuestion: 7,
        totalQuestions: 15,
        createdAt: DateTime.now().subtract(const Duration(minutes: 6)),
      ),
      BattleItem(
        id: 'B1V92842',
        title: 'Current Affairs Duel',
        type: BattleType.oneVOne,
        status: BattleStatus.live,
        subject: 'General Awareness',
        category: 'Current Affairs 2026',
        participants: const [
          BattleParticipant(
            id: 'u7',
            name: 'Priya Sharma',
            avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&auto=format&fit=crop&q=80',
            score: 180,
            rank: 1,
            correctAnswers: 3,
          ),
          BattleParticipant(
            id: 'u8',
            name: 'Neha Singh',
            avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&auto=format&fit=crop&q=80',
            score: 160,
            rank: 2,
            correctAnswers: 2,
          ),
        ],
        totalPlayers: 2,
        maxPlayers: 2,
        timeRemainingSeconds: 108, // 01:48
        totalDurationSeconds: 240,
        entryFee: 30,
        prizePool: 54,
        currentQuestion: 4,
        totalQuestions: 5,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      BattleItem(
        id: 'BM77321',
        title: 'Ultimate 50 Battle Royale',
        type: BattleType.multiplayer,
        status: BattleStatus.live,
        subject: 'Mixed (All)',
        category: 'Mega Battle',
        participants: const [
          BattleParticipant(
            id: 'u9',
            name: 'Vikram Sethi',
            avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&auto=format&fit=crop&q=80',
            score: 480,
            rank: 1,
            correctAnswers: 8,
          ),
          BattleParticipant(
            id: 'u10',
            name: 'Manish Tyagi',
            avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=100&auto=format&fit=crop&q=80',
            score: 450,
            rank: 2,
            correctAnswers: 7,
          ),
        ],
        totalPlayers: 50,
        maxPlayers: 50,
        timeRemainingSeconds: 200, // 03:20
        totalDurationSeconds: 600,
        entryFee: 100,
        prizePool: 4500,
        currentQuestion: 9,
        totalQuestions: 15,
        createdAt: DateTime.now().subtract(const Duration(minutes: 7)),
      ),
    ];

    _ongoingRooms = [
      const OngoingRoomItem(
        id: 'r1',
        name: 'RRB-TECH Practice',
        code: 'RRB50',
        currentPlayers: 24,
        maxPlayers: 50,
        subject: 'Science',
        status: BattleStatus.live,
        entryFee: 10,
        prizePool: 240,
      ),
      const OngoingRoomItem(
        id: 'r2',
        name: 'Math Warriors',
        code: 'MTH30',
        currentPlayers: 18,
        maxPlayers: 30,
        subject: 'Mathematics',
        status: BattleStatus.live,
        entryFee: 25,
        prizePool: 450,
      ),
      const OngoingRoomItem(
        id: 'r3',
        name: 'Daily Quiz Room',
        code: 'DLY20',
        currentPlayers: 12,
        maxPlayers: 20,
        subject: 'Mixed',
        status: BattleStatus.live,
        entryFee: 5,
        prizePool: 60,
      ),
    ];

    _players = [
      PlayerBattleRecord(
        id: 'u1',
        username: 'Rohit Kumar',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&auto=format&fit=crop&q=80',
        rank: 'Diamond III',
        totalBattles: 142,
        wins: 108,
        losses: 34,
        winRate: 76,
        coins: 4850,
        status: 'active',
        joinedAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      PlayerBattleRecord(
        id: 'u2',
        username: 'Amit Verma',
        avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=100&auto=format&fit=crop&q=80',
        rank: 'Platinum I',
        totalBattles: 98,
        wins: 62,
        losses: 36,
        winRate: 63,
        coins: 2150,
        status: 'active',
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      PlayerBattleRecord(
        id: 'u3',
        username: 'Priya Sharma',
        avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&auto=format&fit=crop&q=80',
        rank: 'Master II',
        totalBattles: 260,
        wins: 215,
        losses: 45,
        winRate: 83,
        coins: 14200,
        status: 'active',
        joinedAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      PlayerBattleRecord(
        id: 'u4',
        username: 'Vikram Sethi',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&auto=format&fit=crop&q=80',
        rank: 'Grandmaster',
        totalBattles: 410,
        wins: 365,
        losses: 45,
        winRate: 89,
        coins: 28900,
        status: 'active',
        joinedAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      PlayerBattleRecord(
        id: 'u5',
        username: 'Karan Mehra',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
        rank: 'Gold II',
        totalBattles: 45,
        wins: 20,
        losses: 25,
        winRate: 44,
        coins: 350,
        status: 'restricted',
        joinedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  void _startLiveTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      bool changed = false;
      _battles = _battles.map((b) {
        if (b.status == BattleStatus.live) {
          changed = true;
          if (b.timeRemainingSeconds > 0) {
            return b.copyWith(timeRemainingSeconds: b.timeRemainingSeconds - 1);
          } else {
            // Live arena simulation: cycle question and refresh countdown
            final nextQ = (b.currentQuestion >= b.totalQuestions) ? 1 : b.currentQuestion + 1;
            final resetSec = b.type == BattleType.oneVOne
                ? 156
                : b.type == BattleType.multiplayer
                    ? 310
                    : 504;
            return b.copyWith(
              timeRemainingSeconds: resetSec,
              currentQuestion: nextQ,
            );
          }
        }
        return b;
      }).toList();

      if (changed) {
        notifyListeners();
      }
    });
  }

  List<BattleItem> get filteredBattles {
    return _battles.where((b) {
      if (currentFilter == '1 vs 1' && b.type != BattleType.oneVOne) return false;
      if (currentFilter == 'Multiplayer' && b.type != BattleType.multiplayer) return false;
      if (currentFilter == 'Rooms' && b.type != BattleType.room) return false;

      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchesId = b.id.toLowerCase().contains(q);
        final matchesSubject = b.subject.toLowerCase().contains(q);
        final matchesPlayer = b.participants.any((p) => p.name.toLowerCase().contains(q));
        final matchesRoom = b.roomName?.toLowerCase().contains(q) ?? false;
        if (!matchesId && !matchesSubject && !matchesPlayer && !matchesRoom) {
          return false;
        }
      }

      if (selectedStatus != null && selectedStatus!.isNotEmpty) {
        if (b.status.label.toLowerCase() != selectedStatus!.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void setFilter(String filter) {
    currentFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    selectedStatus = status;
    notifyListeners();
  }

  // Battle Actions
  void startAllWaiting() {
    _battles = _battles.map((b) {
      if (b.status == BattleStatus.waiting || b.status == BattleStatus.paused) {
        return b.copyWith(status: BattleStatus.live);
      }
      return b;
    }).toList();
    _logAction('Start All Battles', 'Started all waiting and paused arenas');
    notifyListeners();
  }

  void pauseAllLive() {
    _battles = _battles.map((b) {
      if (b.status == BattleStatus.live) {
        return b.copyWith(status: BattleStatus.paused);
      }
      return b;
    }).toList();
    _logAction('Pause All Battles', 'Paused all active live arenas');
    notifyListeners();
  }

  void endAllLive() {
    _battles = _battles.map((b) {
      if (b.status == BattleStatus.live || b.status == BattleStatus.paused) {
        return b.copyWith(status: BattleStatus.completed);
      }
      return b;
    }).toList();
    _logAction('End All Battles', 'Ended all active live battles with score settlement');
    notifyListeners();
  }

  void forceEndLive(String reason) {
    _battles = _battles.map((b) {
      if (b.status == BattleStatus.live || b.status == BattleStatus.paused) {
        return b.copyWith(status: BattleStatus.cancelled);
      }
      return b;
    }).toList();
    _logAction('Force End Battles', 'Forced termination: $reason');
    notifyListeners();
  }

  void addTimeToAll(int seconds) {
    _battles = _battles.map((b) {
      if (b.status == BattleStatus.live) {
        return b.copyWith(timeRemainingSeconds: b.timeRemainingSeconds + seconds);
      }
      return b;
    }).toList();
    _logAction('Add Extra Time', 'Added +${seconds}s to all active live arenas');
    notifyListeners();
  }

  void clearAllRooms(String reason) {
    _ongoingRooms.clear();
    _battles = _battles.where((b) => b.type != BattleType.room).toList();
    activeRooms = 0;
    _logAction('Clear Rooms', 'Cleared all participant rooms: $reason');
    notifyListeners();
  }

  void startSingleBattle(String id) {
    _battles = _battles.map((b) {
      if (b.id == id) {
        return b.copyWith(status: BattleStatus.live);
      }
      return b;
    }).toList();
    _logAction('Start Battle', 'Battle $id started');
    notifyListeners();
  }

  void pauseSingleBattle(String id) {
    _battles = _battles.map((b) {
      if (b.id == id) {
        return b.copyWith(status: BattleStatus.paused);
      }
      return b;
    }).toList();
    _logAction('Pause Battle', 'Battle $id paused');
    notifyListeners();
  }

  void endSingleBattle(String id, bool forced, String reason) {
    _battles = _battles.map((b) {
      if (b.id == id) {
        return b.copyWith(status: forced ? BattleStatus.cancelled : BattleStatus.completed);
      }
      return b;
    }).toList();
    _logAction(forced ? 'Force End Battle' : 'End Battle', 'Battle $id: $reason');
    notifyListeners();
  }

  void addTimeToBattle(String id, int seconds) {
    _battles = _battles.map((b) {
      if (b.id == id) {
        return b.copyWith(timeRemainingSeconds: b.timeRemainingSeconds + seconds);
      }
      return b;
    }).toList();
    _logAction('Add Time', 'Added +${seconds}s to battle $id');
    notifyListeners();
  }

  void createNewBattle({
    required String title,
    required BattleType type,
    required String subject,
    required String category,
    required int questionsCount,
    required int timePerQuestion,
    required int entryFee,
    required int reward,
    required int maxPlayers,
  }) {
    final prefix = type == BattleType.oneVOne ? 'B1V' : type == BattleType.multiplayer ? 'BM' : 'RM';
    final id = '$prefix${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final newItem = BattleItem(
      id: id,
      title: title,
      type: type,
      status: BattleStatus.live,
      subject: subject,
      category: category,
      participants: const [],
      totalPlayers: type == BattleType.oneVOne ? 2 : 1,
      maxPlayers: maxPlayers,
      timeRemainingSeconds: questionsCount * timePerQuestion,
      totalDurationSeconds: questionsCount * timePerQuestion,
      entryFee: entryFee,
      prizePool: reward,
      currentQuestion: 1,
      totalQuestions: questionsCount,
      createdAt: DateTime.now(),
    );

    _battles.insert(0, newItem);
    if (type == BattleType.oneVOne) total1v1Battles++;
    if (type == BattleType.multiplayer) multiplayerBattles++;
    if (type == BattleType.room) activeRooms++;

    _logAction('Create Battle', 'Launched $type battle "$title" ($id)');
    notifyListeners();
  }

  void createNewRoom({
    required String name,
    required String code,
    required String subject,
    required int maxPlayers,
    required int entryFee,
    required int reward,
    required bool isPrivate,
    String? password,
  }) {
    final newRoom = OngoingRoomItem(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      code: code,
      currentPlayers: 1,
      maxPlayers: maxPlayers,
      subject: subject,
      status: BattleStatus.live,
      entryFee: entryFee,
      prizePool: reward,
    );

    _ongoingRooms.insert(0, newRoom);
    activeRooms++;

    // Also add to battles list
    _battles.insert(
      0,
      BattleItem(
        id: code,
        title: name,
        type: BattleType.room,
        status: BattleStatus.live,
        subject: subject,
        category: 'Custom Room',
        roomName: name,
        roomCode: code,
        participants: const [],
        totalPlayers: 1,
        maxPlayers: maxPlayers,
        timeRemainingSeconds: 600,
        totalDurationSeconds: 600,
        entryFee: entryFee,
        prizePool: reward,
        createdAt: DateTime.now(),
      ),
    );

    _logAction('Create Room', 'Created room "$name" (Code: $code)');
    notifyListeners();
  }

  void restrictPlayer(String id, int hours, String reason) {
    _players = _players.map((p) {
      if (p.id == id) {
        return p.copyWith(status: 'restricted');
      }
      return p;
    }).toList();
    _logAction('Restrict Player', 'Player $id restricted for $hours hours: $reason');
    notifyListeners();
  }

  void suspendPlayer(String id, bool suspend, String reason) {
    _players = _players.map((p) {
      if (p.id == id) {
        return p.copyWith(status: suspend ? 'suspended' : 'active');
      }
      return p;
    }).toList();
    _logAction(suspend ? 'Suspend Player' : 'Unsuspend Player', 'Player $id: $reason');
    notifyListeners();
  }

  void updateSettings(BattleSettingsData newSettings) {
    settings = newSettings;
    _logAction('Update Settings', 'Global battle settings updated');
    notifyListeners();
  }

  void broadcastMessage(String title, String message, String target) {
    _logAction('Broadcast Alert', 'Transmitted "$title" to $target: $message');
    notifyListeners();
  }

  void _logAction(String action, String details) {
    auditLogs.insert(0, {
      'timestamp': DateTime.now(),
      'action': action,
      'details': details,
      'admin': 'Admin (SuperAdmin)',
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

