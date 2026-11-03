import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
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
        final map = decoded[i];
        if (map is! Map<String, dynamic>) {
          throw 'Item at index $i is not a valid JSON object.';
        }

        final name = map['name']?.toString().trim();
        if (name == null || name.isEmpty) {
          throw 'Item at index $i is missing required "name" field.';
        }

        final id = map['id']?.toString() ?? 'cat-${DateTime.now().millisecondsSinceEpoch + i}';
        final slug = map['slug']?.toString() ?? name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
        final desc = map['description']?.toString() ?? '';
        final iconName = map['icon_name']?.toString() ?? 'school';
        final iconColor = map['icon_color']?.toString() ?? '#5636F5';

        CategoryStatus status = CategoryStatus.active;
        final statusStr = map['status']?.toString().toLowerCase();
        if (statusStr == 'draft') status = CategoryStatus.draft;
        if (statusStr == 'archived') status = CategoryStatus.archived;

        items.add(CategoryItem(
          id: id,
          index: i + 1,
          name: name,
          slug: slug,
          description: desc,
          iconName: iconName,
          iconColor: iconColor,
          status: status,
          displayOrder: i + 1,
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
    return AppModalDialog(
      title: 'Import Categories',
      subtitle: 'Bulk import categories and subjects via JSON array',
      iconData: Icons.file_upload_outlined,
      gradientColors: const [Color(0xFF0284C7), Color(0xFF0EA5E9)],
      maxWidth: 620,
      maxHeight: 700,
      footerLeft: OutlinedButton(
        onPressed: _validate,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF0284C7)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        child: const Text('Validate & Parse Data', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.w600, fontSize: 13)),
      ),
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
          onPressed: _isValidated ? _confirmImport : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            elevation: 0,
          ),
          child: Text('Import (${_parsedItems.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Paste your categories JSON array below to bulk import. Each category requires a "name".',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),

          // Code Input Area
          SizedBox(
            height: 220,
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFF1E293B)),
              decoration: AppModalDialog.inputDecoration(
                '',
                focusColor: const Color(0xFF0284C7),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),

          // Validation Message or Error
          if (_error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDA4AF)),
              ),
              child: Text(
                _error!,
                style: const TextStyle(fontSize: 12, color: Color(0xFFE11D48), fontWeight: FontWeight.w600),
              ),
            ),
          ],
          if (_isValidated) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF6EE7B7)),
              ),
              child: Text(
                '✓ Validated successfully! ${_parsedItems.length} categories ready to import.',
                style: const TextStyle(fontSize: 12, color: Color(0xFF047857), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
