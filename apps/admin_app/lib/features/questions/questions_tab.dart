import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'models/question_item.dart';
import 'widgets/questions_hero_card.dart';
import 'widgets/questions_quick_actions.dart';
import 'widgets/questions_metrics_row.dart';
import 'widgets/questions_table_card.dart';
import 'widgets/question_type_donut_chart.dart';
import 'widgets/difficulty_wise_bar_chart.dart';
import 'widgets/questions_recent_activity_card.dart';
import 'dialogs/create_question_dialog.dart';
import 'dialogs/view_question_dialog.dart';
import 'dialogs/import_questions_dialog.dart';
import 'dialogs/ai_generate_questions_dialog.dart';
import 'dialogs/manage_question_sets_dialog.dart';
import 'dialogs/bulk_actions_dialog.dart';

/// Questions Bank Management Screen
/// Fully backed by live Supabase `questions`, `tests`, and `categories` tables.
class QuestionsTab extends StatefulWidget {
  final List<QuestionItem>? initialItems;

  const QuestionsTab({super.key, this.initialItems});

  @override
  State<QuestionsTab> createState() => _QuestionsTabState();
}

class _QuestionsTabState extends State<QuestionsTab> {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  late List<QuestionItem> _allItems;
  List<({String id, String title, String status, DateTime createdAt})> _dbTests = [];
  List<String> _dbCategories = [];
  final Set<String> _selectedIds = {};

  bool _isLoading = true;
  String? _errorMessage;

  // Filters
  String _searchQuery = '';
  String _selectedTestSeries = 'All Test Series';
  String _selectedSubject = 'All Subjects';
  String _selectedType = 'All Types';
  String _selectedDifficulty = 'All Difficulty';

  // Pagination
  int _currentPage = 1;
  static const int _rowsPerPage = 7;

  @override
  void initState() {
    super.initState();
    if (widget.initialItems != null) {
      _allItems = List.from(widget.initialItems!);
      _isLoading = false;
    } else {
      _allItems = [];
      _loadFromSupabase();
    }
  }

  Future<void> _loadFromSupabase() async {
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
      final results = await Future.wait([
        client.from('questions').select().order('created_at', ascending: false),
        client
            .from('tests')
            .select('id, title, status, created_at')
            .order('created_at', ascending: false),
        client
            .from('categories')
            .select('id, name')
            .order('display_order', ascending: true),
      ]);

      final qRows = List<Map<String, dynamic>>.from(results[0] as List);
      final testRows = List<Map<String, dynamic>>.from(results[1] as List);
      final catRows = List<Map<String, dynamic>>.from(results[2] as List);

      final testLookup = <String, ({String title, QuestionStatus status})>{};
      final parsedTests = <({String id, String title, String status, DateTime createdAt})>[];
      for (final t in testRows) {
        final id = t['id']?.toString() ?? '';
        final title = t['title']?.toString().trim() ?? '';
        final statusStr = t['status']?.toString().trim() ?? 'published';
        final dt = DateTime.tryParse(t['created_at']?.toString() ?? '')?.toLocal() ??
            DateTime.now();
        if (id.isNotEmpty) {
          testLookup[id] = (
            title: title.isNotEmpty ? title : 'Untitled Test',
            status: QuestionStatus.fromString(statusStr),
          );
          if (title.isNotEmpty) {
            parsedTests.add((id: id, title: title, status: statusStr, createdAt: dt));
          }
        }
      }

      final catNames = catRows
          .map((c) => c['name']?.toString().trim() ?? '')
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList();

      final loadedQuestions = qRows.asMap().entries.map((entry) {
        final row = entry.value;
        final tid = row['test_id']?.toString().trim() ?? '';
        final parentTest = tid.isNotEmpty ? testLookup[tid] : null;
        return QuestionItem.fromMap(
          row,
          entry.key + 1,
          parentTest?.title,
          parentTest?.status,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _allItems = loadedQuestions;
        _dbTests = parsedTests;
        _dbCategories = catNames;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load questions from Supabase: $e';
      });
    }
  }

  List<QuestionItem> get _filteredItems {
    return _allItems.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.questionText.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.subject.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.testSeriesTitle.toLowerCase().contains(_searchQuery.toLowerCase());

      final cleanTest = item.testSeriesTitle.replaceAll('\n', ' ').trim();
      final matchesTestSeries = _selectedTestSeries == 'All Test Series' ||
          cleanTest.toLowerCase() == _selectedTestSeries.toLowerCase();

      final matchesSubject = _selectedSubject == 'All Subjects' ||
          item.subject.toLowerCase() == _selectedSubject.toLowerCase();

      final matchesType = _selectedType == 'All Types' ||
          item.questionType.toLowerCase() == _selectedType.toLowerCase();

      final matchesDifficulty = _selectedDifficulty == 'All Difficulty' ||
          item.difficulty.label.toLowerCase() == _selectedDifficulty.toLowerCase();

      return matchesSearch &&
          matchesTestSeries &&
          matchesSubject &&
          matchesType &&
          matchesDifficulty;
    }).toList();
  }

  int get _totalPages {
    final filteredLen = _filteredItems.length;
    return (filteredLen / _rowsPerPage).ceil().clamp(1, 999);
  }

  List<QuestionItem> get _paginatedItems {
    final filtered = _filteredItems;
    final startIdx = (_currentPage - 1) * _rowsPerPage;
    if (startIdx >= filtered.length) return [];
    final endIdx = (startIdx + _rowsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIdx, endIdx);
  }

  // Real computed metrics
  int get _totalQuestions => _allItems.length;
  int get _activeQuestions =>
      _allItems.where((i) => i.status == QuestionStatus.published).length;
  int get _draftQuestions =>
      _allItems.where((i) => i.status == QuestionStatus.draft).length;
  int get _archivedQuestions =>
      _allItems.where((i) => i.status == QuestionStatus.archived).length;
  int get _questionSets => _dbTests.isNotEmpty
      ? _dbTests.length
      : _allItems
          .map((i) => i.testId ?? i.testSeriesTitle)
          .where((s) => s.isNotEmpty && s != 'General Bank')
          .toSet()
          .length;

  int get _easyCount =>
      _allItems.where((i) => i.difficulty == QuestionDifficulty.easy).length;
  int get _mediumCount =>
      _allItems.where((i) => i.difficulty == QuestionDifficulty.medium).length;
  int get _hardCount =>
      _allItems.where((i) => i.difficulty == QuestionDifficulty.hard).length;
  int get _expertCount =>
      _allItems.where((i) => i.difficulty == QuestionDifficulty.expert).length;

  List<String> get _availableTestSeries {
    return <String>{
      ..._dbTests.map((t) => t.title),
      ..._allItems
          .map((i) => i.testSeriesTitle.replaceAll('\n', ' ').trim())
          .where((t) => t.isNotEmpty),
    }.toList()
      ..sort();
  }

  List<String> get _availableSubjects {
    return <String>{
      ..._dbCategories,
      ..._allItems.map((i) => i.subject.trim()).where((s) => s.isNotEmpty),
    }.toList()
      ..sort();
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
    if (_allItems.isEmpty) return const [];
    final counts = <String, int>{};
    for (final item in _allItems) {
      final sub = item.subject.trim().isEmpty ? 'Uncategorized' : item.subject.trim();
      counts[sub] = (counts[sub] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    const palette = [
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFFF59E0B),
      Color(0xFF06B6D4),
      Color(0xFFEC4899),
      Color(0xFF10B981),
      Color(0xFF94A3B8),
    ];

    return sorted.asMap().entries.map((entry) {
      final sub = entry.value.key;
      final cnt = entry.value.value;
      return DonutSlice(
        label: sub,
        percentage: (cnt / _allItems.length) * 100,
        color: palette[entry.key % palette.length],
        count: cnt,
      );
    }).toList();
  }

  List<QuestionActivityItem> get _recentActivities {
    if (_allItems.isEmpty) return const [];
    final sorted = List<QuestionItem>.from(_allItems)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sorted.take(5).map((item) {
      return QuestionActivityItem(
        icon: item.subjectIcon,
        iconBg: item.iconContainerBg,
        text: '${item.subject}: ${item.questionText.replaceAll('\n', ' ')}',
        timeAgo: _formatTimeAgo(item.createdAt),
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

  void _showSnack(String message, {bool isError = false, Color? bg}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : (bg ?? const Color(0xFF10B981)),
      ),
    );
  }

  // Actions
  void _openCreateDialog([QuestionItem? itemToEdit]) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => CreateQuestionDialog(
        initialItem: itemToEdit,
        onBulkSave: (_) => _loadFromSupabase(),
        onSave: (savedItem) async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot save question.', isError: true);
            return;
          }

          try {
            await client.from('questions').upsert(savedItem.toMap());
            if (!mounted) return;
            setState(() {
              final idx = _allItems.indexWhere((i) => i.id == savedItem.id);
              if (idx >= 0) {
                _allItems[idx] = savedItem;
              } else {
                _allItems.insert(0, savedItem);
              }
            });
            _showSnack(
              itemToEdit != null
                  ? 'Updated question #${savedItem.questionNumber}'
                  : 'Added new question #${savedItem.questionNumber}',
            );
          } catch (e) {
            _showSnack('Failed to save question to Supabase: $e', isError: true);
          }
        },
      ),
    );
  }

  void _openViewDialog(QuestionItem item) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ViewQuestionDialog(item: item),
    );
  }

  void _openImportDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ImportQuestionsDialog(
        onImport: (importedItems) async {
          if (importedItems.isEmpty) return;
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot import questions.', isError: true);
            return;
          }

          try {
            await client
                .from('questions')
                .upsert(importedItems.map((i) => i.toMap()).toList());
            if (!mounted) return;
            await _loadFromSupabase();
            _showSnack(
              'Successfully imported ${importedItems.length} questions to Supabase.',
              bg: const Color(0xFF0284C7),
            );
          } catch (e) {
            _showSnack('Failed to import questions: $e', isError: true);
          }
        },
      ),
    );
  }

  void _openAiGenerateDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => AiGenerateQuestionsDialog(
        onSaveGenerated: (generatedItems) async {
          if (generatedItems.isEmpty) return;
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot save generated questions.', isError: true);
            return;
          }

          try {
            await client
                .from('questions')
                .upsert(generatedItems.map((i) => i.toMap()).toList());
            if (!mounted) return;
            await _loadFromSupabase();
            _showSnack('Saved ${generatedItems.length} AI generated questions to Supabase.');
          } catch (e) {
            _showSnack('Failed to save generated questions: $e', isError: true);
          }
        },
      ),
    );
  }

  void _openManageQuestionSetsDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ManageQuestionSetsDialog(
        onSetsUpdated: _loadFromSupabase,
      ),
    );
  }

  Future<void> _duplicateQuestion(QuestionItem item) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      _showSnack('Database not connected. Cannot duplicate question.', isError: true);
      return;
    }

    final duplicated = item.copyWith(
      id: 'q-${DateTime.now().millisecondsSinceEpoch}',
      questionNumber: _allItems.length + 1,
      questionText: '${item.questionText} (Copy)',
      usageCount: 0,
      createdAt: DateTime.now(),
    );

    try {
      await client.from('questions').upsert(duplicated.toMap());
      if (!mounted) return;
      setState(() {
        _allItems.insert(0, duplicated);
      });
      _showSnack('Duplicated question #${item.questionNumber}', bg: const Color(0xFFF59E0B));
    } catch (e) {
      _showSnack('Failed to duplicate question: $e', isError: true);
    }
  }

  void _deleteQuestion(QuestionItem item) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => AppModalDialog(
        title: 'Delete Question',
        subtitle: 'Permanent deletion warning',
        iconData: Icons.delete_outline_rounded,
        gradientColors: const [Color(0xFFDC2626), Color(0xFFEF4444)],
        maxWidth: 440,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final client = SupabaseConfig.clientSafe;
              if (client == null) {
                _showSnack('Database not connected. Cannot delete question.', isError: true);
                return;
              }
              try {
                await client.from('questions').delete().eq('id', item.id);
                if (!mounted) return;
                setState(() {
                  _allItems.removeWhere((i) => i.id == item.id);
                  _selectedIds.remove(item.id);
                });
                _showSnack('Deleted question #${item.questionNumber}');
              } catch (e) {
                _showSnack('Failed to delete question: $e', isError: true);
              }
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Are you sure you want to delete question "${item.questionText}"? This action cannot be undone.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
          ),
        ),
      ),
    );
  }

  void _openBulkActionsDialog() {
    if (_selectedIds.isEmpty) {
      _showSnack(
        'Please select one or more questions from the table first.',
        bg: const Color(0xFFF59E0B),
      );
      return;
    }

    final testOptions = _dbTests.map((t) => (id: t.id, title: t.title)).toList();

    AppModalDialog.show(
      context: context,
      builder: (ctx) => BulkActionsDialog(
        selectedCount: _selectedIds.length,
        availableTests: testOptions,
        onExecute: (op, targetTestId) async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot apply bulk operation.', isError: true);
            return;
          }

          final ids = _selectedIds.toList();
          try {
            switch (op) {
              case BulkOperation.setEasy:
                await client
                    .from('questions')
                    .update({'difficulty_level': 'easy'})
                    .inFilter('id', ids);
                break;
              case BulkOperation.setMedium:
                await client
                    .from('questions')
                    .update({'difficulty_level': 'medium'})
                    .inFilter('id', ids);
                break;
              case BulkOperation.setHard:
                await client
                    .from('questions')
                    .update({'difficulty_level': 'hard'})
                    .inFilter('id', ids);
                break;
              case BulkOperation.assignTest:
                if (targetTestId != null && targetTestId.isNotEmpty) {
                  await client
                      .from('questions')
                      .update({'test_id': targetTestId})
                      .inFilter('id', ids);
                }
                break;
              case BulkOperation.delete:
                await client.from('questions').delete().inFilter('id', ids);
                _selectedIds.clear();
                break;
            }
            if (!mounted) return;
            await _loadFromSupabase();
            _showSnack('Executed ${op.label} on ${ids.length} question(s).');
          } catch (e) {
            _showSnack('Bulk operation failed: $e', isError: true);
          }
        },
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedTestSeries = 'All Test Series';
      _selectedSubject = 'All Subjects';
      _selectedType = 'All Types';
      _selectedDifficulty = 'All Difficulty';
      _currentPage = 1;
    });
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedTestSeries != 'All Test Series' ||
      _selectedSubject != 'All Subjects' ||
      _selectedType != 'All Types' ||
      _selectedDifficulty != 'All Difficulty';

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
            onPressed: _loadFromSupabase,
            icon: const Icon(Icons.refresh_rounded, size: 15),
            label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1024;

    final totalTrend = _computeGrowthAndSparkline(
      _allItems.map((i) => i.createdAt).toList(),
      totalCount: _totalQuestions,
    );
    final activeTrend = _computeGrowthAndSparkline(
      _allItems.where((i) => i.status == QuestionStatus.published).map((i) => i.createdAt).toList(),
      totalCount: _activeQuestions,
    );
    final draftTrend = _computeGrowthAndSparkline(
      _allItems.where((i) => i.status == QuestionStatus.draft).map((i) => i.createdAt).toList(),
      totalCount: _draftQuestions,
    );
    final archivedTrend = _computeGrowthAndSparkline(
      _allItems.where((i) => i.status == QuestionStatus.archived).map((i) => i.createdAt).toList(),
      totalCount: _archivedQuestions,
    );
    final setsTrend = _computeGrowthAndSparkline(
      _dbTests.map((t) => t.createdAt).toList(),
      totalCount: _questionSets,
    );

    final quickActions = QuestionsQuickActions(
      onAddQuestion: () => _openCreateDialog(),
      onImportQuestions: _openImportDialog,
      onAiGenerateQuestions: _openAiGenerateDialog,
      onManageQuestionSets: _openManageQuestionSetsDialog,
      onDuplicateQuestions: () {
        if (_selectedIds.isEmpty) {
          _showSnack('Select a question in the table to duplicate.', bg: const Color(0xFFF59E0B));
        } else {
          final target = _allItems.firstWhere(
            (i) => _selectedIds.contains(i.id),
            orElse: () => _allItems.first,
          );
          _duplicateQuestion(target);
        }
      },
      onBulkActions: _openBulkActionsDialog,
    );

    final tableCard = QuestionsTableCard(
      items: _paginatedItems,
      totalCount: _filteredItems.length,
      selectedTestSeries: _selectedTestSeries,
      selectedSubject: _selectedSubject,
      selectedType: _selectedType,
      selectedDifficulty: _selectedDifficulty,
      availableTestSeries: _availableTestSeries,
      availableSubjects: _availableSubjects,
      searchQuery: _searchQuery,
      currentPage: _currentPage,
      totalPages: _totalPages,
      isLoading: _isLoading,
      onOpenFilters: _hasActiveFilters ? _resetFilters : null,
      onTestSeriesChanged: (val) {
        setState(() {
          _selectedTestSeries = val;
          _currentPage = 1;
        });
      },
      onSubjectChanged: (val) {
        setState(() {
          _selectedSubject = val;
          _currentPage = 1;
        });
      },
      onTypeChanged: (val) {
        setState(() {
          _selectedType = val;
          _currentPage = 1;
        });
      },
      onDifficultyChanged: (val) {
        setState(() {
          _selectedDifficulty = val;
          _currentPage = 1;
        });
      },
      onSearchChanged: (val) {
        setState(() {
          _searchQuery = val;
          _currentPage = 1;
        });
      },
      onPageChanged: (page) {
        setState(() => _currentPage = page);
      },
      onView: _openViewDialog,
      onEdit: (item) => _openCreateDialog(item),
      onDuplicate: _duplicateQuestion,
      onDelete: _deleteQuestion,
      onToggleStatus: (_) {},
      onSelectionChanged: (ids) {
        setState(() {
          _selectedIds.clear();
          _selectedIds.addAll(ids);
        });
      },
    );

    final donutCard = QuestionTypeDonutChartCard(
      totalCount: _totalQuestions,
      slices: _subjectSlices,
      isLoading: _isLoading,
    );

    final difficultyCard = DifficultyWiseBarChartCard(
      easyCount: _easyCount,
      mediumCount: _mediumCount,
      hardCount: _hardCount,
      expertCount: _expertCount,
      isLoading: _isLoading,
    );

    final activityCard = QuestionsRecentActivityCard(
      activities: _recentActivities,
      isLoading: _isLoading,
    );

    return Container(
      color: const Color(0xFFF4F7FF),
      child: SingleChildScrollView(
        padding: AppSpacing.pagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) _buildErrorBanner(),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 63, child: QuestionsHeroCard()),
                  const SizedBox(width: 14),
                  Expanded(flex: 37, child: quickActions),
                ],
              )
            else
              Column(
                children: [
                  const QuestionsHeroCard(),
                  const SizedBox(height: 14),
                  quickActions,
                ],
              ),
            const SizedBox(height: 16),
            QuestionsMetricsRow(
              totalQuestions: _totalQuestions,
              activeQuestions: _activeQuestions,
              draftQuestions: _draftQuestions,
              archivedQuestions: _archivedQuestions,
              questionSets: _questionSets,
              isLoading: _isLoading,
              totalGrowth: totalTrend.growth,
              totalPositive: totalTrend.isPositive,
              totalSparkline: totalTrend.sparkline,
              activeGrowth: activeTrend.growth,
              activePositive: activeTrend.isPositive,
              activeSparkline: activeTrend.sparkline,
              draftGrowth: draftTrend.growth,
              draftPositive: draftTrend.isPositive,
              draftSparkline: draftTrend.sparkline,
              archivedGrowth: archivedTrend.growth,
              archivedPositive: archivedTrend.isPositive,
              archivedSparkline: archivedTrend.sparkline,
              setsGrowth: setsTrend.growth,
              setsPositive: setsTrend.isPositive,
              setsSparkline: setsTrend.sparkline,
            ),
            const SizedBox(height: 18),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: tableCard),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 285,
                    child: Column(
                      children: [
                        donutCard,
                        const SizedBox(height: 12),
                        difficultyCard,
                        const SizedBox(height: 12),
                        activityCard,
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  tableCard,
                  const SizedBox(height: 14),
                  donutCard,
                  const SizedBox(height: 12),
                  difficultyCard,
                  const SizedBox(height: 12),
                  activityCard,
                ],
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
