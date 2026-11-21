import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class NotificationsDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;
  final bool isLoading;
  final void Function(Map<String, dynamic> item)? onView;
  final void Function(Map<String, dynamic> item)? onEdit;
  final void Function(Map<String, dynamic> item)? onDuplicate;
  final void Function(Map<String, dynamic> item)? onDelete;

  const NotificationsDataTable({
    super.key,
    required this.notifications,
    required this.isLoading,
    this.onView,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
  });

  @override
  State<NotificationsDataTable> createState() => _NotificationsDataTableState();
}

class _NotificationsDataTableState extends State<NotificationsDataTable> {
  String _activeTab = 'all'; // 'all', 'sent', 'scheduled', 'draft'
  String _searchQuery = '';
  int _currentPage = 1;
  final int _rowsPerPage = 8;

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
      minWidth: 920.0,
      isLoading: widget.isLoading,
      emptyWidget: _buildEmptyState(),
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
          onChanged: (tab) => setState(() {
            _activeTab = tab;
            _currentPage = 1;
          }),
        ),
      ],
      columns: const [
        DataColumn(label: Text('NOTIFICATION', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('TYPE', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('AUDIENCE', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('STATUS', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('SENT / SCHEDULE', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('READS', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('CTR', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('ACTIONS', style: AppTypography.adminTableHead)),
      ],
      rows: pagedItems.map((item) {
        final title = item['title']?.toString() ?? 'Notification';
        final body = item['body']?.toString() ?? '';
        final type = item['type']?.toString() ?? 'info';
        final segment = item['segment']?.toString() ?? 'All Users';
        final status = item['status']?.toString() ?? 'sent';
        final date = item['date']?.toString() ?? 'Recent';
        final reads = item['reads']?.toString() ?? '1.2k (85%)';
        final ctr = item['ctr']?.toString() ?? '24.5%';

        return DataRow(
          cells: [
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
