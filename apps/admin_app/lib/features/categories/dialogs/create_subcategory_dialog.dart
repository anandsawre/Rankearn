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
      gradientColors: const [Color(0xFFFF9500), Color(0xFFF59E0B)],
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
            backgroundColor: const Color(0xFFFF9500),
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
        // Parent Subject / Category (Level 2)
        AppDropdown<String>(
          value: _selectedCategoryId,
          hint: 'Select Parent Subject *',
          isDense: true,
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
        AppModalDialog.textField(
          controller: _nameCtrl,
          hint: 'Subcategory Name * (e.g. Ancient History, Optics & Waves)',
          prefixIcon: const Icon(Icons.account_tree_outlined, size: 17, color: Color(0xFF94A3B8)),
          validator: (v) => v == null || v.trim().isEmpty ? 'Subcategory name is required' : null,
        ),
        const SizedBox(height: 12),

        // Slug / ID & Display Order Row
        Row(
          children: [
            Expanded(
              flex: 65,
              child: AppModalDialog.textField(
                controller: _slugCtrl,
                hint: 'Slug / URL ID (e.g. ancient-history)',
                prefixIcon: const Icon(Icons.link_rounded, size: 16, color: Color(0xFF94A3B8)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 35,
              child: AppModalDialog.textField(
                controller: _orderCtrl,
                hint: 'Order (1)',
                keyboardType: TextInputType.number,
                suffixText: 'order',
                suffixStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Description
        AppModalDialog.textField(
          controller: _descCtrl,
          maxLines: 2,
          hint: 'Description / Overview (chapters & syllabus)...',
        ),
        const SizedBox(height: 12),

        // Status
        AppDropdown<String>(
          value: _status,
          hint: 'Status',
          isDense: true,
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
}
