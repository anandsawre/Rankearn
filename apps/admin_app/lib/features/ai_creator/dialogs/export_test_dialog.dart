import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import '../models/ai_test_item.dart';

class ExportTestDialog extends StatefulWidget {
  final AiGeneratedTestItem? initialTest;
  final List<AiGeneratedTestItem> allTests;

  const ExportTestDialog({
    super.key,
    this.initialTest,
    required this.allTests,
  });

  @override
  State<ExportTestDialog> createState() => _ExportTestDialogState();
}

class _ExportTestDialogState extends State<ExportTestDialog> {
  AiGeneratedTestItem? _selectedTest;
  String _exportFormat = 'JSON'; // 'JSON', 'CSV'
  bool _includeSolutions = true;
  bool _includeHindiBilingual = true;

  @override
  void initState() {
    super.initState();
    _selectedTest = widget.initialTest ??
        (widget.allTests.isNotEmpty ? widget.allTests.first : null);
  }

  Future<void> _performExport() async {
    final test = _selectedTest;
    if (test == null) return;

    late final String output;
    if (_exportFormat == 'JSON') {
      output = const JsonEncoder.withIndent('  ').convert({
        ...test.toJson(),
        'questions': test.questions.map((q) {
          final map = q.toJson();
          if (!_includeSolutions) map.remove('explanation');
          if (!_includeHindiBilingual) {
            map.remove('question_text_hi');
            map.remove('explanation_hi');
          }
          return map;
        }).toList(),
      });
    } else {
      final buf = StringBuffer()
        ..writeln('question_number,question_text,options,correct_index,explanation');
      for (final q in test.questions) {
        final exp = _includeSolutions ? q.explanation : '';
        buf.writeln(
          '${q.questionNumber},"${q.questionText.replaceAll('"', '""')}","${q.options.join(' | ').replaceAll('"', '""')}",${q.correctOptionIndex},"${exp.replaceAll('"', '""')}"',
        );
      }
      output = buf.toString();
    }

    await Clipboard.setData(ClipboardData(text: output));
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "${test.title}" ($_exportFormat) to clipboard!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final test = _selectedTest;

    return AppModalDialog(
      iconData: Icons.ios_share_rounded,
      gradientColors: const [Color(0xFFE11D48), Color(0xFFF43F5E)],
      title: 'Export AI Test',
      subtitle: 'Copy test schema, answer key & solutions to clipboard',
      maxWidth: 540,
      scrollable: true,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: test == null ? null : _performExport,
          icon: const Icon(Icons.copy_rounded, size: 16),
          label: Text('Copy $_exportFormat'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5636F5),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
      child: test == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No AI tests available to export yet.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppDropdown.simple(
                  label: 'Select Test to Export',
                  value: test,
                  items: widget.allTests.isNotEmpty ? widget.allTests : [test],
                  itemLabel: (t) => t.title,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTest = val);
                  },
                ),
                const SizedBox(height: 14),
                const Text('Export Format', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildFormatTile('JSON', 'Rankearn Schema', Icons.code_rounded, const Color(0xFF5636F5)),
                    const SizedBox(width: 8),
                    _buildFormatTile('CSV', 'Excel Spreadsheet', Icons.table_chart_rounded, const Color(0xFF10B981)),
                  ],
                ),
                const SizedBox(height: 14),
                CheckboxListTile(
                  title: const Text('Include detailed solutions & answer key', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  value: _includeSolutions,
                  onChanged: (val) => setState(() => _includeSolutions = val ?? true),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: const Color(0xFF5636F5),
                ),
                CheckboxListTile(
                  title: const Text('Include Hindi bilingual translations', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  value: _includeHindiBilingual,
                  onChanged: (val) => setState(() => _includeHindiBilingual = val ?? true),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: const Color(0xFF5636F5),
                ),
              ],
            ),
    );
  }

  Widget _buildFormatTile(String format, String sub, IconData icon, Color color) {
    final isSel = _exportFormat == format;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _exportFormat = format),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSel ? color.withAlpha(15) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSel ? color : const Color(0xFFE2E8F0),
              width: isSel ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(format, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isSel ? color : AppColors.textPrimary)),
              Text(sub, style: const TextStyle(fontSize: 9, color: AppColors.textMuted), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
