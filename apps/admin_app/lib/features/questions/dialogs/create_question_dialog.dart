import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import '../models/question_item.dart';
import 'import_questions_dialog.dart';

class CreateQuestionDialog extends StatefulWidget {
  final QuestionItem? initialItem;
  final String? initialTestSeriesTitle;
  final String? initialTestId;
  final ValueChanged<QuestionItem> onSave;
  final ValueChanged<List<QuestionItem>>? onBulkSave;

  const CreateQuestionDialog({
    super.key,
    this.initialItem,
    this.initialTestSeriesTitle,
    this.initialTestId,
    required this.onSave,
    this.onBulkSave,
  });

  @override
  State<CreateQuestionDialog> createState() => _CreateQuestionDialogState();
}

class _CreateQuestionDialogState extends State<CreateQuestionDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _questionTextController;
  late TextEditingController _questionTextHindiController;
  late TextEditingController _explanationController;
  late TextEditingController _marksController;
  late TextEditingController _negativeMarksController;

  late List<TextEditingController> _optionControllers;
  late int _selectedCorrectIndex;

  late String _selectedSubject;
  late String _selectedTestSeries;
  late String _selectedQuestionSet;
  late String _selectedType;
  late QuestionDifficulty _selectedDifficulty;
  late QuestionStatus _selectedStatus;

  bool _showPreview = false;

  final List<String> _subjects = ['General'];

  final List<String> _testSeriesList = ['Unassigned (General Bank)'];

  final Map<String, String> _testTitleToId = {};

  final List<String> _questionTypes = [
    'MCQ',
    'True/False',
    'Fill in the Blanks',
    'Match the Following',
    'Assertion & Reason',
    'Subjective',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;

    _questionTextController = TextEditingController(text: item?.questionText ?? '');
    _questionTextHindiController = TextEditingController(text: item?.questionTextHindi ?? '');
    _explanationController = TextEditingController(text: item?.explanation ?? '');
    _marksController = TextEditingController(text: item?.marks.toString() ?? '1.0');
    _negativeMarksController = TextEditingController(text: item?.negativeMarks.toString() ?? '0.25');

    final opts = item?.options ?? [];
    _optionControllers = List.generate(4, (i) {
      final txt = i < opts.length ? opts[i].text : '';
      return TextEditingController(text: txt);
    });

    _selectedCorrectIndex = item?.correctAnswerIndex ?? 0;

    final subj = item?.subject.trim();
    if (subj != null && subj.isNotEmpty) {
      if (!_subjects.contains(subj)) _subjects.insert(0, subj);
      _selectedSubject = subj;
    } else {
      _selectedSubject = _subjects.first;
    }

    final testTitle = widget.initialTestSeriesTitle?.trim() ?? item?.testSeriesTitle.replaceAll('\n', ' ').trim();
    if (testTitle != null && testTitle.isNotEmpty) {
      if (!_testSeriesList.contains(testTitle)) _testSeriesList.insert(0, testTitle);
      _selectedTestSeries = testTitle;
    } else {
      _selectedTestSeries = _testSeriesList.first;
    }

    if (widget.initialTestId != null && widget.initialTestId!.isNotEmpty) {
      _testTitleToId[_selectedTestSeries] = widget.initialTestId!;
    }

    _selectedQuestionSet = item?.questionSet ?? 'Set A';

    final qType = item?.questionType.trim();
    if (qType != null && qType.isNotEmpty) {
      if (!_questionTypes.contains(qType)) _questionTypes.add(qType);
      _selectedType = qType;
    } else {
      _selectedType = 'MCQ';
    }

    _selectedDifficulty = item?.difficulty ?? QuestionDifficulty.easy;
    _selectedStatus = item?.status ?? QuestionStatus.published;

    final client = SupabaseConfig.clientSafe;
    if (client != null) {
      Future.wait([
        client.from('tests').select('id, title').order('created_at', ascending: false),
        client.from('categories').select('name').order('display_order', ascending: true),
      ]).then((results) {
        if (!mounted) return;
        final testRows = results[0] as List;
        final catRows = results[1] as List;

        final fetchedTitles = <String>[];
        for (final r in testRows) {
          final tId = r['id']?.toString() ?? '';
          final tTitle = r['title']?.toString().trim() ?? '';
          if (tTitle.isNotEmpty) {
            fetchedTitles.add(tTitle);
            if (tId.isNotEmpty) {
              _testTitleToId[tTitle] = tId;
            }
          }
        }

        final fetchedSubjects = catRows
            .map((r) => r['name']?.toString().trim() ?? '')
            .where((n) => n.isNotEmpty)
            .toSet()
            .toList();

        setState(() {
          for (final t in fetchedTitles) {
            if (!_testSeriesList.contains(t)) _testSeriesList.add(t);
          }
          if (widget.initialTestSeriesTitle == null &&
              widget.initialItem == null &&
              fetchedTitles.isNotEmpty) {
            _selectedTestSeries = fetchedTitles.first;
          }
          for (final s in fetchedSubjects) {
            if (!_subjects.contains(s)) _subjects.add(s);
          }
          if (widget.initialItem == null && fetchedSubjects.isNotEmpty && _selectedSubject == 'General') {
            _selectedSubject = fetchedSubjects.first;
          }
        });
      }).catchError((_) {});
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _questionTextHindiController.dispose();
    _explanationController.dispose();
    _marksController.dispose();
    _negativeMarksController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final labels = ['A', 'B', 'C', 'D'];
    final options = List.generate(4, (i) {
      final txt = _optionControllers[i].text.trim();
      return QuestionOptionItem(
        label: labels[i],
        text: txt.isNotEmpty ? txt : 'Option ${labels[i]}',
      );
    });

    final defaultChar = _selectedCorrectIndex < labels.length ? labels[_selectedCorrectIndex] : 'A';
    final targetTestId = _selectedTestSeries == 'Unassigned (General Bank)'
        ? null
        : (widget.initialTestId ?? _testTitleToId[_selectedTestSeries] ?? widget.initialItem?.testId);

    final savedItem = QuestionItem(
      id: widget.initialItem?.id ?? 'q-${DateTime.now().millisecondsSinceEpoch}',
      questionNumber: widget.initialItem?.questionNumber ?? 1,
      questionText: _questionTextController.text.trim(),
      questionTextHindi: _questionTextHindiController.text.trim().isNotEmpty
          ? _questionTextHindiController.text.trim()
          : null,
      subject: _selectedSubject,
      testSeriesTitle: _selectedTestSeries,
      testId: targetTestId,
      questionSet: _selectedQuestionSet,
      questionType: _selectedType,
      difficulty: _selectedDifficulty,
      options: options,
      correctAnswerIndex: _selectedCorrectIndex,
      correctAnswerChar: defaultChar,
      usageCount: widget.initialItem?.usageCount ?? 0,
      status: _selectedStatus,
      createdAt: widget.initialItem?.createdAt ?? DateTime.now(),
      explanation: _explanationController.text.trim().isNotEmpty
          ? _explanationController.text.trim()
          : null,
      marks: double.tryParse(_marksController.text) ?? 1.0,
      negativeMarks: double.tryParse(_negativeMarksController.text) ?? 0.25,
    );

    widget.onSave(savedItem);
    Navigator.of(context).pop();
  }

  void _openImportDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ImportQuestionsDialog(
        onImport: (importedList) async {
          if (importedList.isEmpty) return;

          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Database not connected. Cannot import questions.'),
                  backgroundColor: Color(0xFFDC2626),
                ),
              );
            }
            return;
          }

          final selectedTitle = _selectedTestSeries.trim();
          final hasRealTestId = (widget.initialTestId != null && widget.initialTestId!.isNotEmpty) ||
              (_testTitleToId[selectedTitle]?.isNotEmpty ?? false);
          final String? resolvedTestId = widget.initialTestId ?? _testTitleToId[selectedTitle];
          final String effectiveTestTitle = widget.initialTestSeriesTitle ??
              (hasRealTestId ? selectedTitle : 'General Bank');

          try {
            final seenIds = <String>{};
            final payload = <Map<String, dynamic>>[];
            for (int i = 0; i < importedList.length; i++) {
              final m = importedList[i].toMap();
              if (resolvedTestId != null && resolvedTestId.isNotEmpty) {
                m['test_id'] = resolvedTestId;
              } else {
                m.remove('test_id');
              }
              String qId = m['id']?.toString() ?? '';
              if (qId.isEmpty || seenIds.contains(qId)) {
                qId = 'q_${DateTime.now().microsecondsSinceEpoch}_${i + 1}_${math.Random().nextInt(999999)}';
                m['id'] = qId;
              }
              seenIds.add(qId);
              m['question_number'] = i + 1;
              payload.add(m);
            }

            await client.from('questions').upsert(payload);
            if (resolvedTestId != null && resolvedTestId.isNotEmpty) {
              try {
                final countRows = await client
                    .from('questions')
                    .select('id')
                    .eq('test_id', resolvedTestId);
                await client.from('tests').update({
                  'total_questions': (countRows as List).length,
                }).eq('id', resolvedTestId);
              } catch (_) {}
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to import questions to Supabase: $e'),
                  backgroundColor: const Color(0xFFDC2626),
                ),
              );
            }
            return;
          }

          final itemsWithTest = importedList.asMap().entries.map((entry) {
            final idx = entry.key;
            final q = entry.value;
            return q.copyWith(
              testId: resolvedTestId,
              testSeriesTitle: effectiveTestTitle,
              questionNumber: idx + 1,
            );
          }).toList();

          if (widget.onBulkSave != null) {
            widget.onBulkSave!(itemsWithTest);
          } else {
            for (final q in itemsWithTest) {
              widget.onSave(q);
            }
          }

          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully imported ${importedList.length} questions into "$effectiveTestTitle"!',
                ),
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
    final isEdit = widget.initialItem != null;

    return AppModalDialog(
      title: isEdit ? 'Edit Question' : 'Add New Question',
      subtitle: _selectedTestSeries.isNotEmpty ? _selectedTestSeries : 'Configure question text, options and grading',
      iconData: isEdit ? Icons.edit_rounded : Icons.post_add_rounded,
      gradientColors: const [Color(0xFFFF9500), Color(0xFFF59E0B)],
      maxWidth: 760,
      maxHeight: 740,
      contentPadding: EdgeInsets.zero,
      footerLeft: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppModalDialog.secondaryButton(
            onPressed: () => setState(() => _showPreview = !_showPreview),
            icon: Icon(
              _showPreview ? Icons.edit_note_rounded : Icons.visibility_outlined,
              size: 15,
              color: AppModalDialog.defaultPrimaryColor,
            ),
            borderColor: AppModalDialog.defaultPrimaryColor.withAlpha(110),
            foregroundColor: AppModalDialog.defaultPrimaryColor,
            child: Text(
              _showPreview ? 'Edit Form' : 'Live Preview',
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          AppModalDialog.secondaryButton(
            onPressed: _openImportDialog,
            icon: const Icon(Icons.cloud_upload_outlined, size: 15, color: Color(0xFF0284C7)),
            foregroundColor: const Color(0xFF0284C7),
            child: const Text(
              'Import',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      actions: [
        AppModalDialog.secondaryButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
        ),
        AppModalDialog.primaryButton(
          onPressed: _submit,
          child: Text(
            isEdit ? 'Save Changes' : 'Create Question',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ),
      ],
      child: _showPreview ? _buildPreviewBody() : _buildFormBody(false),
    );
  }

  Widget _buildFormBody(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 22, 14, isMobile ? 16 : 22, 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Subject, Test Series
            Row(
              children: [
                Expanded(
                  child: AppDropdown<String>(
                    hint: 'Select Subject',
                    value: _subjects.contains(_selectedSubject) ? _selectedSubject : _subjects.first,
                    items: _subjects
                        .map((s) => AppDropdownItem(value: s, label: s))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSubject = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdown<String>(
                    hint: 'Select Test Series',
                    value: _testSeriesList.contains(_selectedTestSeries)
                        ? _selectedTestSeries
                        : (_testSeriesList.isNotEmpty ? _testSeriesList.first : null),
                    items: _testSeriesList
                        .map((t) => AppDropdownItem(value: t, label: t))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTestSeries = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Type, Difficulty, Status
            Row(
              children: [
                Expanded(
                  child: AppDropdown<String>(
                    hint: 'Question Type',
                    value: _selectedType,
                    items: _questionTypes
                        .map((t) => AppDropdownItem(value: t, label: t))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdown<QuestionDifficulty>(
                    hint: 'Difficulty Level',
                    value: _selectedDifficulty,
                    items: QuestionDifficulty.values
                        .map((d) => AppDropdownItem(value: d, label: d.label))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDifficulty = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdown<QuestionStatus>(
                    hint: 'Status',
                    value: _selectedStatus,
                    items: QuestionStatus.values
                        .map((s) => AppDropdownItem(value: s, label: s.label))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Question Text (English)
            AppModalDialog.textField(
              controller: _questionTextController,
              maxLines: 2,
              hint: 'Question Text (English) * (e.g. What is the SI unit of force?)',
              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter question text' : null,
            ),
            const SizedBox(height: 12),

            // Question Text (Hindi - Optional)
            AppModalDialog.textField(
              controller: _questionTextHindiController,
              maxLines: 1,
              hint: 'Question Text (Hindi - Optional) (उदा. बल का SI मात्रक क्या है?)',
              prefixIcon: const Icon(Icons.translate_rounded, size: 16, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 14),

            // Options A, B, C, D with Radio Button to choose Correct Answer
            const Text(
              'Answer Options (Select the correct answer button)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),

            for (int i = 0; i < 4; i++) ...[
              _buildOptionInput(i),
              if (i < 3) const SizedBox(height: 8),
            ],

            const SizedBox(height: 14),

            // Explanation
            AppModalDialog.textField(
              controller: _explanationController,
              maxLines: 2,
              hint: 'Solution / Explanation (step-by-step reasoning)...',
            ),
            const SizedBox(height: 12),

            // Row: Marks & Negative Marks
            Row(
              children: [
                Expanded(
                  child: AppModalDialog.textField(
                    controller: _marksController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    hint: 'Positive Marks (1.0)',
                    suffixText: '+ marks',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AppModalDialog.textField(
                    controller: _negativeMarksController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    hint: 'Negative Marks (0.25)',
                    suffixText: '- marks',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionInput(int index) {
    final labels = ['A', 'B', 'C', 'D'];
    final isCorrect = _selectedCorrectIndex == index;

    return Row(
      children: [
        // Radio toggle for correct answer
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _selectedCorrectIndex = index),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCorrect ? AppModalDialog.defaultPrimaryColor : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCorrect ? AppModalDialog.defaultPrimaryColor : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              labels[index],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isCorrect ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Text field
        Expanded(
          child: TextFormField(
            controller: _optionControllers[index],
            style: const TextStyle(fontSize: 12.5),
            decoration: AppModalDialog.inputDecoration(
              'Enter Option ${labels[index]} text...',
              hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              fillColor: isCorrect ? const Color(0xFFFFF7ED) : Colors.white,
              borderColor: isCorrect ? AppModalDialog.defaultPrimaryColor : const Color(0xFFE2E8F0),
              focusColor: AppModalDialog.defaultPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewBody() {
    final labels = ['A', 'B', 'C', 'D'];
    final qText = _questionTextController.text.trim().isNotEmpty
        ? _questionTextController.text.trim()
        : 'Sample Question Title Preview';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _selectedSubject,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6366F1)),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _selectedDifficulty.label,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                  ),
                ),
                const Spacer(),
                Text(
                  '+${_marksController.text} / -${_negativeMarksController.text}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              qText,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF101A3A)),
            ),
            const SizedBox(height: 14),

            for (int i = 0; i < 4; i++) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedCorrectIndex == i ? const Color(0xFFDCFCE7) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedCorrectIndex == i ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                    width: _selectedCorrectIndex == i ? 1.2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _selectedCorrectIndex == i ? const Color(0xFF16A34A) : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _selectedCorrectIndex == i ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _optionControllers[i].text.trim().isNotEmpty
                            ? _optionControllers[i].text.trim()
                            : 'Option ${labels[i]} preview',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _selectedCorrectIndex == i ? FontWeight.w700 : FontWeight.w500,
                          color: _selectedCorrectIndex == i ? const Color(0xFF14532D) : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    if (_selectedCorrectIndex == i)
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 16),
                  ],
                ),
              ),
            ],

            if (_explanationController.text.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Explanation: ${_explanationController.text.trim()}',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF92400E)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
