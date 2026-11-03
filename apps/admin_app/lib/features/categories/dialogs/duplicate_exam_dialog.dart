import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';

class DuplicateExamDialog extends StatefulWidget {
  final List<ExamCategoryModel> exams;
  final ExamCategoryModel? initialExam;
  final ValueChanged<ExamCategoryModel> onDuplicate;

  const DuplicateExamDialog({
    super.key,
    required this.exams,
    this.initialExam,
    required this.onDuplicate,
  });

  @override
  State<DuplicateExamDialog> createState() => _DuplicateExamDialogState();
}

class _DuplicateExamDialogState extends State<DuplicateExamDialog> {
  late ExamCategoryModel _selectedExam;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _idCtrl;
  bool _copySubjects = true;

  @override
  void initState() {
    super.initState();
    _selectedExam = widget.initialExam ?? (widget.exams.isNotEmpty ? widget.exams.first : const ExamCategoryModel(id: '', name: ''));
    _nameCtrl = TextEditingController(text: '${_selectedExam.name} (Copy)');
    _idCtrl = TextEditingController(text: '${_selectedExam.id}_copy');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  void _onExamChanged(ExamCategoryModel exam) {
    setState(() {
      _selectedExam = exam;
      _nameCtrl.text = '${exam.name} (Copy)';
      _idCtrl.text = '${exam.id}_copy';
    });
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final id = _idCtrl.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    if (name.isEmpty || id.isEmpty) return;

    final cloned = _selectedExam.copyWith(
      id: id,
      name: name,
      displayOrder: widget.exams.length + 1,
      isPublished: false,
    );

    widget.onDuplicate(cloned);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Duplicate Target Exam',
      subtitle: 'Clone exam structure and curriculum for a new batch/year',
      iconData: Icons.content_copy_rounded,
      gradientColors: const [Color(0xFFE11D48), Color(0xFFF43F5E)],
      maxWidth: 520,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            elevation: 0,
          ),
          child: const Text('Duplicate Exam', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source Exam Selector
          const Text('Source Exam to Duplicate *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          AppDropdown<String>(
            value: _selectedExam.id,
            items: widget.exams.map((e) => AppDropdownItem(value: e.id, label: '${e.iconUrl ?? "🎯"}  ${e.name}')).toList(),
            onChanged: (newId) {
              if (newId != null) {
                final found = widget.exams.firstWhere((e) => e.id == newId, orElse: () => _selectedExam);
                _onExamChanged(found);
              }
            },
          ),
          const SizedBox(height: 14),

          // Cloned Name
          const Text('New Target Exam Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.5)),
            ),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 14),

          // Cloned Identifier / ID
          const Text('New Identifier (Unique ID) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          TextField(
            controller: _idCtrl,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.5)),
            ),
            style: const TextStyle(fontSize: 13, fontFamily: 'monospace', color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 14),

          // Clone subjects checkbox
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _copySubjects,
              activeColor: const Color(0xFFE11D48),
              onChanged: (val) => setState(() => _copySubjects = val ?? true),
              title: const Text('Clone linked subjects & curriculum outline', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              subtitle: const Text('Creates copies of subjects mapped to this new exam', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        ],
      ),
    );
  }
}
