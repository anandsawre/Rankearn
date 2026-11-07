import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/category_item.dart';

/// Categories (Subjects) Table Card powered by unified [AdminDataTableCard].
class CategoriesTableCard extends StatefulWidget {
  final List<CategoryItem> items;
  final int totalCount;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String sortOption;
  final ValueChanged<String> onSortChanged;
  final String statusFilter;
  final ValueChanged<String> onStatusFilterChanged;
  final int currentPage;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;
  final ValueChanged<CategoryItem> onView;
  final ValueChanged<CategoryItem> onEdit;
  final ValueChanged<CategoryItem> onDuplicate;
  final ValueChanged<CategoryItem> onDelete;
  final ValueChanged<CategoryItem> onToggleStatus;

  const CategoriesTableCard({
    super.key,
    required this.items,
    required this.totalCount,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.sortOption,
    required this.onSortChanged,
    required this.statusFilter,
    required this.onStatusFilterChanged,
    required this.currentPage,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    required this.onView,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  State<CategoriesTableCard> createState() => _CategoriesTableCardState();
}

class _CategoriesTableCardState extends State<CategoriesTableCard> {
  bool _isGridView = false;

  void _toggleSelectAll(bool? selectAll) {
    if (selectAll == true) {
      final allOnPage = widget.items.map((e) => e.id).toSet();
      widget.onSelectionChanged({...widget.selectedIds, ...allOnPage});
    } else {
      final currentOnPage = widget.items.map((e) => e.id).toSet();
      widget.onSelectionChanged(
        widget.selectedIds.where((id) => !currentOnPage.contains(id)).toSet(),
      );
    }
  }

  void _openFilterDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) {
        return AppModalDialog(
          title: 'Filter by Status',
          subtitle: 'Select status filter to narrow down subjects',
          iconData: Icons.filter_list_rounded,
          gradientColors: const [Color(0xFF5636F5), Color(0xFF2587F8)],
          maxWidth: 420,
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('All Statuses', 'all', ctx),
              _buildFilterOption('Active Only', 'active', ctx),
              _buildFilterOption('Draft Only', 'draft', ctx),
              _buildFilterOption('Archived Only', 'archived', ctx),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String title, String val, BuildContext ctx) {
    final isSelected = widget.statusFilter == val;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFF5636F5) : const Color(0xFFCBD5E1),
          width: isSelected ? 1.4 : 1,
        ),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF5636F5) : const Color(0xFF1E293B),
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: isSelected ? const Color(0xFF5636F5) : const Color(0xFF94A3B8),
          size: 18,
        ),
        onTap: () {
          widget.onStatusFilterChanged(val);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allSelected = widget.items.isNotEmpty &&
        widget.items.every((item) => widget.selectedIds.contains(item.id));
    final hasActiveFilter = widget.statusFilter != 'all';
    final totalPages = math.max(1, (widget.totalCount / widget.pageSize).ceil());

    return AdminDataTableCard(
      title: 'Subjects List',
      totalCount: widget.totalCount,
      icon: Icons.folder_rounded,
      iconBgColor: const Color(0xFF0084FF),
      searchQuery: widget.searchQuery,
      searchHint: 'Search categories...',
      onSearchChanged: widget.onSearchChanged,
      currentPage: widget.currentPage,
      totalPages: totalPages,
      rowsPerPage: widget.pageSize,
      onPageChanged: widget.onPageChanged,
      onRowsPerPageChanged: widget.onPageSizeChanged,
      itemLabel: 'subjects',
      customBody: _isGridView ? _buildGridView() : null,
      filterControls: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sort by', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
            const SizedBox(width: 6),
            _buildSortDropdown(),
          ],
        ),
        _buildViewToggles(),
        _buildFilterButton(hasActiveFilter),
      ],
      columns: [
        DataColumn(
          label: SizedBox(
            width: 20,
            child: Checkbox(
              value: allSelected,
              activeColor: AppColors.brandPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: _toggleSelectAll,
            ),
          ),
        ),
        const DataColumn(label: Text('#', style: _headerStyle)),
        const DataColumn(label: Text('Target Exam', style: _headerStyle)),
        const DataColumn(label: Text('Subject Details', style: _headerStyle)),
        const DataColumn(label: Text('Chapters', style: _headerStyle)),
        const DataColumn(label: Text('Total Tests', style: _headerStyle)),
        const DataColumn(label: Text('Questions', style: _headerStyle)),
        const DataColumn(label: Text('Status', style: _headerStyle)),
        const DataColumn(label: Text('Created On', style: _headerStyle)),
        const DataColumn(label: Text('Actions', style: _headerStyle)),
      ],
      rows: widget.items.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final isSelected = widget.selectedIds.contains(item.id);

        return DataRow(
          selected: isSelected,
          cells: [
            // 1. Checkbox
            DataCell(
              SizedBox(
                width: 20,
                child: Checkbox(
                  value: isSelected,
                  activeColor: AppColors.brandPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (val) {
                    final next = Set<String>.from(widget.selectedIds);
                    if (val == true) {
                      next.add(item.id);
                    } else {
                      next.remove(item.id);
                    }
                    widget.onSelectionChanged(next);
                  },
                ),
              ),
            ),
            // 2. Row #
            DataCell(
              Text(
                '${(widget.currentPage - 1) * widget.pageSize + idx + 1}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
            ),
            // 3. Target Exam Badge
            DataCell(
              _buildExamBadge(item.examCategoryId),
            ),
            // 4. Subject Details
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: item.parsedColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(item.iconData, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101A3A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 5. Chapters Pill Badge
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${item.subcategoriesCount} Chapters',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ),
            // 6. Total Tests
            DataCell(
              Text(
                '${item.totalTests}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
            ),
            // 7. Questions
            DataCell(
              Text(
                _formatNumber(item.totalQuestions),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
            ),
            // 8. Status Badge
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.status.bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status.label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: item.status.color,
                  ),
                ),
              ),
            ),
            // 9. Created On
            DataCell(
              Text(
                _formatDate(item.createdAt),
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
              ),
            ),
            // 10. Actions
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminTableActionButton(
                    icon: Icons.remove_red_eye_outlined,
                    tooltip: 'View Category',
                    onPressed: () => widget.onView(item),
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit Category',
                    onPressed: () => widget.onEdit(item),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 16, color: Color(0xFF64748B)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onSelected: (val) {
                      if (val == 'duplicate') widget.onDuplicate(item);
                      if (val == 'toggle_status') widget.onToggleStatus(item);
                      if (val == 'delete') widget.onDelete(item);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.content_copy_rounded, size: 15, color: Color(0xFF64748B)),
                            SizedBox(width: 8),
                            Text('Duplicate Category', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle_status',
                        child: Row(
                          children: [
                            Icon(Icons.sync_rounded, size: 15, color: Color(0xFF64748B)),
                            SizedBox(width: 8),
                            Text(
                              item.status == CategoryStatus.active ? 'Move to Draft' : 'Make Active',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 15, color: Color(0xFFF43F5E)),
                            SizedBox(width: 8),
                            Text('Delete Category', style: TextStyle(fontSize: 12, color: Color(0xFFF43F5E))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
      emptyState: Container(
        height: 240,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_off_outlined, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 8),
            const Text('No categories found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
            const SizedBox(height: 4),
            Text(
              widget.searchQuery.isNotEmpty ? 'Try adjusting your search or filters.' : 'Click "Add Category" above to create one.',
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(bool hasActiveFilter) {
    return InkWell(
      onTap: _openFilterDialog,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: hasActiveFilter ? AppColors.brandPurple.withAlpha(15) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasActiveFilter ? AppColors.brandPurple : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_alt_outlined,
              size: 15,
              color: hasActiveFilter ? AppColors.brandPurple : const Color(0xFF475569),
            ),
            const SizedBox(width: 5),
            Text(
              'Filters',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasActiveFilter ? AppColors.brandPurple : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return AdminTableDropdown<String>(
      value: widget.sortOption,
      items: const [
        'latest',
        'oldest',
        'name_asc',
        'name_desc',
        'tests_desc',
        'questions_desc',
      ],
      itemLabel: (val) {
        switch (val) {
          case 'latest':
            return 'Latest First';
          case 'oldest':
            return 'Oldest First';
          case 'name_asc':
            return 'Name (A-Z)';
          case 'name_desc':
            return 'Name (Z-A)';
          case 'tests_desc':
            return 'Most Tests';
          case 'questions_desc':
            return 'Most Questions';
          default:
            return val;
        }
      },
      height: 36,
      onChanged: widget.onSortChanged,
    );
  }

  Widget _buildViewToggles() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleBtn(
            icon: Icons.list_rounded,
            isActive: !_isGridView,
            onTap: () => setState(() => _isGridView = false),
          ),
          _buildToggleBtn(
            icon: Icons.grid_view_rounded,
            isActive: _isGridView,
            onTap: () => setState(() => _isGridView = true),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isActive ? AppColors.brandPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: isActive ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildExamBadge(String? examId) {
    if (examId == null || examId.isEmpty || examId == 'general' || examId == 'all') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          '🌐 All Exams',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      );
    }

    final id = examId.toLowerCase();
    String label;
    Color bg;
    Color textColor;

    if (id.contains('bpsc')) {
      label = '🏛️ 70th BPSC';
      bg = const Color(0xFFEEF2FF);
      textColor = const Color(0xFF5636F5);
    } else if (id.contains('ssc')) {
      label = '📋 SSC CGL';
      bg = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF2563EB);
    } else if (id.contains('railway')) {
      label = '🚆 Railway ALP';
      bg = const Color(0xFFECFDF5);
      textColor = const Color(0xFF059669);
    } else if (id.contains('upsc')) {
      label = '🇮🇳 UPSC CSE';
      bg = const Color(0xFFFFFBEB);
      textColor = const Color(0xFFD97706);
    } else if (id.contains('banking')) {
      label = '🏦 Banking';
      bg = const Color(0xFFFFF1F2);
      textColor = const Color(0xFFE11D48);
    } else {
      label = '🎯 ${examId.toUpperCase()}';
      bg = const Color(0xFFF3E8FF);
      textColor = const Color(0xFF7C3AED);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildGridView() {
    if (widget.items.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No categories found', style: TextStyle(color: Color(0xFF94A3B8))),
        ),
      );
    }

    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final crossAxisCount = screenWidth > 1350
            ? 3
            : (screenWidth > 850 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.1,
          ),
          itemCount: widget.items.length,
          itemBuilder: (context, idx) {
            final item = widget.items[idx];
            final isSelected = widget.selectedIds.contains(item.id);

            return InkWell(
              onTap: () => widget.onView(item),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF4F7FF) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.brandPurple : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: item.parsedColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Icon(item.iconData, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.description,
                                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.status.bgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.status.label,
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: item.status.color),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.subcategoriesCount} Chapters', style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.w700)),
                        Text('${item.totalTests} Tests • ${_formatNumber(item.totalQuestions)} Qs', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: Color(0xFF64748B),
    letterSpacing: 0.1,
  );

  static String _formatNumber(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final len = s.length;
      final part1 = s.substring(0, len - 3);
      final part2 = s.substring(len - 3);
      return '$part1,$part2';
    }
    return n.toString();
  }

  static String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }
}
