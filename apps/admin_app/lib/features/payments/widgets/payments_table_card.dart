import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import '../models/payment_item.dart';

/// Pixel-accurate Payments Data Table Card powered by unified [AdminDataTableCard].
class PaymentsTableCard extends StatefulWidget {
  final List<PaymentItem> items;
  final int totalCount;
  final String selectedMethod;
  final String selectedStatus;
  final String searchQuery;
  final DateTimeRange? dateRange;
  final int currentPage;
  final int totalPages;
  final int rowsPerPage;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onMethodChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onRowsPerPageChanged;
  final ValueChanged<PaymentItem> onViewDetails;
  final ValueChanged<PaymentItem> onViewReceipt;
  final void Function(PaymentItem item, TapDownDetails details)? onMore;
  final ValueChanged<List<String>>? onBulkExport;
  final VoidCallback? onFiltersTap;

  // Embedded Top-up & Withdrawal support directly in table
  final String activeView; // 'payments', 'topups', 'withdrawals'
  final ValueChanged<String>? onViewChanged;
  final List<Map<String, dynamic>> topups;
  final List<Map<String, dynamic>> withdrawals;
  final void Function(Map<String, dynamic> topup)? onApproveTopup;
  final void Function(Map<String, dynamic> topup)? onRejectTopup;
  final void Function(Map<String, dynamic> withdrawal)? onPayoutWithdrawal;
  final void Function(Map<String, dynamic> withdrawal)? onRejectWithdrawal;

  const PaymentsTableCard({
    super.key,
    required this.items,
    required this.totalCount,
    this.selectedMethod = 'All Payment Methods',
    this.selectedStatus = 'All Status',
    this.searchQuery = '',
    this.dateRange,
    this.currentPage = 1,
    this.totalPages = 835,
    this.rowsPerPage = 10,
    required this.onSearchChanged,
    required this.onMethodChanged,
    required this.onStatusChanged,
    required this.onDateRangeChanged,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
    required this.onViewDetails,
    required this.onViewReceipt,
    this.onMore,
    this.onBulkExport,
    this.onFiltersTap,
    this.activeView = 'payments',
    this.onViewChanged,
    this.topups = const [],
    this.withdrawals = const [],
    this.onApproveTopup,
    this.onRejectTopup,
    this.onPayoutWithdrawal,
    this.onRejectWithdrawal,
  });

  @override
  State<PaymentsTableCard> createState() => _PaymentsTableCardState();
}

class _PaymentsTableCardState extends State<PaymentsTableCard> {
  final Set<String> _selectedIds = {};

  // Search & Filter state for embedded Top-up & Withdrawal views
  String _topupSearchQuery = '';
  String _topupStatusFilter = 'all'; // 'all', 'pending', 'approved'
  String _withdrawalSearchQuery = '';
  String _withdrawalStatusFilter = 'all'; // 'all', 'pending', 'paid'

  static const List<String> _methodFilterOptions = [
    'All Payment Methods',
    'Razorpay',
    'UPI',
    'Credit Card',
    'Debit Card',
    'Net Banking',
    'Wallet',
  ];

  static const List<String> _statusFilterOptions = [
    'All Status',
    'Success',
    'Failed',
    'Pending',
  ];

  List<Map<String, dynamic>> get _filteredTopups {
    return widget.topups.where((t) {
      if (_topupStatusFilter != 'all') {
        if (t['status'] != _topupStatusFilter) return false;
      }
      if (_topupSearchQuery.trim().isNotEmpty) {
        final q = _topupSearchQuery.trim().toLowerCase();
        final name = (t['name'] ?? '').toString().toLowerCase();
        final email = (t['email'] ?? '').toString().toLowerCase();
        final utr = (t['utr'] ?? '').toString().toLowerCase();
        if (!name.contains(q) && !email.contains(q) && !utr.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredWithdrawals {
    return widget.withdrawals.where((w) {
      if (_withdrawalStatusFilter != 'all') {
        if (w['status'] != _withdrawalStatusFilter) return false;
      }
      if (_withdrawalSearchQuery.trim().isNotEmpty) {
        final q = _withdrawalSearchQuery.trim().toLowerCase();
        final name = (w['name'] ?? '').toString().toLowerCase();
        final email = (w['email'] ?? '').toString().toLowerCase();
        final upi = (w['upi'] ?? '').toString().toLowerCase();
        if (!name.contains(q) && !email.contains(q) && !upi.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
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

  Widget _buildStatusFilterPill(
    String label,
    String value,
    String currentValue,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = value == currentValue;
    return InkWell(
      onTap: () => onSelected(value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? const [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activeView == 'topups') {
      return _buildTopupsCard(context);
    } else if (widget.activeView == 'withdrawals') {
      return _buildWithdrawalsCard(context);
    }

    return _buildPaymentsCard(context);
  }

  Widget _buildPaymentsCard(BuildContext context) {
    return AdminDataTableCard(
      title: 'Payments List',
      totalCount: widget.totalCount,
      icon: Icons.receipt_long_rounded,
      iconBgColor: const Color(0xFF2587F8),
      searchQuery: widget.searchQuery,
      searchHint: 'Search by user, transaction ID, or purpose...',
      onSearchChanged: widget.onSearchChanged,
      currentPage: widget.currentPage,
      totalPages: widget.totalPages,
      rowsPerPage: widget.rowsPerPage,
      onPageChanged: widget.onPageChanged,
      onRowsPerPageChanged: widget.onRowsPerPageChanged,
      itemLabel: 'transactions',
      showDateRange: true,
      dateRangeText: widget.dateRange != null
          ? '${_formatShortDate(widget.dateRange!.start)} - ${_formatShortDate(widget.dateRange!.end)}'
          : 'Oct 1, 2026 - Oct 31, 2026',
      onDateRangeTap: () async {
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
      showFiltersButton: true,
      onFiltersTap: widget.onFiltersTap,
      filterControls: [
        AdminTableDropdown<String>(
          value: _methodFilterOptions.contains(widget.selectedMethod)
              ? widget.selectedMethod
              : _methodFilterOptions.first,
          items: _methodFilterOptions,
          onChanged: (val) {
            widget.onMethodChanged(val);
          },
        ),
        AdminTableDropdown<String>(
          value: _statusFilterOptions.contains(widget.selectedStatus)
              ? widget.selectedStatus
              : _statusFilterOptions.first,
          items: _statusFilterOptions,
          onChanged: (val) {
            widget.onStatusChanged(val);
          },
        ),
      ],
      headerActions: [
        if (_selectedIds.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_selectedIds.length} selected',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4338CA)),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => widget.onBulkExport?.call(_selectedIds.toList()),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.file_download_outlined, size: 13, color: Color(0xFF4338CA)),
                      SizedBox(width: 3),
                      Text('Export', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4338CA))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
      columns: [
        DataColumn(
          label: SizedBox(
            width: 20,
            child: Checkbox(
              value: _isAllSelected,
              onChanged: (val) => _toggleSelectAll(),
              activeColor: AppColors.brandPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
        const DataColumn(label: Text('#', style: _headerStyle)),
        const DataColumn(label: Text('User Details', style: _headerStyle)),
        const DataColumn(label: Text('Purpose', style: _headerStyle)),
        const DataColumn(label: Text('Amount', style: _headerStyle)),
        const DataColumn(label: Text('Payment Method', style: _headerStyle)),
        const DataColumn(label: Text('Transaction ID', style: _headerStyle)),
        const DataColumn(label: Text('Status', style: _headerStyle)),
        const DataColumn(label: Text('Date & Time', style: _headerStyle)),
        const DataColumn(label: Text('Actions', style: _headerStyle)),
      ],
      rows: widget.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isChecked = _selectedIds.contains(item.id);
        final rowNumber = (widget.currentPage - 1) * widget.rowsPerPage + index + 1;

        return DataRow(
          selected: isChecked,
          cells: [
            DataCell(
              SizedBox(
                width: 20,
                child: Checkbox(
                  value: isChecked,
                  onChanged: (val) => _toggleRow(item.id),
                  activeColor: AppColors.brandPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
            DataCell(
              Text(
                rowNumber.toString(),
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textMuted),
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: item.userAvatarBg,
                    child: Text(
                      item.userName.isNotEmpty ? item.userName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.userName,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.userEmail,
                        style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DataCell(_buildPurposeBadge(item.purpose)),
            DataCell(
              Text(
                '₹${item.amount.toInt()}',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.paymentMethod.icon, size: 14, color: item.paymentMethod.brandColor),
                  const SizedBox(width: 5),
                  Text(
                    item.paymentMethod.label,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            DataCell(
              Text(
                item.transactionId,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            DataCell(_buildStatusBadge(item.status)),
            DataCell(_buildDateTimeCell(item.dateTime)),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminTableActionButton(
                    icon: Icons.visibility_outlined,
                    tooltip: 'View Transaction',
                    onPressed: () => widget.onViewDetails(item),
                  ),
                  const SizedBox(width: 2),
                  AdminTableActionButton(
                    icon: Icons.receipt_outlined,
                    tooltip: 'View Receipt',
                    onPressed: () => widget.onViewReceipt(item),
                  ),
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTapDown: (details) => widget.onMore?.call(item, details),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.more_vert_rounded, size: 15, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
      emptyState: Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
              child: const Icon(Icons.receipt_long_outlined, size: 28, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            const Text('No Payments Found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Try adjusting your search terms or filter criteria.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopupsCard(BuildContext context) {
    final pendingCount = widget.topups.where((t) => t['status'] == 'pending').length;

    return AdminDataTableCard(
      title: 'Candidate Top-up Requests',
      totalCount: widget.topups.length,
      icon: Icons.add_circle_outline_rounded,
      iconBgColor: const Color(0xFF00B96B),
      searchQuery: _topupSearchQuery,
      searchHint: 'Search candidate or UTR...',
      onSearchChanged: (val) => setState(() => _topupSearchQuery = val),
      itemLabel: 'candidate requests',
      filterControls: [
        Container(
          height: 34,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusFilterPill('All (${widget.topups.length})', 'all', _topupStatusFilter, (v) => setState(() => _topupStatusFilter = v)),
              _buildStatusFilterPill('Pending ($pendingCount)', 'pending', _topupStatusFilter, (v) => setState(() => _topupStatusFilter = v)),
              _buildStatusFilterPill('Approved', 'approved', _topupStatusFilter, (v) => setState(() => _topupStatusFilter = v)),
            ],
          ),
        ),
      ],
      headerActions: [
        ElevatedButton.icon(
          onPressed: () => widget.onViewChanged?.call('payments'),
          icon: const Icon(Icons.arrow_back_rounded, size: 14),
          label: const Text('Back to Payments'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
      customBody: _buildTopupsTableView(),
    );
  }

  Widget _buildWithdrawalsCard(BuildContext context) {
    final pendingCount = widget.withdrawals.where((w) => w['status'] == 'pending').length;

    return AdminDataTableCard(
      title: 'Coin Payout & Redemptions',
      totalCount: widget.withdrawals.length,
      icon: Icons.arrow_outward_rounded,
      iconBgColor: const Color(0xFFD97706),
      searchQuery: _withdrawalSearchQuery,
      searchHint: 'Search candidate or UPI...',
      onSearchChanged: (val) => setState(() => _withdrawalSearchQuery = val),
      itemLabel: 'withdrawal requests',
      filterControls: [
        Container(
          height: 34,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusFilterPill('All (${widget.withdrawals.length})', 'all', _withdrawalStatusFilter, (v) => setState(() => _withdrawalStatusFilter = v)),
              _buildStatusFilterPill('Pending ($pendingCount)', 'pending', _withdrawalStatusFilter, (v) => setState(() => _withdrawalStatusFilter = v)),
              _buildStatusFilterPill('Paid', 'paid', _withdrawalStatusFilter, (v) => setState(() => _withdrawalStatusFilter = v)),
            ],
          ),
        ),
      ],
      headerActions: [
        ElevatedButton.icon(
          onPressed: () => widget.onViewChanged?.call('payments'),
          icon: const Icon(Icons.arrow_back_rounded, size: 14),
          label: const Text('Back to Payments'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
      customBody: _buildWithdrawalsTableView(),
    );
  }

  Widget _buildTopupsTableView() {
    final list = _filteredTopups;
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
              child: const Icon(Icons.account_balance_wallet_outlined, size: 28, color: Color(0xFF00B96B)),
            ),
            const SizedBox(height: 12),
            const Text('No Top-up Requests Found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('No matching coin recharge requests match your filter criteria.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth - 340).clamp(860.0, 1800.0);
    final double candidateWidth = (cardWidth * 0.22).clamp(180.0, 320.0);
    final double fixedColumnsWidth = 24.0 + 90.0 + 100.0 + 170.0 + 80.0 + 90.0 + 150.0 + 16.0;
    final double totalNeededWidth = fixedColumnsWidth + candidateWidth;
    final double remainingSpace = cardWidth - totalNeededWidth;
    final double dynamicColumnSpacing = remainingSpace > 0 ? (remainingSpace / 7).clamp(8.0, 48.0) : 8.0;
    final double tableMinWidth = cardWidth >= 860.0 ? cardWidth : 860.0;

    return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: tableMinWidth),
            child: DataTable(
              showCheckboxColumn: false,
              headingRowHeight: 40,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 56,
              horizontalMargin: 12,
              columnSpacing: dynamicColumnSpacing,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              border: const TableBorder(
                horizontalInside: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
              columns: [
                const DataColumn(label: Text('#', style: _headerStyle)),
                DataColumn(
                  label: SizedBox(
                    width: candidateWidth,
                    child: const Text('Candidate Details', style: _headerStyle),
                  ),
                ),
                const DataColumn(label: Text('Amount Paid', style: _headerStyle)),
                const DataColumn(label: Text('Coins to Credit', style: _headerStyle)),
                const DataColumn(label: Text('UPI / UTR Number', style: _headerStyle)),
                const DataColumn(label: Text('Status', style: _headerStyle)),
                const DataColumn(label: Text('Date', style: _headerStyle)),
                const DataColumn(label: Text('Actions', style: _headerStyle)),
              ],
              rows: list.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final t = entry.value;
                final isPending = t['status'] == 'pending';
                final isApproved = t['status'] == 'approved';
                final utrText = t['utr']?.toString() ?? 'N/A';

                return DataRow(
                  cells: [
                    DataCell(Text(idx.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
                    DataCell(
                      SizedBox(
                        width: candidateWidth,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: const Color(0xFFE8FAF2),
                              child: Text(
                                t['name'] != null && t['name'].toString().isNotEmpty ? t['name'][0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF00B96B)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    t['name']?.toString() ?? 'User',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    t['email']?.toString() ?? 'N/A',
                                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
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
                      Text(
                        t['amount']?.toString() ?? '₹0',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, size: 12, color: Color(0xFFD97706)),
                            const Icon(Icons.monetization_on_rounded, size: 12, color: Color(0xFFD97706)),
                            const SizedBox(width: 3),
                            Text(
                              t['coins'] ?? '0 Coins',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFD97706)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: utrText));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Copied $utrText to clipboard'),
                            duration: const Duration(seconds: 2),
                          ));
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              utrText,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.copy_rounded, size: 12, color: Color(0xFF94A3B8)),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      isPending
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.schedule_rounded, size: 11, color: Color(0xFFD97706)),
                                  SizedBox(width: 4),
                                  Text('Pending', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFD97706))),
                                ],
                              ),
                            )
                          : (isApproved
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFA7F3D0)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle_outline_rounded, size: 11, color: Color(0xFF00B96B)),
                                      SizedBox(width: 4),
                                      Text('Approved', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF00B96B))),
                                    ],
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFFECACA)),
                                  ),
                                  child: const Text('Rejected', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
                                )),
                    ),
                    DataCell(Text(t['date']?.toString() ?? 'N/A', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)))),
                    DataCell(
                      isPending
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => widget.onApproveTopup?.call(t),
                                  icon: const Icon(Icons.check_rounded, size: 12),
                                  label: const Text('Approve & Credit'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00B96B),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                    minimumSize: const Size(0, 28),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                OutlinedButton(
                                  onPressed: () => widget.onRejectTopup?.call(t),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFEF4444),
                                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                                    backgroundColor: const Color(0xFFFEF2F2),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                    minimumSize: const Size(0, 28),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  child: const Text('Reject'),
                                ),
                              ],
                            )
                          : (isApproved
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.done_all_rounded, size: 12, color: Color(0xFF00B96B)),
                                      SizedBox(width: 4),
                                      Text('Settled', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                )
                              : const Text('Rejected', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600))),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
  }

  Widget _buildWithdrawalsTableView() {
    final list = _filteredWithdrawals;
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
              child: const Icon(Icons.account_balance_wallet_outlined, size: 28, color: Color(0xFFFF9F0A)),
            ),
            const SizedBox(height: 12),
            const Text('No Withdrawal Requests Found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('No matching withdrawal redemption records match your search filter.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth - 340).clamp(860.0, 1800.0);
    final double candidateWidth = (cardWidth * 0.22).clamp(180.0, 320.0);
    final double fixedColumnsWidth = 24.0 + 100.0 + 90.0 + 170.0 + 80.0 + 90.0 + 130.0 + 16.0;
    final double totalNeededWidth = fixedColumnsWidth + candidateWidth;
    final double remainingSpace = cardWidth - totalNeededWidth;
    final double dynamicColumnSpacing = remainingSpace > 0 ? (remainingSpace / 7).clamp(8.0, 48.0) : 8.0;
    final double tableMinWidth = cardWidth >= 860.0 ? cardWidth : 860.0;

    return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: tableMinWidth),
            child: DataTable(
              showCheckboxColumn: false,
              headingRowHeight: 40,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 56,
              horizontalMargin: 12,
              columnSpacing: dynamicColumnSpacing,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              border: const TableBorder(
                horizontalInside: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
              columns: [
                const DataColumn(label: Text('#', style: _headerStyle)),
                DataColumn(
                  label: SizedBox(
                    width: candidateWidth,
                    child: const Text('Candidate Details', style: _headerStyle),
                  ),
                ),
                const DataColumn(label: Text('Coins Redeemed', style: _headerStyle)),
                const DataColumn(label: Text('Payout Amount', style: _headerStyle)),
                const DataColumn(label: Text('Candidate UPI / Bank', style: _headerStyle)),
                const DataColumn(label: Text('Status', style: _headerStyle)),
                const DataColumn(label: Text('Date', style: _headerStyle)),
                const DataColumn(label: Text('Actions', style: _headerStyle)),
              ],
              rows: list.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final w = entry.value;
                final isPending = w['status'] == 'pending';
                final isPaid = w['status'] == 'paid';
                final upiText = w['upi']?.toString() ?? 'N/A';

                return DataRow(
                  cells: [
                    DataCell(Text(idx.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
                    DataCell(
                      SizedBox(
                        width: candidateWidth,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: const Color(0xFFFEF3C7),
                              child: Text(
                                w['name'] != null && w['name'].toString().isNotEmpty ? w['name'][0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFD97706)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    w['name']?.toString() ?? 'User',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    w['email']?.toString() ?? 'N/A',
                                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.monetization_on_rounded, size: 12, color: Color(0xFFD97706)),
                            const SizedBox(width: 4),
                            Text(
                              w['coins']?.toString() ?? '0 Coins',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFD97706)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        w['rupees']?.toString() ?? '₹0',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                    ),
                    DataCell(
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: upiText));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Copied $upiText to clipboard'),
                            duration: const Duration(seconds: 2),
                          ));
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              upiText,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: Color(0xFF2563EB)),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.copy_rounded, size: 12, color: Color(0xFF94A3B8)),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      isPending
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.schedule_rounded, size: 11, color: Color(0xFFD97706)),
                                  SizedBox(width: 4),
                                  Text('Pending', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFD97706))),
                                ],
                              ),
                            )
                          : (isPaid
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFA7F3D0)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle_outline_rounded, size: 11, color: Color(0xFF00B96B)),
                                      SizedBox(width: 4),
                                      Text('Paid', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF00B96B))),
                                    ],
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFFECACA)),
                                  ),
                                  child: const Text('Rejected', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
                                )),
                    ),
                    DataCell(Text(w['date']?.toString() ?? 'N/A', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)))),
                    DataCell(
                      isPending
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => widget.onPayoutWithdrawal?.call(w),
                                  icon: const Icon(Icons.check_rounded, size: 12),
                                  label: const Text('Pay'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00B96B),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                    minimumSize: const Size(0, 28),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                OutlinedButton(
                                  onPressed: () => widget.onRejectWithdrawal?.call(w),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFEF4444),
                                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                                    backgroundColor: const Color(0xFFFEF2F2),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                    minimumSize: const Size(0, 28),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  child: const Text('Reject'),
                                ),
                              ],
                            )
                          : (isPaid
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.done_all_rounded, size: 12, color: Color(0xFF00B96B)),
                                      SizedBox(width: 4),
                                      Text('Settled', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                )
                              : const Text('Rejected', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600))),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
  }

  Widget _buildPurposeBadge(PaymentPurpose purpose) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: purpose.backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: purpose.borderColor, width: 0.8),
      ),
      child: Text(
        purpose.label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: purpose.textColor,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }

  Widget _buildDateTimeCell(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final timeStr = '${hour.toString().padLeft(2, '0')}:$minuteStr $period';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateStr,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        ),
        Text(
          timeStr,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  static String _formatShortDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
