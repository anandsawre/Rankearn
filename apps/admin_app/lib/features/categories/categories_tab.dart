import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import 'models/category_item.dart';
import 'widgets/categories_hero_card.dart';
import 'widgets/categories_quick_actions.dart';
import 'widgets/categories_metrics_row.dart';
import 'widgets/target_exams_table_card.dart';
import 'widgets/category_wise_tests_donut_card.dart';
import 'widgets/top_categories_bar_chart.dart';
import 'widgets/category_recent_activity_card.dart';
import 'dialogs/create_category_dialog.dart';
import 'dialogs/import_categories_dialog.dart';
import 'dialogs/manage_subcategories_dialog.dart';
import 'dialogs/bulk_actions_dialog.dart';
import 'dialogs/manage_target_exams_dialog.dart';
import 'dialogs/reorder_exams_dialog.dart';
import 'dialogs/duplicate_exam_dialog.dart';

/// Categories & Target Exams Management Screen for Rankearn Admin Panel
/// Fully backed by live Supabase `exam_categories`, `categories`, `tests`, and `questions`.
class CategoriesTab extends StatefulWidget {
  final List<ExamCategoryModel>? initialExams;
  final List<CategoryItem>? initialCategories;

  const CategoriesTab({
    super.key,
    this.initialExams,
    this.initialCategories,
  });

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final _testsRepo = TestsRepository();

  List<ExamCategoryModel> _targetExams = [];
  List<CategoryItem> _allItems = [];
  List<DateTime> _examDates = [];
  List<DateTime> _publishedExamDates = [];
  List<DateTime> _hiddenExamDates = [];
  List<DateTime> _testDates = [];
  Map<String, int> _questionsPerExam = {};
  List<({String title, DateTime createdAt, IconData icon, Color color, Color bgColor})>
      _activityEvents = [];

  final Set<String> _selectedIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialExams != null || widget.initialCategories != null) {
      _targetExams = List.from(widget.initialExams ?? const []);
      _allItems = List.from(widget.initialCategories ?? const []);
      _isLoading = false;
    } else {
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
        client.from('exam_categories').select().order('display_order', ascending: true),
        client.from('categories').select().order('display_order', ascending: true),
        client
            .from('tests')
            .select('id, exam_category_id, test_mode, created_at')
            .limit(5000),
        client.from('questions').select('id, test_id, created_at').limit(5000),
      ]);

      final examRows = List<Map<String, dynamic>>.from(results[0] as List);
      final categoryRows = List<Map<String, dynamic>>.from(results[1] as List);
      final testRows = List<Map<String, dynamic>>.from(results[2] as List);
      final questionRows = List<Map<String, dynamic>>.from(results[3] as List);

      // Map tests -> counts per exam & testId -> examId lookup
      final mockCounts = <String, int>{};
      final sectionalCounts = <String, int>{};
      final totalTestsByExam = <String, int>{};
      final testIdToExamId = <String, String>{};
      final parsedTestDates = <DateTime>[];

      for (final t in testRows) {
        final tid = t['id']?.toString() ?? '';
        final eid = t['exam_category_id']?.toString() ?? '';
        final mode = t['test_mode']?.toString() ?? 'mock';
        final dt = DateTime.tryParse(t['created_at']?.toString() ?? '')?.toLocal();
        if (dt != null) parsedTestDates.add(dt);

        if (tid.isNotEmpty && eid.isNotEmpty) {
          testIdToExamId[tid] = eid;
        }
        if (eid.isNotEmpty) {
          totalTestsByExam[eid] = (totalTestsByExam[eid] ?? 0) + 1;
          if (mode == 'mock') {
            mockCounts[eid] = (mockCounts[eid] ?? 0) + 1;
          } else if (mode == 'sectional') {
            sectionalCounts[eid] = (sectionalCounts[eid] ?? 0) + 1;
          }
        }
      }

      // Count actual DB questions per exam via test_id
      final qCountsByExam = <String, int>{};
      for (final q in questionRows) {
        final tid = q['test_id']?.toString() ?? '';
        final eid = testIdToExamId[tid];
        if (eid != null && eid.isNotEmpty) {
          qCountsByExam[eid] = (qCountsByExam[eid] ?? 0) + 1;
        }
      }

      final parsedExams = <ExamCategoryModel>[];
      final eDates = <DateTime>[];
      final pubDates = <DateTime>[];
      final hidDates = <DateTime>[];
      final events =
          <({String title, DateTime createdAt, IconData icon, Color color, Color bgColor})>[];

      for (final row in examRows) {
        final base = ExamCategoryModel.fromMap(row);
        final eid = base.id;
        final exam = base.copyWith(
          totalTests: totalTestsByExam[eid] ?? 0,
          totalMocks: mockCounts[eid] ?? 0,
          totalSectional: sectionalCounts[eid] ?? 0,
        );
        parsedExams.add(exam);

        final dt = DateTime.tryParse(row['created_at']?.toString() ?? '')?.toLocal();
        if (dt != null) {
          eDates.add(dt);
          if (exam.isPublished) {
            pubDates.add(dt);
          } else {
            hidDates.add(dt);
          }
          events.add((
            title: '${exam.isPublished ? "Published" : "Draft"} Exam: ${exam.name}',
            createdAt: dt,
            icon: exam.isPublished ? Icons.check_circle_rounded : Icons.edit_note_rounded,
            color: exam.isPublished ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
            bgColor: exam.isPublished ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
          ));
        }
      }

      final parsedCategories = categoryRows
          .asMap()
          .entries
          .map((e) => CategoryItem.fromMap(e.value, e.key + 1))
          .toList();

      for (final cat in parsedCategories.take(10)) {
        final dt = cat.updatedAt ?? cat.createdAt;
        events.add((
          title: 'Subject ${cat.updatedAt != null ? "updated" : "created"}: ${cat.name}',
          createdAt: dt,
          icon: Icons.bookmark_add_rounded,
          color: const Color(0xFF0084FF),
          bgColor: const Color(0xFFEFF6FF),
        ));
      }

      events.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!mounted) return;
      setState(() {
        _targetExams = parsedExams;
        _allItems = parsedCategories;
        _examDates = eDates;
        _publishedExamDates = pubDates;
        _hiddenExamDates = hidDates;
        _testDates = parsedTestDates;
        _questionsPerExam = qCountsByExam;
        _activityEvents = events;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load exams & syllabus from Supabase: $e';
      });
    }
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

  List<DonutSlice> get _examTestSlices {
    final examsWithTests = _targetExams.where((e) => e.totalTests > 0).toList();
    if (examsWithTests.isEmpty) return const [];
    final total = examsWithTests.fold<int>(0, (sum, e) => sum + e.totalTests);
    if (total <= 0) return const [];

    const palette = [
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFFF59E0B),
      Color(0xFF06B6D4),
      Color(0xFF10B981),
      Color(0xFFEC4899),
      Color(0xFFF43F5E),
    ];

    examsWithTests.sort((a, b) => b.totalTests.compareTo(a.totalTests));
    return examsWithTests.asMap().entries.map((entry) {
      final exam = entry.value;
      return DonutSlice(
        label: exam.name,
        percentage: (exam.totalTests / total) * 100,
        color: palette[entry.key % palette.length],
        count: exam.totalTests,
      );
    }).toList();
  }

  List<TopExamBarData> get _topExamBars {
    if (_targetExams.isEmpty) return const [];
    const palette = [
      Color(0xFF0084FF),
      Color(0xFFF43F5E),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
      Color(0xFF10B981),
    ];

    final entries = _targetExams.map((e) {
      final dbQ = _questionsPerExam[e.id] ?? 0;
      return (exam: e, qCount: dbQ);
    }).toList()
      ..sort((a, b) => b.qCount.compareTo(a.qCount));

    return entries.take(5).toList().asMap().entries.map((entry) {
      return TopExamBarData(
        label: entry.value.exam.name,
        value: entry.value.qCount,
        color: palette[entry.key % palette.length],
      );
    }).toList();
  }

  List<CategoryActivityData> get _recentActivities {
    if (_activityEvents.isEmpty) return const [];
    return _activityEvents.take(5).map((ev) {
      return CategoryActivityData(
        icon: ev.icon,
        iconColor: ev.color,
        bgColor: ev.bgColor,
        title: ev.title,
        time: _formatTimeAgo(ev.createdAt),
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

  // ==========================================
  // ACTION HANDLERS
  // ==========================================

  void _openManageTargetExamsDialog([ExamCategoryModel? examToEdit]) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ManageTargetExamsDialog(
        initialExamToEdit: examToEdit,
        onExamsUpdated: _loadFromSupabase,
      ),
    );
  }

  void _openCreateSubjectDialog([CategoryItem? item]) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => CreateCategoryDialog(
        itemToEdit: item,
        onSave: (savedItem) async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot save subject.', isError: true);
            return;
          }

          try {
            await client.from('categories').upsert(savedItem.toMap());
            if (!mounted) return;
            await _loadFromSupabase();
            _showSnack(
              item != null
                  ? 'Updated "${savedItem.name}" in Supabase!'
                  : 'Created "${savedItem.name}" in Supabase!',
            );
          } catch (e) {
            _showSnack('Failed to save subject: $e', isError: true);
          }
        },
      ),
    );
  }

  void _deleteTargetExam(ExamCategoryModel exam) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => AppModalDialog(
        title: 'Delete Target Exam',
        subtitle: 'Permanent deletion warning',
        iconData: Icons.delete_outline_rounded,
        gradientColors: const [Color(0xFFDC2626), Color(0xFFEF4444)],
        maxWidth: 440,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
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
              Navigator.of(ctx).pop();
              final res = await _testsRepo.deleteExamCategory(exam.id);
              if (!mounted) return;
              if (res is Failure<bool>) {
                _showSnack(res.message, isError: true);
                return;
              }
              setState(() {
                _targetExams.removeWhere((e) => e.id == exam.id);
                _selectedIds.remove(exam.id);
              });
              _showSnack('Deleted "${exam.name}"', bg: const Color(0xFFF43F5E));
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Are you sure you want to delete "${exam.name}"? This action will also unlink its assigned subjects.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
          ),
        ),
      ),
    );
  }

  void _openImportDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ImportCategoriesDialog(
        onImport: (imported) async {
          if (imported.isEmpty) return;
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot import syllabus.', isError: true);
            return;
          }

          try {
            await client
                .from('categories')
                .upsert(imported.map((i) => i.toMap()).toList());
            if (!mounted) return;
            await _loadFromSupabase();
            _showSnack('Imported ${imported.length} subjects to Supabase!');
          } catch (e) {
            _showSnack('Failed to import syllabus: $e', isError: true);
          }
        },
      ),
    );
  }

  void _openManageSubcategoriesDialog([CategoryItem? category]) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ManageSubcategoriesDialog(
        categories: _allItems,
        initialCategory: category,
        onChaptersUpdated: _loadFromSupabase,
      ),
    );
  }

  void _openReorderExamsDialog() {
    if (_targetExams.isEmpty) {
      _showSnack('No target exams available to reorder.', bg: const Color(0xFFF59E0B));
      return;
    }

    AppModalDialog.show(
      context: context,
      builder: (ctx) => ReorderExamsDialog(
        exams: _targetExams,
        onSaveOrder: (reordered) async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot save display order.', isError: true);
            return;
          }

          try {
            await Future.wait(
              reordered.map(
                (exam) => client
                    .from('exam_categories')
                    .update({'display_order': exam.displayOrder})
                    .eq('id', exam.id),
              ),
            );
            if (!mounted) return;
            setState(() => _targetExams = reordered);
            _showSnack('Target exams display order updated in Supabase!');
          } catch (e) {
            _showSnack('Failed to update display order: $e', isError: true);
          }
        },
      ),
    );
  }

  void _openDuplicateExamDialog() {
    if (_targetExams.isEmpty) {
      _showSnack('Create a target exam first before duplicating.', bg: const Color(0xFFF59E0B));
      return;
    }

    AppModalDialog.show(
      context: context,
      builder: (ctx) => DuplicateExamDialog(
        exams: _targetExams,
        onDuplicate: (cloned) async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot duplicate exam.', isError: true);
            return;
          }

          try {
            await client.from('exam_categories').insert({
              'id': cloned.id,
              'name': cloned.name,
              'normalized_name': cloned.name.toLowerCase().trim(),
              'icon_url': cloned.iconUrl,
              'display_order': cloned.displayOrder,
              'is_published': cloned.isPublished,
            });
            if (!mounted) return;
            await _loadFromSupabase();
            _showSnack('Duplicated "${cloned.name}" as draft!');
          } catch (e) {
            _showSnack('Failed to duplicate exam: $e', isError: true);
          }
        },
      ),
    );
  }

  void _openBulkActionsDialog() {
    if (_targetExams.isEmpty) {
      _showSnack('No target exams available for bulk actions.', bg: const Color(0xFFF59E0B));
      return;
    }

    final targetIds = _selectedIds.isNotEmpty
        ? Set<String>.from(_selectedIds)
        : _targetExams.map((e) => e.id).toSet();
    final count = targetIds.length;

    AppModalDialog.show(
      context: context,
      builder: (ctx) => BulkCategoriesActionDialog(
        selectedCount: count,
        onApplyAction: (action) async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot apply bulk actions.', isError: true);
            return;
          }

          try {
            if (action == BulkCategoryActionType.makeActive) {
              await client
                  .from('exam_categories')
                  .update({'is_published': true})
                  .inFilter('id', targetIds.toList());
            } else if (action == BulkCategoryActionType.makeDraft) {
              await client
                  .from('exam_categories')
                  .update({'is_published': false})
                  .inFilter('id', targetIds.toList());
            } else if (action == BulkCategoryActionType.delete) {
              await client
                  .from('exam_categories')
                  .delete()
                  .inFilter('id', targetIds.toList());
              _selectedIds.removeAll(targetIds);
            }
            if (!mounted) return;
            await _loadFromSupabase();
            _showSnack('Bulk action "${action.label}" applied to $count exam(s)!');
          } catch (e) {
            _showSnack('Bulk action failed: $e', isError: true);
          }
        },
      ),
    );
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
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1100;

    final publishedCount = _targetExams.where((e) => e.isPublished).length;
    final hiddenCount = _targetExams.where((e) => !e.isPublished).length;
    final totalTestsCount = _targetExams.fold<int>(0, (sum, e) => sum + e.totalTests);
    final totalSubjects = _allItems.length;

    final examTrend = _computeGrowthAndSparkline(_examDates, totalCount: _targetExams.length);
    final pubTrend = _computeGrowthAndSparkline(_publishedExamDates, totalCount: publishedCount);
    final hidTrend = _computeGrowthAndSparkline(_hiddenExamDates, totalCount: hiddenCount);
    final testsTrend = _computeGrowthAndSparkline(_testDates, totalCount: totalTestsCount);
    final subjTrend = _computeGrowthAndSparkline(
      _allItems.map((c) => c.createdAt).toList(),
      totalCount: totalSubjects,
    );

    final quickActions = CategoriesQuickActions(
      onAddExam: () => _openManageTargetExamsDialog(),
      onAddSubject: () => _openCreateSubjectDialog(),
      onManageChapters: () => _openManageSubcategoriesDialog(),
      onImportSyllabus: _openImportDialog,
      onReorderExams: _openReorderExamsDialog,
      onDuplicateExam: _openDuplicateExamDialog,
      onBulkActions: _openBulkActionsDialog,
    );

    final examsTable = TargetExamsTableCard(
      exams: _targetExams,
      categories: _allItems,
      selectedIds: _selectedIds,
      isLoading: _isLoading,
      onSelectionChanged: (set) {
        setState(() {
          _selectedIds.clear();
          _selectedIds.addAll(set);
        });
      },
      onAddExam: () => _openManageTargetExamsDialog(),
      onEditExam: (exam) => _openManageTargetExamsDialog(exam),
      onDeleteExam: _deleteTargetExam,
    );

    final donutCard = CategoryWiseTestsDonutCard(
      totalTests: totalTestsCount,
      slices: _examTestSlices,
      isLoading: _isLoading,
    );

    final barChartCard = TopCategoriesBarChartCard(
      bars: _topExamBars,
      isLoading: _isLoading,
    );

    final activityCard = CategoryRecentActivityCard(
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
                  const Expanded(flex: 63, child: CategoriesHeroCard()),
                  const SizedBox(width: 14),
                  Expanded(flex: 37, child: quickActions),
                ],
              )
            else
              Column(
                children: [
                  const CategoriesHeroCard(),
                  const SizedBox(height: 14),
                  quickActions,
                ],
              ),
            const SizedBox(height: 16),
            CategoriesMetricsRow(
              totalExams: _targetExams.length,
              publishedExams: publishedCount,
              hiddenExams: hiddenCount,
              linkedTests: totalTestsCount,
              totalSubjects: totalSubjects,
              isLoading: _isLoading,
              totalGrowth: examTrend.growth,
              totalPositive: examTrend.isPositive,
              totalSparkline: examTrend.sparkline,
              publishedGrowth: pubTrend.growth,
              publishedPositive: pubTrend.isPositive,
              publishedSparkline: pubTrend.sparkline,
              hiddenGrowth: hidTrend.growth,
              hiddenPositive: hidTrend.isPositive,
              hiddenSparkline: hidTrend.sparkline,
              testsGrowth: testsTrend.growth,
              testsPositive: testsTrend.isPositive,
              testsSparkline: testsTrend.sparkline,
              subjectsGrowth: subjTrend.growth,
              subjectsPositive: subjTrend.isPositive,
              subjectsSparkline: subjTrend.sparkline,
            ),
            const SizedBox(height: 16),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: examsTable),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 295,
                    child: Column(
                      children: [
                        donutCard,
                        const SizedBox(height: 12),
                        barChartCard,
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
                  examsTable,
                  const SizedBox(height: 14),
                  donutCard,
                  const SizedBox(height: 14),
                  barChartCard,
                  const SizedBox(height: 14),
                  activityCard,
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
