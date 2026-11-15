import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class RecentReferralsTable extends StatefulWidget {
  final List<Map<String, dynamic>> referrals;
  final bool isLoading;
  final void Function(Map<String, dynamic> item)? onViewDetails;

  const RecentReferralsTable({
    super.key,
    required this.referrals,
    required this.isLoading,
    this.onViewDetails,
  });

  @override
  State<RecentReferralsTable> createState() => _RecentReferralsTableState();
}

class _RecentReferralsTableState extends State<RecentReferralsTable> {
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'credited', 'pending', 'rejected'
  int _currentPage = 1;
  final int _rowsPerPage = 8;

  List<Map<String, dynamic>> get _filteredList {
    return widget.referrals.where((r) {
      final status = (r['status'] ?? 'credited').toString().toLowerCase();
      if (_statusFilter != 'all' && status != _statusFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final referee = (r['refereeName'] ?? '').toString().toLowerCase();
        final referrer = (r['referrerName'] ?? '').toString().toLowerCase();
        final code = (r['code'] ?? '').toString().toLowerCase();
        final q = _searchQuery.toLowerCase();
        if (!referee.contains(q) && !referrer.contains(q) && !code.contains(q)) {
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
          // Table Title, Filter & Search
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 768;
              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusTabs(),
                    _buildSearchInput(),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusTabs(),
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
                constraints: const BoxConstraints(minWidth: 850),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.adminBackground),
                  headingTextStyle: AppTypography.adminTableHead,
                  dataRowMinHeight: 64,
                  dataRowMaxHeight: 70,
                  horizontalMargin: 16,
                  columnSpacing: 18,
                  columns: const [
                    DataColumn(label: Text('REFERRED USER')),
                    DataColumn(label: Text('REFERRED BY')),
                    DataColumn(label: Text('SIGNUP DATE')),
                    DataColumn(label: Text('REWARD')),
                    DataColumn(label: Text('STATUS')),
                    DataColumn(label: Text('ACTIONS')),
                  ],
                  rows: pagedItems.map((item) {
                    final refereeName = item['refereeName']?.toString() ?? 'Candidate';
                    final refereeEmail = item['refereeEmail']?.toString() ?? 'candidate@rankearn.in';
                    final referrerName = item['referrerName']?.toString() ?? 'Top Referrer';
                    final code = item['code']?.toString() ?? 'REF-EARN';
                    final date = item['date']?.toString() ?? 'Recent';
                    final bonusCoins = item['bonusCoins'] ?? 50;
                    final status = item['status']?.toString() ?? 'credited';

                    return DataRow(
                      cells: [
                        // Referred User (Avatar + Name & Email)
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.adminPurpleLight,
                                child: Text(
                                  refereeName.isNotEmpty ? refereeName[0].toUpperCase() : 'U',
                                  style: AppTypography.adminTablePrimary.copyWith(color: AppColors.adminPurple),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    refereeName,
                                    style: AppTypography.adminTablePrimary,
                                  ),
                                  Text(
                                    refereeEmail,
                                    style: AppTypography.adminTableSecondary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Referred By (Name & Code)
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                referrerName,
                                style: AppTypography.adminTablePrimary,
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.adminPurpleLight.withAlpha(90),
                                  borderRadius: AppRadii.adminBadge,
                                ),
                                child: Text(
                                  code,
                                  style: AppTypography.adminBadge.copyWith(color: AppColors.adminPurple),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Signup Date
                        DataCell(
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.adminSecondaryText),
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

                        // Reward
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.adminAmberLight,
                              borderRadius: AppRadii.adminBadge,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.monetization_on_rounded, size: 13, color: AppColors.adminAmber),
                                const SizedBox(width: 4),
                                Text(
                                  '+$bonusCoins Coins',
                                  style: AppTypography.adminBadge.copyWith(color: AppColors.adminAmberDark),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Status Badge
                        DataCell(_buildStatusBadge(status)),

                        // Actions
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined, size: 16),
                            color: AppColors.adminPurple,
                            tooltip: 'View Details',
                            onPressed: () => widget.onViewDetails?.call(item),
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
                  'Showing ${startIndex + 1} to $endIndex of $totalItems referrals',
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

  Widget _buildStatusTabs() {
    final tabs = [
      {'id': 'all', 'label': 'All Referrals'},
      {'id': 'credited', 'label': 'Credited'},
      {'id': 'pending', 'label': 'Pending'},
      {'id': 'rejected', 'label': 'Rejected'},
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
          final isSelected = _statusFilter == t['id'];
          return InkWell(
            onTap: () => setState(() {
              _statusFilter = t['id']!;
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
          hintText: 'Search referee or code...',
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

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        bg = AppColors.adminAmberLight;
        fg = AppColors.adminAmber;
        icon = Icons.hourglass_top_rounded;
        break;
      case 'rejected':
        bg = AppColors.adminDangerLight;
        fg = AppColors.adminDanger;
        icon = Icons.cancel_outlined;
        break;
      default: // credited
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
              child: const Icon(Icons.group_off_outlined, color: AppColors.adminPurple, size: 28),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Referral Records Found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.adminPrimaryText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'No referral logs match the current search or filter query.',
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
