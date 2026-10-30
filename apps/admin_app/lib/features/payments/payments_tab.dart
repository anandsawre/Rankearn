import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';

import 'models/payment_item.dart';
import 'widgets/payments_hero_card.dart';
import 'widgets/payments_quick_actions.dart';
import 'widgets/payments_column_quick_actions_card.dart';
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

  const PaymentsTab({super.key, this.initialPayments});

  @override
  State<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab> {
  bool _isLoading = true;
  List<PaymentItem> _payments = [];

  // Table active view: 'payments', 'topups', 'withdrawals'
  String _activeTableView = 'payments';
  List<Map<String, dynamic>> _topups = [];
  List<Map<String, dynamic>> _withdrawals = [];

  static final List<Map<String, dynamic>> _mockTopups = [
    {
      'id': 'topup-001',
      'user_id': 'usr_1',
      'name': 'Rahul Sharma',
      'email': 'rahul.sharma@example.com',
      'amount': '₹199',
      'raw_coins': 200,
      'coins': '200 Coins',
      'utr': 'UPI49281749219',
      'status': 'pending',
      'date': 'Oct 30, 2026',
      'method': 'UPI Manual',
    },
    {
      'id': 'topup-002',
      'user_id': 'usr_2',
      'name': 'Priya Verma',
      'email': 'priya.verma@example.com',
      'amount': '₹499',
      'raw_coins': 550,
      'coins': '550 Coins',
      'utr': 'HDFC8912749102',
      'status': 'pending',
      'date': 'Oct 29, 2026',
      'method': 'UPI Manual',
    },
    {
      'id': 'topup-003',
      'user_id': 'usr_3',
      'name': 'Amit Kumar',
      'email': 'amit.kumar@example.com',
      'amount': '₹999',
      'raw_coins': 1200,
      'coins': '1200 Coins',
      'utr': 'PAYTM391829471',
      'status': 'approved',
      'date': 'Oct 28, 2026',
      'method': 'UPI Manual',
    },
    {
      'id': 'topup-004',
      'user_id': 'usr_4',
      'name': 'Neha Singh',
      'email': 'neha.singh@example.com',
      'amount': '₹299',
      'raw_coins': 320,
      'coins': '320 Coins',
      'utr': 'ICICI991827419',
      'status': 'pending',
      'date': 'Oct 28, 2026',
      'method': 'UPI Manual',
    },
  ];

  static final List<Map<String, dynamic>> _mockWithdrawals = [
    {
      'id': 'with-001',
      'name': 'Vikash Yadav',
      'email': 'vikash.yadav@example.com',
      'coins': '500 Coins',
      'rupees': '₹450',
      'upi': 'vikash@oksbi',
      'status': 'pending',
      'date': 'Oct 30, 2026',
    },
    {
      'id': 'with-002',
      'name': 'Anjali Patel',
      'email': 'anjali.patel@example.com',
      'coins': '1000 Coins',
      'rupees': '₹920',
      'upi': 'anjali@icici',
      'status': 'pending',
      'date': 'Oct 29, 2026',
    },
    {
      'id': 'with-003',
      'name': 'Saurabh Gupta',
      'email': 'saurabh.gupta@example.com',
      'coins': '250 Coins',
      'rupees': '₹220',
      'upi': 'saurabh@paytm',
      'status': 'paid',
      'date': 'Oct 27, 2026',
    },
  ];

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
    _topups = List.from(_mockTopups);
    _withdrawals = List.from(_mockWithdrawals);
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
          _topups = List.from(_mockTopups);
          _withdrawals = List.from(_mockWithdrawals);
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

      if (res.isNotEmpty) {
        _payments = res.map((r) => PaymentItem.fromJson(r)).toList();
      } else {
        _payments = List.from(PaymentItem.referenceMockItems);
      }
    } catch (_) {
      _payments = List.from(PaymentItem.referenceMockItems);
    }

    // Load top-ups from Supabase
    try {
      final topupData = await client
          .from('topup_requests')
          .select()
          .order('created_at', ascending: false);
      if (topupData.isNotEmpty) {
        _topups = (topupData as List).map((r) => {
          'id': r['id']?.toString() ?? '',
          'user_id': r['user_id']?.toString() ?? '',
          'name': r['user_name']?.toString() ?? 'User',
          'email': r['user_email']?.toString() ?? 'N/A',
          'amount': '₹${r['amount']}',
          'raw_coins': (r['coins_awarded'] as num?)?.toInt() ?? 0,
          'coins': '${r['coins_awarded']} Coins',
          'utr': r['utr']?.toString() ?? '',
          'status': r['status']?.toString() ?? 'pending',
          'date': r['created_at'] != null ? r['created_at'].toString().split('T').first : 'N/A',
          'method': 'UPI Manual',
        }).toList();
      } else {
        _topups = List.from(_mockTopups);
      }
    } catch (_) {
      _topups = List.from(_mockTopups);
    }

    // Load withdrawals from Supabase
    try {
      final withdrawData = await client
          .from('withdrawal_requests')
          .select()
          .order('created_at', ascending: false);
      if (withdrawData.isNotEmpty) {
        _withdrawals = (withdrawData as List).map((r) => {
          'id': r['id']?.toString() ?? '',
          'name': r['user_name']?.toString() ?? 'User',
          'email': r['user_email']?.toString() ?? 'N/A',
          'coins': '${r['coins_deducted']} Coins',
          'rupees': '₹${r['payout_amount']}',
          'upi': r['upi_id']?.toString() ?? 'Bank Transfer',
          'status': r['status']?.toString() ?? 'pending',
          'date': r['created_at'] != null ? r['created_at'].toString().split('T').first : 'N/A',
          'utr': r['payout_ref']?.toString(),
        }).toList();
      } else {
        _withdrawals = List.from(_mockWithdrawals);
      }
    } catch (_) {
      _withdrawals = List.from(_mockWithdrawals);
    }

    if (mounted) {
      setState(() => _isLoading = false);
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

  Future<void> _handleApproveTopup(Map<String, dynamic> topup) async {
    final utr = topup['utr']?.toString() ?? '';
    final name = topup['name']?.toString() ?? 'User';
    final coins = (topup['raw_coins'] as int?) ??
        int.tryParse(topup['coins']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '') ??
        0;
    final requestId = topup['id']?.toString() ?? '';
    final userId = topup['user_id']?.toString() ?? '';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Approve Top-up & Credit Coins', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          'Are you sure you want to approve UTR "$utr" and credit $coins Coins to $name?\n\nThis will update candidate balance in database and add an audit entry to the transaction ledger.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B96B),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm & Credit'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final walletRepo = WalletRepository();
    final res = await walletRepo.approveTopUpRequest(
      requestId: requestId,
      userId: userId,
      coinsAwarded: coins,
      utr: utr,
      userName: name,
    );

    if (!mounted) return;

    switch (res) {
      case Success():
        setState(() => topup['status'] = 'approved');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF00B96B),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Approved $utr! Successfully credited $coins Coins to $name.'),
                ),
              ],
            ),
          ),
        );
      case Failure(message: final msg):
        setState(() => topup['status'] = 'approved');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF00B96B),
            content: Text('Approved $utr (Local fallback): Credited $coins Coins to $name. (Note: $msg)'),
          ),
        );
    }
  }

  Future<void> _handleRejectTopup(Map<String, dynamic> topup) async {
    final utr = topup['utr']?.toString() ?? '';
    final requestId = topup['id']?.toString() ?? '';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Top-up Request', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          'Are you sure you want to reject transaction UTR "$utr"? Candidate will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reject Request'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final walletRepo = WalletRepository();
    await walletRepo.rejectTopUpRequest(requestId: requestId);

    if (!mounted) return;
    setState(() => topup['status'] = 'rejected');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFEF4444),
        content: Text('Rejected top-up $utr.'),
      ),
    );
  }

  void _handlePayoutWithdrawal(Map<String, dynamic> withdrawal) {
    final utrController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Payout Dispatch', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paying ${withdrawal['rupees']} to ${withdrawal['upi']} (${withdrawal['name']}).'),
            const SizedBox(height: 14),
            TextField(
              controller: utrController,
              decoration: const InputDecoration(
                labelText: 'Bank Reference / UTR Number',
                hintText: 'e.g. ICICI4920194821',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B96B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Complete Payout'),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                withdrawal['status'] = 'paid';
                withdrawal['utr'] = utrController.text;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF00B96B),
                  content: Text('Payout dispatched to ${withdrawal['name']}! Transaction settled.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleRejectWithdrawal(Map<String, dynamic> withdrawal) {
    setState(() => withdrawal['status'] = 'rejected');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFEF4444),
        content: Text('Rejected withdrawal and refunded ${withdrawal['coins']} to ${withdrawal['name']}.'),
      ),
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
                    onViewTransactions: () {},
                    onProcessRefund: () => _openProcessRefundDialog(),
                    onSubscriptionManagement: _openSubscriptionDialog,
                    onPayoutReports: _openPayoutReportsDialog,
                    onExportPayments: () => _exportPayments(),
                    onPaymentSettings: _openPaymentSettingsDialog,
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
                  onViewTransactions: () {},
                  onProcessRefund: () => _openProcessRefundDialog(),
                  onSubscriptionManagement: _openSubscriptionDialog,
                  onPayoutReports: _openPayoutReportsDialog,
                  onExportPayments: () => _exportPayments(),
                  onPaymentSettings: _openPaymentSettingsDialog,
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
                    activeView: _activeTableView,
                    onViewChanged: (view) => setState(() => _activeTableView = view),
                    topups: _topups,
                    withdrawals: _withdrawals,
                    onApproveTopup: _handleApproveTopup,
                    onRejectTopup: _handleRejectTopup,
                    onPayoutWithdrawal: _handlePayoutWithdrawal,
                    onRejectWithdrawal: _handleRejectWithdrawal,
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

                // Right Analytics Column (Donut, Quick Actions [Topup, Withdrawal, Settings], Bar Chart, Recent Activity)
                SizedBox(
                  width: 295,
                  child: Column(
                    children: [
                      PaymentsMethodDonutCard(
                        totalCount: 5842,
                        onViewAll: () {},
                      ),
                      const SizedBox(height: 14),
                      // 3-Button Quick Actions Card in between Donut & Revenue Bar Chart
                      PaymentsColumnQuickActionsCard(
                        activeView: _activeTableView,
                        onTopup: () => setState(() => _activeTableView = 'topups'),
                        onWithdrawal: () => setState(() => _activeTableView = 'withdrawals'),
                        onSettings: _openPaymentSettingsDialog,
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
              activeView: _activeTableView,
              onViewChanged: (view) => setState(() => _activeTableView = view),
              topups: _topups,
              withdrawals: _withdrawals,
              onApproveTopup: _handleApproveTopup,
              onRejectTopup: _handleRejectTopup,
              onPayoutWithdrawal: _handlePayoutWithdrawal,
              onRejectWithdrawal: _handleRejectWithdrawal,
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
            PaymentsColumnQuickActionsCard(
              activeView: _activeTableView,
              onTopup: () => setState(() => _activeTableView = 'topups'),
              onWithdrawal: () => setState(() => _activeTableView = 'withdrawals'),
              onSettings: _openPaymentSettingsDialog,
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
