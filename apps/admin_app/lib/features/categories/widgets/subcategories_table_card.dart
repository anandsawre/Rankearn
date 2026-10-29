import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/category_item.dart';

class SubcategoriesTableCard extends StatefulWidget {
  final List<SubcategoryItem> subcategories;
  final List<CategoryItem> categories;
  final VoidCallback onAddSubcategory;
  final ValueChanged<SubcategoryItem> onEditSubcategory;
  final ValueChanged<SubcategoryItem> onDeleteSubcategory;

  const SubcategoriesTableCard({
    super.key,
    required this.subcategories,
    required this.categories,
    required this.onAddSubcategory,
    required this.onEditSubcategory,
    required this.onDeleteSubcategory,
  });

  @override
  State<SubcategoriesTableCard> createState() => _SubcategoriesTableCardState();
}

class _SubcategoriesTableCardState extends State<SubcategoriesTableCard> {
  String _searchQuery = '';
  String? _selectedCategoryFilter;
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SubcategoryItem> get _filteredSubcategories {
    return widget.subcategories.where((s) {
      if (_selectedCategoryFilter != null && _selectedCategoryFilter!.isNotEmpty) {
        if (s.categoryId != _selectedCategoryFilter) return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        if (!s.name.toLowerCase().contains(q) && !s.id.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  String _getCategoryName(String categoryId) {
    final cat = widget.categories.where((c) => c.id == categoryId).firstOrNull;
    return cat?.name ?? categoryId;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSubcategories;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row with Title and Add Button
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.account_tree_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Subcategories / Units (Level 3)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101A3A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.subcategories.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Subcategory'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5636F5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 0,
                ),
                onPressed: widget.onAddSubcategory,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filters Row: Parent Subject Dropdown + Search Input
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 220,
                child: AppDropdown<String?>(
                  value: _selectedCategoryFilter,
                  hint: 'Filter by Subject',
                  isDense: true,
                  fillColor: const Color(0xFFF8FAFC),
                  borderColor: const Color(0xFFE2E8F0),
                  focusedBorderColor: const Color(0xFF5636F5),
                  selectedItemColor: const Color(0xFF5636F5),
                  selectedItemBackgroundColor: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  items: [
                    const AppDropdownItem<String?>(value: null, label: 'All Subjects (Level 2)'),
                    ...widget.categories.map((c) => AppDropdownItem<String?>(
                      value: c.id,
                      label: c.name,
                      leading: Icon(c.iconData, size: 16, color: c.parsedColor),
                    )),
                  ],
                  onChanged: (val) => setState(() => _selectedCategoryFilter = val),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 240, maxWidth: 360),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF101A3A)),
                  decoration: InputDecoration(
                    hintText: 'Search subcategories...',
                    hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subcategories Table / List
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 40, color: Color(0xFFCBD5E1)),
                  SizedBox(height: 8),
                  Text('No subcategories found for this filter', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                ],
              ),
            )
          else if (isMobile)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final sub = filtered[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.account_tree_outlined, color: Color(0xFF10B981), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sub.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF101A3A))),
                            const SizedBox(height: 3),
                            Text('Subject: ${_getCategoryName(sub.categoryId)} • Order: ${sub.displayOrder}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                        onPressed: () => widget.onEditSubcategory(sub),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFF43F5E)),
                        onPressed: () => widget.onDeleteSubcategory(sub),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2.6),
                1: FlexColumnWidth(2.0),
                2: FlexColumnWidth(1.0),
                3: FlexColumnWidth(1.0),
                4: FlexColumnWidth(1.0),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  children: [
                    Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('SUBCATEGORY NAME', style: _colHeaderStyle)),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('PARENT SUBJECT', style: _colHeaderStyle)),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('ORDER', style: _colHeaderStyle)),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('STATUS', style: _colHeaderStyle)),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('ACTIONS', style: _colHeaderStyle)),
                  ],
                ),
                ...filtered.map((sub) {
                  return TableRow(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(sub.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF101A3A))),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(_getCategoryName(sub.categoryId), style: const TextStyle(fontSize: 12, color: Color(0xFF5636F5), fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text('${sub.displayOrder}', style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B))),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: sub.status == 'active' ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            sub.status == 'active' ? 'Active' : 'Draft',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: sub.status == 'active' ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                              onPressed: () => widget.onEditSubcategory(sub),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFF43F5E)),
                              onPressed: () => widget.onDeleteSubcategory(sub),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  static const _colHeaderStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: Color(0xFF64748B),
    letterSpacing: 0.5,
  );
}

