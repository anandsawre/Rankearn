import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/question_item.dart';

class AiGenerateQuestionsDialog extends StatefulWidget {
  final ValueChanged<List<QuestionItem>> onSaveGenerated;

  const AiGenerateQuestionsDialog({super.key, required this.onSaveGenerated});

  @override
  State<AiGenerateQuestionsDialog> createState() => _AiGenerateQuestionsDialogState();
}

class _AiGenerateQuestionsDialogState extends State<AiGenerateQuestionsDialog> {
  String _selectedSubject = 'Physics';
  final TextEditingController _topicController =
      TextEditingController(text: 'Laws of Motion & Friction');
  QuestionDifficulty _selectedDifficulty = QuestionDifficulty.medium;
  int _questionCount = 3;
  String _language = 'English';

  bool _isGenerating = false;
  List<QuestionItem> _generatedQuestions = [];

  final List<String> _subjects = [
    'Physics',
    'General Awareness',
    'Mathematics',
    'Chemistry',
    'Biology',
    'Reasoning',
    'Polity',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateQuestions() async {
    setState(() {
      _isGenerating = true;
      _generatedQuestions.clear();
    });

    // Simulate AI generation process (secure backend simulation)
    await Future.delayed(const Duration(milliseconds: 1200));

    final topic = _topicController.text.trim().isNotEmpty
        ? _topicController.text.trim()
        : 'General Concepts';

    final generated = <QuestionItem>[
      QuestionItem(
        id: 'ai-gen-${DateTime.now().millisecondsSinceEpoch}-1',
        questionNumber: 1,
        questionText:
            'What force is required to accelerate a 5 kg mass at 2 m/s² according to Newton\'s second law?',
        subject: _selectedSubject,
        testSeriesTitle: 'RRB Technician Grade 3',
        questionType: 'MCQ',
        difficulty: _selectedDifficulty,
        correctAnswerIndex: 1,
        correctAnswerChar: 'B',
        usageCount: 0,
        status: QuestionStatus.published,
        createdAt: DateTime.now(),
        options: const [
          QuestionOptionItem(label: 'A', text: '5 N'),
          QuestionOptionItem(label: 'B', text: '10 N'),
          QuestionOptionItem(label: 'C', text: '15 N'),
          QuestionOptionItem(label: 'D', text: '25 N'),
        ],
        explanation: '[$topic] F = m * a = 5 kg * 2 m/s² = 10 N.',
      ),
      QuestionItem(
        id: 'ai-gen-${DateTime.now().millisecondsSinceEpoch}-2',
        questionNumber: 2,
        questionText:
            'Which type of friction acts between two surfaces that are not in relative motion?',
        subject: _selectedSubject,
        testSeriesTitle: 'RRB Technician Grade 3',
        questionType: 'MCQ',
        difficulty: _selectedDifficulty,
        correctAnswerIndex: 0,
        correctAnswerChar: 'A',
        usageCount: 0,
        status: QuestionStatus.published,
        createdAt: DateTime.now(),
        options: const [
          QuestionOptionItem(label: 'A', text: 'Static friction'),
          QuestionOptionItem(label: 'B', text: 'Kinetic friction'),
          QuestionOptionItem(label: 'C', text: 'Rolling friction'),
          QuestionOptionItem(label: 'D', text: 'Fluid friction'),
        ],
        explanation:
            'Static friction opposes the initiation of motion between resting contact surfaces.',
      ),
      if (_questionCount > 2)
        QuestionItem(
          id: 'ai-gen-${DateTime.now().millisecondsSinceEpoch}-3',
          questionNumber: 3,
          questionText:
              'A rocket accelerates upward based on which principle of classical physics?',
          subject: _selectedSubject,
          testSeriesTitle: 'RRB Technician Grade 3',
          questionType: 'MCQ',
          difficulty: _selectedDifficulty,
          correctAnswerIndex: 2,
          correctAnswerChar: 'C',
          usageCount: 0,
          status: QuestionStatus.published,
          createdAt: DateTime.now(),
          options: const [
            QuestionOptionItem(label: 'A', text: 'Newton\'s First Law'),
            QuestionOptionItem(label: 'B', text: 'Pascal\'s Principle'),
            QuestionOptionItem(label: 'C', text: 'Newton\'s Third Law (Action-Reaction)'),
            QuestionOptionItem(label: 'D', text: 'Archimedes\' Principle'),
          ],
          explanation:
              'Rocket propulsion relies on Newton\'s third law: escaping high-velocity gas exerts equal and opposite thrust.',
        ),
    ];

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _generatedQuestions = generated;
      });
    }
  }

  void _confirmSave() {
    if (_generatedQuestions.isEmpty) return;
    widget.onSaveGenerated(_generatedQuestions);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderXl),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
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
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'AI Question Generator',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101A3A),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Config Row 1: Subject & Topic
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: _buildField(
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
                          flex: 6,
                          child: _buildField(
                            label: 'Topic / Syllabus Area',
                            child: TextFormField(
                              controller: _topicController,
                              style: const TextStyle(fontSize: 12),
                              decoration: _inputDecoration(hint: 'e.g. Laws of Motion & Friction'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Config Row 2: Difficulty, Count, Language
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            label: 'Difficulty',
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
                          child: _buildField(
                            label: 'Questions Count',
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              initialValue: _questionCount,
                              items: const [3, 5, 10, 20]
                                  .map((c) => DropdownMenuItem(value: c, child: Text('$c Questions', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (val) => setState(() => _questionCount = val!),
                              decoration: _inputDecoration(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            label: 'Language',
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _language,
                              items: ['English', 'Hindi', 'Bilingual']
                                  .map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (val) => setState(() => _language = val!),
                              decoration: _inputDecoration(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Generate Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: _isGenerating
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.auto_awesome, size: 16),
                        label: Text(_isGenerating ? 'Generating High-Quality Questions...' : 'Generate Questions with AI'),
                        onPressed: _isGenerating ? null : _generateQuestions,
                      ),
                    ),

                    if (_generatedQuestions.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Generated Questions (${_generatedQuestions.length})',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
                          ),
                          Text(
                            'Review and remove or save to Question Bank',
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      for (int i = 0; i < _generatedQuestions.length; i++) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Q#${i + 1}',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF5636F5)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _generatedQuestions[i].questionText,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                    onPressed: () {
                                      setState(() {
                                        _generatedQuestions.removeAt(i);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              for (final opt in _generatedQuestions[i].options)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                                  child: Row(
                                    children: [
                                      Text('${opt.label}. ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                      Text(
                                        opt.text,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: opt.label == _generatedQuestions[i].correctAnswerChar ? FontWeight.w700 : FontWeight.w400,
                                          color: opt.label == _generatedQuestions[i].correctAnswerChar ? const Color(0xFF16A34A) : const Color(0xFF475569),
                                        ),
                                      ),
                                      if (opt.label == _generatedQuestions[i].correctAnswerChar)
                                        const Text(' (Correct)', style: TextStyle(fontSize: 10, color: Color(0xFF16A34A), fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
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
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text('Save ${_generatedQuestions.length} Questions to Bank'),
                    onPressed: _generatedQuestions.isNotEmpty ? _confirmSave : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
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
        borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.2),
      ),
    );
  }
}
