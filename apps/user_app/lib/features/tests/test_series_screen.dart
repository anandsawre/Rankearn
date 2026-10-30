import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'screens/exam_tests_screen.dart';
import '../live/dialogs/contest_entry_dialog.dart';

class TestSeriesScreen extends StatefulWidget {
  final int userCoins;
  final String? userId;
  final void Function(TestModel test) onStartTest;
  final List<TestModel>? initialTests;
  final VoidCallback? onOpenBattle;
  final VoidCallback? onSpinWheel;
  final VoidCallback? onOpenLive;
  final VoidCallback? onOpenLeaderboard;
  final VoidCallback? onViewLastResult;
  final VoidCallback? onOpenWallet;
  final void Function(int coins)? onCoinDeducted;

  const TestSeriesScreen({
    super.key,
    required this.userCoins,
    this.userId,
    required this.onStartTest,
    this.initialTests,
    this.onOpenBattle,
    this.onSpinWheel,
    this.onOpenLive,
    this.onOpenLeaderboard,
    this.onViewLastResult,
    this.onOpenWallet,
    this.onCoinDeducted,
  });

  @override
  State<TestSeriesScreen> createState() => _TestSeriesScreenState();
}

class _TestSeriesScreenState extends State<TestSeriesScreen> {
  int _selectedTypeIndex =
      0; // 0: All Tests, 1: Daily Test, 2: Mock Tests, 3: PYQ, 4: Chapter Wise, 5: My Tests
  String? _selectedExamId; // null or 'all' = All Exams, or 'bpsc', 'ssc', etc.
  String? _selectedSubject;
  CategoryModel? _selectedCategory;
  String? _selectedTopic;
  final String _searchQuery = '';
  bool _isLoading = false;
  List<TestModel> _tests = [];
  List<TestModel> _upcomingAndLiveTests = [];
  Set<String> _registeredContestIds = {};
  List<ExamCategoryModel> _examCategories = [];
  List<CategoryModel> _allCategories = [];
  StreamSubscription<List<CategoryModel>>? _categoriesSub;
  Timer? _ticker;

  List<
    ({String title, String questionCount, IconData icon, Color color, Color bg})
  >
  _subjects = [];



  @override
  void initState() {
    super.initState();
    if (widget.initialTests != null && widget.initialTests!.isNotEmpty) {
      _tests = List.from(widget.initialTests!);
      _isLoading = false;
    } else {
      _tests = _getFallbackTests();
      _isLoading = false;
    }
    _extractUpcomingTests();
    _loadTests();
    _startCountdownTicker();
  }

  void _startCountdownTicker() {
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTest) return;

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _extractUpcomingTests([List<TestModel>? additional]) {
    final List<TestModel> candidates = [];
    if (additional != null) {
      candidates.addAll(additional);
    }
    candidates.addAll(
      _tests.where(
        (t) =>
            t.isTournament ||
            t.testMode == 'live' ||
            t.scheduledStartTime != null,
      ),
    );

    final seenIds = <String>{};
    final unique = <TestModel>[];
    for (final t in candidates) {
      if (seenIds.add(t.id)) {
        unique.add(t);
      }
    }

    // Filter out past / ended tests
    final active = unique.where((t) => (t.isLive || t.isUpcoming) && !t.isPast).toList();

    // Sort: Live tests first, then upcoming by start time
    active.sort((a, b) {
      if (a.isLive && !b.isLive) return -1;
      if (!a.isLive && b.isLive) return 1;
      final aTime = a.scheduledStartTime ?? DateTime.now();
      final bTime = b.scheduledStartTime ?? DateTime.now();
      return aTime.compareTo(bTime);
    });

    _upcomingAndLiveTests = active;
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

  Color _resolveCategoryColor(
    String hex, [
    Color fallback = const Color(0xFF2587F8),
  ]) {
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

  void _applyCategories([List<CategoryModel>? categories]) {
    final source = categories ?? _allCategories;
    if (source.isEmpty) return;

    final filtered = (_selectedExamId == null || _selectedExamId == 'all')
        ? source
        : source
              .where(
                (c) =>
                    c.examCategoryId != null &&
                    (c.examCategoryId!.toLowerCase() ==
                            _selectedExamId!.toLowerCase() ||
                        c.examCategoryId == _selectedExamId),
              )
              .toList();

    final mapped = filtered.map((c) {
      final accent = _resolveCategoryColor(c.iconColor);
      final countText = c.totalQuestions > 0
          ? '${c.totalQuestions}+ Qs'
          : (c.topics.isNotEmpty
                ? '${c.topics.length} Chapters'
                : 'Practice Qs');
      return (
        title: c.name,
        questionCount: countText,
        icon: _resolveCategoryIcon(c.iconName),
        color: accent,
        bg: accent.withAlpha(25),
      );
    }).toList();

    setState(() {
      _subjects = mapped;
    });
  }

  void _onSelectExam(String? examId) {
    setState(() {
      if (_selectedExamId == examId) {
        _selectedExamId = null;
      } else {
        _selectedExamId = examId;
      }
      _selectedSubject = null;
      _selectedCategory = null;
      _selectedTopic = null;
      _applyCategories();
    });
  }

  void _openExamScreen(ExamCategoryModel exam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamTestsScreen(
          exam: exam,
          userCoins: widget.userCoins,
          onStartTest: widget.onStartTest,
          allTests: _tests,
          allCategories: _allCategories,
        ),
      ),
    );
  }

  void _onSelectSubject(String title) {
    setState(() {
      if (_selectedSubject == title) {
        _selectedSubject = null;
        _selectedCategory = null;
        _selectedTopic = null;
      } else {
        _selectedSubject = title;
        _selectedCategory = _allCategories.cast<CategoryModel?>().firstWhere(
          (c) => c != null && c.name.toLowerCase() == title.toLowerCase(),
          orElse: () => null,
        );
        _selectedTopic = null;
      }
    });
  }

  void _onSelectTopic(String? topic) {
    setState(() {
      if (_selectedTopic == topic) {
        _selectedTopic = null;
      } else {
        _selectedTopic = topic;
      }
    });
  }

  Future<void> _loadTests() async {
    final testsRepo = TestsRepository();
    final res = await testsRepo.getTests();
    final catRes = await testsRepo.getCategories();
    final examRes = await testsRepo.getExamCategoryList();
    final tourRes = await ContestsRepository().getTournaments();
    final registered = await ContestsRepository()
        .getUserRegisteredTournamentIds(widget.userId ?? '');

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _registeredContestIds = registered;
      if (res is Success<List<TestModel>> && res.data.isNotEmpty) {
        _tests = res.data;
      } else if (_tests.isEmpty) {
        _tests = _getFallbackTests();
      }
      if (examRes is Success<List<ExamCategoryModel>>) {
        _examCategories = examRes.data;
      }

      final List<TestModel> extra = [];
      if (tourRes is Success<List<TestModel>>) {
        extra.addAll(tourRes.data);
      }
      _extractUpcomingTests(extra);
    });

    if (catRes is Success<List<CategoryModel>>) {
      _allCategories = catRes.data;
      _applyCategories(catRes.data);
    }

    _categoriesSub ??= testsRepo.streamCategories().listen(
      (updated) {
        if (mounted && updated.isNotEmpty) {
          _allCategories = updated;
          _applyCategories(updated);
        }
      },
      onError: (_) {
        // Silently ignore channel close/reconnect events
      },
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _categoriesSub?.cancel();
    super.dispose();
  }

  Future<void> _handleJoinTest(TestModel test) async {
    // If user already pre-registered for this test, enter directly!
    if (_registeredContestIds.contains(test.id)) {
      widget.onStartTest(test);
      return;
    }

    final entryFee = test.entryFeeCoins;

    if (entryFee > 0) {
      final confirm = await showContestEntryDialog(
        context: context,
        test: test,
        userCoins: widget.userCoins,
        isPreRegister: false,
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

    if (mounted) {
      setState(() {
        _registeredContestIds.add(test.id);
      });
    }

    widget.onStartTest(test);
  }

  Future<void> _handlePreRegister(TestModel test) async {
    final entryFee = test.entryFeeCoins;

    if (entryFee > 0) {
      final confirm = await showContestEntryDialog(
        context: context,
        test: test,
        userCoins: widget.userCoins,
        isPreRegister: true,
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
    } else {
      // Free pre-registration
      final repo = ContestsRepository();
      await repo.joinTournamentSafe(
        testId: test.id,
        userId: widget.userId ?? '',
        entryFee: 0,
      );
    }

    if (!mounted) return;
    setState(() {
      _registeredContestIds.add(test.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✓ Successfully pre-registered for ${test.title}! You can enter directly when it goes live.',
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _formatShortDate(DateTime? dt) {
    if (dt == null) return 'Live Now';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = (dt.month >= 1 && dt.month <= 12) ? months[dt.month - 1] : '';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'pm' : 'am';
    return '${dt.day} $m, ${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  String _formatRemainingTime(DateTime? targetTime) {
    if (targetTime == null) return '00:00:00';
    final diff = targetTime.difference(DateTime.now());
    if (diff.isNegative) return '00:00:00';
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
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

      // 1. Exam category filter
      if (_selectedExamId != null && _selectedExamId != 'all') {
        final examQuery = _selectedExamId!.toLowerCase();
        final matchesExamId = test.examCategoryId != null &&
            (test.examCategoryId!.toLowerCase() == examQuery ||
                test.examCategoryId!.toLowerCase().contains(examQuery) ||
                examQuery.contains(test.examCategoryId!.toLowerCase()));
        final matchesTitle = test.title.toLowerCase().contains(examQuery);
        final matchesCategory =
            test.categoryId != null &&
            test.categoryId!.toLowerCase().contains(examQuery);

        final testCat = _allCategories.cast<CategoryModel?>().firstWhere(
          (c) =>
              c != null &&
              (c.id == test.categoryId ||
                  c.name.toLowerCase() == test.categoryId?.toLowerCase()),
          orElse: () => null,
        );
        final matchesExamCat =
            testCat != null &&
            testCat.examCategoryId != null &&
            (testCat.examCategoryId!.toLowerCase() == examQuery ||
                testCat.examCategoryId == _selectedExamId);

        if (!matchesExamId && !matchesTitle && !matchesCategory && !matchesExamCat) {
          return false;
        }
      }

      // 2. Subject filter
      if (_selectedCategory != null) {
        final catName = _selectedCategory!.name.toLowerCase();
        final catId = _selectedCategory!.id.toLowerCase();
        final matchesCat =
            (test.categoryId != null &&
                (test.categoryId!.toLowerCase() == catId ||
                    test.categoryId!.toLowerCase() == catName ||
                    test.categoryId!.toLowerCase().contains(catName) ||
                    catName.contains(test.categoryId!.toLowerCase()))) ||
            test.title.toLowerCase().contains(catName);
        if (!matchesCat) return false;
      } else if (_selectedSubject != null && _selectedSubject != 'All') {
        final subName = _selectedSubject!.replaceAll('\n', ' ').toLowerCase();
        if (!test.title.toLowerCase().contains(subName) &&
            (test.categoryId == null ||
                (!test.categoryId!.toLowerCase().contains(subName) &&
                    !subName.contains(test.categoryId!.toLowerCase())))) {
          return false;
        }
      }

      // 3. Topic filter
      if (_selectedTopic != null && _selectedTopic != 'All') {
        final topicQuery = _selectedTopic!.toLowerCase();
        if (!test.title.toLowerCase().contains(topicQuery) &&
            (test.categoryId == null ||
                !test.categoryId!.toLowerCase().contains(topicQuery))) {
          return false;
        }
      }

      // 4. Test mode filter
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
            if (test.testMode != 'chapter' && test.testMode != 'topic') {
              return false;
            }
            break;
          case 5: // My Tests
            if (test.unlockPriceCoins > 0 && !test.isProOnly) return false;
            break;
        }
      }
      return true;
    }).toList();
  }



  void _showCreateYourOwnTestDialog() {
    String selectedSubject = 'General Science';
    int questionCount = 25;
    String difficulty = 'Medium';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: const [
              Icon(Icons.add_task_rounded, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text(
                'Create Your Own Test',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customize questions, topics, and duration to target your weak areas.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Subject:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children:
                      [
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
                const Text(
                  'Number of Questions:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
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
                        onSelected: (_) =>
                            setDialogState(() => questionCount = count),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Difficulty Level:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
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
                        onSelected: (_) =>
                            setDialogState(() => difficulty = diff),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
              child: const Text(
                'Generate & Start Test',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            Text(
              'Complete Test Series',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
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
            _buildSeriesTile(
              '70th BPSC Prelims 2026 Master Series',
              '30 Mocks • 4500 Qs • Bilingual',
            ),
            const SizedBox(height: 10),
            _buildSeriesTile(
              'SSC CGL 2026 Tier 1 & 2 Champion Series',
              '50 Mocks • 7500 Qs • TCS Pattern',
            ),
            const SizedBox(height: 10),
            _buildSeriesTile(
              'RRB NTPC & Group D Super Series',
              '40 Mocks • 6000 Qs • Technical & Non-Tech',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B21B6),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _selectedTypeIndex = 2; // Switch to Mock Tests
              });
            },
            child: const Text(
              'View All Series',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            child: const Icon(
              Icons.assignment_turned_in_rounded,
              color: Color(0xFF7C3AED),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
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
            Text(
              'Unlock Test Series',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              test.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your current balance: ${widget.userCoins} Coins',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onStartTest(test);
            },
            child: const Text(
              'Unlock & Start',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 960;

        if (isDesktop) {
          return RefreshIndicator(
            onRefresh: _loadTests,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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

                      // 3. Exam Category Selector (Level 1 Drill-Down)
                      _buildExamCategorySelector(isDesktop, isTablet),
                      const SizedBox(height: 20),

                      // 4. Select Subject Section (Level 2 Drill-Down: shown for Chapter Wise & All Tests)
                      if (_selectedTypeIndex == 4 || _selectedTypeIndex == 0) ...[
                        _buildSelectSubjectSection(isDesktop: true),
                        _buildTopicChipsSection(),
                        const SizedBox(height: 22),
                      ],

                      // 6. Filtered Tests Catalog List (Interactive Level 4 tests)
                      _buildFilteredCatalogSection(),
                      const SizedBox(height: 28),

                      // 7. Bottom Promotional Banners ("Test Series" & "Create Your Own Test")
                      _buildPromotionalBanners(isDesktop, isTablet),
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
          ),
          );
        }

        // Mobile & Tablet Layout (Single column stacking)
        return RefreshIndicator(
          onRefresh: _loadTests,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
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

              // 2. Four User Statistics Cards
              _buildStatisticsGrid(isDesktop, isTablet),
              const SizedBox(height: 18),

              // 3. Exam Category Selector (Level 1 Drill-Down)
              _buildExamCategorySelector(isDesktop, isTablet),
              const SizedBox(height: 20),

              // 4. Upcoming Tests (Mobile: directly below Hero Section)
              _buildUpcomingTestsSection(),
              const SizedBox(height: 20),

              // 5. Select Subject Section (Level 2 Drill-Down: shown for Chapter Wise & All Tests)
              if (_selectedTypeIndex == 4 || _selectedTypeIndex == 0) ...[
                _buildSelectSubjectSection(isDesktop: false),
                _buildTopicChipsSection(),
                const SizedBox(height: 22),
              ],

              // 7. Filtered Tests Catalog List (IMMEDIATELY visible to student!)
              _buildFilteredCatalogSection(),
              const SizedBox(height: 24),

              // 8. Bottom Promotional Banners
              _buildPromotionalBanners(isDesktop, isTablet),
              const SizedBox(height: 24),

              // 9. Today's Goal
              _buildTodaysGoalSection(),
              const SizedBox(height: 20),

              // 10. Quick Actions & Rewards
              _buildQuickActionsCard(),
              const SizedBox(height: 20),

              // 11. Top Performers
              _buildTopPerformersSection(),
              const SizedBox(height: 24),
            ],
          ),
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

  // --- Exam Category Selector Bar ---
  Widget _buildExamCategorySelector(bool isDesktop, bool isTablet) {
    final exams = _examCategories.isNotEmpty
        ? _examCategories
        : const [
            ExamCategoryModel(
              id: 'bpsc',
              name: 'BPSC & State PCS',
              normalizedName: 'bpsc',
              iconUrl: '🏛️',
              totalTests: 35,
              totalMocks: 15,
              totalSectional: 20,
            ),
            ExamCategoryModel(
              id: 'ssc',
              name: 'SSC CGL & CHSL',
              normalizedName: 'ssc',
              iconUrl: '📋',
              totalTests: 45,
              totalMocks: 20,
              totalSectional: 25,
            ),
            ExamCategoryModel(
              id: 'upsc',
              name: 'UPSC Civil Services',
              normalizedName: 'upsc',
              iconUrl: '🇮🇳',
              totalTests: 25,
              totalMocks: 10,
              totalSectional: 15,
            ),
            ExamCategoryModel(
              id: 'railway',
              name: 'RRB NTPC & Group D',
              normalizedName: 'railway',
              iconUrl: '🚆',
              totalTests: 30,
              totalMocks: 12,
              totalSectional: 18,
            ),
            ExamCategoryModel(
              id: 'banking',
              name: 'Banking & Insurance',
              normalizedName: 'banking',
              iconUrl: '🏦',
              totalTests: 28,
              totalMocks: 14,
              totalSectional: 14,
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.explore_rounded, color: Color(0xFF10B981), size: 19),
                SizedBox(width: 8),
                Text(
                  'Target Exam Category',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (_selectedExamId != null)
              InkWell(
                onTap: () => _onSelectExam(null),
                child: const Text(
                  'View All Exams',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildExamCard(
                index: 0,
                id: 'all',
                name: 'All Exams',
                badgeText: 'All Tests',
                isSelected: _selectedExamId == null || _selectedExamId == 'all',
                onTap: () => _onSelectExam('all'),
              ),
              const SizedBox(width: 10),
              for (int i = 0; i < exams.length; i++) ...[
                _buildExamCard(
                  index: i + 1,
                  id: exams[i].id,
                  name: exams[i].name,
                  badgeText:
                      '${exams[i].totalMocks} Mock • ${exams[i].totalSectional} Sec',
                  isSelected: _selectedExamId == exams[i].id,
                  onTap: () {
                    _onSelectExam(exams[i].id);
                    _openExamScreen(exams[i]);
                  },
                ),
                const SizedBox(width: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExamCard({
    required int index,
    required String id,
    required String name,
    required String badgeText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final palette = _getExamPalette(index);
    final iconData = _resolveExamVectorIcon(name, id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: 122,
      height: 144,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.bg, palette.bgEnd],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? palette.accent : palette.border.withAlpha(160),
          width: isSelected ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? palette.accent.withAlpha(40)
                : palette.accent.withAlpha(12),
            blurRadius: isSelected ? 12 : 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                // Background Design 1: Top-Right Decorative Glow Circle
                Positioned(
                  top: -16,
                  right: -16,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.accent.withAlpha(isSelected ? 28 : 16),
                    ),
                  ),
                ),
                // Background Design 2: Top-Right Concentric Ring
                Positioned(
                  top: -26,
                  right: -26,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: palette.accent.withAlpha(isSelected ? 32 : 18),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                // Background Design 3: Bottom-Right Tilted Watermark Icon
                Positioned(
                  bottom: -8,
                  right: -8,
                  child: Transform.rotate(
                    angle: -0.15,
                    child: Icon(
                      iconData,
                      size: 54,
                      color: palette.accent.withAlpha(isSelected ? 30 : 18),
                    ),
                  ),
                ),
                // Background Design 4: Bottom-Left Soft White Highlight Bubble
                Positioned(
                  bottom: -20,
                  left: -20,
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(isSelected ? 110 : 70),
                    ),
                  ),
                ),
                // Foreground Content
                SizedBox.expand(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: palette.accent.withAlpha(22),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            iconData,
                            color: palette.accent,
                            size: 23,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: isSelected
                                    ? palette.accent
                                    : const Color(0xFF1E293B),
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? palette.accent.withAlpha(25)
                                    : Colors.white.withAlpha(190),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                badgeText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? palette.accent
                                      : const Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        color: palette.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static _ExamCategoryStyle _getExamPalette(int index) {
    const palettes = [
      _ExamCategoryStyle(
        bg: Color(0xFFF5F7FF), // Soft Indigo
        bgEnd: Color(0xFFE0E7FF),
        border: Color(0xFFC7D2FE),
        accent: Color(0xFF4F46E5),
      ),
      _ExamCategoryStyle(
        bg: Color(0xFFF0FDF4), // Soft Emerald
        bgEnd: Color(0xFFD1FAE5),
        border: Color(0xFFA7F3D0),
        accent: Color(0xFF059669),
      ),
      _ExamCategoryStyle(
        bg: Color(0xFFFFFDF5), // Soft Amber
        bgEnd: Color(0xFFFEF3C7),
        border: Color(0xFFFDE68A),
        accent: Color(0xFFD97706),
      ),
      _ExamCategoryStyle(
        bg: Color(0xFFFAF5FF), // Soft Purple
        bgEnd: Color(0xFFF3E8FF),
        border: Color(0xFFE9D5FF),
        accent: Color(0xFF7C3AED),
      ),
      _ExamCategoryStyle(
        bg: Color(0xFFFFF5F6), // Soft Rose
        bgEnd: Color(0xFFFFE4E6),
        border: Color(0xFFFECDD3),
        accent: Color(0xFFE11D48),
      ),
      _ExamCategoryStyle(
        bg: Color(0xFFF0FDFF), // Soft Cyan
        bgEnd: Color(0xFFCFFAFE),
        border: Color(0xFFA5F3FC),
        accent: Color(0xFF0891B2),
      ),
      _ExamCategoryStyle(
        bg: Color(0xFFFFF8F1), // Soft Orange
        bgEnd: Color(0xFFFFEDD5),
        border: Color(0xFFFED7AA),
        accent: Color(0xFFEA580C),
      ),
      _ExamCategoryStyle(
        bg: Color(0xFFF0FDF9), // Soft Teal
        bgEnd: Color(0xFFCCFBF1),
        border: Color(0xFF99F6E4),
        accent: Color(0xFF0D9488),
      ),
    ];
    return palettes[index % palettes.length];
  }

  static IconData _resolveExamVectorIcon(String name, String id) {
    final lower = ('$name $id').toLowerCase();
    if (id == 'all') return Icons.layers_rounded;
    if (lower.contains('bpsc') ||
        lower.contains('state pcs') ||
        lower.contains('civil') ||
        lower.contains('pcs')) {
      return Icons.account_balance_rounded;
    }
    if (lower.contains('upsc') ||
        lower.contains('ias') ||
        lower.contains('ips')) {
      return Icons.military_tech_rounded;
    }
    if (lower.contains('ssc') ||
        lower.contains('cgl') ||
        lower.contains('chsl') ||
        lower.contains('mts')) {
      return Icons.assignment_rounded;
    }
    if (lower.contains('railway') ||
        lower.contains('rrb') ||
        lower.contains('ntpc') ||
        lower.contains('group d')) {
      return Icons.train_rounded;
    }
    if (lower.contains('ctest') ||
        lower.contains('science') ||
        lower.contains('tech') ||
        lower.contains('lab')) {
      return Icons.biotech_rounded;
    }
    if (lower.contains('bank') ||
        lower.contains('ibps') ||
        lower.contains('sbi') ||
        lower.contains('rbi')) {
      return Icons.account_balance_wallet_rounded;
    }
    if (lower.contains('teach') ||
        lower.contains('tet') ||
        lower.contains('ctet') ||
        lower.contains('bed')) {
      return Icons.menu_book_rounded;
    }
    if (lower.contains('police') ||
        lower.contains('defence') ||
        lower.contains('army') ||
        lower.contains('navy') ||
        lower.contains('nda')) {
      return Icons.shield_rounded;
    }
    if (lower.contains('gate') ||
        lower.contains('jee') ||
        lower.contains('neet') ||
        lower.contains('engineer')) {
      return Icons.engineering_rounded;
    }
    return Icons.school_rounded;
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
                  Icon(
                    Icons.grid_view_rounded,
                    color: Color(0xFF2587F8),
                    size: 19,
                  ),
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
                  _selectedSubject = null;
                  _selectedCategory = null;
                  _selectedTopic = null;
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

        if (_subjects.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No individual subjects configured for this exam yet. Full Mock Tests are available below!',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (isDesktop)
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
                    onTap: () => _onSelectSubject(_subjects[i].title),
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
                    onTap: () => _onSelectSubject(_subjects[i].title),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  // --- Topic & Chapter Drill-down Chips ---
  Widget _buildTopicChipsSection() {
    final activeCat =
        _selectedCategory ??
        (_selectedSubject != null
            ? _allCategories.cast<CategoryModel?>().firstWhere(
                (c) =>
                    c != null &&
                    c.name.toLowerCase() == _selectedSubject!.toLowerCase(),
                orElse: () => null,
              )
            : null);

    if (activeCat == null || activeCat.topics.isEmpty) {
      return const SizedBox.shrink();
    }

    final topics = activeCat.topics;

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.bookmarks_rounded,
                  size: 16,
                  color: Color(0xFF7C3AED),
                ),
                const SizedBox(width: 8),
                Text(
                  '${activeCat.name} Chapters & Topics',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${topics.length} Chapters',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: _selectedTopic == null,
                      label: const Text('All Topics'),
                      onSelected: (_) => _onSelectTopic(null),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF7C3AED),
                      labelStyle: TextStyle(
                        color: _selectedTopic == null
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(
                        color: _selectedTopic == null
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                  for (final t in topics) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: _selectedTopic == t,
                        label: Text(t),
                        onSelected: (_) => _onSelectTopic(t),
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF7C3AED),
                        labelStyle: TextStyle(
                          color: _selectedTopic == t
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(
                          color: _selectedTopic == t
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981),
                        ),
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
                const SnackBar(
                  content: Text('Entering 1v1 Quiz Battle Arena...'),
                ),
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
        const SizedBox(height: 10),
        // Action 3: Latest Test Result (General Science)
        InkWell(
          onTap: () {
            if (widget.onViewLastResult != null) {
              widget.onViewLastResult!();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Test Result...')),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8FAF2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFB9F0DA), width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00B96B).withAlpha(35),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFF008C52),
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
                        'General Science (Score 42/50)',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF10194F),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '84% Accuracy • Rank #12 • View Result',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF008C52),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF008C52),
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
                  Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF2587F8),
                    size: 20,
                  ),
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

        if (_upcomingAndLiveTests.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 36,
                  color: Colors.blue.shade300,
                ),
                const SizedBox(height: 8),
                const Text(
                  'No Live or Upcoming Tests Right Now',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scheduled tournaments and live contests will appear here.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          for (final t in _upcomingAndLiveTests.take(2)) ...[
            Builder(
              builder: (context) {
                final isRegistered = _registeredContestIds.contains(t.id);
                final isLive = t.isLive;

                final String effectiveStatusLabel = isLive
                    ? 'LIVE NOW'
                    : (isRegistered ? 'REGISTERED' : 'UPCOMING');

                final String buttonLabel = isLive
                    ? (isRegistered ? 'START TEST NOW' : 'JOIN & WIN COINS')
                    : (isRegistered
                        ? '✓ REGISTERED'
                        : (t.entryFeeCoins > 0
                            ? 'PRE-REGISTER (${t.entryFeeCoins} COINS)'
                            : 'REGISTER FREE'));

                final Widget? buttonLeadingIcon = isLive
                    ? (isRegistered
                        ? const Icon(
                            Icons.play_arrow_rounded,
                            size: 18,
                            color: Colors.white,
                          )
                        : null)
                    : (isRegistered
                        ? const Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.how_to_reg_rounded,
                            size: 15,
                            color: Colors.white,
                          ));

                return Column(
                  children: [
                    LiveContestCard(
                      title: t.title,
                      tagline: t.isTournament
                          ? 'Prize Tournament Challenge!'
                          : (t.categoryId != null && t.categoryId!.isNotEmpty
                              ? t.categoryId!
                              : 'Test & Win Rewards!'),
                      icon: t.isTournament
                          ? Icons.emoji_events_rounded
                          : Icons.sensors_rounded,
                      questions: '${t.totalQuestions > 0 ? t.totalQuestions : 10} Qs',
                      duration:
                          '${t.durationMinutes > 0 ? t.durationMinutes : 10} Mins',
                      joined: '${t.totalParticipants} Joined',
                      prizePool: t.prizePoolCoins > 0 ? '${t.prizePoolCoins}' : '0',
                      entryFee: t.entryFeeCoins > 0 ? '${t.entryFeeCoins}' : 'FREE',
                      endsIn: isLive
                          ? _formatRemainingTime(
                              t.scheduledEndTime ??
                                  t.scheduledStartTime?.add(
                                    Duration(
                                      minutes: t.durationMinutes > 0
                                          ? t.durationMinutes
                                          : 60,
                                    ),
                                  ),
                            )
                          : null,
                      countdownTime: !isLive
                          ? _formatRemainingTime(t.scheduledStartTime)
                          : null,
                      countdownLabel: !isLive ? 'STARTS IN' : 'ENDS IN',
                      startsAt: _formatShortDate(t.scheduledStartTime),
                      isLive: isLive,
                      statusLabel: effectiveStatusLabel,
                      // Orange theme for upcoming tests, Red theme for live tests
                      accentColor: isLive ? null : const Color(0xFFEA580C),
                      accentLightColor: isLive ? null : const Color(0xFFFFF7ED),
                      accentBorderColor: isLive ? null : const Color(0xFFFFEDD5),
                      primaryButtonLabel: buttonLabel,
                      primaryButtonLeadingIcon: buttonLeadingIcon,
                      onJoin: () {
                        if (isLive) {
                          _handleJoinTest(t);
                        } else {
                          if (isRegistered) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'You are already registered for ${t.title}! Starts at ${_formatShortDate(t.scheduledStartTime)}.',
                                ),
                                backgroundColor: const Color(0xFFEA580C),
                              ),
                            );
                          } else {
                            _handlePreRegister(t);
                          }
                        }
                      },
                      onShare: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${t.title} link copied! Share with friends.'),
                            backgroundColor: isLive
                                ? const Color(0xFFE5252A)
                                : const Color(0xFFEA580C),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ],
      ],
    );
  }

  // --- Right Sidebar: 4. Top Performers ---
  Widget _buildTopPerformersSection() {
    return Container(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: const [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Top Performers',
                          style: TextStyle(
                            fontSize: 15,
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
                        const SnackBar(
                          content: Text('Viewing All-India Leaderboard...'),
                        ),
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
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
      ),
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
          decoration: BoxDecoration(shape: BoxShape.circle, color: rankBgColor),
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
                _selectedTopic != null
                    ? '${_selectedTopic!} Practice Tests (${_filteredTests.length})'
                    : (_selectedSubject != null
                          ? '${_selectedSubject!.replaceAll('\n', ' ')} Tests (${_filteredTests.length})'
                          : (_selectedExamId != null && _selectedExamId != 'all'
                                ? '${_selectedExamId!.toUpperCase()} Mocks & Tests (${_filteredTests.length})'
                                : 'Recommended Tests (${_filteredTests.length})')),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if ((_selectedExamId != null && _selectedExamId != 'all') ||
                _selectedSubject != null ||
                _selectedTopic != null ||
                _selectedTypeIndex > 0)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedExamId = null;
                    _selectedSubject = null;
                    _selectedCategory = null;
                    _selectedTopic = null;
                    _selectedTypeIndex = 0;
                    _applyCategories();
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
                  const Icon(
                    Icons.menu_book_outlined,
                    size: 40,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No tests found matching criteria',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Show All Tests',
                    size: AppButtonSize.small,
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    borderRadius: AppRadii.borderMd,
                    onPressed: () {
                      setState(() {
                        _selectedExamId = null;
                        _selectedSubject = null;
                        _selectedCategory = null;
                        _selectedTopic = null;
                        _selectedTypeIndex = 0;
                        _applyCategories();
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isFree = !test.isPremium && test.unlockPriceCoins <= 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFree ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Right Vector Illustration Background (NO image asset - pure CustomPaint vector)
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: isMobile ? 150 : 280,
            child: IgnorePointer(
              child: CustomPaint(
                painter: isFree
                    ? FreeTestCardDecorationPainter(isMobile: isMobile)
                    : CoinsTestCardDecorationPainter(isMobile: isMobile),
              ),
            ),
          ),

          // 2. Card Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 18,
              vertical: isMobile ? 14 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Badges (bounded by Expanded so Duration badge NEVER overflows on mobile)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Category pill
                          if ((test.categoryId ?? '').isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.menu_book_rounded,
                                    size: 13,
                                    color: Color(0xFF2587F8),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    test.categoryId!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2587F8),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Free or Coins pill
                          if (isFree)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.card_giftcard_rounded,
                                    size: 13,
                                    color: Color(0xFF00B67A),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '100% Free',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF00B67A),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF59E0B),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '₹',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${test.unlockPriceCoins} Coins',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Duration pill (right)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: Color(0xFF475569),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${test.durationMinutes} mins',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  test.title,
                  style: TextStyle(
                    fontSize: isMobile ? 17 : 19,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle metadata row (Atomic rows inside Wrap to never split icon from label)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 13.5,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${test.totalQuestions} Questions',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const Text('•', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_graph_rounded,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '-${test.negativeMarking} Negative',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const Text('•', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 13.5,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pattern: ${test.testMode.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Bottom feature text & "Attempt Test" button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            isFree ? Icons.bolt_rounded : Icons.lock_rounded,
                            size: isFree ? 18 : 16,
                            color: isFree
                                ? const Color(0xFF00B67A)
                                : const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              isFree
                                  ? (isMobile ? 'Free Mock Test' : 'Free Mock Test • Instant Result & Analysis')
                                  : (isMobile ? 'Requires ${test.unlockPriceCoins} Coins' : 'Requires ${test.unlockPriceCoins} Coins to Unlock'),
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 13,
                                fontWeight: FontWeight.w800,
                                color: isFree
                                    ? const Color(0xFF00B67A)
                                    : const Color(0xFFD97706),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Solid Green Button "▶ Attempt Test"
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B67A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 15 : 22,
                          vertical: isMobile ? 9 : 12,
                        ),
                      ),
                      onPressed: () {
                        if (!isFree) {
                          _showPurchaseDialog(test);
                        } else {
                          widget.onStartTest(test);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            size: isMobile ? 17 : 19,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Attempt Test',
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

class _ExamCategoryStyle {
  final Color bg;
  final Color bgEnd;
  final Color border;
  final Color accent;

  const _ExamCategoryStyle({
    required this.bg,
    required this.bgEnd,
    required this.border,
    required this.accent,
  });
}
