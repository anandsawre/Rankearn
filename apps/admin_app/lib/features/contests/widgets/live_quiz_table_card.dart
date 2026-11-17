import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/live_quiz_item.dart';

/// Pixel-accurate Live Quiz Data Table Card powered by the unified [AdminDataTableCard]
/// from the Rankearn design system.
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
  final Function(LiveQuizItem)? onManageQuestions;
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
    this.onManageQuestions,
    required this.onMore,
    this.onFiltersTap,
  });

  @override
  State<LiveQuizTableCard> createState() => _LiveQuizTableCardState();
}

class _LiveQuizTableCardState extends State<LiveQuizTableCard> {
  final Set<String> _selectedIds = {};

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

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth - 340).clamp(860.0, 1800.0);
    final double detailsWidth = (cardWidth * 0.22).clamp(180.0, 360.0);
    const double fixedColumnsWidth = 24.0 + 22.0 + 85.0 + 85.0 + 65.0 + 60.0 + 75.0 + 75.0 + 110.0 + 32.0;
    final double remainingSpace = cardWidth - (fixedColumnsWidth + detailsWidth);
    final double dynamicColumnSpacing = remainingSpace > 0 ? (remainingSpace / 9).clamp(6.0, 48.0) : 6.0;

    return AdminDataTableCard(
          title: 'Live Quiz List',
          totalCount: widget.totalCount,
          icon: Icons.podcasts_rounded,
          iconBgColor: AppColors.brandBlue,
          searchQuery: widget.searchQuery,
          searchHint: 'Search live quiz by title, description...',
          onSearchChanged: widget.onSearchChanged,
          currentPage: widget.currentPage,
          totalPages: widget.totalPages,
          rowsPerPage: widget.rowsPerPage,
          onPageChanged: widget.onPageChanged,
          onRowsPerPageChanged: widget.onRowsPerPageChanged,
          itemLabel: 'live quizzes',
          columnSpacing: dynamicColumnSpacing,
          filterControls: [
            AdminTableDropdown(
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
            AdminTableDropdown(
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
            AdminTableDateRangeButton(
              dateRange: widget.dateRange,
              onDateRangeChanged: widget.onDateRangeChanged,
            ),
            AdminTableFiltersButton(
              onTap: widget.onFiltersTap ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Filter options opened'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
            ),
          ],
          columns: [
            DataColumn(
              label: SizedBox(
                width: 22,
                child: Checkbox(
                  value: allSelected,
                  onChanged: _toggleSelectAll,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  activeColor: AppColors.brandPurple,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                  'Quiz Details',
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
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Category',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_drop_down, size: 14, color: AppColors.textMuted),
                ],
              ),
            ),
            DataColumn(
              label: Text(
                'Start Time',
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
                'Duration',
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
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_drop_down, size: 14, color: AppColors.textMuted),
                ],
              ),
            ),
            DataColumn(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Created By',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_drop_down, size: 14, color: AppColors.textMuted),
                ],
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
                DataCell(
                  SizedBox(
                    width: 22,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleItem(item.id),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      activeColor: AppColors.brandPurple,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '$idx',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
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
                                style: TextStyle(
                                  fontFamily: AppTypography.fontHeading,
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
                                style: TextStyle(
                                  fontFamily: AppTypography.fontHeading,
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
                DataCell(
                  AdminTableStatusBadge(
                    label: item.category,
                    backgroundColor: LiveQuizItem.getCategoryBgColor(item.category),
                    borderColor: LiveQuizItem.getCategoryBorderColor(item.category),
                    textColor: LiveQuizItem.getCategoryTextColor(item.category),
                  ),
                ),
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(item.startTime),
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _formatTime(item.startTime),
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 9.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${item.durationMinutes} min',
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
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
                      const Icon(Icons.people_alt_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _formatNumber(item.participantsCount),
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  AdminTableStatusBadge(
                    label: item.statusLabel,
                    backgroundColor: item.statusBgColor,
                    borderColor: item.statusBorderColor,
                    textColor: item.statusTextColor,
                    isLive: item.status == LiveQuizStatus.liveNow,
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AppColors.brandPurple,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.person, color: Colors.white, size: 13),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.createdByName,
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
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
                        tooltip: 'View Quiz',
                        onTap: () => widget.onView(item),
                      ),
                      const SizedBox(width: 4),
                      AdminTableActionButton(
                        icon: Icons.bar_chart_rounded,
                        tooltip: 'Analytics',
                        onTap: () => widget.onAnalytics(item),
                      ),
                      const SizedBox(width: 4),
                      AdminTableActionButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit Quiz',
                        onTap: () => widget.onEdit(item),
                      ),
                      const SizedBox(width: 4),
                      if (widget.onManageQuestions != null) ...[
                        AdminTableActionButton(
                          icon: Icons.quiz_outlined,
                          tooltip: 'Manage Questions',
                          color: AppColors.brandPurple,
                          onTap: () => widget.onManageQuestions!(item),
                        ),
                        const SizedBox(width: 4),
                      ],
                      AdminTableActionButton(
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
