import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Hero banner for Refer & Earn Management screen.
/// Fully tokenized using design system [AdminHeroCard].
class ReferralsHeroCard extends StatelessWidget {
  final VoidCallback? onRefresh;

  const ReferralsHeroCard({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return AdminHeroCard(
      title: 'Refer & Earn Management',
      subtitle1: 'Manage referral incentives, track viral invitations, reward bonuses and payout thresholds.',
      subtitle2: 'Automate student signup credits, coin conversion tiers, and viral campaign broadcasts.',
      onSync: onRefresh,
      syncTooltip: 'Refresh referral logs',
      trailing: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandPurple.withValues(alpha: 0.1),
              ),
            ),
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.adminViolet, AppColors.brandPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: AppShadows.card,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
