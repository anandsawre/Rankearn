import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'wallet_icons.dart';
import 'wallet_transaction_filters.dart';

/// Desktop Full-Width Transaction Table Component
class WalletTransactionTable extends StatelessWidget {
  final List<WalletTransactionModel> transactions;
  final bool isLoading;
  final void Function(WalletTransactionModel)? onRowTap;
  final WalletFilterCategory? activeFilter;
  final ValueChanged<WalletFilterCategory>? onFilterSelected;
  final bool showWithdrawals;

  const WalletTransactionTable({
    super.key,
    required this.transactions,
    this.isLoading = false,
    this.onRowTap,
    this.activeFilter,
    this.onFilterSelected,
    this.showWithdrawals = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = activeFilter != null && onFilterSelected != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.walletBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header with Title and Filter Tabs inside the Card
          if (hasFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 640;
                  final filterWidget = WalletTransactionFilters(
                    activeFilter: activeFilter!,
                    onFilterSelected: onFilterSelected!,
                    isDesktop: true,
                    showWithdrawals: showWithdrawals,
                  );

                  if (isWide) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Transactions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.walletNavy,
                                letterSpacing: -0.2,
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${transactions.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.walletSecondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: filterWidget,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Transactions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.walletNavy,
                                letterSpacing: -0.2,
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${transactions.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.walletSecondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        filterWidget,
                      ],
                    );
                  }
                },
              ),
            ),

          // Table Column Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBFF),
              borderRadius: hasFilters
                  ? BorderRadius.zero
                  : const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(
                top: hasFilters
                    ? const BorderSide(color: AppColors.walletBorder, width: 1)
                    : BorderSide.none,
                bottom: const BorderSide(color: AppColors.walletBorder, width: 1),
              ),
            ),

            child: Row(
              children: const [
                SizedBox(
                  width: 36,
                  child: Text(
                    '#',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.walletSecondaryText,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Type',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.walletSecondaryText,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.walletSecondaryText,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Date & Time',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.walletSecondaryText,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Coins',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.walletSecondaryText,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Balance',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.walletSecondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading, Empty, or Table Rows
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.walletPrimaryGreen,
                ),
              ),
            )
          else if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 44,
                    color: AppColors.walletSecondaryText,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No transactions in this category',
                    style: TextStyle(
                      fontSize: 14,
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
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFF1F5F9),
              ),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isPositive = tx.amount > 0 || tx.type == 'earn';
                final isWithdrawal =
                    tx.category == 'withdrawal' || tx.type == 'spend';

                return InkWell(
                  onTap: () => onRowTap?.call(tx),
                  hoverColor: const Color(0xFFF8FAFC),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        // # Index
                        SizedBox(
                          width: 36,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.walletSecondaryText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Type Column (Category Icon + Title)
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              _buildCategoryBadge(tx),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  tx.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.walletNavy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Description Column
                        Expanded(
                          flex: 4,
                          child: Text(
                            _getTxDescription(tx),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.walletSecondaryText,
                            ),
                          ),
                        ),

                        // Date & Time Column
                        Expanded(
                          flex: 3,
                          child: Text(
                            _formatDateTime(tx.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.walletSecondaryText,
                            ),
                          ),
                        ),

                        // Coins Delta Column (+ / -)
                        SizedBox(
                          width: 80,
                          child: Text(
                            '${isPositive ? '+ ' : '- '}${_formatCoins(tx.amount.abs())}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isWithdrawal
                                  ? AppColors.walletErrorRed
                                  : AppColors.walletPrimaryGreen,
                            ),
                          ),
                        ),

                        // Balance After Column
                        SizedBox(
                          width: 80,
                          child: Text(
                            _formatCoins(tx.balanceAfter),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.walletNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(WalletTransactionModel tx) {
    if (tx.category == 'withdrawal') {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF1F2),
          shape: BoxShape.circle,
        ),
        child: const Center(child: UpiIconBadge(size: 16)),
      );
    }

    final (icon, color, bg) = switch (tx.category) {
      'quiz_reward' || 'tournament_prize' => (
        Icons.emoji_events_rounded,
        const Color(0xFF00B96B),
        const Color(0xFFE8FDF2),
      ),
      'battle_win' || 'battle' => (
        Icons.sports_kabaddi_rounded,
        const Color(0xFF6366F1),
        const Color(0xFFEEF2FF),
      ),
      'lucky_wheel_win' || 'spin' => (
        Icons.incomplete_circle_rounded,
        const Color(0xFFF59E0B),
        const Color(0xFFFFFBEB),
      ),
      'mock_test' || 'test_purchase' => (
        Icons.description_rounded,
        const Color(0xFF0284C7),
        const Color(0xFFE0F2FE),
      ),
      'referral' => (
        Icons.card_giftcard_rounded,
        const Color(0xFFD97706),
        const Color(0xFFFFF7ED),
      ),
      'daily_login' => (
        Icons.verified_rounded,
        const Color(0xFFEC4899),
        const Color(0xFFFDF2F8),
      ),
      'offer' || 'special' => (
        Icons.redeem_rounded,
        const Color(0xFFE11D48),
        const Color(0xFFFFF1F2),
      ),
      _ => (
        Icons.monetization_on_rounded,
        const Color(0xFF00B96B),
        const Color(0xFFE8FDF2),
      ),
    };

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 16),
    );
  }

  String _getTxDescription(WalletTransactionModel tx) {
    if (tx.referenceId != null && tx.referenceId!.isNotEmpty) {
      return tx.referenceId!;
    }
    return switch (tx.category) {
      'quiz_reward' => 'Completed Full Test (RRB)',
      'battle_win' => 'Won against Rohit',
      'lucky_wheel_win' => 'Daily Spin Reward',
      'mock_test' => 'Scored 80% in Mock Test',
      'referral' => 'Your friend joined',
      'withdrawal' => 'UPI: vikram@upi',
      'daily_login' => 'Login Bonus',
      'offer' => 'Special Event Reward',
      _ => 'Coin Activity',
    };
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = dt.day;
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$day $month $year, ${hour.toString().padLeft(2, '0')}:$minute $ampm';
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
