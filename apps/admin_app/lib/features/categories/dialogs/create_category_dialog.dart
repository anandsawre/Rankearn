import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import '../models/category_item.dart';
import 'manage_target_exams_dialog.dart';

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

  String? _selectedExamId;
  late CategoryStatus _status;
  late String _iconName;
  late String _iconColor;

  List<ExamCategoryModel> _examList = const [
    ExamCategoryModel(id: 'bpsc', name: 'BPSC & State PCS', iconUrl: '🏛️'),
    ExamCategoryModel(id: 'ssc', name: 'SSC CGL & CHSL', iconUrl: '📋'),
    ExamCategoryModel(id: 'upsc', name: 'UPSC Civil Services', iconUrl: '🇮🇳'),
    ExamCategoryModel(id: 'railway', name: 'RRB NTPC & Group D', iconUrl: '🚆'),
    ExamCategoryModel(id: 'banking', name: 'Banking & Insurance', iconUrl: '🏦'),
  ];

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
    '#5636F5', // Purple
    '#3B82F6', // Blue
    '#10B981', // Emerald
    '#F59E0B', // Amber
    '#F43F5E', // Rose
    '#8B5CF6', // Violet
    '#06B6D4', // Cyan
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

    _selectedExamId = item?.examCategoryId;
    _status = item?.status ?? CategoryStatus.active;
    _iconName = item?.iconName ?? 'school';
    _iconColor = item?.iconColor ?? '#5636F5';

    _nameCtrl.addListener(() {
      if (widget.itemToEdit == null && _slugCtrl.text.isEmpty) {
        _slugCtrl.text = _nameCtrl.text
            .toLowerCase()
            .trim()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      }
    });

    _loadExams();
  }

  Future<void> _loadExams() async {
    final res = await TestsRepository().getExamCategoryList();
    if (res is Success<List<ExamCategoryModel>> && res.data.isNotEmpty && mounted) {
      setState(() {
        _examList = res.data;
      });
    }
  }

  void _openTargetExamsManager() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ManageTargetExamsDialog(
        onExamsUpdated: _loadExams,
      ),
    );
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

    final item = (widget.itemToEdit ?? CategoryItem(
      id: 'cat-${DateTime.now().millisecondsSinceEpoch % 100000}',
      index: 1,
      name: '',
      slug: '',
      description: '',
      createdAt: DateTime.now(),
    )).copyWith(
      name: _nameCtrl.text.trim(),
      examCategoryId: _selectedExamId,
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

    return AppModalDialog(
      title: isEditing ? 'Edit Subject' : 'Create New Subject',
      subtitle: isEditing
          ? 'Update subject curriculum attributes and target exam mapping'
          : 'Define a new subject and configure target exams',
      iconData: isEditing ? Icons.edit_rounded : Icons.add_rounded,
      gradientColors: const [Color(0xFF5636F5), Color(0xFF2587F8)],
      maxWidth: 580,
      maxHeight: 740,
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
            isEditing ? 'Save Changes' : 'Create Subject',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ],
      child: Form(
        key: _formKey,
        child: _buildFormFields(isCompact: false),
      ),
    );
  }

  Widget _buildFormFields({required bool isCompact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),

        // Subject Name
        const Text('Subject Name *', style: _labelStyle),
        const SizedBox(height: 4),
        TextFormField(
          controller: _nameCtrl,
          validator: (v) => v == null || v.trim().isEmpty ? 'Subject name is required' : null,
          style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
          decoration: _inputDecoration('e.g. Indian History, General Science, Mathematics'),
        ),
        const SizedBox(height: 12),

        // Description
        const Text('Description / Overview', style: _labelStyle),
        const SizedBox(height: 4),
        TextFormField(
          controller: _descCtrl,
          maxLines: 2,
          style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
          decoration: _inputDecoration('e.g. Complete syllabus tests with detailed solutions'),
        ),
        const SizedBox(height: 12),

        // Target Exam & Publication Status Row
        if (isCompact) ...[
          _buildTargetExamField(),
          const SizedBox(height: 12),
          _buildStatusField(),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTargetExamField()),
              const SizedBox(width: 12),
              Expanded(child: _buildStatusField()),
            ],
          ),
        const SizedBox(height: 12),

        // Slug & Order Row
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
                    decoration: _inputDecoration('e.g. general-science'),
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
        const SizedBox(height: 14),

        // Category Icon Selection
        const Text('Subject Icon', style: _labelStyle),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableIcons.map((item) {
            final isSel = _iconName == item.name;
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _iconName = item.name),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFF5636F5) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSel ? const Color(0xFF5636F5) : const Color(0xFFCBD5E1),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  item.icon,
                  color: isSel ? Colors.white : const Color(0xFF64748B),
                  size: 18,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Color Theme Selection
        const Text('Color Theme', style: _labelStyle),
        const SizedBox(height: 6),
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
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSel ? const Color(0xFF101A3A) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: isSel
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTargetExamField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Target Exam', style: _labelStyle),
            InkWell(
              onTap: _openTargetExamsManager,
              child: const Text(
                '+ Manage',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5636F5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AppDropdown<String?>(
          value: _examList.any((e) => e.id == _selectedExamId) ? _selectedExamId : null,
          hint: 'All Exams / General',
          isDense: true,
          fillColor: Colors.white,
          borderColor: const Color(0xFFCBD5E1),
          focusedBorderColor: const Color(0xFF5636F5),
          selectedItemColor: const Color(0xFF5636F5),
          selectedItemBackgroundColor: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(8),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9.5),
          items: [
            const AppDropdownItem<String?>(
              value: null,
              label: 'All Exams / General',
              icon: Icons.public_rounded,
            ),
            ..._examList.map((exam) => AppDropdownItem<String?>(
              value: exam.id,
              label: exam.name,
              leading: Text(exam.iconUrl ?? '🎯', style: const TextStyle(fontSize: 14)),
            )),
          ],
          onChanged: (val) {
            setState(() {
              _selectedExamId = val;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Publication Status', style: _labelStyle),
        const SizedBox(height: 4),
        AppDropdown<CategoryStatus>(
          value: _status,
          isDense: true,
          fillColor: Colors.white,
          borderColor: const Color(0xFFCBD5E1),
          focusedBorderColor: const Color(0xFF5636F5),
          selectedItemColor: const Color(0xFF5636F5),
          selectedItemBackgroundColor: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(8),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9.5),
          items: CategoryStatus.values.map((s) => AppDropdownItem<CategoryStatus>(
            value: s,
            label: s.label,
            leading: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
            ),
          )).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _status = val);
          },
        ),
      ],
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Color(0xFF101A3A),
  );

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF5636F5), width: 1.5),
      ),
    );
  }
}
