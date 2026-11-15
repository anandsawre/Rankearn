import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../overview/banner_image_data.dart';

/// Promo Banners Management Hero Card
/// Fully tokenized using the design system's [AdminHeroCard].
class BannersHeroCard extends StatelessWidget {
  final VoidCallback? onRefresh;

  const BannersHeroCard({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return AdminHeroCard(
      title: 'Promo Banner',
      titleAccent: 'Management',
      subtitle1: 'Design, publish and track high-converting carousel and spotlight banners.',
      subtitle2: 'Promote live mock tests, tournaments, discounts, and app updates in real-time.',
      onSync: onRefresh,
      syncTooltip: 'Refresh live banners',
      trailing: Image.memory(
        kBannerCharacterBytes,
        height: 120,
        fit: BoxFit.contain,
        alignment: Alignment.bottomRight,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.brandPurple.withValues(alpha: 0.1),
          ),
          child: const Icon(
            Icons.photo_library_rounded,
            color: AppColors.brandPurple,
            size: 48,
          ),
        ),
      ),
    );
  }
}
