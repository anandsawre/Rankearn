import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import '../models/test_series_item.dart';

class CreateTestSeriesDialog extends StatefulWidget {
  final TestSeriesItem? initialItem;
  final Function(TestSeriesItem) onSave;

  const CreateTestSeriesDialog({
    super.key,
    this.initialItem,
    required this.onSave,
  });

  @override
  State<CreateTestSeriesDialog> createState() => _CreateTestSeriesDialogState();
}

class _CreateTestSeriesDialogState extends State<CreateTestSeriesDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _durationController;
  late TextEditingController _questionsCountController;
  late TextEditingController _negativeMarkingController;
  late TextEditingController _priceCoinsController;
  late TextEditingController _entryFeeController;
  late TextEditingController _topicController;

  late String _examCategoryId;
  late String _testMode;
  String? _selectedSubject;
  String? _selectedTopic;
  late TestSeriesStatus _status;

  bool _isPremium = false;
  bool _isTournament = false;

  DateTime? _scheduledStartTime;
  DateTime? _scheduledEndTime;

  List<ExamCategoryModel> _examList = [];
  List<Map<String, dynamic>> _rawCategories = [];
  List<String> _availableTopics = [];

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;

    _titleController = TextEditingController(text: item?.title ?? '');
    _descController = TextEditingController(text: item?.description ?? '');
    _durationController = TextEditingController(text: (item?.durationMinutes ?? item?.totalTests ?? 60).toString());
    _questionsCountController = TextEditingController(text: (item?.totalQuestions ?? 100).toString());
    _negativeMarkingController = TextEditingController(text: (item?.negativeMarking ?? 0.25).toString());
    _priceCoinsController = TextEditingController(text: (item?.priceInr ?? 0).toString());
    _entryFeeController = TextEditingController(text: (item?.entryFeeCoins ?? 20).toString());
    _topicController = TextEditingController(text: item?.topic ?? '');

    _examCategoryId = item?.examCategoryId ?? '';
    _testMode = item?.testMode ?? 'mock';
    _selectedSubject = item?.subject;
    _selectedTopic = item?.topic;
    _status = item?.status ?? TestSeriesStatus.published;
    _isPremium = item?.isPremium ?? false;
    _isTournament = item?.isTournament ?? false;
    _scheduledStartTime = item?.scheduledStartTime;
    _scheduledEndTime = item?.scheduledEndTime;

    _loadDataFromSupabase();
  }

  Future<void> _loadDataFromSupabase() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return;

    try {
      // 1. Fetch Target Exams
      final examsRes = await TestsRepository().getExamCategoryList();
      if (examsRes is Success<List<ExamCategoryModel>> && examsRes.data.isNotEmpty && mounted) {
        setState(() {
          _examList = examsRes.data;
          if (_examCategoryId.isEmpty && _examList.isNotEmpty) {
            _examCategoryId = _examList.first.id;
          }
        });
      }

      // 2. Fetch Categories with exam_category_id & topics
      final catsRes = await client
          .from('categories')
          .select('id, name, exam_category_id, topics')
          .order('display_order', ascending: true);

      if (catsRes.isNotEmpty && mounted) {
        setState(() {
          _rawCategories = List<Map<String, dynamic>>.from(catsRes as List);
          _updateAvailableTopics();
        });
      }
    } catch (e) {
      debugPrint('CreateTestSeriesDialog load error: $e');
    }
  }

  List<String> get _filteredSubjects {
    if (_examCategoryId.isEmpty) {
      return _rawCategories.map((c) => c['name']?.toString() ?? '').where((n) => n.isNotEmpty).toList();
    }
    final matched = _rawCategories
        .where((c) {
          final parent = c['exam_category_id']?.toString().toLowerCase().trim();
          return parent != null && parent == _examCategoryId.toLowerCase().trim();
        })
        .map((c) => c['name']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    if (matched.isEmpty) {
      return _rawCategories.map((c) => c['name']?.toString() ?? '').where((n) => n.isNotEmpty).toList();
    }
    return matched;
  }

  void _updateAvailableTopics() {
    if (_selectedSubject == null || _selectedSubject!.isEmpty) {
      _availableTopics = [];
      return;
    }

    final cat = _rawCategories.firstWhere(
      (c) => c['name']?.toString().toLowerCase().trim() == _selectedSubject!.toLowerCase().trim(),
      orElse: () => {},
    );

    final rawTopics = cat['topics'];
    if (rawTopics is List) {
      _availableTopics = rawTopics.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    } else {
      _availableTopics = [];
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
    _entryFeeController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_testMode == 'sectional') {
      if (_selectedSubject == null || _selectedSubject!.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a Subject for Sectional Test'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    final duration = int.tryParse(_durationController.text.trim()) ?? 60;
    final totalQ = int.tryParse(_questionsCountController.text.trim()) ?? 100;
    final negMark = double.tryParse(_negativeMarkingController.text.trim()) ?? 0.25;
    final coins = _isPremium ? (int.tryParse(_priceCoinsController.text.trim()) ?? 0) : 0;
    final entryFee = _isTournament ? (int.tryParse(_entryFeeController.text.trim()) ?? 0) : 0;
    final finalTopic = _selectedTopic ?? _topicController.text.trim();

    final item = TestSeriesItem(
      id: widget.initialItem?.id ?? 'test-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      subject: _selectedSubject ?? 'General',
      examCategoryId: _examCategoryId.isNotEmpty ? _examCategoryId : 'general',
      testMode: _testMode,
      totalTests: duration,
      durationMinutes: duration,
      totalQuestions: totalQ,
      negativeMarking: negMark,
      topic: finalTopic.isNotEmpty ? finalTopic : null,
      isPremium: _isPremium,
      priceInr: coins,
      isTournament: _isTournament,
      entryFeeCoins: entryFee,
      scheduledStartTime: _scheduledStartTime,
      scheduledEndTime: _scheduledEndTime,
      enrollments: widget.initialItem?.enrollments ?? 0,
      status: _status,
      createdAt: widget.initialItem?.createdAt ?? DateTime.now(),
      icon: _getIconForSubject(_selectedSubject ?? ''),
      iconColor: _getColorForSubject(_selectedSubject ?? ''),
    );

    widget.onSave(item);
    Navigator.of(context).pop();
  }

  IconData _getIconForSubject(String subject) {
    final lower = subject.toLowerCase();
    if (lower.contains('science')) return Icons.science_rounded;
    if (lower.contains('math')) return Icons.calculate_rounded;
    if (lower.contains('reasoning')) return Icons.lightbulb_rounded;
    if (lower.contains('current') || lower.contains('affairs')) return Icons.public_rounded;
    if (lower.contains('chemistry')) return Icons.biotech_rounded;
    if (lower.contains('biology')) return Icons.eco_rounded;
    return Icons.settings_suggest_rounded;
  }

  Color _getColorForSubject(String subject) {
    final lower = subject.toLowerCase();
    if (lower.contains('science')) return const Color(0xFF6366F1);
    if (lower.contains('math')) return const Color(0xFFF43F5E);
    if (lower.contains('reasoning')) return const Color(0xFFF59E0B);
    if (lower.contains('current') || lower.contains('affairs')) return const Color(0xFF0284C7);
    if (lower.contains('chemistry')) return const Color(0xFFA855F7);
    if (lower.contains('biology')) return const Color(0xFF10B981);
    return const Color(0xFF06B6D4);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialItem != null;
    final isMobile = MediaQuery.sizeOf(context).width < 640;
    final subjects = _filteredSubjects;

    final content = Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // SECTION 1: TARGET EXAM & TEST MODE
            // ==========================================
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Target Exam *', style: _labelStyle),
                      const SizedBox(height: 6),
                      AppDropdown<String>(
                        value: _examList.any((e) => e.id == _examCategoryId)
                            ? _examCategoryId
                            : (_examList.isNotEmpty ? _examList.first.id : null),
                        items: _examList.map((e) => AppDropdownItem(
                          value: e.id,
                          label: '${e.iconUrl ?? "🎯"}  ${e.name}',
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _examCategoryId = val;
                              _selectedSubject = null;
                              _selectedTopic = null;
                              _updateAvailableTopics();
                            });
                          }
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
                      const Text('Test Mode *', style: _labelStyle),
                      const SizedBox(height: 6),
                      AppDropdown<String>(
                        value: _testMode,
                        items: const [
                          AppDropdownItem(value: 'mock', label: '📝 Mock Test (Full Length)'),
                          AppDropdownItem(value: 'sectional', label: '📖 Sectional Test (Subject/Topic)'),
                          AppDropdownItem(value: 'previous-year', label: '⏳ Previous Year Paper'),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _testMode = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ==========================================
            // CONDITIONAL: SUBJECT & TOPIC (FOR SECTIONAL TEST)
            // ==========================================
            if (_testMode == 'sectional') ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.account_tree_outlined, size: 14, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Sectional Curriculum Mapping',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Subject *', style: _labelStyle),
                              const SizedBox(height: 6),
                              AppDropdown<String>(
                                value: subjects.contains(_selectedSubject) ? _selectedSubject : null,
                                hint: 'Select Subject...',
                                items: subjects.map((s) => AppDropdownItem(value: s, label: s)).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedSubject = val;
                                    _selectedTopic = null;
                                    _updateAvailableTopics();
                                  });
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
                              const Text('Topic / Chapter (Optional)', style: _labelStyle),
                              const SizedBox(height: 6),
                              if (_availableTopics.isNotEmpty)
                                AppDropdown<String>(
                                  value: _availableTopics.contains(_selectedTopic) ? _selectedTopic : null,
                                  hint: 'Select Topic...',
                                  items: _availableTopics.map((t) => AppDropdownItem(value: t, label: t)).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedTopic = val;
                                      _topicController.text = val ?? '';
                                    });
                                  },
                                )
                              else
                                TextFormField(
                                  controller: _topicController,
                                  style: const TextStyle(fontSize: 12.5),
                                  decoration: _inputDecoration('e.g. Ancient India, Thermodynamics'),
                                  onChanged: (v) => _selectedTopic = v,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ==========================================
            // SECTION 2: TEST TITLE & SYLLABUS
            // ==========================================
            const Text('Test Title *', style: _labelStyle),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleController,
              validator: (v) => v == null || v.trim().isEmpty ? 'Test Title is required' : null,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              decoration: _inputDecoration('e.g. Railway ALP Stage 1 Full Mock Test 01'),
            ),
            const SizedBox(height: 14),

            const Text('Test Description & Syllabus Overview', style: _labelStyle),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descController,
              maxLines: 2,
              style: const TextStyle(fontSize: 12.5),
              decoration: _inputDecoration('e.g. Complete CBT-1 full mock test based on 2026 latest exam pattern.'),
            ),
            const SizedBox(height: 14),

            // ==========================================
            // SECTION 3: EXAM ENGINE PARAMETERS (Duration, Total Q, Negative Marking)
            // ==========================================
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
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                        decoration: _inputDecoration('60'),
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
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                        decoration: _inputDecoration('100'),
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
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                        decoration: _inputDecoration('0.25'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Publication Status
            const Text('Publication Status', style: _labelStyle),
            const SizedBox(height: 6),
            AppDropdown<TestSeriesStatus>(
              value: _status,
              items: const [
                AppDropdownItem(value: TestSeriesStatus.published, label: '🟢 Published (Visible to Students)'),
                AppDropdownItem(value: TestSeriesStatus.draft, label: '🟡 Draft / Unpublished (Hidden)'),
                AppDropdownItem(value: TestSeriesStatus.archived, label: '⚪ Archived'),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _status = val);
              },
            ),
            const SizedBox(height: 16),

            // ==========================================
            // SECTION 4: MONETIZATION & CONTEST CONFIG
            // ==========================================
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE9D5FF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: _isPremium,
                    activeColor: const Color(0xFF5636F5),
                    onChanged: (val) => setState(() => _isPremium = val ?? false),
                    title: const Text('Exclusive / Premium Test (Coin Unlock)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                    subtitle: const Text('Students spend coins to unlock this test', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ),
                  if (_isPremium) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('Unlock Price (Coins):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          child: TextFormField(
                            controller: _priceCoinsController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5636F5)),
                            decoration: _inputDecoration('50'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 18, color: Color(0xFFE9D5FF)),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: _isTournament,
                    activeColor: const Color(0xFF5636F5),
                    onChanged: (val) => setState(() => _isTournament = val ?? false),
                    title: const Text('Run as Live Paid Contest / Tournament', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                    subtitle: const Text('Leaderboard-based live battle with prize distribution', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ),
                  if (_isTournament) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('Entry Fee (Coins):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          child: TextFormField(
                            controller: _entryFeeController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                            decoration: _inputDecoration('20'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Modal Header
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF5636F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Test Series' : 'Create New Test',
                    style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: Color(0xFF101A3A)),
                  ),
                  const Text(
                    'Configure exam parameters, syllabus and access rules',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );

    // Modal Actions
    final actions = Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5636F5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              elevation: 0,
            ),
            onPressed: _submit,
            child: Text(
              isEditing ? 'Save Changes' : 'Create Test Series',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            header,
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Expanded(child: content),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            actions,
          ],
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
        child: Column(
          children: [
            header,
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Expanded(child: content),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            actions,
          ],
        ),
      ),
    );
  }

  static const _labelStyle = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1E293B),
  );

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
        borderSide: const BorderSide(color: Color(0xFF5636F5), width: 1.5),
      ),
    );
  }
}
