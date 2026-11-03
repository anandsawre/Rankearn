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

  const AiCreatorTab({
    super.key,
    this.onSavedToTests,
    this.onGoToQuestionBank,
  });

  @override
  State<AiCreatorTab> createState() => _AiCreatorTabState();
}

class _AiCreatorTabState extends State<AiCreatorTab> {
  List<AiGeneratedTestItem> _allTests = List.from(kDefaultAiGeneratedTests);
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
    _fetchSupabaseTests();
  }

  Future<void> _fetchSupabaseTests() async {
    try {
      final client = SupabaseConfig.clientSafe;
      if (client == null) return;

      dynamic response;
      try {
        response = await client
            .from('ai_generated_tests')
            .select()
            .order('created_at', ascending: false)
            .limit(50);
      } catch (_) {
        // If ai_generated_tests migration not yet executed in Supabase, try 'tests' table
        try {
          response = await client.from('tests').select().limit(50);
        } catch (_) {}
      }

      if (response != null && response is List && response.isNotEmpty && mounted) {
        final List<AiGeneratedTestItem> loaded = [];
        for (int i = 0; i < response.length; i++) {
          loaded.add(AiGeneratedTestItem.fromJson(response[i] as Map<String, dynamic>, i));
        }
        setState(() {
          _allTests = loaded;
        });
      }
    } catch (_) {}
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

  void _openGenerateDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => GenerateTestDialog(
        onTestGenerated: (newTest) {
          setState(() {
            _allTests.insert(0, newTest);
          });
        },
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
        onUseTemplate: (tpl) {
          _openGenerateDialog();
        },
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
        },
        onExport: () {
          Navigator.of(context).pop();
          _openExportDialog(item);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth >= 1050;

        return SingleChildScrollView(
          padding: AppSpacing.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Section: Hero Banner + Quick Actions
              if (isDesktop) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 7,
                      child: AiTestCreatorHeroCard(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 5,
                      child: AiTestCreatorQuickActions(
                        onGenerateTest: _openGenerateDialog,
                        onCustomPrompt: _openCustomPromptDialog,
                        onManageTemplates: _openManageTemplatesDialog,
                        onSavedTests: _openSavedTestsDialog,
                        onQuestionBank: () {
                          if (widget.onGoToQuestionBank != null) {
                            widget.onGoToQuestionBank!();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Navigating to Questions Bank module...')),
                            );
                          }
                        },
                        onExportTest: () => _openExportDialog(),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const AiTestCreatorHeroCard(),
                const SizedBox(height: 12),
                AiTestCreatorQuickActions(
                  onGenerateTest: _openGenerateDialog,
                  onCustomPrompt: _openCustomPromptDialog,
                  onManageTemplates: _openManageTemplatesDialog,
                  onSavedTests: _openSavedTestsDialog,
                  onQuestionBank: () {
                    if (widget.onGoToQuestionBank != null) {
                      widget.onGoToQuestionBank!();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigating to Questions Bank module...')),
                      );
                    }
                  },
                  onExportTest: () => _openExportDialog(),
                ),
              ],
              const SizedBox(height: 14),

              // 2. Metrics KPI Row (5 Cards)
              const AiTestCreatorMetricsRow(
                testsGenerated: 124,
                questionsCreated: 12580,
                savedTests: 68,
                timesUsed: 3245,
                avgCreationTime: '34 sec',
              ),
              const SizedBox(height: 14),

              // 3. Main Body Section: Table (Left) + Analytics (Right)
              if (isDesktop) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Table
                    Expanded(
                      child: AiTestCreatorTableCard(
                        items: filtered,
                        totalCount: 124,
                        currentPage: _currentPage,
                        rowsPerPage: _rowsPerPage,
                        searchQuery: _searchQuery,
                        selectedSubject: _selectedSubject,
                        selectedDifficulty: _selectedDifficulty,
                        selectedStatus: _selectedStatus,
                        dateRange: _selectedDateRange,
                        onSearchChanged: (q) => setState(() => _searchQuery = q),
                        onSubjectChanged: (s) => setState(() => _selectedSubject = s),
                        onDifficultyChanged: (d) => setState(() => _selectedDifficulty = d),
                        onStatusChanged: (st) => setState(() => _selectedStatus = st),
                        onDateRangeChanged: (r) => setState(() => _selectedDateRange = r),
                        onPageChanged: (p) => setState(() => _currentPage = p),
                        onRowsPerPageChanged: (r) => setState(() => _rowsPerPage = r),
                        onViewTest: (item) => _openPreviewDialog(item),
                        onAnalyticsTest: (item) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Analytics for "${item.title}": 100% completion rate')),
                          );
                        },
                        onEditTest: (item) => _openPreviewDialog(item),
                        onDeleteTest: (item) {
                          setState(() {
                            _allTests.removeWhere((t) => t.id == item.id);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Test "${item.title}" deleted')),
                          );
                        },
                        onFiltersTap: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedSubject = 'All Subjects';
                            _selectedDifficulty = 'All Difficulty';
                            _selectedStatus = 'All Status';
                            _selectedDateRange = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Right Column: Analytics (Subject Donut, Difficulty Donut, Recent Activity)
                    SizedBox(
                      width: 295,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AiSubjectDonutCard(
                            totalCount: 124,
                            onViewAll: () {},
                          ),
                          const SizedBox(height: 12),
                          AiDifficultyDonutCard(
                            totalCount: 124,
                            onViewAll: () {},
                          ),
                          const SizedBox(height: 12),
                          AiTestRecentActivityCard(
                            onViewAll: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Tablet/Mobile: Stacked layout
                AiTestCreatorTableCard(
                  items: filtered,
                  totalCount: 124,
                  currentPage: _currentPage,
                  rowsPerPage: _rowsPerPage,
                  searchQuery: _searchQuery,
                  selectedSubject: _selectedSubject,
                  selectedDifficulty: _selectedDifficulty,
                  selectedStatus: _selectedStatus,
                  dateRange: _selectedDateRange,
                  onSearchChanged: (q) => setState(() => _searchQuery = q),
                  onSubjectChanged: (s) => setState(() => _selectedSubject = s),
                  onDifficultyChanged: (d) => setState(() => _selectedDifficulty = d),
                  onStatusChanged: (st) => setState(() => _selectedStatus = st),
                  onDateRangeChanged: (r) => setState(() => _selectedDateRange = r),
                  onPageChanged: (p) => setState(() => _currentPage = p),
                  onRowsPerPageChanged: (r) => setState(() => _rowsPerPage = r),
                  onViewTest: (item) => _openPreviewDialog(item),
                  onAnalyticsTest: (item) {},
                  onEditTest: (item) => _openPreviewDialog(item),
                  onDeleteTest: (item) {
                    setState(() => _allTests.removeWhere((t) => t.id == item.id));
                  },
                ),
                const SizedBox(height: 14),
                AiSubjectDonutCard(
                  totalCount: 124,
                  onViewAll: () {},
                ),
                const SizedBox(height: 12),
                AiDifficultyDonutCard(
                  totalCount: 124,
                  onViewAll: () {},
                ),
                const SizedBox(height: 12),
                AiTestRecentActivityCard(
                  onViewAll: () {},
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
