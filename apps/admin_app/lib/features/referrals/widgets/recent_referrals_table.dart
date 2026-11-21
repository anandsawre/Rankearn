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

    return AdminDataTableCard(
      title: 'Referral Logs',
      totalCount: widget.referrals.length,
      icon: Icons.people_outline_rounded,
      iconBgColor: AppColors.adminPurpleLight,
      iconColor: AppColors.adminPurple,
      searchHint: 'Search referee or code...',
      searchQuery: _searchQuery,
      onSearchChanged: (v) => setState(() {
        _searchQuery = v;
        _currentPage = 1;
      }),
      currentPage: _currentPage,
      totalPages: totalPages,
      rowsPerPage: _rowsPerPage,
      onPageChanged: (page) => setState(() => _currentPage = page),
      itemLabel: 'referrals',
      minWidth: 850.0,
      isLoading: widget.isLoading,
      emptyWidget: _buildEmptyState(),
      filterControls: [
        AdminTableDropdown<String>(
          value: _statusFilter,
          width: 150,
          prefixIcon: const Icon(Icons.filter_alt_outlined, size: 14, color: AppColors.adminPurple),
          items: const ['all', 'credited', 'pending', 'rejected'],
          itemLabel: (tab) {
            switch (tab) {
              case 'credited':
                return 'Credited';
              case 'pending':
                return 'Pending';
              case 'rejected':
                return 'Rejected';
              case 'all':
              default:
                return 'All';
            }
          },
          onChanged: (tab) => setState(() {
            _statusFilter = tab;
            _currentPage = 1;
          }),
        ),
      ],
      columns: const [
        DataColumn(label: Text('REFERRED USER', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('REFERRED BY', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('SIGNUP DATE', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('REWARD', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('STATUS', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('ACTIONS', style: AppTypography.adminTableHead)),
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
                mainAxisSize: MainAxisSize.min,
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
                mainAxisSize: MainAxisSize.min,
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
              AdminTableActionButton(
                icon: Icons.visibility_outlined,
                color: AppColors.adminPurple,
                tooltip: 'View Details',
                onTap: () => widget.onViewDetails?.call(item),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    Widget iconWidget;

    switch (status.toLowerCase()) {
      case 'pending':
        bg = AppColors.adminAmberLight;
        fg = AppColors.adminAmber;
        iconWidget = Icon(Icons.hourglass_top_rounded, size: 12, color: fg);
        break;
      case 'rejected':
        bg = AppColors.adminDangerLight;
        fg = AppColors.adminDanger;
        iconWidget = Icon(Icons.cancel_outlined, size: 12, color: fg);
        break;
      default: // credited
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
            child: const Icon(Icons.people_outline_rounded, color: AppColors.adminPurple, size: 28),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Referrals Found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.adminPrimaryText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'No referral activity matches your search or current filter criteria.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.adminSecondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
