import 'package:flutter/material.dart';
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
  final _nameCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  bool _copySubcategories = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = '${widget.sourceCategory.name} (Copy)';
    _slugCtrl.text = '${widget.sourceCategory.slug}-copy';
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
      slug: _slugCtrl.text.trim().isEmpty
          ? name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          : _slugCtrl.text.trim(),
      subcategoriesCount: _copySubcategories ? widget.sourceCategory.subcategoriesCount : 0,
      subjectsCount: 0,
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
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
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF43F5E).withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.content_copy_rounded, color: Color(0xFFF43F5E), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Duplicate Category',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101A3A),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFE2E8F0)),

              Text(
                'Create a cloned copy of "${widget.sourceCategory.name}" as a draft.',
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),

              const Text('New Category Name *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                decoration: _inputDec('Enter new name'),
              ),
              const SizedBox(height: 14),

              const Text('New Slug', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextField(
                controller: _slugCtrl,
                decoration: _inputDec('Enter new slug'),
              ),
              const SizedBox(height: 14),

              CheckboxListTile(
                value: _copySubcategories,
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF5636F5),
                title: const Text('Copy subcategories hierarchy structure', style: TextStyle(fontSize: 12.5, color: Color(0xFF334155))),
                onChanged: (val) => setState(() => _copySubcategories = val ?? true),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
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
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF43F5E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Duplicate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    );
  }
}
