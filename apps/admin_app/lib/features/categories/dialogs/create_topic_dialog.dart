import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import '../models/category_item.dart';

class CreateTopicDialog extends StatefulWidget {
  final TopicModel? itemToEdit;
  final List<CategoryItem> categories;
  final List<SubcategoryItem> subcategories;
  final String? initialCategoryId;
  final String? initialSubcategoryId;
  final ValueChanged<TopicModel> onSave;

  const CreateTopicDialog({
    super.key,
    this.itemToEdit,
    required this.categories,
    required this.subcategories,
    this.initialCategoryId,
    this.initialSubcategoryId,
    required this.onSave,
  });

  @override
  State<CreateTopicDialog> createState() => _CreateTopicDialogState();
}

class _CreateTopicDialogState extends State<CreateTopicDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _slugCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _orderCtrl;

  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
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

    final validSubs = widget.subcategories
        .where((s) => _selectedCategoryId == null || s.categoryId == _selectedCategoryId)
        .toList();

    _selectedSubcategoryId = item?.subcategoryId ??
        widget.initialSubcategoryId ??
        (validSubs.isNotEmpty ? validSubs.first.id : null);

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

  List<SubcategoryItem> get _filteredSubcategories {
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      return widget.subcategories;
    }
    return widget.subcategories
        .where((s) => s.categoryId == _selectedCategoryId)
        .toList();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubcategoryId == null || _selectedSubcategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a parent Subcategory (Level 3)'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final id = _slugCtrl.text.trim().isNotEmpty
        ? _slugCtrl.text.trim()
        : 'top-${DateTime.now().millisecondsSinceEpoch}';

    final item = TopicModel(
      id: widget.itemToEdit?.id ?? id,
      subcategoryId: _selectedSubcategoryId!,
      categoryId: _selectedCategoryId,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 640;

    // 📱 Mobile Full Screen Mode
    if (isMobile) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: Colors.white,
        child: SizedBox.expand(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5636F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isEditing ? Icons.edit_rounded : Icons.add_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isEditing ? 'Edit Topic (Level 4)' : 'Create Topic (Level 4)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101A3A),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFields(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),

                // Mobile Footer
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5636F5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          onPressed: _submit,
                          child: Text(
                            isEditing ? 'Save Changes' : 'Create Topic',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 💻 Desktop AlertDialog
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF5636F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isEditing ? Icons.edit_rounded : Icons.add_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isEditing ? 'Edit Topic / Chapter (Level 4)' : 'Create Topic / Chapter (Level 4)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101A3A),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFields(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5636F5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: 0,
          ),
          onPressed: _submit,
          child: Text(
            isEditing ? 'Save Changes' : 'Create Topic',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildFields() {
    final subcategoriesList = _filteredSubcategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),

        // Parent Subject / Category (Level 2)
        const Text('Parent Subject (Level 2) *', style: _labelStyle),
        const SizedBox(height: 4),
        AppDropdown<String>(
          value: _selectedCategoryId,
          hint: 'Select Parent Category',
          isDense: true,
          fillColor: const Color(0xFFF8FAFC),
          borderColor: const Color(0xFFE2E8F0),
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
            setState(() {
              _selectedCategoryId = val;
              final subs = widget.subcategories.where((s) => s.categoryId == val).toList();
              _selectedSubcategoryId = subs.isNotEmpty ? subs.first.id : null;
            });
          },
        ),
        const SizedBox(height: 12),

        // Parent Subcategory (Level 3)
        const Text('Parent Subcategory / Unit (Level 3) *', style: _labelStyle),
        const SizedBox(height: 4),
        AppDropdown<String>(
          value: subcategoriesList.any((s) => s.id == _selectedSubcategoryId)
              ? _selectedSubcategoryId
              : (subcategoriesList.isNotEmpty ? subcategoriesList.first.id : null),
          hint: subcategoriesList.isEmpty ? 'No Subcategories in this Subject' : 'Select Subcategory',
          isDense: true,
          fillColor: const Color(0xFFF8FAFC),
          borderColor: const Color(0xFFE2E8F0),
          focusedBorderColor: const Color(0xFF5636F5),
          selectedItemColor: const Color(0xFF5636F5),
          selectedItemBackgroundColor: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(8),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          items: subcategoriesList.map((s) {
            return AppDropdownItem<String>(
              value: s.id,
              label: s.name,
              icon: Icons.subdirectory_arrow_right_rounded,
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedSubcategoryId = val);
          },
        ),
        const SizedBox(height: 12),

        // Topic / Chapter Name (Level 4)
        const Text('Topic / Chapter Name (Level 4) *', style: _labelStyle),
        const SizedBox(height: 4),
        TextFormField(
          controller: _nameCtrl,
          validator: (v) => v == null || v.trim().isEmpty ? 'Topic name is required' : null,
          style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
          decoration: _inputDecoration('e.g. Indus Valley Civilization, Kinematics & Laws of Motion'),
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
                    decoration: _inputDecoration('e.g. indus-valley-civilization'),
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
          decoration: _inputDecoration('e.g. Concepts, important dates, formulas and mock questions'),
        ),
        const SizedBox(height: 12),

        // Status
        const Text('Status', style: _labelStyle),
        const SizedBox(height: 4),
        AppDropdown<String>(
          value: _status,
          isDense: true,
          fillColor: const Color(0xFFF8FAFC),
          borderColor: const Color(0xFFE2E8F0),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF5636F5), width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}

