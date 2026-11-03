import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
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

  String _examCategoryId = 'rrb_alp';
  String _testMode = 'mock';
  String _selectedSubject = 'General Science';
  TestSeriesStatus _status = TestSeriesStatus.published;
  bool _isPremium = false;

  List<ExamCategoryModel> _examList = [];

  static const List<String> _subjects = [
    'General Science',
    'Mathematics',
    'Reasoning Ability',
    'General Awareness',
    'Current Affairs',
    'Basic Science & Engg',
    'Computer Knowledge',
    'Technical Specialization',
  ];

  static const List<Map<String, String>> _modes = [
    {'value': 'mock', 'label': 'Full Mock Test'},
    {'value': 'sectional', 'label': 'Sectional / Subject Test'},
    {'value': 'topic', 'label': 'Topic Practice Test'},
    {'value': 'speed', 'label': 'Speed Quiz / Rapid Test'},
    {'value': 'previous_year', 'label': 'Previous Year Paper (PYQ)'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'Mock Test Paper 01');
    _descController = TextEditingController(text: 'Full syllabus mock test paper adhering strictly to latest exam pattern.');
    _durationController = TextEditingController(text: '60');
    _questionsCountController = TextEditingController(text: '75');
    _negativeMarkingController = TextEditingController(text: '0.33');
    _priceCoinsController = TextEditingController(text: '0');
    _topicController = TextEditingController(text: 'Complete Syllabus');

    _fetchExamCategories();
  }

  Future<void> _fetchExamCategories() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return;
    try {
      final res = await client.from('exam_categories').select().order('name');
      if (mounted && res.isNotEmpty) {
        setState(() {
          _examList = res.map((r) => ExamCategoryModel.fromMap(r)).toList();
          if (_examList.isNotEmpty) {
            _examCategoryId = _examList.first.id;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching exams for AddTestPaperDialog: $e');
    }
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
    final questions = int.tryParse(_questionsCountController.text.trim()) ?? 75;
    final negMark = double.tryParse(_negativeMarkingController.text.trim()) ?? 0.33;
    final price = int.tryParse(_priceCoinsController.text.trim()) ?? 0;

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
      entryFeeCoins: _isPremium ? 20 : 0,
      enrollments: 0,
      status: _status,
      testMode: _testMode,
      subject: _selectedSubject,
      topic: _topicController.text.trim(),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Target Exam *', style: _labelStyle),
                      const SizedBox(height: 6),
                      AppDropdown<String>(
                        value: _examCategoryId,
                        items: _examList.isNotEmpty
                            ? _examList
                                .map((e) => AppDropdownItem(
                                      value: e.id,
                                      label: '${e.iconUrl ?? "🎯"} ${e.name}',
                                    ))
                                .toList()
                            : const [
                                AppDropdownItem(value: 'rrb_alp', label: '🚂 RRB ALP & Technician'),
                                AppDropdownItem(value: 'ssc_cgl', label: '🏛️ SSC CGL Tier 1'),
                                AppDropdownItem(value: 'bpsc_pre', label: '📘 BPSC Civil Services'),
                                AppDropdownItem(value: 'general', label: '🎯 General Competitive'),
                              ],
                        onChanged: (val) {
                          if (val != null) setState(() => _examCategoryId = val);
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
                      const Text('Test Paper Mode *', style: _labelStyle),
                      const SizedBox(height: 6),
                      AppDropdown<String>(
                        value: _testMode,
                        items: _modes
                            .map((m) => AppDropdownItem(value: m['value']!, label: m['label']!))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _testMode = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Paper Title
            const Text('Test Paper Title *', style: _labelStyle),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('e.g. RRB Technician Grade 3 - Full Mock Test 01'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 14),

            // Row 2: Subject & Topic
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Subject *', style: _labelStyle),
                      const SizedBox(height: 6),
                      AppDropdown<String>(
                        value: _selectedSubject,
                        items: _subjects.map((s) => AppDropdownItem(value: s, label: s)).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSubject = val);
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
                      const Text('Topic / Coverage', style: _labelStyle),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _topicController,
                        decoration: _inputDecoration('e.g. Physics - Motion & Energy'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Row 3: Duration, Questions & Negative Marking
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Duration (Minutes) *', style: _labelStyle),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('60'),
                        validator: (v) => int.tryParse(v ?? '') == null ? 'Valid number' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Questions *', style: _labelStyle),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _questionsCountController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('75'),
                        validator: (v) => int.tryParse(v ?? '') == null ? 'Valid number' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Negative Marking', style: _labelStyle),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _negativeMarkingController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputDecoration('0.33'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Row 4: Status & Pricing
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Publish Status *', style: _labelStyle),
                      const SizedBox(height: 6),
                      AppDropdown<TestSeriesStatus>(
                        value: _status,
                        items: TestSeriesStatus.values
                            .map((s) => AppDropdownItem(value: s, label: s.label))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _status = val);
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
                      const Text('Unlock Coins / Price', style: _labelStyle),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _priceCoinsController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('0 (Free) or coins'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Premium Toggle & Description
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

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334155),
  );

  static InputDecoration _inputDecoration(String hint) =>
      AppModalDialog.inputDecoration(hint, focusColor: const Color(0xFFFF9500));
}
