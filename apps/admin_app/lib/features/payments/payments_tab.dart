import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';

import 'models/payment_item.dart';
import 'widgets/payments_hero_card.dart';
import 'widgets/payments_quick_actions.dart';
import 'widgets/payments_metrics_row.dart';
import 'widgets/payments_table_card.dart';
import 'widgets/payments_method_donut_card.dart';
import 'widgets/payments_revenue_bar_chart_card.dart';
import 'widgets/payments_recent_activity_card.dart';

import 'dialogs/payment_details_dialog.dart';
import 'dialogs/process_refund_dialog.dart';
import 'dialogs/subscription_management_dialog.dart';
import 'dialogs/payout_reports_dialog.dart';
import 'dialogs/payment_settings_dialog.dart';
import 'dialogs/payment_receipt_dialog.dart';

/// Payments Management Tab
/// Pixel-accurate implementation matching the Rankearn reference design.
class PaymentsTab extends StatefulWidget {
  final List<PaymentItem>? initialPayments;
  final VoidCallback? onGoToTopups;
  final VoidCallback? onGoToWithdrawals;
  final VoidCallback? onGoToSettings;

  const PaymentsTab({
    super.key,
    this.initialPayments,
    this.onGoToTopups,
    this.onGoToWithdrawals,
    this.onGoToSettings,
  });

  @override
  State<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab> {
  bool _isLoading = true;
  List<PaymentItem> _payments = [];

  // Filter States
  String _searchQuery = '';
  String _selectedMethod = 'All Payment Methods';
  String _selectedStatus = 'All Status';
  DateTimeRange? _dateRange;

  // Pagination States
  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    if (widget.initialPayments != null) {
      _payments = List.from(widget.initialPayments!);
      _isLoading = false;
    } else {
      _loadPayments();
    }
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) {
        setState(() {
          _payments = List.from(PaymentItem.referenceMockItems);
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final res = await client
          .from('payments')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;
      if (res.isNotEmpty) {
        setState(() {
          _payments = res.map((r) => PaymentItem.fromJson(r)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _payments = List.from(PaymentItem.referenceMockItems);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _payments = List.from(PaymentItem.referenceMockItems);
        _isLoading = false;
      });
    }
  }

  // Filter Logic
  List<PaymentItem> get _filteredPayments {
    return _payments.where((p) {
      // Search
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matchUser = p.userName.toLowerCase().contains(q);
        final matchEmail = p.userEmail.toLowerCase().contains(q);
        final matchTx = p.transactionId.toLowerCase().contains(q);
        final matchPurpose = p.purpose.label.toLowerCase().contains(q);
        if (!matchUser && !matchEmail && !matchTx && !matchPurpose) {
          return false;
        }
      }

      // Method
      if (_selectedMethod != 'All Payment Methods') {
        if (p.paymentMethod.label.toLowerCase() != _selectedMethod.toLowerCase()) {
          return false;
        }
      }

      // Status
      if (_selectedStatus != 'All Status') {
        if (p.status.label.toLowerCase() != _selectedStatus.toLowerCase()) {
          return false;
        }
      }

      // Date Range
      if (_dateRange != null) {
        final start = DateTime(_dateRange!.start.year, _dateRange!.start.month, _dateRange!.start.day);
        final end = DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day, 23, 59, 59);
        if (p.dateTime.isBefore(start) || p.dateTime.isAfter(end)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  int get _totalPages => math.max(1, (_filteredPayments.length / _rowsPerPage).ceil());

  List<PaymentItem> get _paginatedPayments {
    final start = (_currentPage - 1) * _rowsPerPage;
    if (start >= _filteredPayments.length) return [];
    final end = math.min(start + _rowsPerPage, _filteredPayments.length);
    return _filteredPayments.sublist(start, end);
  }

  // Dialog Handlers
  void _openDetailsDialog(PaymentItem item) {
    showDialog(
      context: context,
      builder: (ctx) => PaymentDetailsDialog(
        payment: item,
        onProcessRefund: () {
          Navigator.of(ctx).pop();
          _openProcessRefundDialog(initialPayment: item);
        },
        onViewReceipt: () {
          Navigator.of(ctx).pop();
          _openReceiptDialog(item);
        },
      ),
    );
  }

  void _openProcessRefundDialog({PaymentItem? initialPayment}) {
    showDialog(
      context: context,
      builder: (ctx) => ProcessRefundDialog(
        initialPayment: initialPayment,
        availablePayments: _payments.where((p) => p.status == PaymentStatus.success).toList(),
        onConfirmRefund: (payment, refundAmount, reason) async {
          setState(() {
            final idx = _payments.indexWhere((p) => p.id == payment.id);
            if (idx != -1) {
              final isPartial = refundAmount < payment.amount;
              _payments[idx] = payment.copyWith(
                status: isPartial ? PaymentStatus.partiallyRefunded : PaymentStatus.refunded,
                refundAmount: refundAmount,
                refundReason: reason,
                refundDate: DateTime.now(),
              );
            }
          });
        },
      ),
    );
  }

  void _openReceiptDialog(PaymentItem item) {
    showDialog(
      context: context,
      builder: (ctx) => PaymentReceiptDialog(payment: item),
    );
  }

  void _openSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => const SubscriptionManagementDialog(),
    );
  }

  void _openPayoutReportsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => const PayoutReportsDialog(),
    );
  }

  void _openPaymentSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => const PaymentSettingsDialog(),
    );
  }

  void _exportPayments([List<String>? selectedIds]) {
    final count = selectedIds != null && selectedIds.isNotEmpty
        ? selectedIds.length
        : _filteredPayments.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting $count payment transaction records to CSV...'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _showMoreContextMenu(PaymentItem item, TapDownDetails details) {
    final offset = details.globalPosition;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx + 1, offset.dy + 1),
      items: [
        const PopupMenuItem(value: 'view', child: Text('View Details')),
        const PopupMenuItem(value: 'receipt', child: Text('View Receipt')),
        if (item.status == PaymentStatus.success)
          const PopupMenuItem(value: 'refund', child: Text('Process Refund')),
        const PopupMenuItem(value: 'audit', child: Text('View Audit Log')),
      ],
    ).then((val) {
      if (!mounted) return;
      if (val == 'view') {
        _openDetailsDialog(item);
      } else if (val == 'receipt') {
        _openReceiptDialog(item);
      } else if (val == 'refund') {
        _openProcessRefundDialog(initialPayment: item);
      } else if (val == 'audit') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audit log for ${item.transactionId} loaded.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;
    final isWideHeader = screenWidth >= 960;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF5636F5)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Section: Hero Banner + Quick Actions Row
          if (isWideHeader)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 7,
                  child: PaymentsHeroCard(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 5,
                  child: PaymentsQuickActions(
                    onTopups: widget.onGoToTopups ?? () {},
                    onWithdrawals: widget.onGoToWithdrawals ?? () {},
                    onSettings: widget.onGoToSettings ?? _openPaymentSettingsDialog,
                    onViewTransactions: () {},
                    onProcessRefund: () => _openProcessRefundDialog(),
                    onSubscriptionManagement: _openSubscriptionDialog,
                    onPayoutReports: _openPayoutReportsDialog,
                    onExportPayments: () => _exportPayments(),
                    onCustomize: () {},
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                const PaymentsHeroCard(),
                const SizedBox(height: 12),
                PaymentsQuickActions(
                  onTopups: widget.onGoToTopups ?? () {},
                  onWithdrawals: widget.onGoToWithdrawals ?? () {},
                  onSettings: widget.onGoToSettings ?? _openPaymentSettingsDialog,
                  onViewTransactions: () {},
                  onProcessRefund: () => _openProcessRefundDialog(),
                  onSubscriptionManagement: _openSubscriptionDialog,
                  onPayoutReports: _openPayoutReportsDialog,
                  onExportPayments: () => _exportPayments(),
                  onCustomize: () {},
                ),
              ],
            ),
          const SizedBox(height: 14),

          // 2. Metrics Cards Row (5 Cards)
          PaymentsMetricsRow(
            totalRevenue: 1245780,
            totalTransactions: 5842,
            successfulPayments: 5621,
            failedPayments: 221,
            pendingPayments: 48,
          ),
          const SizedBox(height: 14),

          // 3. Main Content: Table Card on Left + Analytics Column on Right
          if (isDesktop) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Table Card
                Expanded(
                  child: PaymentsTableCard(
                    items: _paginatedPayments,
                    totalCount: _filteredPayments.length,
                    selectedMethod: _selectedMethod,
                    selectedStatus: _selectedStatus,
                    searchQuery: _searchQuery,
                    dateRange: _dateRange,
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    rowsPerPage: _rowsPerPage,
                    onMethodChanged: (m) => setState(() {
                      _selectedMethod = m;
                      _currentPage = 1;
                    }),
                    onStatusChanged: (status) => setState(() {
                      _selectedStatus = status;
                      _currentPage = 1;
                    }),
                    onSearchChanged: (q) => setState(() {
                      _searchQuery = q;
                      _currentPage = 1;
                    }),
                    onDateRangeChanged: (range) => setState(() {
                      _dateRange = range;
                      _currentPage = 1;
                    }),
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    onRowsPerPageChanged: (rpp) => setState(() {
                      _rowsPerPage = rpp;
                      _currentPage = 1;
                    }),
                    onViewDetails: _openDetailsDialog,
                    onViewReceipt: _openReceiptDialog,
                    onMore: _showMoreContextMenu,
                    onBulkExport: (ids) => _exportPayments(ids),
                    onFiltersTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Advanced filters panel opened')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),

                // Right Analytics Column (3 Cards: Donut, Bar Chart, Recent Activity)
                SizedBox(
                  width: 295,
                  child: Column(
                    children: [
                      PaymentsMethodDonutCard(
                        totalCount: 5842,
                        onViewAll: () {},
                      ),
                      const SizedBox(height: 14),
                      PaymentsRevenueBarChartCard(
                        onViewAll: () {},
                      ),
                      const SizedBox(height: 14),
                      PaymentsRecentActivityCard(
                        onViewAll: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            // Tablet/Mobile Stack
            PaymentsTableCard(
              items: _paginatedPayments,
              totalCount: _filteredPayments.length,
              selectedMethod: _selectedMethod,
              selectedStatus: _selectedStatus,
              searchQuery: _searchQuery,
              dateRange: _dateRange,
              currentPage: _currentPage,
              totalPages: _totalPages,
              rowsPerPage: _rowsPerPage,
              onMethodChanged: (m) => setState(() {
                _selectedMethod = m;
                _currentPage = 1;
              }),
              onStatusChanged: (status) => setState(() {
                _selectedStatus = status;
                _currentPage = 1;
              }),
              onSearchChanged: (q) => setState(() {
                _searchQuery = q;
                _currentPage = 1;
              }),
              onDateRangeChanged: (range) => setState(() {
                _dateRange = range;
                _currentPage = 1;
              }),
              onPageChanged: (page) => setState(() => _currentPage = page),
              onRowsPerPageChanged: (rpp) => setState(() {
                _rowsPerPage = rpp;
                _currentPage = 1;
              }),
              onViewDetails: _openDetailsDialog,
              onViewReceipt: _openReceiptDialog,
              onMore: _showMoreContextMenu,
              onBulkExport: (ids) => _exportPayments(ids),
            ),
            const SizedBox(height: 14),
            PaymentsMethodDonutCard(
              totalCount: 5842,
              onViewAll: () {},
            ),
            const SizedBox(height: 14),
            PaymentsRevenueBarChartCard(
              onViewAll: () {},
            ),
            const SizedBox(height: 14),
            PaymentsRecentActivityCard(
              onViewAll: () {},
            ),
          ],
        ],
      ),
    );
  }
}
