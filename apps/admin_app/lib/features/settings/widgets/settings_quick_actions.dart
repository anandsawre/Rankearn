import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Quick Actions panel for System Settings & Configuration screen.
/// Fully tokenized using design system [AppColors], [AppSpacing], and [QuickActionsCard].
class SettingsQuickActions extends StatelessWidget {
  final VoidCallback onUpdateSettings;
  final VoidCallback onResetDefaults;
  final VoidCallback onConfigurePayments;
  final VoidCallback onToggleMaintenance;
  final VoidCallback onBackupDatabase;
  final VoidCallback? onCustomize;
  final double? height;

  const SettingsQuickActions({
    super.key,
    required this.onUpdateSettings,
    required this.onResetDefaults,
    required this.onConfigurePayments,
    required this.onToggleMaintenance,
    required this.onBackupDatabase,
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
          label: 'Save\nSettings',
          icon: Icons.save_rounded,
          iconColor: AppColors.brandPurple,
          cardColor: AppColors.brandPurpleLight,
          onTap: onUpdateSettings,
        ),
        QuickActionItemData(
          label: 'Reset\nDefaults',
          icon: Icons.restart_alt_rounded,
          iconColor: AppColors.adminWarning,
          cardColor: AppColors.adminAmberLight,
          onTap: onResetDefaults,
        ),
        QuickActionItemData(
          label: 'Payment\nGateways',
          icon: Icons.credit_card_rounded,
          iconColor: AppColors.adminBlue,
          cardColor: AppColors.adminBlueLight,
          onTap: onConfigurePayments,
        ),
        QuickActionItemData(
          label: 'Maintenance\nMode',
          icon: Icons.build_circle_outlined,
          iconColor: AppColors.brandPink,
          cardColor: AppColors.brandPinkLight,
          onTap: onToggleMaintenance,
        ),
        QuickActionItemData(
          label: 'Backup\nDatabase',
          icon: Icons.cloud_upload_outlined,
          iconColor: AppColors.adminSuccess,
          cardColor: AppColors.adminSuccessLight,
          onTap: onBackupDatabase,
        ),
      ],
    );
  }
}
