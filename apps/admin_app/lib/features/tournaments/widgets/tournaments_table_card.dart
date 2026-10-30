import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/tournament_item.dart';

class TournamentsTableCard extends StatefulWidget {
  final List<TournamentItem> items;
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
  final ValueChanged<TournamentItem> onView;
  final ValueChanged<TournamentItem> onAnalytics;
  final ValueChanged<TournamentItem> onEdit;
  final void Function(TournamentItem, TapDownDetails)? onMore;
  final ValueChanged<List<String>>? onBulkDelete;
  final ValueChanged<List<String>>? onBulkArchive;

  const TournamentsTableCard({
    super.key,
    required this.items,
    required this.totalCount,
    required this.selectedCategory,
    required this.selectedStatus,
    required this.searchQuery,
    this.dateRange,
    required this.currentPage,
    required this.totalPages,
    required this.rowsPerPage,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onSearchChanged,
    required this.onDateRangeChanged,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
    required this.onView,
    required this.onAnalytics,
    required this.onEdit,
    this.onMore,
    this.onBulkDelete,
    this.onBulkArchive,
  });

  @override
  State<TournamentsTableCard> createState() => _TournamentsTableCardState();
}

class _TournamentsTableCardState extends State<TournamentsTableCard> {
  final Set<String> _selectedIds = {};
  late TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();

  final List<String> _categories = [
    'All Categories',
    'Railway',
    'General Science',
    'Mathematics',
    'Current Affairs',
    'State Level',
    'Reasoning',
    'Biology',
  ];

  final List<String> _statuses = [
    'All Status',
    'Upcoming',
    'Ongoing',
    'Completed',
    'Archived',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant TournamentsTableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isAllSelected =>
      widget.items.isNotEmpty && _selectedIds.length == widget.items.length;

  void _toggleSelectAll() {
    setState(() {
      if (_isAllSelected) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(widget.items.map((e) => e.id));
      }
    });
  }

  void _toggleRow(String id) {
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Toolbar
          _buildToolbar(context),
          const SizedBox(height: 14),

          // 1.5 Bulk Actions Bar if items are selected
          if (_selectedIds.isNotEmpty) ...[
            _buildBulkActionBar(),
            const SizedBox(height: 10),
          ],

          // 2. Responsive Table
          _buildTable(),
          const SizedBox(height: 14),

          // 3. Footer Pagination
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 1200;

    final headerTitle = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFF5636F5),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.emoji_events_rounded,
            color: Colors.white,
            size: 15,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Tournaments List (${widget.totalCount})',
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );

    final controls = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Search Input Field
        SizedBox(
          width: isCompact ? 180 : 230,
          height: 34,
          child: TextField(
            controller: _searchController,
            onChanged: widget.onSearchChanged,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search tournaments by title, description...',
              hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded, size: 16, color: AppColors.textMuted),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF5636F5), width: 1.2),
              ),
            ),
          ),
        ),

        // Status Filter Dropdown
        AppDropdownFilter<String>(
          value: widget.selectedStatus,
          items: _statuses,
          onChanged: (val) {
            if (val != null) widget.onStatusChanged(val);
          },
        ),

        // Category Filter Dropdown
        AppDropdownFilter<String>(
          value: widget.selectedCategory,
          items: _categories,
          onChanged: (val) {
            if (val != null) widget.onCategoryChanged(val);
          },
        ),

        // Date Range Filter Button
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 2),
              initialDateRange: widget.dateRange ??
                  DateTimeRange(
                    start: DateTime(2026, 10, 1),
                    end: DateTime(2026, 10, 31),
                  ),
            );
            if (picked != null) {
              widget.onDateRangeChanged(picked);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  widget.dateRange != null
                      ? '${_formatShortDate(widget.dateRange!.start)} - ${_formatShortDate(widget.dateRange!.end)}'
                      : 'Oct 1, 2026 - Oct 31, 2026',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        ),

        // Filters Button
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: 13, color: AppColors.textSecondary),
                SizedBox(width: 5),
                Text(
                  'Filters',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerTitle,
          const SizedBox(height: 10),
          controls,
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          headerTitle,
          const SizedBox(width: 16),
          controls,
        ],
      ),
    );
  }

  Widget _buildBulkActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedIds.length} tournament(s) selected',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4338CA),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              widget.onBulkArchive?.call(_selectedIds.toList());
              setState(() => _selectedIds.clear());
            },
            icon: const Icon(Icons.archive_outlined, size: 14, color: Color(0xFF4338CA)),
            label: const Text('Archive Selected', style: TextStyle(fontSize: 11.5, color: Color(0xFF4338CA))),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              widget.onBulkDelete?.call(_selectedIds.toList());
              setState(() => _selectedIds.clear());
            },
            icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFDC2626)),
            label: const Text('Delete Selected', style: TextStyle(fontSize: 11.5, color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    if (widget.items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events_outlined, size: 28, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Tournaments Found',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try adjusting your search terms or filter criteria.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        // Sum of fixed columns + margins:
        // Checkbox(24) + #(20) + Category(82) + StartDate(85) + EndDate(85) + EntryFee(82) + Participants(60) + Status(78) + PrizePool(82) + Actions(108) + horizontalMargin(16) = 722
        const double fixedColumnsWidth = 24.0 + 20.0 + 82.0 + 85.0 + 85.0 + 82.0 + 60.0 + 78.0 + 82.0 + 108.0 + 16.0;
        final double detailsWidth = (cardWidth * 0.22).clamp(180.0, 360.0);
        final double totalNeededWidth = fixedColumnsWidth + detailsWidth;
        final double remainingSpace = cardWidth - totalNeededWidth;
        final double dynamicColumnSpacing = remainingSpace > 0 ? (remainingSpace / 10).clamp(6.0, 40.0) : 6.0;
        final double tableMinWidth = cardWidth >= 880.0 ? cardWidth : 880.0;

        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: tableMinWidth),
            child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 38,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 52,
                horizontalMargin: 8,
                columnSpacing: dynamicColumnSpacing,
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                border: const TableBorder(
                  horizontalInside: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                ),
                columns: [
                  // 1. Checkbox
                  DataColumn(
                    label: SizedBox(
                      width: 24,
                      child: Checkbox(
                        value: _isAllSelected,
                        onChanged: (val) => _toggleSelectAll(),
                        activeColor: const Color(0xFF5636F5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),

                  // 2. #
                  const DataColumn(
                    label: Text(
                      '#',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),

                  // 3. Tournament Details
                  DataColumn(
                    label: SizedBox(
                      width: detailsWidth,
                      child: const Text(
                        'Tournament Details',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                    ),
                  ),

                  // 4. Category
                  const DataColumn(
                    label: Text(
                      'Category',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),

                  // 5. Start Date
                  const DataColumn(
                    label: Text(
                      'Start Date',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),

                  // 6. End Date
                  const DataColumn(
                    label: Text(
                      'End Date',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),

                  // 7. Entry Fee
                  const DataColumn(
                    label: Text(
                      'Entry Fee',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),

                  // 8. Participants
                  const DataColumn(
                    label: Text(
                      'Participants',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),

                  // 9. Status
                  const DataColumn(
                    label: Text(
                      'Status',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),

                  // 10. Prize Pool
                  const DataColumn(
                    label: Text(
                      'Prize Pool',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),

                  // 11. Actions
                  const DataColumn(
                    label: Text(
                      'Actions',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),
                ],
                rows: widget.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isChecked = _selectedIds.contains(item.id);
                  final rowNumber = (widget.currentPage - 1) * widget.rowsPerPage + index + 1;

                  return DataRow(
                    selected: isChecked,
                    onSelectChanged: (selected) {
                      _toggleRow(item.id);
                    },
                    cells: [
                      // 1. Checkbox
                      DataCell(
                        SizedBox(
                          width: 24,
                          child: Checkbox(
                            value: isChecked,
                            onChanged: (val) => _toggleRow(item.id),
                            activeColor: const Color(0xFF5636F5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                      ),

                      // 2. Row Number
                      DataCell(
                        Text(
                          rowNumber.toString(),
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                        ),
                      ),

                      // 3. Tournament Details
                      DataCell(
                        SizedBox(
                          width: detailsWidth,
                          child: Row(
                            children: [
                              // Thumbnail Icon Box
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: item.thumbnailBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  item.thumbnailIcon,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 9),
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
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      item.subtitle,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textSecondary,
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

                      // 4. Category
                      DataCell(_buildCategoryBadge(item.category)),

                      // 5. Start Date
                      DataCell(_buildDateTimeCell(item.startDate)),

                      // 6. End Date
                      DataCell(_buildDateTimeCell(item.endDate)),

                      // 7. Entry Fee
                      DataCell(
                        Text(
                          item.entryFee == 0 ? '₹0 (Free)' : '₹${item.entryFee}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: item.entryFee == 0 ? const Color(0xFF10B981) : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),

                      // 8. Participants
                      DataCell(
                        Text(
                          _formatNumber(item.participants),
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ),

                      // 9. Status
                      DataCell(_buildStatusBadge(item.computedStatus)),

                      // 10. Prize Pool
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              size: 14,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '₹${_formatNumber(item.prizePool)}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101A3A),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 11. Actions
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // View
                            IconButton(
                              icon: const Icon(Icons.visibility_outlined, size: 15, color: AppColors.textSecondary),
                              onPressed: () => widget.onView(item),
                              tooltip: 'View Details',
                              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(width: 2),

                            // Analytics
                            IconButton(
                              icon: const Icon(Icons.bar_chart_rounded, size: 15, color: AppColors.textSecondary),
                              onPressed: () => widget.onAnalytics(item),
                              tooltip: 'Analytics',
                              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(width: 2),

                            // Edit
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 15, color: AppColors.textSecondary),
                              onPressed: () => widget.onEdit(item),
                              tooltip: 'Edit Tournament',
                              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(width: 2),

                            // More
                            GestureDetector(
                              onTapDown: (details) => widget.onMore?.call(item, details),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(Icons.more_vert_rounded, size: 15, color: AppColors.textSecondary),
                              ),
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
      );
    }

  Widget _buildCategoryBadge(String cat) {
    Color bg;
    Color fg;

    switch (cat.toLowerCase().trim()) {
      case 'railway':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2587F8);
        break;
      case 'general science':
        bg = const Color(0xFFF5F3FF);
        fg = const Color(0xFF6B4EFF);
        break;
      case 'mathematics':
        bg = const Color(0xFFFFF1F2);
        fg = const Color(0xFFF04483);
        break;
      case 'current affairs':
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFFF9F0A);
        break;
      case 'state level':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF00C48C);
        break;
      case 'reasoning':
        bg = const Color(0xFFECFEFF);
        fg = const Color(0xFF06B6D4);
        break;
      case 'biology':
        bg = const Color(0xFFF0FDF4);
        fg = const Color(0xFF10B981);
        break;
      default:
        bg = const Color(0xFFEEF2FF);
        fg = const Color(0xFF5636F5);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withAlpha(50), width: 0.8),
      ),
      child: Text(
        cat,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TournamentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }

  Widget _buildDateTimeCell(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final timeStr = '${hour.toString().padLeft(2, '0')}:$minuteStr $period';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateStr,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        ),
        Text(
          timeStr,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final startItem = widget.items.isEmpty ? 0 : (widget.currentPage - 1) * widget.rowsPerPage + 1;
    final endItem = math.min(widget.currentPage * widget.rowsPerPage, widget.totalCount);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Showing X to Y of Z tournaments
        Text(
          'Showing $startItem to $endItem of ${widget.totalCount} tournaments',
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),

        // Center: Pagination Buttons (< 1 2 3 ... >)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Previous
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 16),
              onPressed: widget.currentPage > 1
                  ? () => widget.onPageChanged(widget.currentPage - 1)
                  : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
            const SizedBox(width: 2),

            // Pages (1, 2, 3, 4 ... 24)
            ..._buildPaginationNumbers(),

            const SizedBox(width: 2),
            // Next
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 16),
              onPressed: widget.currentPage < widget.totalPages
                  ? () => widget.onPageChanged(widget.currentPage + 1)
                  : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),

        // Right: Show 10 per page
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Show ', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            AppDropdownFilter<int>(
              value: widget.rowsPerPage,
              items: const [5, 10, 20, 50],
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              borderRadius: BorderRadius.circular(6),
              onChanged: (val) {
                if (val != null) widget.onRowsPerPageChanged(val);
              },
            ),
            const Text(' per page', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildPaginationNumbers() {
    final widgets = <Widget>[];
    final pages = <int>[];

    if (widget.totalPages <= 5) {
      for (int i = 1; i <= widget.totalPages; i++) {
        pages.add(i);
      }
    } else {
      pages.addAll([1, 2, 3, 4]);
    }

    for (final p in pages) {
      final isCurrent = p == widget.currentPage;
      widgets.add(
        InkWell(
          onTap: () => widget.onPageChanged(p),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCurrent ? const Color(0xFF5636F5) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              p.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isCurrent ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(width: 2));
    }

    if (widget.totalPages > 5) {
      widgets.add(
        const Text('...', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      );
      widgets.add(const SizedBox(width: 2));
      final lastPage = widget.totalPages;
      final isLastCurrent = lastPage == widget.currentPage;
      widgets.add(
        InkWell(
          onTap: () => widget.onPageChanged(lastPage),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isLastCurrent ? const Color(0xFF5636F5) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              lastPage.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isLastCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isLastCurrent ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
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

  static String _formatShortDate(DateTime dt) {
    final local = dt.toLocal();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }
}
