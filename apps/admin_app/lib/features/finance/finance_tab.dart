import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class FinanceTab extends StatefulWidget {
  const FinanceTab({super.key});

  @override
  State<FinanceTab> createState() => _FinanceTabState();
}

enum _FinanceSubTab { topups, withdrawals, settings }

class _FinanceTabState extends State<FinanceTab> {
  _FinanceSubTab _activeSubTab = _FinanceSubTab.topups;
  String _filterType = 'pending'; // 'pending' or 'history'

  // Mock initial dataset matching React Admin
  final List<Map<String, dynamic>> _topups = [
    {
      'id': 'topup-1',
      'name': 'Anjali Kumari',
      'email': 'anjali.k@gmail.com',
      'amount': '₹250.00',
      'coins': '5,000 Coins',
      'utr': 'UTR349102847192',
      'status': 'pending',
      'date': 'Today, 10:45 AM',
      'method': 'Google Pay UPI',
    },
    {
      'id': 'topup-2',
      'name': 'Manish Kumar',
      'email': 'manish.k99@yahoo.com',
      'amount': '₹100.00',
      'coins': '2,000 Coins',
      'utr': 'UTR492019385721',
      'status': 'pending',
      'date': 'Today, 09:12 AM',
      'method': 'PhonePe UPI',
    },
    {
      'id': 'topup-3',
      'name': 'Suresh Patil',
      'email': 'suresh.patil@outlook.com',
      'amount': '₹500.00',
      'coins': '10,000 Coins',
      'utr': 'UTR593019284719',
      'status': 'pending',
      'date': 'Yesterday, 06:30 PM',
      'method': 'Paytm UPI',
    },
    {
      'id': 'topup-4',
      'name': 'Pooja Verma',
      'email': 'pooja.verma@gmail.com',
      'amount': '₹1,000.00',
      'coins': '20,000 Coins',
      'utr': 'UTR883920192847',
      'status': 'approved',
      'date': 'Yesterday, 02:15 PM',
      'method': 'BHIM UPI',
    },
  ];

  final List<Map<String, dynamic>> _withdrawals = [
    {
      'id': 'w-1',
      'name': 'Ramesh Chandra',
      'email': 'ramesh.c@gmail.com',
      'coins': '4,000 Coins',
      'rupees': '₹200.00',
      'upi': 'ramesh@oksbi',
      'status': 'pending',
      'date': 'Today, 11:15 AM',
    },
    {
      'id': 'w-2',
      'name': 'Priya Singh',
      'email': 'priya.s@gmail.com',
      'coins': '2,500 Coins',
      'rupees': '₹125.00',
      'upi': 'priyasingh@paytm',
      'status': 'pending',
      'date': 'Today, 08:30 AM',
    },
    {
      'id': 'w-3',
      'name': 'Vikram Rathore',
      'email': 'vikram.r@gmail.com',
      'coins': '10,000 Coins',
      'rupees': '₹500.00',
      'upi': 'rathore@ybl',
      'status': 'paid',
      'date': 'Yesterday, 04:20 PM',
      'utr': 'PAYOUT-883921029',
    },
  ];

  // Settings state
  late final TextEditingController _upiIdController;
  late final TextEditingController _merchantNameController;
  late final TextEditingController _minDepositController;
  late final TextEditingController _minWithdrawalController;
  late final TextEditingController _dailyLimitController;

  @override
  void initState() {
    super.initState();
    _upiIdController = TextEditingController(text: 'rankearn.pay@icici');
    _merchantNameController = TextEditingController(text: 'Rankearn Technologies');
    _minDepositController = TextEditingController(text: '50');
    _minWithdrawalController = TextEditingController(text: '1000');
    _dailyLimitController = TextEditingController(text: '50000');
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    _merchantNameController.dispose();
    _minDepositController.dispose();
    _minWithdrawalController.dispose();
    _dailyLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unified Master Header matching React
          _buildMasterHeader(),
          const SizedBox(height: 20),

          // Subtab view switch
          switch (_activeSubTab) {
            _FinanceSubTab.topups => _buildTopupsView(),
            _FinanceSubTab.withdrawals => _buildWithdrawalsView(),
            _FinanceSubTab.settings => _buildSettingsView(),
          },
        ],
      ),
    );
  }

  Widget _buildMasterHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary,
                      borderRadius: AppRadii.borderLg,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandPrimary.withAlpha(60),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.currency_rupee, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Finance Management', style: AppTypography.displayMedium),
                      const SizedBox(height: 2),
                      Text(
                        _activeSubTab == _FinanceSubTab.settings
                            ? 'Configure Payment Rules & Gateways'
                            : (_activeSubTab == _FinanceSubTab.topups
                                ? 'Verify Manual UPI Candidate Top-ups'
                                : 'Process Coin Payout Redemptions'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),

              // Sub-navigation pills
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: AppRadii.borderLg,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    _buildSubTabButton('Top-ups', Icons.add_circle_outline, _FinanceSubTab.topups),
                    _buildSubTabButton('Withdrawals', Icons.arrow_outward, _FinanceSubTab.withdrawals),
                    _buildSubTabButton('Settings', Icons.tune, _FinanceSubTab.settings),
                  ],
                ),
              ),
            ],
          ),
        ),

          // Secondary Filter Bar for Top-ups & Withdrawals
          if (_activeSubTab != _FinanceSubTab.settings) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: AppRadii.borderMd,
                  ),
                  child: Row(
                    children: [
                      _buildFilterPill('Pending', 'pending'),
                      _buildFilterPill('History', 'history'),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF64748B)),
                  tooltip: 'Refresh List',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Finance transaction lists updated.')),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubTabButton(String label, IconData icon, _FinanceSubTab tab) {
    final isSelected = _activeSubTab == tab;
    return InkWell(
      onTap: () => setState(() => _activeSubTab = tab),
      borderRadius: AppRadii.borderMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : Colors.transparent,
          borderRadius: AppRadii.borderMd,
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, String value) {
    final isSelected = _filterType == value;
    return InkWell(
      onTap: () => setState(() => _filterType = value),
      borderRadius: AppRadii.borderSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : Colors.transparent,
          borderRadius: AppRadii.borderSm,
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // --- Top-ups View ---
  Widget _buildTopupsView() {
    final filtered = _topups.where((t) {
      if (_filterType == 'pending') return t['status'] == 'pending';
      return t['status'] != 'pending';
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState('No ${_filterType == 'pending' ? 'pending' : 'historical'} top-up requests found.');
    }

    return Column(
      children: filtered.map((t) => _buildTopupCard(t)).toList(),
    );
  }

  Widget _buildTopupCard(Map<String, dynamic> topup) {
    final isPending = topup['status'] == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFECFDF5),
            child: Text(
              topup['name'][0],
              style: const TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(topup['name'], style: AppTypography.titleMedium),
                    const SizedBox(width: 8),
                    if (isPending)
                      AppStatusPill.pending(label: 'Pending Verification')
                    else if (topup['status'] == 'approved')
                      AppStatusPill.active(label: 'Credited')
                    else
                      AppStatusPill.rejected(label: 'Rejected'),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${topup['email']} • ${topup['utr']} • ${topup['method']} • ${topup['date']}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                topup['amount'],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              Text(
                '+${topup['coins']}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFD97706)),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(width: 20),
            Row(
              children: [
                AppButton(
                  label: 'Approve',
                  size: AppButtonSize.small,
                  onPressed: () {
                    setState(() => topup['status'] = 'approved');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Approved ${topup['utr']}. Credited ${topup['coins']} to ${topup['name']}.')),
                    );
                  },
                ),
                const SizedBox(width: 8),
                AppButton(
                  label: 'Reject',
                  variant: AppButtonVariant.destructive,
                  size: AppButtonSize.small,
                  onPressed: () {
                    setState(() => topup['status'] = 'rejected');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Rejected ${topup['utr']}. Candidate notified.')),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // --- Withdrawals View ---
  Widget _buildWithdrawalsView() {
    final filtered = _withdrawals.where((w) {
      if (_filterType == 'pending') return w['status'] == 'pending';
      return w['status'] != 'pending';
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState('No ${_filterType == 'pending' ? 'pending' : 'historical'} coin withdrawal requests.');
    }

    return Column(
      children: filtered.map((w) => _buildWithdrawalCard(w)).toList(),
    );
  }

  Widget _buildWithdrawalCard(Map<String, dynamic> withdrawal) {
    final isPending = withdrawal['status'] == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFFFFBEB),
            child: const Icon(Icons.arrow_outward, color: Color(0xFFD97706), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(withdrawal['name'], style: AppTypography.titleMedium),
                    const SizedBox(width: 8),
                    if (isPending)
                      AppStatusPill.pending(label: 'Payout Requested')
                    else
                      AppStatusPill.active(label: 'Paid'),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${withdrawal['email']} • UPI VPA: ${withdrawal['upi']} • ${withdrawal['date']}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                withdrawal['rupees'],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              Text(
                'Redeeming ${withdrawal['coins']}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(width: 20),
            Row(
              children: [
                AppButton(
                  label: 'Mark as Paid',
                  size: AppButtonSize.small,
                  onPressed: () => _showPayoutConfirmDialog(withdrawal),
                ),
                const SizedBox(width: 8),
                AppButton(
                  label: 'Reject & Refund',
                  variant: AppButtonVariant.destructive,
                  size: AppButtonSize.small,
                  onPressed: () {
                    setState(() => withdrawal['status'] = 'rejected');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Refunded ${withdrawal['coins']} to ${withdrawal['name']}.')),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showPayoutConfirmDialog(Map<String, dynamic> withdrawal) {
    final utrController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Payout Dispatch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paying ${withdrawal['rupees']} to ${withdrawal['upi']}.', style: AppTypography.bodyMedium),
            const SizedBox(height: 14),
            AppTextField(
              controller: utrController,
              label: 'Bank Reference / UTR Number',
              hintText: 'e.g. ICICI4920194821',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          AppButton(
            label: 'Complete Payout',
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                withdrawal['status'] = 'paid';
                withdrawal['utr'] = utrController.text;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payout dispatched to ${withdrawal['name']}! Transaction settled.')),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Settings View ---
  Widget _buildSettingsView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Platform Economics & Merchant UPI', style: AppTypography.titleLarge),
          const SizedBox(height: 4),
          const Text('20 Coins = ₹1.00 ratio governs all wallet calculations.', style: AppTypography.bodySmall),
          const SizedBox(height: 24),

          Wrap(
            spacing: 20,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 320,
                child: AppTextField(
                  controller: _upiIdController,
                  label: 'Merchant UPI ID (VPA)',
                  hintText: 'merchant@upi',
                ),
              ),
              SizedBox(
                width: 320,
                child: AppTextField(
                  controller: _merchantNameController,
                  label: 'Merchant Display Name',
                  hintText: 'Rankearn Technologies Pvt Ltd',
                ),
              ),
              SizedBox(
                width: 320,
                child: AppTextField(
                  controller: _minDepositController,
                  label: 'Minimum Deposit (₹)',
                  hintText: '50',
                ),
              ),
              SizedBox(
                width: 320,
                child: AppTextField(
                  controller: _minWithdrawalController,
                  label: 'Min Withdrawal Coins (1000 = ₹50)',
                  hintText: '1000',
                ),
              ),
              SizedBox(
                width: 320,
                child: AppTextField(
                  controller: _dailyLimitController,
                  label: 'Daily Max Payout Limit (₹)',
                  hintText: '50000',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          AppButton(
            label: 'Save Finance Settings',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Finance & UPI rules updated successfully.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
