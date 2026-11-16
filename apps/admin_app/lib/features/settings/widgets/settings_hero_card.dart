import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Hero banner for System Settings & Configuration tab matching design tokens.
class SettingsHeroCard extends StatelessWidget {
  final VoidCallback? onResetDefaults;
  final VoidCallback? onUpdateSettings;

  const SettingsHeroCard({
    super.key,
    this.onResetDefaults,
    this.onUpdateSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AdminHeroCard(
      title: 'System Settings',
      subtitle1: 'Configure and manage your platform, features, rewards, payments and general settings.',
      subtitle2: 'All operational parameters and rules are synced across candidates and admin nodes.',
      onSync: onUpdateSettings,
      syncTooltip: 'Update system settings',
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
                Icons.settings_rounded,
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
