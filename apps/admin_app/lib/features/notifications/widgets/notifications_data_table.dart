import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class NotificationsDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;
  final bool isLoading;
  final void Function(Map<String, dynamic> item)? onView;
  final void Function(Map<String, dynamic> item)? onEdit;
  final void Function(Map<String, dynamic> item)? onDuplicate;
  final void Function(Map<String, dynamic> item)? onDelete;
  final void Function(List<String> ids)? onBulkDelete;
  final String? activeTab;
  final ValueChanged<String>? onTabChanged;

  const NotificationsDataTable({
    super.key,
    required this.notifications,
    required this.isLoading,
    this.onView,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
    this.onBulkDelete,
    this.activeTab,
    this.onTabChanged,
  });

  @override
  State<NotificationsDataTable> createState() => _NotificationsDataTableState();
}

class _NotificationsDataTableState extends State<NotificationsDataTable> {
  late String _activeTab;
  String _searchQuery = '';
  int _currentPage = 1;
  final int _rowsPerPage = 8;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _activeTab = widget.activeTab ?? 'all';
  }

  @override
  void didUpdateWidget(covariant NotificationsDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeTab != null && widget.activeTab != _activeTab) {
      _activeTab = widget.activeTab!;
      _currentPage = 1;
    }
    final currentIds = widget.notifications
        .map((e) => e['id']?.toString() ?? '')
        .toSet();
    _selectedIds.removeWhere((id) => !currentIds.contains(id));
  }

  bool? _getSelectAllState(List<Map<String, dynamic>> pagedItems) {
    if (pagedItems.isEmpty) return false;
    final pageIds = pagedItems
        .map((e) => e['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    if (pageIds.isEmpty) return false;
    final selectedCount = pageIds.where((id) => _selectedIds.contains(id)).length;
    if (selectedCount == 0) return false;
    if (selectedCount == pageIds.length) return true;
    return null; // Tristate indeterminate (dash)
  }

  void _toggleSelectAll(List<Map<String, dynamic>> pagedItems) {
    setState(() {
      final pageIds = pagedItems
          .map((e) => e['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      final allSelected = pageIds.isNotEmpty && pageIds.every((id) => _selectedIds.contains(id));
      if (allSelected) {
        _selectedIds.removeAll(pageIds);
      } else {
        _selectedIds.addAll(pageIds);
      }
    });
  }

  void _toggleRow(String id) {
    if (id.isEmpty) return;
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  List<Map<String, dynamic>> get _filteredList {
    return widget.notifications.where((n) {
      // Tab filter
      final status = (n['status'] ?? 'sent').toString().toLowerCase();
      if (_activeTab != 'all' && status != _activeTab) {
        return false;
      }
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final title = (n['title'] ?? '').toString().toLowerCase();
        final body = (n['body'] ?? '').toString().toLowerCase();
        final segment = (n['segment'] ?? '').toString().toLowerCase();
        final q = _searchQuery.toLowerCase();
        if (!title.contains(q) && !body.contains(q) && !segment.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredList;
    final totalItems = filtered.length;
    final totalPages = (totalItems / _rowsPerPage).ceil().clamp(1, 999);
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, totalItems);
    final pagedItems = totalItems > 0 && startIndex < totalItems
        ? filtered.sublist(startIndex, endIndex)
        : <Map<String, dynamic>>[];

    return AdminDataTableCard(
      title: 'Notification History',
      totalCount: widget.notifications.length,
      icon: Icons.notifications_active_rounded,
      iconBgColor: AppColors.adminPurpleLight,
      iconColor: AppColors.adminPurple,
      searchHint: 'Search notifications...',
      searchQuery: _searchQuery,
      onSearchChanged: (v) => setState(() {
        _searchQuery = v;
        _currentPage = 1;
      }),
      currentPage: _currentPage,
      totalPages: totalPages,
      rowsPerPage: _rowsPerPage,
      onPageChanged: (page) => setState(() => _currentPage = page),
      itemLabel: 'notifications',
      minWidth: 980.0,
      isLoading: widget.isLoading,
      emptyWidget: _buildEmptyState(),
      headerActions: _selectedIds.isEmpty
          ? null
          : [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.brandPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.brandPurple),
                    const SizedBox(width: 5),
                    Text(
                      '${_selectedIds.length} Selected',
                      style: const TextStyle(
                        fontFamily: AppTypography.fontBody,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandPurple,
                      ),
                    ),
                  ],
                ),
              ),
              AppButton(
                label: 'Delete Selected (${_selectedIds.length})',
                variant: AppButtonVariant.destructive,
                height: 32,
                leadingIcon: const Icon(Icons.delete_outline_rounded, size: 14, color: Colors.white),
                borderRadius: BorderRadius.circular(6),
                onPressed: () {
                  final idsToDelete = _selectedIds.toList();
                  widget.onBulkDelete?.call(idsToDelete);
                },
              ),
              Tooltip(
                message: 'Deselect all',
                child: InkWell(
                  onTap: () => setState(() => _selectedIds.clear()),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 32,
                    width: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.adminBackground,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.adminBorder),
                    ),
                    child: const Icon(Icons.close_rounded, size: 16, color: AppColors.adminSecondaryText),
                  ),
                ),
              ),
            ],
      filterControls: [
        AdminTableDropdown<String>(
          value: _activeTab,
          width: 150,
          prefixIcon: const Icon(Icons.filter_alt_outlined, size: 14, color: AppColors.adminPurple),
          items: const ['all', 'sent', 'scheduled', 'draft'],
          itemLabel: (tab) {
            switch (tab) {
              case 'sent':
                return 'Sent';
              case 'scheduled':
                return 'Scheduled';
              case 'draft':
                return 'Draft';
              case 'all':
              default:
                return 'All';
            }
          },
          onChanged: (tab) {
            setState(() {
              _activeTab = tab;
              _currentPage = 1;
            });
            widget.onTabChanged?.call(tab);
          },
        ),
      ],
      columns: [
        DataColumn(
          label: SizedBox(
            width: 24,
            child: Checkbox(
              value: _getSelectAllState(pagedItems),
              tristate: true,
              onChanged: pagedItems.isEmpty
                  ? null
                  : (_) => _toggleSelectAll(pagedItems),
              activeColor: AppColors.brandPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const DataColumn(label: Text('NOTIFICATION', style: AppTypography.adminTableHead)),
        const DataColumn(label: Text('TYPE', style: AppTypography.adminTableHead)),
        const DataColumn(label: Text('AUDIENCE', style: AppTypography.adminTableHead)),
        const DataColumn(label: Text('STATUS', style: AppTypography.adminTableHead)),
        const DataColumn(label: Text('SENT / SCHEDULE', style: AppTypography.adminTableHead)),
        const DataColumn(label: Text('READS', style: AppTypography.adminTableHead)),
        const DataColumn(label: Text('CTR', style: AppTypography.adminTableHead)),
        const DataColumn(label: Text('ACTIONS', style: AppTypography.adminTableHead)),
      ],
      rows: pagedItems.map((item) {
        final id = item['id']?.toString() ?? '';
        final isChecked = id.isNotEmpty && _selectedIds.contains(id);
        final title = item['title']?.toString() ?? 'Notification';
        final body = item['body']?.toString() ?? '';
        final type = item['type']?.toString() ?? 'info';
        final segment = item['segment']?.toString() ?? 'All Users';
        final status = item['status']?.toString() ?? 'sent';
        final date = item['date']?.toString() ?? 'Recent';
        final reads = item['reads']?.toString() ?? '1.2k (85%)';
        final ctr = item['ctr']?.toString() ?? '24.5%';

        return DataRow(
          selected: isChecked,
          onSelectChanged: id.isEmpty ? null : (_) => _toggleRow(id),
          cells: [
            // Checkbox
            DataCell(
              SizedBox(
                width: 24,
                child: Checkbox(
                  value: isChecked,
                  activeColor: AppColors.brandPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: id.isEmpty ? null : (_) => _toggleRow(id),
                ),
              ),
            ),
            // Notification Title & Message
            DataCell(
              SizedBox(
                width: 240,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTypography.adminTablePrimary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: AppTypography.adminTableSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Type Badge
            DataCell(_buildTypeBadge(type)),

            // Audience
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.adminBackground,
                  borderRadius: AppRadii.adminBadge,
                  border: Border.all(color: AppColors.adminBorder),
                ),
                child: Text(
                  segment,
                  style: AppTypography.adminTableSecondary.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.adminPrimaryText,
                  ),
                ),
              ),
            ),

            // Status Badge
            DataCell(_buildStatusBadge(status)),

            // Sent / Schedule Date
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.adminSecondaryText),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: AppTypography.adminTableSecondary.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.adminPrimaryText,
                    ),
                  ),
                ],
              ),
            ),

            // Reads
            DataCell(
              Text(
                reads,
                style: AppTypography.adminTableNumber,
              ),
            ),

            // CTR
            DataCell(
              Text(
                ctr,
                style: AppTypography.adminTableAccent,
              ),
            ),

            // Actions
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminTableActionButton(
                    icon: Icons.visibility_outlined,
                    color: AppColors.adminPurple,
                    tooltip: 'View Details',
                    onTap: () => widget.onView?.call(item),
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.edit_outlined,
                    color: AppColors.adminBlue,
                    tooltip: 'Edit',
                    onTap: () => widget.onEdit?.call(item),
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.content_copy_rounded,
                    color: AppColors.adminTeal,
                    tooltip: 'Duplicate',
                    onTap: () => widget.onDuplicate?.call(item),
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.adminDanger,
                    tooltip: 'Delete',
                    onTap: () => widget.onDelete?.call(item),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color bg;
    Color fg;
    switch (type.toLowerCase()) {
      case 'alert':
        bg = AppColors.adminDangerLight;
        fg = AppColors.adminDanger;
        break;
      case 'promotional':
        bg = AppColors.adminAmberLight;
        fg = AppColors.adminAmber;
        break;
      case 'contest':
        bg = AppColors.adminPurpleLight;
        fg = AppColors.adminPurple;
        break;
      case 'update':
        bg = AppColors.adminBlueLight;
        fg = AppColors.adminBlue;
        break;
      default:
        bg = AppColors.adminNeutralLight;
        fg = AppColors.adminNeutral;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.adminBadge,
      ),
      child: Text(
        type.toUpperCase(),
        style: AppTypography.adminBadge.copyWith(color: fg),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    Widget iconWidget;

    switch (status.toLowerCase()) {
      case 'scheduled':
        bg = AppColors.adminSkyLight;
        fg = AppColors.adminSky;
        iconWidget = Icon(Icons.schedule_rounded, size: 12, color: fg);
        break;
      case 'draft':
        bg = AppColors.adminNeutralLight;
        fg = AppColors.adminNeutral;
        iconWidget = Icon(Icons.drafts_outlined, size: 12, color: fg);
        break;
      default: // sent
        bg = AppColors.adminSuccessLight;
        fg = AppColors.adminSuccess;
        iconWidget = Container(
          width: 13,
          height: 13,
          decoration: const BoxDecoration(
            color: AppColors.adminSuccess,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.check_rounded,
            size: 9.5,
            color: Colors.white,
          ),
        );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.adminStatusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: AppTypography.adminBadge.copyWith(color: fg),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.adminPurpleLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_outlined, color: AppColors.adminPurple, size: 28),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Notifications Found',
            style: AppTypography.adminSectionTitle,
          ),
          const SizedBox(height: 4),
          const Text(
            'No notifications match your search or current filter criteria.',
            style: AppTypography.adminTableSecondary,
          ),
        ],
      ),
    );
  }
}
