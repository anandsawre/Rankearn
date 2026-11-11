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
  final String slug;
  final String? examCategoryId;
  final Color color;
  final IconData icon;
  final int testCount;

  const _SubjectEntry({
    required this.id,
    required this.name,
    required this.slug,
    this.examCategoryId,
    required this.color,
    required this.icon,
    this.testCount = 0,
  });
}

class _ManageSubjectsDialogState extends State<ManageSubjectsDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _slugController = TextEditingController();

  List<ExamCategoryModel> _examList = [];
  String _selectedExam = 'all';
  Color _selectedColor = const Color(0xFF10B981);

  List<_SubjectEntry> _subjects = [];
  bool _isLoading = true;
  bool _isMutating = false;
  String? _errorMessage;

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

  @override
  void initState() {
    super.initState();
    _loadFromSupabase();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  Future<void> _loadFromSupabase() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Database connection is not initialized.';
        });
      }
      return;
    }

    try {
      final results = await Future.wait<dynamic>([
        TestsRepository().getExamCategoryList(),
        client
            .from('categories')
            .select()
            .order('display_order', ascending: true),
        client.from('tests').select('id, category_id'),
      ]);

      final examsRes = results[0] as Result<List<ExamCategoryModel>>;
      final catRows = List<Map<String, dynamic>>.from(results[1] as List);
      final testRows = List<Map<String, dynamic>>.from(results[2] as List);

      final testCountsByKey = <String, int>{};
      for (final t in testRows) {
        final cid = t['category_id']?.toString().trim().toLowerCase() ?? '';
        if (cid.isNotEmpty) {
          testCountsByKey[cid] = (testCountsByKey[cid] ?? 0) + 1;
        }
      }

      final exams = examsRes is Success<List<ExamCategoryModel>>
          ? examsRes.data
          : <ExamCategoryModel>[];

      final entries = catRows.map((c) {
        final id = c['id']?.toString() ?? '';
        final name = c['name']?.toString() ?? 'Subject';
        final slug = c['slug']?.toString() ?? '';
        final examId = c['exam_category_id']?.toString();
        final colorHex = c['icon_color']?.toString();
        final count = (testCountsByKey[id.toLowerCase()] ?? 0) +
            (name.toLowerCase() != id.toLowerCase()
                ? (testCountsByKey[name.toLowerCase()] ?? 0)
                : 0);

        return _SubjectEntry(
          id: id,
          name: name,
          slug: slug,
          examCategoryId: examId,
          color: _parseHexColor(colorHex) ?? _palette[entriesIndexColor(id)],
          icon: _iconForSubject(name),
          testCount: count > 0
              ? count
              : ((c['total_tests'] as num?)?.toInt() ?? 0),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _examList = exams;
        _subjects = entries;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load subjects from database: $e';
      });
    }
  }

  int entriesIndexColor(String id) =>
      id.codeUnits.fold<int>(0, (a, b) => a + b) % _palette.length;

  List<_SubjectEntry> get _filteredSubjects {
    if (_selectedExam == 'all') return _subjects;
    return _subjects
        .where((s) =>
            (s.examCategoryId ?? '').toLowerCase() ==
            _selectedExam.toLowerCase())
        .toList();
  }

  Future<void> _addSubject() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _isMutating) return;

    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      _showSnack('Database is not connected.', isError: true);
      return;
    }

    setState(() => _isMutating = true);

    final rawSlug = _slugController.text.trim().isNotEmpty
        ? _slugController.text.trim().toLowerCase()
        : name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final hexColor =
        '#${(_selectedColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    final newId = 'cat_${DateTime.now().millisecondsSinceEpoch}';

    try {
      await client.from('categories').upsert({
        'id': newId,
        'name': name,
        'slug': rawSlug,
        'exam_category_id': _selectedExam == 'all' ? null : _selectedExam,
        'icon_name': _iconNameForSubject(name),
        'icon_color': hexColor,
        'display_order': _subjects.length + 1,
        'status': 'active',
      });

      _nameController.clear();
      _slugController.clear();
      widget.onSubjectsChanged?.call();
      await _loadFromSupabase();
    } catch (e) {
      _showSnack('Failed to add subject: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  Future<void> _deleteSubject(String id) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      _showSnack('Database is not connected.', isError: true);
      return;
    }

    try {
      await client.from('categories').delete().eq('id', id);
      if (!mounted) return;
      setState(() {
        _subjects.removeWhere((s) => s.id == id);
      });
      widget.onSubjectsChanged?.call();
    } catch (e) {
      _showSnack('Failed to delete subject: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : const Color(0xFF00B368),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleSubjects = _filteredSubjects;

    return AppModalDialog(
      title: 'Manage Subjects & Syllabus',
      subtitle: 'Configure live exam subjects and color themes in Supabase',
      iconData: Icons.folder_outlined,
      gradientColors: const [Color(0xFF00B368), Color(0xFF10B981)],
      maxWidth: 640,
      scrollable: true,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B368),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
            elevation: 0,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Done',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.errorRoseLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          // Filter / Tag by Target Exam
          const Text('Target Exam Filter', style: _labelStyle),
          const SizedBox(height: 6),
          AppDropdown<String>(
            value: _selectedExam,
            items: [
              const AppDropdownItem(value: 'all', label: 'All Target Exams'),
              ..._examList.map(
                (e) => AppDropdownItem(
                  value: e.id,
                  label: '${e.iconUrl ?? "🎯"} ${e.name}',
                ),
              ),
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
                    Icon(Icons.add_circle_outline_rounded,
                        size: 16, color: Color(0xFF00B368)),
                    SizedBox(width: 8),
                    Text('Add New Subject',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF1E293B))),
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
                        decoration:
                            _inputDecoration('Subject Name (e.g. Physics)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _slugController,
                        style: const TextStyle(fontSize: 12),
                        decoration: _inputDecoration('Slug (optional)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B368),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: _isMutating ? null : _addSubject,
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(_isMutating ? 'Saving...' : 'Add',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Color Theme: ',
                        style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500)),
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
                                color:
                                    isSel ? Colors.black87 : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: isSel
                                ? const Icon(Icons.check,
                                    size: 14, color: Colors.white)
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
          const SizedBox(height: 16),

          // Active Subjects Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Database Subjects (${visibleSubjects.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF334155),
                ),
              ),
              TextButton.icon(
                onPressed: _isLoading ? null : _loadFromSupabase,
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('Refresh', style: TextStyle(fontSize: 11.5)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Color(0xFF00B368),
                ),
              ),
            )
          else if (visibleSubjects.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Text(
                  'No subjects found for this filter.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleSubjects.length,
              separatorBuilder: (_, idx) => const SizedBox(height: 8),
              itemBuilder: (ctx, idx) {
                final s = visibleSubjects[idx];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: s.color.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Icon(s.icon, color: s.color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101A3A),
                              ),
                            ),
                            Text(
                              '${s.testCount} linked tests${s.slug.isNotEmpty ? ' • ${s.slug}' : ''}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete subject',
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: Color(0xFFEF4444), size: 18),
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

  static Color? _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '').trim();
    if (cleaned.length == 6) {
      final val = int.tryParse('FF$cleaned', radix: 16);
      if (val != null) return Color(val);
    } else if (cleaned.length == 8) {
      final val = int.tryParse(cleaned, radix: 16);
      if (val != null) return Color(val);
    }
    return null;
  }

  static IconData _iconForSubject(String subject) {
    final lower = subject.toLowerCase();
    if (lower.contains('science') || lower.contains('chem')) {
      return Icons.science_rounded;
    } else if (lower.contains('math')) {
      return Icons.calculate_rounded;
    } else if (lower.contains('reason')) {
      return Icons.lightbulb_outline_rounded;
    } else if (lower.contains('current') || lower.contains('affairs')) {
      return Icons.newspaper_rounded;
    } else if (lower.contains('history') || lower.contains('polity')) {
      return Icons.auto_stories_rounded;
    }
    return Icons.school_rounded;
  }

  static String _iconNameForSubject(String subject) {
    final lower = subject.toLowerCase();
    if (lower.contains('science') || lower.contains('chem')) return 'science';
    if (lower.contains('math')) return 'calculate';
    if (lower.contains('reason')) return 'psychology';
    if (lower.contains('current') || lower.contains('affairs')) {
      return 'newspaper';
    }
    if (lower.contains('history')) return 'auto_stories';
    return 'school';
  }

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334155),
  );

  static InputDecoration _inputDecoration(String hint) =>
      AppModalDialog.inputDecoration(hint, focusColor: const Color(0xFF00B368));
}
