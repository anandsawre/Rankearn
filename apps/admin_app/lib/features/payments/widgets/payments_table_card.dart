import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/payment_item.dart';

/// Pixel-accurate Payments Data Table Card matching the reference image.
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
  });

  @override
  State<PaymentsTableCard> createState() => _PaymentsTableCardState();
}

class _PaymentsTableCardState extends State<PaymentsTableCard> {
  final Set<String> _selectedIds = {};
  late TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();

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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant PaymentsTableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Toolbar
          _buildToolbar(context),
          const SizedBox(height: 12),

          // Bulk action notification bar if items selected
          if (_selectedIds.isNotEmpty) ...[
            _buildBulkActionBar(),
            const SizedBox(height: 12),
          ],

          // 2. Data Table
          _buildTable(),
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
            color: const Color(0xFF2587F8),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
            size: 15,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Payments List (${_formatNumber(widget.totalCount)})',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF101A3A),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );

    final controls = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Search Input
        SizedBox(
          width: isCompact ? 160 : 250,
          height: 34,
          child: TextField(
            controller: _searchController,
            onChanged: widget.onSearchChanged,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search by user, transaction ID, or purpose...',
              hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded, size: 15, color: AppColors.textSecondary),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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

        // Method Filter Dropdown
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _methodFilterOptions.contains(widget.selectedMethod)
                  ? widget.selectedMethod
                  : _methodFilterOptions.first,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: AppColors.textSecondary),
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              onChanged: (val) {
                if (val != null) widget.onMethodChanged(val);
              },
              items: _methodFilterOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
            ),
          ),
        ),

        // Status Filter Dropdown
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _statusFilterOptions.contains(widget.selectedStatus)
                  ? widget.selectedStatus
                  : _statusFilterOptions.first,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: AppColors.textSecondary),
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              onChanged: (val) {
                if (val != null) widget.onStatusChanged(val);
              },
              items: _statusFilterOptions.map((opt) {
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
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  widget.dateRange != null
                      ? '${_formatShortDate(widget.dateRange!.start)} - ${_formatShortDate(widget.dateRange!.end)}'
                      : 'Oct 1, 2026 - Oct 31, 2026',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        ),

        // Filters Button
        InkWell(
          onTap: widget.onFiltersTap ?? () {},
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 34,
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
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
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
          controls,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerTitle,
        const SizedBox(width: 16),
        Flexible(child: controls),
      ],
    );
  }

  Widget _buildBulkActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedIds.length} transaction(s) selected',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4338CA),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              widget.onBulkExport?.call(_selectedIds.toList());
            },
            icon: const Icon(Icons.file_download_outlined, size: 14, color: Color(0xFF4338CA)),
            label: const Text('Export Selected', style: TextStyle(fontSize: 11.5, color: Color(0xFF4338CA))),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    if (widget.items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_outlined, size: 28, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Payments Found',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try adjusting your search terms or filter criteria.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        // Proportional user details column
        final double userDetailsWidth = (cardWidth * 0.22).clamp(180.0, 340.0);
        // Fixed widths for other columns + margins:
        // Checkbox(24) + #(20) + Purpose(90) + Amount(70) + Method(100) + TxId(110) + Status(75) + DateTime(90) + Actions(95) + margins(16) = 690
        const double fixedColumnsWidth = 24.0 + 20.0 + 90.0 + 70.0 + 100.0 + 110.0 + 75.0 + 90.0 + 95.0 + 16.0;
        final double totalNeededWidth = fixedColumnsWidth + userDetailsWidth;
        final double remainingSpace = cardWidth - totalNeededWidth;
        // Distribute remaining width across the 9 column gaps
        final double dynamicColumnSpacing = remainingSpace > 0 ? (remainingSpace / 9).clamp(6.0, 48.0) : 6.0;
        final double tableMinWidth = cardWidth >= 860.0 ? cardWidth : 860.0;

        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: tableMinWidth),
            child: DataTable(
              showCheckboxColumn: false,
              headingRowHeight: 38,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 52,
              horizontalMargin: 8,
              columnSpacing: dynamicColumnSpacing,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              border: const TableBorder(
                horizontalInside: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
              columns: [
                // 1. Checkbox
                DataColumn(
                  label: SizedBox(
                    width: 24,
                    child: Checkbox(
                      value: _isAllSelected,
                      onChanged: (val) => _toggleSelectAll(),
                      activeColor: const Color(0xFF5636F5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),

                // 2. #
                const DataColumn(
                  label: Text(
                    '#',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ),

                // 3. User Details
                DataColumn(
                  label: SizedBox(
                    width: userDetailsWidth,
                    child: const Text(
                      'User Details',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),
                ),

                // 4. Purpose
                const DataColumn(
                  label: Text(
                    'Purpose',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ),

                // 5. Amount
                const DataColumn(
                  label: Text(
                    'Amount',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ),

                // 6. Payment Method
                const DataColumn(
                  label: Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ),

                // 7. Transaction ID
                const DataColumn(
                  label: Text(
                    'Transaction ID',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ),

                // 8. Status
                const DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ),

                // 9. Date & Time
                const DataColumn(
                  label: Text(
                    'Date & Time',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ),

                // 10. Actions
                const DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ),
              ],
              rows: widget.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isChecked = _selectedIds.contains(item.id);
                final rowNumber = (widget.currentPage - 1) * widget.rowsPerPage + index + 1;

                return DataRow(
                  selected: isChecked,
                  onSelectChanged: (selected) {
                    _toggleRow(item.id);
                  },
                  cells: [
                    // 1. Checkbox
                    DataCell(
                      SizedBox(
                        width: 24,
                        child: Checkbox(
                          value: isChecked,
                          onChanged: (val) => _toggleRow(item.id),
                          activeColor: const Color(0xFF5636F5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),

                    // 2. Row Number
                    DataCell(
                      Text(
                        rowNumber.toString(),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                      ),
                    ),

                    // 3. User Details
                    DataCell(
                      SizedBox(
                        width: userDetailsWidth,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: item.userAvatarBg,
                              child: Text(
                                item.userName.isNotEmpty ? item.userName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.userName,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    item.userEmail,
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textMuted,
                                    ),
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

                    // 4. Purpose
                    DataCell(_buildPurposeBadge(item.purpose)),

                    // 5. Amount
                    DataCell(
                      Text(
                        '₹${item.amount.toInt()}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101A3A),
                        ),
                      ),
                    ),

                    // 6. Payment Method
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.paymentMethod.icon,
                            size: 14,
                            color: item.paymentMethod.brandColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.paymentMethod.label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 7. Transaction ID
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

                    // 8. Status
                    DataCell(_buildStatusBadge(item.status)),

                    // 9. Date & Time
                    DataCell(_buildDateTimeCell(item.dateTime)),

                    // 10. Actions
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // View Details
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined, size: 15, color: AppColors.textSecondary),
                            onPressed: () => widget.onViewDetails(item),
                            tooltip: 'View Transaction',
                            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 2),

                          // View Receipt / Invoice
                          IconButton(
                            icon: const Icon(Icons.receipt_outlined, size: 15, color: AppColors.textSecondary),
                            onPressed: () => widget.onViewReceipt(item),
                            tooltip: 'View Receipt',
                            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 2),

                          // More
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
            ),
          ),
        );
      },
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

  Widget _buildFooter() {
    final startItem = widget.items.isEmpty ? 0 : (widget.currentPage - 1) * widget.rowsPerPage + 1;
    final endItem = math.min(widget.currentPage * widget.rowsPerPage, widget.totalCount);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        // Left: Showing X to Y of Z transactions
        Text(
          'Showing $startItem to $endItem of ${_formatNumber(widget.totalCount)} transactions',
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),

        // Center: Pagination Buttons (< 1 2 3 ... >)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Previous
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 16),
              onPressed: widget.currentPage > 1
                  ? () => widget.onPageChanged(widget.currentPage - 1)
                  : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
            const SizedBox(width: 2),

            // Pages (1, 2, 3, 4, 5 ... 835)
            ..._buildPaginationNumbers(),

            const SizedBox(width: 2),
            // Next
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 16),
              onPressed: widget.currentPage < widget.totalPages
                  ? () => widget.onPageChanged(widget.currentPage + 1)
                  : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),

        // Right: Show 10 per page
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Show ', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: widget.rowsPerPage,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textSecondary),
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  onChanged: (val) {
                    if (val != null) widget.onRowsPerPageChanged(val);
                  },
                  items: [5, 10, 20, 50]
                      .map((n) => DropdownMenuItem(value: n, child: Text(n.toString())))
                      .toList(),
                ),
              ),
            ),
            const Text(' per page', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildPaginationNumbers() {
    final widgets = <Widget>[];
    final pages = <int>[];

    if (widget.totalPages <= 5) {
      for (int i = 1; i <= widget.totalPages; i++) {
        pages.add(i);
      }
    } else {
      pages.addAll([1, 2, 3, 4, 5]);
    }

    for (final p in pages) {
      final isCurrent = p == widget.currentPage;
      widgets.add(
        InkWell(
          onTap: () => widget.onPageChanged(p),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCurrent ? const Color(0xFF5636F5) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              p.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isCurrent ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(width: 2));
    }

    if (widget.totalPages > 5) {
      widgets.add(
        const Text('...', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      );
      widgets.add(const SizedBox(width: 2));
      final lastPage = widget.totalPages;
      final isLastCurrent = lastPage == widget.currentPage;
      widgets.add(
        InkWell(
          onTap: () => widget.onPageChanged(lastPage),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isLastCurrent ? const Color(0xFF5636F5) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              lastPage.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isLastCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isLastCurrent ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
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

  static String _formatShortDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
