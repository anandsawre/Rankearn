import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/question_item.dart';

class CreateQuestionDialog extends StatefulWidget {
  final QuestionItem? initialItem;
  final ValueChanged<QuestionItem> onSave;

  const CreateQuestionDialog({
    super.key,
    this.initialItem,
    required this.onSave,
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

  final List<String> _subjects = [
    'Physics',
    'General Awareness',
    'Mathematics',
    'Chemistry',
    'Biology',
    'Reasoning',
    'Polity',
  ];

  final List<String> _testSeriesList = [
    'RRB Technician Grade 3',
    'Current Affairs Practice Series',
    'Railway Maths Practice Series',
    'Chemistry Practice Series',
    'Biology Marathon Series',
    'Reasoning Special Series',
    'Current Affairs Monthly Series',
  ];

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
    _selectedSubject = item?.subject ?? _subjects.first;
    _selectedTestSeries = item?.testSeriesTitle.replaceAll('\n', ' ') ?? _testSeriesList.first;
    _selectedQuestionSet = item?.questionSet ?? 'Set A';
    _selectedType = item?.questionType ?? 'MCQ';
    _selectedDifficulty = item?.difficulty ?? QuestionDifficulty.easy;
    _selectedStatus = item?.status ?? QuestionStatus.published;
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

    final savedItem = QuestionItem(
      id: widget.initialItem?.id ?? 'q-${DateTime.now().millisecondsSinceEpoch}',
      questionNumber: widget.initialItem?.questionNumber ?? 1,
      questionText: _questionTextController.text.trim(),
      questionTextHindi: _questionTextHindiController.text.trim().isNotEmpty
          ? _questionTextHindiController.text.trim()
          : null,
      subject: _selectedSubject,
      testSeriesTitle: _selectedTestSeries,
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

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialItem != null;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderXl),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5636F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      isEdit ? Icons.edit_rounded : Icons.add_circle_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEdit ? 'Edit Question' : 'Add New Question',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101A3A),
                    ),
                  ),
                  const Spacer(),
                  // Toggle Preview Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: Icon(
                      _showPreview ? Icons.edit_note_rounded : Icons.visibility_outlined,
                      size: 15,
                      color: const Color(0xFF5636F5),
                    ),
                    label: Text(
                      _showPreview ? 'Edit Form' : 'Live Preview',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF5636F5)),
                    ),
                    onPressed: () => setState(() => _showPreview = !_showPreview),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form Body / Preview Body
            Expanded(
              child: _showPreview ? _buildPreviewBody() : _buildFormBody(),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5636F5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text(isEdit ? 'Save Changes' : 'Create Question'),
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Subject, Test Series, Question Set
            Row(
              children: [
                Expanded(
                  child: _buildFormFieldLabel(
                    label: 'Subject',
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedSubject,
                      items: _subjects
                          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedSubject = val!),
                      decoration: _inputDecoration(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFormFieldLabel(
                    label: 'Test Series',
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedTestSeries,
                      items: _testSeriesList
                          .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedTestSeries = val!),
                      decoration: _inputDecoration(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Type, Difficulty, Status
            Row(
              children: [
                Expanded(
                  child: _buildFormFieldLabel(
                    label: 'Question Type',
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedType,
                      items: _questionTypes
                          .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedType = val!),
                      decoration: _inputDecoration(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFormFieldLabel(
                    label: 'Difficulty Level',
                    child: DropdownButtonFormField<QuestionDifficulty>(
                      isExpanded: true,
                      initialValue: _selectedDifficulty,
                      items: QuestionDifficulty.values
                          .map((d) => DropdownMenuItem(value: d, child: Text(d.label, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedDifficulty = val!),
                      decoration: _inputDecoration(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFormFieldLabel(
                    label: 'Status',
                    child: DropdownButtonFormField<QuestionStatus>(
                      isExpanded: true,
                      initialValue: _selectedStatus,
                      items: QuestionStatus.values
                          .map((s) => DropdownMenuItem(value: s, child: Text(s.label, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedStatus = val!),
                      decoration: _inputDecoration(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Question Text (English)
            _buildFormFieldLabel(
              label: 'Question Text (English) *',
              child: TextFormField(
                controller: _questionTextController,
                maxLines: 2,
                style: const TextStyle(fontSize: 12.5),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter question text' : null,
                decoration: _inputDecoration(hint: 'e.g. What is the SI unit of force?'),
              ),
            ),
            const SizedBox(height: 12),

            // Question Text (Hindi - Optional)
            _buildFormFieldLabel(
              label: 'Question Text (Hindi - Optional)',
              child: TextFormField(
                controller: _questionTextHindiController,
                maxLines: 1,
                style: const TextStyle(fontSize: 12),
                decoration: _inputDecoration(hint: 'उदा. बल का SI मात्रक क्या है?'),
              ),
            ),
            const SizedBox(height: 16),

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

            const SizedBox(height: 16),

            // Explanation
            _buildFormFieldLabel(
              label: 'Solution / Explanation',
              child: TextFormField(
                controller: _explanationController,
                maxLines: 2,
                style: const TextStyle(fontSize: 12),
                decoration: _inputDecoration(hint: 'Provide detailed step-by-step reasoning...'),
              ),
            ),
            const SizedBox(height: 12),

            // Row: Marks & Negative Marks
            Row(
              children: [
                Expanded(
                  child: _buildFormFieldLabel(
                    label: 'Positive Marks (+)',
                    child: TextFormField(
                      controller: _marksController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 12),
                      decoration: _inputDecoration(hint: '1.0'),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildFormFieldLabel(
                    label: 'Negative Marks (-)',
                    child: TextFormField(
                      controller: _negativeMarksController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 12),
                      decoration: _inputDecoration(hint: '0.25'),
                    ),
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
              color: isCorrect ? const Color(0xFF5636F5) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCorrect ? const Color(0xFF5636F5) : const Color(0xFFCBD5E1),
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
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Enter Option ${labels[index]} text...',
              hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: isCorrect ? const Color(0xFFF5F3FF) : const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: isCorrect ? const Color(0xFF5636F5) : const Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: isCorrect ? const Color(0xFF5636F5) : const Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF5636F5), width: 1.2),
              ),
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
      padding: const EdgeInsets.all(20),
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

  Widget _buildFormFieldLabel({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        borderSide: const BorderSide(color: Color(0xFF5636F5), width: 1.2),
      ),
    );
  }
}
