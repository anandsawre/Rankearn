import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'models/ai_test_item.dart';
import 'widgets/ai_test_creator_hero_card.dart';
import 'widgets/ai_test_creator_quick_actions.dart';
import 'widgets/ai_test_creator_metrics_row.dart';
import 'widgets/ai_test_creator_table_card.dart';
import 'widgets/ai_subject_donut_card.dart';
import 'widgets/ai_difficulty_donut_card.dart';
import 'widgets/ai_test_recent_activity_card.dart';
import 'dialogs/generate_test_dialog.dart';
import 'dialogs/custom_prompt_dialog.dart';
import 'dialogs/manage_templates_dialog.dart';
import 'dialogs/saved_tests_dialog.dart';
import 'dialogs/test_preview_dialog.dart';
import 'dialogs/export_test_dialog.dart';

class AiCreatorTab extends StatefulWidget {
  final VoidCallback? onSavedToTests;
  final VoidCallback? onGoToQuestionBank;
  final List<AiGeneratedTestItem>? initialTests;

  const AiCreatorTab({
    super.key,
    this.onSavedToTests,
    this.onGoToQuestionBank,
    this.initialTests,
  });

  @override
  State<AiCreatorTab> createState() => _AiCreatorTabState();
}

class _AiCreatorTabState extends State<AiCreatorTab> {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  late List<AiGeneratedTestItem> _allTests;
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedSubject = 'All Subjects';
  String _selectedDifficulty = 'All Difficulty';
  String _selectedStatus = 'All Status';
  DateTimeRange? _selectedDateRange;
  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    if (widget.initialTests != null) {
      _allTests = List.from(widget.initialTests!);
      _isLoading = false;
    } else {
      _allTests = [];
      _fetchSupabaseTests();
    }
  }

  Future<void> _fetchSupabaseTests() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Database connection is not initialized.';
        });
      }
      return;
    }

    try {
      final response = await client
          .from('ai_generated_tests')
          .select()
          .order('created_at', ascending: false)
          .limit(100);

      final rows = List<Map<String, dynamic>>.from(response as List);
      final loaded = rows
          .asMap()
          .entries
          .map((e) => AiGeneratedTestItem.fromJson(e.value, e.key))
          .toList();

      if (!mounted) return;
      setState(() {
        _allTests = loaded;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load AI generated tests from Supabase: $e';
      });
    }
  }

  List<AiGeneratedTestItem> get _filteredItems {
    return _allTests.where((item) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = item.title.toLowerCase().contains(q) ||
            item.subtitle.toLowerCase().contains(q) ||
            item.subject.label.toLowerCase().contains(q);
        if (!match) return false;
      }
      if (_selectedSubject != 'All Subjects' &&
          item.subject.label.toLowerCase() != _selectedSubject.toLowerCase()) {
        return false;
      }
      if (_selectedDifficulty != 'All Difficulty' &&
          item.difficulty.label.toLowerCase() != _selectedDifficulty.toLowerCase()) {
        return false;
      }
      if (_selectedStatus != 'All Status' &&
          item.status.label.toLowerCase() != _selectedStatus.toLowerCase()) {
        return false;
      }
      if (_selectedDateRange != null) {
        if (item.createdOn.isBefore(_selectedDateRange!.start) ||
            item.createdOn.isAfter(_selectedDateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  ({String growth, bool isPositive, List<double> sparkline}) _computeGrowthAndSparkline(
    List<DateTime> dates, {
    int totalCount = 0,
  }) {
    if (dates.isEmpty) {
      return (growth: '', isPositive: true, sparkline: const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]);
    }
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = todayStart.subtract(const Duration(days: 6));
    final fourteenDaysAgo = todayStart.subtract(const Duration(days: 13));

    int cur = 0;
    int prev = 0;
    final buckets = List<double>.filled(7, 0.0);

    for (final dt in dates) {
      if (!dt.isBefore(sevenDaysAgo)) {
        cur++;
      } else if (!dt.isBefore(fourteenDaysAgo)) {
        prev++;
      }
      final dayOnly = DateTime(dt.year, dt.month, dt.day);
      final diff = todayStart.difference(dayOnly).inDays;
      if (diff >= 0 && diff < 7) {
        buckets[6 - diff] += 1;
      }
    }

    String growth = '';
    bool isPos = true;
    if (prev > 0) {
      final pct = (((cur - prev) / prev) * 100).round();
      isPos = pct >= 0;
      growth = '${pct >= 0 ? '+' : ''}$pct%';
    } else if (cur > 0 && totalCount > 0) {
      final pct = ((cur / totalCount) * 100).round();
      growth = '+$pct%';
    }
    return (growth: growth, isPositive: isPos, sparkline: buckets);
  }

  List<DonutSlice> get _subjectSlices {
    if (_allTests.isEmpty) return const [];
    final counts = <AiTestSubject, int>{};
    for (final t in _allTests) {
      counts[t.subject] = (counts[t.subject] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) {
      return DonutSlice(
        label: e.key.label,
        percentage: (e.value / _allTests.length) * 100,
        color: e.key.color,
        count: e.value,
      );
    }).toList();
  }

  List<DonutSlice> get _difficultySlices {
    if (_allTests.isEmpty) return const [];
    final counts = <AiTestDifficulty, int>{};
    for (final t in _allTests) {
      counts[t.difficulty] = (counts[t.difficulty] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) {
      return DonutSlice(
        label: e.key.label,
        percentage: (e.value / _allTests.length) * 100,
        color: e.key.color,
        count: e.value,
      );
    }).toList();
  }

  List<AiTestActivityItem> get _recentActivities {
    if (_allTests.isEmpty) return const [];
    final sorted = List<AiGeneratedTestItem>.from(_allTests)
      ..sort((a, b) => b.createdOn.compareTo(a.createdOn));
    return sorted.take(5).map((t) {
      final isPub = t.status == AiTestStatus.published;
      return AiTestActivityItem(
        title: '${isPub ? "Published" : t.status.label}: ${t.title}',
        time: _formatTimeAgo(t.createdOn),
        icon: isPub ? Icons.check_circle_rounded : Icons.auto_awesome_rounded,
        iconColor: isPub ? const Color(0xFF10B981) : t.subject.color,
        iconBgColor: isPub ? const Color(0xFFECFDF5) : t.subject.backgroundColor,
      );
    }).toList();
  }

  static String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${_months[dt.month - 1]} ${dt.day}';
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : const Color(0xFF10B981),
      ),
    );
  }

  void _openGenerateDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => GenerateTestDialog(
        onTestGenerated: (_) => _fetchSupabaseTests(),
      ),
    );
  }

  void _openCustomPromptDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => CustomPromptDialog(
        onOpenGenerate: _openGenerateDialog,
      ),
    );
  }

  void _openManageTemplatesDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ManageTemplatesDialog(
        onUseTemplate: (_) => _openGenerateDialog(),
      ),
    );
  }

  void _openSavedTestsDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => SavedTestsDialog(
        tests: _allTests,
        onResumeTest: (t) => _openPreviewDialog(t),
      ),
    );
  }

  void _openExportDialog([AiGeneratedTestItem? item]) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ExportTestDialog(
        initialTest: item,
        allTests: _allTests,
      ),
    );
  }

  void _openPreviewDialog(AiGeneratedTestItem item) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => TestPreviewDialog(
        test: item,
        onPublish: (publishedTest) {
          setState(() {
            final idx = _allTests.indexWhere((t) => t.id == publishedTest.id);
            if (idx != -1) {
              _allTests[idx] = publishedTest.copyWith(status: AiTestStatus.published);
            }
          });
          widget.onSavedToTests?.call();
        },
        onExport: () {
          Navigator.of(context).pop();
          _openExportDialog(item);
        },
      ),
    );
  }

  Future<void> _deleteTest(AiGeneratedTestItem item) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      _showSnack('Database not connected. Cannot delete test.', isError: true);
      return;
    }

    try {
      await client.from('ai_generated_tests').delete().eq('id', item.id);
      if (!mounted) return;
      setState(() {
        _allTests.removeWhere((t) => t.id == item.id);
      });
      _showSnack('Deleted "${item.title}" from Supabase.');
    } catch (e) {
      _showSnack('Failed to delete AI test: $e', isError: true);
    }
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: const Color(0xFFFDA4AF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9F1239),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _fetchSupabaseTests,
            icon: const Icon(Icons.refresh_rounded, size: 15),
            label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final totalQuestionsCreated =
        _allTests.fold<int>(0, (sum, t) => sum + t.questionCount);
    final savedCount = _allTests
        .where((t) => t.status == AiTestStatus.published || t.status == AiTestStatus.draft)
        .length;
    final totalTimesUsed = _allTests.fold<int>(0, (sum, t) => sum + t.timesUsed);
    final recordedTimes = _allTests
        .map((t) => t.generationTimeSeconds)
        .whereType<int>()
        .toList();
    final avgTimeStr = recordedTimes.isEmpty
        ? '—'
        : '${(recordedTimes.reduce((a, b) => a + b) / recordedTimes.length).round()} sec';

    final testsTrend = _computeGrowthAndSparkline(
      _allTests.map((t) => t.createdOn).toList(),
      totalCount: _allTests.length,
    );

    final quickActions = AiTestCreatorQuickActions(
      onGenerateTest: _openGenerateDialog,
      onCustomPrompt: _openCustomPromptDialog,
      onManageTemplates: _openManageTemplatesDialog,
      onSavedTests: _openSavedTestsDialog,
      onQuestionBank: () {
        if (widget.onGoToQuestionBank != null) {
          widget.onGoToQuestionBank!();
        } else {
          _showSnack('Switch to Questions tab to view the question bank.');
        }
      },
      onExportTest: () => _openExportDialog(),
    );

    final tableCard = AiTestCreatorTableCard(
      items: filtered,
      totalCount: filtered.length,
      currentPage: _currentPage,
      rowsPerPage: _rowsPerPage,
      searchQuery: _searchQuery,
      selectedSubject: _selectedSubject,
      selectedDifficulty: _selectedDifficulty,
      selectedStatus: _selectedStatus,
      dateRange: _selectedDateRange,
      isLoading: _isLoading,
      onSearchChanged: (q) => setState(() => _searchQuery = q),
      onSubjectChanged: (s) => setState(() => _selectedSubject = s),
      onDifficultyChanged: (d) => setState(() => _selectedDifficulty = d),
      onStatusChanged: (st) => setState(() => _selectedStatus = st),
      onDateRangeChanged: (r) => setState(() => _selectedDateRange = r),
      onPageChanged: (p) => setState(() => _currentPage = p),
      onRowsPerPageChanged: (r) => setState(() => _rowsPerPage = r),
      onViewTest: _openPreviewDialog,
      onAnalyticsTest: (item) {
        _openPreviewDialog(item);
      },
      onEditTest: _openPreviewDialog,
      onDeleteTest: _deleteTest,
      onFiltersTap: () {
        setState(() {
          _searchQuery = '';
          _selectedSubject = 'All Subjects';
          _selectedDifficulty = 'All Difficulty';
          _selectedStatus = 'All Status';
          _selectedDateRange = null;
        });
      },
    );

    final subjectDonut = AiSubjectDonutCard(
      totalCount: _allTests.length,
      slices: _subjectSlices,
      isLoading: _isLoading,
      onViewAll: () => setState(() => _selectedSubject = 'All Subjects'),
    );

    final difficultyDonut = AiDifficultyDonutCard(
      totalCount: _allTests.length,
      slices: _difficultySlices,
      isLoading: _isLoading,
      onViewAll: () => setState(() => _selectedDifficulty = 'All Difficulty'),
    );

    final activityCard = AiTestRecentActivityCard(
      activities: _recentActivities,
      isLoading: _isLoading,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1050;

        return SingleChildScrollView(
          padding: AppSpacing.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) _buildErrorBanner(),
              if (isDesktop) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 7, child: AiTestCreatorHeroCard()),
                    const SizedBox(width: 14),
                    Expanded(flex: 5, child: quickActions),
                  ],
                ),
              ] else ...[
                const AiTestCreatorHeroCard(),
                const SizedBox(height: 12),
                quickActions,
              ],
              const SizedBox(height: 14),
              AiTestCreatorMetricsRow(
                testsGenerated: _allTests.length,
                questionsCreated: totalQuestionsCreated,
                savedTests: savedCount,
                timesUsed: totalTimesUsed,
                avgCreationTime: avgTimeStr,
                isLoading: _isLoading,
                testsGrowth: testsTrend.growth,
                testsPositive: testsTrend.isPositive,
                testsSparkline: testsTrend.sparkline,
              ),
              const SizedBox(height: 14),
              if (isDesktop) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: tableCard),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 295,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          subjectDonut,
                          const SizedBox(height: 12),
                          difficultyDonut,
                          const SizedBox(height: 12),
                          activityCard,
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                tableCard,
                const SizedBox(height: 14),
                subjectDonut,
                const SizedBox(height: 12),
                difficultyDonut,
                const SizedBox(height: 12),
                activityCard,
              ],
            ],
          ),
        );
      },
    );
  }
}
