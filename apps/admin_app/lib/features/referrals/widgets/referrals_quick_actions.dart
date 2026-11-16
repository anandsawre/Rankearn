import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Quick Actions panel for Refer & Earn Management screen.
/// Fully tokenized using design system [AppColors], [AppSpacing], and [QuickActionsCard].
class ReferralsQuickActions extends StatelessWidget {
  final void Function(String actionId)? onAction;
  final VoidCallback? onCustomize;
  final double? height;

  const ReferralsQuickActions({
    super.key,
    this.onAction,
    this.onCustomize,
    this.height = AppSpacing.adminHeroHeight,
  });

  @override
  Widget build(BuildContext context) {
    return QuickActionsCard(
      onCustomize: onCustomize,
      height: height,
      compact: true,
      actions: [
        QuickActionItemData(
          label: 'Export\nCSV',
          icon: Icons.file_download_outlined,
          iconColor: AppColors.brandPurple,
          cardColor: AppColors.brandPurpleLight,
          onTap: () => onAction?.call('export'),
        ),
        QuickActionItemData(
          label: 'Manage\nRewards',
          icon: Icons.card_giftcard_rounded,
          iconColor: AppColors.adminBlue,
          cardColor: AppColors.adminBlueLight,
          onTap: () => onAction?.call('rewards'),
        ),
        QuickActionItemData(
          label: 'Payout\nRequests',
          icon: Icons.payments_outlined,
          iconColor: AppColors.adminWarning,
          cardColor: AppColors.adminAmberLight,
          onTap: () => onAction?.call('payouts'),
        ),
        QuickActionItemData(
          label: 'Double\nCampaign',
          icon: Icons.bolt_rounded,
          iconColor: AppColors.brandPink,
          cardColor: AppColors.brandPinkLight,
          onTap: () => onAction?.call('campaign'),
        ),
        QuickActionItemData(
          label: 'Send\nBroadcast',
          icon: Icons.send_rounded,
          iconColor: AppColors.adminSuccess,
          cardColor: AppColors.adminSuccessLight,
          onTap: () => onAction?.call('broadcast'),
        ),
      ],
    );
  }
}
