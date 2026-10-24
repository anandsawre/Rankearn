import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import 'models/leaderboard_model.dart';
import 'services/leaderboard_service.dart';
import 'components/leaderboard_hero_banner.dart';
import 'components/leaderboard_filter_tabs.dart';
import 'components/leaderboard_table.dart';
import 'components/leaderboard_podium.dart';
import 'components/leaderboard_mobile_list.dart';
import 'components/personal_rank_summary.dart';
import 'components/leaderboard_sidebar.dart';
import 'components/leaderboard_mobile_header.dart';

/// Production-ready Leaderboard Screen strictly matching Rankearn Desktop (Image 1)
/// and Mobile (Image 2) reference specifications.
class LeaderboardScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback? onOpenWallet;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenTests;
  final VoidCallback? onOpenBattle;
  final VoidCallback? onOpenRewards;

  const LeaderboardScreen({
    super.key,
    required this.profile,
    this.onOpenWallet,
    this.onOpenProfile,
    this.onOpenTests,
    this.onOpenBattle,
    this.onOpenRewards,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  LeaderboardScope _selectedScope = LeaderboardScope.global;
  LeaderboardPeriod _selectedPeriod = LeaderboardPeriod.allTime;
  String _selectedSubject = 'All Subjects';

  List<LeaderboardUserEntry> _entries = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await LeaderboardService.getLeaderboard(
      scope: _selectedScope,
      period: _selectedPeriod,
      subject: _selectedSubject,
      currentUserId: widget.profile.id,
    );
    if (!mounted) return;
    setState(() {
      _entries = data;
      _isLoading = false;
    });
  }

  void _onScopeChanged(LeaderboardScope scope) {
    if (_selectedScope == scope) return;
    setState(() => _selectedScope = scope);
    _loadData();
  }

  void _onPeriodChanged(LeaderboardPeriod period) {
    if (_selectedPeriod == period) return;
    setState(() => _selectedPeriod = period);
    _loadData();
  }

  void _onSubjectChanged(String subject) {
    if (_selectedSubject == subject) return;
    setState(() => _selectedSubject = subject);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEntry = LeaderboardService.getCurrentUserEntry(
      widget.profile,
    );
    final topWeekly = LeaderboardService.getTop3Weekly();

    return Scaffold(
      backgroundColor: AppColors.leaderboardBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 850;

          if (isDesktop) {
            return _buildDesktopLayout(
              currentUser: currentUserEntry,
              topWeekly: topWeekly,
              maxWidth: constraints.maxWidth,
            );
          } else {
            return _buildMobileLayout(currentUser: currentUserEntry);
          }
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DESKTOP LAYOUT (Image 1 Reference)
  // ---------------------------------------------------------------------------
  Widget _buildDesktopLayout({
    required LeaderboardUserEntry currentUser,
    required List<LeaderboardUserEntry> topWeekly,
    required double maxWidth,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Main Content (~70%) - Hero Banner, Filter Tabs, Leaderboard Table
          Expanded(
            flex: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Hero Banner
                const LeaderboardHeroBanner(),
                const SizedBox(height: AppSpacing.xl),

                // 2. Main Leaderboard Table (with Filter Tabs embedded inside the card)
                LeaderboardTable(
                  entries: _entries,
                  isLoading: _isLoading,
                  filterTabs: LeaderboardFilterTabs(
                    selectedScope: _selectedScope,
                    selectedPeriod: _selectedPeriod,
                    onScopeChanged: _onScopeChanged,
                    onPeriodChanged: _onPeriodChanged,
                    isDesktop: true,
                  ),
                  onUserTap: (user) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Viewing ${user.name} (#${user.rank}) profile',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.huge),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xxl),

          // Right: Dedicated Sidebar (~30%) - Your Rank, Top 3 This Week, Filters, Climb Tips
          Expanded(
            flex: 30,
            child: LeaderboardSidebar(
              currentUser: currentUser,
              topWeekly: topWeekly,
              selectedScope: _selectedScope,
              selectedPeriod: _selectedPeriod,
              selectedSubject: _selectedSubject,
              onScopeChanged: _onScopeChanged,
              onPeriodChanged: _onPeriodChanged,
              onSubjectChanged: _onSubjectChanged,
              onViewProfile: widget.onOpenProfile,
              onViewAllWeekly: () {
                setState(() => _selectedPeriod = LeaderboardPeriod.weekly);
                _loadData();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE LAYOUT (Image 2 Reference)
  // ---------------------------------------------------------------------------
  Widget _buildMobileLayout({required LeaderboardUserEntry currentUser}) {
    final first = _entries.isNotEmpty
        ? _entries.firstWhere((e) => e.rank == 1, orElse: () => _entries[0])
        : currentUser;
    final second = _entries.length > 1
        ? _entries.firstWhere((e) => e.rank == 2, orElse: () => _entries[1])
        : currentUser;
    final third = _entries.length > 2
        ? _entries.firstWhere((e) => e.rank == 3, orElse: () => _entries[2])
        : currentUser;

    return Column(
      children: [
        // 1. Mobile Top Green Header (matching Wheel Screen's SpinHeader)
        LeaderboardMobileHeader(
          selectedScope: _selectedScope,
          onScopeChanged: _onScopeChanged,
        ),

        // 2. Main Scrollable Content Area
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePaddingMobile,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top-Three 3D Podium
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.huge),
                      child: CircularProgressIndicator(
                        color: AppColors.leaderboardGreen,
                      ),
                    ),
                  )
                else ...[
                  LeaderboardPodium(
                    first: first,
                    second: second,
                    third: third,
                    onUserTap: (user) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Podium rank #${user.rank}: ${user.name} (${user.coinsEarned} coins)',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Ranked User List (with Filter Tabs embedded inside the card)
                  LeaderboardMobileList(
                    entries: _entries,
                    isLoading: _isLoading,
                    filterTabs: LeaderboardFilterTabs(
                      selectedScope: _selectedScope,
                      selectedPeriod: _selectedPeriod,
                      onScopeChanged: _onScopeChanged,
                      onPeriodChanged: _onPeriodChanged,
                      isDesktop: false,
                    ),
                    onUserTap: (user) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('User rank #${user.rank}: ${user.name}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Personal Rank Summary Card (Sticky/Bottom card for Vikram Singh)
                  PersonalRankSummary(
                    userEntry: currentUser,
                    onTap: widget.onOpenProfile,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
