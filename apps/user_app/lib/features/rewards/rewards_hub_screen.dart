import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

/// Rankearn Rewards Tab Screen
/// Production-ready, pixel-perfect responsive implementation matching reference design.
class RewardsHubScreen extends StatefulWidget {
  final int userCoins;
  final UserProfile profile;
  final void Function(int deltaCoins)? onCoinUpdate;
  final VoidCallback? onOpenWallet;
  final VoidCallback? onOpenTests;
  final VoidCallback? onOpenBattle;
  final VoidCallback? onOpenSpinWheel;

  const RewardsHubScreen({
    super.key,
    required this.userCoins,
    required this.profile,
    this.onCoinUpdate,
    this.onOpenWallet,
    this.onOpenTests,
    this.onOpenBattle,
    this.onOpenSpinWheel,
  });

  @override
  State<RewardsHubScreen> createState() => _RewardsHubScreenState();
}

class _RewardsHubScreenState extends State<RewardsHubScreen> {
  final RewardRepository _repository = RewardRepository();

  RewardCategoryTab _selectedTab = RewardCategoryTab.all;
  RewardSummaryStatsModel _stats = const RewardSummaryStatsModel();
  List<RewardTaskModel> _dailyTasks = [];
  List<WeeklyRewardTaskModel> _weeklyTasks = [];

  @override
  void initState() {
    super.initState();
    _stats = RewardSummaryStatsModel(
      myCoins: widget.userCoins > 0 ? widget.userCoins : 1250,
      dailyStreakDays: 7,
      myRank: 1256,
      totalEarned: widget.profile.totalEarned > 0 ? widget.profile.totalEarned : 12500,
    );
    _loadRewardsData();
  }

  Future<void> _loadRewardsData() async {
    final statsRes = await _repository.getRewardStats(
      userCoins: widget.userCoins,
      totalEarned: widget.profile.totalEarned,
    );
    final dailyRes = await _repository.getDailyTasks();
    final weeklyRes = await _repository.getWeeklyTasks();

    if (!mounted) return;
    setState(() {
      if (statsRes is Success<RewardSummaryStatsModel>) _stats = statsRes.data;
      if (dailyRes is Success<List<RewardTaskModel>>) _dailyTasks = dailyRes.data;
      if (weeklyRes is Success<List<WeeklyRewardTaskModel>>) _weeklyTasks = weeklyRes.data;
    });
  }

  // --- How To Earn Informational Modal ---
  void _openHowToEarnModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  Icon(Icons.help_outline_rounded, color: Color(0xFF10B981), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'How to Earn Coins?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111A4B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildHowToEarnItem(
                icon: Icons.assignment_turned_in_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'Attempt Daily Tests',
                subtitle: 'Score 70% or more on tests to earn up to +150 bonus coins each day.',
              ),
              _buildHowToEarnItem(
                icon: Icons.sports_esports_rounded,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Win 1v1 Quiz Battles',
                subtitle: 'Challenge live students across India and multiply your coin pool with instant victories.',
              ),
              _buildHowToEarnItem(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFF97316),
                title: 'Keep Daily Streaks',
                subtitle: 'Practice consistently every day for 7 consecutive days to unlock mega weekly milestone chests.',
              ),
              _buildHowToEarnItem(
                icon: Icons.share_rounded,
                iconColor: const Color(0xFF2587F8),
                title: 'Refer Your Friends',
                subtitle: 'Get 100 free coins instantly as soon as your invited friend signs up with your referral code.',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B96B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Got It!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHowToEarnItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111A4B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Invite Friends Modal Flow ---
  void _openInviteModal() {
    final referralCode = widget.profile.referralCode ?? 'RANK123';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.share_rounded, color: Color(0xFF00B96B), size: 30),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Invite Friends & Earn 100 Coins',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111A4B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Share your unique code with your classmates. You both get 100 bonus coins on signup!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Referral Code',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                        Text(
                          referralCode,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111A4B),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: referralCode));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Referral code copied to clipboard!'),
                            backgroundColor: Color(0xFF00B96B),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B96B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- Top Rewards Details Modal ---
  void _openRewardsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  Icon(Icons.card_giftcard_rounded, color: Color(0xFFF43F5E), size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Rankearn Rewards Catalog',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111A4B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const ListTile(
                leading: Icon(Icons.monetization_on_rounded, color: Color(0xFFF59E0B)),
                title: Text('Instant Coins', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Earn coins directly into your wallet for all completed tasks and victories.'),
              ),
              const ListTile(
                leading: Icon(Icons.emoji_events_rounded, color: Color(0xFFEAB308)),
                title: Text('Rank Badges & Titles', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Unlock prestigious profile badges as you level up your academic ranking.'),
              ),
              const ListTile(
                leading: Icon(Icons.workspace_premium_rounded, color: Color(0xFF2587F8)),
                title: Text('Verified Certificates', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Earn official completion and merit certificates for top performance.'),
              ),
              const ListTile(
                leading: Icon(Icons.card_giftcard_rounded, color: Color(0xFF8B5CF6)),
                title: Text('Special Gifts & Tournament Passes', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Top performers receive special gifts and free entries into prize contests.'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleTaskAction(RewardTaskModel task) {
    if (task.actionType == RewardTaskActionType.goNow) {
      if (task.id == 'daily_1' || task.id == 'daily_2') {
        widget.onOpenTests?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Starting: ${task.title}...'),
            backgroundColor: const Color(0xFF00B96B),
          ),
        );
      }
    } else if (task.actionType == RewardTaskActionType.claim) {
      widget.onCoinUpdate?.call(task.coinsReward);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Claimed +${task.coinsReward} Coins successfully!'),
          backgroundColor: const Color(0xFF00B96B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 990;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 990;

        // Main Column Content (~70% on desktop)
        final mainContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Banner
            RewardsHeroBanner(
              borderRadius: BorderRadius.circular(16),
              onHowToEarn: _openHowToEarnModal,
            ),
            const SizedBox(height: 18),

            // 2. Summary Statistics (4 Cards)
            RewardMetricsRow(
              myCoins: '${_stats.myCoins}',
              dailyStreak: '${_stats.dailyStreakDays} Days',
              myRank: '#${_stats.myRank}',
              totalEarned: '${_stats.totalEarned}',
              onMyCoinsTap: widget.onOpenWallet,
              onDailyStreakTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('7-Day Streak active! Keep learning to earn bonus rewards.'),
                    backgroundColor: Color(0xFFF97316),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),

            // 3. Category Filter Tabs
            RewardCategoryTabs(
              selectedTab: _selectedTab,
              onTabSelected: (tab) => setState(() => _selectedTab = tab),
            ),
            const SizedBox(height: 20),

            // 4. Daily Tasks Section
            if (_selectedTab == RewardCategoryTab.all || _selectedTab == RewardCategoryTab.daily) ...[
              _buildDailyTasksSection(),
              const SizedBox(height: 24),
            ],

            // 5. Weekly Tasks Section
            if (_selectedTab == RewardCategoryTab.all || _selectedTab == RewardCategoryTab.weekly) ...[
              _buildWeeklyTasksSection(isDesktop, isTablet),
              const SizedBox(height: 24),
            ],

            // 6. Refer & Earn Banner
            ReferEarnCard(
              referralCode: widget.profile.referralCode ?? 'RANK123',
              onInviteNow: _openInviteModal,
            ),
            const SizedBox(height: 24),
          ],
        );

        // Right Sidebar (~30% on desktop)
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
                    const SizedBox(height: 20),
                    rightSidebar,
                  ],
                ),
        );
      },
    );
  }

  // --- Daily Tasks Section ---
  Widget _buildDailyTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row: Calendar Icon + Title + Resets timer
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 720;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: Color(0xFF6428F5),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Daily Tasks',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111A4B),
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (!isNarrow) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'Complete daily tasks and earn coins',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF64748B),
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Resets in 14h 25m',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isNarrow) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Complete daily tasks and earn coins',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 12),

        // List of Daily Task Cards
        for (int i = 0; i < _dailyTasks.length; i++) ...[
          DailyTaskCard(
            icon: _dailyTasks[i].icon,
            iconBgColor: _dailyTasks[i].iconBgColor,
            iconColor: _dailyTasks[i].iconColor,
            title: _dailyTasks[i].title,
            description: _dailyTasks[i].description,
            coinsReward: _dailyTasks[i].coinsReward,
            actionType: switch (_dailyTasks[i].actionType) {
              RewardTaskActionType.goNow => DailyTaskActionType.goNow,
              RewardTaskActionType.claim => DailyTaskActionType.claim,
              RewardTaskActionType.completed => DailyTaskActionType.completed,
              RewardTaskActionType.progressPill => DailyTaskActionType.progressPill,
            },
            progressText: _dailyTasks[i].progressText,
            onAction: () => _handleTaskAction(_dailyTasks[i]),
          ),
          if (i < _dailyTasks.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  // --- Weekly Tasks Section ---
  Widget _buildWeeklyTasksSection(bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row: Trophy Icon + Title + Resets timer
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 720;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFFF59E0B),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Weekly Tasks',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111A4B),
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (!isNarrow) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'Complete weekly goals for bigger rewards',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF64748B),
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Resets in 4d 14h',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isNarrow) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Complete weekly goals for bigger rewards',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 12),

        // Responsive Grid for Weekly Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 620;

            if (isNarrow) {
              return Column(
                children: [
                  for (int i = 0; i < _weeklyTasks.length; i++) ...[
                    WeeklyTaskCard(
                      icon: _weeklyTasks[i].icon,
                      iconBgColor: _weeklyTasks[i].iconBgColor,
                      iconColor: _weeklyTasks[i].iconColor,
                      title: _weeklyTasks[i].title,
                      progressString: _weeklyTasks[i].progressString,
                      progressRatio: _weeklyTasks[i].progressRatio,
                      coinsReward: _weeklyTasks[i].coinsReward,
                      onTap: widget.onOpenTests,
                    ),
                    if (i < _weeklyTasks.length - 1) const SizedBox(height: 10),
                  ],
                ],
              );
            }

            return Row(
              children: [
                for (int i = 0; i < _weeklyTasks.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: WeeklyTaskCard(
                      icon: _weeklyTasks[i].icon,
                      iconBgColor: _weeklyTasks[i].iconBgColor,
                      iconColor: _weeklyTasks[i].iconColor,
                      title: _weeklyTasks[i].title,
                      progressString: _weeklyTasks[i].progressString,
                      progressRatio: _weeklyTasks[i].progressRatio,
                      coinsReward: _weeklyTasks[i].coinsReward,
                      onTap: widget.onOpenTests,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  // --- Right Sidebar (Matching Reference Design) ---
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
          unitLabel: 'Tests',
          subtitle: 'Complete 5 tests today to earn 50 coins!',
          onTap: widget.onOpenTests ?? () {},
        ),
        const SizedBox(height: 18),

        // 2. Daily Streak
        DailyStreakCard(
          streakDays: 7,
          completedDays: 5,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('7-Day Streak Active! Keep completing daily tasks.'),
                backgroundColor: Color(0xFFF97316),
              ),
            );
          },
        ),
        const SizedBox(height: 18),

        // 3. Quick Actions & Rewards
        QuickActionsRewardsCard(
          onSpinWheel: widget.onOpenSpinWheel,
          onQuizBattle: widget.onOpenBattle,
        ),
        const SizedBox(height: 18),

        // 4. Top Rewards
        BattleTopRewardsCard(
          title: 'Top Rewards',
          subtitle: null,
          onViewAll: _openRewardsModal,
          onRewardTap: (rewardType) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$rewardType available in Rewards Catalog!'),
                backgroundColor: const Color(0xFFF43F5E),
              ),
            );
          },
        ),
      ],
    );
  }
}
