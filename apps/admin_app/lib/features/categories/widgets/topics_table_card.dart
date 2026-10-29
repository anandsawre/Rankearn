import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import '../models/category_item.dart';

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
                      color: const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Topics / Chapters (Level 4)',
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
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.topics.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Topic'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5636F5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 0,
                ),
                onPressed: widget.onAddTopic,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filters Row: Parent Subject + Parent Subcategory + Search Input
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 210,
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
                  onChanged: (val) {
                    setState(() {
                      _selectedCategoryFilter = val;
                      _selectedSubcategoryFilter = null; // reset child filter
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
                  focusedBorderColor: const Color(0xFF5636F5),
                  selectedItemColor: const Color(0xFF5636F5),
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
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF101A3A)),
                  decoration: InputDecoration(
                    hintText: 'Search topics...',
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

          // Topics Table / List
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 40, color: Color(0xFFCBD5E1)),
                  SizedBox(height: 8),
                  Text('No topics found for this filter', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
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
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF5636F5)),
                        onPressed: () => widget.onEditTopic(topic),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                        onPressed: () => widget.onDeleteTopic(topic),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.5), // Topic Name & Slug
                  1: FlexColumnWidth(2.0), // Subcategory (Level 3)
                  2: FlexColumnWidth(1.8), // Subject (Level 2)
                  3: FlexColumnWidth(0.8), // Order
                  4: FlexColumnWidth(1.0), // Status
                  5: FixedColumnWidth(90), // Actions
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                    children: [
                      _th('TOPIC NAME'),
                      _th('SUBCATEGORY (L3)'),
                      _th('SUBJECT (L2)'),
                      _th('ORDER'),
                      _th('STATUS'),
                      _th('ACTIONS', align: TextAlign.right),
                    ],
                  ),
                  ...filtered.map((topic) {
                    final subName = _getSubcategoryName(topic.subcategoryId);
                    final catName = _getCategoryName(topic.categoryId, topic.subcategoryId);

                    return TableRow(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Row(
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
                              Expanded(
                                child: Column(
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
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Container(
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Text(
                            catName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Text(
                            '#${topic.displayOrder}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Container(
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () => widget.onEditTopic(topic),
                                borderRadius: BorderRadius.circular(6),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.edit_outlined, size: 17, color: Color(0xFF5636F5)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => widget.onDeleteTopic(topic),
                                borderRadius: BorderRadius.circular(6),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.delete_outline_rounded, size: 17, color: Color(0xFFEF4444)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _th(String title, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        title,
        textAlign: align,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

