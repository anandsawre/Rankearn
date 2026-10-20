import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'models/category_item.dart';
import 'widgets/categories_hero_card.dart';
import 'widgets/categories_quick_actions.dart';
import 'widgets/categories_metrics_row.dart';
import 'widgets/categories_table_card.dart';
import 'widgets/category_wise_tests_donut_card.dart';
import 'widgets/top_categories_bar_chart.dart';
import 'widgets/category_recent_activity_card.dart';
import 'dialogs/create_category_dialog.dart';
import 'dialogs/import_categories_dialog.dart';
import 'dialogs/manage_subcategories_dialog.dart';
import 'dialogs/reorder_categories_dialog.dart';
import 'dialogs/duplicate_category_dialog.dart';
import 'dialogs/bulk_actions_dialog.dart';
import 'dialogs/view_category_dialog.dart';

/// Categories Management Screen for Rankearn Admin Panel
/// Pixel-accurate to reference specification image with Supabase integration.
class CategoriesTab extends StatefulWidget {
  const CategoriesTab({super.key});

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  List<CategoryItem> _allItems = List.from(kReferenceCategories);
  final Set<String> _selectedIds = {};

  String _searchQuery = '';
  String _sortOption = 'latest';
  String _statusFilter = 'all';

  int _currentPage = 1;
  int _pageSize = 7; // Matching 7 rows displayed in specification image

  @override
  void initState() {
    super.initState();
    _loadFromSupabase();
  }

  Future<void> _loadFromSupabase() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return;

    try {
      final res = await client
          .from('categories')
          .select()
          .order('display_order', ascending: true);

      if (res.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _allItems = (res as List)
              .asMap()
              .entries
              .map((e) => CategoryItem.fromMap(e.value, e.key + 1))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('CategoriesTab Supabase fetch (using robust fallback dataset): $e');
    }
  }

  // Filtered Categories computation
  List<CategoryItem> get _filteredItems {
    var list = _allItems.where((item) {
      // 1. Search Query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = item.name.toLowerCase().contains(q);
        final matchesDesc = item.description.toLowerCase().contains(q);
        final matchesSlug = item.slug.toLowerCase().contains(q);
        if (!matchesName && !matchesDesc && !matchesSlug) return false;
      }

      // 2. Status Filter
      if (_statusFilter != 'all') {
        if (item.status.name.toLowerCase() != _statusFilter.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sorting
    switch (_sortOption) {
      case 'oldest':
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'name_asc':
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'name_desc':
        list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'tests_desc':
        list.sort((a, b) => b.totalTests.compareTo(a.totalTests));
        break;
      case 'questions_desc':
        list.sort((a, b) => b.totalQuestions.compareTo(a.totalQuestions));
        break;
      case 'latest':
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return list;
  }

  // Paginated slice
  List<CategoryItem> get _paginatedItems {
    final filtered = _filteredItems;
    final start = (_currentPage - 1) * _pageSize;
    if (start >= filtered.length) {
      return [];
    }
    final end = (start + _pageSize).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  // Actions
  void _openCreateDialog([CategoryItem? itemToEdit]) {
    showDialog(
      context: context,
      builder: (ctx) => CreateCategoryDialog(
        itemToEdit: itemToEdit,
        onSave: (saved) {
          setState(() {
            final idx = _allItems.indexWhere((e) => e.id == saved.id);
            if (idx >= 0) {
              _allItems[idx] = saved;
            } else {
              _allItems.insert(0, saved);
            }
          });

          // Sync to Supabase
          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            client.from('categories').upsert(saved.toMap()).then((_) {
              debugPrint('Saved category to Supabase: ${saved.id}');
            }).catchError((err) {
              debugPrint('Supabase upsert category error: $err');
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(itemToEdit != null ? 'Category updated successfully!' : 'Category created successfully!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        },
      ),
    );
  }

  void _openImportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ImportCategoriesDialog(
        onImport: (importedList) {
          setState(() {
            _allItems.insertAll(0, importedList);
          });

          // Sync to Supabase
          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            final records = importedList.map((e) => e.toMap()).toList();
            client.from('categories').upsert(records).then((_) {
              debugPrint('Imported ${importedList.length} categories to Supabase');
            }).catchError((err) {
              debugPrint('Supabase bulk insert error: $err');
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully imported ${importedList.length} categories!'),
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

  void _openReorderDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ReorderCategoriesDialog(
        categories: _allItems,
        onSaveOrder: (reordered) {
          setState(() {
            _allItems = reordered;
          });

          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            for (final item in reordered) {
              client.from('categories').update({'display_order': item.displayOrder}).eq('id', item.id);
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category order updated successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        },
      ),
    );
  }

  void _openDuplicateDialog([CategoryItem? category]) {
    CategoryItem? target = category;
    if (target == null && _selectedIds.isNotEmpty) {
      target = _allItems.firstWhere((e) => _selectedIds.contains(e.id), orElse: () => _allItems.first);
    }
    target ??= _allItems.first;

    showDialog(
      context: context,
      builder: (ctx) => DuplicateCategoryDialog(
        sourceCategory: target!,
        onDuplicate: (cloned) {
          setState(() {
            _allItems.insert(0, cloned);
          });

          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            client.from('categories').insert(cloned.toMap());
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
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select one or more categories in the table first.'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => BulkCategoriesActionDialog(
        selectedCount: _selectedIds.length,
        onApplyAction: (action) {
          setState(() {
            if (action == BulkCategoryActionType.delete) {
              _allItems.removeWhere((item) => _selectedIds.contains(item.id));
              final client = SupabaseConfig.clientSafe;
              if (client != null) {
                client.from('categories').delete().inFilter('id', _selectedIds.toList());
              }
              _selectedIds.clear();
            } else {
              CategoryStatus newStatus = CategoryStatus.active;
              if (action == BulkCategoryActionType.makeDraft) newStatus = CategoryStatus.draft;
              if (action == BulkCategoryActionType.makeArchived) newStatus = CategoryStatus.archived;

              for (int i = 0; i < _allItems.length; i++) {
                if (_selectedIds.contains(_allItems[i].id)) {
                  _allItems[i] = _allItems[i].copyWith(status: newStatus);
                }
              }

              final client = SupabaseConfig.clientSafe;
              if (client != null) {
                client.from('categories').update({'status': newStatus.name}).inFilter('id', _selectedIds.toList());
              }
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bulk action applied to ${_selectedIds.length} categories!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        },
      ),
    );
  }

  void _openViewDialog(CategoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => ViewCategoryDialog(
        item: item,
        onEdit: () => _openCreateDialog(item),
      ),
    );
  }

  void _deleteCategory(CategoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Category', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete "${item.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF43F5E), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _allItems.removeWhere((e) => e.id == item.id);
                _selectedIds.remove(item.id);
              });

              final client = SupabaseConfig.clientSafe;
              if (client != null) {
                client.from('categories').delete().eq('id', item.id);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "${item.name}"'),
                  backgroundColor: const Color(0xFFF43F5E),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleCategoryStatus(CategoryItem item) {
    final nextStatus = item.status == CategoryStatus.active ? CategoryStatus.draft : CategoryStatus.active;
    setState(() {
      final idx = _allItems.indexWhere((e) => e.id == item.id);
      if (idx >= 0) {
        _allItems[idx] = item.copyWith(status: nextStatus);
      }
    });

    final client = SupabaseConfig.clientSafe;
    if (client != null) {
      client.from('categories').update({'status': nextStatus.name}).eq('id', item.id);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${item.name}" moved to ${nextStatus.label}!'),
        backgroundColor: nextStatus.color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1100;

    final activeCount = _allItems.where((i) => i.status == CategoryStatus.active).length;
    final draftCount = _allItems.where((i) => i.status == CategoryStatus.draft).length;
    final archivedCount = _allItems.where((i) => i.status == CategoryStatus.archived).length;
    final totalSubjects = _allItems.fold<int>(0, (sum, i) => sum + i.subjectsCount);

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
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(
                      flex: 63,
                      child: CategoriesHeroCard(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 37,
                      child: CategoriesQuickActions(
                        onAddCategory: () => _openCreateDialog(),
                        onImportCategories: _openImportDialog,
                        onManageSubcategories: () => _openManageSubcategoriesDialog(),
                        onReorderCategories: _openReorderDialog,
                        onDuplicateCategory: () => _openDuplicateDialog(),
                        onBulkActions: _openBulkActionsDialog,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  const CategoriesHeroCard(),
                  const SizedBox(height: 14),
                  CategoriesQuickActions(
                    onAddCategory: () => _openCreateDialog(),
                    onImportCategories: _openImportDialog,
                    onManageSubcategories: () => _openManageSubcategoriesDialog(),
                    onReorderCategories: _openReorderDialog,
                    onDuplicateCategory: () => _openDuplicateDialog(),
                    onBulkActions: _openBulkActionsDialog,
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // ==========================================
            // ROW 2: 5 METRIC CARDS
            // ==========================================
            CategoriesMetricsRow(
              totalCategories: _allItems.length,
              activeCategories: activeCount,
              draftCategories: draftCount,
              archivedCategories: archivedCount,
              totalSubjects: totalSubjects > 0 ? totalSubjects : 128,
            ),

            const SizedBox(height: 16),

            // ==========================================
            // ROW 3: CATEGORIES LIST TABLE + RIGHT ANALYTICS
            // ==========================================
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Table
                  Expanded(
                    child: CategoriesTableCard(
                      items: _paginatedItems,
                      totalCount: _filteredItems.length,
                      selectedIds: _selectedIds,
                      onSelectionChanged: (ids) => setState(() {
                        _selectedIds.clear();
                        _selectedIds.addAll(ids);
                      }),
                      searchQuery: _searchQuery,
                      onSearchChanged: (q) => setState(() {
                        _searchQuery = q;
                        _currentPage = 1;
                      }),
                      sortOption: _sortOption,
                      onSortChanged: (s) => setState(() => _sortOption = s),
                      statusFilter: _statusFilter,
                      onStatusFilterChanged: (f) => setState(() {
                        _statusFilter = f;
                        _currentPage = 1;
                      }),
                      currentPage: _currentPage,
                      pageSize: _pageSize,
                      onPageChanged: (p) => setState(() => _currentPage = p),
                      onPageSizeChanged: (sz) => setState(() {
                        _pageSize = sz;
                        _currentPage = 1;
                      }),
                      onView: _openViewDialog,
                      onEdit: _openCreateDialog,
                      onDuplicate: _openDuplicateDialog,
                      onDelete: _deleteCategory,
                      onToggleStatus: _toggleCategoryStatus,
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
                              const SnackBar(content: Text('Displaying all category activity logs.')),
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
                  CategoriesTableCard(
                    items: _paginatedItems,
                    totalCount: _filteredItems.length,
                    selectedIds: _selectedIds,
                    onSelectionChanged: (ids) => setState(() {
                      _selectedIds.clear();
                      _selectedIds.addAll(ids);
                    }),
                    searchQuery: _searchQuery,
                    onSearchChanged: (q) => setState(() {
                      _searchQuery = q;
                      _currentPage = 1;
                    }),
                    sortOption: _sortOption,
                    onSortChanged: (s) => setState(() => _sortOption = s),
                    statusFilter: _statusFilter,
                    onStatusFilterChanged: (f) => setState(() {
                      _statusFilter = f;
                      _currentPage = 1;
                    }),
                    currentPage: _currentPage,
                    pageSize: _pageSize,
                    onPageChanged: (p) => setState(() => _currentPage = p),
                    onPageSizeChanged: (sz) => setState(() {
                      _pageSize = sz;
                      _currentPage = 1;
                    }),
                    onView: _openViewDialog,
                    onEdit: _openCreateDialog,
                    onDuplicate: _openDuplicateDialog,
                    onDelete: _deleteCategory,
                    onToggleStatus: _toggleCategoryStatus,
                  ),
                  const SizedBox(height: 14),
                  const CategoryWiseTestsDonutCard(),
                  const SizedBox(height: 14),
                  const TopCategoriesBarChartCard(),
                  const SizedBox(height: 14),
                  CategoryRecentActivityCard(
                    onViewAll: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Displaying all category activity logs.')),
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
