import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

/// LiveTestsScreen - Production-Quality Live Tests Tab
/// Implemented to reproduce the Rankearn Live Tests reference design.
class LiveTestsScreen extends StatefulWidget {
  final int userCoins;
  final void Function(TestModel test)? onStartTest;
  final VoidCallback? onOpenBattle;
  final VoidCallback? onOpenLeaderboard;
  final VoidCallback? onExploreSeries;

  const LiveTestsScreen({
    super.key,
    required this.userCoins,
    this.onStartTest,
    this.onOpenBattle,
    this.onOpenLeaderboard,
    this.onExploreSeries,
  });

  @override
  State<LiveTestsScreen> createState() => _LiveTestsScreenState();
}

class _LiveTestsScreenState extends State<LiveTestsScreen> {
  LiveTestFilterTab _selectedTab = LiveTestFilterTab.allLiveTests;
  final Set<String> _notifiedTestIds = <String>{};

  // Reference Live Now Tests Data
  final List<Map<String, dynamic>> _liveNowTests = [
    {
      'id': 'live_rrb_01',
      'title': 'RRB Technician Special Live Test',
      'subject': 'General Science',
      'questions': 100,
      'duration': 60,
      'participants': '2.4K',
      'coins': 200,
      'bgColor': const Color(0xFF0C4A6E),
      'icon': Icons.directions_railway_rounded,
      'badge': 'RRB Technician',
    },
    {
      'id': 'live_all_india_quiz_02',
      'title': 'All India Mega Quiz',
      'subject': 'Mixed Subjects',
      'questions': 50,
      'duration': 30,
      'participants': '1.1K',
      'coins': 100,
      'bgColor': const Color(0xFF581C87),
      'icon': Icons.emoji_events_rounded,
      'badge': 'Mega Quiz',
    },
    {
      'id': 'live_maths_speed_03',
      'title': 'Maths Speed Test',
      'subject': 'Mathematics',
      'questions': 25,
      'duration': 20,
      'participants': '856',
      'coins': 50,
      'bgColor': const Color(0xFFBE123C),
      'icon': Icons.calculate_rounded,
      'badge': 'Speed Test',
    },
  ];

  // Reference Upcoming Live Tests Data
  final List<Map<String, dynamic>> _upcomingTests = [
    {
      'id': 'up_01',
      'day': '20',
      'month': 'Oct',
      'title': 'General Science Mega Test',
      'badge': 'SCORE BASED',
      'badgeColor': Color(0xFF2587F8),
      'questions': 100,
      'duration': 60,
      'startsIn': '2h 15m',
    },
    {
      'id': 'up_02',
      'day': '21',
      'month': 'Oct',
      'title': 'Current Affairs Live Test',
      'badge': 'ALL INDIA',
      'badgeColor': Color(0xFF2587F8),
      'questions': 50,
      'duration': 30,
      'startsIn': '1 day',
    },
    {
      'id': 'up_03',
      'day': '22',
      'month': 'Oct',
      'title': 'Reasoning Challenge',
      'badge': 'RANK BASED',
      'badgeColor': Color(0xFF2587F8),
      'questions': 50,
      'duration': 30,
      'startsIn': '2 days',
    },
  ];

  void _handleJoinTest(String title, int duration) {
    if (widget.onStartTest != null) {
      final test = TestModel(
        id: 'live_${title.toLowerCase().replaceAll(' ', '_')}',
        title: title,
        totalQuestions: 20,
        durationMinutes: duration,
        testMode: 'tournament',
        isTournament: true,
      );
      widget.onStartTest!(test);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joining $title... Good luck!'),
          backgroundColor: AppColors.brandGreen,
        ),
      );
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLeaderboardRow(1, 'Aman Kumar (You)', '1,250 Coins', true),
              const Divider(height: 12),
              _buildLeaderboardRow(2, 'Priya Sharma', '1,180 Coins', false),
              const Divider(height: 12),
              _buildLeaderboardRow(3, 'Rohit Verma', '990 Coins', false),
              const Divider(height: 12),
              _buildLeaderboardRow(4, 'Sneha Patel', '850 Coins', false),
            ],
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
              color: rank == 1 ? const Color(0xFFFFD633) : (rank == 2 ? const Color(0xFFCBD5E1) : const Color(0xFFFED7AA)),
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

  void _openCreateTestDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.add_circle_outline_rounded, color: AppColors.brandGreen, size: 24),
              SizedBox(width: 8),
              Text('Host Live Test', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Create your custom room, invite your friends, and compete in real-time!',
                style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Test Room Name',
                  hintText: 'e.g. Science Champions Battle',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test room created! Room code: RNK-7842 copied.'),
                    backgroundColor: AppColors.brandGreen,
                  ),
                );
              },
              child: const Text('Create Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 990;

        final mainContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Live Tests Hero Banner
            LiveTestsHeroBanner(
              borderRadius: BorderRadius.circular(12),
              imageAssetPath: 'assets/images/live_tests_hero_mascot.jpg',
              onJoinLiveTest: () => _handleJoinTest('RRB Technician Special Live Test', 60),
            ),
            const SizedBox(height: 16),

            // 2. Four Statistics Cards (Live Now, Participants, Coins Earned, Rank Position)
            LiveTestMetricsRow(
              liveNowCount: 3,
              participants: '5.2K',
              coinsEarned: '1,250',
              rankPosition: '#1256',
              onLiveNowTap: () => setState(() => _selectedTab = LiveTestFilterTab.liveNow),
              onParticipantsTap: _openLeaderboardsDialog,
              onCoinsTap: () => widget.onOpenLeaderboard?.call(),
              onRankTap: _openLeaderboardsDialog,
            ),
            const SizedBox(height: 16),

            // 3. Navigation Filter Tabs (Live Tests, Upcoming, Live Now, My Participations, Leaderboards)
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

            // Content filtered by active tab
            if (_selectedTab == LiveTestFilterTab.myParticipations)
              _buildMyParticipationsView()
            else ...[
              // Section 1: Live Now Carousel
              if (_selectedTab == LiveTestFilterTab.allLiveTests ||
                  _selectedTab == LiveTestFilterTab.liveNow) ...[
                _buildSectionHeader(
                  title: 'Live Now',
                  icon: Icons.sensors_rounded,
                  iconColor: const Color(0xFFF43F5E),
                  onViewAll: () => setState(() => _selectedTab = LiveTestFilterTab.liveNow),
                ),
                const SizedBox(height: 12),
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

              // Section 3: Promotional Banners (Live Test Series & Create a Live Test)
              LiveTestPromoBanners(
                onViewSeries: () {
                  if (widget.onExploreSeries != null) {
                    widget.onExploreSeries!();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening Live Test Series catalog...'),
                        backgroundColor: Color(0xFF6B21A8),
                      ),
                    );
                  }
                },
                onCreateLiveTest: _openCreateTestDialog,
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
              streakDays: 7,
              completedDays: 5,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('7-Day Streak Active! Keep practicing every day to earn bonus coins.'),
                    backgroundColor: Color(0xFFF97316),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),

            // 3. Weekly Leaderboard
            WeeklyLeaderboardCard(
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

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : 16,
            vertical: 16,
          ),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Column (~72%)
                    Expanded(
                      flex: 72,
                      child: mainContent,
                    ),
                    const SizedBox(width: 24),

                    // Right Sidebar (~28%)
                    Expanded(
                      flex: 28,
                      child: rightSidebar,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    mainContent,
                    const SizedBox(height: 12),
                    rightSidebar,
                  ],
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
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF6366F1),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLiveNowCarousel(bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _liveNowTests.map((t) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: LiveTestCard(
                title: t['title'] as String,
                subject: t['subject'] as String,
                questionsCount: t['questions'] as int,
                durationMinutes: t['duration'] as int,
                participants: t['participants'] as String,
                coinsReward: t['coins'] as int,
                thumbnailBgColor: t['bgColor'] as Color?,
                thumbnailIcon: t['icon'] as IconData,
                thumbnailBadgeText: t['badge'] as String?,
                onJoin: () => _handleJoinTest(t['title'] as String, t['duration'] as int),
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
        children: _liveNowTests.map((t) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: LiveTestCard(
              title: t['title'] as String,
              subject: t['subject'] as String,
              questionsCount: t['questions'] as int,
              durationMinutes: t['duration'] as int,
              participants: t['participants'] as String,
              coinsReward: t['coins'] as int,
              thumbnailBgColor: t['bgColor'] as Color?,
              thumbnailIcon: t['icon'] as IconData,
              thumbnailBadgeText: t['badge'] as String?,
              onJoin: () => _handleJoinTest(t['title'] as String, t['duration'] as int),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUpcomingLiveTestsList() {
    return Column(
      children: _upcomingTests.map((t) {
        final testId = t['id'] as String;
        final isNotified = _notifiedTestIds.contains(testId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: UpcomingLiveTestCard(
            day: t['day'] as String,
            month: t['month'] as String,
            title: t['title'] as String,
            typeBadge: t['badge'] as String,
            typeBadgeColor: t['badgeColor'] as Color?,
            questionsCount: t['questions'] as int,
            durationMinutes: t['duration'] as int,
            startsIn: t['startsIn'] as String,
            isNotified: isNotified,
            onToggleNotification: () => _toggleNotification(testId, t['title'] as String),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTodaysGoalSection() {
    return TodayGoalCard(
      completed: 3,
      target: 5,
      subtitle: 'Complete 5 tests today to earn 50 coins!',
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Today\'s Goal: Complete 2 more live tests to claim 50 bonus coins!'),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'You participated in 2 live contests this week. Keep testing to earn rank coins!',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: const Color(0xFFF8FAFC),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB800)),
            title: const Text('BPSC 70th Prelims Mega Test', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            subtitle: const Text('Rank #14 • Score: 92/100', style: TextStyle(fontSize: 11)),
            trailing: const Text('+120 Coins', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w800, fontSize: 12)),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Back to All Live Tests',
            size: AppButtonSize.medium,
            variant: AppButtonVariant.secondary,
            onPressed: () => setState(() => _selectedTab = LiveTestFilterTab.allLiveTests),
          ),
        ],
      ),
    );
  }
}
