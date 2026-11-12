import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import '../../categories/models/exam_icon_helper.dart';
import '../models/test_series_item.dart';

class AddTestPaperDialog extends StatefulWidget {
  final List<TestSeriesItem> existingSeries;
  final ValueChanged<TestSeriesItem> onSave;

  const AddTestPaperDialog({
    super.key,
    required this.existingSeries,
    required this.onSave,
  });

  @override
  State<AddTestPaperDialog> createState() => _AddTestPaperDialogState();
}

class _AddTestPaperDialogState extends State<AddTestPaperDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _durationController;
  late final TextEditingController _questionsCountController;
  late final TextEditingController _negativeMarkingController;
  late final TextEditingController _priceCoinsController;
  late final TextEditingController _topicController;

  String? _examCategoryId;
  String _testMode = 'mock';
  String? _selectedSubject;
  TestSeriesStatus _status = TestSeriesStatus.published;
  bool _isPremium = false;

  List<ExamCategoryModel> _examList = [];
  List<String> _subjects = [];
  bool _isLoadingMeta = true;

  static const List<Map<String, String>> _modes = [
    {'value': 'mock', 'label': 'Full Mock Test'},
    {'value': 'sectional', 'label': 'Sectional / Subject Test'},
    {'value': 'previous-year', 'label': 'Previous Year Paper (PYQ)'},
    {'value': 'tournament', 'label': 'Tournament Paper'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _durationController = TextEditingController(text: '60');
    _questionsCountController = TextEditingController(text: '50');
    _negativeMarkingController = TextEditingController(text: '0.25');
    _priceCoinsController = TextEditingController(text: '0');
    _topicController = TextEditingController();

    _fetchMetadata();
  }

  Future<void> _fetchMetadata() async {
    final existingSubjects = widget.existingSeries
        .map((s) => s.subject.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) {
        setState(() {
          _subjects = existingSubjects;
          _selectedSubject = _subjects.isNotEmpty ? _subjects.first : null;
          _isLoadingMeta = false;
        });
      }
      return;
    }

    List<ExamCategoryModel> exams = [];
    try {
      final examRows = await client
          .from('exam_categories')
          .select()
          .order('display_order', ascending: true);
      exams = (examRows as List)
          .map((m) => ExamCategoryModel.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList();
    } catch (e) {
      debugPrint('Error fetching exam_categories for AddTestPaperDialog: $e');
    }

    var dbSubjects = <String>[...existingSubjects];
    try {
      final catRows = List<Map<String, dynamic>>.from(
        await client.from('categories').select('name').order('display_order') as List,
      );
      dbSubjects = <String>{
        ...catRows
            .map((r) => r['name']?.toString().trim() ?? '')
            .where((n) => n.isNotEmpty),
        ...existingSubjects,
      }.toList();
    } catch (e) {
      debugPrint('Error fetching categories for AddTestPaperDialog: $e');
    }

    if (!mounted) return;
    setState(() {
      _examList = exams;
      _examCategoryId = _examList.isNotEmpty ? _examList.first.id : null;
      _subjects = dbSubjects;
      _selectedSubject = _subjects.isNotEmpty ? _subjects.first : null;
      _isLoadingMeta = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _questionsCountController.dispose();
    _negativeMarkingController.dispose();
    _priceCoinsController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final duration = int.tryParse(_durationController.text.trim()) ?? 60;
    final questions = int.tryParse(_questionsCountController.text.trim()) ?? 50;
    final negMark = double.tryParse(_negativeMarkingController.text.trim()) ?? 0.25;
    final price = _isPremium ? (int.tryParse(_priceCoinsController.text.trim()) ?? 0) : 0;

    final now = DateTime.now();
    final newId = 'paper_${now.millisecondsSinceEpoch}';

    final newItem = TestSeriesItem(
      id: newId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      examCategoryId: _examCategoryId,
      totalTests: 1,
      totalQuestions: questions,
      durationMinutes: duration,
      negativeMarking: negMark,
      priceInr: price,
      entryFeeCoins: 0,
      enrollments: 0,
      status: _status,
      testMode: _testMode,
      subject: _selectedSubject ?? 'General',
      topic: _topicController.text.trim().isNotEmpty ? _topicController.text.trim() : null,
      isPremium: _isPremium,
      createdAt: now,
      icon: Icons.description_outlined,
      iconColor: const Color(0xFF0084FF),
    );

    widget.onSave(newItem);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Add Test Paper',
      subtitle: 'Create a standalone mock test paper or practice test',
      iconData: Icons.description_outlined,
      gradientColors: const [Color(0xFFFF9500), Color(0xFFF59E0B)],
      maxWidth: 620,
      scrollable: true,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12.5)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9500),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          onPressed: _submit,
          child: const Text('Add Test Paper', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Target Exam & Test Mode
            Row(
              children: [
                Expanded(
                  child: AppDropdown<String>(
                    value: _examList.any((e) => e.id == _examCategoryId) ? _examCategoryId : null,
                    inlineLabel: true,
                    hint: _isLoadingMeta
                        ? 'Loading exams...'
                        : (_examList.isEmpty
                            ? 'No exams found (Optional)'
                            : 'Select Target Exam (Optional)...'),
                    items: _examList
                        .map((e) => AppDropdownItem(
                              value: e.id,
                              label: e.name,
                              leading: buildExamIconWidget(e.iconUrl, size: 16),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _examCategoryId = val),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AppDropdown<String>(
                    value: _testMode,
                    inlineLabel: true,
                    hint: 'Test Paper Mode *',
                    items: _modes
                        .map((m) => AppDropdownItem(value: m['value']!, label: m['label']!))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _testMode = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Paper Title & Description
            TextFormField(
              controller: _titleController,
              decoration: AppModalDialog.inputDecoration(
                'Test Paper Title * (e.g. RRB Technician Mock 01)',
                prefixIcon: const Icon(Icons.description_outlined, size: 17, color: Color(0xFF94A3B8)),
              ),
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
              validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descController,
              maxLines: 2,
              decoration: AppModalDialog.inputDecoration(
                'Syllabus / Description (coverage & instructions)...',
                isMultiline: true,
              ),
              style: const TextStyle(fontSize: 12.5),
            ),
            const SizedBox(height: 12),

            // Row 2: Subject & Topic
            Row(
              children: [
                Expanded(
                  child: AppDropdown<String>(
                    value: _subjects.contains(_selectedSubject) ? _selectedSubject : null,
                    inlineLabel: true,
                    hint: _isLoadingMeta ? 'Loading subjects...' : 'Select Subject...',
                    items: _subjects.map((s) => AppDropdownItem(value: s, label: s)).toList(),
                    onChanged: (val) => setState(() => _selectedSubject = val),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: _topicController,
                    decoration: AppModalDialog.inputDecoration(
                      'Topic / Coverage (e.g. Motion)',
                      prefixIcon: const Icon(Icons.topic_outlined, size: 16, color: Color(0xFF94A3B8)),
                    ),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 3: Duration, Questions & Negative Marking
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: AppModalDialog.inputDecoration(
                      'Duration *',
                      suffixText: 'min',
                      suffixStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                    ),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    validator: (v) => int.tryParse(v ?? '') == null ? 'Valid number' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _questionsCountController,
                    keyboardType: TextInputType.number,
                    decoration: AppModalDialog.inputDecoration(
                      'Questions *',
                      suffixText: 'Qs',
                      suffixStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                    ),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    validator: (v) => int.tryParse(v ?? '') == null ? 'Valid number' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _negativeMarkingController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: AppModalDialog.inputDecoration(
                      'Negative',
                      suffixText: 'neg',
                      suffixStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                    ),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 4: Status & Pricing
            Row(
              children: [
                Expanded(
                  child: AppDropdown<TestSeriesStatus>(
                    value: _status,
                    inlineLabel: true,
                    hint: 'Publish Status *',
                    items: TestSeriesStatus.values
                        .map((s) => AppDropdownItem(value: s, label: s.label))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: _priceCoinsController,
                    enabled: _isPremium,
                    keyboardType: TextInputType.number,
                    decoration: AppModalDialog.inputDecoration(
                      _isPremium ? 'Unlock Coins *' : 'Unlock Coins (Free)',
                      suffixText: 'coins',
                      suffixStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                    ),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Premium Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Premium Exclusive Paper', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B))),
                        Text('Only active subscribers or coin holders can attempt this paper.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isPremium,
                    activeThumbColor: const Color(0xFFFF9500),
                    onChanged: (val) => setState(() => _isPremium = val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
