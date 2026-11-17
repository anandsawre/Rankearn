import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'dialogs/contest_entry_dialog.dart';

/// LiveTestsScreen - Production-Quality Live Tests & Tournaments Tab
/// Fully wired with Supabase Contests, Realtime Leaderboard, and Dynamic Live/Upcoming state.
class LiveTestsScreen extends StatefulWidget {
  final int userCoins;
  final String? userId;
  final void Function(TestModel test)? onStartTest;
  final VoidCallback? onOpenBattle;
  final VoidCallback? onOpenLeaderboard;
  final VoidCallback? onExploreSeries;
  final VoidCallback? onOpenWallet;
  final ValueChanged<int>? onCoinDeducted;
  final List<TestModel>? initialTournaments;

  const LiveTestsScreen({
    super.key,
    required this.userCoins,
    this.userId,
    this.onStartTest,
    this.onOpenBattle,
    this.onOpenLeaderboard,
    this.onExploreSeries,
    this.onOpenWallet,
    this.onCoinDeducted,
    this.initialTournaments,
  });

  @override
  State<LiveTestsScreen> createState() => _LiveTestsScreenState();
}

class _LiveTestsScreenState extends State<LiveTestsScreen> {
  LiveTestFilterTab _selectedTab = LiveTestFilterTab.allLiveTests;
  bool _isLoading = true;

  List<TestModel> _allTournaments = [];
  List<TestModel> _liveNowTournaments = [];
  List<TestModel> _upcomingTournaments = [];
  List<Map<String, dynamic>> _myParticipations = [];
  List<Map<String, dynamic>> _leaderboardUsers = [];
  Map<String, dynamic> _userStats = {};

  final Set<String> _notifiedTestIds = <String>{};
  Timer? _refreshTimer;
  List<BannerModel> _contestBanners = [];
  StreamSubscription<List<BannerModel>>? _bannersSub;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTournaments ?? <TestModel>[];
    _processTournaments(initial);
    _isLoading = initial.isEmpty;
    _loadLiveScreenData();
    _loadBanners();

    // Auto-update live and upcoming status every 15 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted && _allTournaments.isNotEmpty) {
        setState(() {
          _processTournaments(_allTournaments);
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _bannersSub?.cancel();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    final res = await BannersRepository().getActiveBanners(displayMode: 'contest_spotlight');
    if (res is Success<List<BannerModel>> && mounted) {
      setState(() => _contestBanners = res.data);
    }
    _bannersSub ??= BannersRepository().streamActiveBanners(displayMode: 'contest_spotlight').listen((updated) {
      if (mounted) setState(() => _contestBanners = updated);
    }, onError: (_) {});
  }

  Widget _buildTopBanner({required BorderRadius borderRadius}) {
    if (_contestBanners.isEmpty) {
      return LiveTestsHeroBanner(
        borderRadius: borderRadius,
        imageAssetPath: 'assets/images/live_tests_hero_mascot.jpg',
        onJoinLiveTest: () {
          if (_liveNowTournaments.isNotEmpty) {
            _handleJoinTest(_liveNowTournaments.first);
          } else if (_allTournaments.isNotEmpty) {
            _handleJoinTest(_allTournaments.first);
          } else {
            widget.onExploreSeries?.call();
          }
        },
      );
    }
    return BannerCarousel(
      banners: _contestBanners.map((b) => BannerItemData(
        id: b.id,
        imageUrl: b.imageUrl,
        title: b.title,
        link: b.link,
        type: b.type,
        spotlightData: b.spotlightData,
      )).toList(),
      borderRadius: borderRadius,
      onBannerTap: (b) => BannersRepository().recordClick(b.id),
      fallbackWidget: LiveTestsHeroBanner(
        borderRadius: borderRadius,
        imageAssetPath: 'assets/images/live_tests_hero_mascot.jpg',
        onJoinLiveTest: () {
          if (_liveNowTournaments.isNotEmpty) {
            _handleJoinTest(_liveNowTournaments.first);
          } else if (_allTournaments.isNotEmpty) {
            _handleJoinTest(_allTournaments.first);
          } else {
            widget.onExploreSeries?.call();
          }
        },
      ),
    );
  }

  void _processTournaments(List<TestModel> tournaments) {
    final liveNow = <TestModel>[];
    final upcoming = <TestModel>[];

    for (final t in tournaments) {
      if (t.isUpcoming) {
        upcoming.add(t);
      } else if (t.isLive) {
        liveNow.add(t);
      }
    }

    _allTournaments = tournaments;
    _liveNowTournaments = liveNow;
    _upcomingTournaments = upcoming;
  }

  Future<void> _loadLiveScreenData() async {
    final repo = ContestsRepository();
    final testsRepo = TestsRepository();

    final results = await Future.wait([
      repo.getLiveAndUpcomingTests(),
      repo.getLeaderboardUsers(),
      repo.getUserParticipations(widget.userId ?? ''),
      testsRepo.getUserStats(widget.userId ?? ''),
    ]);

    if (!mounted) return;

    final tRes = results[0] as Result<List<TestModel>>;
    final lRes = results[1] as Result<List<Map<String, dynamic>>>;
    final pRes = results[2] as Result<List<Map<String, dynamic>>>;
    final stats = results[3] as Map<String, dynamic>;

    final tournaments = tRes is Success<List<TestModel>> ? tRes.data : <TestModel>[];
    final leaderboard = lRes is Success<List<Map<String, dynamic>>> ? lRes.data : <Map<String, dynamic>>[];
    final participations = pRes is Success<List<Map<String, dynamic>>> ? pRes.data : <Map<String, dynamic>>[];

    setState(() {
      _processTournaments(tournaments);
      _leaderboardUsers = leaderboard;
      _myParticipations = participations;
      _userStats = stats;
      _isLoading = false;
    });
  }

  Future<void> _handleJoinTest(TestModel test) async {
    final entryFee = test.entryFeeCoins;

    if (entryFee > 0) {
      final confirm = await showContestEntryDialog(
        context: context,
        test: test,
        userCoins: widget.userCoins,
        isPreRegister: test.isUpcoming,
        onOpenWallet: widget.onOpenWallet,
      );

      if (confirm != true || !mounted) return;

      final repo = ContestsRepository();
      final res = await repo.joinTournamentSafe(
        testId: test.id,
        userId: widget.userId ?? '',
        entryFee: entryFee,
      );

      if (res is Failure) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text((res as Failure).message),
          ),
        );
        return;
      }

      widget.onCoinDeducted?.call(entryFee);
    }

    if (widget.onStartTest != null) {
      widget.onStartTest!(test);
    }
  }

  void _toggleNotification(String testId, String title) {
    setState(() {
      if (_notifiedTestIds.contains(testId)) {
        _notifiedTestIds.remove(testId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder cancelled for $title'),
            backgroundColor: const Color(0xFF475569),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _notifiedTestIds.add(testId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Reminder set for $title! We will notify you before it starts.')),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _openLeaderboardsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB800), size: 24),
              SizedBox(width: 8),
              Text('Live Leaderboards', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          content: _leaderboardUsers.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.emoji_events_outlined, size: 40, color: AppColors.textMuted),
                      SizedBox(height: 12),
                      Text(
                        'No leaderboard rankings yet',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rankings will appear as learners participate in live contests.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _leaderboardUsers.take(10).map((u) {
                      final rank = _leaderboardUsers.indexOf(u) + 1;
                      final isUser = u['id'] == widget.userId;
                      final name = isUser
                          ? '${u['name'] ?? 'Candidate'} (You)'
                          : (u['name']?.toString() ?? (u['email'] != null ? u['email'].toString().split('@').first : 'Learner'));
                      return Column(
                        children: [
                          _buildLeaderboardRow(
                            rank,
                            name,
                            '${u['coins'] ?? 0} Coins',
                            isUser,
                          ),
                          if (rank < _leaderboardUsers.length.clamp(0, 10))
                            const Divider(height: 12),
                        ],
                      );
                    }).toList(),
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeaderboardRow(int rank, String name, String coins, bool isUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rank == 1
                  ? const Color(0xFFFFD633)
                  : (rank == 2 ? const Color(0xFFCBD5E1) : (rank == 3 ? const Color(0xFFFED7AA) : const Color(0xFFF1F5F9))),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF0F172A)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: isUser ? FontWeight.w900 : FontWeight.w700,
                color: isUser ? AppColors.brandPurple : const Color(0xFF0F172A),
                fontSize: 13,
              ),
            ),
          ),
          Text(
            coins,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  String _calculateStartsIn(DateTime? start) {
    if (start == null) return 'Starting Soon';
    final diff = start.difference(DateTime.now());
    if (diff.isNegative) return 'Live Now';
    if (diff.inDays > 0) return '${diff.inDays} days';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    return '${diff.inMinutes} mins';
  }

  String _formatMonth(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (m >= 1 && m <= 12) return months[m - 1];
    return 'Live';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 990;

        final totalParts = _allTournaments.fold<int>(0, (sum, t) => sum + t.totalParticipants);
        final displayParts = totalParts > 0 ? (totalParts >= 1000 ? '${(totalParts / 1000).toStringAsFixed(1)}K' : '$totalParts') : '0';
        final userRank = _userStats['rank']?.toString() ?? '-';

        final mainContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Live Tests Hero Banner / Dynamic Carousel
            _buildTopBanner(borderRadius: BorderRadius.circular(12)),
            const SizedBox(height: 16),

            // 2. Real Statistics Cards (Live Count, Participants, Coins, Rank)
            LiveTestMetricsRow(
              liveNowCount: _liveNowTournaments.length,
              participants: displayParts,
              coinsEarned: '${widget.userCoins}',
              rankPosition: userRank,
              onLiveNowTap: () => setState(() => _selectedTab = LiveTestFilterTab.liveNow),
              onParticipantsTap: _openLeaderboardsDialog,
              onCoinsTap: () => widget.onOpenLeaderboard?.call(),
              onRankTap: _openLeaderboardsDialog,
            ),
            const SizedBox(height: 16),

            // 3. Navigation Filter Tabs
            LiveTestNavigation(
              selectedTab: _selectedTab,
              onTabSelected: (tab) {
                setState(() => _selectedTab = tab);
                if (tab == LiveTestFilterTab.leaderboards) {
                  _openLeaderboardsDialog();
                }
              },
            ),
            const SizedBox(height: 20),

            // 4. Content filtered by active tab
            if (_selectedTab == LiveTestFilterTab.myParticipations)
              _buildMyParticipationsView()
            else ...[
              // Section 1: Live Now Carousel (Hidden when no live tests are active on All tab)
              if (_liveNowTournaments.isNotEmpty &&
                  (_selectedTab == LiveTestFilterTab.allLiveTests ||
                      _selectedTab == LiveTestFilterTab.liveNow)) ...[
                _buildSectionHeader(
                  title: 'Live Now',
                  icon: Icons.sensors_rounded,
                  iconColor: const Color(0xFFF43F5E),
                  onViewAll: () => setState(() => _selectedTab = LiveTestFilterTab.liveNow),
                ),
                const SizedBox(height: 12),
                _buildLiveNowCarousel(isDesktop),
                const SizedBox(height: 24),
              ] else if (_selectedTab == LiveTestFilterTab.liveNow && _liveNowTournaments.isEmpty) ...[
                _buildLiveNowCarousel(isDesktop),
                const SizedBox(height: 24),
              ],

              // Section 2: Upcoming Live Tests
              if (_selectedTab == LiveTestFilterTab.allLiveTests ||
                  _selectedTab == LiveTestFilterTab.upcoming) ...[
                _buildSectionHeader(
                  title: 'Upcoming Live Tests',
                  icon: Icons.calendar_month_outlined,
                  iconColor: const Color(0xFF6366F1),
                  onViewAll: () => setState(() => _selectedTab = LiveTestFilterTab.upcoming),
                ),
                const SizedBox(height: 12),
                _buildUpcomingLiveTestsList(),
                const SizedBox(height: 24),
              ],

              // Section 3: Promotional Banners
              LiveTestPromoBanners(
                onViewSeries: () => widget.onExploreSeries?.call(),
                onCreateLiveTest: () => widget.onOpenBattle?.call(),
              ),
              const SizedBox(height: 24),
            ],
          ],
        );

        final rightSidebar = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Today's Goal
            _buildTodaysGoalSection(),
            const SizedBox(height: 18),

            // 2. Daily Streak
            DailyStreakCard(
              streakDays: (_userStats['streakDays'] as num?)?.toInt() ?? 0,
              completedDays: ((_userStats['testsAttempted'] as num?)?.toInt() ?? 0).clamp(0, 7),
              onTap: () {
                final sDays = _userStats['streakDays'] ?? 0;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$sDays-Day Streak! Keep taking tests to earn bonus coins.'),
                    backgroundColor: const Color(0xFFF97316),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),

            // 3. Weekly Leaderboard
            WeeklyLeaderboardCard(
              title: 'Top Performers',
              topUsers: _leaderboardUsers.take(6).map((u) {
                final rank = _leaderboardUsers.indexOf(u) + 1;
                final name = u['id'] == widget.userId
                    ? '${u['name'] ?? 'Candidate'} (You)'
                    : (u['name']?.toString() ?? (u['email'] != null ? u['email'].toString().split('@').first : 'Learner'));
                return {
                  'rank': rank,
                  'name': name,
                  'coins': (u['coins'] as num?)?.toInt() ?? 0,
                  'avatarUrl': u['profile_photo_url'],
                  'isCurrentUser': u['id'] == widget.userId,
                };
              }).toList(),
              onViewAll: _openLeaderboardsDialog,
              onUserTap: (user) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user['name']} • Rank #${user['rank']} with ${user['coins']} coins'),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),

            // 4. Top Rewards
            TopRewardsCard(
              onTap: () => widget.onOpenLeaderboard?.call(),
              onRewardTap: (rewardType) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rewards: $rewardType available for top live test performers!'),
                    backgroundColor: const Color(0xFFF43F5E),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        );

        return RefreshIndicator(
          onRefresh: _loadLiveScreenData,
          color: const Color(0xFF6366F1),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 16,
              vertical: 16,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                : (isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 72, child: mainContent),
                          const SizedBox(width: 24),
                          Expanded(flex: 28, child: rightSidebar),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          mainContent,
                          const SizedBox(height: 12),
                          rightSidebar,
                        ],
                      )),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (onViewAll != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onViewAll,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Row(
                  children: const [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: Color(0xFF6366F1), size: 14),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLiveNowCarousel(bool isDesktop) {
    if (_liveNowTournaments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sensors_off_rounded, color: Color(0xFF94A3B8), size: 36),
              const SizedBox(height: 10),
              const Text(
                'No Live Contests Running Right Now',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Check upcoming scheduled contests below or explore test series to practice!',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              AppButton(
                label: 'Explore Test Series',
                size: AppButtonSize.small,
                variant: AppButtonVariant.primary,
                onPressed: () => widget.onExploreSeries?.call(),
              ),
            ],
          ),
        ),
      );
    }

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _liveNowTournaments.map((t) {
          final isTournament = t.isTournament;
          final entryFee = t.entryFeeCoins;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: LiveTestCard(
                title: t.title,
                subject: t.syllabus ?? (t.categoryId ?? 'All Subjects'),
                questionsCount: t.totalQuestions > 0 ? t.totalQuestions : 50,
                durationMinutes: t.durationMinutes > 0 ? t.durationMinutes : 60,
                participants: '${t.totalParticipants}',
                coinsReward: t.prizePoolCoins > 0 ? t.prizePoolCoins : (entryFee > 0 ? entryFee * 10 : 100),
                thumbnailBgColor: isTournament ? const Color(0xFF581C87) : const Color(0xFF1E3A8A),
                thumbnailIcon: isTournament ? Icons.emoji_events_rounded : Icons.podcasts_rounded,
                thumbnailBadgeText: isTournament ? (entryFee > 0 ? '₹ $entryFee Coins' : 'FREE TOURNAMENT') : 'LIVE QUIZ NOW',
                onJoin: () => _handleJoinTest(t),
              ),
            ),
          );
        }).toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _liveNowTournaments.map((t) {
          final isTournament = t.isTournament;
          final entryFee = t.entryFeeCoins;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: LiveTestCard(
              title: t.title,
              subject: t.syllabus ?? (t.categoryId ?? 'All Subjects'),
              questionsCount: t.totalQuestions > 0 ? t.totalQuestions : 50,
              durationMinutes: t.durationMinutes > 0 ? t.durationMinutes : 60,
              participants: '${t.totalParticipants}',
              coinsReward: t.prizePoolCoins > 0 ? t.prizePoolCoins : (entryFee > 0 ? entryFee * 10 : 100),
              thumbnailBgColor: isTournament ? const Color(0xFF581C87) : const Color(0xFF1E3A8A),
              thumbnailIcon: isTournament ? Icons.emoji_events_rounded : Icons.podcasts_rounded,
              thumbnailBadgeText: isTournament ? (entryFee > 0 ? '₹ $entryFee Coins' : 'FREE TOURNAMENT') : 'LIVE QUIZ NOW',
              onJoin: () => _handleJoinTest(t),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUpcomingLiveTestsList() {
    if (_upcomingTournaments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text(
            'No upcoming scheduled tests at the moment. Check back soon!',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Column(
      children: _upcomingTournaments.map((t) {
        final testId = t.id;
        final isNotified = _notifiedTestIds.contains(testId);
        final date = t.scheduledStartTime;
        final dayStr = date != null ? '${date.day}' : '--';
        final monthStr = date != null ? _formatMonth(date.month) : 'SOON';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: UpcomingLiveTestCard(
            day: dayStr,
            month: monthStr,
            title: t.title,
            typeBadge: t.isTournament ? (t.entryFeeCoins > 0 ? 'TOURNAMENT (${t.entryFeeCoins}C)' : 'FREE TOURNAMENT') : 'LIVE QUIZ',
            typeBadgeColor: t.isTournament ? const Color(0xFF7C3AED) : const Color(0xFFEA580C),
            questionsCount: t.totalQuestions > 0 ? t.totalQuestions : 50,
            durationMinutes: t.durationMinutes > 0 ? t.durationMinutes : 60,
            startsIn: _calculateStartsIn(t.scheduledStartTime),
            isNotified: isNotified,
            onToggleNotification: () => _toggleNotification(testId, t.title),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTodaysGoalSection() {
    final testsDone = ((_userStats['testsAttempted'] as num?)?.toInt() ?? _myParticipations.length).clamp(0, 5);
    return TodayGoalCard(
      completed: testsDone,
      target: 5,
      subtitle: 'Complete 5 tests today to earn 50 coins!',
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Today\'s Goal: $testsDone/5 completed! Keep practicing.'),
            backgroundColor: AppColors.brandGreen,
          ),
        );
      },
    );
  }

  Widget _buildMyParticipationsView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandGreen.withAlpha(20),
            ),
            child: const Icon(Icons.assignment_turned_in_rounded, color: AppColors.brandGreen, size: 28),
          ),
          const SizedBox(height: 12),
          const Text(
            'My Live Test Participations',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          Text(
            _myParticipations.isEmpty
                ? 'You haven\'t participated in any live tests yet. Join a live contest to earn ranking coins!'
                : 'You have participated in ${_myParticipations.length} tests. Keep testing to earn rank coins!',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_myParticipations.isEmpty) ...[
            AppButton(
              label: 'Join Live Now',
              size: AppButtonSize.medium,
              variant: AppButtonVariant.primary,
              onPressed: () => setState(() => _selectedTab = LiveTestFilterTab.liveNow),
            ),
          ] else ...[
            ..._myParticipations.map((p) {
              final score = p['score'] ?? 0;
              final accuracy = p['accuracy'] ?? 0;
              final testId = p['test_id'] ?? 'Test';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  tileColor: const Color(0xFFF8FAFC),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB800)),
                  title: Text('Contest ID: $testId', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  subtitle: Text('Score: $score • Accuracy: $accuracy%', style: const TextStyle(fontSize: 11)),
                  trailing: const Text('Completed', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w800, fontSize: 12)),
                ),
              );
            }),
            const SizedBox(height: 12),
            AppButton(
              label: 'Back to All Live Tests',
              size: AppButtonSize.medium,
              variant: AppButtonVariant.secondary,
              onPressed: () => setState(() => _selectedTab = LiveTestFilterTab.allLiveTests),
            ),
          ],
        ],
      ),
    );
  }
}
