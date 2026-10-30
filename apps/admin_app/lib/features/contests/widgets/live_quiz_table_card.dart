import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/live_quiz_item.dart';

/// Pixel-accurate Live Quiz Data Table Card matching the reference image.
class LiveQuizTableCard extends StatefulWidget {
  final List<LiveQuizItem> items;
  final int totalCount;
  final String selectedCategory;
  final String selectedStatus;
  final String searchQuery;
  final DateTimeRange? dateRange;
  final int currentPage;
  final int totalPages;
  final int rowsPerPage;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onRowsPerPageChanged;
  final Function(LiveQuizItem) onView;
  final Function(LiveQuizItem) onAnalytics;
  final Function(LiveQuizItem) onEdit;
  final Function(LiveQuizItem) onMore;
  final VoidCallback? onFiltersTap;

  const LiveQuizTableCard({
    super.key,
    required this.items,
    required this.totalCount,
    required this.selectedCategory,
    required this.selectedStatus,
    required this.searchQuery,
    this.dateRange,
    required this.currentPage,
    required this.totalPages,
    this.rowsPerPage = 10,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onSearchChanged,
    required this.onDateRangeChanged,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
    required this.onView,
    required this.onAnalytics,
    required this.onEdit,
    required this.onMore,
    this.onFiltersTap,
  });

  @override
  State<LiveQuizTableCard> createState() => _LiveQuizTableCardState();
}

class _LiveQuizTableCardState extends State<LiveQuizTableCard> {
  final Set<String> _selectedIds = {};
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant LiveQuizTableCard oldWidget) {
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Table Top Controls Bar (Search + Dropdowns + DatePicker + Filters Button)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Builder(
              builder: (context) {
                final isNarrow = MediaQuery.sizeOf(context).width < 1050;

                final titleWidget = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2587F8),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.podcasts_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Live Quiz List (${widget.totalCount})',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                );

                final controlsList = [
                  // Search Input Field
                  SizedBox(
                    width: 200,
                    height: 32,
                    child: TextField(
                      controller: _searchController,
                      onChanged: widget.onSearchChanged,
                      style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search live quiz by title, description...',
                        hintStyle: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
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

                  // Dropdown: All Status
                  _buildDropdown(
                    value: widget.selectedStatus,
                    items: const [
                      'All Status',
                      'Live Now',
                      'Completed',
                      'Scheduled',
                      'Ongoing',
                      'Draft',
                    ],
                    onChanged: widget.onStatusChanged,
                  ),
                  const SizedBox(width: 8),

                  // Dropdown: All Categories
                  _buildDropdown(
                    value: widget.selectedCategory,
                    items: const [
                      'All Categories',
                      'Railway',
                      'General Science',
                      'Mathematics',
                      'Current Affairs',
                      'Reasoning',
                      'Biology',
                      'Mixed',
                    ],
                    onChanged: widget.onCategoryChanged,
                  ),
                  const SizedBox(width: 8),

                  // Date Range Picker Button
                  _buildDateRangeButton(context),
                  const SizedBox(width: 8),

                  // Filters Button
                  _buildFiltersButton(context),
                ];

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleWidget,
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controlsList,
                      ),
                    ],
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      titleWidget,
                      const SizedBox(width: 16),
                      ...controlsList,
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),

          // 2. Data Table with Dynamic Stretch to fill card width
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth;
              // Expand details column to fill available card width proportionally
              final double detailsWidth = (cardWidth * 0.22).clamp(180.0, 360.0);

              // Fixed content widths:
              // Checkbox(24) + #(22) + Category(85) + StartTime(85) + Duration(65) + Participants(60) + Status(75) + CreatedBy(75) + Actions(110) + Margins(32) = 633
              const double fixedColumnsWidth = 24.0 + 22.0 + 85.0 + 85.0 + 65.0 + 60.0 + 75.0 + 75.0 + 110.0 + 32.0;
              final double totalNeededWidth = fixedColumnsWidth + detailsWidth;
              final double remainingSpace = cardWidth - totalNeededWidth;
              // Distribute remaining width across the 9 column gaps
              final double dynamicColumnSpacing = remainingSpace > 0 ? (remainingSpace / 9).clamp(6.0, 48.0) : 6.0;
              final double tableMinWidth = cardWidth >= 860.0 ? cardWidth : 860.0;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: tableMinWidth),
                  child: DataTable(
                    headingRowHeight: 40,
                    dataRowMinHeight: 56,
                    dataRowMaxHeight: 58,
                    horizontalMargin: 16,
                    columnSpacing: dynamicColumnSpacing,
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    showCheckboxColumn: false,
                    columns: [
                      // Checkbox
                      DataColumn(
                        label: SizedBox(
                          width: 22,
                          child: Checkbox(
                            value: allSelected,
                            onChanged: _toggleSelectAll,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            activeColor: const Color(0xFF5636F5),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                      // Row #
                      const DataColumn(
                        label: Text(
                          '#',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      // Quiz Details
                      DataColumn(
                        label: SizedBox(
                          width: detailsWidth,
                          child: const Text(
                            'Quiz Details',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      // Category
                      const DataColumn(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Category',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.arrow_drop_down, size: 14, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                      // Start Time
                      const DataColumn(
                        label: Text(
                          'Start Time',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      // Duration
                      const DataColumn(
                        label: Text(
                          'Duration',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      // Participants
                      const DataColumn(
                        label: Text(
                          'Participants',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      // Status
                      const DataColumn(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.arrow_drop_down, size: 14, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                      // Created By
                      const DataColumn(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Created By',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.arrow_drop_down, size: 14, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                      // Actions
                      const DataColumn(
                        label: Text(
                          'Actions',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                    rows: widget.items.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final item = entry.value;
                      final isSelected = _selectedIds.contains(item.id);

                      return DataRow(
                        selected: isSelected,
                        color: WidgetStateProperty.resolveWith<Color?>((states) {
                          if (states.contains(WidgetState.hovered)) {
                            return const Color(0xFFF8FAFC);
                          }
                          if (isSelected) {
                            return const Color(0xFFF5F3FF);
                          }
                          return Colors.white;
                        }),
                        cells: [
                          // Checkbox
                          DataCell(
                            SizedBox(
                              width: 22,
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (_) => _toggleItem(item.id),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                activeColor: const Color(0xFF5636F5),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          // #
                          DataCell(
                            Text(
                              '$idx',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          // Quiz Details (Thumbnail + Title + Subtitle, scaled to detailsWidth)
                          DataCell(
                            SizedBox(
                              width: detailsWidth,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildThumbnail(item),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontSize: 12,
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
                                            fontSize: 10,
                                            color: AppColors.textMuted,
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
                          // Category Badge
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: LiveQuizItem.getCategoryBgColor(item.category),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: LiveQuizItem.getCategoryBorderColor(item.category),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                item.category,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: LiveQuizItem.getCategoryTextColor(item.category),
                                ),
                              ),
                            ),
                          ),
                          // Start Time
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(item.startTime),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  _formatTime(item.startTime),
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Duration
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 13,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.durationMinutes} min',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Participants
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.people_alt_outlined,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatNumber(item.participantsCount),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Status Badge
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: item.statusBgColor,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: item.statusBorderColor, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.statusLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: item.statusTextColor,
                                    ),
                                  ),
                                  if (item.status == LiveQuizStatus.liveNow) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF3B30),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          // Created By
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF5636F5),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.person, color: Colors.white, size: 13),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.createdByName,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Actions (View, Analytics, Edit, More)
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildActionButton(
                                  icon: Icons.visibility_outlined,
                                  tooltip: 'View Quiz',
                                  onTap: () => widget.onView(item),
                                ),
                                const SizedBox(width: 4),
                                _buildActionButton(
                                  icon: Icons.bar_chart_rounded,
                                  tooltip: 'Analytics',
                                  onTap: () => widget.onAnalytics(item),
                                ),
                                const SizedBox(width: 4),
                                _buildActionButton(
                                  icon: Icons.edit_outlined,
                                  tooltip: 'Edit Quiz',
                                  onTap: () => widget.onEdit(item),
                                ),
                                const SizedBox(width: 4),
                                _buildActionButton(
                                  icon: Icons.more_vert_rounded,
                                  tooltip: 'More',
                                  onTap: () => widget.onMore(item),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),

          // 3. Table Pagination Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // "Showing 1 to 7 of 128 live quizzes"
                Text(
                  'Showing 1 to ${widget.items.length} of ${widget.totalCount} live quizzes',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),

                // Page numbers row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPageNavBtn(
                      icon: Icons.chevron_left_rounded,
                      isEnabled: widget.currentPage > 1,
                      onTap: () => widget.onPageChanged(widget.currentPage - 1),
                    ),
                    const SizedBox(width: 4),
                    _buildPageNumberBtn(1, isSelected: widget.currentPage == 1),
                    const SizedBox(width: 3),
                    _buildPageNumberBtn(2, isSelected: widget.currentPage == 2),
                    const SizedBox(width: 3),
                    _buildPageNumberBtn(3, isSelected: widget.currentPage == 3),
                    const SizedBox(width: 3),
                    _buildPageNumberBtn(4, isSelected: widget.currentPage == 4),
                    const SizedBox(width: 3),
                    _buildPageNumberBtn(5, isSelected: widget.currentPage == 5),
                    const SizedBox(width: 3),
                    const Text('...', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(width: 3),
                    _buildPageNumberBtn(widget.totalPages, isSelected: widget.currentPage == widget.totalPages),
                    const SizedBox(width: 4),
                    _buildPageNavBtn(
                      icon: Icons.chevron_right_rounded,
                      isEnabled: widget.currentPage < widget.totalPages,
                      onTap: () => widget.onPageChanged(widget.currentPage + 1),
                    ),
                  ],
                ),

                // "Show 10 ▾ per page"
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Show', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(width: 6),
                    Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: widget.rowsPerPage,
                          items: const [10, 20, 50].map((n) {
                            return DropdownMenuItem<int>(
                              value: n,
                              child: Text(
                                '$n',
                                style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) widget.onRowsPerPageChanged(val);
                          },
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('per page', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: AppRadii.borderSm,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          items: items.map((i) {
            return DropdownMenuItem<String>(
              value: i,
              child: Text(
                i,
                style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildDateRangeButton(BuildContext context) {
    final range = widget.dateRange;
    final label = range != null
        ? '${_formatMonthDay(range.start)} - ${_formatMonthDay(range.end)}'
        : 'Oct 1, 2026 - Oct 18, 2026';

    return InkWell(
      onTap: () async {
        final initial = widget.dateRange ??
            DateTimeRange(
              start: DateTime(2026, 10, 1),
              end: DateTime(2026, 10, 18),
            );
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2025),
          lastDate: DateTime(2028),
          initialDateRange: initial,
        );
        if (picked != null) {
          widget.onDateRangeChanged(picked);
        }
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: AppRadii.borderSm,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersButton(BuildContext context) {
    return InkWell(
      onTap: widget.onFiltersTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Filter options opened'),
                duration: Duration(seconds: 1),
              ),
            );
          },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: AppRadii.borderSm,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_rounded, size: 15, color: AppColors.textSecondary),
            SizedBox(width: 6),
            Text(
              'Filters',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(LiveQuizItem item) {
    final colors = _getThumbnailGradient(item.category);
    return Container(
      width: 42,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.podcasts_rounded,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  List<Color> _getThumbnailGradient(String category) {
    switch (category.toLowerCase().trim()) {
      case 'railway':
        return [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)];
      case 'general science':
      case 'science':
        return [const Color(0xFF831843), const Color(0xFFEC4899)];
      case 'mathematics':
      case 'maths':
        return [const Color(0xFFC2410C), const Color(0xFFFB923C)];
      case 'current affairs':
        return [const Color(0xFF1E293B), const Color(0xFF64748B)];
      case 'reasoning':
        return [const Color(0xFF431407), const Color(0xFFB45309)];
      case 'biology':
        return [const Color(0xFF064E3B), const Color(0xFF10B981)];
      case 'mixed':
      default:
        return [const Color(0xFF1E1B4B), const Color(0xFF6366F1)];
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 14, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildPageNumberBtn(int page, {required bool isSelected}) {
    return InkWell(
      onTap: () => widget.onPageChanged(page),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5636F5) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPageNavBtn({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 15,
          color: isEnabled ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  static String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final period = local.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = local.minute.toString().padLeft(2, '0');
    final hourStr = hour.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $period';
  }

  static String _formatMonthDay(DateTime dt) {
    final local = dt.toLocal();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
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
}
