import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/lucky_wheel_item.dart';

/// Lucky Wheel Table Card powered by the unified [AdminDataTableCard] from the design system.
class LuckyWheelTableCard extends StatefulWidget {
  final List<LuckyWheelCampaignItem> items;
  final int totalCount;
  final int currentPage;
  final int rowsPerPage;
  final String searchQuery;
  final String selectedStatus;
  final String selectedRewardType;
  final DateTimeRange? dateRange;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onRewardTypeChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onRowsPerPageChanged;
  final ValueChanged<LuckyWheelCampaignItem> onViewCampaign;
  final ValueChanged<LuckyWheelCampaignItem> onAnalyticsCampaign;
  final ValueChanged<LuckyWheelCampaignItem> onEditCampaign;
  final ValueChanged<LuckyWheelCampaignItem> onDeleteCampaign;
  final ValueChanged<LuckyWheelCampaignItem>? onDuplicateCampaign;
  final ValueChanged<LuckyWheelCampaignItem>? onTogglePauseCampaign;
  final VoidCallback? onFiltersTap;

  const LuckyWheelTableCard({
    super.key,
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.rowsPerPage,
    required this.searchQuery,
    required this.selectedStatus,
    required this.selectedRewardType,
    this.dateRange,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onRewardTypeChanged,
    required this.onDateRangeChanged,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
    required this.onViewCampaign,
    required this.onAnalyticsCampaign,
    required this.onEditCampaign,
    required this.onDeleteCampaign,
    this.onDuplicateCampaign,
    this.onTogglePauseCampaign,
    this.onFiltersTap,
  });

  @override
  State<LuckyWheelTableCard> createState() => _LuckyWheelTableCardState();
}

class _LuckyWheelTableCardState extends State<LuckyWheelTableCard> {
  final Set<String> _selectedIds = {};

  static const List<String> _statusOptions = [
    'All Status',
    'Active',
    'Scheduled',
    'Completed',
    'Paused',
  ];

  static const List<String> _rewardTypeOptions = [
    'All Reward Types',
    'Coins',
    'Cashback',
    'Gift',
    'Discount',
    'Product',
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
    final totalPages = (widget.totalCount / widget.rowsPerPage).ceil();

    return AdminDataTableCard(
      title: 'Lucky Wheel Campaigns',
      totalCount: widget.totalCount,
      icon: Icons.track_changes_rounded,
      iconBgColor: AppColors.brandPurple,
      searchQuery: widget.searchQuery,
      searchHint: 'Search campaigns...',
      onSearchChanged: widget.onSearchChanged,
      currentPage: widget.currentPage,
      totalPages: totalPages > 0 ? totalPages : 1,
      rowsPerPage: widget.rowsPerPage,
      onPageChanged: widget.onPageChanged,
      onRowsPerPageChanged: widget.onRowsPerPageChanged,
      itemLabel: 'campaigns',
      filterControls: [
        AdminTableDropdown(
          value: widget.selectedStatus,
          items: _statusOptions,
          onChanged: widget.onStatusChanged,
        ),
        AdminTableDropdown(
          value: widget.selectedRewardType,
          items: _rewardTypeOptions,
          onChanged: widget.onRewardTypeChanged,
        ),
        AdminTableDateRangeButton(
          dateRange: widget.dateRange,
          onDateRangeChanged: widget.onDateRangeChanged,
        ),
        AdminTableFiltersButton(
          onTap: widget.onFiltersTap ?? () {},
        ),
      ],
      columns: [
        DataColumn(
          label: SizedBox(
            width: 28,
            child: Checkbox(
              value: _isAllSelected,
              activeColor: AppColors.brandPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (val) => _toggleSelectAll(),
            ),
          ),
        ),
        const DataColumn(
          label: SizedBox(
            width: 24,
            child: Text(
              '#',
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const DataColumn(
          label: Text(
            'Campaign Details',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const DataColumn(
          label: Text(
            'Reward Type',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const DataColumn(
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
        const DataColumn(
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
        const DataColumn(
          label: Text(
            'Total Spins',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const DataColumn(
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
        const DataColumn(
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
        const DataColumn(
          label: Text(
            'Created By',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const DataColumn(
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
      rows: widget.items.map((item) {
        final isSelected = _selectedIds.contains(item.id);

        return DataRow(
          selected: isSelected,
          color: WidgetStateProperty.resolveWith<Color?>((states) {
            if (isSelected) return const Color(0xFFF3EEFF).withValues(alpha: 0.5);
            return null;
          }),
          cells: [
            DataCell(
              SizedBox(
                width: 28,
                child: Checkbox(
                  value: isSelected,
                  activeColor: AppColors.brandPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (val) => _toggleRow(item.id),
                ),
              ),
            ),
            DataCell(
              SizedBox(
                width: 24,
                child: Text(
                  '${item.rowNumber}',
                  style: TextStyle(
                    fontFamily: AppTypography.fontHeading,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: item.iconBgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: item.iconColor.withValues(alpha: 0.25), width: 0.8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(item.iconData, size: 18, color: item.iconColor),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                  ],
                ),
              ),
            ),
            DataCell(_buildRewardTypeBadge(item.rewardType)),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatDate(item.startDate),
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _formatTime(item.startDate),
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatDate(item.endDate),
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _formatTime(item.endDate),
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(
              Text(
                _formatNumber(item.totalSpins),
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
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
            DataCell(_buildStatusBadge(item.status)),
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
                    child: const Icon(Icons.person, color: Colors.white, size: 12),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.createdBy,
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11,
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
                    tooltip: 'View Campaign',
                    onTap: () => widget.onViewCampaign(item),
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.bar_chart_rounded,
                    tooltip: 'Analytics',
                    onTap: () => widget.onAnalyticsCampaign(item),
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit Campaign',
                    onTap: () => widget.onEditCampaign(item),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onSelected: (val) {
                      if (val == 'pause') widget.onTogglePauseCampaign?.call(item);
                      if (val == 'duplicate') widget.onDuplicateCampaign?.call(item);
                      if (val == 'delete') widget.onDeleteCampaign(item);
                    },
                    itemBuilder: (context) => [
                      if (widget.onTogglePauseCampaign != null)
                        PopupMenuItem(
                          value: 'pause',
                          child: Text(
                            item.status == WheelCampaignStatus.active ? 'Pause Campaign' : 'Resume Campaign',
                            style: TextStyle(fontFamily: AppTypography.fontHeading, fontSize: 12),
                          ),
                        ),
                      if (widget.onDuplicateCampaign != null)
                        PopupMenuItem(
                          value: 'duplicate',
                          child: Text(
                            'Duplicate Campaign',
                            style: TextStyle(fontFamily: AppTypography.fontHeading, fontSize: 12),
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete Campaign',
                          style: TextStyle(fontFamily: AppTypography.fontHeading, fontSize: 12, color: Colors.red),
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
    );
  }

  Widget _buildRewardTypeBadge(WheelRewardType type) {
    return AdminTableStatusBadge(
      label: type.label,
      backgroundColor: type.backgroundColor,
      textColor: type.color,
    );
  }

  Widget _buildStatusBadge(WheelCampaignStatus status) {
    return AdminTableStatusBadge(
      label: status.label,
      backgroundColor: status.backgroundColor,
      textColor: status.color,
      isLive: status == WheelCampaignStatus.active,
    );
  }

  static String _formatDate(DateTime dt) {
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
