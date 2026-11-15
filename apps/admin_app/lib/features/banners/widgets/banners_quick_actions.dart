import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Quick Actions panel for Promo Banners screen.
/// Fully tokenized using design system [AppColors], [AppSpacing], and [QuickActionsCard].
class BannersQuickActions extends StatelessWidget {
  final VoidCallback onNewBanner;
  final VoidCallback onSelectCarousel;
  final VoidCallback onSchedule;
  final VoidCallback onAnalytics;
  final VoidCallback onRefresh;
  final VoidCallback? onCustomize;
  final double? height;

  const BannersQuickActions({
    super.key,
    required this.onNewBanner,
    required this.onSelectCarousel,
    required this.onSchedule,
    required this.onAnalytics,
    required this.onRefresh,
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
          label: 'Create\nBanner',
          icon: Icons.add_photo_alternate_rounded,
          iconColor: AppColors.brandPurple,
          cardColor: AppColors.brandPurpleLight,
          onTap: onNewBanner,
        ),
        QuickActionItemData(
          label: 'Home\nCarousel',
          icon: Icons.view_carousel_rounded,
          iconColor: AppColors.adminBlue,
          cardColor: AppColors.adminBlueLight,
          onTap: onSelectCarousel,
        ),
        QuickActionItemData(
          label: 'Schedule\nDelivery',
          icon: Icons.calendar_today_rounded,
          iconColor: AppColors.adminWarning,
          cardColor: AppColors.adminAmberLight,
          onTap: onSchedule,
        ),
        QuickActionItemData(
          label: 'Banner\nAnalytics',
          icon: Icons.insights_rounded,
          iconColor: AppColors.brandPink,
          cardColor: AppColors.brandPinkLight,
          onTap: onAnalytics,
        ),
        QuickActionItemData(
          label: 'Refresh\nBanners',
          icon: Icons.refresh_rounded,
          iconColor: AppColors.adminSuccess,
          cardColor: AppColors.adminSuccessLight,
          onTap: onRefresh,
        ),
      ],
    );
  }
}
