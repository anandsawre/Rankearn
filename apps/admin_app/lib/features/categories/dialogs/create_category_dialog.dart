import 'package:flutter/material.dart';
import '../models/category_item.dart';

class CreateCategoryDialog extends StatefulWidget {
  final CategoryItem? itemToEdit;
  final ValueChanged<CategoryItem> onSave;

  const CreateCategoryDialog({
    super.key,
    this.itemToEdit,
    required this.onSave,
  });

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _slugCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _orderCtrl;
  late final TextEditingController _topicsCtrl;
  String? _selectedExamId;
  late CategoryStatus _status;
  late String _iconName;
  late String _iconColor;

  final List<({String name, IconData icon})> _availableIcons = const [
    (name: 'school', icon: Icons.school_rounded),
    (name: 'menu_book', icon: Icons.menu_book_rounded),
    (name: 'account_balance', icon: Icons.account_balance_rounded),
    (name: 'auto_stories', icon: Icons.auto_stories_rounded),
    (name: 'code', icon: Icons.code_rounded),
    (name: 'public', icon: Icons.public_rounded),
    (name: 'assignment', icon: Icons.assignment_rounded),
    (name: 'psychology', icon: Icons.psychology_rounded),
    (name: 'biotech', icon: Icons.biotech_rounded),
    (name: 'calculate', icon: Icons.calculate_rounded),
  ];

  final List<String> _availableColors = const [
    '#3B82F6', // Blue
    '#F43F5E', // Rose
    '#F59E0B', // Amber
    '#8B5CF6', // Purple
    '#10B981', // Emerald
    '#06B6D4', // Cyan
    '#EC4899', // Pink
    '#64748B', // Slate
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _slugCtrl = TextEditingController(text: item?.slug ?? '');
    _descCtrl = TextEditingController(text: item?.description ?? '');
    _orderCtrl = TextEditingController(text: (item?.displayOrder ?? 1).toString());
    _topicsCtrl = TextEditingController(text: item?.topics.join(', ') ?? '');
    _selectedExamId = item?.examCategoryId;
    _status = item?.status ?? CategoryStatus.active;
    _iconName = item?.iconName ?? 'school';
    _iconColor = item?.iconColor ?? '#3B82F6';

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
    _topicsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final rawTopics = _topicsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final item = (widget.itemToEdit ?? CategoryItem(
      id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
      index: 1,
      name: '',
      slug: '',
      description: '',
      createdAt: DateTime.now(),
    )).copyWith(
      name: _nameCtrl.text.trim(),
      examCategoryId: _selectedExamId,
      topics: rawTopics,
      slug: _slugCtrl.text.trim().isEmpty
          ? _nameCtrl.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          : _slugCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      iconName: _iconName,
      iconColor: _iconColor,
      displayOrder: int.tryParse(_orderCtrl.text.trim()) ?? 1,
      status: _status,
      updatedAt: DateTime.now(),
    );

    widget.onSave(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
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
                            color: const Color(0xFF5636F5).withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.folder_rounded,
                            color: Color(0xFF5636F5),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isEditing ? 'Edit Category' : 'Create Category',
                          style: const TextStyle(
                            fontSize: 18,
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

                // Form Fields (Scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Category Name
                        const Text('Category Name *', style: _labelStyle),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: _inputDec('e.g. Indian History, General Science'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Category name is required' : null,
                        ),
                        const SizedBox(height: 14),

                        // Target Exam Category
                        const Text('Target Exam Category', style: _labelStyle),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedExamId,
                          decoration: _inputDec('Select Exam (e.g. BPSC, SSC)'),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('All Exams / General Subject')),
                            DropdownMenuItem(value: 'bpsc', child: Text('BPSC (Bihar Public Service Commission)')),
                            DropdownMenuItem(value: 'ssc', child: Text('SSC CGL & CHSL')),
                            DropdownMenuItem(value: 'upsc', child: Text('UPSC Civil Services')),
                            DropdownMenuItem(value: 'railway', child: Text('Railway RRB NTPC')),
                            DropdownMenuItem(value: 'banking', child: Text('Banking IBPS / SBI')),
                          ],
                          onChanged: (val) => setState(() => _selectedExamId = val),
                        ),
                        const SizedBox(height: 14),

                        // Topics / Chapters
                        const Text('Topics / Chapters (Comma Separated)', style: _labelStyle),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _topicsCtrl,
                          decoration: _inputDec('e.g. Ancient India, Medieval India, Modern India'),
                        ),
                        const SizedBox(height: 14),

                        // Slug & Display Order Row
                        Row(
                          children: [
                            Expanded(
                              flex: 65,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Slug (URL Identifier)', style: _labelStyle),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _slugCtrl,
                                    decoration: _inputDec('e.g. competitive-exams'),
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
                                  const Text('Order', style: _labelStyle),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _orderCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDec('1'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Description
                        const Text('Description', style: _labelStyle),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _descCtrl,
                          maxLines: 2,
                          decoration: _inputDec('Brief summary of categories and exams covered...'),
                        ),
                        const SizedBox(height: 14),

                        // Status Selection
                        const Text('Status', style: _labelStyle),
                        const SizedBox(height: 6),
                        Row(
                          children: CategoryStatus.values.map((s) {
                            final isSel = _status == s;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(s.label),
                                selected: isSel,
                                selectedColor: s.bgColor,
                                backgroundColor: const Color(0xFFF1F5F9),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  color: isSel ? s.color : const Color(0xFF475569),
                                ),
                                side: BorderSide(
                                  color: isSel ? s.color : const Color(0xFFE2E8F0),
                                ),
                                onSelected: (_) => setState(() => _status = s),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        // Icon Selection
                        const Text('Category Icon', style: _labelStyle),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableIcons.map((item) {
                            final isSel = _iconName == item.name;
                            return InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => setState(() => _iconName = item.name),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF5636F5) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSel ? const Color(0xFF5636F5) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  item.icon,
                                  color: isSel ? Colors.white : const Color(0xFF64748B),
                                  size: 20,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        // Color Selection
                        const Text('Category Color Theme', style: _labelStyle),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableColors.map((colorHex) {
                            final isSel = _iconColor.toUpperCase() == colorHex.toUpperCase();
                            final color = Color(int.parse('FF${colorHex.replaceAll('#', '')}', radix: 16));
                            return InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => setState(() => _iconColor = colorHex),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSel ? Colors.black : Colors.transparent,
                                    width: 2.2,
                                  ),
                                ),
                                child: isSel
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5636F5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _submit,
                      child: Text(isEditing ? 'Save Changes' : 'Create Category'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _labelStyle = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334155),
  );

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
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF5636F5)),
      ),
    );
  }
}
