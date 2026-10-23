import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'battle_screen.dart';

/// Rankearn 1v1 Quiz Battle Tab
/// High-fidelity, responsive screen matching the reference image.
class BattleHubScreen extends StatefulWidget {
  final int userCoins;
  final UserProfile profile;
  final void Function(int coinsDelta)? onCoinUpdate;
  final VoidCallback? onOpenWallet;

  const BattleHubScreen({
    super.key,
    required this.userCoins,
    required this.profile,
    this.onCoinUpdate,
    this.onOpenWallet,
  });

  @override
  State<BattleHubScreen> createState() => _BattleHubScreenState();
}

class _BattleHubScreenState extends State<BattleHubScreen> {
  final BattleRepository _repository = BattleRepository();

  BattleNavTab _selectedTab = BattleNavTab.oneVOne;
  BattleStatsModel _stats = const BattleStatsModel();
  List<BattlePlayerModel> _topPlayers = [];
  List<BattleMissionModel> _missions = [];
  List<BattleHistoryItemModel> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBattleData();
  }

  Future<void> _loadBattleData() async {
    final statsRes = await _repository.getBattleStats(userId: widget.profile.id);
    final playersRes = await _repository.getTopPlayers();
    final missionsRes = await _repository.getDailyMissions();
    final historyRes = await _repository.getBattleHistory();

    if (!mounted) return;
    setState(() {
      if (statsRes is Success<BattleStatsModel>) _stats = statsRes.data;
      if (playersRes is Success<List<BattlePlayerModel>>) _topPlayers = playersRes.data;
      if (missionsRes is Success<List<BattleMissionModel>>) _missions = missionsRes.data;
      if (historyRes is Success<List<BattleHistoryItemModel>>) _history = historyRes.data;
      _isLoading = false;
    });
  }

  // --- Interactive Matchmaking Flow (Screen 1: Finding Opponent Radar) ---
  void _startMatchmaking({required String battleType, required int entryFee}) {
    if (widget.userCoins < entryFee) {
      _showInsufficientCoinsDialog(entryFee);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FindingOpponentScreen(
          userCoins: widget.userCoins,
          profile: widget.profile,
          battleType: battleType,
          entryFee: entryFee,
          onCoinUpdate: (coinsWon) {
            widget.onCoinUpdate?.call(coinsWon);
            _loadBattleData();
          },
        ),
      ),
    );
  }

  void _showInsufficientCoinsDialog(int requiredCoins) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.monetization_on_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text('Insufficient Coins', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text(
          'You need $requiredCoins coins to enter this battle arena. Current balance: ${widget.userCoins} coins.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              widget.onOpenWallet?.call();
            },
            child: const Text('Add Coins'),
          ),
        ],
      ),
    );
  }

  // --- Custom Room Dialog ---
  void _openCustomRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => _CustomRoomDialog(
        userCoins: widget.userCoins,
        onRoomCreated: (roomCode, fee) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Room $roomCode created! Waiting for friend to join...'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        },
        onJoinRoom: (roomCode) {
          Navigator.pop(context);
          _startMatchmaking(battleType: 'Friends Battle ($roomCode)', entryFee: 20);
        },
      ),
    );
  }

  // --- Leaderboard Modal ---
  void _openLeaderboardModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B)),
                    SizedBox(width: 8),
                    Text(
                      'Battle Leaderboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111A4B),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _topPlayers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final p = _topPlayers[index];
                  return BattlePlayerCard(
                    rank: p.rank,
                    name: p.name,
                    score: p.score,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Missions Modal ---
  void _openMissionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.70,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.track_changes_rounded, color: Color(0xFF2587F8)),
                    SizedBox(width: 8),
                    Text(
                      'All Daily Missions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111A4B),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _missions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final m = _missions[index];
                  return BattleMissionCard(
                    icon: _getMissionIcon(m.iconKey),
                    iconColor: _getMissionIconColor(m.iconKey),
                    iconBgColor: _getMissionIconBg(m.iconKey),
                    title: m.title,
                    currentProgress: m.currentProgress,
                    targetProgress: m.targetProgress,
                    rewardCoins: m.rewardCoins,
                    isClaimed: m.isClaimed,
                    onClaim: () {
                      Navigator.pop(context);
                      _claimMissionReward(m);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _claimMissionReward(BattleMissionModel m) {
    widget.onCoinUpdate?.call(m.rewardCoins);
    setState(() {
      final index = _missions.indexWhere((item) => item.id == m.id);
      if (index != -1) {
        _missions[index] = _missions[index].copyWith(isClaimed: true);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('+${m.rewardCoins} coins added to your wallet!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  IconData _getMissionIcon(String key) {
    switch (key) {
      case 'swords':
        return Icons.sports_esports_rounded;
      case 'trophy':
        return Icons.emoji_events_rounded;
      case 'chart':
        return Icons.bar_chart_rounded;
      default:
        return Icons.groups_rounded;
    }
  }

  Color _getMissionIconColor(String key) {
    switch (key) {
      case 'swords':
        return const Color(0xFF3B82F6);
      case 'trophy':
        return const Color(0xFFF59E0B);
      case 'chart':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF0284C7);
    }
  }

  Color _getMissionIconBg(String key) {
    switch (key) {
      case 'swords':
        return const Color(0xFFEFF6FF);
      case 'trophy':
        return const Color(0xFFFEF3C7);
      case 'chart':
        return const Color(0xFFD1FAE5);
      default:
        return const Color(0xFFE0F2FE);
    }
  }

  void _openRewardsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.military_tech_rounded, color: Color(0xFFF59E0B)),
                      SizedBox(width: 8),
                      Text('1v1 Battle Rewards', style: AppTypography.titleLarge),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.monetization_on_rounded, color: Color(0xFFF59E0B)),
                title: Text('Instant Coins', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Earn 50 to 100+ coins on each 1v1 battle victory!'),
              ),
              const ListTile(
                leading: Icon(Icons.emoji_events_rounded, color: Color(0xFFEAB308)),
                title: Text('Rank Badges', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Climb divisions from Bronze up to Grandmaster.'),
              ),
              const ListTile(
                leading: Icon(Icons.card_giftcard_rounded, color: Color(0xFF8B5CF6)),
                title: Text('Exciting Prizes & Passes', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Top performers receive special gifts and tournament entries.'),
              ),
              const ListTile(
                leading: Icon(Icons.workspace_premium_rounded, color: Color(0xFF2587F8)),
                title: Text('Verified Certificates', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Showcase verified Rankearn academic competition skill.'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRightSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Today's Goal
        const AppSectionHeader(
          title: "Today's Goal",
          icon: Icons.flag_rounded,
          iconColor: Color(0xFF2587F8),
        ),
        const SizedBox(height: 10),
        TodayGoalCard(
          completed: 3,
          target: 5,
          unitLabel: 'Battles',
          subtitle: 'Complete 5 battles today to earn 50 coins!',
          onTap: () => _startMatchmaking(battleType: 'Quick Battle', entryFee: 50),
        ),
        const SizedBox(height: 18),

        // 2. Daily Streak
        DailyStreakCard(
          streakDays: 7,
          completedDays: 5,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('7-Day Streak Active! Keep battling daily for bonus rewards.'),
                backgroundColor: Color(0xFFF97316),
              ),
            );
          },
        ),
        const SizedBox(height: 18),

        // 3. Weekly Leaderboard
        WeeklyLeaderboardCard(
          title: 'Weekly Leaderboard',
          topUsers: const [
            {
              'rank': 1,
              'name': 'Aman Kumar',
              'coins': 12540,
              'avatarColor': Color(0xFF3B82F6),
              'initial': 'A',
            },
            {
              'rank': 2,
              'name': 'Priya Singh',
              'coins': 11230,
              'avatarColor': Color(0xFFEC4899),
              'initial': 'P',
            },
            {
              'rank': 3,
              'name': 'Rohit Rai',
              'coins': 10980,
              'avatarColor': Color(0xFFF59E0B),
              'initial': 'R',
            },
            {
              'rank': 4,
              'name': 'Sneha Patel',
              'coins': 9650,
              'avatarColor': Color(0xFF10B981),
              'initial': 'S',
            },
            {
              'rank': 5,
              'name': 'Vikram Singh',
              'coins': 8420,
              'avatarColor': Color(0xFF8B5CF6),
              'initial': 'V',
            },
          ],
          onViewAll: _openLeaderboardModal,
          onUserTap: (user) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${user['name']} • Rank #${user['rank']} with ${user['coins']} coins'),
              ),
            );
          },
        ),
        const SizedBox(height: 18),

        // 4. Top Battle Rewards
        BattleTopRewardsCard(
          onViewAll: _openRewardsModal,
          onRewardTap: (rewardType) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$rewardType: Win exciting rewards in 1v1 battles!'),
                backgroundColor: const Color(0xFFF43F5E),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 990;
        final isWideDesktop = constraints.maxWidth >= 1150;
        final isTablet = constraints.maxWidth >= 640 && constraints.maxWidth < 990;

        final mainContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loading Indicator if refreshing
            if (_isLoading) ...[
              const LinearProgressIndicator(
                color: AppColors.primary,
                backgroundColor: Colors.transparent,
                minHeight: 2,
              ),
              const SizedBox(height: 8),
            ],

            // 1. Hero Banner
            BattleHeroBanner(
              borderRadius: BorderRadius.circular(12),
              onStartBattle: () => _startMatchmaking(battleType: 'Quick Battle', entryFee: 50),
            ),
            const SizedBox(height: 18),

            // 2. Battle Statistics (4 Cards)
            BattleMetricsRow(
              playersOnline: '${_stats.playersOnline}',
              battlesPlayed: '${_stats.battlesPlayed}',
              yourWins: '${_stats.yourWins}',
              winRate: '${_stats.winRatePercent}%',
            ),
            const SizedBox(height: 18),

            // 3. Battle Navigation Tabs
            BattleNavigationTabs(
              selectedTab: _selectedTab,
              onTabSelected: (tab) {
                setState(() => _selectedTab = tab);
                if (tab == BattleNavTab.customRoom) {
                  _openCustomRoomDialog();
                }
              },
            ),
            const SizedBox(height: 20),

            // 4. Tab Content: If History is selected, show History; else show Choose Battle Type
            if (_selectedTab == BattleNavTab.history) ...[
              _buildHistorySection(),
            ] else ...[
              // A. Choose Battle Type Section
              const AppSectionHeader(
                title: 'Choose Battle Type',
                icon: Icons.bolt_rounded,
                iconColor: Color(0xFF2587F8),
              ),
              const SizedBox(height: 12),
              _buildBattleTypeCards(isDesktop, isTablet),
              const SizedBox(height: 24),

              // B. Top Players Section
              AppSectionHeader(
                title: 'Top Players',
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFFF59E0B),
                onAction: _openLeaderboardModal,
              ),
              const SizedBox(height: 12),
              _buildTopPlayersGrid(isWideDesktop, isTablet),
              const SizedBox(height: 24),

              // C. Daily Battle Mission Section
              AppSectionHeader(
                title: 'Daily Battle Mission',
                icon: Icons.track_changes_rounded,
                iconColor: const Color(0xFF2587F8),
                onAction: _openMissionsModal,
              ),
              const SizedBox(height: 12),
              _buildDailyMissionsGrid(isWideDesktop, isTablet),
            ],
            const SizedBox(height: 24),
          ],
        );

        final rightSidebar = _buildRightSidebar();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : 16,
            vertical: 14,
          ),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Column (~70%)
                    Expanded(
                      flex: 70,
                      child: mainContent,
                    ),
                    const SizedBox(width: 22),
                    // Right Sidebar (~30%)
                    Expanded(
                      flex: 30,
                      child: rightSidebar,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    mainContent,
                    const SizedBox(height: 24),
                    rightSidebar,
                  ],
                ),
        );
      },
    );
  }

  // --- Choose Battle Type Cards Grid ---
  Widget _buildBattleTypeCards(bool isDesktop, bool isTablet) {
    final quickCard = BattleTypeCard.quick(
      onPlay: () => _startMatchmaking(battleType: 'Quick Battle', entryFee: 50),
    );
    final rankedCard = BattleTypeCard.ranked(
      onPlay: () => _startMatchmaking(battleType: 'Ranked Battle', entryFee: 100),
    );
    final friendsCard = BattleTypeCard.friends(
      onCreateRoom: _openCustomRoomDialog,
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: quickCard),
          const SizedBox(width: 14),
          Expanded(child: rankedCard),
          const SizedBox(width: 14),
          Expanded(child: friendsCard),
        ],
      );
    }

    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: quickCard),
          const SizedBox(width: 10),
          Expanded(child: rankedCard),
          const SizedBox(width: 10),
          Expanded(child: friendsCard),
        ],
      );
    }

    // Mobile vertical stack
    return Column(
      children: [
        quickCard,
        const SizedBox(height: 12),
        rankedCard,
        const SizedBox(height: 12),
        friendsCard,
      ],
    );
  }

  // --- Top Players Grid (4 Cards) ---
  Widget _buildTopPlayersGrid(bool isDesktop, bool isTablet) {
    final players = _topPlayers.isNotEmpty
        ? _topPlayers.take(4).toList()
        : const [
            BattlePlayerModel(rank: 1, id: '1', name: 'Aman Kumar', score: 12540),
            BattlePlayerModel(rank: 2, id: '2', name: 'Priya Singh', score: 11230),
            BattlePlayerModel(rank: 3, id: '3', name: 'Rohit Raj', score: 10980),
            BattlePlayerModel(rank: 4, id: '4', name: 'Sneha Patel', score: 9650),
          ];

    final cards = [
      BattlePlayerCard(
        rank: 1,
        name: players[0].name,
        score: players[0].score,
        avatarBgColor: const Color(0xFF99F6E4), // Mint/teal for boy 1
      ),
      BattlePlayerCard(
        rank: 2,
        name: players.length > 1 ? players[1].name : 'Priya Singh',
        score: players.length > 1 ? players[1].score : 11230,
        avatarBgColor: const Color(0xFFFBCFE8), // Pink for girl 1
      ),
      BattlePlayerCard(
        rank: 3,
        name: players.length > 2 ? players[2].name : 'Rohit Raj',
        score: players.length > 2 ? players[2].score : 10980,
        avatarBgColor: const Color(0xFFBAE6FD), // Sky blue for boy 2
      ),
      BattlePlayerCard(
        rank: 4,
        name: players.length > 3 ? players[3].name : 'Sneha Patel',
        score: players.length > 3 ? players[3].score : 9650,
        avatarBgColor: const Color(0xFFE2E8F0), // Slate for girl 2
      ),
    ];

    if (isDesktop) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }

    // Mobile / Tablet 2x2 grid
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 8),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: cards[2]),
            const SizedBox(width: 8),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }

  // --- Daily Missions Grid (4 Cards) ---
  Widget _buildDailyMissionsGrid(bool isDesktop, bool isTablet) {
    final missions = _missions.isNotEmpty
        ? _missions.take(4).toList()
        : const [
            BattleMissionModel(
              id: 'bm_01',
              title: 'Play 3 Battles',
              iconKey: 'swords',
              currentProgress: 1,
              targetProgress: 3,
              rewardCoins: 100,
            ),
            BattleMissionModel(
              id: 'bm_02',
              title: 'Win 2 Battles',
              iconKey: 'trophy',
              currentProgress: 0,
              targetProgress: 2,
              rewardCoins: 150,
            ),
            BattleMissionModel(
              id: 'bm_03',
              title: 'Score 80%+',
              iconKey: 'chart',
              currentProgress: 0,
              targetProgress: 1,
              rewardCoins: 200,
            ),
            BattleMissionModel(
              id: 'bm_04',
              title: 'Battle with Friend',
              iconKey: 'friends',
              currentProgress: 0,
              targetProgress: 1,
              rewardCoins: 100,
            ),
          ];

    final cards = missions.map((m) {
      return BattleMissionCard(
        icon: _getMissionIcon(m.iconKey),
        iconColor: _getMissionIconColor(m.iconKey),
        iconBgColor: _getMissionIconBg(m.iconKey),
        title: m.title,
        currentProgress: m.currentProgress,
        targetProgress: m.targetProgress,
        rewardCoins: m.rewardCoins,
        isClaimed: m.isClaimed,
        onClaim: () => _claimMissionReward(m),
      );
    }).toList();

    if (isDesktop) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }

    // Mobile / Tablet 2x2 grid
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 8),
            if (cards.length > 1) Expanded(child: cards[1]),
          ],
        ),
        if (cards.length > 2) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 8),
              if (cards.length > 3) Expanded(child: cards[3]),
            ],
          ),
        ],
      ],
    );
  }

  // --- Battle History Section ---
  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Recent Battle History',
          icon: Icons.history_rounded,
          iconColor: Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 12),
        if (_history.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No battles played yet. Start your first 1v1 battle now!',
                style: TextStyle(color: Color(0xFF566797), fontWeight: FontWeight.w600),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _history.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final h = _history[index];
              final isWon = h.result == 'Won';

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2EAF8), width: 1.1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isWon ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isWon ? Icons.emoji_events_rounded : Icons.close_rounded,
                          color: isWon ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'vs ${h.opponentName}',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111A4B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${h.battleType} • ${h.dateString}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF566797),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${h.myScore} - ${h.opponentScore}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111A4B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isWon ? '+${h.coinsDelta} Coins' : '${h.coinsDelta} Coins',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: isWon ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Matchmaking Dialog with live animated search & opponent found countdown
class _MatchmakingDialog extends StatefulWidget {
  final String battleType;
  final int entryFee;
  final String playerName;
  final void Function(String opponentName) onMatchFound;
  final VoidCallback onCancel;

  const _MatchmakingDialog({
    required this.battleType,
    required this.entryFee,
    required this.playerName,
    required this.onMatchFound,
    required this.onCancel,
  });

  @override
  State<_MatchmakingDialog> createState() => _MatchmakingDialogState();
}

class _MatchmakingDialogState extends State<_MatchmakingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _searchDelayTimer;
  Timer? _countdownTimer;
  int _countdown = 3;
  bool _opponentFound = false;
  final String _foundOpponent = 'Amit Verma (Rank #4)';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Simulate search -> opponent found -> countdown -> launch
    _searchDelayTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() => _opponentFound = true);

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (_countdown > 1) {
          setState(() => _countdown--);
        } else {
          timer.cancel();
          widget.onMatchFound(_foundOpponent);
        }
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchDelayTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0728),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Radar / Battle Icon
            RotationTransition(
              turns: _opponentFound ? const AlwaysStoppedAnimation(0) : _animController,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF1B0E54)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _opponentFound ? Icons.verified_rounded : Icons.sports_esports_rounded,
                    color: _opponentFound ? const Color(0xFFFFD633) : Colors.white,
                    size: 38,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              _opponentFound ? 'Opponent Found!' : 'Searching Opponent...',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle
            Text(
              _opponentFound
                  ? 'Matched with $_foundOpponent'
                  : 'Matching with skilled players in ${widget.battleType}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFFCBD5E1),
              ),
            ),
            const SizedBox(height: 16),

            // Countdown / Entry Fee
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _opponentFound
                    ? 'Starting in $_countdown...'
                    : 'Entry Fee: ${widget.entryFee} Coins',
                style: TextStyle(
                  fontSize: _opponentFound ? 15 : 12.5,
                  fontWeight: FontWeight.w900,
                  color: _opponentFound ? const Color(0xFFFFD633) : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Cancel Button
            if (!_opponentFound)
              TextButton(
                onPressed: widget.onCancel,
                child: const Text(
                  'Cancel Matchmaking',
                  style: TextStyle(
                    color: Color(0xFFF43F5E),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom Room creation / join dialog
class _CustomRoomDialog extends StatefulWidget {
  final int userCoins;
  final void Function(String roomCode, int fee) onRoomCreated;
  final void Function(String roomCode) onJoinRoom;

  const _CustomRoomDialog({
    required this.userCoins,
    required this.onRoomCreated,
    required this.onJoinRoom,
  });

  @override
  State<_CustomRoomDialog> createState() => _CustomRoomDialogState();
}

class _CustomRoomDialogState extends State<_CustomRoomDialog> {
  int _selectedFee = 20;
  final TextEditingController _codeController = TextEditingController();
  bool _isCreateTab = true;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.meeting_room_rounded, color: Color(0xFFF97316)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Custom Battle Room',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111A4B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tab switch: Create vs Join
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isCreateTab = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCreateTab ? const Color(0xFFF97316) : const Color(0xFFF1F5F9),
                      foregroundColor: _isCreateTab ? Colors.white : const Color(0xFF566797),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Create Room', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isCreateTab = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isCreateTab ? const Color(0xFFF97316) : const Color(0xFFF1F5F9),
                      foregroundColor: !_isCreateTab ? Colors.white : const Color(0xFF566797),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Join Room', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isCreateTab) ...[
              const Text('Select Entry Fee per Player:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [10, 20, 50, 100].map((fee) {
                  final isSel = _selectedFee == fee;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFee = fee),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFFFF7ED) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel ? const Color(0xFFF97316) : const Color(0xFFE2EAF8),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '$fee Coins',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isSel ? const Color(0xFFF97316) : const Color(0xFF566797),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    final code = 'RK-${(1000 + DateTime.now().millisecond % 9000)}';
                    widget.onRoomCreated(code, _selectedFee);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Generate Room Code', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ] else ...[
              const Text('Enter 6-Digit Room Code:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'e.g. RK-7821',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    final code = _codeController.text.trim();
                    if (code.isNotEmpty) widget.onJoinRoom(code);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Join Arena', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
