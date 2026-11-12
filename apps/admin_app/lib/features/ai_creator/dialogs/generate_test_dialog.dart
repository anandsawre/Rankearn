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

  static const String _allSubSubjects = 'All Sub-Subjects';
  static const String _allTopics = 'All Topics';

  String _selectedSubjectName = AiTestSubject.generalScience.label;
  String _selectedSubSubject = _allSubSubjects;
  String _selectedTopicName = _allTopics;
  String _lastAutoTopic = '';
  AiTestDifficulty _selectedDifficulty = AiTestDifficulty.medium;
  int _questionCount = 25;
  int _durationMinutes = 30;
  List<ExamCategoryModel> _examModels = const [];
  List<CategoryModel> _dbCategories = const [];
  List<SubcategoryModel> _dbSubcategories = const [];
  List<TopicModel> _dbTopics = const [];
  List<String> _examOptions = ['General Competitive Exam'];
  String _selectedExam = 'General Competitive Exam';
  List<String> _subjectOptions = AiTestSubject.values.map((s) => s.label).toList();
  List<String> _subSubjectOptions = const [_allSubSubjects];
  List<String> _topicOptions = const [_allTopics];
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
    _loadExamsAndSubjects();
  }

  Future<void> _loadExamsAndSubjects() async {
    final repo = CategoriesRepository();
    final results = await Future.wait<dynamic>([
      repo.getExamCategories(),
      repo.getCategories(),
      repo.getSubcategories(),
      repo.getTopics(),
    ]);
    if (!mounted) return;

    final examRes = results[0] as Result<List<ExamCategoryModel>>;
    final catRes = results[1] as Result<List<CategoryModel>>;
    final subRes = results[2] as Result<List<SubcategoryModel>>;
    final topicRes = results[3] as Result<List<TopicModel>>;

    final exams = examRes is Success<List<ExamCategoryModel>> ? examRes.data : <ExamCategoryModel>[];
    final cats = catRes is Success<List<CategoryModel>> ? catRes.data : <CategoryModel>[];
    final subs = subRes is Success<List<SubcategoryModel>> ? subRes.data : <SubcategoryModel>[];
    final topics = topicRes is Success<List<TopicModel>> ? topicRes.data : <TopicModel>[];

    setState(() {
      _examModels = exams;
      _dbCategories = cats;
      _dbSubcategories = subs;
      _dbTopics = topics;
      if (exams.isNotEmpty) {
        _examOptions = exams.map((e) => e.name).toSet().toList();
        if (!_examOptions.contains(_selectedExam)) {
          _selectedExam = _examOptions.first;
        }
      }
      _syncSubjectOptionsForSelectedExam();
    });
  }

  ExamCategoryModel? _resolveSelectedExamModel() {
    return _examModels.cast<ExamCategoryModel?>().firstWhere(
          (e) => e?.name == _selectedExam,
          orElse: () => null,
        );
  }

  CategoryModel? _resolveSelectedCategoryModel() {
    final exam = _resolveSelectedExamModel();
    if (exam != null) {
      final exact = _dbCategories.cast<CategoryModel?>().firstWhere(
            (c) =>
                c != null &&
                c.examCategoryId == exam.id &&
                c.name.trim().toLowerCase() == _selectedSubjectName.trim().toLowerCase(),
            orElse: () => null,
          );
      if (exact != null) return exact;
    }
    return _dbCategories.cast<CategoryModel?>().firstWhere(
          (c) =>
              c != null &&
              c.name.trim().toLowerCase() == _selectedSubjectName.trim().toLowerCase(),
          orElse: () => null,
        );
  }

  void _syncSubjectOptionsForSelectedExam() {
    final matchingExam = _resolveSelectedExamModel();

    final examSubjects = matchingExam != null
        ? _dbCategories
            .where((c) => c.examCategoryId == matchingExam.id && c.name.trim().isNotEmpty)
            .map((c) => c.name.trim())
            .toList()
        : <String>[];

    final allDbSubjects = _dbCategories
        .where((c) => c.name.trim().isNotEmpty)
        .map((c) => c.name.trim())
        .toList();

    final merged = <String>{
      ...examSubjects,
      ...allDbSubjects,
      if (examSubjects.isEmpty && allDbSubjects.isEmpty)
        ...AiTestSubject.values.map((s) => s.label),
    }.toList();

    _subjectOptions = merged;
    if (examSubjects.isNotEmpty && !examSubjects.contains(_selectedSubjectName)) {
      _selectedSubjectName = examSubjects.first;
    } else if (!_subjectOptions.contains(_selectedSubjectName) && _subjectOptions.isNotEmpty) {
      _selectedSubjectName = _subjectOptions.first;
    }
    _syncSubSubjectsAndTopics(resetSubSubject: true);
  }

  void _syncSubSubjectsAndTopics({bool resetSubSubject = false}) {
    if (resetSubSubject) {
      _selectedSubSubject = _allSubSubjects;
      _selectedTopicName = _allTopics;
    }

    final selectedCat = _resolveSelectedCategoryModel();
    final subNames = <String>{};
    SubcategoryModel? selectedSubModel;

    if (selectedCat != null) {
      final matchingSubs = _dbSubcategories
          .where((s) => s.categoryId == selectedCat.id && s.name.trim().isNotEmpty)
          .toList();
      for (final s in matchingSubs) {
        subNames.add(s.name.trim());
      }
      // Also include chapter names saved on CategoryModel.topics when no subcategories rows exist
      if (matchingSubs.isEmpty) {
        for (final ch in selectedCat.topics) {
          if (ch.trim().isNotEmpty) subNames.add(ch.trim());
        }
      }

      if (_selectedSubSubject != _allSubSubjects) {
        selectedSubModel = matchingSubs.cast<SubcategoryModel?>().firstWhere(
              (s) => s != null && s.name.trim() == _selectedSubSubject,
              orElse: () => null,
            );
      }
    }

    _subSubjectOptions = [_allSubSubjects, ...subNames];
    if (!_subSubjectOptions.contains(_selectedSubSubject)) {
      _selectedSubSubject = _allSubSubjects;
      _selectedTopicName = _allTopics;
    }

    final topicNames = <String>{};
    if (selectedSubModel != null) {
      for (final t in _dbTopics) {
        if (t.subcategoryId == selectedSubModel.id && t.name.trim().isNotEmpty) {
          topicNames.add(t.name.trim());
        }
      }
    }
    if (topicNames.isEmpty && selectedCat != null) {
      for (final t in _dbTopics) {
        if (t.categoryId == selectedCat.id && t.name.trim().isNotEmpty) {
          topicNames.add(t.name.trim());
        }
      }
    }

    _topicOptions = [_allTopics, ...topicNames];
    if (!_topicOptions.contains(_selectedTopicName)) {
      _selectedTopicName = _allTopics;
    }
    _syncTopicFocusText();
  }

  void _syncTopicFocusText() {
    final parts = <String>[
      if (_selectedSubSubject != _allSubSubjects) _selectedSubSubject,
      if (_selectedTopicName != _allTopics) _selectedTopicName,
    ];
    final nextAuto = parts.join(' • ');
    final currentText = _topicController.text.trim();
    if (currentText.isEmpty || currentText == _lastAutoTopic) {
      _topicController.text = nextAuto;
    }
    _lastAutoTopic = nextAuto;
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
      final resolvedSubject = AiTestSubject.fromString(_selectedSubjectName);
      final effectiveSubjectLabel = _selectedSubSubject != _allSubSubjects
          ? '$_selectedSubjectName > $_selectedSubSubject'
          : _selectedSubjectName;
      final focusTopic = _topicController.text.trim().isNotEmpty
          ? _topicController.text.trim()
          : (_selectedTopicName != _allTopics
              ? _selectedTopicName
              : (_selectedSubSubject != _allSubSubjects
                  ? _selectedSubSubject
                  : _selectedSubjectName));
      final questions = await AiCreatorService().generateQuestions(
        title: _titleController.text.trim(),
        topic: focusTopic,
        subject: resolvedSubject,
        subjectLabel: effectiveSubjectLabel,
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
        subtitle: '$_selectedExam • $_selectedSubjectName',
        subject: resolvedSubject,
        customSubject: _selectedSubjectName,
        difficulty: _selectedDifficulty,
        questionCount: questions.length,
        durationMinutes: _durationMinutes,
        status: AiTestStatus.published,
        createdOn: DateTime.now(),
        createdBy: 'Admin',
        icon: resolvedSubject.icon,
        iconBgColor: resolvedSubject.color,
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
              AppModalDialog.secondaryButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              ),
              AppModalDialog.primaryButton(
                onPressed: _startGeneration,
                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                child: const Text('Generate with AI', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
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
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    backgroundColor: Color(0xFFFFF7ED),
                    valueColor: AlwaysStoppedAnimation<Color>(AppModalDialog.defaultPrimaryColor),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppModalDialog.defaultPrimaryColor.withAlpha(24),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppModalDialog.defaultPrimaryColor,
                    size: 28,
                  ),
                ),
              ],
            ),
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
              backgroundColor: const Color(0xFFFFF7ED),
              valueColor: const AlwaysStoppedAnimation<Color>(AppModalDialog.defaultPrimaryColor),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(_generationProgress * 100).toInt()}% completed',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppModalDialog.defaultPrimaryColor,
            ),
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
          TextFormField(
            controller: _titleController,
            decoration: AppModalDialog.inputDecoration(
              'E.G. Modern History Mock Test *',
              prefixIcon: const Icon(Icons.description_outlined, size: 17, color: Color(0xFF94A3B8)),
            ),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
            validator: (val) => val == null || val.trim().isEmpty ? 'Enter a test title' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppDropdown.simple(
                  label: 'Select Subject *',
                  inlineLabel: true,
                  value: _subjectOptions.contains(_selectedSubjectName)
                      ? _selectedSubjectName
                      : _subjectOptions.first,
                  items: _subjectOptions,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedSubjectName = val;
                        _syncSubSubjectsAndTopics(resetSubSubject: true);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdown.simple(
                  label: 'Difficulty Level *',
                  inlineLabel: true,
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
                  label: 'Sub-Subject / Chapter',
                  inlineLabel: true,
                  value: _subSubjectOptions.contains(_selectedSubSubject)
                      ? _selectedSubSubject
                      : _allSubSubjects,
                  items: _subSubjectOptions,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedSubSubject = val;
                        _selectedTopicName = _allTopics;
                        _syncSubSubjectsAndTopics(resetSubSubject: false);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdown.simple(
                  label: 'Curriculum Topic',
                  inlineLabel: true,
                  value: _topicOptions.contains(_selectedTopicName)
                      ? _selectedTopicName
                      : _allTopics,
                  items: _topicOptions,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedTopicName = val;
                        _syncTopicFocusText();
                      });
                    }
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
                  inlineLabel: true,
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
                  inlineLabel: true,
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
                  inlineLabel: true,
                  value: activeExam,
                  items: _examOptions,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedExam = val;
                        _syncSubjectOptionsForSelectedExam();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdown.simple(
                  label: 'Language Mode',
                  inlineLabel: true,
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
          TextFormField(
            controller: _topicController,
            maxLines: 2,
            decoration: AppModalDialog.inputDecoration(
              'Topics / Syllabus Focus (optional)...',
              isMultiline: true,
            ),
            style: const TextStyle(fontSize: 12.5),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _customPromptController,
            maxLines: 2,
            decoration: AppModalDialog.inputDecoration(
              'Optional instructions for question style...',
              isMultiline: true,
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
                  activeColor: AppModalDialog.defaultPrimaryColor,
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
                  activeColor: AppModalDialog.defaultPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
