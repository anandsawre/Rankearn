import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import '../models/ai_test_item.dart';

class ManageTemplatesDialog extends StatefulWidget {
  final ValueChanged<AiTestTemplate> onUseTemplate;

  const ManageTemplatesDialog({
    super.key,
    required this.onUseTemplate,
  });

  @override
  State<ManageTemplatesDialog> createState() => _ManageTemplatesDialogState();
}

class _ManageTemplatesDialogState extends State<ManageTemplatesDialog> {
  List<AiTestTemplate> _templates = [];
  bool _isLoading = true;
  bool _isCreating = false;
  bool _isSaving = false;
  String? _errorMessage;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _examCtrl = TextEditingController();
  AiTestSubject _subject = AiTestSubject.generalScience;
  AiTestDifficulty _difficulty = AiTestDifficulty.medium;
  int _qCount = 50;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _examCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
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
      final rows = await client
          .from('ai_test_templates')
          .select()
          .order('created_at', ascending: false);

      final parsed = (rows as List).map((r) {
        final m = Map<String, dynamic>.from(r as Map);
        final subj = AiTestSubject.fromString(m['subject']?.toString() ?? 'General Science');
        return AiTestTemplate(
          id: m['id']?.toString() ?? '',
          title: m['title']?.toString() ?? 'Untitled Template',
          description: m['description']?.toString() ?? '',
          subject: subj,
          defaultDifficulty: AiTestDifficulty.fromString(
            m['default_difficulty']?.toString() ?? 'Medium',
          ),
          defaultQuestionCount: (m['default_question_count'] as num?)?.toInt() ?? 50,
          defaultDurationMinutes: (m['default_duration_minutes'] as num?)?.toInt() ?? 60,
          targetExam: m['target_exam']?.toString() ?? 'Competitive Exam',
          icon: subj.icon,
          color: subj.color,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _templates = parsed;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load AI templates: $e';
      });
    }
  }

  Future<void> _createTemplate() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      setState(() => _errorMessage = 'Database not connected. Cannot save template.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await client.from('ai_test_templates').insert({
        'title': title,
        'description': _descCtrl.text.trim(),
        'subject': _subject.label,
        'default_difficulty': _difficulty.label,
        'default_question_count': _qCount,
        'default_duration_minutes': _qCount,
        'target_exam': _examCtrl.text.trim().isNotEmpty
            ? _examCtrl.text.trim()
            : 'Competitive Exam',
      });
      _titleCtrl.clear();
      _descCtrl.clear();
      _examCtrl.clear();
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _isCreating = false;
      });
      await _loadTemplates();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'Failed to create template: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      iconData: Icons.folder_special_rounded,
      gradientColors: const [Color(0xFF047857), Color(0xFF10B981)],
      title: 'Manage Test Templates',
      subtitle: 'Reusable Supabase blueprints (`ai_test_templates`) for test generation',
      maxWidth: 620,
      scrollable: true,
      actions: [
        if (!_isCreating)
          OutlinedButton.icon(
            onPressed: () => setState(() => _isCreating = true),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('New Template'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDA4AF)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF9F1239), fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadTemplates,
                    child: const Text('Retry', style: TextStyle(fontSize: 11.5)),
                  ),
                ],
              ),
            ),
          ],
          if (_isCreating) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleCtrl,
                    decoration: AppModalDialog.inputDecoration('Template Title *', focusColor: const Color(0xFF10B981)),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _examCtrl,
                    decoration: AppModalDialog.inputDecoration('Target Exam (e.g. SSC CGL)', focusColor: const Color(0xFF10B981)),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: AppDropdown.simple(
                          label: 'Subject',
                          value: _subject,
                          items: AiTestSubject.values,
                          itemLabel: (s) => s.label,
                          onChanged: (v) {
                            if (v != null) setState(() => _subject = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppDropdown.simple(
                          label: 'Difficulty',
                          value: _difficulty,
                          items: AiTestDifficulty.values,
                          itemLabel: (d) => d.label,
                          onChanged: (v) {
                            if (v != null) setState(() => _difficulty = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppDropdown.simple(
                          label: 'Questions',
                          value: _qCount,
                          items: const [25, 50, 75, 100],
                          itemLabel: (n) => '$n Qs',
                          onChanged: (v) {
                            if (v != null) setState(() => _qCount = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving ? null : () => setState(() => _isCreating = false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _createTemplate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: Text(_isSaving ? 'Saving...' : 'Save Template'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_templates.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No templates stored in Supabase yet.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                ),
              ),
            )
          else
            ..._templates.map((tpl) => _buildTemplateCard(context, tpl)),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, AiTestTemplate tpl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tpl.color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(tpl.icon, color: tpl.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tpl.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
                ),
                Text(
                  '${tpl.targetExam} • ${tpl.defaultQuestionCount} Qs • ${tpl.defaultDurationMinutes} min • ${tpl.defaultDifficulty.label}',
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onUseTemplate(tpl);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5636F5),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Use Template', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
