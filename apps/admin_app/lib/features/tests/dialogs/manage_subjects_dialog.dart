import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';

class ManageSubjectsDialog extends StatefulWidget {
  final VoidCallback? onSubjectsChanged;

  const ManageSubjectsDialog({
    super.key,
    this.onSubjectsChanged,
  });

  @override
  State<ManageSubjectsDialog> createState() => _ManageSubjectsDialogState();
}

class _SubjectEntry {
  final String id;
  final String name;
  final String code;
  final Color color;
  final IconData icon;
  final int testCount;

  _SubjectEntry({
    required this.id,
    required this.name,
    required this.code,
    required this.color,
    required this.icon,
    this.testCount = 0,
  });
}

class _ManageSubjectsDialogState extends State<ManageSubjectsDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  String _selectedExam = 'rrb_alp';
  Color _selectedColor = const Color(0xFF10B981);
  final IconData _selectedIcon = Icons.science_rounded;

  final List<Color> _palette = const [
    Color(0xFF10B981), // Emerald
    Color(0xFF5636F5), // Indigo
    Color(0xFF0084FF), // Blue
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEF4444), // Red
    Color(0xFF06B6D4), // Cyan
  ];

  final List<_SubjectEntry> _subjects = [
    _SubjectEntry(id: 's1', name: 'General Science', code: 'GS', color: const Color(0xFF10B981), icon: Icons.science_rounded, testCount: 42),
    _SubjectEntry(id: 's2', name: 'Mathematics', code: 'MATH', color: const Color(0xFF5636F5), icon: Icons.calculate_rounded, testCount: 38),
    _SubjectEntry(id: 's3', name: 'Reasoning Ability', code: 'REAS', color: const Color(0xFF0084FF), icon: Icons.lightbulb_outline_rounded, testCount: 29),
    _SubjectEntry(id: 's4', name: 'General Awareness', code: 'GA', color: const Color(0xFFF59E0B), icon: Icons.public_rounded, testCount: 25),
    _SubjectEntry(id: 's5', name: 'Current Affairs', code: 'CA', color: const Color(0xFFEC4899), icon: Icons.newspaper_rounded, testCount: 18),
    _SubjectEntry(id: 's6', name: 'Basic Science & Engg', code: 'BSE', color: const Color(0xFF8B5CF6), icon: Icons.precision_manufacturing_rounded, testCount: 14),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _addSubject() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final code = _codeController.text.trim().isNotEmpty
        ? _codeController.text.trim().toUpperCase()
        : name.substring(0, name.length > 4 ? 4 : name.length).toUpperCase();

    final newSub = _SubjectEntry(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      code: code,
      color: _selectedColor,
      icon: _selectedIcon,
      testCount: 0,
    );

    setState(() {
      _subjects.insert(0, newSub);
      _nameController.clear();
      _codeController.clear();
    });

    final client = SupabaseConfig.clientSafe;
    if (client != null) {
      try {
        await client.from('categories').upsert({
          'id': newSub.id,
          'name': newSub.name,
          'category_type': 'subject',
          'parent_id': _selectedExam,
        });
      } catch (e) {
        debugPrint('Subject save note: $e');
      }
    }

    widget.onSubjectsChanged?.call();
  }

  void _deleteSubject(String id) async {
    setState(() {
      _subjects.removeWhere((s) => s.id == id);
    });

    final client = SupabaseConfig.clientSafe;
    if (client != null) {
      try {
        await client.from('categories').delete().eq('id', id);
      } catch (_) {}
    }

    widget.onSubjectsChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Manage Subjects & Syllabus',
      subtitle: 'Configure exam subjects, syllabus tags, and icon color themes',
      iconData: Icons.folder_outlined,
      gradientColors: const [Color(0xFF00B368), Color(0xFF10B981)],
      maxWidth: 640,
      scrollable: true,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B368),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
            elevation: 0,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter by Exam
          const Text('Target Exam', style: _labelStyle),
          const SizedBox(height: 6),
          AppDropdown<String>(
            value: _selectedExam,
            items: const [
              AppDropdownItem(value: 'rrb_alp', label: '🚂 RRB ALP & Technician'),
              AppDropdownItem(value: 'ssc_cgl', label: '🏛️ SSC CGL Tier 1 & Tier 2'),
              AppDropdownItem(value: 'bpsc_pre', label: '📘 BPSC Civil Services'),
              AppDropdownItem(value: 'general', label: '🎯 General Competitive Exams'),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedExam = val);
            },
          ),
          const SizedBox(height: 18),

          // Add New Subject Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF00B368)),
                    SizedBox(width: 8),
                    Text('Add New Subject', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 12),
                        decoration: _inputDecoration('Subject Name (e.g. Physics)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _codeController,
                        style: const TextStyle(fontSize: 12),
                        decoration: _inputDecoration('Code (e.g. PHY)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B368),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: _addSubject,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Color Theme: ', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                    const SizedBox(width: 8),
                    Wrap(
                      spacing: 8,
                      children: _palette.map((c) {
                        final isSel = _selectedColor == c;
                        return InkWell(
                          onTap: () => setState(() => _selectedColor = c),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? Colors.black87 : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: isSel
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Configured Subjects List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Configured Subjects (${_subjects.length})',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF334155)),
              ),
              const Text(
                'Linked to Test Papers',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _subjects.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final s = _subjects[idx];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: s.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(s.icon, size: 18, color: s.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B))),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: Text(s.code, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('${s.testCount} Test Papers Active', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                      tooltip: 'Remove Subject',
                      onPressed: () => _deleteSubject(s.id),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334155),
  );

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF00B368), width: 1.5),
      ),
    );
  }
}
