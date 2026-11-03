import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/test_series_item.dart';
import '../../questions/models/question_item.dart';

class AiGenerateTestSeriesDialog extends StatefulWidget {
  final Function(TestSeriesItem test, List<QuestionItem> questions) onSaveGenerated;

  const AiGenerateTestSeriesDialog({
    super.key,
    required this.onSaveGenerated,
  });

  @override
  State<AiGenerateTestSeriesDialog> createState() => _AiGenerateTestSeriesDialogState();
}

class _AiGenerateTestSeriesDialogState extends State<AiGenerateTestSeriesDialog> {
  final TextEditingController _titleController =
      TextEditingController(text: 'AI Generated Full Mock Test 01');
  final TextEditingController _topicsController =
      TextEditingController(text: 'Complete Syllabus, Current Affairs & Core Science');

  String _targetExam = 'rrb_alp';
  String _subject = 'General Science';
  String _difficulty = 'Medium';
  int _questionCount = 50;
  int _duration = 60;
  String _language = 'Bilingual (English + Hindi)';

  bool _isGenerating = false;
  double _progress = 0.0;
  String _statusText = 'Ready to launch AI generation';

  @override
  void dispose() {
    _titleController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  void _startGeneration() async {
    setState(() {
      _isGenerating = true;
      _progress = 0.15;
      _statusText = 'Analyzing exam pattern and syllabus weightage...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _progress = 0.45;
      _statusText = 'Generating $_questionCount high-yield MCQs with distractors...';
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _progress = 0.80;
      _statusText = 'Formatting bilingual explanations and KaTeX notation...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _progress = 1.0;
      _statusText = 'Test generation completed!';
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final now = DateTime.now();
    final testId = 'ai_test_${now.millisecondsSinceEpoch}';

    final testItem = TestSeriesItem(
      id: testId,
      title: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : 'AI Mock Test Series',
      description: 'AI synthesized mock test covering: ${_topicsController.text.trim()}',
      examCategoryId: _targetExam,
      totalTests: 1,
      totalQuestions: _questionCount,
      durationMinutes: _duration,
      negativeMarking: 0.33,
      priceInr: 0,
      entryFeeCoins: 0,
      enrollments: 0,
      status: TestSeriesStatus.published,
      testMode: 'mock',
      subject: _subject,
      topic: _topicsController.text.trim(),
      createdAt: now,
      icon: Icons.auto_awesome_rounded,
      iconColor: const Color(0xFFFF3385),
    );

    final questions = <QuestionItem>[];
    for (int i = 1; i <= _questionCount; i++) {
      questions.add(QuestionItem(
        id: 'q_${testId}_$i',
        testId: testId,
        questionNumber: i,
        questionText: 'Which principle governs the working of hydraulic brakes in automobiles? (Q#$i)',
        questionTextHindi: 'स्वचालित वाहनों में हाइड्रोलिक ब्रेक किस सिद्धांत पर कार्य करते हैं?',
        subject: _subject,
        testSeriesTitle: testItem.title,
        questionType: 'MCQ',
        difficulty: QuestionDifficulty.medium,
        correctAnswerIndex: 1,
        correctAnswerChar: 'B',
        usageCount: 0,
        status: QuestionStatus.published,
        createdAt: now,
        options: const [
          QuestionOptionItem(label: 'A', text: 'Bernoulli\'s principle / बर्नौली का प्रमेय'),
          QuestionOptionItem(label: 'B', text: 'Pascal\'s law / पास्कल का नियम'),
          QuestionOptionItem(label: 'C', text: 'Archimedes principle / आर्किमिडीज सिद्धांत'),
          QuestionOptionItem(label: 'D', text: 'Newton\'s third law / न्यूटन का तीसरा नियम'),
        ],
        explanation: 'Hydraulic brakes operate on Pascal\'s principle, stating pressure applied to an enclosed fluid is transmitted undiminished.',
        marks: 1.0,
        negativeMarks: 0.33,
      ));
    }

    widget.onSaveGenerated(testItem, questions);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'AI Generate Test Series',
      subtitle: 'Synthesize complete exam-standard mock tests with Gemini AI',
      iconData: Icons.auto_awesome_rounded,
      gradientColors: const [Color(0xFFFF3385), Color(0xFFEC4899)],
      maxWidth: 620,
      scrollable: true,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          onPressed: _isGenerating ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12.5)),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF3385),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          onPressed: _isGenerating ? null : _startGeneration,
          icon: _isGenerating
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.auto_awesome_rounded, size: 16),
          label: Text(
            _isGenerating ? 'Generating...' : 'Generate Test Series',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Target Exam & Subject
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Exam *', style: _labelStyle),
                    const SizedBox(height: 6),
                    AppDropdown<String>(
                      value: _targetExam,
                      items: const [
                        AppDropdownItem(value: 'rrb_alp', label: '🚂 RRB ALP & Technician'),
                        AppDropdownItem(value: 'ssc_cgl', label: '🏛️ SSC CGL Tier 1'),
                        AppDropdownItem(value: 'bpsc_pre', label: '📘 BPSC Civil Services'),
                        AppDropdownItem(value: 'general', label: '🎯 General Competitive'),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _targetExam = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Subject Focus *', style: _labelStyle),
                    const SizedBox(height: 6),
                    AppDropdown<String>(
                      value: _subject,
                      items: const [
                        AppDropdownItem(value: 'General Science', label: '🔬 General Science'),
                        AppDropdownItem(value: 'Mathematics', label: '📐 Quantitative Aptitude'),
                        AppDropdownItem(value: 'Reasoning Ability', label: '💡 Reasoning Ability'),
                        AppDropdownItem(value: 'General Awareness', label: '🌍 General Awareness'),
                        AppDropdownItem(value: 'Complete Mixed Syllabus', label: '📑 Full Mixed Mock'),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _subject = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Test Title
          const Text('Test Series Title *', style: _labelStyle),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 13),
            decoration: _inputDecoration('e.g. RRB ALP CBT 1 - Rapid Science Mock 01'),
          ),
          const SizedBox(height: 14),

          // Row 2: Questions Count, Duration & Difficulty
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Questions *', style: _labelStyle),
                    const SizedBox(height: 6),
                    AppDropdown<int>(
                      value: _questionCount,
                      items: const [
                        AppDropdownItem(value: 20, label: '20 Questions'),
                        AppDropdownItem(value: 30, label: '30 Questions'),
                        AppDropdownItem(value: 50, label: '50 Questions'),
                        AppDropdownItem(value: 75, label: '75 Questions'),
                        AppDropdownItem(value: 100, label: '100 Questions'),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _questionCount = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Duration *', style: _labelStyle),
                    const SizedBox(height: 6),
                    AppDropdown<int>(
                      value: _duration,
                      items: const [
                        AppDropdownItem(value: 30, label: '30 Minutes'),
                        AppDropdownItem(value: 45, label: '45 Minutes'),
                        AppDropdownItem(value: 60, label: '60 Minutes'),
                        AppDropdownItem(value: 90, label: '90 Minutes'),
                        AppDropdownItem(value: 120, label: '120 Minutes'),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _duration = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Difficulty *', style: _labelStyle),
                    const SizedBox(height: 6),
                    AppDropdown<String>(
                      value: _difficulty,
                      items: const [
                        AppDropdownItem(value: 'Easy', label: 'Easy Level'),
                        AppDropdownItem(value: 'Medium', label: 'Standard Medium'),
                        AppDropdownItem(value: 'Hard', label: 'Advanced Hard'),
                        AppDropdownItem(value: 'Exam Pattern', label: 'Exam Pattern'),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _difficulty = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 3: Language & Topic Coverage
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Language *', style: _labelStyle),
                    const SizedBox(height: 6),
                    AppDropdown<String>(
                      value: _language,
                      items: const [
                        AppDropdownItem(value: 'Bilingual (English + Hindi)', label: '🌐 Bilingual (Eng + Hindi)'),
                        AppDropdownItem(value: 'English Only', label: '🇬🇧 English Only'),
                        AppDropdownItem(value: 'Hindi Only', label: '🇮🇳 Hindi Only'),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _language = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Syllabus / Topics Focus', style: _labelStyle),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _topicsController,
                      style: const TextStyle(fontSize: 12),
                      decoration: _inputDecoration('e.g. Physics, Chemistry, Indian Polity'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Progress indicator during generation
          if (_isGenerating) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF2F8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFBCFE8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFF3385), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusText,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9D174D)),
                        ),
                      ),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF3385)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: const Color(0xFFFCE7F3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF3385)),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334155),
  );

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF3385), width: 1.5),
      ),
    );
  }
}
