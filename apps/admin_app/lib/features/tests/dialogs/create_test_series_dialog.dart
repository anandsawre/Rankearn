import 'package:flutter/material.dart';
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
  late TextEditingController _testsCountController;
  late TextEditingController _questionsCountController;
  late TextEditingController _priceController;

  late String _subject;
  late TestSeriesStatus _status;

  final List<String> _subjects = [
    'General Science',
    'Mathematics',
    'Reasoning',
    'Current Affairs',
    'Chemistry',
    'Biology',
    'Mixed',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _descController = TextEditingController(text: item?.description ?? '');
    _testsCountController = TextEditingController(text: item?.totalTests.toString() ?? '20');
    _questionsCountController = TextEditingController(text: item?.totalQuestions.toString() ?? '2000');
    _priceController = TextEditingController(text: item?.priceInr.toString() ?? '149');
    _subject = item?.subject ?? 'General Science';
    _status = item?.status ?? TestSeriesStatus.published;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _testsCountController.dispose();
    _questionsCountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final item = TestSeriesItem(
      id: widget.initialItem?.id ?? 'ts-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      subject: _subject,
      totalTests: int.tryParse(_testsCountController.text.trim()) ?? 20,
      totalQuestions: int.tryParse(_questionsCountController.text.trim()) ?? 2000,
      priceInr: int.tryParse(_priceController.text.trim()) ?? 149,
      enrollments: widget.initialItem?.enrollments ?? 0,
      status: _status,
      createdAt: widget.initialItem?.createdAt ?? DateTime.now(),
      icon: _getIconForSubject(_subject),
      iconColor: _getColorForSubject(_subject),
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

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF5636F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isEditing ? Icons.edit_rounded : Icons.add_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isEditing ? 'Edit Test Series' : 'Create New Test Series',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF101A3A)),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),

                // Title
                const Text('Test Series Title', style: _labelStyle),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _titleController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                  style: const TextStyle(fontSize: 12),
                  decoration: _inputDecoration('e.g. RRB Technician Grade 3 Mock Series'),
                ),
                const SizedBox(height: 12),

                // Description
                const Text('Description / Syllabus', style: _labelStyle),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12),
                  decoration: _inputDecoration('e.g. Complete test series with detailed solutions'),
                ),
                const SizedBox(height: 12),

                // Subject & Status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Subject', style: _labelStyle),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: _subject,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                            decoration: _inputDecoration(''),
                            items: _subjects
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _subject = val);
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
                          const Text('Publication Status', style: _labelStyle),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<TestSeriesStatus>(
                            initialValue: _status,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                            decoration: _inputDecoration(''),
                            items: TestSeriesStatus.values
                                .map((st) => DropdownMenuItem(value: st, child: Text(st.label)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _status = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Metrics (Tests, Questions, Price)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Tests', style: _labelStyle),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _testsCountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 12),
                            decoration: _inputDecoration('20'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Questions', style: _labelStyle),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _questionsCountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 12),
                            decoration: _inputDecoration('2000'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Price (₹ INR)', style: _labelStyle),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 12),
                            decoration: _inputDecoration('149'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5636F5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: _submit,
          child: Text(isEditing ? 'Save Changes' : 'Create Test Series'),
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
        borderSide: const BorderSide(color: Color(0xFF5636F5), width: 1.5),
      ),
    );
  }
}
