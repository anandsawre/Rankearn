import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import '../dialogs/tournament_details_dialog.dart';
import '../dialogs/tournament_leaderboard_dialog.dart';
import '../dialogs/tournament_rules_dialog.dart';
import '../widgets/tournament_card.dart';
import '../widgets/tournament_filter_chips.dart';
import '../widgets/tournament_hero_banner.dart';
import '../widgets/tournament_right_panel.dart';
import '../widgets/tournament_shortcuts.dart';
import '../widgets/tournament_stats_cards.dart';
import '../widgets/upcoming_tournament_card.dart';

/// Full-Featured Responsive Tournament Dashboard Screen
/// Strictly matches Desktop and Mobile reference UI designs
class TournamentScreen extends StatefulWidget {
  final UserProfile profile;
  final void Function(TestModel test) onStartTest;
  final VoidCallback? onOpenBattle;
  final VoidCallback? onOpenLeaderboard;
  final VoidCallback? onOpenRewards;
  final void Function(int fee)? onCoinDeducted;

  const TournamentScreen({
    super.key,
    required this.profile,
    required this.onStartTest,
    this.onOpenBattle,
    this.onOpenLeaderboard,
    this.onOpenRewards,
    this.onCoinDeducted,
  });

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  final ContestsRepository _contestsRepo = ContestsRepository();
  final TestsRepository _testsRepo = TestsRepository();

  bool _isLoading = true;
  String? _errorMessage;
  List<TestModel> _allTournaments = [];
  Set<String> _registeredIds = {};
  List<Map<String, dynamic>> _leaderboardUsers = [];
  Map<String, dynamic> _userStats = {};

  String _selectedFilter = 'all'; // all, running, upcoming, completed, free, paid
  String _activeShortcut = 'all'; // all, my, leaderboard, rewards, rules

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final futures = await Future.wait([
        _contestsRepo.getTournaments(),
        _contestsRepo.getUserRegisteredTournamentIds(widget.profile.id),
        _contestsRepo.getLeaderboardUsers(limit: 10),
        _testsRepo.getUserStats(widget.profile.id),
      ]);

      if (!mounted) return;

      final tourneyRes = futures[0] as Result<List<TestModel>>;
      final regIds = futures[1] as Set<String>;
      final leadRes = futures[2] as Result<List<Map<String, dynamic>>>;
      final stats = futures[3] as Map<String, dynamic>;

      List<TestModel> tournaments = [];
      if (tourneyRes case Success(:final data)) {
        tournaments = data;
      }

      List<Map<String, dynamic>> leaderboard = [];
      if (leadRes case Success(:final data)) {
        leaderboard = data;
      }

      setState(() {
        _allTournaments = tournaments;
        _registeredIds = regIds;
        _leaderboardUsers = leaderboard;
        _userStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load tournaments. Please check your network.';
        _isLoading = false;
      });
    }
  }

  List<TestModel> get _filteredTournaments {
    if (_activeShortcut == 'my') {
      return _allTournaments
          .where((t) => _registeredIds.contains(t.id))
          .toList();
    }

    switch (_selectedFilter) {
      case 'running':
        return _allTournaments
            .where((t) => t.isLive || (!t.isPast && !t.isUpcoming))
            .toList();
      case 'upcoming':
        return _allTournaments.where((t) => t.isUpcoming).toList();
      case 'completed':
        return _allTournaments.where((t) => t.isPast).toList();
      case 'free':
        return _allTournaments.where((t) => t.entryFeeCoins == 0).toList();
      case 'paid':
        return _allTournaments.where((t) => t.entryFeeCoins > 0).toList();
      default:
        return _allTournaments;
    }
  }

  List<TestModel> get _runningTournaments {
    return _allTournaments
        .where((t) => t.isLive || (!t.isPast && !t.isUpcoming))
        .toList();
  }

  List<TestModel> get _upcomingTournaments {
    return _allTournaments.where((t) => t.isUpcoming).toList();
  }

  Future<void> _handleParticipate(TestModel tournament) async {
    final isRegistered = _registeredIds.contains(tournament.id);

    // If already registered or joined, start test directly
    if (isRegistered) {
      widget.onStartTest(tournament);
      return;
    }

    final entryFee = tournament.entryFeeCoins;
    final isFree = entryFee == 0;

    // Show Confirmation Dialog
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isFree
                    ? const Color(0xFFE6F8EF)
                    : const Color(0xFFFEF3C7),
                borderRadius: AppRadii.borderMd,
              ),
              alignment: Alignment.center,
              child: Icon(
                isFree
                    ? Icons.celebration_rounded
                    : Icons.monetization_on_rounded,
                color: isFree
                    ? AppColors.brandGreen
                    : const Color(0xFFD97706),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Join Contest',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tournament.title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFree
                  ? 'Registration is completely FREE! Compete for the All-India leaderboard rank and prize pool.'
                  : 'Entry Fee: $entryFee Coins will be deducted from your Rankearn wallet balance (${widget.profile.coins} Coins available).',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (!isFree && widget.profile.coins < entryFee) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: AppRadii.borderMd,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: Color(0xFFDC2626), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Insufficient coin balance! Please earn or top up coins to participate.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB91C1C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: (!isFree && widget.profile.coins < entryFee)
                ? null
                : () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.borderMd,
              ),
              elevation: 0,
            ),
            child: Text(isFree ? 'Confirm & Join' : 'Pay $entryFee Coins & Join'),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    // Show join progress
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.brandGreen),
      ),
    );

    final joinRes = await _contestsRepo.joinTournamentSafe(
      testId: tournament.id,
      userId: widget.profile.id,
      entryFee: entryFee,
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // dismiss loader

    if (joinRes case Success()) {
      setState(() {
        _registeredIds.add(tournament.id);
      });
      widget.onCoinDeducted?.call(entryFee);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully registered for ${tournament.title}!'),
          backgroundColor: AppColors.brandGreen,
        ),
      );
      widget.onStartTest(tournament);
    } else if (joinRes case Failure(:final message)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  void _onShortcutTap(String shortcut) {
    setState(() => _activeShortcut = shortcut);

    switch (shortcut) {
      case 'all':
        setState(() => _selectedFilter = 'all');
        break;
      case 'my':
        // Filter set to my participations
        break;
      case 'leaderboard':
        TournamentLeaderboardDialog.show(
          context,
          leaderboardUsers: _leaderboardUsers,
          currentUserId: widget.profile.id,
        );
        break;
      case 'rewards':
        widget.onOpenRewards?.call();
        break;
      case 'rules':
        TournamentRulesDialog.show(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.brandPurple),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 990;

                    return RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppColors.brandGreen,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 24 : 16,
                          vertical: isDesktop ? 20 : 12,
                        ),
                        child: isDesktop
                            ? _buildDesktopLayout()
                            : _buildMobileLayout(),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildDesktopLayout() {
    final running = _runningTournaments;
    final displayTournaments = _filteredTournaments;
    final topUpcoming = _upcomingTournaments.isNotEmpty
        ? _upcomingTournaments.first
        : (_allTournaments.isNotEmpty ? _allTournaments.last : null);

    final rankStr = _userStats['rank']?.toString() ?? '#1';
    final streakDays = (_userStats['streakDays'] as num?)?.toInt() ?? 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Purple Hero Banner
        TournamentHeroBanner(
          isDesktop: true,
          onExploreTap: () {
            setState(() {
              _activeShortcut = 'all';
              _selectedFilter = 'all';
            });
          },
        ),
        const SizedBox(height: 18),

        // 2. Four Stats Cards
        TournamentStatsCards(
          isDesktop: true,
          activeCount: running.isNotEmpty ? running.length : 3,
          participationCount: _registeredIds.isNotEmpty ? _registeredIds.length : 6,
          myRank: rankStr,
          totalRewards: '₹2,500',
        ),
        const SizedBox(height: 18),

        // 3. Quick Navigation Shortcuts
        TournamentShortcuts(
          isDesktop: true,
          activeShortcut: _activeShortcut,
          onShortcutTap: _onShortcutTap,
        ),
        const SizedBox(height: 22),

        // 4. Main Body: Left Content + Right Panel
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Content Section (Tournaments List)
            Expanded(
              flex: 68,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Filter Chips Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEDE9FE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flag_rounded,
                          size: 16,
                          color: AppColors.brandPurple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Contests (${displayTournaments.length})',
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      TournamentFilterChips(
                        selectedFilter: _selectedFilter,
                        totalCount: displayTournaments.length,
                        onFilterChanged: (filter) {
                          setState(() {
                            _activeShortcut = 'all';
                            _selectedFilter = filter;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tournament Cards List
                  if (displayTournaments.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayTournaments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final tourney = displayTournaments[index];
                        final isReg = _registeredIds.contains(tourney.id);

                        return TournamentCard(
                          tournament: tourney,
                          isDesktop: true,
                          isRegistered: isReg,
                          onParticipate: () => _handleParticipate(tourney),
                          onViewDetails: () => TournamentDetailsDialog.show(
                            context,
                            tournament: tourney,
                            isRegistered: isReg,
                            onParticipate: () => _handleParticipate(tourney),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(width: 22),

            // Right Information Panel
            SizedBox(
              width: 320,
              child: TournamentRightPanel(
                leaderboardUsers: _leaderboardUsers,
                upcomingTournament: topUpcoming,
                streakDays: streakDays,
                completedToday: 3,
                onViewAllRankers: () => TournamentLeaderboardDialog.show(
                  context,
                  leaderboardUsers: _leaderboardUsers,
                  currentUserId: widget.profile.id,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final running = _runningTournaments;
    final upcoming = _upcomingTournaments;
    final displayTournaments = _filteredTournaments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Purple Hero Banner
        TournamentHeroBanner(
          isDesktop: false,
          onExploreTap: () {
            setState(() {
              _activeShortcut = 'all';
              _selectedFilter = 'all';
            });
          },
        ),
        const SizedBox(height: 14),

        // 2. Two Stats Cards
        TournamentStatsCards(
          isDesktop: false,
          activeCount: running.isNotEmpty ? running.length : 3,
          participationCount: _registeredIds.isNotEmpty ? _registeredIds.length : 6,
          myRank: _userStats['rank']?.toString() ?? '#1',
          totalRewards: '₹2,500',
        ),
        const SizedBox(height: 14),

        // 3. Four Colored Shortcut Pods
        TournamentShortcuts(
          isDesktop: false,
          activeShortcut: _activeShortcut,
          onShortcutTap: _onShortcutTap,
        ),
        const SizedBox(height: 16),

        // 4. Horizontal Scrolling Filters
        TournamentFilterChips(
          selectedFilter: _selectedFilter,
          totalCount: displayTournaments.length,
          onFilterChanged: (filter) {
            setState(() {
              _activeShortcut = 'all';
              _selectedFilter = filter;
            });
          },
        ),
        const SizedBox(height: 18),

        // 5. Running Tournaments Section
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFFF3E8FF),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.brandPurple,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Running Contests',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () => setState(() => _selectedFilter = 'running'),
              child: const Row(
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandPurple,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: AppColors.brandPurple,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Running Cards List
        if (displayTournaments.isEmpty)
          _buildEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayTournaments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tourney = displayTournaments[index];
              final isReg = _registeredIds.contains(tourney.id);

              return TournamentCard(
                tournament: tourney,
                isDesktop: false,
                isRegistered: isReg,
                onParticipate: () => _handleParticipate(tourney),
                onViewDetails: () => TournamentDetailsDialog.show(
                  context,
                  tournament: tourney,
                  isRegistered: isReg,
                  onParticipate: () => _handleParticipate(tourney),
                ),
              );
            },
          ),

        const SizedBox(height: 22),

        // 6. Upcoming Tournaments Section
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFFF3E8FF),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.brandPurple,
                size: 15,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Upcoming Contests',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () => setState(() => _selectedFilter = 'upcoming'),
              child: const Row(
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandPurple,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: AppColors.brandPurple,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (upcoming.isNotEmpty)
          UpcomingTournamentCard(
            tournament: upcoming.first,
            isDesktop: false,
          )
        else if (_allTournaments.isNotEmpty)
          UpcomingTournamentCard(
            tournament: _allTournaments.last,
            isDesktop: false,
          ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.emoji_events_outlined,
              size: 28,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Contests Found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No contests match the selected filter category.',
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedFilter = 'all';
                _activeShortcut = 'all';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.borderMd,
              ),
            ),
            child: const Text('Show All Contests'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.borderMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
