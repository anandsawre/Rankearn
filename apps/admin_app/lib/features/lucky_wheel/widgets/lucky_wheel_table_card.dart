import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/lucky_wheel_item.dart';
import 'lucky_wheel_icon.dart';

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
  late final TextEditingController _searchController;

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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant LuckyWheelTableCard oldWidget) {
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EAF7), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Toolbar
          _buildToolbar(context),
          const SizedBox(height: 12),

          // Bulk action banner if items selected
          if (_selectedIds.isNotEmpty) ...[
            _buildBulkActionBar(),
            const SizedBox(height: 10),
          ],

          // 2. Data Table with zero horizontal overflow on wide screens
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth;
              final tableMinWidth = cardWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: tableMinWidth),
                  child: DataTable(
                    showCheckboxColumn: false,
                    horizontalMargin: 8,
                    columnSpacing: 8,
                    dataRowMinHeight: 56,
                    dataRowMaxHeight: 56,
                    headingRowHeight: 40,
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columns: _buildColumns(),
                    rows: _buildRows(context),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // 3. Footer Pagination
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 900;

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
          child: const LuckyWheelIcon(
            color: Colors.white,
            size: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Lucky Wheel Campaigns (${_formatNumber(widget.totalCount)})',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF101A3A),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );

    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        // Search Input
        SizedBox(
          width: isCompact ? 140 : 175,
          height: 32,
          child: TextField(
            controller: _searchController,
            onChanged: widget.onSearchChanged,
            style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search campaigns by title, description...',
              hintStyle: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded, size: 14, color: AppColors.textSecondary),
              prefixIconConstraints: const BoxConstraints(minWidth: 26),
              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
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
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _statusOptions.contains(widget.selectedStatus)
                  ? widget.selectedStatus
                  : _statusOptions.first,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textSecondary),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              onChanged: (val) {
                if (val != null) widget.onStatusChanged(val);
              },
              items: _statusOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
            ),
          ),
        ),

        // Reward Type Filter Dropdown
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _rewardTypeOptions.contains(widget.selectedRewardType)
                  ? widget.selectedRewardType
                  : _rewardTypeOptions.first,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textSecondary),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              onChanged: (val) {
                if (val != null) widget.onRewardTypeChanged(val);
              },
              items: _rewardTypeOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
            ),
          ),
        ),

        // Date Range Picker
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final res = await showDateRangePicker(
              context: context,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 1),
              initialDateRange: widget.dateRange ??
                  DateTimeRange(
                    start: DateTime(2026, 10, 1),
                    end: DateTime(2026, 10, 31),
                  ),
            );
            if (res != null) {
              widget.onDateRangeChanged(res);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Text(
                  widget.dateRange != null
                      ? '${_formatShortDate(widget.dateRange!.start)} - ${_formatShortDate(widget.dateRange!.end)}'
                      : 'Oct 1, 2026 - Oct 31, 2026',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 4),
                if (widget.dateRange != null)
                  InkWell(
                    onTap: () => widget.onDateRangeChanged(null),
                    child: const Icon(Icons.close_rounded, size: 13, color: AppColors.textMuted),
                  )
                else
                  const Icon(Icons.close_rounded, size: 13, color: AppColors.textMuted),
              ],
            ),
          ),
        ),

        // Filters Button right next to Date Range
        InkWell(
          onTap: widget.onFiltersTap ?? () {},
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 32,
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
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: controls,
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerTitle,
        const SizedBox(width: 10),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: controls,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulkActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6C8FF), width: 1),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedIds.length} campaigns selected',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5636F5),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exporting ${_selectedIds.length} campaigns...')),
              );
            },
            icon: const Icon(Icons.file_download_outlined, size: 14, color: Color(0xFF5636F5)),
            label: const Text('Export Selected', style: TextStyle(fontSize: 11, color: Color(0xFF5636F5))),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => setState(() => _selectedIds.clear()),
            child: const Text('Deselect All', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(
        label: SizedBox(
          width: 28,
          child: Checkbox(
            value: _isAllSelected,
            activeColor: const Color(0xFF5636F5),
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
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
          ),
        ),
      ),
      const DataColumn(
        label: Text(
          'Campaign Details',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
        ),
      ),
      const DataColumn(
        label: Text(
          'Reward Type',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
        ),
      ),
      const DataColumn(
        label: Text(
          'Start Date',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
        ),
      ),
      const DataColumn(
        label: Text(
          'End Date',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
        ),
      ),
      const DataColumn(
        label: Text(
          'Total Spins',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
        ),
      ),
      const DataColumn(
        label: Text(
          'Participants',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
        ),
      ),
      const DataColumn(
        label: Text(
          'Status',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
        ),
      ),
      const DataColumn(
        label: Text(
          'Created By',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
        ),
      ),
      const DataColumn(
        label: Text(
          'Actions',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
        ),
      ),
    ];
  }

  List<DataRow> _buildRows(BuildContext context) {
    return widget.items.map((item) {
      final isSelected = _selectedIds.contains(item.id);

      return DataRow(
        selected: isSelected,
        color: WidgetStateProperty.resolveWith<Color?>((states) {
          if (isSelected) return const Color(0xFFF3EEFF).withValues(alpha: 0.5);
          return null;
        }),
        cells: [
          // 1. Single Checkbox (showCheckboxColumn: false prevents duplicate!)
          DataCell(
            SizedBox(
              width: 28,
              child: Checkbox(
                value: isSelected,
                activeColor: const Color(0xFF5636F5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (val) => _toggleRow(item.id),
              ),
            ),
          ),

          // 2. Row Number #
          DataCell(
            SizedBox(
              width: 24,
              child: Text(
                '${item.rowNumber}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ),

          // 3. Campaign Details: Thumbnail + Title + Subtitle
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
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101A3A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
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
                ],
              ),
            ),
          ),

          // 4. Reward Type Badge
          DataCell(
            _buildRewardTypeBadge(item.rewardType),
          ),

          // 5. Start Date & Time
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatDate(item.startDate),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  _formatTime(item.startDate),
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 6. End Date & Time
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatDate(item.endDate),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  _formatTime(item.endDate),
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 7. Total Spins
          DataCell(
            Text(
              _formatNumber(item.totalSpins),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101A3A),
              ),
            ),
          ),

          // 8. Participants
          DataCell(
            Text(
              _formatNumber(item.participants),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101A3A),
              ),
            ),
          ),

          // 9. Status Badge
          DataCell(
            _buildStatusBadge(item.status),
          ),

          // 10. Created By
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
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  item.createdBy,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),

          // 11. Actions: Eye, BarChart, Edit, 3-dots
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionIconButton(
                  icon: Icons.remove_red_eye_outlined,
                  tooltip: 'View Campaign',
                  onTap: () => widget.onViewCampaign(item),
                ),
                const SizedBox(width: 3),
                _buildActionIconButton(
                  icon: Icons.bar_chart_rounded,
                  tooltip: 'Analytics',
                  onTap: () => widget.onAnalyticsCampaign(item),
                ),
                const SizedBox(width: 3),
                _buildActionIconButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit Campaign',
                  onTap: () => widget.onEditCampaign(item),
                ),
                const SizedBox(width: 3),
                _buildMoreMenu(item),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildRewardTypeBadge(WheelRewardType rewardType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: rewardType.backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: rewardType.color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        rewardType.label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: rewardType.color,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(WheelCampaignStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: status.color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: status.color,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildActionIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 27,
      height: 27,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 13, color: const Color(0xFF536789)),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildMoreMenu(LuckyWheelCampaignItem item) {
    return PopupMenuButton<String>(
      tooltip: 'More actions',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Container(
        width: 27,
        height: 27,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        ),
        child: const Icon(
          Icons.more_vert_rounded,
          size: 14,
          color: Color(0xFF536789),
        ),
      ),
      itemBuilder: (ctx) => [
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(Icons.copy_rounded, size: 14, color: Color(0xFF536789)),
              SizedBox(width: 8),
              Text('Duplicate Campaign', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle_pause',
          child: Row(
            children: [
              Icon(
                item.status == WheelCampaignStatus.paused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                size: 14,
                color: const Color(0xFF536789),
              ),
              const SizedBox(width: 8),
              Text(
                item.status == WheelCampaignStatus.paused ? 'Resume Campaign' : 'Pause Campaign',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'export',
          child: Row(
            children: [
              Icon(Icons.file_download_outlined, size: 14, color: Color(0xFF536789)),
              SizedBox(width: 8),
              Text('Export Spin Data', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text('Delete Campaign', style: TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
            ],
          ),
        ),
      ],
      onSelected: (val) {
        if (val == 'duplicate' && widget.onDuplicateCampaign != null) {
          widget.onDuplicateCampaign!(item);
        } else if (val == 'toggle_pause' && widget.onTogglePauseCampaign != null) {
          widget.onTogglePauseCampaign!(item);
        } else if (val == 'delete') {
          widget.onDeleteCampaign(item);
        }
      },
    );
  }

  Widget _buildFooter() {
    if (widget.totalCount <= 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Showing 0 campaigns',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Show', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
              const SizedBox(width: 6),
              Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: widget.rowsPerPage,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textSecondary),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    onChanged: (val) {
                      if (val != null) widget.onRowsPerPageChanged(val);
                    },
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5')),
                      DropdownMenuItem(value: 10, child: Text('10')),
                      DropdownMenuItem(value: 20, child: Text('20')),
                      DropdownMenuItem(value: 50, child: Text('50')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    final totalPages = (widget.totalCount / widget.rowsPerPage).ceil();
    final startItem = math.min((widget.currentPage - 1) * widget.rowsPerPage + 1, widget.totalCount);
    final endItem = math.min(widget.currentPage * widget.rowsPerPage, widget.totalCount);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Showing count
        Text(
          'Showing $startItem to $endItem of ${widget.totalCount} campaigns',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),

        // Center: Dynamic Pagination Buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPaginationArrow(
              icon: Icons.chevron_left_rounded,
              isEnabled: widget.currentPage > 1,
              onTap: () => widget.onPageChanged(widget.currentPage - 1),
            ),
            const SizedBox(width: 4),
            for (int p = 1; p <= math.min(totalPages, 5); p++) ...[
              _buildPagePill(p, isActive: widget.currentPage == p),
              const SizedBox(width: 4),
            ],
            if (totalPages > 5) ...[
              const Text('...', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              const SizedBox(width: 4),
              _buildPagePill(totalPages, isActive: widget.currentPage == totalPages),
              const SizedBox(width: 4),
            ],
            _buildPaginationArrow(
              icon: Icons.chevron_right_rounded,
              isEnabled: widget.currentPage < totalPages,
              onTap: () => widget.onPageChanged(widget.currentPage + 1),
            ),
          ],
        ),

        // Right: Show per page selector
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Show', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
            const SizedBox(width: 6),
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: widget.rowsPerPage,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textSecondary),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  onChanged: (val) {
                    if (val != null) widget.onRowsPerPageChanged(val);
                  },
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5')),
                    DropdownMenuItem(value: 10, child: Text('10')),
                    DropdownMenuItem(value: 20, child: Text('20')),
                    DropdownMenuItem(value: 50, child: Text('50')),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Text('per page', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
          ],
        ),
      ],
    );
  }

  Widget _buildPaginationArrow({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 15,
          color: isEnabled ? const Color(0xFF536789) : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }

  Widget _buildPagePill(int page, {required bool isActive}) {
    return InkWell(
      onTap: () => widget.onPageChanged(page),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF5636F5) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? const Color(0xFF5636F5) : const Color(0xFFE2E8F0),
            width: 0.8,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : const Color(0xFF536789),
          ),
        ),
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

  static String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }

  static String _formatTime(DateTime d) {
    final hour = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final period = d.hour >= 12 ? 'PM' : 'AM';
    final minute = d.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  static String _formatShortDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
