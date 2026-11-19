import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

import 'models/test_series_item.dart';
import 'widgets/test_series_hero_card.dart';
import 'widgets/test_series_quick_actions.dart';
import 'widgets/test_series_metrics_row.dart';
import 'widgets/test_series_table_card.dart';
import 'widgets/subject_wise_chart_card.dart';
import 'widgets/recent_activity_card.dart';

import 'dialogs/create_test_series_dialog.dart';
import 'dialogs/view_test_series_dialog.dart';
import 'dialogs/view_test_questions_dialog.dart';
import 'dialogs/analytics_test_series_dialog.dart';
import 'dialogs/add_test_paper_dialog.dart';
import 'dialogs/manage_subjects_dialog.dart';
import 'dialogs/import_tests_dialog.dart';
import 'dialogs/ai_generate_test_series_dialog.dart';

import '../questions/dialogs/create_question_dialog.dart';

/// Test Series Management Screen
/// Fully backed by live Supabase database queries and mutations.
class TestsTab extends StatefulWidget {
  final List<TestSeriesItem>? initialItems;

  const TestsTab({super.key, this.initialItems});

  @override
  State<TestsTab> createState() => _TestsTabState();
}

class _TestsTabState extends State<TestsTab> {
  static const List<String> _months = [
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

  late List<TestSeriesItem> _allItems;
  List<Map<String, dynamic>> _dbCategories = [];
  List<DateTime> _attemptDates = [];
  List<DateTime> _questionDates = [];
  List<({String title, DateTime createdAt, bool isAttempt})> _dbActivityEvents = [];

  bool _isLoading = true;
  String? _errorMessage;

  // Search & Filtering State
  String _searchQuery = '';
  String _selectedSubject = 'All Subjects';
  String _selectedStatus = 'All Status';
  String _accessFilter = 'All'; // 'All', 'Free', 'Premium'
  String _modeFilter = 'All Modes'; // 'All Modes', 'mock', 'sectional', 'previous-year', 'tournament'

  // Pagination State
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
        client.from('tests').select().order('created_at', ascending: false),
        client.from('categories').select('*').order('display_order', ascending: true),
        client.from('questions').select('id, test_id, created_at').limit(5000),
        client
            .from('attempts')
            .select('id, test_id, created_at')
            .order('created_at', ascending: false)
            .limit(2000),
      ]);

      final testRows = List<Map<String, dynamic>>.from(results[0] as List);
      final categoryRows = List<Map<String, dynamic>>.from(results[1] as List);
      final questionRows = List<Map<String, dynamic>>.from(results[2] as List);
      final attemptRows = List<Map<String, dynamic>>.from(results[3] as List);

      // Build category ID/name lookup
      final catNameLookup = <String, String>{};
      for (final c in categoryRows) {
        final id = c['id']?.toString().trim() ?? '';
        final name = c['name']?.toString().trim() ?? '';
        if (id.isNotEmpty && name.isNotEmpty) {
          catNameLookup[id.toLowerCase()] = name;
        }
        if (name.isNotEmpty) {
          catNameLookup[name.toLowerCase()] = name;
        }
      }

      // Count actual DB questions & attempts per test_id
      final questionsCountByTest = <String, int>{};
      final qDates = <DateTime>[];
      for (final q in questionRows) {
        final tid = q['test_id']?.toString().trim() ?? '';
        if (tid.isNotEmpty) {
          questionsCountByTest[tid] = (questionsCountByTest[tid] ?? 0) + 1;
        }
        final dt = DateTime.tryParse(q['created_at']?.toString() ?? '')?.toLocal();
        if (dt != null) qDates.add(dt);
      }

      final attemptsCountByTest = <String, int>{};
      final aDates = <DateTime>[];
      for (final a in attemptRows) {
        final tid = a['test_id']?.toString().trim() ?? '';
        if (tid.isNotEmpty) {
          attemptsCountByTest[tid] = (attemptsCountByTest[tid] ?? 0) + 1;
        }
        final dt = DateTime.tryParse(a['created_at']?.toString() ?? '')?.toLocal();
        if (dt != null) aDates.add(dt);
      }

      final testTitleMap = <String, String>{};
      final loadedItems = testRows.asMap().entries.map((entry) {
        final row = entry.value;
        final id = row['id']?.toString() ?? '';
        final title = row['title']?.toString() ?? '';
        if (id.isNotEmpty && title.isNotEmpty) testTitleMap[id] = title;

        final rawCatId = row['category_id']?.toString().trim().toLowerCase() ?? '';
        final rawCat = row['category']?.toString().trim().toLowerCase() ?? '';
        final resolvedSub = catNameLookup[rawCatId] ?? catNameLookup[rawCat];

        return TestSeriesItem.fromMap(
          row,
          entry.key + 1,
          resolvedSubject: resolvedSub,
          actualQuestionsCount: questionsCountByTest[id],
          actualEnrollments: attemptsCountByTest[id],
        );
      }).toList();

      // Build combined live activity events from real tests & attempts
      final events = <({String title, DateTime createdAt, bool isAttempt})>[];
      for (final item in loadedItems.take(5)) {
        final label = item.status == TestSeriesStatus.published ? 'Published' : item.status.label;
        events.add((
          title: '$label: ${item.title}',
          createdAt: item.createdAt,
          isAttempt: false,
        ));
      }
      for (final a in attemptRows.take(5)) {
        final dt = DateTime.tryParse(a['created_at']?.toString() ?? '')?.toLocal();
        if (dt != null) {
          final tid = a['test_id']?.toString() ?? '';
          final tTitle = testTitleMap[tid] ?? 'Test Series';
          events.add((
            title: 'Attempt submitted: $tTitle',
            createdAt: dt,
            isAttempt: true,
          ));
        }
      }
      events.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!mounted) return;
      setState(() {
        _allItems = loadedItems;
        _dbCategories = categoryRows;
        _attemptDates = aDates;
        _questionDates = qDates;
        _dbActivityEvents = events.take(6).toList();
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load test series from database: $e';
      });
    }
  }

  // Filtered Items computation
  List<TestSeriesItem> get _filteredItems {
    return _allItems.where((item) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = item.title.toLowerCase().contains(query);
        final matchesDesc = item.description.toLowerCase().contains(query);
        final matchesSub = item.subject.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc && !matchesSub) return false;
      }

      if (_selectedSubject != 'All Subjects') {
        if (item.subject.toLowerCase() != _selectedSubject.toLowerCase()) {
          return false;
        }
      }

      if (_selectedStatus != 'All Status') {
        if (item.status.label.toLowerCase() != _selectedStatus.toLowerCase()) {
          return false;
        }
      }

      if (_accessFilter == 'Free' && (item.isPremium || item.priceInr > 0)) {
        return false;
      }
      if (_accessFilter == 'Premium' && (!item.isPremium && item.priceInr <= 0)) {
        return false;
      }

      if (_modeFilter != 'All Modes') {
        if (item.testMode.toLowerCase() != _modeFilter.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Pagination computation
  List<TestSeriesItem> get _paginatedItems {
    final filtered = _filteredItems;
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    if (startIndex >= filtered.length) {
      return filtered.isNotEmpty ? filtered.sublist(0, filtered.length) : [];
    }
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  int get _totalPages {
    final count = _filteredItems.length;
    if (count == 0) return 1;
    return (count / _rowsPerPage).ceil();
  }

  // Dynamic Metric aggregates
  int get _totalTestSeries => _allItems.length;
  int get _publishedCount =>
      _allItems.where((i) => i.status == TestSeriesStatus.published).length;
  int get _draftsCount =>
      _allItems.where((i) => i.status == TestSeriesStatus.draft).length;
  int get _totalTests =>
      _allItems.fold<int>(0, (sum, i) => sum + i.totalTests);
  int get _totalQuestions =>
      _allItems.fold<int>(0, (sum, i) => sum + i.totalQuestions);
  int get _totalEnrollments =>
      _allItems.fold<int>(0, (sum, i) => sum + i.enrollments);

  ({String growth, bool isPositive, List<double> sparkline}) _computeTrend(
    List<DateTime> dates,
    int totalCount,
  ) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    int cur = 0;
    int prev = 0;
    final buckets = List<double>.filled(7, 0);

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

  // Dynamic Subject Slices for Donut Chart
  List<DonutSlice> get _subjectSlices {
    if (_allItems.isEmpty) return const [];
    final colorLookup = <String, Color>{};
    for (final c in _dbCategories) {
      final name = c['name']?.toString().trim().toLowerCase() ?? '';
      final parsed = _parseHexColor(c['icon_color']?.toString());
      if (name.isNotEmpty && parsed != null) {
        colorLookup[name] = parsed;
      }
    }

    final Map<String, int> counts = {};
    for (final item in _allItems) {
      final sub = item.subject.trim().isEmpty ? 'General' : item.subject.trim();
      counts[sub] = (counts[sub] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    const palette = [
      AppColors.brandBlue,
      AppColors.battleAdminPurple,
      AppColors.coinGold,
      Color(0xFF06B6D4),
      AppColors.brandPink,
      AppColors.brandOrange,
      AppColors.brandGreen,
      AppColors.brandPurple,
    ];

    int colorIdx = 0;
    return sorted.map((entry) {
      final pct = (entry.value / _allItems.length) * 100;
      final color = colorLookup[entry.key.toLowerCase()] ?? palette[colorIdx % palette.length];
      colorIdx++;
      return DonutSlice(
        label: entry.key,
        percentage: pct,
        color: color,
        count: entry.value,
      );
    }).toList();
  }

  List<String> get _availableSubjects {
    return <String>{
      ..._dbCategories
          .map((c) => c['name']?.toString().trim() ?? '')
          .where((n) => n.isNotEmpty),
      ..._allItems.map((i) => i.subject.trim()).where((s) => s.isNotEmpty),
    }.toList()
      ..sort();
  }

  // Dynamic Recent Activity from real database events
  List<ActivityItemData> get _recentActivities {
    if (_dbActivityEvents.isNotEmpty) {
      return _dbActivityEvents.take(5).map((ev) {
        if (ev.isAttempt) {
          return ActivityItemData(
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.battleAdminPurple,
            iconBgColor: AppColors.battleAdminPurpleLight,
            text: ev.title,
            timeAgo: _formatTimeAgo(ev.createdAt),
          );
        }
        final isPub = ev.title.startsWith('Published:');
        return ActivityItemData(
          icon: isPub ? Icons.check_circle_rounded : Icons.edit_note_rounded,
          iconColor: isPub ? AppColors.brandGreen : AppColors.coinGold,
          iconBgColor: isPub ? AppColors.brandGreenLight : AppColors.coinGoldLight,
          text: ev.title,
          timeAgo: _formatTimeAgo(ev.createdAt),
        );
      }).toList();
    }

    if (_allItems.isEmpty) return const [];
    return _allItems.take(5).map((item) {
      final isPub = item.status == TestSeriesStatus.published;
      return ActivityItemData(
        icon: isPub ? Icons.check_circle_rounded : Icons.edit_note_rounded,
        iconColor: isPub ? AppColors.brandGreen : AppColors.coinGold,
        iconBgColor: isPub ? AppColors.brandGreenLight : AppColors.coinGoldLight,
        text: '${isPub ? "Published" : item.status.label}: ${item.title}',
        timeAgo: _formatTimeAgo(item.createdAt),
      );
    }).toList();
  }

  void _showSnack(String message, {bool isError = false, Color? backgroundColor}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : (backgroundColor ?? AppColors.brandGreen),
      ),
    );
  }

  // Actions
  void _openCreateDialog([TestSeriesItem? itemToEdit]) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => CreateTestSeriesDialog(
        initialItem: itemToEdit,
        onSave: (savedItem) async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot save test series.', isError: true);
            return;
          }

          try {
            await client.from('tests').upsert(savedItem.toMap());
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
                  ? 'Updated test series "${savedItem.title}"'
                  : 'Created new test series "${savedItem.title}"',
            );
          } catch (e) {
            _showSnack('Failed to save test series to database: $e', isError: true);
          }
        },
      ),
    );
  }

  void _openViewDialog(TestSeriesItem item) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ViewTestSeriesDialog(
        item: item,
        onAddQuestion: () => _openAddQuestionDialog(item),
        onViewQuestions: () => _openViewQuestionsDialog(item),
      ),
    );
  }

  void _openViewQuestionsDialog(TestSeriesItem item) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ViewTestQuestionsDialog(
        item: item,
        onQuestionsUpdated: () {
          _loadFromSupabase();
        },
      ),
    );
  }

  void _openAddQuestionDialog([TestSeriesItem? item]) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => CreateQuestionDialog(
        initialTestSeriesTitle: item?.title,
        initialTestId: item?.id,
        onBulkSave: (importedQuestions) {
          _loadFromSupabase();
        },
        onSave: (savedQuestion) async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot save question.', isError: true);
            return;
          }

          try {
            final payload = savedQuestion.toMap();
            if (item != null) {
              payload['test_id'] = item.id;
              await client.from('tests').upsert(item.toMap());
            }
            await client.from('questions').upsert(payload);

            if (item != null) {
              final newCount = item.totalQuestions + 1;
              await client.from('tests').update({
                'total_questions': newCount,
              }).eq('id', item.id);

              if (mounted) {
                setState(() {
                  final idx = _allItems.indexWhere((i) => i.id == item.id);
                  if (idx >= 0) {
                    _allItems[idx] = _allItems[idx].copyWith(totalQuestions: newCount);
                  }
                });
              }
            }

            _showSnack(
              item != null
                  ? 'Question added to "${item.title}" successfully!'
                  : 'Question added to question bank successfully!',
            );
          } catch (e) {
            _showSnack('Failed to save question to Supabase: $e', isError: true);
          }
        },
      ),
    );
  }

  void _openAddTestPaperDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => AddTestPaperDialog(
        existingSeries: _allItems,
        onSave: (newItem) async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot add test paper.', isError: true);
            return;
          }

          try {
            await client.from('tests').upsert(newItem.toMap());
            if (!mounted) return;
            setState(() {
              _allItems.insert(0, newItem);
            });
            _showSnack(
              'Test Paper "${newItem.title}" added successfully!',
              backgroundColor: const Color(0xFF0084FF),
            );
          } catch (e) {
            _showSnack('Failed to add test paper to Supabase: $e', isError: true);
          }
        },
      ),
    );
  }

  void _openManageSubjectsDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ManageSubjectsDialog(
        onSubjectsChanged: () {
          _loadFromSupabase();
        },
      ),
    );
  }

  void _openImportTestsDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ImportTestsDialog(
        existingTests: _allItems,
        onImportTests: (imported) async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot import tests.', isError: true);
            return;
          }

          try {
            final payload = imported.map((i) => i.toMap()).toList();
            await client.from('tests').upsert(payload);
            if (!mounted) return;
            setState(() {
              _allItems.insertAll(0, imported);
            });
            _showSnack(
              'Successfully imported ${imported.length} test papers!',
              backgroundColor: const Color(0xFFFF9500),
            );
          } catch (e) {
            _showSnack('Failed to import tests to Supabase: $e', isError: true);
          }
        },
      ),
    );
  }

  void _openAiGenerateTestSeriesDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => AiGenerateTestSeriesDialog(
        onSaveGenerated: (testItem, questions) async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot save AI generated test.', isError: true);
            return;
          }

          try {
            await client.from('tests').upsert(testItem.toMap());
            if (questions.isNotEmpty) {
              final payload = questions.map((q) => q.toMap()).toList();
              await client.from('questions').upsert(payload);
            }
            if (!mounted) return;
            setState(() {
              _allItems.insert(0, testItem);
            });
            _showSnack(
              'AI Test Series "${testItem.title}" with ${questions.length} questions saved!',
              backgroundColor: const Color(0xFFFF3385),
            );
          } catch (e) {
            _showSnack('Failed to save generated test series to Supabase: $e', isError: true);
          }
        },
      ),
    );
  }

  void _openAnalyticsDialog(TestSeriesItem item) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => AnalyticsTestSeriesDialog(item: item),
    );
  }

  void _openAdvancedFiltersDialog() {
    String draftAccess = _accessFilter;
    String draftMode = _modeFilter;

    AppModalDialog.show(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AppModalDialog(
              title: 'Filter Test Series',
              subtitle: 'Refine test series by pricing tier and exam mode',
              iconData: Icons.filter_list_rounded,
              maxWidth: 460,
              footerLeft: TextButton.icon(
                onPressed: () {
                  setDialogState(() {
                    draftAccess = 'All';
                    draftMode = 'All Modes';
                  });
                },
                icon: const Icon(
                  Icons.restart_alt_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                label: Text(
                  'Reset',
                  style: TextStyle(
                    fontFamily: AppTypography.fontHeading,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.borderSm),
                ),
              ),
              actions: [
                AppModalDialog.cancelButton(ctx),
                AppModalDialog.primaryButton(
                  onPressed: () {
                    setState(() {
                      _accessFilter = draftAccess;
                      _modeFilter = draftMode;
                      _currentPage = 1;
                    });
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Access Tier',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppDropdown<String>(
                    value: draftAccess,
                    items: const [
                      AppDropdownItem(value: 'All', label: 'All Tiers'),
                      AppDropdownItem(value: 'Free', label: 'Free Only'),
                      AppDropdownItem(value: 'Premium', label: 'Premium / Paid'),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => draftAccess = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Test Mode',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppDropdown<String>(
                    value: draftMode,
                    items: const [
                      AppDropdownItem(value: 'All Modes', label: 'All Modes'),
                      AppDropdownItem(value: 'mock', label: 'Mock Test'),
                      AppDropdownItem(value: 'sectional', label: 'Sectional Test'),
                      AppDropdownItem(value: 'previous-year', label: 'Previous Year'),
                      AppDropdownItem(value: 'tournament', label: 'Tournament'),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => draftMode = val);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteItem(TestSeriesItem item) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => AppModalDialog(
        title: 'Delete Test Series',
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
                _showSnack('Database not connected. Cannot delete test series.', isError: true);
                return;
              }
              try {
                await client.from('tests').delete().eq('id', item.id);
                if (!mounted) return;
                setState(() {
                  _allItems.removeWhere((i) => i.id == item.id);
                });
                _showSnack('Deleted "${item.title}"', backgroundColor: AppColors.textPrimary);
              } catch (e) {
                _showSnack('Failed to delete test series: $e', isError: true);
              }
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
        child: Text(
          'Are you sure you want to delete "${item.title}"? This action cannot be undone and will remove all associated test records.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.45),
        ),
      ),
    );
  }

  void _toggleStatus(TestSeriesItem item) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      _showSnack('Database not connected. Cannot update status.', isError: true);
      return;
    }

    final nextStatus = item.status == TestSeriesStatus.published
        ? TestSeriesStatus.draft
        : TestSeriesStatus.published;
    final updated = item.copyWith(status: nextStatus);

    try {
      await client.from('tests').update({'status': nextStatus.name}).eq('id', item.id);
      if (!mounted) return;
      setState(() {
        final idx = _allItems.indexWhere((i) => i.id == item.id);
        if (idx >= 0) _allItems[idx] = updated;
      });
      _showSnack(
        'Status changed to ${nextStatus.label} for "${item.title}"',
        backgroundColor: const Color(0xFF5636F5),
      );
    } catch (e) {
      _showSnack('Failed to update status in Supabase: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;
    final isMobile = screenWidth < 768;

    final seriesTrend = _computeTrend(
      _allItems.map((i) => i.createdAt).toList(),
      _totalTestSeries,
    );
    final publishedTrend = _computeTrend(
      _allItems.where((i) => i.status == TestSeriesStatus.published).map((i) => i.createdAt).toList(),
      _publishedCount,
    );
    final draftsTrend = _computeTrend(
      _allItems.where((i) => i.status == TestSeriesStatus.draft).map((i) => i.createdAt).toList(),
      _draftsCount,
    );
    final questionsTrend = _computeTrend(_questionDates, _totalQuestions);
    final attemptsTrend = _computeTrend(_attemptDates, _totalEnrollments);

    final metricsRow = TestSeriesMetricsRow(
      totalTestSeries: _totalTestSeries,
      publishedCount: _publishedCount,
      draftsCount: _draftsCount,
      totalTests: _totalTests,
      totalEnrollments: _totalEnrollments,
      isLoading: _isLoading && _allItems.isEmpty,
      totalSeriesGrowth: seriesTrend.growth,
      totalSeriesPositive: seriesTrend.isPositive,
      totalSeriesSparkline: seriesTrend.sparkline,
      publishedGrowth: publishedTrend.growth,
      publishedPositive: publishedTrend.isPositive,
      publishedSparkline: publishedTrend.sparkline,
      draftsGrowth: draftsTrend.growth,
      draftsPositive: draftsTrend.isPositive,
      draftsSparkline: draftsTrend.sparkline,
      questionsGrowth: questionsTrend.growth,
      questionsPositive: questionsTrend.isPositive,
      questionsSparkline: questionsTrend.sparkline,
      enrollmentsGrowth: attemptsTrend.growth,
      enrollmentsPositive: attemptsTrend.isPositive,
      enrollmentsSparkline: attemptsTrend.sparkline,
    );

    final tableCard = TestSeriesTableCard(
      items: _paginatedItems,
      totalCount: _filteredItems.length,
      selectedSubject: _selectedSubject,
      availableSubjects: _availableSubjects,
      selectedStatus: _selectedStatus,
      searchQuery: _searchQuery,
      currentPage: _currentPage,
      totalPages: _totalPages,
      isLoading: _isLoading,
      onSubjectChanged: (val) {
        setState(() {
          _selectedSubject = val;
          _currentPage = 1;
        });
      },
      onStatusChanged: (val) {
        setState(() {
          _selectedStatus = val;
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
      onFiltersTap: _openAdvancedFiltersDialog,
      onView: _openViewDialog,
      onAnalytics: _openAnalyticsDialog,
      onEdit: (item) => _openCreateDialog(item),
      onDelete: _deleteItem,
      onToggleStatus: _toggleStatus,
      onAddQuestion: (item) => _openAddQuestionDialog(item),
      onViewQuestions: _openViewQuestionsDialog,
    );

    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: AppSpacing.pagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.errorRoseLight,
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _isLoading ? null : _loadFromSupabase,
                      icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.error),
                      label: Text(
                        'Retry',
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ==========================================
            // ROW 1: HERO CARD + QUICK ACTIONS
            // ==========================================
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    flex: 63,
                    child: TestSeriesHeroCard(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 37,
                    child: TestSeriesQuickActions(
                      onCreateTestSeries: () => _openCreateDialog(),
                      onAddTestPaper: () => _openAddTestPaperDialog(),
                      onManageSubjects: () => _openManageSubjectsDialog(),
                      onImportTests: () => _openImportTestsDialog(),
                      onAiGenerate: () => _openAiGenerateTestSeriesDialog(),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const TestSeriesHeroCard(),
                  const SizedBox(height: 16),
                  TestSeriesQuickActions(
                    onCreateTestSeries: () => _openCreateDialog(),
                    onAddTestPaper: () => _openAddTestPaperDialog(),
                    onManageSubjects: () => _openManageSubjectsDialog(),
                    onImportTests: () => _openImportTestsDialog(),
                    onAiGenerate: () => _openAiGenerateTestSeriesDialog(),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // ==========================================
            // ROW 2: 5 LIVE METRIC CARDS
            // ==========================================
            metricsRow,
            const SizedBox(height: 20),

            // ==========================================
            // ROW 3: TABLE CARD + RIGHT ANALYTICS COLUMN
            // ==========================================
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: tableCard),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 295,
                    child: Column(
                      children: [
                        SubjectWiseChartCard(
                          totalCount: _totalTestSeries,
                          slices: _subjectSlices,
                          isLoading: _isLoading && _allItems.isEmpty,
                        ),
                        const SizedBox(height: 16),
                        RecentActivityCard(
                          activities: _recentActivities,
                          isLoading: _isLoading && _allItems.isEmpty,
                          onViewAll: _isLoading ? null : _loadFromSupabase,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else if (isMobile)
              Column(
                children: [
                  tableCard,
                  const SizedBox(height: 16),
                  SubjectWiseChartCard(
                    totalCount: _totalTestSeries,
                    slices: _subjectSlices,
                    isLoading: _isLoading && _allItems.isEmpty,
                  ),
                  const SizedBox(height: 16),
                  RecentActivityCard(
                    activities: _recentActivities,
                    isLoading: _isLoading && _allItems.isEmpty,
                    onViewAll: _isLoading ? null : _loadFromSupabase,
                  ),
                ],
              )
            else
              Column(
                children: [
                  tableCard,
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SubjectWiseChartCard(
                          totalCount: _totalTestSeries,
                          slices: _subjectSlices,
                          isLoading: _isLoading && _allItems.isEmpty,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: RecentActivityCard(
                          activities: _recentActivities,
                          isLoading: _isLoading && _allItems.isEmpty,
                          onViewAll: _isLoading ? null : _loadFromSupabase,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${_months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}';
  }

  Color? _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '').trim();
    if (cleaned.length == 6) {
      final val = int.tryParse('FF$cleaned', radix: 16);
      if (val != null) return Color(val);
    } else if (cleaned.length == 8) {
      final val = int.tryParse(cleaned, radix: 16);
      if (val != null) return Color(val);
    }
    return null;
  }
}
