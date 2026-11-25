import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import '../models/test_series_item.dart';
import '../../questions/models/question_item.dart';
import '../../questions/dialogs/create_question_dialog.dart';
import '../../questions/dialogs/import_questions_dialog.dart';

/// Dialog to view, search, and manage all questions belonging to a specific Test Series.
/// Strictly follows the centralized Rankearn Design System (AlertDialog, tokens, and button styles).
class ViewTestQuestionsDialog extends StatefulWidget {
  final TestSeriesItem item;
  final VoidCallback? onQuestionsUpdated;

  const ViewTestQuestionsDialog({
    super.key,
    required this.item,
    this.onQuestionsUpdated,
  });

  @override
  State<ViewTestQuestionsDialog> createState() => _ViewTestQuestionsDialogState();
}

class _ViewTestQuestionsDialogState extends State<ViewTestQuestionsDialog> {
  bool _isLoading = true;
  List<QuestionItem> _questions = [];
  String _searchQuery = '';
  String _selectedDifficulty = 'All';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);

    final client = SupabaseConfig.clientSafe;
    if (client != null) {
      try {
        final res = await client
            .from('questions')
            .select()
            .eq('test_id', widget.item.id)
            .order('question_number', ascending: true);

        if (res.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            _questions = res
                .asMap()
                .entries
                .map((e) => QuestionItem.fromMap(e.value, e.key + 1))
                .toList();
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        debugPrint('Supabase fetch questions for test error: $e');
      }
    }

    // If DB has no questions for this test yet, show empty state instead of fake dummy questions
    if (!mounted) return;
    setState(() {
      _questions = [];
      _isLoading = false;
    });
  }



  List<QuestionItem> get _filteredQuestions {
    return _questions.where((q) {
      if (_selectedDifficulty != 'All') {
        if (q.difficulty.label.toLowerCase() != _selectedDifficulty.toLowerCase()) {
          return false;
        }
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchQ = q.questionText.toLowerCase().contains(query);
        final matchHindi = q.questionTextHindi?.toLowerCase().contains(query) ?? false;
        final matchOpt = q.options.any((o) => o.text.toLowerCase().contains(query));
        final matchExp = q.explanation?.toLowerCase().contains(query) ?? false;
        if (!matchQ && !matchHindi && !matchOpt && !matchExp) return false;
      }

      return true;
    }).toList();
  }

  void _openAddQuestionDialog([QuestionItem? itemToEdit]) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => CreateQuestionDialog(
        initialItem: itemToEdit,
        initialTestSeriesTitle: widget.item.title,
        initialTestId: widget.item.id,
        onBulkSave: (importedQuestions) {
          final itemsToStore = importedQuestions.map((q) {
            return (q.testId != null && q.testId!.isNotEmpty)
                ? q
                : q.copyWith(testId: widget.item.id);
          }).toList();

          setState(() {
            _questions.insertAll(0, itemsToStore);
          });

          widget.onQuestionsUpdated?.call();
        },
        onSave: (savedQuestion) async {
          final questionToStore = (savedQuestion.testId != null && savedQuestion.testId!.isNotEmpty)
              ? savedQuestion
              : savedQuestion.copyWith(testId: widget.item.id);

          setState(() {
            final idx = _questions.indexWhere((q) => q.id == questionToStore.id);
            if (idx >= 0) {
              _questions[idx] = questionToStore;
            } else {
              _questions.add(questionToStore);
            }
          });

          String? syncNotice;
          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            try {
              // 1. Ensure test exists in tests table so foreign key constraint passes
              try {
                await client.from('tests').upsert(widget.item.toMap());
              } catch (tErr) {
                debugPrint('Parent test upsert note: $tErr');
              }

              // 2. Ensure test_id is guaranteed non-null
              final questionMap = questionToStore.toMap();
              questionMap['test_id'] = widget.item.id;

              await client.from('questions').upsert(questionMap);
              await client.from('tests').update({
                'total_questions': _questions.length,
              }).eq('id', widget.item.id);
            } catch (e) {
              debugPrint('Supabase question save sync error: $e');
              if (e.toString().contains('42501') || e.toString().contains('row-level security')) {
                syncNotice = 'Saved locally! (Run Supabase RLS SQL migration to enable cloud sync)';
              } else if (e.toString().contains('23502') || e.toString().contains('test_id')) {
                syncNotice = 'Saved locally! (Run test_id DROP NOT NULL SQL migration in Supabase)';
              }
            }
          }

          widget.onQuestionsUpdated?.call();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  syncNotice ??
                      (itemToEdit != null
                          ? 'Question #${savedQuestion.questionNumber} updated successfully!'
                          : 'New question added to "${widget.item.title}"!'),
                ),
                backgroundColor: syncNotice != null ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
              ),
            );
          }
        },
      ),
    );
  }

  // --- IMPORT / COPY QUESTIONS FROM EXISTING TEST ---
  Future<void> _openImportFromExistingTestDialog() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database client not connected.')),
      );
      return;
    }

    // 1. Fetch all existing tests (excluding this one)
    List<Map<String, dynamic>> availableTests = [];
    try {
      final res = await client
          .from('tests')
          .select('id, title, category_id, total_questions, duration_minutes')
          .neq('id', widget.item.id)
          .order('created_at', ascending: false);
      availableTests = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('Error fetching tests for question import: $e');
    }

    if (!mounted) return;

    if (availableTests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No other tests found in database to import from.'),
          backgroundColor: Color(0xFFFF9F0A),
        ),
      );
      return;
    }

    String? selectedTestId = availableTests.first['id']?.toString();
    bool replaceExisting = false;
    int previewQuestionCount =
        (availableTests.first['total_questions'] as num?)?.toInt() ?? 0;

    await AppModalDialog.show(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selectedTest = availableTests.firstWhere(
            (t) => t['id']?.toString() == selectedTestId,
            orElse: () => availableTests.first,
          );

          return AppModalDialog(
            title: 'Add from Existing Test',
            subtitle: 'Bulk copy questions from another test series or mock test',
            iconData: Icons.copy_all_rounded,
            maxWidth: 520,
            actions: [
              AppModalDialog.cancelButton(ctx),
              AppModalDialog.primaryButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _copyQuestionsFromTest(
                    sourceTestId: selectedTestId!,
                    sourceTestTitle: selectedTest['title']?.toString() ?? 'Selected Test',
                    replaceExisting: replaceExisting,
                  );
                },
                child: const Text(
                  'Copy Questions Now',
                  style: TextStyle(
                    fontFamily: AppTypography.fontHeading,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select any existing test or mock set. All its questions will be automatically copied into this test.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 16),

                // Test Selection Dropdown
                const Text(
                  'Select Test to Copy From *',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                AppDropdown<String>(
                  value: selectedTestId,
                  items: availableTests.map((t) {
                    final tId = t['id']?.toString() ?? '';
                    final tTitle = t['title']?.toString() ?? 'Untitled Test';
                    final tCat = t['category_id']?.toString() ?? 'General';
                    final tQs = (t['total_questions'] as num?)?.toInt() ?? 0;
                    return AppDropdownItem<String>(
                      value: tId,
                      label: '$tTitle ($tCat • $tQs Questions)',
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedTestId = val;
                        final match = availableTests.firstWhere(
                          (t) => t['id']?.toString() == val,
                        );
                        previewQuestionCount =
                            (match['total_questions'] as num?)?.toInt() ?? 0;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF5636F5),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Selected test: "${selectedTest['title']}"\nQuestions to copy: $previewQuestionCount questions',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Replace vs Append Checkbox
                CheckboxListTile(
                  value: replaceExisting,
                  onChanged: (val) =>
                      setDialogState(() => replaceExisting = val ?? false),
                  title: const Text(
                    'Replace existing questions in this test',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'If checked, current questions will be removed before copying.',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                  ),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: const Color(0xFF5636F5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _copyQuestionsFromTest({
    required String sourceTestId,
    required String sourceTestTitle,
    required bool replaceExisting,
  }) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return;

    setState(() => _isLoading = true);

    try {
      final sourceQuestionsData = await client
          .from('questions')
          .select()
          .eq('test_id', sourceTestId)
          .order('question_number', ascending: true);

      if (sourceQuestionsData.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No questions found in "$sourceTestTitle" to copy.'),
              backgroundColor: const Color(0xFFFF9F0A),
            ),
          );
        }
        return;
      }

      if (replaceExisting) {
        await client.from('questions').delete().eq('test_id', widget.item.id);
        _questions.clear();
      }

      final startNum = _questions.length;
      final payload = <Map<String, dynamic>>[];

      for (int i = 0; i < sourceQuestionsData.length; i++) {
        final original = Map<String, dynamic>.from(sourceQuestionsData[i]);
        final newNum = startNum + i + 1;
        original['id'] =
            'q_${widget.item.id}_${DateTime.now().millisecondsSinceEpoch}_$newNum';
        original['test_id'] = widget.item.id;
        original['question_number'] = newNum;
        original['created_at'] = DateTime.now().toUtc().toIso8601String();
        payload.add(original);
      }

      await client.from('questions').upsert(payload);

      await client.from('tests').update({
        'total_questions': _questions.length + payload.length,
      }).eq('id', widget.item.id);

      await _loadQuestions();
      widget.onQuestionsUpdated?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully copied ${payload.length} questions from "$sourceTestTitle"!',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error copying questions: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy questions: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _openImportQuestionsDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ImportQuestionsDialog(
        onImport: (importedQuestions) async {
          if (importedQuestions.isEmpty) return;

          setState(() {
            _questions.insertAll(0, importedQuestions);
          });

          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            try {
              // 1. Ensure test exists in tests table without invalid foreign keys
              try {
                await client.from('tests').upsert(widget.item.toMap());
              } catch (e) {
                debugPrint('Parent test upsert notice: $e');
              }

              // 2. Attach test_id and ensure strictly unique IDs and sequential question numbers
              final seenIds = <String>{};
              final currentMaxNumber = _questions.fold<int>(0, (max, q) => q.questionNumber > max ? q.questionNumber : max);
              final payload = <Map<String, dynamic>>[];

              for (int i = 0; i < importedQuestions.length; i++) {
                final m = importedQuestions[i].toMap();
                m['test_id'] = widget.item.id;

                String qId = m['id']?.toString() ?? '';
                if (qId.isEmpty || seenIds.contains(qId)) {
                  qId = 'q_${DateTime.now().microsecondsSinceEpoch}_${i + 1}_${math.Random().nextInt(999999)}';
                  m['id'] = qId;
                }
                seenIds.add(qId);
                m['question_number'] = currentMaxNumber + i + 1;
                payload.add(m);
              }

              await client.from('questions').upsert(payload);

              // 3. Update test's total questions
              try {
                await client.from('tests').update({
                  'total_questions': _questions.length,
                }).eq('id', widget.item.id);
              } catch (_) {}
            } catch (e) {
              debugPrint('Error importing questions into test: $e');
            }
          }

          widget.onQuestionsUpdated?.call();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully imported ${importedQuestions.length} questions into "${widget.item.title}"!'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
        },
      ),
    );
  }

  void _deleteQuestion(QuestionItem question) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => AppModalDialog(
        title: 'Delete Question',
        subtitle: 'Question #${question.questionNumber}',
        iconData: Icons.delete_outline_rounded,
        gradientColors: const [Color(0xFFDC2626), Color(0xFFEF4444)],
        maxWidth: 420,
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() {
                _questions.removeWhere((q) => q.id == question.id);
              });

              final client = SupabaseConfig.clientSafe;
              if (client != null) {
                try {
                  await client.from('questions').delete().eq('id', question.id);
                  await client.from('tests').update({
                    'total_questions': _questions.length,
                  }).eq('id', widget.item.id);
                } catch (e) {
                  debugPrint('Supabase delete question sync error: $e');
                }
              }

              widget.onQuestionsUpdated?.call();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Question #${question.questionNumber} deleted.'),
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
        child: Text(
          'Are you sure you want to delete Question #${question.questionNumber}? This action cannot be undone.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.45),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: widget.item.title,
      subtitle: '${widget.item.subject} • ${_questions.length} Questions',
      iconData: widget.item.icon,
      gradientColors: const [Color(0xFF1E1B4B), Color(0xFF4338CA)],
      maxWidth: 880,
      maxHeight: 740,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Close',
            style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            side: const BorderSide(color: Color(0xFF6366F1)),
            foregroundColor: const Color(0xFF4F46E5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: const Icon(Icons.copy_all_rounded, size: 15),
          label: const Text(
            'Add from Existing Test',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          onPressed: () => _openImportFromExistingTestDialog(),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            side: const BorderSide(color: Color(0xFF10B981)),
            foregroundColor: const Color(0xFF059669),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: const Icon(Icons.cloud_upload_rounded, size: 15),
          label: const Text(
            'Import Questions',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          onPressed: () => _openImportQuestionsDialog(),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9500),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          icon: const Icon(Icons.post_add_rounded, size: 15),
          label: const Text(
            'Add Question',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          onPressed: () => _openAddQuestionDialog(),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search & Filter Toolbar
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 12),
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: AppModalDialog.inputDecoration(
                      'Search questions, options, or explanations...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 16, color: Color(0xFF94A3B8)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      focusColor: const Color(0xFF5636F5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Difficulty Dropdown
              SizedBox(
                width: 170,
                child: AppDropdown<String>(
                  value: _selectedDifficulty,
                  items: const [
                    AppDropdownItem(value: 'All', label: 'All Difficulties'),
                    AppDropdownItem(value: 'Easy', label: 'Easy'),
                    AppDropdownItem(value: 'Medium', label: 'Medium'),
                    AppDropdownItem(value: 'Hard', label: 'Hard'),
                    AppDropdownItem(value: 'Expert', label: 'Expert'),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDifficulty = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Questions List Body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF5636F5)))
                : _filteredQuestions.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: _filteredQuestions.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) => _buildQuestionCard(_filteredQuestions[i], i + 1),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E7FF)),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.quiz_outlined, size: 26, color: Color(0xFF5636F5)),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No questions matched "$_searchQuery"'
                  : 'No questions added to this test series yet.',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Add your first question to populate this test series.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5636F5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  icon: const Icon(Icons.post_add_rounded, size: 16),
                  label: const Text('Add Question', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  onPressed: () => _openAddQuestionDialog(),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4F46E5),
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  icon: const Icon(Icons.copy_all_rounded, size: 16),
                  label: const Text('Add Existing Test', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  onPressed: () => _openImportFromExistingTestDialog(),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    side: const BorderSide(color: Color(0xFF10B981)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                  label: const Text('Import Questions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  onPressed: () => _openImportQuestionsDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuestionItem question, int displayIndex) {
    Color diffBg;
    Color diffText;
    switch (question.difficulty) {
      case QuestionDifficulty.easy:
        diffBg = const Color(0xFFDCFCE7);
        diffText = const Color(0xFF16A34A);
        break;
      case QuestionDifficulty.medium:
        diffBg = const Color(0xFFFEF3C7);
        diffText = const Color(0xFFD97706);
        break;
      case QuestionDifficulty.hard:
        diffBg = const Color(0xFFFFE4E6);
        diffText = const Color(0xFFE11D48);
        break;
      case QuestionDifficulty.expert:
        diffBg = const Color(0xFFF3E8FF);
        diffText = const Color(0xFF9333EA);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Top Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF5636F5).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q$displayIndex',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5636F5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: diffBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  question.difficulty.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: diffText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${question.marks} / -${question.negativeMarks}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const Spacer(),
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                tooltip: 'Edit Question',
                onPressed: () => _openAddQuestionDialog(question),
              ),
              const SizedBox(width: 4),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                tooltip: 'Delete Question',
                onPressed: () => _deleteQuestion(question),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Question Text (English)
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              height: 1.35,
            ),
          ),

          // Question Text (Hindi - if present)
          if (question.questionTextHindi != null && question.questionTextHindi!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'हिन्दी',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.questionTextHindi!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF334155),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),

          // 4 Options Grid/Column
          ...question.options.asMap().entries.map((entry) {
            final optIndex = entry.key;
            final opt = entry.value;
            final isCorrect = (question.correctAnswerIndex == optIndex) ||
                (question.correctAnswerChar.toUpperCase() == opt.label.toUpperCase());

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                    width: isCorrect ? 1.2 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        opt.label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isCorrect ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        opt.text,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isCorrect ? FontWeight.w700 : FontWeight.w500,
                          color: isCorrect ? const Color(0xFF15803D) : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    if (isCorrect) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF16A34A)),
                    ],
                  ],
                ),
              ),
            );
          }),

          // Explanation Box (if present)
          if (question.explanation != null && question.explanation!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, size: 15, color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Explanation: ${question.explanation}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF92400E),
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
