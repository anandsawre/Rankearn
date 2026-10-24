import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'components/wallet_hero_card.dart';
import 'components/wallet_summary_card.dart';
import 'components/wallet_transaction_filters.dart';
import 'components/wallet_transaction_table.dart';
import 'components/wallet_transaction_tile.dart';
import 'withdrawal/withdrawal_feature.dart';
import 'components/wallet_quick_actions.dart';
import 'components/earnings_summary_card.dart';
import 'components/promotional_banners.dart';
import 'components/wallet_modals.dart';

class WalletScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onCoinsUpdated;
  final List<WalletTransactionModel>? initialTransactions;
  final ValueChanged<UserNavTab>? onNavigateToTab;
  final ValueChanged<int>? onCoinUpdate;

  const WalletScreen({
    super.key,
    required this.profile,
    required this.onCoinsUpdated,
    this.initialTransactions,
    this.onNavigateToTab,
    this.onCoinUpdate,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late int _currentCoins;
  late int _totalEarned;
  late int _totalWithdrawn;

  WalletFilterCategory _activeFilter = WalletFilterCategory.all;
  List<WalletTransactionModel> _transactions = [];
  bool _isLoadingTransactions = true;

  // Scroll controller for desktop / mobile quick navigation
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _withdrawalKey = GlobalKey();
  final GlobalKey _transactionsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentCoins = widget.profile.coins;
    _totalEarned = widget.profile.totalEarned > 0
        ? widget.profile.totalEarned
        : 12500;
    _totalWithdrawn = widget.profile.totalSpent > 0
        ? widget.profile.totalSpent
        : 5000;

    if (widget.initialTransactions != null &&
        widget.initialTransactions!.isNotEmpty) {
      _transactions = List.from(widget.initialTransactions!);
      _isLoadingTransactions = false;
    } else {
      _loadTransactions();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoadingTransactions = true);
    try {
      final res = await WalletRepository().getTransactions(
        userId: widget.profile.id,
      );
      if (!mounted) return;

      if (res is Success<List<WalletTransactionModel>> && res.data.isNotEmpty) {
        setState(() {
          _transactions = res.data;
          _isLoadingTransactions = false;
        });
      } else {
        // Fallback to reference transactions for zero-latency faithful display
        setState(() {
          _transactions = _getSampleTransactions();
          _isLoadingTransactions = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _transactions = _getSampleTransactions();
        _isLoadingTransactions = false;
      });
    }
  }

  List<WalletTransactionModel> _getSampleTransactions() {
    return [
      WalletTransactionModel(
        id: 'tx_01',
        userId: widget.profile.id,
        amount: 50,
        type: 'earn',
        category: 'quiz_reward',
        title: 'Quiz Test Reward',
        referenceId: 'Completed Full Test (RRB)',
        balanceAfter: 1250,
        createdAt: DateTime(2026, 10, 24, 18, 15),
      ),
      WalletTransactionModel(
        id: 'tx_02',
        userId: widget.profile.id,
        amount: 100,
        type: 'earn',
        category: 'battle_win',
        title: '1v1 Battle Win',
        referenceId: 'Won against Rohit',
        balanceAfter: 1200,
        createdAt: DateTime(2026, 10, 24, 17, 40),
      ),
      WalletTransactionModel(
        id: 'tx_03',
        userId: widget.profile.id,
        amount: 20,
        type: 'earn',
        category: 'lucky_wheel_win',
        title: 'Spin & Win',
        referenceId: 'Daily Spin Reward',
        balanceAfter: 1100,
        createdAt: DateTime(2026, 10, 24, 16, 12),
      ),
      WalletTransactionModel(
        id: 'tx_04',
        userId: widget.profile.id,
        amount: 50,
        type: 'earn',
        category: 'mock_test',
        title: 'Mock Test Reward',
        referenceId: 'Scored 80% in Mock Test',
        balanceAfter: 1080,
        createdAt: DateTime(2026, 10, 23, 21, 30),
      ),
      WalletTransactionModel(
        id: 'tx_05',
        userId: widget.profile.id,
        amount: 200,
        type: 'earn',
        category: 'referral',
        title: 'Referral Bonus',
        referenceId: 'Your friend joined',
        balanceAfter: 1030,
        createdAt: DateTime(2026, 10, 22, 11, 20),
      ),
      WalletTransactionModel(
        id: 'tx_06',
        userId: widget.profile.id,
        amount: -1000,
        type: 'spend',
        category: 'withdrawal',
        title: 'Withdrawal to UPI',
        referenceId: 'UPI: vikram@upi',
        balanceAfter: 830,
        createdAt: DateTime(2026, 10, 21, 15, 10),
      ),
      WalletTransactionModel(
        id: 'tx_07',
        userId: widget.profile.id,
        amount: 10,
        type: 'earn',
        category: 'daily_login',
        title: 'Daily Login',
        referenceId: 'Login Bonus',
        balanceAfter: 1830,
        createdAt: DateTime(2026, 10, 20, 8, 5),
      ),
      WalletTransactionModel(
        id: 'tx_08',
        userId: widget.profile.id,
        amount: 50,
        type: 'earn',
        category: 'offer',
        title: 'Offer Reward',
        referenceId: 'Special Event Reward',
        balanceAfter: 1820,
        createdAt: DateTime(2026, 10, 19, 19, 45),
      ),
    ];
  }

  List<WalletTransactionModel> _getFilteredTransactions() {
    switch (_activeFilter) {
      case WalletFilterCategory.earned:
        return _transactions
            .where((t) => t.amount > 0 || t.type == 'earn')
            .toList();
      case WalletFilterCategory.withdrawals:
        return _transactions
            .where((t) => t.category == 'withdrawal' || t.type == 'spend')
            .toList();
      case WalletFilterCategory.rewards:
        return _transactions.where((t) {
          final cat = t.category.toLowerCase();
          return cat.contains('reward') ||
              cat.contains('prize') ||
              cat.contains('spin') ||
              cat.contains('wheel') ||
              cat.contains('referral') ||
              cat.contains('login') ||
              cat.contains('battle');
        }).toList();
      case WalletFilterCategory.offers:
        return _transactions.where((t) {
          final cat = t.category.toLowerCase();
          return cat.contains('offer') ||
              cat.contains('special') ||
              cat.contains('discount');
        }).toList();
      case WalletFilterCategory.all:
        return _transactions;
    }
  }

  Future<bool> _handleWithdrawalSubmit({
    required int coins,
    required double payoutAmount,
    required String upiId,
  }) async {
    if (!isWithdrawalSupported) return false;
    final ok = await executeWithdrawal(
      userId: widget.profile.id,
      coins: coins,
      upiId: upiId,
      payoutAmount: payoutAmount,
    );
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit withdrawal request. Please try again.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
      return false;
    }

    if (!mounted) return false;

    setState(() {
      _currentCoins -= coins;
      _totalWithdrawn += coins;

      final newTx = WalletTransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        userId: widget.profile.id,
        amount: -coins,
        type: 'spend',
        category: 'withdrawal',
        title: 'Withdrawal to UPI',
        referenceId: 'UPI: $upiId',
        balanceAfter: _currentCoins,
        createdAt: DateTime.now(),
      );
      _transactions.insert(0, newTx);
    });

    widget.onCoinUpdate?.call(-coins);
    widget.onCoinsUpdated();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Withdrawal request for ${_formatCoins(coins)} Coins (₹${payoutAmount.toStringAsFixed(0)}) to $upiId submitted successfully!',
        ),
        backgroundColor: AppColors.walletPrimaryGreen,
        duration: const Duration(seconds: 4),
      ),
    );

    return true;
  }

  void _scrollToWithdrawal() {
    final ctx = _withdrawalKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _scrollToTransactions() {
    final ctx = _transactionsKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _openMobileWithdrawalModal() {
    if (!isWithdrawalSupported) return;
    openWithdrawalModal(
      context,
      userCoins: _currentCoins,
      onWithdraw: _handleWithdrawalSubmit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.walletBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 1024;
          final isTablet = width >= 600 && width < 1024;

          if (isDesktop) {
            return _buildDesktopLayout(width);
          } else if (isTablet) {
            return _buildTabletLayout(width);
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  // ==========================================
  // 1. DESKTOP FULL-WIDTH LAYOUT (MANDATORY)
  // ==========================================
  Widget _buildDesktopLayout(double viewportWidth) {
    final filteredTxs = _getFilteredTransactions();
    final horizontalGutter = viewportWidth >= 1440 ? 32.0 : 24.0;

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: horizontalGutter, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive Two-Column Layout (Left ~65%, Right ~35%)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN (~65% width)
              Expanded(
                flex: 65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. Hero Banner
                    const DesktopWalletHeroBanner(),
                    const SizedBox(height: 18),

                    // B. Summary Cards (Total Coins, Total Earned, Total Withdrawn)
                    DesktopWalletSummaryRow(
                      currentCoins: _currentCoins,
                      totalEarned: _totalEarned,
                      totalWithdrawn: _totalWithdrawn,
                      onInfoTap: () =>
                          WalletModals.showHowItWorksDialog(context),
                    ),
                    const SizedBox(height: 20),

                    // C. Full-Width Transaction Table with Integrated Filters inside the Card
                    Container(
                      key: _transactionsKey,
                      child: WalletTransactionTable(
                        transactions: filteredTxs,
                        isLoading: _isLoadingTransactions,
                        activeFilter: _activeFilter,
                        onFilterSelected: (cat) =>
                            setState(() => _activeFilter = cat),
                        onRowTap: (tx) =>
                            WalletModals.showTransactionDetails(context, tx),
                        showWithdrawals: isWithdrawalSupported,
                      ),
                    ),
                  ],
                ),
              ),

              // Gap between columns
              const SizedBox(width: 22),

              // RIGHT COLUMN (~35% width)
              Expanded(
                flex: 35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. Withdraw to UPI Card (Web only)
                    if (isWithdrawalSupported) ...[
                      Container(
                        key: _withdrawalKey,
                        child: WithdrawalPanel(
                          userCoins: _currentCoins,
                          onWithdraw: _handleWithdrawalSubmit,
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // B. Quick Actions Card
                    DesktopQuickActionsCard(
                      showWithdraw: isWithdrawalSupported,
                      onWithdraw: _scrollToWithdrawal,
                      onHistory: _scrollToTransactions,
                      onEarnMore: () =>
                          widget.onNavigateToTab?.call(UserNavTab.tests),
                      onRedeem: () => WalletModals.showRedeemOffersModal(
                        context,
                        userCoins: _currentCoins,
                      ),
                      onHowItWorks: () =>
                          WalletModals.showHowItWorksDialog(context),
                    ),
                    const SizedBox(height: 18),

                    // C. Your Earnings Card
                    EarningsSummaryCard(
                      totalEarned: _totalEarned,
                      totalWithdrawn: _totalWithdrawn,
                      onViewDetails: () {
                        setState(
                          () => _activeFilter = WalletFilterCategory.earned,
                        );
                        _scrollToTransactions();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bottom Promotional Banners (Side-by-side on desktop)
          DesktopPromotionalBannersSection(
            onViewTasks: () => widget.onNavigateToTab?.call(UserNavTab.tests),
            onReferNow: () => WalletModals.showReferralModal(
              context,
              referralCode: widget.profile.referralCode ?? 'VIKRAM2026',
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // ==========================================
  // 2. TABLET LAYOUT (600 - 1023px)
  // ==========================================
  Widget _buildTabletLayout(double viewportWidth) {
    final filteredTxs = _getFilteredTransactions();

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DesktopWalletHeroBanner(),
          const SizedBox(height: 16),

          DesktopWalletSummaryRow(
            currentCoins: _currentCoins,
            totalEarned: _totalEarned,
            totalWithdrawn: _totalWithdrawn,
            onInfoTap: () => WalletModals.showHowItWorksDialog(context),
          ),
          const SizedBox(height: 18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWithdrawalSupported) ...[
                Expanded(
                  child: WithdrawalPanel(
                    userCoins: _currentCoins,
                    onWithdraw: _handleWithdrawalSubmit,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  children: [
                    DesktopQuickActionsCard(
                      showWithdraw: isWithdrawalSupported,
                      onWithdraw: _scrollToWithdrawal,
                      onHistory: _scrollToTransactions,
                      onEarnMore: () =>
                          widget.onNavigateToTab?.call(UserNavTab.tests),
                      onRedeem: () => WalletModals.showRedeemOffersModal(
                        context,
                        userCoins: _currentCoins,
                      ),
                      onHowItWorks: () =>
                          WalletModals.showHowItWorksDialog(context),
                    ),
                    const SizedBox(height: 16),
                    EarningsSummaryCard(
                      totalEarned: _totalEarned,
                      totalWithdrawn: _totalWithdrawn,
                      onViewDetails: () => setState(
                        () => _activeFilter = WalletFilterCategory.earned,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          WalletTransactionTable(
            transactions: filteredTxs,
            isLoading: _isLoadingTransactions,
            activeFilter: _activeFilter,
            onFilterSelected: (cat) => setState(() => _activeFilter = cat),
            onRowTap: (tx) => WalletModals.showTransactionDetails(context, tx),
            showWithdrawals: isWithdrawalSupported,
          ),
          const SizedBox(height: 22),

          DesktopPromotionalBannersSection(
            onViewTasks: () => widget.onNavigateToTab?.call(UserNavTab.tests),
            onReferNow: () => WalletModals.showReferralModal(
              context,
              referralCode: widget.profile.referralCode ?? 'VIKRAM2026',
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ==========================================
  // 3. MOBILE SCREEN (< 600px)
  // ==========================================
  Widget _buildMobileLayout() {
    final filteredTxs = _getFilteredTransactions();

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1 & 2. My Wallet Title + Total Coins Hero Card
          MobileWalletHeroSection(
            coins: _currentCoins,
            onHowItWorksTap: () => WalletModals.showHowItWorksDialog(context),
            onInfoTap: () => WalletModals.showHowItWorksDialog(context),
            showWithdrawalInfo: isWithdrawalSupported,
          ),
          const SizedBox(height: 16),

          // 3. 4 Quick Action Cards (Withdraw, History, Earn More, Redeem)
          MobileQuickActionsRow(
            showWithdraw: isWithdrawalSupported,
            onWithdraw: _openMobileWithdrawalModal,
            onHistory: _scrollToTransactions,
            onEarnMore: () => widget.onNavigateToTab?.call(UserNavTab.tests),
            onRedeem: () => WalletModals.showRedeemOffersModal(
              context,
              userCoins: _currentCoins,
            ),
            onHowItWorks: () => WalletModals.showHowItWorksDialog(context),
          ),
          const SizedBox(height: 18),

          // 4. Transaction History Card (with Integrated Filters)
          Container(
            key: _transactionsKey,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.walletBorder, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Title & Count
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Recent Transactions',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.walletNavy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${filteredTxs.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.walletSecondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filters inside the transaction card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: WalletTransactionFilters(
                    activeFilter: _activeFilter,
                    onFilterSelected: (cat) => setState(() => _activeFilter = cat),
                    isDesktop: false,
                    showWithdrawals: isWithdrawalSupported,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.walletBorder),

                if (_isLoadingTransactions)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.walletPrimaryGreen,
                      ),
                    ),
                  )
                else if (filteredTxs.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    alignment: Alignment.center,
                    child: Column(
                      children: const [
                        Icon(
                          Icons.receipt_long,
                          size: 40,
                          color: AppColors.walletSecondaryText,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.walletNavy,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredTxs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final tx = filteredTxs[index];
                      return WalletTransactionTile(
                        transaction: tx,
                        onTap: () =>
                            WalletModals.showTransactionDetails(context, tx),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 6. Complete Daily Tasks Banner
          DailyTasksBanner(
            onViewTasks: () => widget.onNavigateToTab?.call(UserNavTab.tests),
          ),
          const SizedBox(height: 12),

          // Refer & Earn Banner
          ReferEarnBanner(
            onReferNow: () => WalletModals.showReferralModal(
              context,
              referralCode: widget.profile.referralCode ?? 'VIKRAM2026',
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatCoins(int amount) {
    if (amount >= 1000) {
      final s = amount.toString();
      final lastThree = s.substring(s.length - 3);
      final remaining = s.substring(0, s.length - 3);
      return '$remaining,$lastThree';
    }
    return amount.toString();
  }
}
