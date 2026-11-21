import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'widgets/live_poll_card.dart';
import '../tests/screens/all_exams_screen.dart';
import '../tests/screens/exam_tests_screen.dart';

class DashboardScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onStartTest;
  final void Function(TestModel test)? onStartTestModel;
  final void Function(
    TestModel test, {
    List<QuestionModel>? customQuestions,
    Map<String, int>? initialAnswers,
    int? initialSecondsRemaining,
    int? initialIndex,
  })? onResumeTest;
  final VoidCallback onExploreTests;
  final VoidCallback onJoinContest;
  final VoidCallback onSpinWheel;
  final VoidCallback onOpenWallet;
  final VoidCallback? onOpenBattle;
  final void Function(String category)? onFilterSubject;
  final VoidCallback? onDailyStreakTap;
  final VoidCallback? onLeaderboardTap;
  final Map<String, bool>? featureFlags;

  const DashboardScreen({
    super.key,
    required this.profile,
    required this.onStartTest,
    this.onStartTestModel,
    this.onResumeTest,
    required this.onExploreTests,
    required this.onJoinContest,
    required this.onSpinWheel,
    required this.onOpenWallet,
    this.onOpenBattle,
    this.onFilterSubject,
    this.onDailyStreakTap,
    this.onLeaderboardTap,
    this.featureFlags,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  IncompleteTestModel? _incompleteTest;
  List<TestModel> _popularTests = [];
  List<TestModel> _allTests = [];
  List<ExamCategoryModel> _examCategories = [];
  List<TestModel> _tournaments = [];
  List<CategoryModel> _liveCategories = [];
  List<BannerModel> _activeBanners = [];
  Map<String, dynamic> _userStats = {};
  List<Map<String, dynamic>> _leaderboardUsers = [];
  StreamSubscription<List<CategoryModel>>? _categoriesSub;
  StreamSubscription<List<BannerModel>>? _bannersSub;
  StreamSubscription<Map<String, bool>>? _flagsSub;
  Map<String, bool> _localFlags = {};

  bool _isFeatureEnabled(String key) {
    if (widget.featureFlags != null && widget.featureFlags!.containsKey(key)) {
      return widget.featureFlags![key]!;
    }
    if (_localFlags.containsKey(key)) {
      return _localFlags[key]!;
    }
    return FeatureFlagsRepository().isEnabled(key);
  }

  @override
  void initState() {
    super.initState();
    _localFlags = Map<String, bool>.from(FeatureFlagsRepository().currentFlags);
    _flagsSub = FeatureFlagsRepository().flagsStream.listen(
      (flags) {
        if (mounted) setState(() => _localFlags = flags);
      },
      onError: (_) {},
    );
    _loadDashboardData();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadIncompleteTest();
  }

  Future<void> _loadIncompleteTest() async {
    final incomplete =
        await IncompleteTestsRepository().getLatestIncompleteTest();
    if (mounted) {
      setState(() => _incompleteTest = incomplete);
    }
  }

  Future<void> _loadDashboardData() async {
    final testsRes = await TestsRepository().getTests();
    final tourRes = await ContestsRepository().getTournaments();
    final catRes = await TestsRepository().getCategories();
    final examRes = await TestsRepository().getExamCategoryList();
    final bannersRes = await BannersRepository().getActiveBanners(displayMode: 'home_carousel');
    final stats = await TestsRepository().getUserStats(widget.profile.id);
    final lbRes = await ContestsRepository().getLeaderboardUsers(limit: 8);
    final incomplete =
        await IncompleteTestsRepository().getLatestIncompleteTest();

    if (!mounted) return;
    setState(() {
      _userStats = stats;
      _incompleteTest = incomplete;
      if (testsRes is Success<List<TestModel>>) {
        _allTests = testsRes.data;
        // Exclude active / upcoming live tests and tournaments from normal popular tests list
        _popularTests = testsRes.data
            .where(
              (t) =>
                  !t.isTournament &&
                  t.testMode != 'live' &&
                  t.testMode != 'tournament' &&
                  !t.isLive &&
                  !t.isUpcoming,
            )
            .toList();
      }
      if (examRes is Success<List<ExamCategoryModel>> && examRes.data.isNotEmpty) {
        _examCategories = examRes.data;
      }
      if (tourRes is Success<List<TestModel>>) {
        _tournaments = tourRes.data;
      }
      if (catRes is Success<List<CategoryModel>> && catRes.data.isNotEmpty) {
        _liveCategories = catRes.data;
      }
      if (bannersRes is Success<List<BannerModel>>) {
        _activeBanners = bannersRes.data;
      }
      if (lbRes is Success<List<Map<String, dynamic>>>) {
        _leaderboardUsers = lbRes.data;
      }
    });

    _categoriesSub ??= TestsRepository().streamCategories().listen(
      (updated) {
        if (mounted && updated.isNotEmpty) {
          setState(() {
            _liveCategories = updated;
          });
        }
      },
      onError: (_) {
        // Silently ignore channel close/reconnect events
      },
    );

    _bannersSub ??= BannersRepository().streamActiveBanners(displayMode: 'home_carousel').listen(
      (updated) {
        if (mounted) {
          setState(() {
            _activeBanners = updated;
          });
        }
      },
      onError: (_) {},
    );

    // Pop-up Modal on Launch
    try {
      final popupRes = await BannersRepository().getActiveBanners(displayMode: 'popup_modal');
      if (popupRes is Success<List<BannerModel>> && popupRes.data.isNotEmpty && mounted) {
        _showLaunchPopup(popupRes.data.first);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _categoriesSub?.cancel();
    _bannersSub?.cancel();
    _flagsSub?.cancel();
    super.dispose();
  }

  void _resumeTest(IncompleteTestModel incomplete) {
    if (widget.onResumeTest != null) {
      widget.onResumeTest!(
        incomplete.test,
        customQuestions: incomplete.questions,
        initialAnswers: incomplete.userAnswers,
        initialSecondsRemaining: incomplete.secondsRemaining,
        initialIndex: incomplete.currentIndex,
      );
    } else if (widget.onStartTestModel != null) {
      widget.onStartTestModel!(incomplete.test);
    } else {
      widget.onStartTest();
    }
  }

  void _triggerStartTest([TestModel? test]) {
    final target = test ?? (_popularTests.isNotEmpty ? _popularTests.first : null);
    if (widget.onStartTestModel != null && target != null) {
      widget.onStartTestModel!(target);
    } else {
      widget.onStartTest();
    }
  }

  void _openExam(ExamCategoryModel exam) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExamTestsScreen(
          exam: exam,
          allTests: _allTests,
          allCategories: _liveCategories,
          onStartTest: (t) => _triggerStartTest(t),
          userCoins: widget.profile.coins,
        ),
      ),
    );
  }

  void _openAllExams() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AllExamsScreen(
          examCategories: _examCategories,
          allTests: _allTests,
          allCategories: _liveCategories,
          onStartTest: (t) => _triggerStartTest(t),
          userCoins: widget.profile.coins,
        ),
      ),
    );
  }

  static bool _hasShownLaunchPopup = false;

  void _showLaunchPopup(BannerModel banner) {
    if (_hasShownLaunchPopup) return;
    _hasShownLaunchPopup = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    if (banner.imageUrl.isNotEmpty)
                      Image.network(
                        banner.imageUrl,
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        style: IconButton.styleFrom(backgroundColor: Colors.black45),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                  ],
                ),
                if (banner.title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Text(
                      banner.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5636F5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _handleBannerTap(BannerItemData(
                        id: banner.id,
                        imageUrl: banner.imageUrl,
                        title: banner.title,
                        link: banner.link,
                        type: banner.type,
                      ));
                    },
                    child: const Text('Explore Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _handleBannerTap(BannerItemData banner) {
    BannersRepository().recordClick(banner.id);
    final link = banner.link.trim().toLowerCase();
    if (link == '/tests' || link == 'tests') {
      widget.onStartTest();
    } else if (link == '/spin' || link == 'spin' || link.contains('wheel')) {
      widget.onSpinWheel();
    } else if (link == '/wallet' || link == 'wallet') {
      widget.onOpenWallet();
    } else if (link == '/battle' || link == 'battle') {
      widget.onOpenBattle?.call();
    } else if (link == '/leaderboard' || link == 'leaderboard') {
      widget.onLeaderboardTap?.call();
    } else {
      widget.onStartTest();
    }
  }

  Widget _buildTopBanner({required BorderRadius borderRadius}) {
    if (_activeBanners.isEmpty) {
      return HeroPromoBanner(
        onStartLearning: widget.onStartTest,
        borderRadius: borderRadius,
      );
    }

    return BannerCarousel(
      banners: _activeBanners.map((b) => BannerItemData(
        id: b.id,
        imageUrl: b.imageUrl,
        title: b.title,
        link: b.link,
        type: b.type,
        spotlightData: b.spotlightData,
      )).toList(),
      borderRadius: borderRadius,
      onBannerTap: _handleBannerTap,
      fallbackWidget: HeroPromoBanner(
        onStartLearning: widget.onStartTest,
        borderRadius: borderRadius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;

        if (isDesktop) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: AppSpacing.pagePadding(context),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primary Learning Feed (Left ~67%)
                Expanded(
                  flex: 67,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopBanner(
                        borderRadius: AppRadii.borderMd,
                      ),
                      if (_isFeatureEnabled('live_poll')) ...[
                        const SizedBox(height: 20),
                        LivePollCard(profile: widget.profile),
                      ],
                      _buildUserStatsSection(),
                      const SizedBox(height: 24),
                      _buildContinueLearningOnlySection(),
                      const SizedBox(height: 24),
                      _buildExploreByExamSection(),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TodayGoalCard(
                        completed: ((_userStats['testsAttempted'] as num?)?.toInt() ?? 0).clamp(0, 5),
                        target: 5,
                        subtitle: 'Complete 5 tests today to earn 50 coins!',
                        onTap: widget.onStartTest,
                      ),
                      const SizedBox(height: 16),
                      DailyStreakCard(
                        streakDays: (_userStats['streakDays'] as num?)?.toInt() ?? 0,
                        completedDays: ((_userStats['testsAttempted'] as num?)?.toInt() ?? 0).clamp(0, 7),
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

        // Standard Mobile & Tablet Layout (Direct reference match to Admin App Dashboard)
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: AppSpacing.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBanner(
                borderRadius: AppRadii.borderMd,
              ),
              if (_isFeatureEnabled('live_poll')) ...[
                const SizedBox(height: 18),
                LivePollCard(profile: widget.profile),
              ],
              _buildUserStatsSection(),
              const SizedBox(height: 20),
              _buildContinueLearningAndGoalSection(),
              const SizedBox(height: 22),
              _buildExploreByExamSection(),
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
          value: (_userStats['streakDays'] ?? 0) > 0 ? '${_userStats['streakDays']} Days' : '0 Days',
          accentColor: const Color(0xFFF97316),
          backgroundColor: const Color(0xFFFFF7ED),
          onTap: widget.onDailyStreakTap ?? () => _showStreakInfo(context),
        ),
        TestMetricCard(
          icon: Icons.track_changes_rounded,
          label: 'Tests Attempted',
          value: '${_userStats['testsAttempted'] ?? 0}',
          accentColor: const Color(0xFF2587F8),
          backgroundColor: const Color(0xFFEFF6FF),
          onTap: widget.onExploreTests,
        ),
        TestMetricCard(
          icon: Icons.military_tech_rounded,
          label: 'My Rank',
          value: '${_userStats['rank'] ?? '-'}',
          accentColor: const Color(0xFFEAB308),
          backgroundColor: const Color(0xFFFEFCE8),
          onTap: widget.onLeaderboardTap ?? () => _showRankInfo(context),
        ),
      ],
    );
  }

  // --- 4. Continue Learning & Today's Goal ---
  Widget _buildContinueLearningAndGoalSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        final hasIncomplete = _incompleteTest != null;
        final activeTitle = hasIncomplete
            ? _incompleteTest!.test.title
            : 'Start a Practice Test';
        final activeSubtitle = hasIncomplete
            ? '${_incompleteTest!.test.categoryId ?? "General"} • ${_incompleteTest!.totalQuestions} Questions (${_incompleteTest!.answeredCount}/${_incompleteTest!.totalQuestions} answered)'
            : 'Pick any mock, chapter or sectional test to begin';
        final activeTag = hasIncomplete
            ? (_incompleteTest!.test.examCategoryId ??
                _incompleteTest!.test.categoryId ??
                'In Progress')
            : 'Practice';
        final double progressVal =
            hasIncomplete ? _incompleteTest!.progress : 0.0;
        final iconData = hasIncomplete
            ? _resolveCategoryIcon(_incompleteTest!.test.categoryId ?? '')
            : Icons.assignment_rounded;

        final continueCard = ContinueLearningCard(
          title: activeTitle,
          subtitle: activeSubtitle,
          progress: progressVal,
          tag: activeTag,
          icon: iconData,
          onContinue: () {
            if (hasIncomplete) {
              _resumeTest(_incompleteTest!);
            } else {
              widget.onExploreTests();
            }
          },
          onViewAll: widget.onExploreTests,
        );

        final goalCard = TodayGoalCard(
          completed: ((_userStats['testsAttempted'] as num?)?.toInt() ?? 0).clamp(0, 5),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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

  // --- 5. Explore by Exam ---
  Widget _buildExploreByExamSection() {
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
                        Icons.school_rounded,
                        color: AppColors.brandBlue,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Explore by Exam',
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
              onTap: _openAllExams,
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
        if (_examCategories.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'No exam categories available right now.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                ExamCategoryCard(
                  index: 0,
                  id: 'all',
                  name: 'All Exams',
                  badgeText: 'All Tests',
                  onTap: _openAllExams,
                ),
                const SizedBox(width: 10),
                for (int i = 0; i < _examCategories.length; i++) ...[
                  ExamCategoryCard(
                    index: i + 1,
                    id: _examCategories[i].id,
                    name: _examCategories[i].name,
                    badgeText: _examCategories[i].totalMocks > 0 ||
                            _examCategories[i].totalSectional > 0
                        ? '${_examCategories[i].totalMocks} Mock • ${_examCategories[i].totalSectional} Sec'
                        : (_examCategories[i].totalTests > 0
                            ? '${_examCategories[i].totalTests} Tests'
                            : 'Practice'),
                    onTap: () => _openExam(_examCategories[i]),
                  ),
                  const SizedBox(width: 10),
                ],
              ],
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
        final showFortune = _isFeatureEnabled('fortune_wheel');

        final dailyChallengeCard = PromoBannerCard.dailyChallenge(
          onPlay: widget.onStartTest,
        );

        if (!showFortune) {
          return dailyChallengeCard;
        }

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
    if (!_isFeatureEnabled('live_quiz')) {
      return const SizedBox.shrink();
    }
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
        for (final t in _tournaments.take(5))
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
                color: t.isLive ? const Color(0xFFF43F5E) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  t.isLive ? Icons.calendar_month_rounded : Icons.emoji_events_rounded,
                  color: t.isLive ? Colors.white : const Color(0xFF2587F8),
                  size: 22,
                ),
              ),
            ),
            isLive: t.isLive,
            actionType: t.isLive ? LiveEventActionType.joinNow : LiveEventActionType.register,
            onAction: widget.onJoinContest,
          ),
      ],
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
        if (liveEvents.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'No live tournaments currently scheduled.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
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
    final hasIncomplete = _incompleteTest != null;
    final activeTitle = hasIncomplete
        ? _incompleteTest!.test.title
        : 'Start a Practice Test';
    final activeSubtitle = hasIncomplete
        ? '${_incompleteTest!.test.categoryId ?? "General"} • ${_incompleteTest!.totalQuestions} Questions (${_incompleteTest!.answeredCount}/${_incompleteTest!.totalQuestions} answered)'
        : 'Pick any mock, chapter or sectional test to begin';
    final activeTag = hasIncomplete
        ? (_incompleteTest!.test.examCategoryId ??
            _incompleteTest!.test.categoryId ??
            'In Progress')
        : 'Practice';
    final double progressVal = hasIncomplete ? _incompleteTest!.progress : 0.0;
    final iconData = hasIncomplete
        ? _resolveCategoryIcon(_incompleteTest!.test.categoryId ?? '')
        : Icons.assignment_rounded;

    return ContinueLearningCard(
      title: activeTitle,
      subtitle: activeSubtitle,
      progress: progressVal,
      tag: activeTag,
      icon: iconData,
      onContinue: () {
        if (hasIncomplete) {
          _resumeTest(_incompleteTest!);
        } else {
          widget.onExploreTests();
        }
      },
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
        if (_tournaments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'No live tests scheduled right now.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          )
        else
          for (final t in _tournaments.take(3)) ...[
            _buildDesktopLiveEventCard(
              iconBg: t.isLive ? const Color(0xFFF43F5E) : const Color(0xFF2587F8),
              icon: Icon(
                t.isLive ? Icons.calendar_month_rounded : Icons.emoji_events_rounded,
                color: Colors.white,
                size: 22,
              ),
              isLive: t.isLive,
              title: t.title,
              dateTime: t.scheduledStartTime != null
                  ? '${t.scheduledStartTime!.day} ${_monthName(t.scheduledStartTime!.month)} • ${_formatHour(t.scheduledStartTime!)}'
                  : 'Live Tournament',
              questions: '${t.totalQuestions} Questions',
              actionLabel: t.isLive ? 'Join Now →' : 'Register →',
              actionColor: t.isLive ? const Color(0xFFE11D48) : const Color(0xFF2587F8),
              actionBg: t.isLive ? const Color(0xFFFFE4E6) : const Color(0xFFEFF6FF),
              onTap: widget.onJoinContest,
            ),
            const SizedBox(height: 10),
          ],
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
    IconData watermarkIcon = Icons.calendar_month_rounded;
    if (title.contains('Science') || title.contains('Mega')) {
      watermarkIcon = Icons.emoji_events_rounded;
    } else if (title.contains('Tournament') || title.contains('Quiz')) {
      watermarkIcon = Icons.military_tech_rounded;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(iconBg.withAlpha(18), Colors.white),
            Colors.white,
          ],
        ),
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: iconBg.withAlpha(45), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: iconBg.withAlpha(14),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          const BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadii.borderLg,
        child: Stack(
          children: [
            // 1. Soft Halo Glow in Top Right
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBg.withAlpha(18),
                ),
              ),
            ),

            // 2. Concentric Arc Ring
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconBg.withAlpha(16),
                    width: 1.0,
                  ),
                ),
              ),
            ),

            // 3. Faint Watermark Icon near right
            Positioned(
              right: 80,
              bottom: -6,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: -0.12,
                  child: Icon(
                    watermarkIcon,
                    size: 56,
                    color: iconBg.withAlpha(20),
                  ),
                ),
              ),
            ),

            // 4. Foreground Content
            Padding(
              padding: const EdgeInsets.all(12),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLeaderboardCard() {
    const accentColor = Color(0xFFF59E0B);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(accentColor.withAlpha(20), Colors.white),
            Colors.white,
            Colors.white,
          ],
        ),
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: accentColor.withAlpha(45), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(14),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
          const BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadii.borderLg,
        child: Stack(
          children: [
            // 1. Soft Halo Glow in Top Right
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withAlpha(18),
                ),
              ),
            ),

            // 2. Concentric Arc Ring
            Positioned(
              top: -45,
              right: -45,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withAlpha(16),
                    width: 1.0,
                  ),
                ),
              ),
            ),

            // 3. Faint Trophy / Medal Watermark Icon in lower-right
            Positioned(
              right: 14,
              bottom: 12,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: -0.12,
                  child: Icon(
                    Icons.military_tech_rounded,
                    size: 92,
                    color: accentColor.withAlpha(18),
                  ),
                ),
              ),
            ),

            // 4. Foreground Content
            Padding(
              padding: const EdgeInsets.all(16),
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
          if (_leaderboardUsers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No learners on leaderboard yet.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            ..._leaderboardUsers.take(8).map((u) {
              final rank = _leaderboardUsers.indexOf(u) + 1;
              final isUser = u['id'] == widget.profile.id;
              final name = isUser
                  ? '${widget.profile.name} (You)'
                  : (u['name']?.toString() ?? (u['email'] != null ? u['email'].toString().split('@').first : 'Learner'));
              final coins = (u['coins'] as num?)?.toInt() ?? 0;

              final badgeBg = rank == 1
                  ? const Color(0xFFFEF3C7)
                  : (rank == 2
                      ? const Color(0xFFF1F5F9)
                      : (rank == 3 ? const Color(0xFFFFEDD5) : const Color(0xFFF8FAFC)));
              final badgeColor = rank == 1
                  ? const Color(0xFFD97706)
                  : (rank == 2
                      ? const Color(0xFF64748B)
                      : (rank == 3 ? const Color(0xFFC2410C) : const Color(0xFF64748B)));
              final avatarBg = rank == 1
                  ? const Color(0xFFDBEAFE)
                  : (rank == 2
                      ? const Color(0xFFFCE7F3)
                      : (rank == 3 ? const Color(0xFFDCFCE7) : const Color(0xFFEDE9FE)));

              return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: _buildLeaderboardRow(
                  rank: rank,
                  name: name,
                  coins: coins,
                  badgeBg: badgeBg,
                  badgeColor: badgeColor,
                  avatarBg: avatarBg,
                  isUser: isUser,
                ),
              );
            }),
        ],
      ),
    ),
          ],
        ),
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
