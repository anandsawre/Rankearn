import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/category_item.dart';

class ManageSubcategoriesDialog extends StatefulWidget {
  final List<CategoryItem> categories;
  final CategoryItem? initialCategory;

  const ManageSubcategoriesDialog({
    super.key,
    required this.categories,
    this.initialCategory,
  });

  @override
  State<ManageSubcategoriesDialog> createState() => _ManageSubcategoriesDialogState();
}

class _ManageSubcategoriesDialogState extends State<ManageSubcategoriesDialog> {
  late CategoryItem _selectedCategory;
  final List<SubcategoryItem> _subcategories = [];
  final _newSubcategoryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? (widget.categories.isNotEmpty ? widget.categories.first : kReferenceCategories.first);
    _loadSampleSubcategories();
  }

  void _loadSampleSubcategories() {
    _subcategories.clear();
    final count = _selectedCategory.subcategoriesCount;
    for (int i = 1; i <= count; i++) {
      _subcategories.add(
        SubcategoryItem(
          id: 'sub-${_selectedCategory.id}-$i',
          categoryId: _selectedCategory.id,
          name: '${_selectedCategory.name} - Tier $i Section',
          description: 'Curriculum section $i for ${_selectedCategory.name}',
          displayOrder: i,
          createdAt: DateTime.now().subtract(Duration(days: i * 2)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _newSubcategoryCtrl.dispose();
    super.dispose();
  }

  void _addSubcategory() {
    final text = _newSubcategoryCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _subcategories.add(
        SubcategoryItem(
          id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
          categoryId: _selectedCategory.id,
          name: text,
          description: 'Custom subcategory for ${_selectedCategory.name}',
          displayOrder: _subcategories.length + 1,
          createdAt: DateTime.now(),
        ),
      );
      _newSubcategoryCtrl.clear();
    });
  }

  void _removeSubcategory(int index) {
    setState(() {
      _subcategories.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Manage Chapters & Units',
      subtitle: '${_subcategories.length} subcategories configured for ${_selectedCategory.name}',
      iconData: Icons.account_tree_outlined,
      gradientColors: const [Color(0xFF00B368), Color(0xFF10B981)],
      maxWidth: 620,
      maxHeight: 700,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B368),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            elevation: 0,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Parent Subject Selector
          Row(
            children: [
              const Text('Select Subject:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdown<String>(
                  value: _selectedCategory.id,
                  items: widget.categories.map((c) {
                    return AppDropdownItem<String>(
                      value: c.id,
                      label: c.name,
                      leading: Icon(c.iconData, size: 16, color: c.parsedColor),
                    );
                  }).toList(),
                  onChanged: (newCatId) {
                    if (newCatId != null) {
                      final found = widget.categories.firstWhere((c) => c.id == newCatId, orElse: () => _selectedCategory);
                      setState(() {
                        _selectedCategory = found;
                        _loadSampleSubcategories();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Add New Subcategory Input Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newSubcategoryCtrl,
                  decoration: AppModalDialog.inputDecoration(
                    'Enter new subcategory / chapter name...',
                    focusColor: const Color(0xFF00B368),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                  onSubmitted: (_) => _addSubcategory(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B368),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                onPressed: _addSubcategory,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subcategories List Area
          Text(
            'Existing Subcategories (${_subcategories.length})',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: _subcategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.folder_open_rounded, size: 36, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 6),
                        Text('No subcategories yet. Add one above.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _subcategories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 6),
                    itemBuilder: (context, idx) {
                      final sub = _subcategories[idx];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            Text('${idx + 1}.', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B), fontSize: 12)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(sub.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF101A3A))),
                                  if (sub.description.isNotEmpty)
                                    Text(sub.description, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFF43F5E)),
                              onPressed: () => _removeSubcategory(idx),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
