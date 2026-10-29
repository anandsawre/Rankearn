import 'package:flutter/material.dart';
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                          color: const Color(0xFF10B981).withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.account_tree_outlined, color: Color(0xFF10B981), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Manage Chapters & Units',
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

              // Parent Subject Selector
              Row(
                children: [
                  const Text('Select Subject:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CategoryItem>(
                          value: widget.categories.contains(_selectedCategory) ? _selectedCategory : widget.categories.first,
                          isExpanded: true,
                          items: widget.categories.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Row(
                                children: [
                                  Icon(c.iconData, size: 16, color: c.parsedColor),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(c.name, style: const TextStyle(fontSize: 12.5), overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCategory = val;
                                _loadSampleSubcategories();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Add New Subcategory Input Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newSubcategoryCtrl,
                      decoration: InputDecoration(
                        hintText: 'Enter new subcategory name...',
                        hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      onSubmitted: (_) => _addSubcategory(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
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
              Expanded(
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Text('${idx + 1}.', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B), fontSize: 12)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(sub.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF101A3A))),
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
              const SizedBox(height: 16),

              // Footer Done Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5636F5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
