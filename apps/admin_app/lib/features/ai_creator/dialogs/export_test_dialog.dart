import 'package:flutter/material.dart';
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
  late AiGeneratedTestItem _selectedTest;
  String _exportFormat = 'PDF'; // 'PDF', 'JSON', 'CSV'
  bool _includeSolutions = true;
  bool _includeHindiBilingual = true;

  @override
  void initState() {
    super.initState();
    _selectedTest = widget.initialTest ?? widget.allTests.first;
  }

  void _performExport() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Test "${_selectedTest.title}" exported successfully as $_exportFormat format.'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
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
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF43F5E).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.ios_share_rounded, color: Color(0xFFF43F5E), size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Export AI Test',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
                              ),
                              Text(
                                'Download question paper, answer key & solutions',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.borderSubtle),

              // Select Test to Export
              const Text('Select Test to Export', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              DropdownButtonFormField<AiGeneratedTestItem>(
                initialValue: _selectedTest,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                items: widget.allTests.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.title, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTest = val);
                },
              ),
              const SizedBox(height: 14),

              // Export Format Options
              const Text('Export Format', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildFormatTile('PDF', 'Printable Exam Paper', Icons.picture_as_pdf_rounded, const Color(0xFFEF4444)),
                  const SizedBox(width: 8),
                  _buildFormatTile('JSON', 'Rankearn Schema', Icons.code_rounded, const Color(0xFF5636F5)),
                  const SizedBox(width: 8),
                  _buildFormatTile('CSV', 'Excel Spreadsheet', Icons.table_chart_rounded, const Color(0xFF10B981)),
                ],
              ),
              const SizedBox(height: 14),

              // Export Options Toggles
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
                title: const Text('Include bilingual Hindi translation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                value: _includeHindiBilingual,
                onChanged: (val) => setState(() => _includeHindiBilingual = val ?? true),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: const Color(0xFF5636F5),
              ),

              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _performExport,
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: Text('Download $_exportFormat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5636F5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatTile(String format, String desc, IconData icon, Color color) {
    final isSelected = _exportFormat == format;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _exportFormat = format),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(15) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : AppColors.textSecondary, size: 20),
              const SizedBox(height: 4),
              Text(format, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? color : AppColors.textPrimary)),
              Text(desc, style: const TextStyle(fontSize: 9, color: AppColors.textMuted), textAlign: TextAlign.center, maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}
