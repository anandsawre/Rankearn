import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import '../models/exam_icon_helper.dart';

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
  final ExamCategoryModel? initialExamToEdit;

  const ManageTargetExamsDialog({
    super.key,
    this.onExamsUpdated,
    this.initialExamToEdit,
  });

  @override
  State<ManageTargetExamsDialog> createState() => _ManageTargetExamsDialogState();
}

class _ManageTargetExamsDialogState extends State<ManageTargetExamsDialog> {
  static const Color _primaryPurple = Color(0xFFFF9500);
  static const Color _textNavy = Color(0xFF101A3A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _borderSubtle = Color(0xFFCBD5E1);
  static const Color _fillBg = Color(0xFFF8FAFC);

  final _testsRepo = TestsRepository();
  final _categoriesRepo = CategoriesRepository();

  bool _isLoading = true;
  String? _errorMessage;
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

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _slugCtrl = TextEditingController();
    _iconCtrl = TextEditingController(text: 'school');
    _orderCtrl = TextEditingController(text: '1');

    _nameCtrl.addListener(() {
      if (_editingExam == null && _slugCtrl.text.isEmpty) {
        _slugCtrl.text = _nameCtrl.text
            .toLowerCase()
            .trim()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      }
    });

    _loadExams().then((_) {
      if (widget.initialExamToEdit != null && mounted) {
        _startEdit(widget.initialExamToEdit!);
      }
    });
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (!mounted) return;
      setState(() {
        _exams = [];
        _isLoading = false;
        _errorMessage = 'Database connection is not initialized.';
      });
      return;
    }

    final res = await _categoriesRepo.getExamCategories();
    if (!mounted) return;

    if (res is Success<List<ExamCategoryModel>>) {
      final mockCounts = <String, int>{};
      final sectionalCounts = <String, int>{};
      final totalCounts = <String, int>{};
      try {
        final testsRows = await client
            .from('tests')
            .select('exam_category_id, test_mode');
        for (final t in (testsRows as List)) {
          final eid = t['exam_category_id']?.toString() ?? '';
          final mode = t['test_mode']?.toString() ?? 'mock';
          if (eid.isNotEmpty) {
            totalCounts[eid] = (totalCounts[eid] ?? 0) + 1;
            if (mode == 'mock') {
              mockCounts[eid] = (mockCounts[eid] ?? 0) + 1;
            } else if (mode == 'sectional') {
              sectionalCounts[eid] = (sectionalCounts[eid] ?? 0) + 1;
            }
          }
        }
      } catch (_) {}

      if (!mounted) return;
      final enriched = res.data
          .map(
            (e) => e.copyWith(
              totalTests: totalCounts[e.id] ?? 0,
              totalMocks: mockCounts[e.id] ?? 0,
              totalSectional: sectionalCounts[e.id] ?? 0,
            ),
          )
          .toList();

      setState(() {
        _exams = enriched;
        _isLoading = false;
      });
    } else if (res is Failure<List<ExamCategoryModel>>) {
      setState(() {
        _exams = [];
        _isLoading = false;
        _errorMessage = res.message;
      });
    }
  }

  void _startCreateNew() {
    setState(() {
      _editingExam = null;
      _nameCtrl.clear();
      _slugCtrl.clear();
      _iconCtrl.text = 'school';
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
    _iconCtrl.text = (exam.iconUrl != null && exam.iconUrl!.trim().isNotEmpty)
        ? exam.iconUrl!.trim()
        : 'school';
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
        final chaptersList = subs.isNotEmpty
            ? subs.map((s) => s.name.trim()).where((s) => s.isNotEmpty).toList()
            : cat.topics;

        final topicsRes = await _categoriesRepo.getTopics(categoryId: cat.id);
        final topicList = (topicsRes.dataOrNull ?? [])
            .map((t) => t.name.trim())
            .where((t) => t.isNotEmpty)
            .toList();

        _subjectDrafts.add(
          SubjectDraft(
            name: cat.name,
            chapters: chaptersList.join(', '),
            topics: topicList.join(', '),
          ),
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
    final icon = _iconCtrl.text.trim().isNotEmpty ? _iconCtrl.text.trim() : 'school';
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
    final examSaveRes = await _testsRepo.upsertExamCategory(model);
    if (!mounted) return;
    if (examSaveRes is Failure<ExamCategoryModel>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(examSaveRes.message),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    // 2. Save all Dynamic Subjects & Chapters under this exam into `categories`
    int validSubjectsSaved = 0;
    for (int i = 0; i < _subjectDrafts.length; i++) {
      final draft = _subjectDrafts[i];
      final subjectName = draft.nameCtrl.text.trim();
      if (subjectName.isEmpty) continue;

      final subjectSlug = subjectName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      final subjectId = 'cat-$id-$subjectSlug';

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

      final catModel = CategoryModel(
        id: subjectId,
        examCategoryId: id,
        name: subjectName,
        slug: subjectSlug,
        description: '$subjectName syllabus for $name',
        topics: rawChapters,
        subcategoriesCount: rawChapters.length,
        displayOrder: i + 1,
        status: _isPublished ? 'active' : 'draft',
        createdAt: DateTime.now(),
      );
      final catRes = await _categoriesRepo.upsertCategory(catModel);
      if (catRes is Success<CategoryModel>) {
        validSubjectsSaved++;

        // Persist Chapters/Units into `subcategories`
        String? primarySubId;
        final chaptersToSave = rawChapters.isNotEmpty
            ? rawChapters
            : (rawTopics.isNotEmpty ? ['General'] : <String>[]);
        for (int cIdx = 0; cIdx < chaptersToSave.length; cIdx++) {
          final chapterName = chaptersToSave[cIdx];
          final chapterSlug = chapterName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
          final subId = 'sub-$subjectId-$chapterSlug';
          primarySubId ??= subId;
          await _categoriesRepo.upsertSubcategory(
            SubcategoryModel(
              id: subId,
              categoryId: subjectId,
              name: chapterName,
              slug: chapterSlug,
              description: '$chapterName under $subjectName',
              displayOrder: cIdx + 1,
              status: _isPublished ? 'active' : 'draft',
              createdAt: DateTime.now(),
            ),
          );
        }

        // Persist Topics into `topics`
        if (rawTopics.isNotEmpty && primarySubId != null) {
          for (int tIdx = 0; tIdx < rawTopics.length; tIdx++) {
            final topicName = rawTopics[tIdx];
            final topicSlug = topicName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
            await _categoriesRepo.upsertTopic(
              TopicModel(
                id: 'top-$subjectId-$topicSlug',
                subcategoryId: primarySubId,
                categoryId: subjectId,
                name: topicName,
                slug: topicSlug,
                description: '$topicName under $subjectName',
                displayOrder: tIdx + 1,
                status: _isPublished ? 'active' : 'draft',
                createdAt: DateTime.now(),
              ),
            );
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
    final confirmed = await AppModalDialog.show<bool>(
      context: context,
      builder: (ctx) => AppModalDialog(
        title: 'Delete Target Exam',
        subtitle: 'Permanent deletion warning',
        iconData: Icons.delete_outline_rounded,
        gradientColors: const [Color(0xFFDC2626), Color(0xFFEF4444)],
        maxWidth: 440,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _textMuted, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Are you sure you want to delete "${exam.name}" (${exam.id})? This will also unlink its assigned subjects.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    final delRes = await _testsRepo.deleteExamCategory(exam.id);
    if (!mounted) return;
    if (delRes is Failure<bool>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(delRes.message),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

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

    return AppModalDialog(
      title: _isCreatingOrEditing
          ? (isEditing ? 'Edit Target Exam & Subjects' : 'Create Target Exam & Subjects')
          : 'Target Exams (Level 1 Categories)',
      subtitle: _isCreatingOrEditing
          ? 'Configure exam identity and curriculum structure'
          : '${_exams.length} target exams configured for student test explorer',
      iconData: _isCreatingOrEditing
          ? (isEditing ? Icons.edit_rounded : Icons.add_rounded)
          : Icons.explore_rounded,
      gradientColors: const [Color(0xFFFF9500), Color(0xFFF59E0B)],
      maxWidth: 620,
      maxHeight: 740,
      contentPadding: _isCreatingOrEditing
          ? const EdgeInsets.fromLTRB(22, 14, 22, 22)
          : null,
      scrollable: true,
      actions: _isCreatingOrEditing
          ? [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: _cancelForm,
                child: const Text('Cancel', style: TextStyle(color: _textMuted, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  elevation: 0,
                ),
                onPressed: _saveExam,
                child: Text(
                  isEditing ? 'Save Changes' : 'Save Exam & Subjects',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ]
          : [
              Text(
                '${_exams.length} Target Exams configured',
                style: const TextStyle(
                  fontSize: 12,
                  color: _textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Target Exam', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
      child: _isCreatingOrEditing ? _buildForm() : _buildExamList(),
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

    if (_errorMessage != null) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 32, color: Color(0xFFDC2626)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9F1239), fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _loadExams,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
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

  Widget _buildExamIcon(String? iconUrl) => buildExamIconWidget(iconUrl, size: 20);

  Widget _buildForm() {
    final isEditing = _editingExam != null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
            // Exam Name
            TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
              decoration: AppModalDialog.inputDecoration(
                'Exam Name * (e.g. 70th BPSC Prelims, SSC CGL)',
                prefixIcon: const Icon(Icons.school_outlined, size: 17, color: Color(0xFF94A3B8)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Exam name is required' : null,
            ),
            const SizedBox(height: 12),

            // Slug / ID & Display Order Row
            Row(
              children: [
                Expanded(
                  flex: 65,
                  child: TextFormField(
                    controller: _slugCtrl,
                    enabled: !isEditing, // Immutable ID when editing
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B)),
                    decoration: AppModalDialog.inputDecoration(
                      'Unique ID / Slug * (e.g. bpsc-70th)',
                      prefixIcon: const Icon(Icons.link_rounded, size: 16, color: Color(0xFF94A3B8)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'ID is required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 35,
                  child: TextFormField(
                    controller: _orderCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                    decoration: AppModalDialog.inputDecoration(
                      'Order (1)',
                      suffixText: 'order',
                      suffixStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Exam Icon Picker (Material Icons)
            const Text('Exam Icon', style: _labelStyle),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _primaryPurple.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _primaryPurple.withAlpha(110), width: 1.4),
                  ),
                  alignment: Alignment.center,
                  child: buildExamIconWidget(_iconCtrl.text, size: 22, color: _primaryPurple),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: kExamIconOptions.map((option) {
                        final isSelected = _iconCtrl.text.trim() == option.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Tooltip(
                            message: option.label,
                            child: InkWell(
                              onTap: () => setState(() => _iconCtrl.text = option.key),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isSelected ? _primaryPurple.withAlpha(24) : _fillBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? _primaryPurple : _borderSubtle,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  option.icon,
                                  size: 18,
                                  color: isSelected ? _primaryPurple : _textMuted,
                                ),
                              ),
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
            AppDropdown<bool>(
              value: _isPublished,
              inlineLabel: true,
              hint: 'Publication Status',
              isDense: true,
              fillColor: Colors.white,
              borderColor: const Color(0xFFE2E8F0),
              focusedBorderColor: _primaryPurple,
              selectedItemColor: _primaryPurple,
              selectedItemBackgroundColor: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
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
    );
  }

  Widget _buildCurriculumSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _primaryPurple.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _primaryPurple.withAlpha(40)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _primaryPurple,
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
                            color: _primaryPurple.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _primaryPurple,
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
                TextFormField(
                  controller: draft.nameCtrl,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B)),
                  decoration: _inputDecoration('Subject Name (e.g. General Science, Mathematics)'),
                ),
                const SizedBox(height: 10),

                // Chapters / Subcategories
                TextFormField(
                  controller: draft.chaptersCtrl,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B)),
                  decoration: _inputDecoration('Chapters / Units, comma separated (e.g. Physics, Chemistry)'),
                ),
                const SizedBox(height: 10),

                // Topics (Optional)
                TextFormField(
                  controller: draft.topicsCtrl,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B)),
                  decoration: _inputDecoration('Topics (optional, comma separated e.g. Optics, Motion)'),
                ),
              ],
            ),
          );
        }),

        // + Add Another Subject Button (tokenized via AppModalDialog)
        AppModalDialog.secondaryButton(
          icon: const Icon(Icons.add_rounded, size: 15),
          foregroundColor: _primaryPurple,
          borderColor: _primaryPurple.withAlpha(110),
          child: const Text(
            'Add Another Subject',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

  InputDecoration _inputDecoration(String hint) =>
      AppModalDialog.inputDecoration(hint, focusColor: _primaryPurple);
}
