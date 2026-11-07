import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/category_item.dart';

/// Subcategories Table Card powered by unified [AdminDataTableCard].
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

    return AdminDataTableCard(
      title: 'Subcategories / Units',
      totalCount: widget.subcategories.length,
      icon: Icons.account_tree_rounded,
      iconBgColor: const Color(0xFF10B981),
      searchQuery: _searchQuery,
      searchHint: 'Search subcategories...',
      onSearchChanged: (val) => setState(() => _searchQuery = val),
      itemLabel: 'subcategories',
      filterControls: [
        SizedBox(
          width: 220,
          child: AppDropdown<String?>(
            value: _selectedCategoryFilter,
            hint: 'Filter by Subject',
            isDense: true,
            fillColor: const Color(0xFFF8FAFC),
            borderColor: const Color(0xFFE2E8F0),
            focusedBorderColor: AppColors.brandPurple,
            selectedItemColor: AppColors.brandPurple,
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
      ],
      headerActions: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Add Subcategory'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            elevation: 0,
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          onPressed: widget.onAddSubcategory,
        ),
      ],
      customBody: (isMobile && filtered.isNotEmpty)
          ? ListView.separated(
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
                      AdminTableActionButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit',
                        onPressed: () => widget.onEditSubcategory(sub),
                      ),
                      const SizedBox(width: 4),
                      AdminTableActionButton(
                        icon: Icons.delete_outline_rounded,
                        tooltip: 'Delete',
                        onPressed: () => widget.onDeleteSubcategory(sub),
                      ),
                    ],
                  ),
                );
              },
            )
          : null,
      columns: const [
        DataColumn(label: Text('SUBCATEGORY NAME', style: _colHeaderStyle)),
        DataColumn(label: Text('PARENT SUBJECT', style: _colHeaderStyle)),
        DataColumn(label: Text('ORDER', style: _colHeaderStyle)),
        DataColumn(label: Text('STATUS', style: _colHeaderStyle)),
        DataColumn(label: Text('ACTIONS', style: _colHeaderStyle)),
      ],
      rows: filtered.map((sub) {
        return DataRow(
          cells: [
            DataCell(
              Text(
                sub.name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
              ),
            ),
            DataCell(
              Text(
                _getCategoryName(sub.categoryId),
                style: const TextStyle(fontSize: 12, color: AppColors.brandPurple, fontWeight: FontWeight.w600),
              ),
            ),
            DataCell(
              Text(
                '${sub.displayOrder}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
              ),
            ),
            DataCell(
              Container(
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
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminTableActionButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit',
                    onPressed: () => widget.onEditSubcategory(sub),
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete',
                    onPressed: () => widget.onDeleteSubcategory(sub),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
      emptyState: Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: const Column(
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: Color(0xFFCBD5E1)),
            SizedBox(height: 8),
            Text('No subcategories found for this filter', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ],
        ),
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
