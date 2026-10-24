import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'wallet_icons.dart';

/// Mobile Transaction Card Tile matching mobile reference screenshot
class WalletTransactionTile extends StatelessWidget {
  final WalletTransactionModel transaction;
  final VoidCallback? onTap;

  const WalletTransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.amount > 0 || transaction.type == 'earn';
    final isWithdrawal =
        transaction.category == 'withdrawal' || transaction.type == 'spend';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.walletBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category Icon Badge
              _buildCategoryBadge(transaction),
              const SizedBox(width: 12),

              // Title and Date/Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transaction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.walletNavy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDateTime(transaction.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.walletSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount & Balance After + Chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${isPositive ? '+ ' : '- '}${_formatCoins(transaction.amount.abs())} Coins',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isWithdrawal
                          ? AppColors.walletErrorRed
                          : AppColors.walletPrimaryGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Balance: ${_formatCoins(transaction.balanceAfter)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.walletSecondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(WalletTransactionModel tx) {
    if (tx.category == 'withdrawal') {
      return Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF1F2),
          shape: BoxShape.circle,
        ),
        child: const Center(child: UpiIconBadge(size: 20)),
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
      _ => (
        Icons.monetization_on_rounded,
        const Color(0xFF00B96B),
        const Color(0xFFE8FDF2),
      ),
    };

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 20),
    );
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
