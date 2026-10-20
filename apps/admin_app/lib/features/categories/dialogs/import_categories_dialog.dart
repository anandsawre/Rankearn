import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/category_item.dart';

class ImportCategoriesDialog extends StatefulWidget {
  final ValueChanged<List<CategoryItem>> onImport;

  const ImportCategoriesDialog({super.key, required this.onImport});

  @override
  State<ImportCategoriesDialog> createState() => _ImportCategoriesDialogState();
}

class _ImportCategoriesDialogState extends State<ImportCategoriesDialog> {
  final _textController = TextEditingController();
  List<CategoryItem> _parsedItems = [];
  String? _error;
  bool _isValidated = false;

  final String _sampleJson = '''[
  {
    "name": "Artificial Intelligence & ML",
    "description": "Machine learning, prompt engineering, and deep learning",
    "icon_name": "psychology",
    "icon_color": "#8B5CF6",
    "status": "active"
  },
  {
    "name": "Cybersecurity & Ethical Hacking",
    "description": "Network defense, vulnerability assessment, and certs",
    "icon_name": "code",
    "icon_color": "#10B981",
    "status": "draft"
  }
]''';

  @override
  void initState() {
    super.initState();
    _textController.text = _sampleJson;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _error = null;
      _parsedItems = [];
      _isValidated = false;
    });

    try {
      final decoded = jsonDecode(_textController.text.trim());
      if (decoded is! List) {
        throw 'Input must be a JSON array of category objects.';
      }

      final items = <CategoryItem>[];
      for (int i = 0; i < decoded.length; i++) {
        final row = decoded[i];
        if (row is! Map<String, dynamic>) {
          throw 'Row ${i + 1} is not a valid JSON object.';
        }
        if (row['name'] == null || row['name'].toString().trim().isEmpty) {
          throw 'Row ${i + 1}: "name" is required.';
        }

        final name = row['name'].toString().trim();
        items.add(CategoryItem(
          id: 'cat-imp-${DateTime.now().millisecondsSinceEpoch}-$i',
          index: i + 1,
          name: name,
          slug: row['slug']?.toString() ?? name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
          description: row['description']?.toString() ?? '',
          iconName: row['icon_name']?.toString() ?? 'school',
          iconColor: row['icon_color']?.toString() ?? '#3B82F6',
          status: CategoryStatus.fromString(row['status']?.toString()),
          createdAt: DateTime.now(),
        ));
      }

      setState(() {
        _parsedItems = items;
        _isValidated = true;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isValidated = false;
      });
    }
  }

  void _confirmImport() {
    if (_parsedItems.isEmpty) return;
    widget.onImport(_parsedItems);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
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
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.file_upload_outlined, color: Color(0xFF0284C7), size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Import Categories (CSV / JSON)',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101A3A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFE2E8F0)),

              // Instructions
              const Text(
                'Paste your categories JSON array below to bulk import. Each category requires a "name".',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 10),

              // Code Input Area
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
              ),

              // Validation Message or Error
              if (_error != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFDA4AF)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFFE11D48), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              if (_isValidated) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF6EE7B7)),
                  ),
                  child: Text(
                    '✓ Validated successfully! ${_parsedItems.length} categories ready to import.',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF047857), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Footer Actions
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 8,
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: _validate,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0284C7)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Validate & Parse Data', style: TextStyle(color: Color(0xFF0284C7))),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isValidated ? _confirmImport : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Import (${_parsedItems.length})'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
