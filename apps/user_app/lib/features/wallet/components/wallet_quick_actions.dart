import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class QuickActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color arrowColor;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.arrowColor,
    required this.onTap,
  });
}

/// Mobile Quick Actions Row (4 Cards)
class MobileQuickActionsRow extends StatelessWidget {
  final VoidCallback onWithdraw;
  final VoidCallback onHistory;
  final VoidCallback onEarnMore;
  final VoidCallback onRedeem;
  final VoidCallback? onHowItWorks;
  final VoidCallback? onAddCoins;
  final bool showWithdraw;

  const MobileQuickActionsRow({
    super.key,
    required this.onWithdraw,
    required this.onHistory,
    required this.onEarnMore,
    required this.onRedeem,
    this.onHowItWorks,
    this.onAddCoins,
    this.showWithdraw = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      if (onAddCoins != null)
        QuickActionItem(
          title: 'Add Coins',
          subtitle: 'Buy Packs',
          icon: Icons.add_circle_rounded,
          iconColor: const Color(0xFF00B96B),
          bgColor: const Color(0xFFE8FDF2),
          arrowColor: const Color(0xFF00B96B),
          onTap: onAddCoins!,
        ),
      if (showWithdraw)
        QuickActionItem(
          title: 'Withdraw',
          subtitle: 'To UPI',
          icon: Icons.account_balance_wallet_rounded,
          iconColor: const Color(0xFF00B96B),
          bgColor: const Color(0xFFE8FDF2),
          arrowColor: const Color(0xFF00B96B),
          onTap: onWithdraw,
        )
      else
        QuickActionItem(
          title: 'Redeem',
          subtitle: 'Use Coins',
          icon: Icons.confirmation_number_rounded,
          iconColor: const Color(0xFF8B5CF6),
          bgColor: const Color(0xFFF5F3FF),
          arrowColor: const Color(0xFF8B5CF6),
          onTap: onRedeem,
        ),
      QuickActionItem(
        title: 'History',
        subtitle: 'View all',
        icon: Icons.access_time_rounded,
        iconColor: const Color(0xFF2587F8),
        bgColor: const Color(0xFFEFF6FF),
        arrowColor: const Color(0xFF2587F8),
        onTap: onHistory,
      ),
      if (onAddCoins == null)
        QuickActionItem(
          title: 'Earn More',
          subtitle: 'Play & Earn',
          icon: Icons.card_giftcard_rounded,
          iconColor: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFFFBEB),
          arrowColor: const Color(0xFFF59E0B),
          onTap: onEarnMore,
        ),
      QuickActionItem(
        title: 'Redeem',
        subtitle: 'Offers',
        icon: Icons.confirmation_number_rounded,
        iconColor: const Color(0xFF8B5CF6),
        bgColor: const Color(0xFFF5F3FF),
        arrowColor: const Color(0xFF8B5CF6),
        onTap: onRedeem,
      ),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: item.arrowColor.withAlpha(50),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, color: item.iconColor, size: 26),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.walletNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.walletSecondaryText,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 13,
                          color: item.arrowColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Desktop Quick Actions Card Container
class DesktopQuickActionsCard extends StatelessWidget {
  final VoidCallback onWithdraw;
  final VoidCallback onHistory;
  final VoidCallback onEarnMore;
  final VoidCallback onRedeem;
  final VoidCallback? onHowItWorks;
  final VoidCallback? onAddCoins;
  final bool showWithdraw;

  const DesktopQuickActionsCard({
    super.key,
    required this.onWithdraw,
    required this.onHistory,
    required this.onEarnMore,
    required this.onRedeem,
    this.onHowItWorks,
    this.onAddCoins,
    this.showWithdraw = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      if (onAddCoins != null)
        QuickActionItem(
          title: 'Add Coins',
          subtitle: 'Buy Packs',
          icon: Icons.add_circle_rounded,
          iconColor: const Color(0xFF00B96B),
          bgColor: const Color(0xFFE8FDF2),
          arrowColor: const Color(0xFF00B96B),
          onTap: onAddCoins!,
        ),
      if (showWithdraw)
        QuickActionItem(
          title: 'Withdraw',
          subtitle: 'To UPI',
          icon: Icons.account_balance_wallet_rounded,
          iconColor: const Color(0xFF00B96B),
          bgColor: const Color(0xFFE8FDF2),
          arrowColor: const Color(0xFF00B96B),
          onTap: onWithdraw,
        )
      else
        QuickActionItem(
          title: 'Redeem',
          subtitle: 'Use Coins',
          icon: Icons.confirmation_number_rounded,
          iconColor: const Color(0xFF8B5CF6),
          bgColor: const Color(0xFFF5F3FF),
          arrowColor: const Color(0xFF8B5CF6),
          onTap: onRedeem,
        ),
      QuickActionItem(
        title: 'History',
        subtitle: 'View all',
        icon: Icons.access_time_rounded,
        iconColor: const Color(0xFF2587F8),
        bgColor: const Color(0xFFEFF6FF),
        arrowColor: const Color(0xFF2587F8),
        onTap: onHistory,
      ),
      if (onAddCoins == null)
        QuickActionItem(
          title: 'Earn More',
          subtitle: 'Play & Earn',
          icon: Icons.card_giftcard_rounded,
          iconColor: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFFFBEB),
          arrowColor: const Color(0xFFF59E0B),
          onTap: onEarnMore,
        ),
      QuickActionItem(
        title: 'Redeem',
        subtitle: 'Use Coins',
        icon: Icons.confirmation_number_rounded,
        iconColor: const Color(0xFF8B5CF6),
        bgColor: const Color(0xFFF5F3FF),
        arrowColor: const Color(0xFF8B5CF6),
        onTap: onRedeem,
      ),
    ];

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
          Row(
            children: const [
              Icon(Icons.near_me_rounded, size: 20, color: Color(0xFF2587F8)),
              SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.walletNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: items.map((item) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: item.bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: item.arrowColor.withAlpha(50),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, color: item.iconColor, size: 28),
                          const SizedBox(height: 6),
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.walletNavy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.walletSecondaryText,
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
        ],
      ),
    );
  }
}
