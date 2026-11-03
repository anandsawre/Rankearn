import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/category_item.dart';

class CreateSubcategoryDialog extends StatefulWidget {
  final SubcategoryItem? itemToEdit;
  final List<CategoryItem> categories;
  final String? initialCategoryId;
  final ValueChanged<SubcategoryItem> onSave;

  const CreateSubcategoryDialog({
    super.key,
    this.itemToEdit,
    required this.categories,
    this.initialCategoryId,
    required this.onSave,
  });

  @override
  State<CreateSubcategoryDialog> createState() => _CreateSubcategoryDialogState();
}

class _CreateSubcategoryDialogState extends State<CreateSubcategoryDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _slugCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _orderCtrl;

  String? _selectedCategoryId;
  late String _status;

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _slugCtrl = TextEditingController(text: item?.id ?? '');
    _descCtrl = TextEditingController(text: item?.description ?? '');
    _orderCtrl = TextEditingController(text: (item?.displayOrder ?? 1).toString());

    _selectedCategoryId = item?.categoryId ??
        widget.initialCategoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : null);
    _status = item?.status ?? 'active';

    _nameCtrl.addListener(() {
      if (widget.itemToEdit == null && _slugCtrl.text.isEmpty) {
        _slugCtrl.text = _nameCtrl.text
            .toLowerCase()
            .trim()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _descCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a parent Category / Subject'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final id = _slugCtrl.text.trim().isNotEmpty
        ? _slugCtrl.text.trim()
        : 'sub-${DateTime.now().millisecondsSinceEpoch}';

    final item = SubcategoryItem(
      id: widget.itemToEdit?.id ?? id,
      categoryId: _selectedCategoryId!,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      displayOrder: int.tryParse(_orderCtrl.text.trim()) ?? 1,
      status: _status,
      createdAt: widget.itemToEdit?.createdAt ?? DateTime.now(),
    );

    widget.onSave(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemToEdit != null;

    return AppModalDialog(
      title: isEditing ? 'Edit Subcategory' : 'Create Subcategory',
      subtitle: isEditing
          ? 'Update chapter or subcategory details'
          : 'Define a new chapter or unit under a parent subject',
      iconData: isEditing ? Icons.edit_rounded : Icons.add_rounded,
      gradientColors: const [Color(0xFF5636F5), Color(0xFF2587F8)],
      maxWidth: 540,
      maxHeight: 700,
      scrollable: true,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5636F5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          onPressed: _submit,
          child: Text(
            isEditing ? 'Save Changes' : 'Create Subcategory',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ],
      child: Form(
        key: _formKey,
        child: _buildFields(),
      ),
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),

        // Parent Subject / Category (Level 2)
        const Text('Parent Subject / Category (Level 2) *', style: _labelStyle),
        const SizedBox(height: 4),
        AppDropdown<String>(
          value: _selectedCategoryId,
          hint: 'Select Parent Category',
          isDense: true,
          fillColor: Colors.white,
          borderColor: const Color(0xFFCBD5E1),
          focusedBorderColor: const Color(0xFF5636F5),
          selectedItemColor: const Color(0xFF5636F5),
          selectedItemBackgroundColor: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(8),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          items: widget.categories.map((c) {
            return AppDropdownItem<String>(
              value: c.id,
              label: c.name,
              leading: Icon(c.iconData, size: 16, color: c.parsedColor),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategoryId = val);
          },
        ),
        const SizedBox(height: 12),

        // Subcategory Name
        const Text('Subcategory Name (Level 3) *', style: _labelStyle),
        const SizedBox(height: 4),
        TextFormField(
          controller: _nameCtrl,
          validator: (v) => v == null || v.trim().isEmpty ? 'Subcategory name is required' : null,
          style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
          decoration: _inputDecoration('e.g. Ancient History, Optics & Waves, Organic Chemistry'),
        ),
        const SizedBox(height: 12),

        // Slug / ID & Display Order Row
        Row(
          children: [
            Expanded(
              flex: 65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Slug (URL Identifier)', style: _labelStyle),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _slugCtrl,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                    decoration: _inputDecoration('e.g. ancient-history'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 35,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Display Order', style: _labelStyle),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _orderCtrl,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('1'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Description
        const Text('Description / Overview', style: _labelStyle),
        const SizedBox(height: 4),
        TextFormField(
          controller: _descCtrl,
          maxLines: 2,
          style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
          decoration: _inputDecoration('e.g. Chapters and tests for ancient Indian history and culture'),
        ),
        const SizedBox(height: 12),

        // Status
        const Text('Status', style: _labelStyle),
        const SizedBox(height: 4),
        AppDropdown<String>(
          value: _status,
          isDense: true,
          fillColor: Colors.white,
          borderColor: const Color(0xFFCBD5E1),
          focusedBorderColor: const Color(0xFF5636F5),
          selectedItemColor: const Color(0xFF5636F5),
          selectedItemBackgroundColor: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(8),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          items: const [
            AppDropdownItem<String>(
              value: 'active',
              label: 'Active',
              leading: Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
            ),
            AppDropdownItem<String>(
              value: 'draft',
              label: 'Draft',
              leading: Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFFF59E0B)),
            ),
            AppDropdownItem<String>(
              value: 'archived',
              label: 'Archived',
              leading: Icon(Icons.archive_rounded, size: 16, color: Color(0xFF94A3B8)),
            ),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _status = val);
          },
        ),
      ],
    );
  }

  static const _labelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1E293B),
  );

  InputDecoration _inputDecoration(String hint) =>
      AppModalDialog.inputDecoration(hint, focusColor: const Color(0xFF5636F5));
}
