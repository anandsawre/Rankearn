import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'wallet_icons.dart';

/// Single Wallet Summary Stat Card
class WalletSummaryCard extends StatelessWidget {
  final String title;
  final int coins;
  final Widget iconWidget;
  final bool showInfoIcon;
  final VoidCallback? onInfoTap;

  const WalletSummaryCard({
    super.key,
    required this.title,
    required this.coins,
    required this.iconWidget,
    this.showInfoIcon = false,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final rupeeValue = (coins * 0.10).toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.walletSecondaryText,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatCoins(coins),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.walletNavy,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                InkWell(
                  onTap: onInfoTap,
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          '≈ ₹$rupeeValue',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.walletSecondaryText,
                          ),
                        ),
                      ),
                      if (showInfoIcon) ...[
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 13,
                          color: AppColors.walletSecondaryText,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
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

/// 3-Card Summary Row for Desktop / Tablet
class DesktopWalletSummaryRow extends StatelessWidget {
  final int currentCoins;
  final int totalEarned;
  final int totalWithdrawn;
  final VoidCallback? onInfoTap;

  const DesktopWalletSummaryRow({
    super.key,
    required this.currentCoins,
    required this.totalEarned,
    required this.totalWithdrawn,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 620;

        if (isSmall) {
          return Column(
            children: [
              _buildCoinsCard(),
              const SizedBox(height: 10),
              _buildEarnedCard(),
              const SizedBox(height: 10),
              _buildWithdrawnCard(),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _buildCoinsCard()),
            const SizedBox(width: 14),
            Expanded(child: _buildEarnedCard()),
            const SizedBox(width: 14),
            Expanded(child: _buildWithdrawnCard()),
          ],
        );
      },
    );
  }

  Widget _buildCoinsCard() {
    return WalletSummaryCard(
      title: 'Total Coins',
      coins: currentCoins,
      showInfoIcon: true,
      onInfoTap: onInfoTap,
      iconWidget: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7DC),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFE082), width: 1.5),
        ),
        child: const Center(child: RankearnCurrencyCoin(size: 30)),
      ),
    );
  }

  Widget _buildEarnedCard() {
    return WalletSummaryCard(
      title: 'Total Earned',
      coins: totalEarned,
      iconWidget: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFE8FDF2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
        ),
        child: const Center(
          child: Icon(
            Icons.card_giftcard_rounded,
            color: Color(0xFF00B96B),
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawnCard() {
    return WalletSummaryCard(
      title: 'Total Withdrawn',
      coins: totalWithdrawn,
      iconWidget: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECDD3), width: 1.5),
        ),
        child: const Center(
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: Color(0xFFF43F5E),
            size: 26,
          ),
        ),
      ),
    );
  }
}
