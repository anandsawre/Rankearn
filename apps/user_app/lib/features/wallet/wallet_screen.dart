import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

enum WalletTxFilter { all, earn, spend }

class WalletScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onCoinsUpdated;

  const WalletScreen({
    super.key,
    required this.profile,
    required this.onCoinsUpdated,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late int _currentCoins;
  WalletTxFilter _activeFilter = WalletTxFilter.all;
  bool _isRefreshing = false;

  // Modals state
  int _topUpStep = 1; // 1: amount, 2: qr, 3: utr
  int _selectedTopUpAmount = 500;
  final TextEditingController _utrController = TextEditingController();

  int _withdrawStep = 1; // 1: amount, 2: details, 3: confirm
  int _withdrawAmount = 1000;
  String _withdrawMethod = 'upi'; // 'upi' or 'bank'
  final TextEditingController _upiIdController = TextEditingController(text: 'vikram@okaxis');
  final TextEditingController _upiNameController = TextEditingController(text: 'Vikram Singh');
  final TextEditingController _bankHolderController = TextEditingController(text: 'Vikram Singh');
  final TextEditingController _bankAccountController = TextEditingController(text: '918237465019');
  final TextEditingController _bankIfscController = TextEditingController(text: 'SBIN0001423');
  bool _saveForFuture = true;

  late final List<WalletTransactionModel> _mockTransactions;

  @override
  void initState() {
    super.initState();
    _currentCoins = widget.profile.coins;
    _mockTransactions = [
      WalletTransactionModel(
        id: 'tx_01',
        userId: widget.profile.id,
        amount: 250,
        type: 'earn',
        category: 'tournament_prize',
        title: 'BPSC Grand Mock League 🏆',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        balanceAfter: _currentCoins,
      ),
      WalletTransactionModel(
        id: 'tx_02',
        userId: widget.profile.id,
        amount: -50,
        type: 'spend',
        category: 'tournament_entry',
        title: '70th BPSC Prelims Speed Test',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        balanceAfter: _currentCoins - 250,
      ),
      WalletTransactionModel(
        id: 'tx_03',
        userId: widget.profile.id,
        amount: 50,
        type: 'earn',
        category: 'lucky_wheel_win',
        title: 'Daily Lucky Wheel Jackpot',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        balanceAfter: _currentCoins - 200,
      ),
      WalletTransactionModel(
        id: 'tx_04',
        userId: widget.profile.id,
        amount: 500,
        type: 'earn',
        category: 'top_up',
        title: 'UPI Wallet Top-up (Ref: 429184029182)',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        balanceAfter: _currentCoins - 250,
      ),
      WalletTransactionModel(
        id: 'tx_05',
        userId: widget.profile.id,
        amount: 100,
        type: 'earn',
        category: 'referral',
        title: 'Friend Signup Bonus: Anita K.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        balanceAfter: _currentCoins - 750,
      ),
      WalletTransactionModel(
        id: 'tx_06',
        userId: widget.profile.id,
        amount: -200,
        type: 'spend',
        category: 'test_purchase',
        title: 'SSC CGL Tier-1 2024 Pro Mock Series',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        balanceAfter: _currentCoins - 850,
      ),
    ];
  }

  @override
  void dispose() {
    _utrController.dispose();
    _upiIdController.dispose();
    _upiNameController.dispose();
    _bankHolderController.dispose();
    _bankAccountController.dispose();
    _bankIfscController.dispose();
    super.dispose();
  }

  void _refreshHistory() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction history updated successfully!'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTxs = _mockTransactions.where((tx) {
      if (_activeFilter == WalletTxFilter.earn) return tx.type == 'earn';
      if (_activeFilter == WalletTxFilter.spend) return tx.type == 'spend';
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Four Gradient Stat Cards Grid (Matching React Wallet.tsx stats)
          _buildStatCardsGrid(),
          const SizedBox(height: 16),

          // 2. Mobile Quick Action Buttons (Add Coins & Withdraw)
          _buildMobileActionButtons(),
          const SizedBox(height: 20),

          // 3. Transactions Card with Header, Filter Tabs, and Rows
          _buildTransactionsCard(filteredTxs),
        ],
      ),
    );
  }

  // --- 1. Four Gradient Stat Cards Grid ---
  Widget _buildStatCardsGrid() {
    final lifetimeEarned = _mockTransactions
        .where((t) => t.type == 'earn')
        .fold<int>(0, (acc, t) => acc + t.amount);
    final lifetimeSpent = _mockTransactions
        .where((t) => t.type == 'spend')
        .fold<int>(0, (acc, t) => acc + t.amount.abs());
    final withdrawableInRupees = (_currentCoins / 20).toStringAsFixed(0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 700;
        final cardWidth = isDesktop ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // Card 1: Balance
            _buildStatCard(
              width: cardWidth,
              title: 'BALANCE',
              value: '$_currentCoins',
              subtext: 'Available for tests',
              icon: Icons.currency_rupee,
              gradient: const LinearGradient(
                colors: [Color(0xFFFB923C), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _openTopUpModal(),
            ),
            // Card 2: Total Earned
            _buildStatCard(
              width: cardWidth,
              title: 'TOTAL EARNED',
              value: '$lifetimeEarned',
              subtext: 'Lifetime rewards',
              icon: Icons.trending_up,
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF0891B2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            // Card 3: Total Spent
            _buildStatCard(
              width: cardWidth,
              title: 'TOTAL SPENT',
              value: '$lifetimeSpent',
              subtext: 'Contest entries',
              icon: Icons.access_time_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFF43F5E), Color(0xFFC026D3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            // Card 4: Withdraw (₹)
            _buildStatCard(
              width: cardWidth,
              title: 'WITHDRAW',
              value: '₹$withdrawableInRupees',
              subtext: 'Winnings for bank',
              icon: Icons.account_balance,
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF4338CA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _openWithdrawModal(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required double width,
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required LinearGradient gradient,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.borderLg,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: AppRadii.borderLg,
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withAlpha(50),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withAlpha(75)),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Mobile Quick Action Buttons ---
  Widget _buildMobileActionButtons() {
    return Row(
      children: [
        // Top-up Button
        Expanded(
          child: InkWell(
            onTap: _openTopUpModal,
            borderRadius: AppRadii.borderMd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: AppRadii.borderMd,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WALLET',
                        style: TextStyle(
                          color: Colors.white.withAlpha(190),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'Add Coins',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Withdraw Button
        Expanded(
          child: InkWell(
            onTap: _openWithdrawModal,
            borderRadius: AppRadii.borderMd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                ),
                borderRadius: AppRadii.borderMd,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_outward, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PAYOUT',
                        style: TextStyle(
                          color: Colors.white.withAlpha(190),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'Withdraw (₹)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 3. Transactions Card ---
  Widget _buildTransactionsCard(List<WalletTransactionModel> txs) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header with Title & Refresh
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.canvasDark,
                        borderRadius: AppRadii.borderSm,
                      ),
                      child: const Icon(Icons.history, color: AppColors.textSecondary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Filter Chips
                    _buildFilterChip('All', WalletTxFilter.all),
                    const SizedBox(width: 6),
                    _buildFilterChip('Earned (+)', WalletTxFilter.earn),
                    const SizedBox(width: 6),
                    _buildFilterChip('Spent (-)', WalletTxFilter.spend),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: _isRefreshing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          : const Icon(Icons.refresh, size: 18, color: AppColors.textSecondary),
                      onPressed: _isRefreshing ? null : _refreshHistory,
                      tooltip: 'Refresh Transactions',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Transactions List Rows
          if (txs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: const [
                  Icon(Icons.receipt_long, size: 48, color: AppColors.border),
                  SizedBox(height: 12),
                  Text('No Transactions Found', style: AppTypography.titleMedium),
                  SizedBox(height: 4),
                  Text(
                    'Your coin ledger activity will appear here.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: txs.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final tx = txs[index];
                final isEarn = tx.type == 'earn';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Category Icon Box
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isEarn ? AppColors.primarySubtle : const Color(0xFFFFE4E6),
                          borderRadius: AppRadii.borderMd,
                        ),
                        child: Icon(
                          _getTxCategoryIcon(tx.category),
                          color: isEarn ? AppColors.primary : const Color(0xFFF43F5E),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Title & Time Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTxCategoryTitle(tx.category),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (tx.title.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  tx.title,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 11, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  '${tx.createdAt.day} ${_getMonthName(tx.createdAt.month)}, ${tx.createdAt.hour.toString().padLeft(2, '0')}:${tx.createdAt.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Amount and Running Balance
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isEarn ? '+' : '-'}${tx.amount.abs()}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isEarn ? AppColors.primary : const Color(0xFFE11D48),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Bal: ${tx.balanceAfter}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, WalletTxFilter filter) {
    final isSelected = _activeFilter == filter;
    return InkWell(
      onTap: () => setState(() => _activeFilter = filter),
      borderRadius: AppRadii.borderSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySubtle : Colors.transparent,
          borderRadius: AppRadii.borderSm,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  IconData _getTxCategoryIcon(String category) {
    switch (category) {
      case 'tournament_prize':
        return Icons.emoji_events;
      case 'tournament_entry':
        return Icons.sports_score;
      case 'top_up':
        return Icons.credit_card;
      case 'lucky_wheel_win':
        return Icons.star;
      case 'referral':
        return Icons.card_giftcard;
      case 'test_purchase':
        return Icons.lock_open;
      default:
        return Icons.monetization_on;
    }
  }

  String _getTxCategoryTitle(String category) {
    switch (category) {
      case 'tournament_prize':
        return 'Contest Prize Winnings';
      case 'tournament_entry':
        return 'Joined Contest Fee';
      case 'top_up':
        return 'Wallet Top-up';
      case 'lucky_wheel_win':
        return 'Lucky Wheel Win';
      case 'referral':
        return 'Referral Bonus';
      case 'test_purchase':
        return 'Unlocked Test Series';
      default:
        return 'Coin Adjustment';
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  // ==========================================
  // TOP-UP MODAL (3-STEP UPI PAYMENT FLOW)
  // ==========================================
  void _openTopUpModal() {
    setState(() {
      _topUpStep = 1;
      _selectedTopUpAmount = 500;
      _utrController.clear();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Gradient Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(50),
                              borderRadius: AppRadii.borderMd,
                            ),
                            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TOP-UP WALLET',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Step $_topUpStep of 3: ${_getTopUpStepTitle(_topUpStep)}',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(200),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // Body per Step
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: switch (_topUpStep) {
                        1 => _buildTopUpStep1(setModalState),
                        2 => _buildTopUpStep2(setModalState),
                        3 => _buildTopUpStep3(setModalState),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getTopUpStepTitle(int step) {
    switch (step) {
      case 1:
        return 'Select Coins';
      case 2:
        return 'Scan & Pay via UPI';
      case 3:
        return 'Verify 12-digit UTR';
      default:
        return '';
    }
  }

  Widget _buildTopUpStep1(StateSetter setModalState) {
    final rupeeAmount = (_selectedTopUpAmount / 10).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Candidate info banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.canvasDark,
            borderRadius: AppRadii.borderMd,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 18,
                child: Text(
                  widget.profile.name.isNotEmpty ? widget.profile.name[0] : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.profile.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    Text(
                      'Current Balance: $_currentCoins Coins',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text('Choose Top-Up Package', style: AppTypography.titleMedium),
        const SizedBox(height: 10),

        // Package Chips
        Row(
          children: [100, 500, 1000, 2000].map((amt) {
            final isSel = _selectedTopUpAmount == amt;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => setModalState(() => _selectedTopUpAmount = amt),
                  borderRadius: AppRadii.borderMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primarySubtle : Colors.white,
                      border: Border.all(
                        color: isSel ? AppColors.primary : AppColors.border,
                        width: isSel ? 2 : 1,
                      ),
                      borderRadius: AppRadii.borderMd,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$amt',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isSel ? AppColors.primary : AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Coins',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isSel ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Pay Price Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            border: Border.all(color: AppColors.primary.withAlpha(50)),
            borderRadius: AppRadii.borderMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOU PAY',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹$rupeeAmount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.shield_outlined, color: AppColors.primary, size: 36),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Next Button
        AppButton(
          label: 'Proceed to Payment (₹$rupeeAmount) →',
          variant: AppButtonVariant.primary,
          fullWidth: true,
          onPressed: () {
            setModalState(() => _topUpStep = 2);
          },
        ),
      ],
    );
  }

  Widget _buildTopUpStep2(StateSetter setModalState) {
    final rupeeAmount = (_selectedTopUpAmount / 10).toStringAsFixed(0);

    return Column(
      children: [
        // QR Code Simulated Display matching React QRCodeSVG
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.borderLg,
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Custom high-tech QR Visual Matrix
              CustomPaint(
                size: const Size(160, 160),
                painter: _SimulatedQrPainter(),
              ),
              const SizedBox(height: 12),
              const Text(
                'UPI ID: rankearn@icici',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'Merchant: Rankearn Education Pvt Ltd',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Info Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: AppRadii.borderMd,
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Scan using GPay, PhonePe, or Paytm and pay ₹$rupeeAmount. Note down the 12-digit UTR/Ref No.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Back',
                variant: AppButtonVariant.secondary,
                onPressed: () => setModalState(() => _topUpStep = 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton(
                label: 'I Have Paid →',
                variant: AppButtonVariant.primary,
                onPressed: () => setModalState(() => _topUpStep = 3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopUpStep3(StateSetter setModalState) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(
            color: Color(0xFFECFDF5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified_user, color: AppColors.primary, size: 28),
        ),
        const SizedBox(height: 12),
        const Text(
          'Enter 12-Digit UTR Number',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        const Text(
          'Find the 12-digit UPI Transaction Ref ID in your bank or UPI app.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _utrController,
          keyboardType: TextInputType.number,
          maxLength: 12,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. 429184029182',
            border: OutlineInputBorder(
              borderRadius: AppRadii.borderMd,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.borderMd,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Back',
                variant: AppButtonVariant.secondary,
                onPressed: () => setModalState(() => _topUpStep = 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton(
                label: 'Submit Verification',
                variant: AppButtonVariant.primary,
                onPressed: () {
                  if (_utrController.text.trim().length < 8) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid 12-digit UTR/Ref number.'),
                        backgroundColor: Color(0xFFE11D48),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  setState(() {
                    _currentCoins += _selectedTopUpAmount;
                    _mockTransactions.insert(
                      0,
                      WalletTransactionModel(
                        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                        userId: widget.profile.id,
                        amount: _selectedTopUpAmount,
                        type: 'earn',
                        category: 'top_up',
                        title: 'Wallet Top-up (Ref: ${_utrController.text.trim()})',
                        createdAt: DateTime.now(),
                        balanceAfter: _currentCoins,
                      ),
                    );
                  });
                  widget.onCoinsUpdated();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Top-up request verified! $_selectedTopUpAmount Coins added.'),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // WITHDRAWAL MODAL (3-STEP WITHDRAWAL FLOW)
  // ==========================================
  void _openWithdrawModal() {
    setState(() {
      _withdrawStep = 1;
      _withdrawAmount = 1000;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Gradient Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(50),
                              borderRadius: AppRadii.borderMd,
                            ),
                            child: const Icon(Icons.account_balance, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'WITHDRAW WINNINGS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Step $_withdrawStep of 3: ${_getWithdrawStepTitle(_withdrawStep)}',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(200),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: switch (_withdrawStep) {
                        1 => _buildWithdrawStep1(setModalState),
                        2 => _buildWithdrawStep2(setModalState),
                        3 => _buildWithdrawStep3(setModalState),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getWithdrawStepTitle(int step) {
    switch (step) {
      case 1:
        return 'Select Amount';
      case 2:
        return 'Enter Payout Details';
      case 3:
        return 'Review & Confirm';
      default:
        return '';
    }
  }

  Widget _buildWithdrawStep1(StateSetter setModalState) {
    final rupeeAmount = (_withdrawAmount / 20).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Balance info tile
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            border: Border.all(color: const Color(0xFFFED7AA)),
            borderRadius: AppRadii.borderMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WITHDRAWABLE BALANCE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC2410C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_currentCoins Coins',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF9A3412),
                    ),
                  ),
                ],
              ),
              const Text(
                'Min: 1,000 Coins',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC2410C),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text('Select Coin Amount', style: AppTypography.titleMedium),
        const SizedBox(height: 10),

        // Amount chips
        Row(
          children: [1000, 2000, 5000].map((amt) {
            final isSel = _withdrawAmount == amt;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => setModalState(() => _withdrawAmount = amt),
                  borderRadius: AppRadii.borderMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFFFF7ED) : Colors.white,
                      border: Border.all(
                        color: isSel ? const Color(0xFFEA580C) : AppColors.border,
                        width: isSel ? 2 : 1,
                      ),
                      borderRadius: AppRadii.borderMd,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$amt',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isSel ? const Color(0xFFEA580C) : AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Coins',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isSel ? const Color(0xFFEA580C) : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // You Receive Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            border: Border.all(color: const Color(0xFFFDE68A)),
            borderRadius: AppRadii.borderMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOU RECEIVE IN BANK / UPI',
                    style: TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹$rupeeAmount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  const Text(
                    '(20 Coins = ₹1.00 • 0% Transaction Fee)',
                    style: TextStyle(fontSize: 10, color: Color(0xFFB45309)),
                  ),
                ],
              ),
              const Icon(Icons.currency_rupee, color: Color(0xFFD97706), size: 36),
            ],
          ),
        ),
        const SizedBox(height: 20),

        AppButton(
          label: 'Continue to Payout Details →',
          variant: AppButtonVariant.primary,
          fullWidth: true,
          onPressed: () {
            if (_withdrawAmount > _currentCoins) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Insufficient coin balance for this withdrawal amount.'),
                  backgroundColor: Color(0xFFE11D48),
                ),
              );
              return;
            }
            setModalState(() => _withdrawStep = 2);
          },
        ),
      ],
    );
  }

  Widget _buildWithdrawStep2(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Method Switcher (UPI vs Bank)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.canvasDark,
            borderRadius: AppRadii.borderMd,
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setModalState(() => _withdrawMethod = 'upi'),
                  borderRadius: AppRadii.borderSm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _withdrawMethod == 'upi' ? Colors.white : Colors.transparent,
                      borderRadius: AppRadii.borderSm,
                      boxShadow: _withdrawMethod == 'upi'
                          ? const [BoxShadow(color: Colors.black12, blurRadius: 4)]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        'UPI Transfer (Instant)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _withdrawMethod == 'upi' ? const Color(0xFFEA580C) : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setModalState(() => _withdrawMethod = 'bank'),
                  borderRadius: AppRadii.borderSm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _withdrawMethod == 'bank' ? Colors.white : Colors.transparent,
                      borderRadius: AppRadii.borderSm,
                      boxShadow: _withdrawMethod == 'bank'
                          ? const [BoxShadow(color: Colors.black12, blurRadius: 4)]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        'Bank Account (NEFT/IMPS)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _withdrawMethod == 'bank' ? const Color(0xFFEA580C) : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_withdrawMethod == 'upi') ...[
          Text('Account Holder Name', style: AppTypography.labelLarge),
          const SizedBox(height: 6),
          TextField(
            controller: _upiNameController,
            decoration: InputDecoration(
              hintText: 'Full Name as in Bank',
              border: OutlineInputBorder(borderRadius: AppRadii.borderMd),
            ),
          ),
          const SizedBox(height: 12),
          Text('UPI ID (VPA)', style: AppTypography.labelLarge),
          const SizedBox(height: 6),
          TextField(
            controller: _upiIdController,
            decoration: InputDecoration(
              hintText: 'e.g. mobile@upi or name@okaxis',
              border: OutlineInputBorder(borderRadius: AppRadii.borderMd),
            ),
          ),
        ] else ...[
          Text('Bank Account Holder Name', style: AppTypography.labelLarge),
          const SizedBox(height: 6),
          TextField(
            controller: _bankHolderController,
            decoration: InputDecoration(
              hintText: 'Name as on passbook',
              border: OutlineInputBorder(borderRadius: AppRadii.borderMd),
            ),
          ),
          const SizedBox(height: 10),
          Text('Account Number', style: AppTypography.labelLarge),
          const SizedBox(height: 6),
          TextField(
            controller: _bankAccountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '918237465019',
              border: OutlineInputBorder(borderRadius: AppRadii.borderMd),
            ),
          ),
          const SizedBox(height: 10),
          Text('IFSC Code', style: AppTypography.labelLarge),
          const SizedBox(height: 6),
          TextField(
            controller: _bankIfscController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'SBIN0001423',
              border: OutlineInputBorder(borderRadius: AppRadii.borderMd),
            ),
          ),
        ],
        const SizedBox(height: 12),

        Row(
          children: [
            Checkbox(
              value: _saveForFuture,
              activeColor: const Color(0xFFEA580C),
              onChanged: (val) => setModalState(() => _saveForFuture = val ?? true),
            ),
            const Text(
              'Save details securely for future payouts',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Back',
                variant: AppButtonVariant.secondary,
                onPressed: () => setModalState(() => _withdrawStep = 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton(
                label: 'Review Request →',
                variant: AppButtonVariant.primary,
                onPressed: () {
                  if (_withdrawMethod == 'upi' && !_upiIdController.text.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid UPI ID with @ symbol.'),
                        backgroundColor: Color(0xFFE11D48),
                      ),
                    );
                    return;
                  }
                  setModalState(() => _withdrawStep = 3);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWithdrawStep3(StateSetter setModalState) {
    final rupeeAmount = (_withdrawAmount / 20).toStringAsFixed(0);
    final destination = _withdrawMethod == 'upi'
        ? '${_upiNameController.text} (${_upiIdController.text})'
        : '${_bankHolderController.text} (A/C: ${_bankAccountController.text})';

    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF7ED),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.security, color: Color(0xFFEA580C), size: 28),
        ),
        const SizedBox(height: 12),
        const Text('Confirm Withdrawal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const Text(
          'Please verify payout information carefully before proceeding.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Summary details card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.canvasDark,
            borderRadius: AppRadii.borderMd,
          ),
          child: Column(
            children: [
              _buildReviewRow('Coins Deducted', '$_withdrawAmount Coins', isHighlight: true),
              const Divider(height: 16),
              _buildReviewRow('Cash Value', '₹$rupeeAmount', isHighlight: true),
              const Divider(height: 16),
              _buildReviewRow('Payment Mode', _withdrawMethod.toUpperCase()),
              const Divider(height: 16),
              _buildReviewRow('Payout To', destination),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: AppRadii.borderMd,
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: const [
              Icon(Icons.access_time, color: Color(0xFFD97706), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Transfers usually complete within 24-48 business hours after security review.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Back',
                variant: AppButtonVariant.secondary,
                onPressed: () => setModalState(() => _withdrawStep = 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton(
                label: 'Submit Payout Request',
                variant: AppButtonVariant.primary,
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentCoins -= _withdrawAmount;
                    _mockTransactions.insert(
                      0,
                      WalletTransactionModel(
                        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                        userId: widget.profile.id,
                        amount: -_withdrawAmount,
                        type: 'spend',
                        category: 'withdrawal_request',
                        title: 'Withdrawal to ${_withdrawMethod.toUpperCase()}',
                        createdAt: DateTime.now(),
                        balanceAfter: _currentCoins,
                      ),
                    );
                  });
                  widget.onCoinsUpdated();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Withdrawal request submitted for ₹$rupeeAmount!'),
                      backgroundColor: const Color(0xFFEA580C),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 14 : 12,
            fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
            color: isHighlight ? const Color(0xFFEA580C) : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// Custom Painter for simulated QR matrix visual
class _SimulatedQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0F172A);

    // Corner Finder Patterns
    void drawFinder(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, 32, 32), paint);
      canvas.drawRect(Rect.fromLTWH(x + 4, y + 4, 24, 24), Paint()..color = Colors.white);
      canvas.drawRect(Rect.fromLTWH(x + 8, y + 8, 16, 16), paint);
    }

    drawFinder(4, 4);
    drawFinder(size.width - 36, 4);
    drawFinder(4, size.height - 36);

    // Decorative Data Matrix Dots
    final dotPaint = Paint()..color = const Color(0xFF1E293B);
    for (double i = 44; i < size.width - 40; i += 10) {
      for (double j = 10; j < size.height - 10; j += 10) {
        if ((i.toInt() ^ j.toInt()) % 3 == 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(i, j, 6, 6), const Radius.circular(2)),
            dotPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
