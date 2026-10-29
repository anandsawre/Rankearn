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
      isPublished: false, // Start as draft/unpublished
    );

    widget.onDuplicate(cloned);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 640;

    final content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E).withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.content_copy_rounded, color: Color(0xFFF43F5E), size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duplicate Target Exam',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF101A3A)),
                        ),
                        Text('Clone exam structure for a new batch/year', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFE2E8F0)),

            // Source Exam Selector
            const Text('Source Exam to Duplicate *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
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
            const SizedBox(height: 16),

            // Cloned Name
            const Text('New Target Exam Name *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF5636F5), width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Cloned Identifier / ID
            const Text('New Identifier (Unique ID) *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
            const SizedBox(height: 6),
            TextField(
              controller: _idCtrl,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF5636F5), width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 14),

            // Clone subjects checkbox
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _copySubjects,
              activeColor: const Color(0xFF5636F5),
              onChanged: (val) => setState(() => _copySubjects = val ?? true),
              title: const Text('Clone linked subjects & curriculum outline', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              subtitle: const Text('Creates copies of subjects mapped to this new exam', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Duplicate Exam', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isMobile) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        child: content,
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: content,
    );
  }
}

