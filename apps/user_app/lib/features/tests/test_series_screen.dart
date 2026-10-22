import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class TestSeriesScreen extends StatefulWidget {
  final int userCoins;
  final void Function(TestModel test) onStartTest;
  final List<TestModel>? initialTests;
  final VoidCallback? onOpenBattle;
  final VoidCallback? onSpinWheel;
  final VoidCallback? onOpenLive;
  final VoidCallback? onOpenLeaderboard;

  const TestSeriesScreen({
    super.key,
    required this.userCoins,
    required this.onStartTest,
    this.initialTests,
    this.onOpenBattle,
    this.onSpinWheel,
    this.onOpenLive,
    this.onOpenLeaderboard,
  });

  @override
  State<TestSeriesScreen> createState() => _TestSeriesScreenState();
}

class _TestSeriesScreenState extends State<TestSeriesScreen> {
  int _selectedTypeIndex = 0; // 0: All Tests, 1: Daily Test, 2: Mock Tests, 3: PYQ, 4: Chapter Wise, 5: My Tests
  String? _selectedSubject;
  final String _searchQuery = '';
  bool _isLoading = true;
  List<TestModel> _tests = [];

  final List<({String title, String questionCount, IconData icon, Color color, Color bg})> _subjects = const [
    (
      title: 'General Science',
      questionCount: '1200+ Qs',
      icon: Icons.science_rounded,
      color: Color(0xFF2587F8),
      bg: Color(0xFFEFF6FF),
    ),
    (
      title: 'Mathematics',
      questionCount: '800+ Qs',
      icon: Icons.calculate_rounded,
      color: Color(0xFFF59E0B),
      bg: Color(0xFFFFFBEB),
    ),
    (
      title: 'Reasoning',
      questionCount: '700+ Qs',
      icon: Icons.psychology_rounded,
      color: Color(0xFFF43F5E),
      bg: Color(0xFFFFF1F2),
    ),
    (
      title: 'Current Affairs',
      questionCount: '500+ Qs',
      icon: Icons.newspaper_rounded,
      color: Color(0xFF7C3AED),
      bg: Color(0xFFF5F3FF),
    ),
    (
      title: 'Chemistry',
      questionCount: '600+ Qs',
      icon: Icons.biotech_rounded,
      color: Color(0xFF06B6D4),
      bg: Color(0xFFECFEFF),
    ),
    (
      title: 'Biology',
      questionCount: '550+ Qs',
      icon: Icons.eco_rounded,
      color: Color(0xFF10B981),
      bg: Color(0xFFECFDF5),
    ),
  ];

  final List<({
    String title,
    String description,
    IconData icon,
    Color color,
    String testsCount,
    String questionsCount,
    IconData leftIcon,
    IconData rightIcon,
  })> _categories = const [
    (
      title: 'Mock Tests',
      description: 'Full syllabus tests with real exam pattern.',
      icon: Icons.description_rounded,
      color: Color(0xFF2587F8),
      testsCount: '25 Tests',
      questionsCount: '1200+ Qs',
      leftIcon: Icons.description_outlined,
      rightIcon: Icons.trending_up_rounded,
    ),
    (
      title: 'Chapter Wise Tests',
      description: 'Practice subject wise and chapter wise tests.',
      icon: Icons.layers_rounded,
      color: Color(0xFFF59E0B),
      testsCount: '150+ Tests',
      questionsCount: '8000+ Qs',
      leftIcon: Icons.description_outlined,
      rightIcon: Icons.bar_chart_rounded,
    ),
    (
      title: 'Previous Year Papers',
      description: "Practice last year's questions with solutions.",
      icon: Icons.menu_book_rounded,
      color: Color(0xFFF43F5E),
      testsCount: '20+ Papers',
      questionsCount: '2000+ Qs',
      leftIcon: Icons.menu_book_outlined,
      rightIcon: Icons.bar_chart_rounded,
    ),
    (
      title: 'Daily Practice Tests',
      description: 'New tests every day to improve your skills.',
      icon: Icons.calendar_today_rounded,
      color: Color(0xFF10B981),
      testsCount: '30+ Tests',
      questionsCount: '3000+ Qs',
      leftIcon: Icons.description_outlined,
      rightIcon: Icons.trending_up_rounded,
    ),
    (
      title: 'Topic Wise Tests',
      description: 'Focus on important topics and weak areas.',
      icon: Icons.track_changes_rounded,
      color: Color(0xFF8B5CF6),
      testsCount: '200+ Tests',
      questionsCount: '10000+ Qs',
      leftIcon: Icons.description_outlined,
      rightIcon: Icons.show_chart_rounded,
    ),
    (
      title: 'Live Tests',
      description: 'Compete live with students across India.',
      icon: Icons.sensors_rounded,
      color: Color(0xFFF43F5E),
      testsCount: 'Weekly',
      questionsCount: 'Real-time Ranking',
      leftIcon: Icons.calendar_month_outlined,
      rightIcon: Icons.signal_cellular_alt_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialTests != null && widget.initialTests!.isNotEmpty) {
      _tests = widget.initialTests!;
      _isLoading = false;
    } else {
      _loadTests();
    }
  }

  Future<void> _loadTests() async {
    setState(() => _isLoading = true);
    final res = await TestsRepository().getTests();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (res is Success<List<TestModel>> && res.data.isNotEmpty) {
        _tests = res.data;
      } else {
        _tests = _getFallbackTests();
      }
    });
  }

  List<TestModel> _getFallbackTests() {
    return const [
      TestModel(
        id: 'test_mock_01',
        title: '70th BPSC Prelims Grand Full Mock Test 1',
        categoryId: 'General Science',
        durationMinutes: 120,
        totalQuestions: 150,
        negativeMarking: 0.33,
        isProOnly: false,
        unlockPriceCoins: 0,
        testMode: 'mock',
      ),
      TestModel(
        id: 'test_math_02',
        title: 'Quantitative Aptitude Master Challenge',
        categoryId: 'Mathematics',
        durationMinutes: 60,
        totalQuestions: 50,
        negativeMarking: 0.25,
        isProOnly: false,
        unlockPriceCoins: 0,
        testMode: 'chapter',
      ),
      TestModel(
        id: 'test_reasoning_03',
        title: 'Logical & Analytical Reasoning Speed Test',
        categoryId: 'Reasoning',
        durationMinutes: 45,
        totalQuestions: 40,
        negativeMarking: 0.25,
        isProOnly: true,
        unlockPriceCoins: 50,
        testMode: 'topic',
      ),
      TestModel(
        id: 'test_ca_04',
        title: 'October 2026 Current Affairs Super Quiz',
        categoryId: 'Current Affairs',
        durationMinutes: 30,
        totalQuestions: 30,
        negativeMarking: 0.0,
        isProOnly: false,
        unlockPriceCoins: 0,
        testMode: 'daily',
      ),
      TestModel(
        id: 'test_pyq_05',
        title: '69th BPSC Prelims 2024 Solved Official Paper',
        categoryId: 'General Science',
        durationMinutes: 120,
        totalQuestions: 150,
        negativeMarking: 0.33,
        isProOnly: false,
        unlockPriceCoins: 0,
        testMode: 'previous-year',
      ),
      TestModel(
        id: 'test_chem_06',
        title: 'Organic Chemistry Reactions & Catalysts Test',
        categoryId: 'Chemistry',
        durationMinutes: 45,
        totalQuestions: 40,
        negativeMarking: 0.25,
        isProOnly: false,
        unlockPriceCoins: 0,
        testMode: 'chapter',
      ),
      TestModel(
        id: 'test_bio_07',
        title: 'Human Physiology & Cell Biology Mega Test',
        categoryId: 'Biology',
        durationMinutes: 50,
        totalQuestions: 50,
        negativeMarking: 0.25,
        isProOnly: false,
        unlockPriceCoins: 0,
        testMode: 'chapter',
      ),
      TestModel(
        id: 'test_live_08',
        title: 'All India Live Scholarship Championship #12',
        categoryId: 'General Science',
        durationMinutes: 90,
        totalQuestions: 100,
        negativeMarking: 0.33,
        isProOnly: false,
        unlockPriceCoins: 0,
        testMode: 'live',
      ),
    ];
  }

  List<TestModel> get _filteredTests {
    return _tests.where((test) {
      if (_searchQuery.isNotEmpty &&
          !test.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedSubject != null && _selectedSubject != 'All') {
        final subName = _selectedSubject!.replaceAll('\n', ' ');
        if (!test.title.toLowerCase().contains(subName.toLowerCase()) &&
            (test.categoryId == null || !test.categoryId!.toLowerCase().contains(subName.toLowerCase()))) {
          return false;
        }
      }
      if (_selectedTypeIndex > 0) {
        switch (_selectedTypeIndex) {
          case 1: // Daily Test
            if (test.testMode != 'daily') return false;
            break;
          case 2: // Mock Tests
            if (test.testMode != 'mock') return false;
            break;
          case 3: // Previous Year
            if (test.testMode != 'previous-year') return false;
            break;
          case 4: // Chapter Wise
            if (test.testMode != 'chapter') return false;
            break;
          case 5: // My Tests
            if (test.unlockPriceCoins > 0 && !test.isProOnly) return false;
            break;
        }
      }
      return true;
    }).toList();
  }

  void _showTestListDialog(String categoryTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
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
                  Expanded(
                    child: Text(
                      categoryTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Available ${categoryTitle.toLowerCase()} with official question patterns.',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _tests.length,
                  itemBuilder: (context, index) {
                    final test = _tests[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTestCard(test),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateYourOwnTestDialog() {
    String selectedSubject = 'General Science';
    int questionCount = 25;
    String difficulty = 'Medium';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.add_task_rounded, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text('Create Your Own Test', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customize questions, topics, and duration to target your weak areas.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                const Text('Select Subject:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    'General Science',
                    'Mathematics',
                    'Reasoning',
                    'Current Affairs',
                    'Chemistry',
                    'Biology',
                  ].map((s) {
                    final isSel = selectedSubject == s;
                    return ChoiceChip(
                      label: Text(s),
                      selected: isSel,
                      selectedColor: const Color(0xFF10B981),
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: (val) {
                        if (val) setDialogState(() => selectedSubject = s);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Number of Questions:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [10, 25, 50].map((count) {
                    final isSel = questionCount == count;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('$count Qs'),
                        selected: isSel,
                        selectedColor: const Color(0xFF10B981),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                        onSelected: (_) => setDialogState(() => questionCount = count),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Difficulty Level:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: ['Easy', 'Medium', 'Hard'].map((diff) {
                    final isSel = difficulty == diff;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(diff),
                        selected: isSel,
                        selectedColor: const Color(0xFF10B981),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                        onSelected: (_) => setDialogState(() => difficulty = diff),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                final customTest = TestModel(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  title: 'Custom Practice: $selectedSubject ($difficulty)',
                  categoryId: selectedSubject,
                  durationMinutes: (questionCount * 1.2).toInt(),
                  totalQuestions: questionCount,
                  negativeMarking: 0.25,
                  isProOnly: false,
                  unlockPriceCoins: 0,
                  testMode: 'practice',
                );
                widget.onStartTest(customTest);
              },
              child: const Text('Generate & Start Test', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showTestSeriesExplorerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: const [
            Icon(Icons.military_tech_rounded, color: Color(0xFFFFD633)),
            SizedBox(width: 8),
            Text('Complete Test Series', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enrolled in full preparation test series with detailed video explanations, All-India rank analytics, and exam-level mock simulations.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _buildSeriesTile('70th BPSC Prelims 2026 Master Series', '30 Mocks • 4500 Qs • Bilingual'),
            const SizedBox(height: 10),
            _buildSeriesTile('SSC CGL 2026 Tier 1 & 2 Champion Series', '50 Mocks • 7500 Qs • TCS Pattern'),
            const SizedBox(height: 10),
            _buildSeriesTile('RRB NTPC & Group D Super Series', '40 Mocks • 6000 Qs • Technical & Non-Tech'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B21B6)),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _selectedTypeIndex = 2; // Switch to Mock Tests
              });
            },
            child: const Text('View All Series', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesTile(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF7C3AED), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(TestModel test) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.lock_open_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text('Unlock Test Series', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(test.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Price to Unlock:'),
                  Text(
                    '${test.unlockPriceCoins} Coins',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text('Your current balance: ${widget.userCoins} Coins', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onStartTest(test);
            },
            child: const Text('Unlock & Start', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 960;

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
                    // Main Content Column (~72%)
                    Expanded(
                      flex: 72,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Tests Hero Banner
                          TestsHeroBanner(
                            borderRadius: BorderRadius.circular(12),
                            onStartPracticing: () {
                              if (_filteredTests.isNotEmpty) {
                                widget.onStartTest(_filteredTests.first);
                              }
                            },
                          ),
                          const SizedBox(height: 18),

                          // 2. Four User Statistics Cards
                          _buildStatisticsGrid(isDesktop, isTablet),
                          const SizedBox(height: 18),

                          // 3. Test-Type Navigation Bar
                          TestTypeNavigation(
                            selectedIndex: _selectedTypeIndex,
                            onSelect: (index) {
                              setState(() {
                                _selectedTypeIndex = index;
                              });
                            },
                          ),
                          const SizedBox(height: 22),

                          // 4. Select Subject Section (6 cards row)
                          _buildSelectSubjectSection(isDesktop: true),
                          const SizedBox(height: 22),

                          // 5. Test Categories Section (2 columns)
                          _buildTestCategoriesSection(isDesktop, isTablet),
                          const SizedBox(height: 22),

                          // 6. Bottom Promotional Banners ("Test Series" & "Create Your Own Test")
                          _buildPromotionalBanners(isDesktop, isTablet),
                          const SizedBox(height: 24),

                          // 7. Filtered Tests Catalog List (Interactive drill-down)
                          _buildFilteredCatalogSection(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Right Sidebar Column (~28%)
                    Expanded(
                      flex: 28,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Today's Goal
                          _buildTodaysGoalSection(),
                          const SizedBox(height: 20),

                          // 2. Quick Actions & Rewards
                          _buildQuickActionsCard(),
                          const SizedBox(height: 20),

                          // 3. Upcoming Tests
                          _buildUpcomingTestsSection(),
                          const SizedBox(height: 20),

                          // 4. Top Performers
                          _buildTopPerformersSection(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

        // Mobile & Tablet Layout (Single column stacking)
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tests Hero Banner
              TestsHeroBanner(
                borderRadius: BorderRadius.circular(12),
                onStartPracticing: () {
                  if (_filteredTests.isNotEmpty) {
                    widget.onStartTest(_filteredTests.first);
                  }
                },
              ),
              const SizedBox(height: 18),

              // 2. Upcoming Tests (Mobile: directly below Hero Section)
              _buildUpcomingTestsSection(),
              const SizedBox(height: 20),

              // 3. Four User Statistics Cards
              _buildStatisticsGrid(isDesktop, isTablet),
              const SizedBox(height: 18),

              // 4. Test-Type Navigation Bar
              TestTypeNavigation(
                selectedIndex: _selectedTypeIndex,
                onSelect: (index) {
                  setState(() {
                    _selectedTypeIndex = index;
                  });
                },
              ),
              const SizedBox(height: 22),

              // 5. Select Subject Section
              _buildSelectSubjectSection(isDesktop: false),
              const SizedBox(height: 22),

              // 6. Test Categories Section
              _buildTestCategoriesSection(isDesktop, isTablet),
              const SizedBox(height: 22),

              // 7. Bottom Promotional Banners
              _buildPromotionalBanners(isDesktop, isTablet),
              const SizedBox(height: 24),

              // 8. Today's Goal
              _buildTodaysGoalSection(),
              const SizedBox(height: 20),

              // 9. Quick Actions & Rewards
              _buildQuickActionsCard(),
              const SizedBox(height: 20),

              // 10. Top Performers
              _buildTopPerformersSection(),
              const SizedBox(height: 24),

              // 11. Filtered Tests Catalog List
              _buildFilteredCatalogSection(),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  // --- 2. Statistics Grid (4 Metric Cards) ---
  Widget _buildStatisticsGrid(bool isDesktop, bool isTablet) {
    final metrics = [
      (
        icon: Icons.description_rounded,
        label: 'Tests Attempted',
        value: '28',
        color: const Color(0xFF10B981),
        bg: const Color(0xFFF0FDF4),
      ),
      (
        icon: Icons.track_changes_rounded,
        label: 'Average Score',
        value: '78%',
        color: const Color(0xFF8B5CF6),
        bg: const Color(0xFFF5F3FF),
      ),
      (
        icon: Icons.bar_chart_rounded,
        label: 'Rank Position',
        value: '#1256',
        color: const Color(0xFFF59E0B),
        bg: const Color(0xFFFFFBEB),
      ),
      (
        icon: Icons.emoji_events_rounded,
        label: 'Coins Earned',
        value: widget.userCoins > 0 ? _formatNumber(widget.userCoins) : '1,250',
        color: const Color(0xFFF43F5E),
        bg: const Color(0xFFFFF1F2),
      ),
    ];

    return AppMetricsRow(
      breakpoint: isDesktop ? 600 : 640,
      spacing: isDesktop ? 12 : 8,
      cards: [
        for (final m in metrics)
          TestMetricCard(
            icon: m.icon,
            label: m.label,
            value: m.value,
            accentColor: m.color,
            backgroundColor: m.bg,
          ),
      ],
    );
  }

  // --- 4. Select Subject Section ---
  Widget _buildSelectSubjectSection({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: const [
                  Icon(Icons.grid_view_rounded, color: Color(0xFF2587F8), size: 19),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select Subject',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedSubject = null; // Clear subject filter
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2587F8),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: Color(0xFF2587F8),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (isDesktop)
          Row(
            children: [
              for (int i = 0; i < _subjects.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: SubjectSelectionCard(
                    title: _subjects[i].title,
                    questionCount: _subjects[i].questionCount,
                    icon: _subjects[i].icon,
                    accentColor: _subjects[i].color,
                    backgroundColor: _subjects[i].bg,
                    width: null,
                    isSelected: _selectedSubject == _subjects[i].title,
                    onTap: () {
                      setState(() {
                        if (_selectedSubject == _subjects[i].title) {
                          _selectedSubject = null;
                        } else {
                          _selectedSubject = _subjects[i].title;
                        }
                      });
                    },
                  ),
                ),
              ],
            ],
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (int i = 0; i < _subjects.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  SubjectSelectionCard(
                    title: _subjects[i].title,
                    questionCount: _subjects[i].questionCount,
                    icon: _subjects[i].icon,
                    accentColor: _subjects[i].color,
                    backgroundColor: _subjects[i].bg,
                    isSelected: _selectedSubject == _subjects[i].title,
                    onTap: () {
                      setState(() {
                        if (_selectedSubject == _subjects[i].title) {
                          _selectedSubject = null;
                        } else {
                          _selectedSubject = _subjects[i].title;
                        }
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  // --- 5. Test Categories Section (2 Columns matching reference) ---
  Widget _buildTestCategoriesSection(bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.description_rounded, color: Color(0xFF2587F8), size: 19),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Test Categories',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final isSingleColumn = constraints.maxWidth < 480;

            if (isSingleColumn) {
              return Column(
                children: [
                  for (int i = 0; i < _categories.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    TestCategoryCard(
                      icon: _categories[i].icon,
                      title: _categories[i].title,
                      description: _categories[i].description,
                      testsCount: _categories[i].testsCount,
                      questionsCount: _categories[i].questionsCount,
                      leftMetaIcon: _categories[i].leftIcon,
                      rightMetaIcon: _categories[i].rightIcon,
                      accentColor: _categories[i].color,
                      onTap: () => _showTestListDialog(_categories[i].title),
                    ),
                  ],
                ],
              );
            }

            // 2-column layout matching reference screenshot
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 124,
              ),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return TestCategoryCard(
                  icon: cat.icon,
                  title: cat.title,
                  description: cat.description,
                  testsCount: cat.testsCount,
                  questionsCount: cat.questionsCount,
                  leftMetaIcon: cat.leftIcon,
                  rightMetaIcon: cat.rightIcon,
                  accentColor: cat.color,
                  onTap: () => _showTestListDialog(cat.title),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // --- Right Sidebar: 1. Today's Goal ---
  Widget _buildTodaysGoalSection() {
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE3EAF7), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06101A3A),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildDartboardTarget(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Goal",
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text(
                                '3/5 Tests',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF10B981).withAlpha(25),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.6,
                            minHeight: 6,
                            backgroundColor: Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Complete 5 tests today to earn 50 coins!',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildDartboardTarget() {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEF4444),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEF4444),
            ),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2587F8),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Transform.rotate(
              angle: -0.6,
              child: const Icon(
                Icons.navigation_rounded,
                size: 24,
                color: Color(0xFF2587F8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Right Sidebar: 2. Quick Actions & Rewards ---
  Widget _buildQuickActionsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Quick Actions & Rewards',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Action 1: Spin Lucky Wheel
        InkWell(
          onTap: () {
            if (widget.onSpinWheel != null) {
              widget.onSpinWheel!();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Spin Lucky Wheel...')),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Color(0xFFEF4444),
                        Color(0xFFF59E0B),
                        Color(0xFF10B981),
                        Color(0xFF2587F8),
                        Color(0xFF8B5CF6),
                        Color(0xFFEC4899),
                        Color(0xFFEF4444),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Spin Lucky Wheel',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Win up to 500 Coins today',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFD97706),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Action 2: 1v1 Quiz Battle
        InkWell(
          onTap: () {
            if (widget.onOpenBattle != null) {
              widget.onOpenBattle!();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Entering 1v1 Quiz Battle Arena...')),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDDD6FE), width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF7C3AED).withAlpha(40),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.sports_esports_rounded,
                      color: Color(0xFF7C3AED),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '1v1 Quiz Battle',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Challenge live aspirants now',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF7C3AED),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Right Sidebar: 3. Upcoming Tests ---
  Widget _buildUpcomingTestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: const [
                  Icon(Icons.calendar_month_rounded, color: Color(0xFF2587F8), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Upcoming Tests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                if (widget.onOpenLive != null) {
                  widget.onOpenLive!();
                } else {
                  setState(() => _selectedTypeIndex = 1);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2587F8),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF2587F8)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Card 1: Live Contest Card matching user reference design
        LiveContestCard(
          title: 'Physics Live Test',
          tagline: 'Test & Win Rewards!',
          questions: '10 Qs',
          duration: '10 Mins',
          joined: '0 Joined',
          prizePool: '0',
          entryFee: '10',
          endsIn: '210:06:33',
          startsAt: '21 Oct, 05:38 am',
          isLive: true,
          onJoin: () {
            final liveTest = _tests.firstWhere(
              (t) => t.testMode == 'live',
              orElse: () => _tests.first,
            );
            widget.onStartTest(liveTest);
          },
          onShare: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Live Test link copied! Share with friends.'),
                backgroundColor: Color(0xFFE5252A),
              ),
            );
          },
        ),
        const SizedBox(height: 10),

        // Card 2: General Science Mega Test (matching LiveContestCard design system)
        LiveContestCard(
          title: 'General Science Mega Test',
          tagline: 'All India Scholarship Challenge!',
          icon: Icons.emoji_events_rounded,
          questions: '120 Qs',
          duration: '90 Mins',
          joined: '1.2k Joined',
          prizePool: '25,000',
          entryFee: 'FREE',
          countdownTime: '05:22:10',
          countdownLabel: 'STARTS IN',
          startsAt: '21 Oct, 06:00 pm',
          isLive: false,
          statusLabel: 'UPCOMING',
          accentColor: AppColors.brandBlue,
          accentLightColor: AppColors.infoBlueLight,
          accentBorderColor: AppColors.infoBlueBorder,
          primaryButtonLabel: 'NOTIFY ME',
          primaryButtonLeadingIcon: const Icon(
            Icons.notifications_none_rounded,
            size: 15,
            color: Colors.white,
          ),
          onJoin: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reminder set for General Science Mega Test!'),
                backgroundColor: Color(0xFF2587F8),
              ),
            );
          },
          onShare: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mega Test link copied! Share with friends.'),
                backgroundColor: Color(0xFF2587F8),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- Right Sidebar: 4. Top Performers ---
  Widget _buildTopPerformersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: const [
                  Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Top Performers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                if (widget.onOpenLeaderboard != null) {
                  widget.onOpenLeaderboard!();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Viewing All-India Leaderboard...')),
                  );
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2587F8),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF2587F8)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE3EAF7), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06101A3A),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildLeaderboardRow(
                rank: 1,
                name: 'Aarav Sharma',
                coins: '3,420',
                rankBgColor: const Color(0xFFFEF3C7),
                rankTextColor: const Color(0xFFD97706),
                avatarColor: const Color(0xFF3B82F6),
                isUser: false,
              ),
              const Divider(height: 14, color: Color(0xFFF1F5F9)),
              _buildLeaderboardRow(
                rank: 2,
                name: 'Priya Patel',
                coins: '2,980',
                rankBgColor: const Color(0xFFF1F5F9),
                rankTextColor: const Color(0xFF64748B),
                avatarColor: const Color(0xFFEC4899),
                isUser: false,
              ),
              const Divider(height: 14, color: Color(0xFFF1F5F9)),
              _buildLeaderboardRow(
                rank: 3,
                name: 'Vikram Singh (You)',
                coins: '1,450',
                rankBgColor: const Color(0xFFFFEDD5),
                rankTextColor: const Color(0xFFB45309),
                avatarColor: const Color(0xFF10B981),
                isUser: true,
              ),
              const Divider(height: 14, color: Color(0xFFF1F5F9)),
              _buildLeaderboardRow(
                rank: 4,
                name: 'Ananya Mishra',
                coins: '1,320',
                rankBgColor: const Color(0xFFF8FAFC),
                rankTextColor: const Color(0xFF64748B),
                avatarColor: const Color(0xFF8B5CF6),
                isUser: false,
              ),
              const Divider(height: 14, color: Color(0xFFF1F5F9)),
              _buildLeaderboardRow(
                rank: 5,
                name: 'Rohan Verma',
                coins: '1,190',
                rankBgColor: const Color(0xFFF8FAFC),
                rankTextColor: const Color(0xFF64748B),
                avatarColor: const Color(0xFFF59E0B),
                isUser: false,
              ),
              const Divider(height: 14, color: Color(0xFFF1F5F9)),
              _buildLeaderboardRow(
                rank: 6,
                name: 'Sneha Reddy',
                coins: '1,050',
                rankBgColor: const Color(0xFFF8FAFC),
                rankTextColor: const Color(0xFF64748B),
                avatarColor: const Color(0xFF06B6D4),
                isUser: false,
              ),
              const Divider(height: 14, color: Color(0xFFF1F5F9)),
              _buildLeaderboardRow(
                rank: 7,
                name: 'Rahul Kumar',
                coins: '980',
                rankBgColor: const Color(0xFFF8FAFC),
                rankTextColor: const Color(0xFF64748B),
                avatarColor: const Color(0xFF6366F1),
                isUser: false,
              ),
              const Divider(height: 14, color: Color(0xFFF1F5F9)),
              _buildLeaderboardRow(
                rank: 8,
                name: 'Pooja Gupta',
                coins: '890',
                rankBgColor: const Color(0xFFF8FAFC),
                rankTextColor: const Color(0xFF64748B),
                avatarColor: const Color(0xFFF43F5E),
                isUser: false,
              ),
              const Divider(height: 14, color: Color(0xFFF1F5F9)),
              _buildLeaderboardRow(
                rank: 9,
                name: 'Amit Deshmukh',
                coins: '810',
                rankBgColor: const Color(0xFFF8FAFC),
                rankTextColor: const Color(0xFF64748B),
                avatarColor: const Color(0xFF14B8A6),
                isUser: false,
              ),
              const Divider(height: 14, color: Color(0xFFF1F5F9)),
              _buildLeaderboardRow(
                rank: 10,
                name: 'Neha Joshi',
                coins: '750',
                rankBgColor: const Color(0xFFF8FAFC),
                rankTextColor: const Color(0xFF64748B),
                avatarColor: const Color(0xFF84CC16),
                isUser: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow({
    required int rank,
    required String name,
    required String coins,
    required Color rankBgColor,
    required Color rankTextColor,
    required Color avatarColor,
    required bool isUser,
  }) {
    return Row(
      children: [
        // Rank circle
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: rankBgColor,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: rank >= 10 ? 10 : 11,
                fontWeight: FontWeight.w900,
                color: rankTextColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Avatar
        CircleAvatar(
          radius: 14,
          backgroundColor: avatarColor,
          child: Text(
            name[0],
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Name
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isUser ? FontWeight.w900 : FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        // Coins
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF59E0B),
              ),
              child: const Center(
                child: Text(
                  'C',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              coins,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 6. Promotional Banners ---
  Widget _buildPromotionalBanners(bool isDesktop, bool isTablet) {
    final testSeriesBanner = TestPromoCard(
      title: 'Test Series',
      description: 'Complete series for full preparation',
      ctaText: 'Explore',
      isDarkPurple: true,
      onCtaPressed: _showTestSeriesExplorerDialog,
    );

    final createTestBanner = TestPromoCard(
      title: 'Create Your Own Test',
      description: 'Choose topics, set questions and practice.',
      ctaText: 'Create',
      isDarkPurple: false,
      onCtaPressed: _showCreateYourOwnTestDialog,
    );

    if (isDesktop || isTablet) {
      return Row(
        children: [
          Expanded(child: testSeriesBanner),
          const SizedBox(width: 14),
          Expanded(child: createTestBanner),
        ],
      );
    }

    return Column(
      children: [
        testSeriesBanner,
        const SizedBox(height: 12),
        createTestBanner,
      ],
    );
  }

  // --- 7. Filtered Tests Catalog ---
  Widget _buildFilteredCatalogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedSubject != null
                    ? '${_selectedSubject!.replaceAll('\n', ' ')} Tests (${_filteredTests.length})'
                    : 'Recommended Tests (${_filteredTests.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_selectedSubject != null || _selectedTypeIndex > 0)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedSubject = null;
                    _selectedTypeIndex = 0;
                  });
                },
                icon: const Icon(Icons.clear_rounded, size: 14),
                label: const Text('Reset', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_filteredTests.isEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.menu_book_outlined, size: 40, color: AppColors.textMuted),
                  const SizedBox(height: 8),
                  const Text('No tests found matching criteria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Show All Tests',
                    size: AppButtonSize.small,
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    borderRadius: AppRadii.borderMd,
                    onPressed: () {
                      setState(() {
                        _selectedSubject = null;
                        _selectedTypeIndex = 0;
                      });
                    },
                  ),
                ],
              ),
            ),
          )
        else
          for (final test in _filteredTests)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTestCard(test),
            ),
      ],
    );
  }

  Widget _buildTestCard(TestModel test) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        test.categoryId ?? 'General',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2587F8),
                        ),
                      ),
                    ),
                    if (test.isPremium || test.unlockPriceCoins > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.monetization_on, size: 12, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 2),
                            Text(
                              '${test.unlockPriceCoins} Coins',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '100% Free',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${test.durationMinutes} mins',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            test.title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '${test.totalQuestions} Questions • -${test.negativeMarking} Negative • Mode: ${test.testMode.toUpperCase()}',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  test.isPremium || test.unlockPriceCoins > 0
                      ? 'Unlock with ${test.unlockPriceCoins} Coins'
                      : 'Unlimited Free Practice',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: test.isPremium ? const Color(0xFFD97706) : const Color(0xFF059669),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              AppButton(
                label: test.isPremium ? 'Unlock Test' : 'Start Test',
                size: AppButtonSize.small,
                backgroundColor: test.isPremium ? const Color(0xFF7C3AED) : const Color(0xFF10B981),
                foregroundColor: Colors.white,
                borderRadius: AppRadii.borderMd,
                onPressed: () {
                  if (test.isPremium && test.unlockPriceCoins > 0) {
                    _showPurchaseDialog(test);
                  } else {
                    widget.onStartTest(test);
                  }
                },
              ),
            ],
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
}
