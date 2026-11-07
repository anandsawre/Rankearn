import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import '../models/category_item.dart';

/// Topics Table Card powered by unified [AdminDataTableCard].
class TopicsTableCard extends StatefulWidget {
  final List<TopicModel> topics;
  final List<CategoryItem> categories;
  final List<SubcategoryItem> subcategories;
  final VoidCallback onAddTopic;
  final ValueChanged<TopicModel> onEditTopic;
  final ValueChanged<TopicModel> onDeleteTopic;

  const TopicsTableCard({
    super.key,
    required this.topics,
    required this.categories,
    required this.subcategories,
    required this.onAddTopic,
    required this.onEditTopic,
    required this.onDeleteTopic,
  });

  @override
  State<TopicsTableCard> createState() => _TopicsTableCardState();
}

class _TopicsTableCardState extends State<TopicsTableCard> {
  String _searchQuery = '';
  String? _selectedCategoryFilter;
  String? _selectedSubcategoryFilter;

  List<SubcategoryItem> get _availableSubcategories {
    if (_selectedCategoryFilter == null || _selectedCategoryFilter!.isEmpty) {
      return widget.subcategories;
    }
    return widget.subcategories
        .where((s) => s.categoryId == _selectedCategoryFilter)
        .toList();
  }

  List<TopicModel> get _filteredTopics {
    return widget.topics.where((t) {
      if (_selectedCategoryFilter != null && _selectedCategoryFilter!.isNotEmpty) {
        if (t.categoryId != null && t.categoryId != _selectedCategoryFilter) {
          return false;
        }
      }
      if (_selectedSubcategoryFilter != null && _selectedSubcategoryFilter!.isNotEmpty) {
        if (t.subcategoryId != _selectedSubcategoryFilter) return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        if (!t.name.toLowerCase().contains(q) &&
            !t.id.toLowerCase().contains(q) &&
            !t.slug.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  String _getSubcategoryName(String subcategoryId) {
    final sub = widget.subcategories.where((s) => s.id == subcategoryId).firstOrNull;
    return sub?.name ?? subcategoryId;
  }

  String _getCategoryName(String? categoryId, String subcategoryId) {
    if (categoryId != null && categoryId.isNotEmpty) {
      final cat = widget.categories.where((c) => c.id == categoryId).firstOrNull;
      if (cat != null) return cat.name;
    }
    final sub = widget.subcategories.where((s) => s.id == subcategoryId).firstOrNull;
    if (sub != null) {
      final cat = widget.categories.where((c) => c.id == sub.categoryId).firstOrNull;
      if (cat != null) return cat.name;
    }
    return 'General';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTopics;
    final isMobile = MediaQuery.of(context).size.width < 700;
    final availableSubs = _availableSubcategories;

    return AdminDataTableCard(
      title: 'Topics / Chapters',
      totalCount: widget.topics.length,
      icon: Icons.menu_book_rounded,
      iconBgColor: const Color(0xFF8B5CF6),
      searchQuery: _searchQuery,
      searchHint: 'Search topics...',
      onSearchChanged: (val) => setState(() => _searchQuery = val),
      itemLabel: 'topics',
      filterControls: [
        SizedBox(
          width: 210,
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
            onChanged: (val) {
              setState(() {
                _selectedCategoryFilter = val;
                _selectedSubcategoryFilter = null;
              });
            },
          ),
        ),
        SizedBox(
          width: 220,
          child: AppDropdown<String?>(
            value: _selectedSubcategoryFilter,
            hint: 'Filter by Subcategory',
            isDense: true,
            fillColor: const Color(0xFFF8FAFC),
            borderColor: const Color(0xFFE2E8F0),
            focusedBorderColor: AppColors.brandPurple,
            selectedItemColor: AppColors.brandPurple,
            selectedItemBackgroundColor: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(8),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            items: [
              const AppDropdownItem<String?>(value: null, label: 'All Subcategories (Level 3)'),
              ...availableSubs.map((s) => AppDropdownItem<String?>(
                value: s.id,
                label: s.name,
                leading: const Icon(Icons.account_tree_outlined, size: 16, color: Color(0xFF10B981)),
              )),
            ],
            onChanged: (val) => setState(() => _selectedSubcategoryFilter = val),
          ),
        ),
      ],
      headerActions: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Add Topic'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            elevation: 0,
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          onPressed: widget.onAddTopic,
        ),
      ],
      customBody: (isMobile && filtered.isNotEmpty)
          ? ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final topic = filtered[index];
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
                          color: const Color(0xFF8B5CF6).withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.menu_book_outlined, color: Color(0xFF8B5CF6), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101A3A),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${_getSubcategoryName(topic.subcategoryId)} • ${_getCategoryName(topic.categoryId, topic.subcategoryId)}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AdminTableActionButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit Topic',
                        onPressed: () => widget.onEditTopic(topic),
                      ),
                      const SizedBox(width: 4),
                      AdminTableActionButton(
                        icon: Icons.delete_outline_rounded,
                        tooltip: 'Delete Topic',
                        onPressed: () => widget.onDeleteTopic(topic),
                      ),
                    ],
                  ),
                );
              },
            )
          : null,
      columns: const [
        DataColumn(label: Text('TOPIC NAME', style: _colHeaderStyle)),
        DataColumn(label: Text('SUBCATEGORY (L3)', style: _colHeaderStyle)),
        DataColumn(label: Text('SUBJECT (L2)', style: _colHeaderStyle)),
        DataColumn(label: Text('ORDER', style: _colHeaderStyle)),
        DataColumn(label: Text('STATUS', style: _colHeaderStyle)),
        DataColumn(label: Text('ACTIONS', style: _colHeaderStyle)),
      ],
      rows: filtered.map((topic) {
        final subName = _getSubcategoryName(topic.subcategoryId);
        final catName = _getCategoryName(topic.categoryId, topic.subcategoryId);

        return DataRow(
          cells: [
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.menu_book_outlined, color: Color(0xFF8B5CF6), size: 16),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101A3A),
                        ),
                      ),
                      Text(
                        topic.id,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  subName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ),
            DataCell(
              Text(
                catName,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            DataCell(
              Text(
                '#${topic.displayOrder}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: topic.isActive
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  topic.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: topic.isActive
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF64748B),
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
                    tooltip: 'Edit Topic',
                    onPressed: () => widget.onEditTopic(topic),
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete Topic',
                    onPressed: () => widget.onDeleteTopic(topic),
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
            Text('No topics found for this filter', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
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
