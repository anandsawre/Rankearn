import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

enum WalletFilterCategory {
  all('All Transactions'),
  earned('Earned'),
  withdrawals('Withdrawals'),
  rewards('Rewards'),
  offers('Offers');

  final String label;
  const WalletFilterCategory(this.label);
}

class WalletTransactionFilters extends StatelessWidget {
  final WalletFilterCategory activeFilter;
  final ValueChanged<WalletFilterCategory> onFilterSelected;
  final bool isDesktop;
  final bool showWithdrawals;

  const WalletTransactionFilters({
    super.key,
    required this.activeFilter,
    required this.onFilterSelected,
    this.isDesktop = true,
    this.showWithdrawals = true,
  });

  @override
  Widget build(BuildContext context) {
    var availableCategories = isDesktop
        ? WalletFilterCategory.values
        : [
            WalletFilterCategory.all,
            WalletFilterCategory.earned,
            WalletFilterCategory.withdrawals,
            WalletFilterCategory.rewards,
          ];

    if (!showWithdrawals) {
      availableCategories = availableCategories
          .where((c) => c != WalletFilterCategory.withdrawals)
          .toList();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: availableCategories.map((category) {
          final isSelected = activeFilter == category;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => onFilterSelected(category),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 16 : 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.walletPrimaryGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category.label,
                  style: TextStyle(
                    fontSize: isDesktop ? 13 : 12,
                    fontWeight: isSelected
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.walletNavy,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
