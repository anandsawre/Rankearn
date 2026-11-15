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

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: AppRadii.adminCard,
        border: Border.fromBorderSide(BorderSide(color: AppColors.adminBorder)),
        boxShadow: AppShadows.adminCard,
      ),
      padding: AppSpacing.adminCardPaddingCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header: Title, Tabs & Search
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 768;
              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSubTabs(),
                    _buildSearchInput(),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubTabs(),
                  const SizedBox(height: 12),
                  _buildSearchInput(),
                ],
              );
            },
          ),
          const SizedBox(height: 18),

          // Data Table
          if (widget.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.adminPurple),
              ),
            )
          else if (filtered.isEmpty)
            _buildEmptyState()
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 900),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.adminBackground),
                  headingTextStyle: AppTypography.adminTableHead,
                  dataRowMinHeight: 64,
                  dataRowMaxHeight: 72,
                  horizontalMargin: 16,
                  columnSpacing: 18,
                  columns: const [
                    DataColumn(label: Text('NOTIFICATION')),
                    DataColumn(label: Text('TYPE')),
                    DataColumn(label: Text('AUDIENCE')),
                    DataColumn(label: Text('STATUS')),
                    DataColumn(label: Text('SENT / SCHEDULE')),
                    DataColumn(label: Text('READS')),
                    DataColumn(label: Text('CTR')),
                    DataColumn(label: Text('ACTIONS')),
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
                              _buildActionButton(
                                icon: Icons.visibility_outlined,
                                color: AppColors.adminPurple,
                                tooltip: 'View Details',
                                onTap: () => widget.onView?.call(item),
                              ),
                              const SizedBox(width: 4),
                              _buildActionButton(
                                icon: Icons.edit_outlined,
                                color: const Color(0xFF2563EB),
                                tooltip: 'Edit',
                                onTap: () => widget.onEdit?.call(item),
                              ),
                              const SizedBox(width: 4),
                              _buildActionButton(
                                icon: Icons.content_copy_rounded,
                                color: const Color(0xFF0D9488),
                                tooltip: 'Duplicate',
                                onTap: () => widget.onDuplicate?.call(item),
                              ),
                              const SizedBox(width: 4),
                              _buildActionButton(
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
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Pagination
          if (filtered.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${startIndex + 1} to $endIndex of $totalItems notifications',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.adminSecondaryText,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 20),
                      onPressed: _currentPage > 1
                          ? () => setState(() => _currentPage--)
                          : null,
                      color: AppColors.adminPurple,
                    ),
                    Text(
                      'Page $_currentPage of $totalPages',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.adminPrimaryText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 20),
                      onPressed: _currentPage < totalPages
                          ? () => setState(() => _currentPage++)
                          : null,
                      color: AppColors.adminPurple,
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSubTabs() {
    final tabs = [
      {'id': 'all', 'label': 'All'},
      {'id': 'sent', 'label': 'Sent'},
      {'id': 'scheduled', 'label': 'Scheduled'},
      {'id': 'draft', 'label': 'Draft'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.adminBackground,
        borderRadius: AppRadii.adminControl,
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs.map((t) {
          final isSelected = _activeTab == t['id'];
          return InkWell(
            onTap: () => setState(() {
              _activeTab = t['id']!;
              _currentPage = 1;
            }),
            borderRadius: AppRadii.adminTab,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: AppRadii.adminTab,
                boxShadow: isSelected ? AppShadows.adminSubtle : null,
              ),
              child: Text(
                t['label']!,
                style: isSelected ? AppTypography.adminTabActive : AppTypography.adminTabInactive,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchInput() {
    return SizedBox(
      width: 240,
      height: 38,
      child: TextField(
        onChanged: (v) => setState(() {
          _searchQuery = v;
          _currentPage = 1;
        }),
        style: const TextStyle(fontSize: 12, color: AppColors.adminPrimaryText),
        decoration: InputDecoration(
          hintText: 'Search notifications...',
          hintStyle: const TextStyle(fontSize: 12, color: AppColors.adminSecondaryText),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.adminSecondaryText),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          filled: true,
          fillColor: AppColors.adminBackground,
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppRadii.adminControl,
            borderSide: BorderSide(color: AppColors.adminBorder),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: AppRadii.adminControl,
            borderSide: BorderSide(color: AppColors.adminPurple, width: 1.5),
          ),
        ),
      ),
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
    IconData icon;

    switch (status.toLowerCase()) {
      case 'scheduled':
        bg = AppColors.adminSkyLight;
        fg = AppColors.adminSky;
        icon = Icons.schedule_rounded;
        break;
      case 'draft':
        bg = AppColors.adminNeutralLight;
        fg = AppColors.adminNeutral;
        icon = Icons.drafts_outlined;
        break;
      default: // sent
        bg = AppColors.adminSuccessLight;
        fg = AppColors.adminSuccess;
        icon = Icons.check_circle_outline_rounded;
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
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: AppTypography.adminBadge.copyWith(color: fg),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.adminPurpleLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_off_outlined, color: AppColors.adminPurple, size: 28),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Notifications Found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.adminPrimaryText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'No notifications match your search or current filter criteria.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.adminSecondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
