import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Notifications Management Hero Card
/// Fully tokenized using the design system's [AdminHeroCard].
class NotificationsHeroCard extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NotificationsHeroCard({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return AdminHeroCard(
      title: 'Notification',
      titleAccent: 'Management',
      subtitle1: 'Create, schedule and manage cross-channel notifications for your candidates and users.',
      subtitle2: 'Deliver instant updates to all candidates or filtered student cohorts.',
      onSync: onRefresh,
      syncTooltip: 'Refresh broadcast history',
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
                Icons.campaign_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: const BoxDecoration(
                  color: AppColors.adminSuccess,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 11,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
