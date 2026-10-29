import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

/// Class to hold in-memory draft state for each subject added under a target exam
class SubjectDraft {
  final TextEditingController nameCtrl;
  final TextEditingController chaptersCtrl;
  final TextEditingController topicsCtrl;

  SubjectDraft({
    String name = '',
    String chapters = '',
    String topics = '',
  })  : nameCtrl = TextEditingController(text: name),
        chaptersCtrl = TextEditingController(text: chapters),
        topicsCtrl = TextEditingController(text: topics);

  void dispose() {
    nameCtrl.dispose();
    chaptersCtrl.dispose();
    topicsCtrl.dispose();
  }
}

class ManageTargetExamsDialog extends StatefulWidget {
  final VoidCallback? onExamsUpdated;

  const ManageTargetExamsDialog({
    super.key,
    this.onExamsUpdated,
  });

  @override
  State<ManageTargetExamsDialog> createState() => _ManageTargetExamsDialogState();
}

class _ManageTargetExamsDialogState extends State<ManageTargetExamsDialog> {
  static const Color _primaryPurple = Color(0xFF5636F5);
  static const Color _textNavy = Color(0xFF101A3A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _borderSubtle = Color(0xFFE2E8F0);
  static const Color _fillBg = Color(0xFFF8FAFC);

  final _testsRepo = TestsRepository();
  final _categoriesRepo = CategoriesRepository();

  bool _isLoading = true;
  List<ExamCategoryModel> _exams = [];

  // Form state for creating / editing
  bool _isCreatingOrEditing = false;
  ExamCategoryModel? _editingExam;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _slugCtrl;
  late final TextEditingController _iconCtrl;
  late final TextEditingController _orderCtrl;
  bool _isPublished = true;

  // Dynamic Curriculum: Multiple Subjects under this exam (Tareeqa 1)
  List<SubjectDraft> _subjectDrafts = [];

  final List<String> _popularIcons = const [
    '🏛️', '📋', '🇮🇳', '🚆', '🏦', '🎖️', '📚', '⚖️', '🎯', '🔬', '🩺', '⚡', '🏆', '🌍'
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _slugCtrl = TextEditingController();
    _iconCtrl = TextEditingController(text: '🎯');
    _orderCtrl = TextEditingController(text: '1');

    _nameCtrl.addListener(() {
      if (_editingExam == null && _slugCtrl.text.isEmpty) {
        _slugCtrl.text = _nameCtrl.text
            .toLowerCase()
            .trim()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      }
    });

    _loadExams();
  }

  void _clearSubjectDrafts() {
    for (final d in _subjectDrafts) {
      d.dispose();
    }
    _subjectDrafts.clear();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _iconCtrl.dispose();
    _orderCtrl.dispose();
    _clearSubjectDrafts();
    super.dispose();
  }

  Future<void> _loadExams() async {
    setState(() => _isLoading = true);
    final res = await _testsRepo.getExamCategoryList();
    if (!mounted) return;

    if (res is Success<List<ExamCategoryModel>> && res.data.isNotEmpty) {
      setState(() {
        _exams = List<ExamCategoryModel>.from(res.data);
        _isLoading = false;
      });
    } else {
      setState(() {
        _exams = [
          const ExamCategoryModel(
            id: 'bpsc',
            name: 'BPSC & State PCS',
            normalizedName: 'bpsc',
            iconUrl: '🏛️',
            displayOrder: 1,
            isPublished: true,
          ),
          const ExamCategoryModel(
            id: 'ssc',
            name: 'SSC CGL & CHSL',
            normalizedName: 'ssc',
            iconUrl: '📋',
            displayOrder: 2,
            isPublished: true,
          ),
          const ExamCategoryModel(
            id: 'upsc',
            name: 'UPSC Civil Services',
            normalizedName: 'upsc',
            iconUrl: '🇮🇳',
            displayOrder: 3,
            isPublished: true,
          ),
          const ExamCategoryModel(
            id: 'railway',
            name: 'RRB NTPC & Group D',
            normalizedName: 'railway',
            iconUrl: '🚆',
            displayOrder: 4,
            isPublished: true,
          ),
          const ExamCategoryModel(
            id: 'banking',
            name: 'Banking & Insurance',
            normalizedName: 'banking',
            iconUrl: '🏦',
            displayOrder: 5,
            isPublished: true,
          ),
        ];
        _isLoading = false;
      });
    }
  }

  void _startCreateNew() {
    setState(() {
      _editingExam = null;
      _nameCtrl.clear();
      _slugCtrl.clear();
      _iconCtrl.text = '🎯';
      _orderCtrl.text = (_exams.length + 1).toString();
      _isPublished = true;
      _clearSubjectDrafts();
      _subjectDrafts = [
        SubjectDraft(name: '', chapters: '', topics: ''),
      ];
      _isCreatingOrEditing = true;
    });
  }

  Future<void> _startEdit(ExamCategoryModel exam) async {
    _editingExam = exam;
    _nameCtrl.text = exam.name;
    _slugCtrl.text = exam.id;
    _iconCtrl.text = exam.iconUrl ?? '🎯';
    _orderCtrl.text = exam.displayOrder.toString();
    _isPublished = exam.isPublished;

    _clearSubjectDrafts();

    // Fetch existing subjects for this exam from repository
    final catsRes = await _categoriesRepo.getCategories(examCategoryId: exam.id);
    final cats = catsRes.dataOrNull ?? [];

    if (cats.isNotEmpty) {
      for (final cat in cats) {
        final subsRes = await _categoriesRepo.getSubcategories(categoryId: cat.id);
        final subs = subsRes.dataOrNull ?? [];
        final chapters = subs.map((s) => s.name).join(', ');
        _subjectDrafts.add(
          SubjectDraft(name: cat.name, chapters: chapters, topics: ''),
        );
      }
    } else {
      _subjectDrafts = [
        SubjectDraft(name: '', chapters: '', topics: ''),
      ];
    }

    if (!mounted) return;
    setState(() {
      _isCreatingOrEditing = true;
    });
  }

  void _cancelForm() {
    setState(() {
      _isCreatingOrEditing = false;
      _editingExam = null;
      _clearSubjectDrafts();
    });
  }

  Future<void> _saveExam() async {
    if (!_formKey.currentState!.validate()) return;

    final id = _slugCtrl.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final name = _nameCtrl.text.trim();
    final icon = _iconCtrl.text.trim().isNotEmpty ? _iconCtrl.text.trim() : '🎯';
    final order = int.tryParse(_orderCtrl.text.trim()) ?? (_exams.length + 1);

    final model = ExamCategoryModel(
      id: id,
      name: name,
      normalizedName: id,
      iconUrl: icon,
      displayOrder: order,
      isPublished: _isPublished,
    );

    // 1. Save Target Exam
    await _testsRepo.upsertExamCategory(model);

    // 2. Save all Dynamic Subjects & Chapters under this exam (Tareeqa 1)
    int validSubjectsSaved = 0;
    for (int i = 0; i < _subjectDrafts.length; i++) {
      final draft = _subjectDrafts[i];
      final subjectName = draft.nameCtrl.text.trim();
      if (subjectName.isEmpty) continue;

      final subjectSlug = subjectName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      final subjectId = 'cat-$id-$subjectSlug';

      final catModel = CategoryModel(
        id: subjectId,
        examCategoryId: id,
        name: subjectName,
        slug: subjectSlug,
        description: '$subjectName syllabus for $name',
        displayOrder: i + 1,
        status: _isPublished ? 'active' : 'draft',
        createdAt: DateTime.now(),
      );
      await _categoriesRepo.upsertCategory(catModel);
      validSubjectsSaved++;

      // Chapters (Subcategories)
      final rawChapters = draft.chaptersCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final rawTopics = draft.topicsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      for (int cIdx = 0; cIdx < rawChapters.length; cIdx++) {
        final chapterName = rawChapters[cIdx];
        final chapterSlug = chapterName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
        final chapterId = 'sub-$subjectId-$chapterSlug';

        final subModel = SubcategoryModel(
          id: chapterId,
          categoryId: subjectId,
          name: chapterName,
          slug: chapterSlug,
          displayOrder: cIdx + 1,
          status: _isPublished ? 'active' : 'draft',
          createdAt: DateTime.now(),
        );
        await _categoriesRepo.upsertSubcategory(subModel);

        // Topics
        if (rawTopics.isNotEmpty) {
          for (int tIdx = 0; tIdx < rawTopics.length; tIdx++) {
            final topicName = rawTopics[tIdx];
            final topicSlug = topicName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
            final topicId = 'top-$chapterId-$topicSlug';

            final topicModel = TopicModel(
              id: topicId,
              subcategoryId: chapterId,
              categoryId: subjectId,
              name: topicName,
              slug: topicSlug,
              displayOrder: tIdx + 1,
              status: _isPublished ? 'active' : 'draft',
              createdAt: DateTime.now(),
            );
            await _categoriesRepo.upsertTopic(topicModel);
          }
        }
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_editingExam == null
            ? 'Created "$name" with $validSubjectsSaved subjects successfully!'
            : 'Updated "$name" curriculum!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );

    _cancelForm();
    _loadExams();
    widget.onExamsUpdated?.call();
  }

  Future<void> _deleteExam(ExamCategoryModel exam) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Target Exam?'),
        content: Text('Are you sure you want to delete "${exam.name}" (${exam.id})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF43F5E)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _testsRepo.deleteExamCategory(exam.id);
    if (!mounted) return;

    setState(() {
      _exams = List<ExamCategoryModel>.from(_exams)..removeWhere((e) => e.id == exam.id);
    });

    widget.onExamsUpdated?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${exam.name}"'),
        backgroundColor: const Color(0xFFF43F5E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingExam != null;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 640;

    // 📱 MOBILE FULL-SCREEN MODE ONLY ON MOBILE
    if (isMobile) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: Colors.white,
        child: SizedBox.expand(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _primaryPurple,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _isCreatingOrEditing
                                    ? (isEditing ? Icons.edit_rounded : Icons.add_rounded)
                                    : Icons.explore_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isCreatingOrEditing
                                        ? (isEditing ? 'Edit Target Exam & Subjects' : 'New Target Exam & Subjects')
                                        : 'Target Exams (Level 1 Categories)',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _textNavy,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (!_isCreatingOrEditing)
                                    const Text(
                                      'Exams that appear on the user test series explorer',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _textMuted,
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
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Content Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _isCreatingOrEditing ? _buildForm() : _buildExamList(),
                  ),
                ),

                // Mobile Footer
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: _isCreatingOrEditing
                      ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _cancelForm,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Cancel', style: TextStyle(color: _textMuted, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  elevation: 0,
                                ),
                                onPressed: _saveExam,
                                child: Text(
                                  isEditing ? 'Save Changes' : 'Save Exam & Subjects',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Text(
                                '${_exams.length} Target Exams configured',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add Target Exam'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryPurple,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _startCreateNew,
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

    // 💻 DESKTOP: EXACT UNTOUCHED ORIGINAL AlertDialog!
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _primaryPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _isCreatingOrEditing
                        ? (isEditing ? Icons.edit_rounded : Icons.add_rounded)
                        : Icons.explore_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCreatingOrEditing
                            ? (isEditing ? 'Edit Target Exam & Subjects' : 'Create Target Exam & Subjects')
                            : 'Target Exams (Level 1 Categories)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _textNavy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!_isCreatingOrEditing)
                        const Text(
                          'Exams that appear on the user test series explorer',
                          style: TextStyle(
                            fontSize: 11,
                            color: _textMuted,
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
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: _isCreatingOrEditing ? _buildForm() : _buildExamList(),
      ),
      actions: _isCreatingOrEditing
          ? [
              TextButton(
                onPressed: _cancelForm,
                child: const Text('Cancel', style: TextStyle(color: _textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 0,
                ),
                onPressed: _saveExam,
                child: Text(
                  isEditing ? 'Save Changes' : 'Save Exam & Subjects',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ]
          : [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    '${_exams.length} Target Exams configured',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add Target Exam'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _startCreateNew,
                  ),
                ],
              ),
            ],
    );
  }

  Widget _buildExamList() {
    if (_isLoading) {
      return const SizedBox(
        height: 280,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: _primaryPurple),
        ),
      );
    }

    if (_exams.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No target exams configured yet.', style: TextStyle(color: _textMuted)),
        ),
      );
    }

    return SizedBox(
      height: 380,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _exams.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final exam = _exams[index];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _fillBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderSubtle),
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _borderSubtle),
                  ),
                  alignment: Alignment.center,
                  child: _buildExamIcon(exam.iconUrl),
                ),
                const SizedBox(width: 12),

                // Title and details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            exam.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: _textNavy,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ID: ${exam.id}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _primaryPurple,
                              ),
                            ),
                          ),
                          if (!exam.isPublished)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Hidden',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Order: ${exam.displayOrder}  •  ${exam.totalTests} Tests (${exam.totalMocks} Mocks, ${exam.totalSectional} Sectional)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Action buttons
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                  tooltip: 'Edit',
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: const EdgeInsets.all(4),
                  onPressed: () => _startEdit(exam),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFF43F5E)),
                  tooltip: 'Delete',
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: const EdgeInsets.all(4),
                  onPressed: () => _deleteExam(exam),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExamIcon(String? iconUrl) {
    if (iconUrl == null || iconUrl.trim().isEmpty) {
      return const Text('🎯', style: TextStyle(fontSize: 18));
    }
    final clean = iconUrl.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          clean,
          width: 22,
          height: 22,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Text('🎯', style: TextStyle(fontSize: 18)),
        ),
      );
    }
    if (clean.startsWith('assets/')) {
      return Image.asset(
        clean,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Text('🎯', style: TextStyle(fontSize: 18)),
      );
    }
    return Text(
      clean,
      style: const TextStyle(fontSize: 18),
    );
  }

  Widget _buildForm() {
    final isEditing = _editingExam != null;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),

            // Exam Name
            const Text('Exam Name', style: _labelStyle),
            const SizedBox(height: 4),
            TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
              decoration: _inputDecoration('e.g. 70th BPSC Prelims, SSC CGL 2026, Railway NTPC'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Exam name is required' : null,
            ),
            const SizedBox(height: 12),

            // Slug / ID & Display Order Row
            Row(
              children: [
                Expanded(
                  flex: 65,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Unique ID / Slug (used in URL)', style: _labelStyle),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _slugCtrl,
                        enabled: !isEditing, // Immutable ID when editing
                        style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                        decoration: _inputDecoration('e.g. bpsc-70th, ssc-cgl, railway-ntpc'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'ID is required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 35,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Display Order', style: _labelStyle),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _orderCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                        decoration: _inputDecoration('1'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Icon / Emoji
            const Text('Exam Icon (Emoji or Image URL)', style: _labelStyle),
            const SizedBox(height: 4),
            Row(
              children: [
                SizedBox(
                  width: 70,
                  child: TextFormField(
                    controller: _iconCtrl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                    decoration: _inputDecoration('🎯'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _popularIcons.map((emoji) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => setState(() => _iconCtrl.text = emoji),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: _fillBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: _borderSubtle),
                              ),
                              child: Text(emoji, style: const TextStyle(fontSize: 15)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Visibility Status Dropdown
            const Text('Publication Status', style: _labelStyle),
            const SizedBox(height: 4),
            AppDropdown<bool>(
              value: _isPublished,
              isDense: true,
              fillColor: const Color(0xFFF8FAFC),
              borderColor: const Color(0xFFE2E8F0),
              focusedBorderColor: const Color(0xFF5636F5),
              selectedItemColor: const Color(0xFF5636F5),
              selectedItemBackgroundColor: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9.5),
              items: [
                AppDropdownItem<bool>(
                  value: true,
                  label: 'Published (Visible in User App)',
                  leading: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                  ),
                ),
                AppDropdownItem<bool>(
                  value: false,
                  label: 'Hidden (Draft / Disabled)',
                  leading: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Color(0xFF94A3B8), shape: BoxShape.circle),
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _isPublished = val);
              },
            ),
            const SizedBox(height: 18),

            // ==========================================
            // TAREEQA 1: DYNAMIC SUBJECTS & CHAPTERS SECTION
            // ==========================================
            _buildCurriculumSection(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildCurriculumSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF5636F5).withAlpha(15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF5636F5).withAlpha(40)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF5636F5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'EXAM CURRICULUM',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Subjects, Chapters & Topics',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _textNavy,
                ),
              ),
              const Spacer(),
              Text(
                '${_subjectDrafts.length} ${_subjectDrafts.length == 1 ? 'Subject' : 'Subjects'}',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: _primaryPurple,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Is exam ke andar jitne chahein subjects aur unke chapters yahan ek sath add karein:',
          style: TextStyle(fontSize: 11, color: _textMuted),
        ),
        const SizedBox(height: 10),

        // Subject Cards
        ..._subjectDrafts.asMap().entries.map((entry) {
          final index = entry.key;
          final draft = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5636F5).withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF5636F5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Subject #${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _textNavy,
                          ),
                        ),
                      ],
                    ),
                    if (_subjectDrafts.length > 1)
                      InkWell(
                        onTap: () {
                          setState(() {
                            final removed = _subjectDrafts.removeAt(index);
                            removed.dispose();
                          });
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Subject Name
                const Text('Subject Name', style: _labelStyle),
                const SizedBox(height: 4),
                TextFormField(
                  controller: draft.nameCtrl,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                  decoration: _inputDecoration('e.g. General Science, Indian History, Mathematics'),
                ),
                const SizedBox(height: 8),

                // Chapters / Subcategories
                const Text('Chapters / Units (Comma Separated)', style: _labelStyle),
                const SizedBox(height: 4),
                TextFormField(
                  controller: draft.chaptersCtrl,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                  decoration: _inputDecoration('e.g. Physics, Chemistry, Biology'),
                ),
                const SizedBox(height: 8),

                // Topics (Optional)
                const Text('Topics (Comma Separated - Optional)', style: _labelStyle),
                const SizedBox(height: 4),
                TextFormField(
                  controller: draft.topicsCtrl,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                  decoration: _inputDecoration('e.g. Laws of Motion, Optics, Periodic Table'),
                ),
              ],
            ),
          );
        }),

        // + Add Another Subject Button
        OutlinedButton.icon(
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Add Another Subject'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _primaryPurple,
            side: const BorderSide(color: Color(0xFFC7D2FE)),
            backgroundColor: const Color(0xFFEEF2FF),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            setState(() {
              _subjectDrafts.add(SubjectDraft(name: '', chapters: '', topics: ''));
            });
          },
        ),
      ],
    );
  }

  static const _labelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1E293B),
  );

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: _fillBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _borderSubtle),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: _primaryPurple, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}
