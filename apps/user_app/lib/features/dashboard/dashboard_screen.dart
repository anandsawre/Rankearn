import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class DashboardScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onStartTest;
  final void Function(TestModel test)? onStartTestModel;
  final VoidCallback onExploreTests;
  final VoidCallback onJoinContest;
  final VoidCallback onSpinWheel;
  final VoidCallback onOpenWallet;
  final VoidCallback? onOpenBattle;
  final void Function(String category)? onFilterSubject;
  final VoidCallback? onDailyStreakTap;
  final VoidCallback? onLeaderboardTap;

  const DashboardScreen({
    super.key,
    required this.profile,
    required this.onStartTest,
    this.onStartTestModel,
    required this.onExploreTests,
    required this.onJoinContest,
    required this.onSpinWheel,
    required this.onOpenWallet,
    this.onOpenBattle,
    this.onFilterSubject,
    this.onDailyStreakTap,
    this.onLeaderboardTap,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TestModel> _popularTests = [];
  List<TestModel> _tournaments = [];
  List<CategoryModel> _liveCategories = [];
  StreamSubscription<List<CategoryModel>>? _categoriesSub;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final testsRes = await TestsRepository().getTests();
    final tourRes = await ContestsRepository().getTournaments();
    final catRes = await TestsRepository().getCategories();

    if (!mounted) return;
    setState(() {
      if (testsRes is Success<List<TestModel>>) {
        _popularTests = testsRes.data;
      }
      if (tourRes is Success<List<TestModel>>) {
        _tournaments = tourRes.data;
      }
      if (catRes is Success<List<CategoryModel>> && catRes.data.isNotEmpty) {
        _liveCategories = catRes.data;
      }
    });

    _categoriesSub ??= TestsRepository().streamCategories().listen((updated) {
      if (mounted && updated.isNotEmpty) {
        setState(() {
          _liveCategories = updated;
        });
      }
    });
  }

  @override
  void dispose() {
    _categoriesSub?.cancel();
    super.dispose();
  }

  void _triggerStartTest([TestModel? test]) {
    final target = test ?? (_popularTests.isNotEmpty ? _popularTests.first : null);
    if (widget.onStartTestModel != null && target != null) {
      widget.onStartTestModel!(target);
    } else {
      widget.onStartTest();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;

        if (isDesktop) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primary Learning Feed (Left ~67%)
                Expanded(
                  flex: 67,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeroPromoBanner(
                        onStartLearning: widget.onStartTest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(height: 20),
                      _buildUserStatsSection(),
                      const SizedBox(height: 22),
                      _buildFeatureShortcutsSection(),
                      const SizedBox(height: 24),
                      _buildContinueLearningOnlySection(),
                      const SizedBox(height: 24),
                      _buildExploreBySubjectSection(),
                      const SizedBox(height: 24),
                      _buildPromotionalBannersSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Dedicated Desktop Sidebar (Right ~33%)
                Expanded(
                  flex: 33,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TodayGoalCard(
                        completed: 3,
                        target: 5,
                        subtitle: 'Complete 5 tests today to earn 50 coins!',
                        onTap: widget.onStartTest,
                      ),
                      const SizedBox(height: 16),
                      DailyStreakCard(
                        streakDays: 7,
                        completedDays: 5,
                        onTap: widget.onDailyStreakTap ?? () => _showStreakInfo(context),
                      ),
                      const SizedBox(height: 20),
                      _buildDesktopUpcomingLiveTests(),
                      const SizedBox(height: 20),
                      _buildDesktopLeaderboardCard(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Standard Mobile & Tablet Layout (Direct reference match)
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroPromoBanner(
                onStartLearning: widget.onStartTest,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(height: 18),
              _buildUserStatsSection(),
              const SizedBox(height: 20),
              _buildFeatureShortcutsSection(),
              const SizedBox(height: 20),
              _buildContinueLearningAndGoalSection(),
              const SizedBox(height: 22),
              _buildExploreBySubjectSection(),
              const SizedBox(height: 22),
              _buildPromotionalBannersSection(),
              const SizedBox(height: 22),
              _buildUpcomingLiveTestsSection(),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // --- 2. User Statistics Cards ---
  Widget _buildUserStatsSection() {
    return AppMetricsRow(
      breakpoint: 640,
      spacing: 8,
      cards: [
        TestMetricCard(
          icon: Icons.monetization_on_rounded,
          label: 'My Coins',
          value: _formatNumber(widget.profile.coins),
          accentColor: const Color(0xFFF59E0B),
          backgroundColor: const Color(0xFFFFFBEB),
          onTap: widget.onOpenWallet,
        ),
        TestMetricCard(
          icon: Icons.local_fire_department_rounded,
          label: 'Daily Streak',
          value: '7 Days',
          accentColor: const Color(0xFFF97316),
          backgroundColor: const Color(0xFFFFF7ED),
          onTap: widget.onDailyStreakTap ?? () => _showStreakInfo(context),
        ),
        TestMetricCard(
          icon: Icons.track_changes_rounded,
          label: 'Tests Attempted',
          value: '28',
          accentColor: const Color(0xFF2587F8),
          backgroundColor: const Color(0xFFEFF6FF),
          onTap: widget.onExploreTests,
        ),
        TestMetricCard(
          icon: Icons.military_tech_rounded,
          label: 'My Rank',
          value: '#1256',
          accentColor: const Color(0xFFEAB308),
          backgroundColor: const Color(0xFFFEFCE8),
          onTap: widget.onLeaderboardTap ?? () => _showRankInfo(context),
        ),
      ],
    );
  }

  // --- 3. Primary Feature Shortcuts (6 items) ---
  Widget _buildFeatureShortcutsSection() {
    final shortcuts = [
      (
        icon: Icons.feed_rounded,
        label: 'Mock Tests',
        color: const Color(0xFF7C3AED), // Purple
        bg: const Color(0xFFF5F3FF),
        border: const Color(0xFFEDE9FE),
        onTap: widget.onExploreTests,
      ),
      (
        icon: Icons.menu_book_rounded,
        label: 'Previous\nYear Papers',
        color: const Color(0xFFF43F5E), // Pink / Red
        bg: const Color(0xFFFFF1F2),
        border: const Color(0xFFFFE4E6),
        onTap: widget.onExploreTests,
      ),
      (
        icon: Icons.sensors_rounded,
        label: 'Live Test',
        color: const Color(0xFF10B981), // Green
        bg: const Color(0xFFECFDF5),
        border: const Color(0xFFD1FAE5),
        onTap: widget.onJoinContest,
      ),
      (
        icon: Icons.flash_on_rounded,
        label: '1v1\nQuiz Battle',
        color: const Color(0xFFFF9F0A), // Orange
        bg: const Color(0xFFFFF7ED),
        border: const Color(0xFFFFEDD5),
        onTap: widget.onOpenBattle ?? widget.onJoinContest,
      ),
      (
        icon: Icons.donut_large_rounded,
        label: 'Fortune Wheel',
        color: const Color(0xFF2587F8), // Sky Blue
        bg: const Color(0xFFEFF6FF),
        border: const Color(0xFFDBEAFE),
        onTap: widget.onSpinWheel,
      ),
      (
        icon: Icons.emoji_events_rounded,
        label: 'Tournaments',
        color: const Color(0xFF8B5CF6), // Violet
        bg: const Color(0xFFF5F3FF),
        border: const Color(0xFFEDE9FE),
        onTap: widget.onJoinContest,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;

        Widget buildSegment(int i) {
          final s = shortcuts[i];
          return Material(
            color: s.bg,
            child: InkWell(
              onTap: s.onTap,
              child: Container(
                constraints: const BoxConstraints(minHeight: 116),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: s.color,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: s.color.withAlpha(70),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          s.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 32,
                      child: Center(
                        child: Text(
                          s.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (isDesktop) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3EAF7), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < shortcuts.length; i++) ...[
                      if (i > 0)
                        Container(
                          width: 1,
                          color: const Color(0xFFE3EAF7),
                        ),
                      Expanded(
                        child: buildSegment(i),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }

        // Mobile compact scrollable bar with vertical divider lines
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE3EAF7), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < shortcuts.length; i++) ...[
                      if (i > 0)
                        Container(
                          width: 1,
                          color: const Color(0xFFE3EAF7),
                        ),
                      SizedBox(
                        width: 90,
                        child: buildSegment(i),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- 4. Continue Learning & Today's Goal ---
  Widget _buildContinueLearningAndGoalSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        final activeTitle = _popularTests.isNotEmpty
            ? _popularTests.first.title
            : 'RRB Technician Grade 3';
        final activeSubtitle = _popularTests.isNotEmpty
            ? '${_popularTests.first.categoryId ?? "General Science"} • ${_popularTests.first.totalQuestions} Questions'
            : 'General Science • 120 Questions';
        final activeTag = _popularTests.isNotEmpty
            ? (_popularTests.first.categoryId ?? 'Target Exam')
            : 'RRB Technician';

        final continueCard = ContinueLearningCard(
          title: activeTitle,
          subtitle: activeSubtitle,
          progress: 0.65,
          tag: activeTag,
          onContinue: () => _triggerStartTest(),
          onViewAll: widget.onExploreTests,
        );

        final goalCard = TodayGoalCard(
          completed: 3,
          target: 5,
          onTap: () => _triggerStartTest(),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(flex: 3, child: continueCard),
              const SizedBox(width: 14),
              Expanded(flex: 2, child: goalCard),
            ],
          );
        }

        return Column(
          children: [
            continueCard,
            const SizedBox(height: 12),
            goalCard,
          ],
        );
      },
    );
  }

  IconData _resolveCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'science':
        return Icons.science_rounded;
      case 'calculate':
        return Icons.calculate_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'newspaper':
        return Icons.newspaper_rounded;
      case 'biotech':
        return Icons.biotech_rounded;
      case 'eco':
        return Icons.eco_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'assignment':
        return Icons.assignment_rounded;
      case 'public':
        return Icons.public_rounded;
      case 'history':
      case 'auto_stories':
        return Icons.auto_stories_rounded;
      case 'code':
        return Icons.code_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  Color _resolveCategoryColor(String hex, [Color fallback = const Color(0xFF2587F8)]) {
    try {
      final clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  // --- 5. Explore by Subject ---
  Widget _buildExploreBySubjectSection() {
    final List<({String title, String count, IconData icon, Color accent, Color bg})> subjects;

    if (_liveCategories.isNotEmpty) {
      subjects = _liveCategories.map((c) {
        final accent = _resolveCategoryColor(c.iconColor);
        final countText = c.totalQuestions > 0 ? '${c.totalQuestions}+ Qs' : 'Practice Qs';
        return (
          title: c.name,
          count: countText,
          icon: _resolveCategoryIcon(c.iconName),
          accent: accent,
          bg: accent.withAlpha(20),
        );
      }).toList();
    } else {
      subjects = const [
        (
          title: 'General\nScience',
          count: '1200+ Qs',
          icon: Icons.science_rounded,
          accent: Color(0xFF2587F8),
          bg: Color(0xFFF0F7FF),
        ),
        (
          title: 'Mathematics',
          count: '800+ Qs',
          icon: Icons.calculate_rounded,
          accent: Color(0xFFF59E0B),
          bg: Color(0xFFFFFBEB),
        ),
        (
          title: 'Reasoning',
          count: '700+ Qs',
          icon: Icons.psychology_rounded,
          accent: Color(0xFFF43F5E),
          bg: Color(0xFFFFF1F2),
        ),
        (
          title: 'Current Affairs',
          count: '500+ Qs',
          icon: Icons.newspaper_rounded,
          accent: Color(0xFF8B5CF6),
          bg: Color(0xFFF5F3FF),
        ),
        (
          title: 'Chemistry',
          count: '600+ Qs',
          icon: Icons.biotech_rounded,
          accent: Color(0xFF06B6D4),
          bg: Color(0xFFECFEFF),
        ),
        (
          title: 'Biology',
          count: '550+ Qs',
          icon: Icons.eco_rounded,
          accent: Color(0xFF10B981),
          bg: Color(0xFFECFDF5),
        ),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.brandBlueLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.grid_view_rounded,
                        color: AppColors.brandBlue,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Explore by Subject',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: widget.onExploreTests,
              child: Row(
                children: const [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandPurple,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.brandPurple,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: subjects.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final sub = subjects[index];
              return SubjectCard(
                title: sub.title,
                questionCount: sub.count,
                icon: sub.icon,
                accentColor: sub.accent,
                backgroundColor: sub.bg,
                onTap: () {
                  if (widget.onFilterSubject != null) {
                    widget.onFilterSubject!(sub.title.replaceAll('\n', ' '));
                  } else {
                    widget.onExploreTests();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 6. Promotional Banners: Daily Challenge & Fortune Wheel ---
  Widget _buildPromotionalBannersSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;

        final dailyChallengeCard = PromoBannerCard.dailyChallenge(
          onPlay: widget.onStartTest,
        );

        final fortuneWheelCard = PromoBannerCard.fortuneWheel(
          onSpin: widget.onSpinWheel,
        );

        if (isWide) {
          return Row(
            children: [
              Expanded(child: dailyChallengeCard),
              const SizedBox(width: 14),
              Expanded(child: fortuneWheelCard),
            ],
          );
        }

        return Column(
          children: [
            dailyChallengeCard,
            const SizedBox(height: 12),
            fortuneWheelCard,
          ],
        );
      },
    );
  }

  // --- 7. Upcoming Live Tests & Tournaments ---
  Widget _buildUpcomingLiveTestsSection() {
    final liveEvents = <({
      String title,
      String dateTime,
      String questions,
      Widget icon,
      bool isLive,
      LiveEventActionType actionType,
      VoidCallback onAction,
    })>[
      if (_tournaments.isNotEmpty) ...[
        for (final t in _tournaments.take(2))
          (
            title: t.title,
            dateTime: t.scheduledStartTime != null
                ? '${t.scheduledStartTime!.day} ${_monthName(t.scheduledStartTime!.month)} • ${_formatHour(t.scheduledStartTime!)}'
                : 'Live Tournament',
            questions: '${t.totalQuestions} Questions',
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.emoji_events_rounded, color: Color(0xFF2587F8), size: 22),
              ),
            ),
            isLive: t.isLive,
            actionType: t.isLive ? LiveEventActionType.joinNow : LiveEventActionType.register,
            onAction: widget.onJoinContest,
          ),
      ],
      (
        title: 'RRB Special Live Test',
        dateTime: '20 Oct 2026 • 10:00 AM',
        questions: '100 Questions',
        icon: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF43F5E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
          ),
        ),
        isLive: true,
        actionType: LiveEventActionType.joinNow,
        onAction: widget.onJoinContest,
      ),
      (
        title: 'General Science Mega Test',
        dateTime: '21 Oct 2026 • 06:00 PM',
        questions: '120 Questions',
        icon: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF2587F8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.emoji_events_rounded, color: Colors.white, size: 22),
          ),
        ),
        isLive: false,
        actionType: LiveEventActionType.notifyMe,
        onAction: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reminder set! You will be notified 15 minutes before the test begins.'),
              backgroundColor: AppColors.brandBlue,
            ),
          );
        },
      ),
      (
        title: 'All India Quiz Tournament',
        dateTime: '25 Oct 2026 • 07:00 PM',
        questions: '50 Questions',
        icon: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.military_tech_rounded, color: Colors.white, size: 22),
          ),
        ),
        isLive: false,
        actionType: LiveEventActionType.register,
        onAction: widget.onJoinContest,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.sensors_rounded,
                    color: Color(0xFFF43F5E),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Upcoming Live Tests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: widget.onJoinContest,
              child: Row(
                children: const [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandPurple,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.brandPurple,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 142,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: liveEvents.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final event = liveEvents[index];
              return LiveEventCard(
                title: event.title,
                dateTime: event.dateTime,
                questionCount: event.questions,
                icon: event.icon,
                isLive: event.isLive,
                actionType: event.actionType,
                onAction: event.onAction,
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Desktop Specific Sidebar Components ---
  Widget _buildContinueLearningOnlySection() {
    final activeTitle = _popularTests.isNotEmpty
        ? _popularTests.first.title
        : 'RRB Technician Grade 3';
    final activeSubtitle = _popularTests.isNotEmpty
        ? '${_popularTests.first.categoryId ?? "General Science"} • ${_popularTests.first.totalQuestions} Questions'
        : 'General Science • 120 Questions';
    final activeTag = _popularTests.isNotEmpty
        ? (_popularTests.first.categoryId ?? 'Target Exam')
        : 'RRB Technician';

    return ContinueLearningCard(
      title: activeTitle,
      subtitle: activeSubtitle,
      progress: 0.65,
      tag: activeTag,
      onContinue: () => _triggerStartTest(),
      onViewAll: widget.onExploreTests,
    );
  }

  Widget _buildDesktopUpcomingLiveTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: Color(0xFF2587F8),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Upcoming Live Tests',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: widget.onJoinContest,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandPurple,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.brandPurple,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Event 1: RRB Special Live Test
        _buildDesktopLiveEventCard(
          iconBg: const Color(0xFFF43F5E),
          icon: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
          isLive: true,
          title: 'RRB Special Live Test',
          dateTime: '20 Oct 2026 • 10:00 AM',
          questions: '100 Questions',
          actionLabel: 'Join Now →',
          actionColor: const Color(0xFFE11D48),
          actionBg: const Color(0xFFFFE4E6),
          onTap: widget.onJoinContest,
        ),
        const SizedBox(height: 10),
        // Event 2: General Science Mega Test
        _buildDesktopLiveEventCard(
          iconBg: const Color(0xFF2587F8),
          icon: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 22),
          isLive: false,
          title: 'General Science Mega Test',
          dateTime: '21 Oct 2026 • 06:00 PM',
          questions: '120 Questions',
          actionLabel: 'Notify Me',
          actionIcon: Icons.notifications_none_rounded,
          actionColor: const Color(0xFF2587F8),
          actionBg: const Color(0xFFEFF6FF),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reminder set! You will be notified 15 minutes before the test begins.'),
                backgroundColor: AppColors.brandBlue,
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        // Event 3: All India Quiz Tournament
        _buildDesktopLiveEventCard(
          iconBg: const Color(0xFF7C3AED),
          icon: const Icon(Icons.military_tech_rounded, color: Colors.white, size: 22),
          isLive: false,
          title: 'All India Quiz Tournament',
          dateTime: '25 Oct 2026 • 07:00 PM',
          questions: '50 Questions',
          actionLabel: 'Register →',
          actionColor: const Color(0xFF7C3AED),
          actionBg: const Color(0xFFF3E8FF),
          onTap: widget.onJoinContest,
        ),
      ],
    );
  }

  Widget _buildDesktopLiveEventCard({
    required Color iconBg,
    required Widget icon,
    required bool isLive,
    required String title,
    required String dateTime,
    required String questions,
    required String actionLabel,
    IconData? actionIcon,
    required Color actionColor,
    required Color actionBg,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLive) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4E6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.circle, color: Color(0xFFE11D48), size: 5),
                            SizedBox(width: 3),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Color(0xFFE11D48),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateTime,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  questions,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: actionBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (actionIcon != null) ...[
                    Icon(actionIcon, size: 13, color: actionColor),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    actionLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: actionColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLeaderboardCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.military_tech_rounded,
                          color: Color(0xFFD97706),
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Top Performers',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: widget.onLeaderboardTap ?? () => _showRankInfo(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandPurple,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.brandPurple,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...[
            (
              rank: 1,
              name: 'Aarav Sharma',
              coins: 3420,
              badgeBg: const Color(0xFFFEF3C7),
              badgeColor: const Color(0xFFD97706),
              avatarBg: const Color(0xFFDBEAFE),
              isUser: false,
            ),
            (
              rank: 2,
              name: 'Priya Patel',
              coins: 2980,
              badgeBg: const Color(0xFFF1F5F9),
              badgeColor: const Color(0xFF64748B),
              avatarBg: const Color(0xFFFCE7F3),
              isUser: false,
            ),
            (
              rank: 3,
              name: '${widget.profile.name} (You)',
              coins: widget.profile.coins > 0 ? widget.profile.coins : 1450,
              badgeBg: const Color(0xFFFFEDD5),
              badgeColor: const Color(0xFFC2410C),
              avatarBg: const Color(0xFFDCFCE7),
              isUser: true,
            ),
            (
              rank: 4,
              name: 'Amit Verma',
              coins: 1320,
              badgeBg: const Color(0xFFF8FAFC),
              badgeColor: const Color(0xFF64748B),
              avatarBg: const Color(0xFFEDE9FE),
              isUser: false,
            ),
            (
              rank: 5,
              name: 'Sneha Roy',
              coins: 1240,
              badgeBg: const Color(0xFFF8FAFC),
              badgeColor: const Color(0xFF64748B),
              avatarBg: const Color(0xFFFEF3C7),
              isUser: false,
            ),
            (
              rank: 6,
              name: 'Rohan Gupta',
              coins: 1150,
              badgeBg: const Color(0xFFF8FAFC),
              badgeColor: const Color(0xFF64748B),
              avatarBg: const Color(0xFFE0E7FF),
              isUser: false,
            ),
            (
              rank: 7,
              name: 'Ananya Singh',
              coins: 1080,
              badgeBg: const Color(0xFFF8FAFC),
              badgeColor: const Color(0xFF64748B),
              avatarBg: const Color(0xFFFCE7F3),
              isUser: false,
            ),
            (
              rank: 8,
              name: 'Deepak Kumar',
              coins: 990,
              badgeBg: const Color(0xFFF8FAFC),
              badgeColor: const Color(0xFF64748B),
              avatarBg: const Color(0xFFDCFCE7),
              isUser: false,
            ),
          ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: _buildLeaderboardRow(
                  rank: item.rank,
                  name: item.name,
                  coins: item.coins,
                  badgeBg: item.badgeBg,
                  badgeColor: item.badgeColor,
                  avatarBg: item.avatarBg,
                  isUser: item.isUser,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow({
    required int rank,
    required String name,
    required int coins,
    required Color badgeBg,
    required Color badgeColor,
    required Color avatarBg,
    bool isUser = false,
  }) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: badgeBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: badgeColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        CircleAvatar(
          radius: 14,
          backgroundColor: avatarBg,
          child: Icon(
            Icons.person,
            size: 16,
            color: badgeColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isUser ? FontWeight.w800 : FontWeight.w600,
              color: isUser ? AppColors.brandPurple : AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFEF3C7),
              ),
              child: const Center(
                child: Icon(Icons.monetization_on, size: 12, color: Color(0xFFF59E0B)),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _formatNumber(coins),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showStreakInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.local_fire_department_rounded, color: Color(0xFFF97316)),
            SizedBox(width: 8),
            Text('Daily Streak: 7 Days!', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: const Text(
          'Keep your momentum going! Attempt at least 1 mock test or quiz daily to maintain your streak and earn 50 bonus coins every 7 days.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showRankInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.military_tech_rounded, color: Color(0xFFEAB308)),
            SizedBox(width: 8),
            Text('All India Rank #1256', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: const Text(
          'Your rank is calculated dynamically across all mock tests and live tournaments. Score above 80% on 3 more tests to break into the Top 500!',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPurple),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onStartTest();
            },
            child: const Text('Practice Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int val) {
    if (val >= 1000) {
      final str = val.toString();
      final regex = RegExp(r'(\d+?)(?=(\d{3})+$)');
      return str.replaceAllMapped(regex, (match) => '${match[1]},');
    }
    return '$val';
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  String _formatHour(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $ampm';
  }
}
