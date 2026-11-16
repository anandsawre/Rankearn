import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class BannersDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> banners;
  final bool isLoading;
  final void Function(Map<String, dynamic> item)? onEdit;
  final void Function(Map<String, dynamic> item)? onToggleStatus;
  final void Function(Map<String, dynamic> item)? onAnalytics;
  final void Function(Map<String, dynamic> item)? onDelete;
  final bool isDesktop;

  const BannersDataTable({
    super.key,
    required this.banners,
    required this.isLoading,
    this.onEdit,
    this.onToggleStatus,
    this.onAnalytics,
    this.onDelete,
    this.isDesktop = false,
  });

  @override
  State<BannersDataTable> createState() => _BannersDataTableState();
}

class _BannersDataTableState extends State<BannersDataTable> {
  String _activeTab = 'all'; // 'all', 'active', 'scheduled', 'inactive'
  String _searchQuery = '';
  int _currentPage = 1;
  final int _rowsPerPage = 8;

  List<Map<String, dynamic>> get _filteredList {
    return widget.banners.where((b) {
      final isActive = b['isActive'] == true;
      final isScheduled = b['isScheduled'] == true;

      if (_activeTab == 'active' && !isActive) return false;
      if (_activeTab == 'inactive' && isActive) return false;
      if (_activeTab == 'scheduled' && !isScheduled) return false;

      if (_searchQuery.isNotEmpty) {
        final title = (b['title'] ?? '').toString().toLowerCase();
        final link = (b['link'] ?? '').toString().toLowerCase();
        final q = _searchQuery.toLowerCase();
        if (!title.contains(q) && !link.contains(q)) return false;
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
      title: 'Promo Banners',
      totalCount: widget.banners.length,
      icon: Icons.view_carousel_rounded,
      iconBgColor: AppColors.adminPurpleLight,
      iconColor: AppColors.adminPurple,
      searchHint: 'Search banners...',
      searchQuery: _searchQuery,
      onSearchChanged: (v) => setState(() {
        _searchQuery = v;
        _currentPage = 1;
      }),
      currentPage: _currentPage,
      totalPages: totalPages,
      rowsPerPage: _rowsPerPage,
      onPageChanged: (page) => setState(() => _currentPage = page),
      itemLabel: 'banners',
      minWidth: 960.0,
      isLoading: widget.isLoading,
      emptyWidget: _buildEmptyState(),
      filterControls: [
        AdminTableDropdown<String>(
          value: _activeTab,
          width: 175,
          prefixIcon: const Icon(Icons.filter_alt_outlined, size: 14, color: AppColors.adminPurple),
          items: const ['all', 'active', 'scheduled', 'inactive'],
          itemLabel: (tab) {
            switch (tab) {
              case 'active':
                final count = widget.banners.where((b) => b['isActive'] == true).length;
                return 'Active ($count)';
              case 'scheduled':
                final count = widget.banners.where((b) => b['isScheduled'] == true).length;
                return 'Scheduled ($count)';
              case 'inactive':
                final count = widget.banners.where((b) => b['isActive'] != true).length;
                return 'Inactive ($count)';
              case 'all':
              default:
                return 'All Banners (${widget.banners.length})';
            }
          },
          onChanged: (tab) => setState(() {
            _activeTab = tab;
            _currentPage = 1;
          }),
        ),
      ],
      columns: const [
        DataColumn(label: Text('PREVIEW', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('BANNER TITLE & LINK', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('STATUS', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('DISPLAY MODE', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('SCHEDULE', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('VIEWS', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('CLICKS', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('CTR', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('ACTIONS', style: AppTypography.adminTableHead)),
      ],
      rows: pagedItems.map((item) {
        final title = item['title']?.toString() ?? 'Promo Banner';
        final link = item['link']?.toString() ?? '/tests';
        final imageUrl = item['imageUrl']?.toString() ?? '';
        final isActive = item['isActive'] == true;
        final isScheduled = item['isScheduled'] == true;
        final display = item['display']?.toString() ?? 'Home Carousel';
        final schedule = item['schedule']?.toString() ?? 'Always Active';
        final views = item['views']?.toString() ?? '42.5k';
        final clicks = item['clicks']?.toString() ?? '8.1k';
        final ctr = item['ctr']?.toString() ?? '19.1%';

        return DataRow(
          cells: [
            // Banner Preview Thumbnail
            DataCell(
              Container(
                width: 68,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.adminBackground,
                  borderRadius: AppRadii.adminControl,
                  border: Border.all(color: AppColors.adminBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.image_outlined,
                          size: 20,
                          color: AppColors.adminSecondaryText,
                        ),
                      )
                    : const Icon(
                        Icons.photo_size_select_actual_outlined,
                        size: 20,
                        color: AppColors.adminSecondaryText,
                      ),
              ),
            ),

            // Title & Target Link
            DataCell(
              SizedBox(
                width: 220,
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
                    Row(
                      children: [
                        const Icon(Icons.link_rounded, size: 12, color: AppColors.adminSecondaryText),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            link,
                            style: AppTypography.adminTableSecondary.copyWith(
                              color: AppColors.adminPurple,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Status Badge
            DataCell(_buildStatusBadge(isActive, isScheduled)),

            // Display Mode
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.adminBackground,
                  borderRadius: AppRadii.adminControl,
                  border: Border.all(color: AppColors.adminBorder),
                ),
                child: Text(
                  display,
                  style: AppTypography.adminTableSecondary.copyWith(
                    color: AppColors.adminPrimaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Schedule
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isScheduled ? Icons.date_range_rounded : Icons.all_inclusive_rounded,
                    size: 13,
                    color: isScheduled ? AppColors.adminSky : AppColors.adminSecondaryText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    schedule,
                    style: AppTypography.adminTableSecondary.copyWith(
                      color: isScheduled ? AppColors.adminSky : AppColors.adminPrimaryText,
                    ),
                  ),
                ],
              ),
            ),

            // Views
            DataCell(
              Text(
                views,
                style: AppTypography.adminTableNumber,
              ),
            ),

            // Clicks
            DataCell(
              Text(
                clicks,
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
                    icon: Icons.edit_outlined,
                    color: AppColors.adminPurple,
                    tooltip: 'Edit Banner',
                    onTap: () => widget.onEdit?.call(item),
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                    color: isActive ? AppColors.adminOrange : AppColors.adminSuccess,
                    tooltip: isActive ? 'Pause Banner' : 'Activate Banner',
                    onTap: () => widget.onToggleStatus?.call(item),
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.insights_rounded,
                    color: AppColors.adminBlue,
                    tooltip: 'Analytics',
                    onTap: () => widget.onAnalytics?.call(item),
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.adminDanger,
                    tooltip: 'Delete Banner',
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

  Widget _buildStatusBadge(bool isActive, bool isScheduled) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (isScheduled) {
      bg = AppColors.adminSkyLight;
      fg = AppColors.adminSky;
      icon = Icons.schedule_rounded;
      label = 'SCHEDULED';
    } else if (isActive) {
      bg = AppColors.adminSuccessLight;
      fg = AppColors.adminSuccess;
      icon = Icons.check_circle_outline_rounded;
      label = 'ACTIVE';
    } else {
      bg = AppColors.adminNeutralLight;
      fg = AppColors.adminNeutral;
      icon = Icons.pause_circle_outline_rounded;
      label = 'INACTIVE';
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
            label,
            style: AppTypography.adminBadge.copyWith(color: fg),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasActiveFilter = _activeTab != 'all' || _searchQuery.isNotEmpty;

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
            child: const Icon(
              Icons.photo_library_outlined,
              color: AppColors.adminPurple,
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Banners Found',
            style: AppTypography.adminCardTitle,
          ),
          const SizedBox(height: 4),
          Text(
            'No promotional banners match your current filter or query.',
            style: AppTypography.adminCardSubtitle,
            textAlign: TextAlign.center,
          ),
          if (hasActiveFilter) ...[
            const SizedBox(height: 14),
            AppButton.adminOutline(
              label: 'Reset Filters',
              height: 36,
              onPressed: () => setState(() {
                _activeTab = 'all';
                _searchQuery = '';
                _currentPage = 1;
              }),
            ),
          ],
        ],
      ),
    );
  }
}
