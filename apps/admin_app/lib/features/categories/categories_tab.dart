import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
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
/// Pixel-accurate to centralized design system specification (Option 1: Exam -> Subject -> Chapter).
class CategoriesTab extends StatefulWidget {
  const CategoriesTab({super.key});

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  final _testsRepo = TestsRepository();

  // Level 1: Target Exams State (Loaded dynamically from Supabase)
  List<ExamCategoryModel> _targetExams = [];

  // Level 2: Subjects State (Loaded dynamically from Supabase)
  List<CategoryItem> _allItems = [];
  final Set<String> _selectedIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFromSupabase();
  }

  Future<void> _loadFromSupabase() async {
    setState(() => _isLoading = true);

    // 1. Load Target Exams from Supabase
    try {
      final examsRes = await _testsRepo.getExamCategoryList();
      if (examsRes is Success<List<ExamCategoryModel>>) {
        if (mounted) {
          setState(() {
            _targetExams = List<ExamCategoryModel>.from(examsRes.data);
          });
        }
      }
    } catch (e) {
      debugPrint('CategoriesTab Target Exams fetch error: $e');
    }

    // 2. Load Subjects from Supabase
    final client = SupabaseConfig.clientSafe;
    if (client != null) {
      try {
        final res = await client
            .from('categories')
            .select()
            .order('display_order', ascending: true);

        if (mounted) {
          setState(() {
            _allItems = (res as List)
                .asMap()
                .entries
                .map((e) => CategoryItem.fromMap(e.value, e.key + 1))
                .toList();
          });
        }
      } catch (e) {
        debugPrint('CategoriesTab Categories fetch error: $e');
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // ACTION HANDLERS
  // ==========================================

  void _openManageTargetExamsDialog([ExamCategoryModel? examToEdit]) {
    showDialog(
      context: context,
      builder: (ctx) => ManageTargetExamsDialog(
        onExamsUpdated: () {
          _loadFromSupabase();
        },
      ),
    );
  }

  void _openCreateSubjectDialog([CategoryItem? item]) {
    showDialog(
      context: context,
      builder: (ctx) => CreateCategoryDialog(
        itemToEdit: item,
        onSave: (savedItem) {
          setState(() {
            final idx = _allItems.indexWhere((e) => e.id == savedItem.id);
            if (idx >= 0) {
              _allItems[idx] = savedItem;
            } else {
              _allItems.insert(0, savedItem);
            }
          });

          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            client.from('categories').upsert(savedItem.toMap());
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(item != null
                  ? 'Updated "${savedItem.name}" successfully!'
                  : 'Created "${savedItem.name}" successfully!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        },
      ),
    );
  }

  void _deleteTargetExam(ExamCategoryModel exam) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Target Exam', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete "${exam.name}"? This action will also unlink its subjects.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF43F5E),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() {
                _targetExams.removeWhere((e) => e.id == exam.id);
              });

              await _testsRepo.deleteExamCategory(exam.id);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted "${exam.name}"'),
                    backgroundColor: const Color(0xFFF43F5E),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openImportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ImportCategoriesDialog(
        onImport: (imported) {
          setState(() {
            _allItems.insertAll(0, imported);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imported ${imported.length} categories successfully!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        },
      ),
    );
  }

  void _openManageSubcategoriesDialog([CategoryItem? category]) {
    showDialog(
      context: context,
      builder: (ctx) => ManageSubcategoriesDialog(
        categories: _allItems,
        initialCategory: category,
      ),
    );
  }

  void _openReorderExamsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ReorderExamsDialog(
        exams: _targetExams,
        onSaveOrder: (reordered) {
          setState(() {
            _targetExams = reordered;
          });

          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            for (final exam in reordered) {
              client.from('exam_categories').update({'display_order': exam.displayOrder}).eq('id', exam.id);
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Target exams reordered successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        },
      ),
    );
  }

  void _openDuplicateExamDialog() {
    showDialog(
      context: context,
      builder: (ctx) => DuplicateExamDialog(
        exams: _targetExams,
        onDuplicate: (cloned) {
          setState(() {
            _targetExams.insert(0, cloned);
          });

          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            client.from('exam_categories').insert({
              'id': cloned.id,
              'name': cloned.name,
              'normalized_name': cloned.name.toLowerCase().trim(),
              'icon_url': cloned.iconUrl,
              'display_order': cloned.displayOrder,
              'is_published': cloned.isPublished,
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Duplicated "${cloned.name}" as draft!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        },
      ),
    );
  }

  void _openBulkActionsDialog() {
    final count = _selectedIds.isNotEmpty ? _selectedIds.length : _targetExams.length;
    final targetIds = _selectedIds.isNotEmpty
        ? Set<String>.from(_selectedIds)
        : _targetExams.map((e) => e.id).toSet();

    showDialog(
      context: context,
      builder: (ctx) => BulkCategoriesActionDialog(
        selectedCount: count,
        onApplyAction: (action) async {
          final client = SupabaseConfig.clientSafe;
          if (action == BulkCategoryActionType.makeActive) {
            setState(() {
              _targetExams = _targetExams
                  .map((e) => targetIds.contains(e.id) ? e.copyWith(isPublished: true) : e)
                  .toList();
            });
            if (client != null) {
              await client.from('exam_categories').update({'is_published': true}).inFilter('id', targetIds.toList());
            }
          } else if (action == BulkCategoryActionType.makeDraft) {
            setState(() {
              _targetExams = _targetExams
                  .map((e) => targetIds.contains(e.id) ? e.copyWith(isPublished: false) : e)
                  .toList();
            });
            if (client != null) {
              await client.from('exam_categories').update({'is_published': false}).inFilter('id', targetIds.toList());
            }
          } else if (action == BulkCategoryActionType.delete) {
            setState(() {
              _targetExams.removeWhere((e) => targetIds.contains(e.id));
              _selectedIds.removeAll(targetIds);
            });
            if (client != null) {
              await client.from('exam_categories').delete().inFilter('id', targetIds.toList());
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bulk action "${action.label}" applied to $count exam(s)!'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1100;

    final publishedCount = _targetExams.where((e) => e.isPublished).length;
    final hiddenCount = _targetExams.where((e) => !e.isPublished).length;
    final totalSubjects = _allItems.length;

    return Container(
      color: const Color(0xFFF4F7FF),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // ROW 1: HERO CARD + QUICK ACTIONS PANEL
            // ==========================================
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    flex: 63,
                    child: CategoriesHeroCard(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 37,
                    child: CategoriesQuickActions(
                      onAddExam: () => _openManageTargetExamsDialog(),
                      onAddSubject: () => _openCreateSubjectDialog(),
                      onManageChapters: () => _openManageSubcategoriesDialog(),
                      onImportSyllabus: _openImportDialog,
                      onReorderExams: _openReorderExamsDialog,
                      onDuplicateExam: _openDuplicateExamDialog,
                      onBulkActions: _openBulkActionsDialog,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const CategoriesHeroCard(),
                  const SizedBox(height: 14),
                  CategoriesQuickActions(
                    onAddExam: () => _openManageTargetExamsDialog(),
                    onAddSubject: () => _openCreateSubjectDialog(),
                    onManageChapters: () => _openManageSubcategoriesDialog(),
                    onImportSyllabus: _openImportDialog,
                    onReorderExams: _openReorderExamsDialog,
                    onDuplicateExam: _openDuplicateExamDialog,
                    onBulkActions: _openBulkActionsDialog,
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // ==========================================
            // ROW 2: 5 METRIC CARDS
            // ==========================================
            CategoriesMetricsRow(
              totalCategories: _targetExams.length,
              activeCategories: publishedCount,
              draftCategories: hiddenCount,
              archivedCategories: 0,
              totalSubjects: totalSubjects,
            ),

            const SizedBox(height: 16),

            // ==========================================
            // ROW 3: TARGET EXAMS (OPTION 1 MAIN TABLE) + RIGHT ANALYTICS
            // ==========================================
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Target Exams Table Card
                  Expanded(
                    child: TargetExamsTableCard(
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
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Right Analytics Column
                  SizedBox(
                    width: 295,
                    child: Column(
                      children: [
                        const CategoryWiseTestsDonutCard(),
                        const SizedBox(height: 12),
                        const TopCategoriesBarChartCard(),
                        const SizedBox(height: 12),
                        CategoryRecentActivityCard(
                          onViewAll: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Displaying all exam activity logs.')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  TargetExamsTableCard(
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
                  ),
                  const SizedBox(height: 14),
                  const CategoryWiseTestsDonutCard(),
                  const SizedBox(height: 14),
                  const TopCategoriesBarChartCard(),
                  const SizedBox(height: 14),
                  CategoryRecentActivityCard(
                    onViewAll: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Displaying all exam activity logs.')),
                      );
                    },
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
