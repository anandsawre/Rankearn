import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Quick Actions panel for Notifications Management screen.
/// Fully tokenized using design system [AppColors], [AppSpacing], and [QuickActionsCard].
class NotificationsQuickActions extends StatelessWidget {
  final VoidCallback onNewBroadcast;
  final VoidCallback onPushChannel;
  final VoidCallback onInAppChannel;
  final VoidCallback onSchedule;
  final VoidCallback onTargetAll;
  final VoidCallback onHistorySync;
  final VoidCallback? onCustomize;
  final double? height;

  const NotificationsQuickActions({
    super.key,
    required this.onNewBroadcast,
    required this.onPushChannel,
    required this.onInAppChannel,
    required this.onSchedule,
    required this.onTargetAll,
    required this.onHistorySync,
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
          label: 'New\nBroadcast',
          icon: Icons.add_alert_rounded,
          iconColor: AppColors.brandPurple,
          cardColor: AppColors.brandPurpleLight,
          onTap: onNewBroadcast,
        ),
        QuickActionItemData(
          label: 'Push\nAlert',
          icon: Icons.notifications_active_rounded,
          iconColor: AppColors.adminBlue,
          cardColor: AppColors.adminBlueLight,
          onTap: onPushChannel,
        ),
        QuickActionItemData(
          label: 'In-App\nNotice',
          icon: Icons.chat_bubble_outline_rounded,
          iconColor: AppColors.adminSuccess,
          cardColor: AppColors.adminSuccessLight,
          onTap: onInAppChannel,
        ),
        QuickActionItemData(
          label: 'Schedule\nAlert',
          icon: Icons.schedule_rounded,
          iconColor: AppColors.adminWarning,
          cardColor: AppColors.adminAmberLight,
          onTap: onSchedule,
        ),
        QuickActionItemData(
          label: 'Target\nAll Users',
          icon: Icons.groups_rounded,
          iconColor: AppColors.brandPink,
          cardColor: AppColors.brandPinkLight,
          onTap: onTargetAll,
        ),
        QuickActionItemData(
          label: 'Delivery\nHistory',
          icon: Icons.history_rounded,
          iconColor: AppColors.adminSky,
          cardColor: AppColors.adminSkyLight,
          onTap: onHistorySync,
        ),
      ],
    );
  }
}
