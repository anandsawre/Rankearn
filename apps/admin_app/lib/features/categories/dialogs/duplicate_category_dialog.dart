import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/category_item.dart';

class DuplicateCategoryDialog extends StatefulWidget {
  final CategoryItem sourceCategory;
  final ValueChanged<CategoryItem> onDuplicate;

  const DuplicateCategoryDialog({
    super.key,
    required this.sourceCategory,
    required this.onDuplicate,
  });

  @override
  State<DuplicateCategoryDialog> createState() => _DuplicateCategoryDialogState();
}

class _DuplicateCategoryDialogState extends State<DuplicateCategoryDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _slugCtrl;
  bool _copySubcategories = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: '${widget.sourceCategory.name} (Copy)');
    _slugCtrl = TextEditingController(text: '${widget.sourceCategory.slug}-copy');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final duplicated = widget.sourceCategory.copyWith(
      id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      slug: _slugCtrl.text.trim().isNotEmpty
          ? _slugCtrl.text.trim()
          : name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
      subcategoriesCount: _copySubcategories ? widget.sourceCategory.subcategoriesCount : 0,
      totalTests: 0,
      totalQuestions: 0,
      status: CategoryStatus.draft,
      createdAt: DateTime.now(),
    );

    widget.onDuplicate(duplicated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Duplicate Category',
      subtitle: 'Create a cloned copy of "${widget.sourceCategory.name}" as draft',
      iconData: Icons.content_copy_rounded,
      gradientColors: const [Color(0xFFE11D48), Color(0xFFF43F5E)],
      maxWidth: 480,
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
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            elevation: 0,
          ),
          child: const Text('Duplicate', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New Category Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          TextField(
            controller: _nameCtrl,
            decoration: _inputDec('Enter new name'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 14),

          const Text('New Slug (URL Identifier)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          TextField(
            controller: _slugCtrl,
            decoration: _inputDec('Enter new slug'),
            style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: CheckboxListTile(
              value: _copySubcategories,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFFE11D48),
              title: const Text('Copy subcategories hierarchy structure', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              onChanged: (val) => setState(() => _copySubcategories = val ?? true),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
      ),
    );
  }
}
