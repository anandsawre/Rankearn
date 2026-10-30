import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import '../models/tournament_item.dart';
import '../../questions/models/question_item.dart';
import '../../questions/dialogs/create_question_dialog.dart';
import '../../questions/dialogs/import_questions_dialog.dart';

/// Production-ready Dialog to View, Manage, and Add Questions to a Tournament,
/// including importing all questions from any existing test series/mock test.
class TournamentQuestionsDialog extends StatefulWidget {
  final TournamentItem tournament;
  final VoidCallback? onQuestionsUpdated;

  const TournamentQuestionsDialog({
    super.key,
    required this.tournament,
    this.onQuestionsUpdated,
  });

  @override
  State<TournamentQuestionsDialog> createState() => _TournamentQuestionsDialogState();
}

class _TournamentQuestionsDialogState extends State<TournamentQuestionsDialog> {
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
            .eq('test_id', widget.tournament.id)
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
        debugPrint('Supabase fetch tournament questions error: $e');
      }
    }

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

  // --- 1. Manual Add / Edit Question Dialog ---
  void _openAddQuestionDialog([QuestionItem? itemToEdit]) {
    showDialog(
      context: context,
      builder: (ctx) => CreateQuestionDialog(
        initialItem: itemToEdit,
        initialTestSeriesTitle: widget.tournament.title,
        initialTestId: widget.tournament.id,
        onBulkSave: (importedQuestions) {
          final itemsToStore = importedQuestions.map((q) {
            return (q.testId != null && q.testId!.isNotEmpty)
                ? q
                : q.copyWith(testId: widget.tournament.id);
          }).toList();

          setState(() {
            _questions.insertAll(0, itemsToStore);
          });

          widget.onQuestionsUpdated?.call();
        },
        onSave: (savedQuestion) async {
          final questionToStore = (savedQuestion.testId != null && savedQuestion.testId!.isNotEmpty)
              ? savedQuestion
              : savedQuestion.copyWith(testId: widget.tournament.id);

          setState(() {
            final idx = _questions.indexWhere((q) => q.id == questionToStore.id);
            if (idx >= 0) {
              _questions[idx] = questionToStore;
            } else {
              _questions.add(questionToStore);
            }
          });

          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            try {
              final questionMap = questionToStore.toMap();
              questionMap['test_id'] = widget.tournament.id;

              await client.from('questions').upsert(questionMap);
              await client.from('tests').update({
                'total_questions': _questions.length,
              }).eq('id', widget.tournament.id);
            } catch (e) {
              debugPrint('Supabase question save sync error: $e');
            }
          }

          widget.onQuestionsUpdated?.call();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  itemToEdit != null
                      ? 'Question #${savedQuestion.questionNumber} updated successfully!'
                      : 'New question added to "${widget.tournament.title}"!',
                ),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
        },
      ),
    );
  }

  // --- 2. Bulk Upload Questions (CSV / Excel) ---
  void _openImportQuestionsDialog() {
    showDialog(
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
              final seenIds = <String>{};
              final currentMaxNumber = _questions.fold<int>(0, (max, q) => q.questionNumber > max ? q.questionNumber : max);
              final payload = <Map<String, dynamic>>[];

              for (int i = 0; i < importedQuestions.length; i++) {
                final m = importedQuestions[i].toMap();
                m['test_id'] = widget.tournament.id;

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
              await client.from('tests').update({
                'total_questions': _questions.length,
              }).eq('id', widget.tournament.id);
            } catch (e) {
              debugPrint('Error importing CSV questions into tournament: $e');
            }
          }

          widget.onQuestionsUpdated?.call();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully imported ${importedQuestions.length} questions into "${widget.tournament.title}"!'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          }
        },
      ),
    );
  }

  // --- 3. IMPORT / COPY QUESTIONS FROM EXISTING TEST ---
  Future<void> _openImportFromExistingTestDialog() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database not connected.'), backgroundColor: Colors.red),
      );
      return;
    }

    // 1. Fetch all existing tests (practice tests, test series, mocks, excluding this tournament)
    List<Map<String, dynamic>> availableTests = [];
    try {
      final res = await client
          .from('tests')
          .select('id, title, category_id, total_questions, duration_minutes, is_tournament')
          .neq('id', widget.tournament.id)
          .order('created_at', ascending: false);
      availableTests = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('Error fetching tests for question import: $e');
    }

    if (!mounted) return;

    if (availableTests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other tests found in database to import from.'), backgroundColor: Color(0xFFFF9F0A)),
      );
      return;
    }

    String? selectedTestId = availableTests.first['id']?.toString();
    bool replaceExisting = false;
    int previewQuestionCount = (availableTests.first['total_questions'] as num?)?.toInt() ?? 0;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selectedTest = availableTests.firstWhere(
            (t) => t['id']?.toString() == selectedTestId,
            orElse: () => availableTests.first,
          );

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.copy_all_rounded, color: Color(0xFF5636F5)),
                SizedBox(width: 10),
                Text('Add from Existing Test', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            content: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select any existing test or mock set. All its questions will be automatically copied into this tournament.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Test Selection Dropdown
                  const Text('Select Test to Copy From *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedTestId,
                        isExpanded: true,
                        items: availableTests.map((t) {
                          final tId = t['id']?.toString() ?? '';
                          final tTitle = t['title']?.toString() ?? 'Untitled Test';
                          final tCat = t['category_id']?.toString() ?? 'General';
                          final tQs = (t['total_questions'] as num?)?.toInt() ?? 0;
                          return DropdownMenuItem<String>(
                            value: tId,
                            child: Text(
                              '$tTitle ($tCat • $tQs Questions)',
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedTestId = val;
                              final match = availableTests.firstWhere((t) => t['id']?.toString() == val);
                              previewQuestionCount = (match['total_questions'] as num?)?.toInt() ?? 0;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F0FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDDD6FE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xFF6B4EFF), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Selected test: "${selectedTest['title']}"\nQuestions to copy: $previewQuestionCount questions',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF5636F5), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Replace vs Append Checkbox
                  CheckboxListTile(
                    value: replaceExisting,
                    onChanged: (val) => setDialogState(() => replaceExisting = val ?? false),
                    title: const Text('Replace existing questions in this tournament', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    subtitle: const Text('If checked, current questions of this tournament will be removed before importing.', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF5636F5),
                  ),
                ],
              ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _copyQuestionsFromTest(
                    sourceTestId: selectedTestId!,
                    sourceTestTitle: selectedTest['title']?.toString() ?? 'Selected Test',
                    replaceExisting: replaceExisting,
                  );
                },
                child: const Text('Copy Questions Now'),
              ),
            ],
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
      // 1. Fetch questions from source test
      final sourceQuestionsData = await client
          .from('questions')
          .select()
          .eq('test_id', sourceTestId)
          .order('question_number', ascending: true);

      if (sourceQuestionsData.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No questions found in "$sourceTestTitle" to copy.'), backgroundColor: const Color(0xFFFF9F0A)),
          );
        }
        return;
      }

      // 2. If replace requested, delete existing questions for this tournament
      if (replaceExisting) {
        await client.from('questions').delete().eq('test_id', widget.tournament.id);
        _questions.clear();
      }

      // 3. Prepare payload with new unique IDs and test_id = tournament.id
      final currentMaxNumber = _questions.fold<int>(0, (max, q) => q.questionNumber > max ? q.questionNumber : max);
      final payload = <Map<String, dynamic>>[];

      for (int i = 0; i < sourceQuestionsData.length; i++) {
        final original = Map<String, dynamic>.from(sourceQuestionsData[i]);
        final newId = 'q_tour_${widget.tournament.id}_${DateTime.now().millisecondsSinceEpoch}_${i + 1}_${math.Random().nextInt(999999)}';

        original['id'] = newId;
        original['test_id'] = widget.tournament.id;
        original['question_number'] = currentMaxNumber + i + 1;
        original['created_at'] = DateTime.now().toUtc().toIso8601String();

        payload.add(original);
      }

      // 4. Batch insert into questions
      await client.from('questions').upsert(payload);

      // 5. Update tests.total_questions
      final newTotal = _questions.length + payload.length;
      await client.from('tests').update({
        'total_questions': newTotal,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', widget.tournament.id);

      // 6. Reload questions
      await _loadQuestions();

      widget.onQuestionsUpdated?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully copied ${payload.length} questions from "$sourceTestTitle" into tournament!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error copying questions: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to copy questions: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _deleteQuestion(QuestionItem question) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Question', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('Are you sure you want to delete Question #${question.questionNumber}?'),
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
                _questions.removeWhere((q) => q.id == question.id);
              });

              final client = SupabaseConfig.clientSafe;
              if (client != null) {
                try {
                  await client.from('questions').delete().eq('id', question.id);
                  await client.from('tests').update({
                    'total_questions': _questions.length,
                  }).eq('id', widget.tournament.id);
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredQuestions;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1040,
          maxHeight: 750,
          minWidth: 700,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.tournament.thumbnailBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(widget.tournament.thumbnailIcon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.tournament.title,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.tournament.category,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_questions.length} Questions Attached • Entry Fee: ${widget.tournament.entryFee} Coins • Prize: ₹${widget.tournament.prizePool}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons in Header
                  Wrap(
                    spacing: 8,
                    children: [
                      // IMPORT FROM EXISTING TEST BUTTON (STAR FEATURE)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5636F5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.copy_all_rounded, size: 16),
                        label: const Text('Add Existing Test', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        onPressed: _openImportFromExistingTestDialog,
                      ),

                      // Manual Add Question Button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF5636F5),
                          side: const BorderSide(color: Color(0xFF5636F5)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('New Question', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        onPressed: () => _openAddQuestionDialog(),
                      ),

                      // Import CSV / Excel Button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.upload_file_rounded, size: 16),
                        label: const Text('Import CSV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        onPressed: _openImportQuestionsDialog,
                      ),

                      // Close Dialog
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                        splashRadius: 18,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFE2E8F0)),

              // 2. Search & Filter Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Search questions by text, explanation, or options...',
                          hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.search_rounded, size: 17, color: AppColors.textSecondary),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Difficulty Filter
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDifficulty,
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                        items: const ['All', 'Easy', 'Medium', 'Hard', 'Expert']
                            .map((d) => DropdownMenuItem(value: d, child: Text('$d Difficulty')))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDifficulty = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3. Questions List / Empty State / Loader
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF5636F5)))
                    : filtered.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final q = filtered[index];
                              return _buildQuestionCard(q);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FF),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.quiz_outlined, size: 32, color: Color(0xFF5636F5)),
          ),
          const SizedBox(height: 14),
          Text(
            _searchQuery.isNotEmpty ? 'No questions match your search' : 'No questions attached to this tournament yet',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'You can add questions from an existing test, create one manually, or import from CSV.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5636F5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.copy_all_rounded, size: 16),
            label: const Text('Add from Existing Test', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            onPressed: _openImportFromExistingTestDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionItem q) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF5636F5),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Q${q.questionNumber}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              _buildDifficultyChip(q.difficulty),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF2563EB)),
                tooltip: 'Edit Question',
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                onPressed: () => _openAddQuestionDialog(q),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                tooltip: 'Delete Question',
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                onPressed: () => _deleteQuestion(q),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Question Text
          Text(
            q.questionText,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.35),
          ),
          if (q.questionTextHindi != null && q.questionTextHindi!.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              q.questionTextHindi!,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w400, color: Color(0xFF475569)),
            ),
          ],
          const SizedBox(height: 10),

          // Options Grid
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: q.options.asMap().entries.map((entry) {
              final idx = entry.key;
              final opt = entry.value;
              final isCorrect = (idx == q.correctAnswerIndex);

              return Container(
                constraints: const BoxConstraints(minWidth: 180, maxWidth: 450),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isCorrect ? const Color(0xFFECFDF5) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                    width: isCorrect ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: isCorrect ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                      child: Text(
                        opt.label,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isCorrect ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        opt.text,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w400,
                          color: isCorrect ? const Color(0xFF065F46) : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCorrect) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF10B981)),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),

          // Explanation
          if (q.explanation != null && q.explanation!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, size: 14, color: Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Explanation: ${q.explanation}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF1E40AF), height: 1.3),
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

  Widget _buildDifficultyChip(QuestionDifficulty diff) {
    Color bg;
    Color fg;
    switch (diff) {
      case QuestionDifficulty.easy:
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        break;
      case QuestionDifficulty.medium:
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFD97706);
        break;
      case QuestionDifficulty.hard:
      case QuestionDifficulty.expert:
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFDC2626);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        diff.label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
