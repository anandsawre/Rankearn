import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class BannersDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> banners;
  final bool isLoading;
  final void Function(Map<String, dynamic> item)? onEdit;
  final void Function(Map<String, dynamic> item)? onToggleStatus;
  final void Function(Map<String, dynamic> item)? onAnalytics;
  final void Function(Map<String, dynamic> item)? onDelete;

  const BannersDataTable({
    super.key,
    required this.banners,
    required this.isLoading,
    this.onEdit,
    this.onToggleStatus,
    this.onAnalytics,
    this.onDelete,
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0810143A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtabs and Search Bar
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
                constraints: const BoxConstraints(minWidth: 960),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.adminBackground),
                  headingTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.adminSecondaryText,
                    letterSpacing: 0.5,
                  ),
                  dataRowMinHeight: 68,
                  dataRowMaxHeight: 76,
                  horizontalMargin: 16,
                  columnSpacing: 18,
                  columns: const [
                    DataColumn(label: Text('PREVIEW')),
                    DataColumn(label: Text('BANNER TITLE & LINK')),
                    DataColumn(label: Text('STATUS')),
                    DataColumn(label: Text('DISPLAY MODE')),
                    DataColumn(label: Text('SCHEDULE')),
                    DataColumn(label: Text('VIEWS')),
                    DataColumn(label: Text('CLICKS')),
                    DataColumn(label: Text('CTR')),
                    DataColumn(label: Text('ACTIONS')),
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
                              borderRadius: BorderRadius.circular(6),
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
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.adminPrimaryText,
                                  ),
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
                                        style: const TextStyle(
                                          fontSize: 11,
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
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.adminBorder),
                            ),
                            child: Text(
                              display,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.adminPrimaryText,
                              ),
                            ),
                          ),
                        ),

                        // Schedule
                        DataCell(
                          Row(
                            children: [
                              Icon(
                                isScheduled ? Icons.date_range_rounded : Icons.all_inclusive_rounded,
                                size: 13,
                                color: isScheduled ? const Color(0xFF0284C7) : AppColors.adminSecondaryText,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                schedule,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isScheduled ? const Color(0xFF0284C7) : AppColors.adminPrimaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Views
                        DataCell(
                          Text(
                            views,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.adminPrimaryText,
                            ),
                          ),
                        ),

                        // Clicks
                        DataCell(
                          Text(
                            clicks,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.adminPrimaryText,
                            ),
                          ),
                        ),

                        // CTR
                        DataCell(
                          Text(
                            ctr,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.adminPurple,
                            ),
                          ),
                        ),

                        // Actions
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildActionButton(
                                icon: Icons.edit_outlined,
                                color: AppColors.adminPurple,
                                tooltip: 'Edit Banner',
                                onTap: () => widget.onEdit?.call(item),
                              ),
                              const SizedBox(width: 4),
                              _buildActionButton(
                                icon: isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                                color: isActive ? const Color(0xFFF97316) : AppColors.adminSuccess,
                                tooltip: isActive ? 'Pause Banner' : 'Activate Banner',
                                onTap: () => widget.onToggleStatus?.call(item),
                              ),
                              const SizedBox(width: 4),
                              _buildActionButton(
                                icon: Icons.insights_rounded,
                                color: const Color(0xFF2563EB),
                                tooltip: 'Analytics',
                                onTap: () => widget.onAnalytics?.call(item),
                              ),
                              const SizedBox(width: 4),
                              _buildActionButton(
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
                  'Showing ${startIndex + 1} to $endIndex of $totalItems banners',
                  style: const TextStyle(fontSize: 12, color: AppColors.adminSecondaryText),
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
      {'id': 'all', 'label': 'All Banners'},
      {'id': 'active', 'label': 'Active'},
      {'id': 'scheduled', 'label': 'Scheduled'},
      {'id': 'inactive', 'label': 'Inactive'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.adminBackground,
        borderRadius: AppRadii.borderMd,
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
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x10000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                t['label']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.adminPurple : AppColors.adminSecondaryText,
                ),
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
          hintText: 'Search banners...',
          hintStyle: const TextStyle(fontSize: 12, color: AppColors.adminSecondaryText),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.adminSecondaryText),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          filled: true,
          fillColor: AppColors.adminBackground,
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadii.borderMd,
            borderSide: const BorderSide(color: AppColors.adminBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadii.borderMd,
            borderSide: const BorderSide(color: AppColors.adminPurple, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isScheduled) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (isScheduled) {
      bg = const Color(0xFFE0F2FE);
      fg = const Color(0xFF0284C7);
      icon = Icons.schedule_rounded;
      label = 'SCHEDULED';
    } else if (isActive) {
      bg = const Color(0xFFDCFCE7);
      fg = AppColors.adminSuccess;
      icon = Icons.check_circle_outline_rounded;
      label = 'ACTIVE';
    } else {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
      icon = Icons.pause_circle_outline_rounded;
      label = 'INACTIVE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
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
              child: const Icon(Icons.photo_library_outlined, color: AppColors.adminPurple, size: 28),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Banners Found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.adminPrimaryText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'No promotional banners match your current filter or query.',
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
