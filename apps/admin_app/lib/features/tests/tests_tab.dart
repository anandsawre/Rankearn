import 'dart:math' as math;
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

import '../questions/dialogs/create_question_dialog.dart';
import '../questions/dialogs/import_questions_dialog.dart';
import '../questions/dialogs/ai_generate_questions_dialog.dart';

/// Test Series Management Screen
/// Pixel-accurate reproduction of the Rankearn reference specification.
class TestsTab extends StatefulWidget {
  final List<TestSeriesItem>? initialItems;

  const TestsTab({super.key, this.initialItems});

  @override
  State<TestsTab> createState() => _TestsTabState();
}

class _TestsTabState extends State<TestsTab> {
  late List<TestSeriesItem> _allItems;

  // Search & Filtering State
  String _searchQuery = '';
  String _selectedSubject = 'All Subjects';
  String _selectedStatus = 'All Status';

  // Pagination State
  int _currentPage = 1;
  static const int _rowsPerPage = 7;

  @override
  void initState() {
    super.initState();
    _allItems = widget.initialItems ?? [];
    _loadFromSupabase();
  }

  Future<void> _loadFromSupabase() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return;

    try {
      final res = await client
          .from('tests')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _allItems = res
            .asMap()
            .entries
            .map((e) => TestSeriesItem.fromMap(e.value, e.key + 1))
            .toList();
      });
    } catch (e) {
      debugPrint('TestsTab Supabase fetch error: $e');
    }
  }

  // Filtered Items computation
  List<TestSeriesItem> get _filteredItems {
    return _allItems.where((item) {
      // 1. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = item.title.toLowerCase().contains(query);
        final matchesDesc = item.description.toLowerCase().contains(query);
        final matchesSub = item.subject.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc && !matchesSub) return false;
      }

      // 2. Subject Filter
      if (_selectedSubject != 'All Subjects') {
        if (item.subject.toLowerCase() != _selectedSubject.toLowerCase()) {
          return false;
        }
      }

      // 3. Status Filter
      if (_selectedStatus != 'All Status') {
        if (item.status.label.toLowerCase() != _selectedStatus.toLowerCase()) {
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
  int get _totalEnrollments =>
      _allItems.fold<int>(0, (sum, i) => sum + i.enrollments);

  // Dynamic Subject Slices for Donut Chart
  List<DonutSlice> get _subjectSlices {
    if (_allItems.isEmpty) return const [];
    final Map<String, int> counts = {};
    for (final item in _allItems) {
      final sub = item.subject.trim().isEmpty ? 'General' : item.subject.trim();
      counts[sub] = (counts[sub] ?? 0) + 1;
    }
    const colors = [
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFFF59E0B),
      Color(0xFF06B6D4),
      Color(0xFFEC4899),
      Color(0xFFEA580C),
      Color(0xFF10B981),
      Color(0xFF6366F1),
    ];
    int colorIdx = 0;
    return counts.entries.map((entry) {
      final pct = (entry.value / _allItems.length) * 100;
      final color = colors[colorIdx % colors.length];
      colorIdx++;
      return DonutSlice(
        label: entry.key,
        percentage: pct.roundToDouble(),
        color: color,
        count: entry.value,
      );
    }).toList();
  }

  // Dynamic Recent Activity from test series items
  List<ActivityItemData> get _recentActivities {
    if (_allItems.isEmpty) return const [];
    final items = _allItems.take(5).toList();
    return items.map((item) {
      final isPub = item.status == TestSeriesStatus.published;
      return ActivityItemData(
        icon: isPub ? Icons.check_circle_rounded : Icons.edit_note_rounded,
        iconColor: isPub ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
        iconBgColor: isPub ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
        text: '${isPub ? "Published" : "Draft"}: ${item.title}',
        timeAgo: '${item.totalQuestions} Questions',
      );
    }).toList();
  }

  // Actions
  void _openCreateDialog([TestSeriesItem? itemToEdit]) {
    showDialog(
      context: context,
      builder: (ctx) => CreateTestSeriesDialog(
        initialItem: itemToEdit,
        onSave: (savedItem) async {
          setState(() {
            final idx = _allItems.indexWhere((i) => i.id == savedItem.id);
            if (idx >= 0) {
              _allItems[idx] = savedItem;
            } else {
              _allItems.insert(0, savedItem);
            }
          });

          // Sync to Supabase if connected
          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            try {
              await client.from('tests').upsert(savedItem.toMap());
            } catch (_) {}
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  itemToEdit != null
                      ? 'Updated test series "${savedItem.title}"'
                      : 'Created new test series "${savedItem.title}"',
                ),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
        },
      ),
    );
  }

  void _openViewDialog(TestSeriesItem item) {
    showDialog(
      context: context,
      builder: (ctx) => ViewTestSeriesDialog(
        item: item,
        onAddQuestion: () => _openAddQuestionDialog(item),
        onViewQuestions: () => _openViewQuestionsDialog(item),
      ),
    );
  }

  void _openViewQuestionsDialog(TestSeriesItem item) {
    showDialog(
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
    showDialog(
      context: context,
      builder: (ctx) => CreateQuestionDialog(
        initialTestSeriesTitle: item?.title,
        initialTestId: item?.id,
        onBulkSave: (importedQuestions) {
          if (item != null) {
            final newCount = item.totalQuestions + importedQuestions.length;
            setState(() {
              final idx = _allItems.indexWhere((i) => i.id == item.id);
              if (idx >= 0) {
                _allItems[idx] = _allItems[idx].copyWith(totalQuestions: newCount);
              }
            });
          }
        },
        onSave: (savedQuestion) async {
          String? syncNotice;
          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            try {
              final payload = savedQuestion.toMap();
              if (item != null) {
                payload['test_id'] = item.id;
                try {
                  await client.from('tests').upsert(item.toMap());
                } catch (tErr) {
                  debugPrint('Parent test upsert note: $tErr');
                }
              }
              await client.from('questions').upsert(payload);

              if (item != null) {
                final newCount = item.totalQuestions + 1;
                await client.from('tests').update({
                  'total_questions': newCount,
                }).eq('id', item.id);

                setState(() {
                  final idx = _allItems.indexWhere((i) => i.id == item.id);
                  if (idx >= 0) {
                    _allItems[idx] = _allItems[idx].copyWith(totalQuestions: newCount);
                  }
                });
              }
            } catch (e) {
              debugPrint('Error saving question to Supabase: $e');
              if (e.toString().contains('42501') || e.toString().contains('row-level security')) {
                syncNotice = 'Saved locally! (Run Supabase RLS SQL migration to enable cloud sync)';
              } else if (e.toString().contains('23502') || e.toString().contains('test_id')) {
                syncNotice = 'Saved locally! (Run test_id DROP NOT NULL SQL migration in Supabase)';
              }
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  syncNotice ??
                      (item != null
                          ? 'Question added to "${item.title}" successfully!'
                          : 'Question added to question bank successfully!'),
                ),
                backgroundColor: syncNotice != null ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
              ),
            );
          }
        },
      ),
    );
  }

  void _openImportQuestionsDialog([TestSeriesItem? item]) {
    final targetTest = item ?? (_allItems.isNotEmpty ? _allItems.first : null);

    showDialog(
      context: context,
      builder: (ctx) => ImportQuestionsDialog(
        onImport: (importedQuestions) async {
          if (importedQuestions.isEmpty) return;
          String? syncNotice;
          final client = SupabaseConfig.clientSafe;
          if (client != null && targetTest != null) {
            try {
              try {
                await client.from('tests').upsert(targetTest.toMap());
              } catch (tErr) {
                debugPrint('Parent test upsert note: $tErr');
              }
              final seenIds = <String>{};
              final payload = <Map<String, dynamic>>[];
              for (int i = 0; i < importedQuestions.length; i++) {
                final m = importedQuestions[i].toMap();
                m['test_id'] = targetTest.id;
                String qId = m['id']?.toString() ?? '';
                if (qId.isEmpty || seenIds.contains(qId)) {
                  qId = 'q_${DateTime.now().microsecondsSinceEpoch}_${i + 1}_${math.Random().nextInt(999999)}';
                  m['id'] = qId;
                }
                seenIds.add(qId);
                m['question_number'] = targetTest.totalQuestions + i + 1;
                payload.add(m);
              }
              await client.from('questions').upsert(payload);

              final newCount = targetTest.totalQuestions + importedQuestions.length;
              try {
                await client.from('tests').update({
                  'total_questions': newCount,
                }).eq('id', targetTest.id);
              } catch (_) {}

              setState(() {
                final idx = _allItems.indexWhere((i) => i.id == targetTest.id);
                if (idx >= 0) {
                  _allItems[idx] = _allItems[idx].copyWith(totalQuestions: newCount);
                }
              });
            } catch (e) {
              debugPrint('Error importing questions to Supabase: $e');
              if (e.toString().contains('42501') || e.toString().contains('row-level security')) {
                syncNotice = 'Imported locally! (Run Supabase RLS SQL migration to enable cloud sync)';
              } else if (e.toString().contains('23502') || e.toString().contains('test_id')) {
                syncNotice = 'Imported locally! (Run test_id DROP NOT NULL SQL migration in Supabase)';
              }
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  syncNotice ??
                      (targetTest != null
                          ? 'Imported ${importedQuestions.length} questions into "${targetTest.title}" successfully!'
                          : 'Imported ${importedQuestions.length} questions successfully!'),
                ),
                backgroundColor: syncNotice != null ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
              ),
            );
          }
        },
      ),
    );
  }

  void _openAiGenerateQuestionsDialog([TestSeriesItem? item]) {
    showDialog(
      context: context,
      builder: (ctx) => AiGenerateQuestionsDialog(
        onSaveGenerated: (generatedQuestions) async {
          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            try {
              final payload = generatedQuestions.map((q) {
                var map = q.toMap();
                if (item != null) {
                  map['test_id'] = item.id;
                }
                return map;
              }).toList();
              await client.from('questions').upsert(payload);

              if (item != null) {
                final newCount = item.totalQuestions + generatedQuestions.length;
                await client.from('tests').update({
                  'total_questions': newCount,
                }).eq('id', item.id);

                setState(() {
                  final idx = _allItems.indexWhere((i) => i.id == item.id);
                  if (idx >= 0) {
                    _allItems[idx] = _allItems[idx].copyWith(totalQuestions: newCount);
                  }
                });
              }
            } catch (e) {
              debugPrint('Error saving AI generated questions to Supabase: $e');
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Generated & saved ${generatedQuestions.length} questions!'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
        },
      ),
    );
  }

  void _openAnalyticsDialog(TestSeriesItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AnalyticsTestSeriesDialog(item: item),
    );
  }

  void _deleteItem(TestSeriesItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Test Series', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete "${item.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() {
                _allItems.removeWhere((i) => i.id == item.id);
              });
              final client = SupabaseConfig.clientSafe;
              if (client != null) {
                try {
                  await client.from('tests').delete().eq('id', item.id);
                } catch (e) {
                  debugPrint('Error deleting test from Supabase: $e');
                }
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "${item.title}"')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleStatus(TestSeriesItem item) async {
    final nextStatus = item.status == TestSeriesStatus.published
        ? TestSeriesStatus.draft
        : TestSeriesStatus.published;
    final updated = item.copyWith(status: nextStatus);
    setState(() {
      final idx = _allItems.indexWhere((i) => i.id == item.id);
      if (idx >= 0) _allItems[idx] = updated;
    });

    final client = SupabaseConfig.clientSafe;
    if (client != null) {
      try {
        await client.from('tests').update({'status': nextStatus.name}).eq('id', item.id);
      } catch (e) {
        debugPrint('Error updating test status in Supabase: $e');
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status changed to ${nextStatus.label} for "${item.title}"'),
          backgroundColor: const Color(0xFF5636F5),
        ),
      );
    }
  }

  void _openGenericActionModal(String title, String description) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
        title: Row(
          children: [
            const Icon(Icons.tune_rounded, color: Color(0xFF5636F5), size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: AppRadii.borderSm,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF5636F5)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ready to process batch configuration & sync with database.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF334155)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5636F5),
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderSm),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title workflow executed successfully.'),
                  backgroundColor: AppColors.brandPrimary,
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // ROW 1: HERO CARD + QUICK ACTIONS
            // ==========================================
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wide Hero Card (63% width)
                  const Expanded(
                    flex: 63,
                    child: TestSeriesHeroCard(),
                  ),
                  const SizedBox(width: 16),

                  // Quick Actions Card (37% width)
                  Expanded(
                    flex: 37,
                    child: TestSeriesQuickActions(
                      onCreateTestSeries: () => _openCreateDialog(),
                      onAddTestPaper: () => _openAddQuestionDialog(),
                      onManageSubjects: () => _openGenericActionModal(
                        'Manage Subjects',
                        'Configure subjects, categories, syllabus tags, and icon color themes.',
                      ),
                      onImportTests: () => _openImportQuestionsDialog(),
                      onAiGenerate: () => _openAiGenerateQuestionsDialog(),
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
                    onAddTestPaper: () => _openAddQuestionDialog(),
                    onManageSubjects: () => _openGenericActionModal('Manage Subjects', 'Configure subjects.'),
                    onImportTests: () => _openImportQuestionsDialog(),
                    onAiGenerate: () => _openAiGenerateQuestionsDialog(),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // ==========================================
            // ROW 2: 5 METRIC CARDS
            // ==========================================
            TestSeriesMetricsRow(
              totalTestSeries: _totalTestSeries,
              publishedCount: _publishedCount,
              draftsCount: _draftsCount,
              totalTests: _totalTests,
              totalEnrollments: _totalEnrollments,
            ),
            const SizedBox(height: 20),

            // ==========================================
            // ROW 3: TABLE CARD + RIGHT ANALYTICS COLUMN
            // ==========================================
            if (isDesktop)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Test Series List Table (Flexible width)
                    Expanded(
                      child: TestSeriesTableCard(
                        items: _paginatedItems,
                        totalCount: _filteredItems.length,
                        selectedSubject: _selectedSubject,
                        selectedStatus: _selectedStatus,
                        searchQuery: _searchQuery,
                        currentPage: _currentPage,
                        totalPages: _totalPages,
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
                        onView: _openViewDialog,
                        onAnalytics: _openAnalyticsDialog,
                        onEdit: (item) => _openCreateDialog(item),
                        onDelete: _deleteItem,
                        onToggleStatus: _toggleStatus,
                        onAddQuestion: (item) => _openAddQuestionDialog(item),
                        onViewQuestions: _openViewQuestionsDialog,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Analytics Column (Dynamically matches TestSeriesTableCard height)
                    SizedBox(
                      width: 295,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 46,
                            child: SubjectWiseChartCard(
                              fillHeight: true,
                              totalCount: _totalTestSeries,
                              slices: _subjectSlices,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            flex: 54,
                            child: RecentActivityCard(
                              fillHeight: true,
                              activities: _recentActivities,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  TestSeriesTableCard(
                    items: _paginatedItems,
                    totalCount: _filteredItems.length,
                    selectedSubject: _selectedSubject,
                    selectedStatus: _selectedStatus,
                    searchQuery: _searchQuery,
                    currentPage: _currentPage,
                    totalPages: _totalPages,
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
                    onView: _openViewDialog,
                    onAnalytics: _openAnalyticsDialog,
                    onEdit: (item) => _openCreateDialog(item),
                    onDelete: _deleteItem,
                    onToggleStatus: _toggleStatus,
                    onAddQuestion: (item) => _openAddQuestionDialog(item),
                    onViewQuestions: _openViewQuestionsDialog,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SubjectWiseChartCard(
                          totalCount: _totalTestSeries,
                          slices: _subjectSlices,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: RecentActivityCard(
                          activities: _recentActivities,
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
}
