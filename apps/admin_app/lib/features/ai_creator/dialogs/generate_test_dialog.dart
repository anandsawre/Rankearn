import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/ai_test_item.dart';
import '../services/ai_creator_service.dart';

class GenerateTestDialog extends StatefulWidget {
  final ValueChanged<AiGeneratedTestItem> onTestGenerated;

  const GenerateTestDialog({
    super.key,
    required this.onTestGenerated,
  });

  @override
  State<GenerateTestDialog> createState() => _GenerateTestDialogState();
}

class _GenerateTestDialogState extends State<GenerateTestDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _topicController;
  late final TextEditingController _customPromptController;

  AiTestSubject _selectedSubject = AiTestSubject.generalScience;
  AiTestDifficulty _selectedDifficulty = AiTestDifficulty.medium;
  int _questionCount = 50;
  int _durationMinutes = 60;
  String _selectedExam = 'RRB Technician 2026';
  String _selectedLanguage = 'Bilingual (English + Hindi)';
  bool _includeExplanations = true;
  bool _negativeMarking = true;
  bool _isGenerating = false;
  double _generationProgress = 0.0;
  String _progressStatus = 'Initializing Gemini 1.5 Pro pipeline...';

  static const List<String> _examOptions = [
    'RRB Technician 2026',
    'Railway Group D / ALP',
    'SSC CGL / CHSL',
    'BPSC 70th Prelims',
    'NEET UG 2026',
    'UPSC CSE GS Prelims',
    'Custom Syllabus Test',
  ];

  static const List<String> _languageOptions = [
    'Bilingual (English + Hindi)',
    'English Only',
    'Hindi Only',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'General Science Sprint Test');
    _topicController = TextEditingController(text: 'Electricity, Magnetism, Chemical Reactions, Optics, Cell Biology');
    _customPromptController = TextEditingController(text: 'Focus on application-oriented questions with numericals and standard RRB syllabus.');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }

  void _startGeneration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
      _generationProgress = 0.05;
      _progressStatus = 'Initializing Gemini AI Creator pipeline...';
    });

    final questions = await AiCreatorService().generateQuestions(
      title: _titleController.text.trim(),
      topic: _topicController.text.trim(),
      subject: _selectedSubject,
      difficulty: _selectedDifficulty,
      count: _questionCount,
      exam: _selectedExam,
      language: _selectedLanguage,
      customInstructions: _customPromptController.text.trim(),
      onProgress: (progress, status) {
        if (mounted) {
          setState(() {
            _generationProgress = progress;
            _progressStatus = status;
          });
        }
      },
    );

    if (!mounted) return;

    final newTest = AiGeneratedTestItem(
      id: 'ait_${DateTime.now().millisecondsSinceEpoch}',
      rowNumber: 1,
      title: _titleController.text.trim(),
      subtitle: '$_selectedExam • ${_selectedSubject.label}',
      subject: _selectedSubject,
      difficulty: _selectedDifficulty,
      questionCount: questions.length,
      durationMinutes: _durationMinutes,
      status: AiTestStatus.published,
      createdOn: DateTime.now(),
      createdBy: 'AI Creator',
      icon: _selectedSubject.icon,
      iconBgColor: _selectedSubject.color,
      iconColor: Colors.white,
      questions: questions,
    );

    // Save/publish to Supabase if available
    await AiCreatorService().publishTestToApp(testItem: newTest);

    if (!mounted) return;

    widget.onTestGenerated(newTest);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ AI Test "${newTest.title}" generated successfully with ${newTest.questionCount} questions!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      iconData: Icons.auto_awesome_rounded,
      gradientColors: const [Color(0xFF5636F5), Color(0xFF2587F8)],
      title: _isGenerating ? 'Synthesizing Test' : 'Generate Test with AI',
      subtitle: _isGenerating
          ? 'Generating verified bilingual questions via AI pipeline'
          : 'Synthesize complete test series with solutions and explanations',
      maxWidth: 640,
      scrollable: !_isGenerating,
      showCloseButton: !_isGenerating,
      actions: _isGenerating
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: _startGeneration,
                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                label: const Text('Generate with AI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5636F5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ],
      child: _isGenerating ? _buildGeneratingView() : _buildFormView(),
    );
  }

  Widget _buildGeneratingView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF5636F5).withAlpha(20),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF5636F5), size: 30),
          ),
          const SizedBox(height: 16),
          const Text(
            'Creating Your Competitive Test Series...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
          ),
          const SizedBox(height: 6),
          Text(
            _progressStatus,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _generationProgress,
              minHeight: 8,
              backgroundColor: const Color(0xFFEEF0FF),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5636F5)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(_generationProgress * 100).toInt()}% completed',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF5636F5)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

            // Test Title
            const Text('Test Title *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. RRB Technician Mock Test 2026',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: const TextStyle(fontSize: 12),
              validator: (val) => val == null || val.trim().isEmpty ? 'Enter a test title' : null,
            ),
            const SizedBox(height: 12),

            // Subject & Difficulty Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Subject *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<AiTestSubject>(
                        initialValue: _selectedSubject,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: AiTestSubject.values.map((s) {
                          return DropdownMenuItem(value: s, child: Text(s.label, style: const TextStyle(fontSize: 12)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSubject = val);
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
                      const Text('Difficulty Level *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<AiTestDifficulty>(
                        initialValue: _selectedDifficulty,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: AiTestDifficulty.values.map((d) {
                          return DropdownMenuItem(value: d, child: Text(d.label, style: const TextStyle(fontSize: 12)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDifficulty = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Questions Count & Duration Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Number of Questions', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int>(
                        initialValue: _questionCount,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: [10, 25, 40, 50, 75, 100].map((n) {
                          return DropdownMenuItem(value: n, child: Text('$n Questions', style: const TextStyle(fontSize: 12)));
                        }).toList(),
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
                      const Text('Duration (Minutes)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int>(
                        initialValue: _durationMinutes,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: [20, 30, 45, 60, 90, 120].map((n) {
                          return DropdownMenuItem(value: n, child: Text('$n Minutes', style: const TextStyle(fontSize: 12)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _durationMinutes = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Target Exam & Language Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Target Exam / Pattern', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedExam,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: _examOptions.map((e) {
                          return DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedExam = val);
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
                      const Text('Language Mode', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedLanguage,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: _languageOptions.map((l) {
                          return DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 12)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedLanguage = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Topics / Syllabus Focus
            const Text('Topics / Syllabus Focus', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            TextFormField(
              controller: _topicController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. Kinematics, Newton Laws, Periodic Table, Modern Indian History',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),

            // Toggles Wrap (Responsive to prevent overflow)
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                SizedBox(
                  width: 240,
                  child: CheckboxListTile(
                    title: const Text('Detailed Explanations', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    value: _includeExplanations,
                    onChanged: (val) => setState(() => _includeExplanations = val ?? true),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: const Color(0xFF5636F5),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: CheckboxListTile(
                    title: const Text('Negative Marking (1/3rd)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    value: _negativeMarking,
                    onChanged: (val) => setState(() => _negativeMarking = val ?? true),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: const Color(0xFF5636F5),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }
}
