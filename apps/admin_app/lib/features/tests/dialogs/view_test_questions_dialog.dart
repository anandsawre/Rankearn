import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
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

    // Fallback: Generate contextual realistic sample questions if DB has no records yet
    if (!mounted) return;
    setState(() {
      _questions = _generateFallbackQuestions();
      _isLoading = false;
    });
  }

  List<QuestionItem> _generateFallbackQuestions() {
    final sub = widget.item.subject;
    final title = widget.item.title;

    return [
      QuestionItem(
        id: 'q-demo-1',
        questionNumber: 1,
        questionText: 'What is the primary objective of $title?',
        questionTextHindi: '$title का प्राथमिक उद्देश्य क्या है?',
        subject: sub,
        testSeriesTitle: title,
        testId: widget.item.id,
        difficulty: QuestionDifficulty.easy,
        correctAnswerIndex: 0,
        correctAnswerChar: 'A',
        options: const [
          QuestionOptionItem(label: 'A', text: 'To assess conceptual clarity and exam-readiness.'),
          QuestionOptionItem(label: 'B', text: 'To memorize facts without practical reasoning.'),
          QuestionOptionItem(label: 'C', text: 'To focus exclusively on negative marking.'),
          QuestionOptionItem(label: 'D', text: 'None of the above options.'),
        ],
        explanation: 'Test series are structured to enhance accuracy, time management, and conceptual mastery.',
        marks: 1.0,
        negativeMarks: 0.25,
        status: QuestionStatus.published,
        createdAt: DateTime.now(),
        usageCount: 142,
      ),
      QuestionItem(
        id: 'q-demo-2',
        questionNumber: 2,
        questionText: 'Which law or principle governs the core analytical framework of $sub?',
        questionTextHindi: '$sub के विश्लेषणात्मक ढांचे को कौन सा सिद्धांत नियंत्रित करता है?',
        subject: sub,
        testSeriesTitle: title,
        testId: widget.item.id,
        difficulty: QuestionDifficulty.medium,
        correctAnswerIndex: 1,
        correctAnswerChar: 'B',
        options: const [
          QuestionOptionItem(label: 'A', text: 'Empirical Trial & Error model'),
          QuestionOptionItem(label: 'B', text: 'Standard syllabus framework and foundational rules'),
          QuestionOptionItem(label: 'C', text: 'Randomized probabilistic distribution'),
          QuestionOptionItem(label: 'D', text: 'Non-deterministic qualitative matrix'),
        ],
        explanation: 'Core questions are calibrated according to the official curriculum and historical paper patterns.',
        marks: 1.0,
        negativeMarks: 0.25,
        status: QuestionStatus.published,
        createdAt: DateTime.now(),
        usageCount: 98,
      ),
      QuestionItem(
        id: 'q-demo-3',
        questionNumber: 3,
        questionText: 'In high-yield competitive assessments, what is the best strategy for solving multi-step questions?',
        questionTextHindi: 'प्रतियोगी परीक्षाओं में बहु-चरणीय प्रश्नों को हल करने की सर्वोत्तम रणनीति क्या है?',
        subject: sub,
        testSeriesTitle: title,
        testId: widget.item.id,
        difficulty: QuestionDifficulty.hard,
        correctAnswerIndex: 2,
        correctAnswerChar: 'C',
        options: const [
          QuestionOptionItem(label: 'A', text: 'Guessing immediately based on intuition.'),
          QuestionOptionItem(label: 'B', text: 'Skipping all medium difficulty problems entirely.'),
          QuestionOptionItem(label: 'C', text: 'Eliminating impossible options and calculating systematically.'),
          QuestionOptionItem(label: 'D', text: 'Spending over 5 minutes per question in round one.'),
        ],
        explanation: 'Elimination of implausible distractors improves probability of accurate scoring significantly.',
        marks: 2.0,
        negativeMarks: 0.50,
        status: QuestionStatus.published,
        createdAt: DateTime.now(),
        usageCount: 65,
      ),
    ];
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
    showDialog(
      context: context,
      builder: (ctx) => CreateQuestionDialog(
        initialItem: itemToEdit,
        initialTestSeriesTitle: widget.item.title,
        initialTestId: widget.item.id,
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
              // 1. Ensure test exists in tests table without invalid foreign keys
              try {
                await client.from('tests').upsert(widget.item.toMap());
              } catch (e) {
                debugPrint('Parent test upsert notice: $e');
              }

              // 2. Attach test_id to all imported questions
              final payload = importedQuestions.map((q) {
                final m = q.toMap();
                m['test_id'] = widget.item.id;
                return m;
              }).toList();

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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    if (isMobile) {
      return Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: widget.item.iconColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Icon(widget.item.icon, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF101A3A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${widget.item.subject} • ${_questions.length} Questions',
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(34, 34),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                  tooltip: 'Import Questions',
                  onPressed: () => _openImportQuestionsDialog(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF5636F5),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(34, 34),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  tooltip: 'Add Question',
                  onPressed: () => _openAddQuestionDialog(),
                ),
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 12),
                          onChanged: (val) => setState(() => _searchQuery = val.trim()),
                          decoration: InputDecoration(
                            hintText: 'Search questions...',
                            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            prefixIcon: const Icon(Icons.search_rounded, size: 16, color: Color(0xFF94A3B8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            isDense: true,
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF5636F5))),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDifficulty,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                          items: ['All', 'Easy', 'Medium', 'Hard', 'Expert']
                              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDifficulty = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF5636F5)))
                    : _filteredQuestions.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                            itemCount: _filteredQuestions.length,
                            separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                            itemBuilder: (ctx, i) => _buildQuestionCard(_filteredQuestions[i], i + 1),
                          ),
              ),
            ],
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: (MediaQuery.of(context).size.height * 0.90).clamp(450.0, 720.0),
        ),
        child: Container(
          width: 720,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: widget.item.iconColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Icon(widget.item.icon, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.item.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF101A3A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_questions.length} Questions',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF5636F5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.item.subject} • Question Bank Review',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Search & Filter Toolbar + Questions List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Search & Filter Toolbar
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(fontSize: 12),
                                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                                decoration: InputDecoration(
                                  hintText: 'Search questions, options, or explanations...',
                                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
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
                                  isDense: true,
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF5636F5)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Difficulty Dropdown
                          Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedDifficulty,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                                style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                                items: ['All', 'Easy', 'Medium', 'Hard', 'Expert']
                                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
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
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Footer Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${_filteredQuestions.length} of ${_questions.length} questions',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            side: const BorderSide(color: Color(0xFF10B981)),
                            foregroundColor: const Color(0xFF059669),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                          label: const Text(
                            'Import Questions',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          onPressed: () => _openImportQuestionsDialog(),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5636F5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.post_add_rounded, size: 16),
                          label: const Text(
                            'Add Question',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          onPressed: () => _openAddQuestionDialog(),
                        ),
                      ],
                    ),
                  ],
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
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5636F5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              icon: const Icon(Icons.post_add_rounded, size: 16),
              label: const Text('Add First Question', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              onPressed: () => _openAddQuestionDialog(),
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
