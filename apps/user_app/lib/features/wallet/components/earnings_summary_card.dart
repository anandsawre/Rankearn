import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'wallet_icons.dart';

class EarningsSummaryCard extends StatelessWidget {
  final int totalEarned;
  final int totalWithdrawn;
  final VoidCallback? onViewDetails;

  const EarningsSummaryCard({
    super.key,
    required this.totalEarned,
    required this.totalWithdrawn,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final earnedRupees = (totalEarned * 0.10).toStringAsFixed(2);
    final withdrawnRupees = (totalWithdrawn * 0.10).toStringAsFixed(2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Bar chart icon + Title + "View Details"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 22,
                      color: Color(0xFFF59E0B),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your Earnings',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.walletNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onViewDetails,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2587F8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Two stats side by side (or stacked if very narrow)
          LayoutBuilder(
            builder: (context, constraints) {
              final isVeryNarrow = constraints.maxWidth < 270;
              if (isVeryNarrow) {
                return Column(
                  children: [
                    _buildEarnedStat(totalEarned, earnedRupees),
                    const SizedBox(height: 12),
                    _buildWithdrawnStat(totalWithdrawn, withdrawnRupees),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildEarnedStat(totalEarned, earnedRupees)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildWithdrawnStat(totalWithdrawn, withdrawnRupees),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEarnedStat(int totalEarned, String earnedRupees) {
    return Row(
      children: [
        const RankearnCurrencyCoin(size: 34),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total Coins Earned',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.walletSecondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatCoins(totalEarned),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.walletNavy,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '≈ ₹$earnedRupees',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00B96B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawnStat(int totalWithdrawn, String withdrawnRupees) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Color(0xFFE8FDF2),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: Color(0xFF00B96B),
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total Withdrawn',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.walletSecondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatCoins(totalWithdrawn),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.walletNavy,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '≈ ₹$withdrawnRupees',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00B96B),
                ),
              ),
            ],
          ),
        ),
      ],
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
