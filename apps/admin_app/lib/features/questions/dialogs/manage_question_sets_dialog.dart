import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import '../models/question_set_item.dart';

class ManageQuestionSetsDialog extends StatefulWidget {
  final List<QuestionSetItem>? initialSets;
  final VoidCallback? onSetsUpdated;

  const ManageQuestionSetsDialog({
    super.key,
    this.initialSets,
    this.onSetsUpdated,
  });

  @override
  State<ManageQuestionSetsDialog> createState() => _ManageQuestionSetsDialogState();
}

class _ManageQuestionSetsDialogState extends State<ManageQuestionSetsDialog> {
  List<QuestionSetItem> _sets = [];
  List<String> _subjects = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isCreating = false;
  String? _errorMessage;

  final TextEditingController _nameController = TextEditingController();
  String? _selectedSubject;
  String _selectedDifficulty = 'Medium';

  @override
  void initState() {
    super.initState();
    if (widget.initialSets != null) {
      _sets = List.from(widget.initialSets!);
      _isLoading = false;
    } else {
      _loadFromSupabase();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      final results = await Future.wait([
        client.from('tests').select('id, title, category_id, status, created_at').order('created_at', ascending: false),
        client.from('questions').select('id, test_id').limit(5000),
        client.from('categories').select('id, name').order('display_order', ascending: true),
      ]);

      final testRows = List<Map<String, dynamic>>.from(results[0] as List);
      final qRows = List<Map<String, dynamic>>.from(results[1] as List);
      final catRows = List<Map<String, dynamic>>.from(results[2] as List);

      final catNameLookup = <String, String>{};
      final subjNames = <String>[];
      for (final c in catRows) {
        final id = c['id']?.toString().trim() ?? '';
        final name = c['name']?.toString().trim() ?? '';
        if (name.isNotEmpty) {
          subjNames.add(name);
          catNameLookup[name.toLowerCase()] = name;
          if (id.isNotEmpty) catNameLookup[id.toLowerCase()] = name;
        }
      }

      final qCountByTest = <String, int>{};
      for (final q in qRows) {
        final tid = q['test_id']?.toString().trim() ?? '';
        if (tid.isNotEmpty) {
          qCountByTest[tid] = (qCountByTest[tid] ?? 0) + 1;
        }
      }

      final loadedSets = testRows.map((row) {
        final id = row['id']?.toString() ?? '';
        final rawCat = row['category_id']?.toString().trim() ?? '';
        final resolvedSubj = catNameLookup[rawCat.toLowerCase()] ??
            (rawCat.isNotEmpty ? rawCat : 'Uncategorized');
        return QuestionSetItem(
          id: id,
          name: row['title']?.toString() ?? 'Untitled Set',
          subject: resolvedSubj,
          totalQuestions: qCountByTest[id] ?? 0,
          difficulty: 'Mixed',
          status: row['status']?.toString() ?? 'draft',
          createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _sets = loadedSets;
        _subjects = subjNames.toSet().toList();
        _selectedSubject ??= _subjects.isNotEmpty ? _subjects.first : null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load question sets: $e';
      });
    }
  }

  Future<void> _addNewSet() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      setState(() => _errorMessage = 'Database not connected. Cannot create question set.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final now = DateTime.now();
    final id = 'set-${now.millisecondsSinceEpoch}';
    final subject = _selectedSubject ?? 'General';

    try {
      await client.from('tests').insert({
        'id': id,
        'title': name,
        'category_id': subject,
        'test_mode': 'sectional',
        'duration_minutes': 30,
        'total_questions': 0,
        'status': 'draft',
        'created_at': now.toIso8601String(),
      });

      final newSet = QuestionSetItem(
        id: id,
        name: name,
        subject: subject,
        totalQuestions: 0,
        difficulty: _selectedDifficulty,
        status: 'draft',
        createdAt: now,
      );

      if (!mounted) return;
      setState(() {
        _sets.insert(0, newSet);
        _isCreating = false;
        _isSaving = false;
        _nameController.clear();
      });

      widget.onSetsUpdated?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created question set "$name" in Supabase'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'Failed to create question set: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjOptions = _subjects.isNotEmpty ? _subjects : ['General'];
    final activeSubj = (_selectedSubject != null && subjOptions.contains(_selectedSubject))
        ? _selectedSubject!
        : subjOptions.first;

    return AppModalDialog(
      title: 'Manage Question Sets',
      subtitle: '${_sets.length} live test series question pools in Supabase',
      iconData: Icons.folder_outlined,
      maxWidth: 640,
      maxHeight: 700,
      scrollable: true,
      actions: [
        AppModalDialog.cancelButton(context, label: 'Close'),
        if (!_isCreating)
          AppModalDialog.primaryButton(
            onPressed: () => setState(() => _isCreating = true),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16),
                SizedBox(width: 6),
                Text(
                  'Create New Question Set',
                  style: TextStyle(
                    fontFamily: AppTypography.fontHeading,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.liveRedLight,
                borderRadius: AppRadii.button,
                border: Border.all(color: AppColors.liveRedBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.liveRed, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.liveRedDark, fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadFromSupabase,
                    child: const Text('Retry', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
          if (_isCreating)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.brandOrangeLight,
                borderRadius: AppRadii.cardSubtle,
                border: Border.all(color: AppModalDialog.defaultPrimaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'New Question Set Details',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppModalDialog.textField(
                    controller: _nameController,
                    hint: 'Enter question set name...',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppDropdown<String>(
                          hint: 'Subject',
                          value: activeSubj,
                          items: subjOptions.map((s) => AppDropdownItem(value: s, label: s)).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSubject = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppDropdown<String>(
                          hint: 'Difficulty Target',
                          value: _selectedDifficulty,
                          items: ['Easy', 'Medium', 'Hard']
                              .map((d) => AppDropdownItem(value: d, label: d))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDifficulty = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppModalDialog.secondaryButton(
                        onPressed: _isSaving ? null : () => setState(() => _isCreating = false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: AppTypography.fontHeading,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppModalDialog.primaryButton(
                        onPressed: _isSaving ? null : _addNewSet,
                        child: Text(
                          _isSaving ? 'Saving...' : 'Save Set',
                          style: const TextStyle(
                            fontFamily: AppTypography.fontHeading,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          if (_isCreating || _errorMessage != null) const SizedBox(height: 18),
          const Text(
            'EXISTING QUESTION SETS',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8),
          ),
          const SizedBox(height: 10),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_sets.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No question sets found in Supabase yet.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
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
                            '${set.subject} • ${set.totalQuestions} Questions',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: set.status == 'published' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: set.status == 'published' ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Text(
                        set.status,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: set.status == 'published' ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        ),
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
