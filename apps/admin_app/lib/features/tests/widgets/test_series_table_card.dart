import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/test_series_item.dart';

/// Test Series Table Card
/// Pixel-accurate data table matching the reference image.
class TestSeriesTableCard extends StatefulWidget {
  final List<TestSeriesItem> items;
  final int totalCount;
  final String selectedSubject;
  final String selectedStatus;
  final String searchQuery;
  final int currentPage;
  final int totalPages;
  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int> onPageChanged;
  final Function(TestSeriesItem) onView;
  final Function(TestSeriesItem) onAnalytics;
  final Function(TestSeriesItem) onEdit;
  final Function(TestSeriesItem) onDelete;
  final Function(TestSeriesItem) onToggleStatus;
  final Function(TestSeriesItem)? onAddQuestion;
  final Function(TestSeriesItem)? onViewQuestions;

  const TestSeriesTableCard({
    super.key,
    required this.items,
    required this.totalCount,
    required this.selectedSubject,
    required this.selectedStatus,
    required this.searchQuery,
    required this.currentPage,
    required this.totalPages,
    required this.onSubjectChanged,
    required this.onStatusChanged,
    required this.onSearchChanged,
    required this.onPageChanged,
    required this.onView,
    required this.onAnalytics,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
    this.onAddQuestion,
    this.onViewQuestions,
  });

  @override
  State<TestSeriesTableCard> createState() => _TestSeriesTableCardState();
}

class _TestSeriesTableCardState extends State<TestSeriesTableCard> {
  final Set<String> _selectedIds = {};
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant TestSeriesTableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelectAll(bool? val) {
    setState(() {
      if (val == true) {
        _selectedIds.addAll(widget.items.map((i) => i.id));
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _toggleItem(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allSelected = widget.items.isNotEmpty &&
        widget.items.every((i) => _selectedIds.contains(i.id));

    return Container(
      constraints: const BoxConstraints(minHeight: 520),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Table Top Controls Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Builder(
              builder: (context) {
                final isNarrow = MediaQuery.sizeOf(context).width < 900;
                final controlsList = [
                  // Dropdown 1: All Subjects
                  _buildDropdown(
                    value: widget.selectedSubject,
                    items: const [
                      'All Subjects',
                      'General Science',
                      'Mathematics',
                      'Reasoning',
                      'Current Affairs',
                      'Chemistry',
                      'Biology',
                      'Mixed',
                    ],
                    onChanged: widget.onSubjectChanged,
                  ),
                  const SizedBox(width: 8),

                  // Dropdown 2: All Status
                  _buildDropdown(
                    value: widget.selectedStatus,
                    items: const [
                      'All Status',
                      'Published',
                      'Draft',
                      'Archived',
                    ],
                    onChanged: widget.onStatusChanged,
                  ),
                  const SizedBox(width: 8),

                  // Search Input Field
                  SizedBox(
                    width: 170,
                    height: 32,
                    child: TextField(
                      controller: _searchController,
                      onChanged: widget.onSearchChanged,
                      style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search test series...',
                        hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 15,
                          color: AppColors.textMuted,
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 28),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                        border: OutlineInputBorder(
                          borderRadius: AppRadii.borderSm,
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadii.borderSm,
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadii.borderSm,
                          borderSide: const BorderSide(color: Color(0xFF5636F5), width: 1.2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Filters Button
                  _buildFiltersButton(context),
                ];

                final titleRow = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.format_list_bulleted_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Test Series List (${widget.totalCount})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleRow,
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: controlsList,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    titleRow,
                    const Spacer(),
                    ...controlsList,
                  ],
                );
              },
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 2. Data Table with Dynamic Stretch to fill card width
          Builder(
            builder: (context) {
              final screenWidth = MediaQuery.sizeOf(context).width;
              final isDesktop = screenWidth >= 1024;
              final availableWidth = isDesktop
                  ? math.max(650.0, screenWidth - 48 - 16 - 295 - 2)
                  : math.max(650.0, screenWidth - 48);

              final double detailsWidth = (availableWidth * 0.22).clamp(180.0, 360.0);
              // Base content widths of all other columns + margins:
              // Checkbox(24) + #(22) + Subject(85) + Tests(60) + Questions(75) + Price(55) + Enrollments(75) + Status(75) + Created(80) + Actions(110) + Margins(32) = 638
              const double fixedColumnsWidth = 24.0 + 22.0 + 85.0 + 60.0 + 75.0 + 55.0 + 75.0 + 75.0 + 80.0 + 110.0 + 32.0;
              final double totalNeededWidth = fixedColumnsWidth + detailsWidth;
              final double remainingSpace = availableWidth - totalNeededWidth;
              // Distribute remaining width across the 10 column gaps
              final double dynamicColumnSpacing = remainingSpace > 0 ? (remainingSpace / 10).clamp(6.0, 48.0) : 6.0;
              final double tableMinWidth = availableWidth >= 860.0 ? availableWidth : 860.0;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: tableMinWidth),
                  child: DataTable(
                    showCheckboxColumn: false,
                    headingRowHeight: 40,
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 52,
                    horizontalMargin: 16,
                    columnSpacing: dynamicColumnSpacing,
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columns: [
                      // 1. Select All Checkbox
                      DataColumn(
                        label: SizedBox(
                          width: 20,
                          child: Transform.scale(
                            scale: 0.85,
                            child: Checkbox(
                              value: allSelected,
                              onChanged: _toggleSelectAll,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              activeColor: const Color(0xFF5636F5),
                            ),
                          ),
                        ),
                      ),
                      // 2. # Index
                      const DataColumn(
                        label: Text('#', style: _headerStyle),
                      ),
                      // 3. Test Series Details
                      DataColumn(
                        label: SizedBox(
                          width: detailsWidth,
                          child: const Text('Test Series Details', style: _headerStyle),
                        ),
                      ),
                      // 4. Subject
                      const DataColumn(
                        label: Text('• Subject', style: _headerStyle),
                      ),
                      // 5. Total Tests
                      const DataColumn(
                        label: Text('Total Tests', style: _headerStyle),
                      ),
                      // 6. Total Questions
                      const DataColumn(
                        label: Text('Total Questions', style: _headerStyle),
                      ),
                      // 7. Price
                      const DataColumn(
                        label: Text('Price', style: _headerStyle),
                      ),
                      // 8. Enrollments
                      const DataColumn(
                        label: Text('• Enrollments', style: _headerStyle),
                      ),
                      // 9. Status
                      const DataColumn(
                        label: Text('• Status', style: _headerStyle),
                      ),
                      // 10. Created On
                      const DataColumn(
                        label: Text('Created On', style: _headerStyle),
                      ),
                      // 11. Actions
                      const DataColumn(
                        label: Text('Actions', style: _headerStyle),
                      ),
                    ],
                    rows: List.generate(widget.items.length, (index) {
                      final item = widget.items[index];
                      final isSelected = _selectedIds.contains(item.id);

                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (_) => _toggleItem(item.id),
                        color: WidgetStateProperty.resolveWith<Color?>((states) {
                          if (states.contains(WidgetState.hovered)) {
                            return const Color(0xFFF8FAFC);
                          }
                          if (isSelected) {
                            return const Color(0xFFEEF2FF);
                          }
                          return Colors.white;
                        }),
                        cells: [
                          // Checkbox
                          DataCell(
                            SizedBox(
                              width: 20,
                              child: Transform.scale(
                                scale: 0.85,
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => _toggleItem(item.id),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  activeColor: const Color(0xFF5636F5),
                                ),
                              ),
                            ),
                          ),
                          // Index
                          DataCell(
                            Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          // Details (Icon + Title + Subtitle matching Dashboard Recent Quizzes)
                          DataCell(
                            SizedBox(
                              width: detailsWidth,
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: item.iconColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(item.icon, color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.description,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w400,
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
                          ),
                          // Subject Badge
                          DataCell(_buildSubjectBadge(item.subject)),
                          // Total Tests
                          DataCell(
                            Text(
                              '${item.totalTests}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // Total Questions
                          DataCell(
                            InkWell(
                              onTap: widget.onViewQuestions != null ? () => widget.onViewQuestions!(item) : null,
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatNumber(item.totalQuestions),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: widget.onViewQuestions != null ? const Color(0xFF5636F5) : AppColors.textPrimary,
                                        decoration: widget.onViewQuestions != null ? TextDecoration.underline : null,
                                        decorationColor: const Color(0xFF5636F5).withValues(alpha: 0.35),
                                      ),
                                    ),
                                    if (widget.onViewQuestions != null) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.open_in_new_rounded, size: 12, color: Color(0xFF5636F5)),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Price
                          DataCell(
                            Text(
                              '₹${item.priceInr}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // Enrollments
                          DataCell(
                            Text(
                              _formatNumber(item.enrollments),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // Status Badge
                          DataCell(_buildStatusBadge(item.status)),
                          // Created On
                          DataCell(
                            Text(
                              _formatDate(item.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          // Actions (View, Analytics, Edit, View Questions, Add Questions, More)
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 16),
                                  color: AppColors.textSecondary,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                  tooltip: 'View Details',
                                  onPressed: () => widget.onView(item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.bar_chart_rounded, size: 16),
                                  color: AppColors.textSecondary,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                  tooltip: 'Analytics',
                                  onPressed: () => widget.onAnalytics(item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 16),
                                  color: AppColors.textSecondary,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                  tooltip: 'Edit Series',
                                  onPressed: () => widget.onEdit(item),
                                ),
                                if (widget.onViewQuestions != null)
                                  IconButton(
                                    icon: const Icon(Icons.format_list_bulleted_rounded, size: 16),
                                    color: const Color(0xFF0084FF),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                    tooltip: 'View Questions',
                                    onPressed: () => widget.onViewQuestions!(item),
                                  ),
                                if (widget.onAddQuestion != null)
                                  IconButton(
                                    icon: const Icon(Icons.post_add_rounded, size: 16),
                                    color: const Color(0xFF5636F5),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                    tooltip: 'Add Questions',
                                    onPressed: () => widget.onAddQuestion!(item),
                                  ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textSecondary),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                  onSelected: (val) {
                                    if (val == 'view_questions') {
                                      widget.onViewQuestions?.call(item);
                                    } else if (val == 'add_question') {
                                      widget.onAddQuestion?.call(item);
                                    } else if (val == 'toggle_status') {
                                      widget.onToggleStatus(item);
                                    } else if (val == 'delete') {
                                      widget.onDelete(item);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    if (widget.onViewQuestions != null)
                                      const PopupMenuItem(
                                        value: 'view_questions',
                                        child: Row(
                                          children: [
                                            Icon(Icons.format_list_bulleted_rounded, size: 14, color: Color(0xFF0084FF)),
                                            SizedBox(width: 8),
                                            Text(
                                              'View Questions',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0084FF)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const PopupMenuItem(
                                      value: 'add_question',
                                      child: Row(
                                        children: [
                                          Icon(Icons.post_add_rounded, size: 14, color: Color(0xFF5636F5)),
                                          SizedBox(width: 8),
                                          Text(
                                            'Add Questions',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5636F5)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'toggle_status',
                                      child: Text(
                                        item.status == TestSeriesStatus.published
                                            ? 'Move to Draft'
                                            : 'Publish Now',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(fontSize: 12, color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              );
            },
          ),

          if (widget.items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.layers_clear_rounded, size: 22, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No Test Series Found',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create a new test series or import one to get started.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 3. Table Footer: Showing text + Pagination
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  'Showing 1 to ${widget.items.length} of ${widget.totalCount} test series',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Previous Chevron
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, size: 18),
                        color: widget.currentPage > 1 ? const Color(0xFF101A3A) : const Color(0xFFCBD5E1),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: widget.currentPage > 1
                            ? () => widget.onPageChanged(widget.currentPage - 1)
                            : null,
                      ),
                      const SizedBox(width: 4),

                      // Page Pills 1 to 6
                      for (int p = 1; p <= widget.totalPages; p++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () => widget.onPageChanged(p),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: widget.currentPage == p
                                    ? const Color(0xFF5636F5)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$p',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: widget.currentPage == p
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),

                      // Next Chevron
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, size: 18),
                        color: widget.currentPage < widget.totalPages ? const Color(0xFF101A3A) : const Color(0xFFCBD5E1),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: widget.currentPage < widget.totalPages
                            ? () => widget.onPageChanged(widget.currentPage + 1)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Filter drawer opened with advanced criteria.'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_alt_outlined, size: 14, color: Color(0xFF64748B)),
            SizedBox(width: 4),
            Text(
              'Filters',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          items: items.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Text(s),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  Widget _buildSubjectBadge(String subject) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);

    final lower = subject.toLowerCase();
    if (lower.contains('science')) {
      bg = const Color(0xFFEEF2FF);
      text = const Color(0xFF6366F1);
    } else if (lower.contains('math')) {
      bg = const Color(0xFFFFF1F2);
      text = const Color(0xFFF43F5E);
    } else if (lower.contains('reasoning')) {
      bg = const Color(0xFFF0F9FF);
      text = const Color(0xFF0284C7);
    } else if (lower.contains('current') || lower.contains('affairs')) {
      bg = const Color(0xFFFFF7ED);
      text = const Color(0xFFEA580C);
    } else if (lower.contains('chemistry')) {
      bg = const Color(0xFFFDF2F8);
      text = const Color(0xFFDB2777);
    } else if (lower.contains('biology')) {
      bg = const Color(0xFFF0FDF4);
      text = const Color(0xFF16A34A);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        subject,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: text),
      ),
    );
  }

  Widget _buildStatusBadge(TestSeriesStatus status) {
    final isPublished = status == TestSeriesStatus.published;
    final bg = isPublished ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF);
    final text = isPublished ? const Color(0xFF16A34A) : const Color(0xFF3B82F6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: text),
      ),
    );
  }

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

  static String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[dt.month - 1];
    final d = dt.day.toString().padLeft(2, '0');
    return '$m $d, ${dt.year}';
  }

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );
}

