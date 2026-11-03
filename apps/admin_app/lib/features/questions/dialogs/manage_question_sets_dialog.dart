import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/question_set_item.dart';

class ManageQuestionSetsDialog extends StatefulWidget {
  final List<QuestionSetItem>? initialSets;

  const ManageQuestionSetsDialog({super.key, this.initialSets});

  @override
  State<ManageQuestionSetsDialog> createState() => _ManageQuestionSetsDialogState();
}

class _ManageQuestionSetsDialogState extends State<ManageQuestionSetsDialog> {
  late List<QuestionSetItem> _sets;
  bool _isCreating = false;

  final TextEditingController _nameController = TextEditingController();
  String _selectedSubject = 'Physics';
  String _selectedDifficulty = 'Medium';

  final List<String> _subjects = [
    'Physics',
    'General Awareness',
    'Mathematics',
    'Chemistry',
    'Biology',
    'Reasoning',
    'Polity',
  ];

  @override
  void initState() {
    super.initState();
    _sets = widget.initialSets != null
        ? List.from(widget.initialSets!)
        : List.from(QuestionSetItem.sampleSets);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addNewSet() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final newSet = QuestionSetItem(
      id: 'qs-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      subject: _selectedSubject,
      totalQuestions: 0,
      difficulty: _selectedDifficulty,
      status: 'Active',
      createdAt: DateTime.now(),
    );

    setState(() {
      _sets.insert(0, newSet);
      _isCreating = false;
      _nameController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Created question set "$name"'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Manage Question Sets',
      subtitle: '${_sets.length} organized curriculum question pools',
      iconData: Icons.folder_outlined,
      gradientColors: const [Color(0xFFD97706), Color(0xFFF59E0B)],
      maxWidth: 640,
      maxHeight: 700,
      scrollable: true,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD97706),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create New Set Toggle or Form
          if (!_isCreating)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                elevation: 0,
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Create New Question Set', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
              onPressed: () => setState(() => _isCreating = true),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'New Question Set Details',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                    decoration: AppModalDialog.inputDecoration(
                      'Enter question set name (e.g. Current Affairs Part 2)',
                      focusColor: const Color(0xFFF59E0B),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Subject',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 4),
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Difficulty',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 4),
                            AppDropdown<String>(
                              value: _selectedDifficulty,
                              items: ['Easy', 'Medium', 'Hard', 'Expert']
                                  .map((d) => AppDropdownItem(value: d, label: d))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedDifficulty = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _isCreating = false),
                        child: const Text('Cancel', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          elevation: 0,
                        ),
                        onPressed: _addNewSet,
                        child: const Text('Save Set', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 18),
          const Text(
            'EXISTING QUESTION SETS',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8),
          ),
          const SizedBox(height: 10),

          for (final set in _sets) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.folder_copy_outlined, size: 18, color: Color(0xFFD97706)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          set.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${set.subject} • ${set.totalQuestions} Questions • ${set.difficulty}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Text(
                      set.status,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
