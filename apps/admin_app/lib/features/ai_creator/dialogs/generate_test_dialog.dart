import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
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
  final _titleController = TextEditingController();
  final _topicController = TextEditingController();
  final _customPromptController = TextEditingController();

  AiTestSubject _selectedSubject = AiTestSubject.generalScience;
  AiTestDifficulty _selectedDifficulty = AiTestDifficulty.medium;
  int _questionCount = 25;
  int _durationMinutes = 30;
  List<String> _examOptions = ['General Competitive Exam'];
  String _selectedExam = 'General Competitive Exam';
  String _selectedLanguage = 'Bilingual (English + Hindi)';
  bool _includeExplanations = true;
  bool _negativeMarking = true;

  bool _isGenerating = false;
  double _generationProgress = 0.0;
  String _progressStatus = 'Ready to generate...';
  String? _errorMessage;

  static const List<String> _languageOptions = [
    'Bilingual (English + Hindi)',
    'English Only',
    'Hindi Only',
  ];

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    final res = await CategoriesRepository().getExamCategories();
    if (res is Success<List<ExamCategoryModel>> && res.data.isNotEmpty && mounted) {
      setState(() {
        _examOptions = res.data.map((e) => e.name).toSet().toList();
        _selectedExam = _examOptions.first;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }

  Future<void> _startGeneration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generationProgress = 0.05;
      _progressStatus = 'Initializing Gemini AI Creator pipeline...';
    });

    final sw = Stopwatch()..start();

    try {
      final questions = await AiCreatorService().generateQuestions(
        title: _titleController.text.trim(),
        topic: _topicController.text.trim().isNotEmpty
            ? _topicController.text.trim()
            : _selectedSubject.label,
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
      sw.stop();

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
        createdBy: 'Admin',
        icon: _selectedSubject.icon,
        iconBgColor: _selectedSubject.color,
        iconColor: Colors.white,
        questions: questions,
        generationTimeSeconds: sw.elapsed.inSeconds,
      );

      await AiCreatorService().publishTestToApp(testItem: newTest);
      if (!mounted) return;

      widget.onTestGenerated(newTest);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'AI Test "${newTest.title}" generated and saved to Supabase (${newTest.questionCount} questions)!',
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      sw.stop();
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _generationProgress = 0.0;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      iconData: Icons.auto_awesome_rounded,
      gradientColors: const [Color(0xFF5636F5), Color(0xFF2587F8)],
      title: _isGenerating ? 'Synthesizing Test' : 'Generate Test with AI',
      subtitle: _isGenerating
          ? 'Generating verified bilingual questions via AI pipeline'
          : 'Generate real test series questions via Gemini / Supabase Edge Proxy',
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
            'Generating Competitive Test Series...',
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
    final activeExam = _examOptions.contains(_selectedExam) ? _selectedExam : _examOptions.first;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDA4AF)),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF9F1239), fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const Text('Test Title *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _titleController,
            decoration: AppModalDialog.inputDecoration(
              'Enter test title...',
              focusColor: const Color(0xFF5636F5),
            ),
            style: const TextStyle(fontSize: 12.5),
            validator: (val) => val == null || val.trim().isEmpty ? 'Enter a test title' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppDropdown.simple(
                  label: 'Subject *',
                  value: _selectedSubject,
                  items: AiTestSubject.values,
                  itemLabel: (s) => s.label,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSubject = val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdown.simple(
                  label: 'Difficulty Level *',
                  value: _selectedDifficulty,
                  items: AiTestDifficulty.values,
                  itemLabel: (d) => d.label,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDifficulty = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppDropdown.simple(
                  label: 'Number of Questions',
                  value: _questionCount,
                  items: const [10, 25, 40, 50, 75, 100],
                  itemLabel: (n) => '$n Questions',
                  onChanged: (val) {
                    if (val != null) setState(() => _questionCount = val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdown.simple(
                  label: 'Duration (Minutes)',
                  value: _durationMinutes,
                  items: const [20, 30, 45, 60, 90, 120],
                  itemLabel: (n) => '$n Minutes',
                  onChanged: (val) {
                    if (val != null) setState(() => _durationMinutes = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppDropdown.simple(
                  label: 'Target Exam / Pattern',
                  value: activeExam,
                  items: _examOptions,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedExam = val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdown.simple(
                  label: 'Language Mode',
                  value: _selectedLanguage,
                  items: _languageOptions,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLanguage = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Topics / Syllabus Focus', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _topicController,
            maxLines: 2,
            decoration: AppModalDialog.inputDecoration(
              'Enter syllabus topics...',
              focusColor: const Color(0xFF5636F5),
            ),
            style: const TextStyle(fontSize: 12.5),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _customPromptController,
            maxLines: 2,
            decoration: AppModalDialog.inputDecoration(
              'Optional instructions for question style...',
              focusColor: const Color(0xFF5636F5),
            ),
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 10),
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
