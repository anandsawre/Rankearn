import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/tournament_item.dart';

/// Tournaments Table Card powered by the unified [AdminDataTableCard] from the design system.
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
  final ValueChanged<TournamentItem>? onManageQuestions;
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
    this.onManageQuestions,
    this.onMore,
    this.onBulkDelete,
    this.onBulkArchive,
  });

  @override
  State<TournamentsTableCard> createState() => _TournamentsTableCardState();
}

class _TournamentsTableCardState extends State<TournamentsTableCard> {
  final Set<String> _selectedIds = {};

  final List<String> _categories = const [
    'All Categories',
    'Railway',
    'General Science',
    'Mathematics',
    'Current Affairs',
    'State Level',
    'Reasoning',
    'Biology',
  ];

  final List<String> _statuses = const [
    'All Status',
    'Upcoming',
    'Ongoing',
    'Completed',
    'Archived',
  ];

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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth - 340).clamp(860.0, 1800.0);
    const double fixedColumnsWidth = 24.0 + 20.0 + 82.0 + 85.0 + 85.0 + 82.0 + 60.0 + 78.0 + 82.0 + 108.0 + 16.0;
    final double detailsWidth = (cardWidth * 0.22).clamp(180.0, 360.0);
    final double totalNeededWidth = fixedColumnsWidth + detailsWidth;
    final double remainingSpace = cardWidth - totalNeededWidth;
    final double dynamicColumnSpacing = remainingSpace > 0 ? (remainingSpace / 10).clamp(6.0, 40.0) : 6.0;

    return AdminDataTableCard(
          title: 'Tournaments List',
          totalCount: widget.totalCount,
          icon: Icons.emoji_events_rounded,
          iconBgColor: AppColors.brandPurple,
          searchQuery: widget.searchQuery,
          searchHint: 'Search tournaments by title, description...',
          onSearchChanged: widget.onSearchChanged,
          currentPage: widget.currentPage,
          totalPages: widget.totalPages,
          rowsPerPage: widget.rowsPerPage,
          onPageChanged: widget.onPageChanged,
          onRowsPerPageChanged: widget.onRowsPerPageChanged,
          itemLabel: 'tournaments',
          columnSpacing: dynamicColumnSpacing,
          filterControls: [
            AdminTableDropdown(
              value: widget.selectedStatus,
              items: _statuses,
              onChanged: widget.onStatusChanged,
            ),
            AdminTableDropdown(
              value: widget.selectedCategory,
              items: _categories,
              onChanged: widget.onCategoryChanged,
            ),
            AdminTableDateRangeButton(
              dateRange: widget.dateRange,
              onDateRangeChanged: widget.onDateRangeChanged,
            ),
            AdminTableFiltersButton(
              onTap: () {},
            ),
          ],
          columns: [
            DataColumn(
              label: SizedBox(
                width: 24,
                child: Checkbox(
                  value: _isAllSelected,
                  onChanged: (val) => _toggleSelectAll(),
                  activeColor: AppColors.brandPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                '#',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: detailsWidth,
                child: Text(
                  'Tournament Details',
                  style: TextStyle(
                    fontFamily: AppTypography.fontHeading,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Category',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Start Date',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'End Date',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Entry Fee',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Participants',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Prize Pool',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
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
                DataCell(
                  SizedBox(
                    width: 24,
                    child: Checkbox(
                      value: isChecked,
                      onChanged: (val) => _toggleRow(item.id),
                      activeColor: AppColors.brandPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    rowNumber.toString(),
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: detailsWidth,
                    child: Row(
                      children: [
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
                                style: TextStyle(
                                  fontFamily: AppTypography.fontHeading,
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
                                style: TextStyle(
                                  fontFamily: AppTypography.fontHeading,
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
                DataCell(_buildCategoryBadge(item.category)),
                DataCell(_buildDateTimeCell(item.startDate)),
                DataCell(_buildDateTimeCell(item.endDate)),
                DataCell(
                  Text(
                    item.entryFee == 0 ? '₹0 (Free)' : '₹${item.entryFee}',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: item.entryFee == 0 ? AppColors.brandGreen : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
                DataCell(
                  Text(
                    _formatNumber(item.participants),
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                DataCell(_buildStatusBadge(item.computedStatus)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 14,
                        color: AppColors.coinGold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '₹${_formatNumber(item.prizePool)}',
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AdminTableActionButton(
                        icon: Icons.visibility_outlined,
                        tooltip: 'View Details',
                        onTap: () => widget.onView(item),
                      ),
                      const SizedBox(width: 2),
                      AdminTableActionButton(
                        icon: Icons.bar_chart_rounded,
                        tooltip: 'Analytics',
                        onTap: () => widget.onAnalytics(item),
                      ),
                      const SizedBox(width: 2),
                      AdminTableActionButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit Tournament',
                        onTap: () => widget.onEdit(item),
                      ),
                      if (widget.onManageQuestions != null) ...[
                        const SizedBox(width: 2),
                        AdminTableActionButton(
                          icon: Icons.quiz_outlined,
                          tooltip: 'Manage Questions',
                          color: AppColors.brandPurple,
                          onTap: () => widget.onManageQuestions!(item),
                        ),
                      ],
                      const SizedBox(width: 2),
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
        );
  }

  Widget _buildCategoryBadge(String category) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);

    switch (category.toLowerCase()) {
      case 'railway':
        bg = const Color(0xFFEEF2FF);
        text = const Color(0xFF6366F1);
        break;
      case 'general science':
        bg = const Color(0xFFFDF2F8);
        text = const Color(0xFFDB2777);
        break;
      case 'mathematics':
        bg = const Color(0xFFFFFBEB);
        text = const Color(0xFFD97706);
        break;
      case 'current affairs':
        bg = const Color(0xFFF0FDF4);
        text = const Color(0xFF16A34A);
        break;
      case 'state level':
        bg = const Color(0xFFF5F3FF);
        text = const Color(0xFF7C3AED);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF475569);
        break;
    }

    return AdminTableStatusBadge(
      label: category,
      backgroundColor: bg,
      textColor: text,
    );
  }

  Widget _buildStatusBadge(TournamentStatus status) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);

    switch (status) {
      case TournamentStatus.upcoming:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        break;
      case TournamentStatus.ongoing:
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF16A34A);
        break;
      case TournamentStatus.completed:
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF64748B);
        break;
      case TournamentStatus.archived:
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
        break;
    }

    return AdminTableStatusBadge(
      label: status.label,
      backgroundColor: bg,
      textColor: text,
    );
  }

  Widget _buildDateTimeCell(DateTime dt) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatShortDate(dt),
          style: TextStyle(
            fontFamily: AppTypography.fontHeading,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          _formatTime(dt),
          style: TextStyle(
            fontFamily: AppTypography.fontHeading,
            fontSize: 9.5,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  static String _formatShortDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
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
