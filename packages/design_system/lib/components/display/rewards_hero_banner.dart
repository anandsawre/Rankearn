import 'package:flutter/material.dart';
import 'app_hero_banner.dart';

/// RewardsHeroBanner matching the Rankearn Rewards Tab reference design.
/// Powered by the unified [AppHeroBanner] engine.
class RewardsHeroBanner extends StatelessWidget {
  final String? imageAssetPath;
  final VoidCallback? onHowToEarn;
  final VoidCallback? onBannerTap;
  final BorderRadius? borderRadius;

  const RewardsHeroBanner({
    super.key,
    this.imageAssetPath = 'assets/images/rewards_hero_mascot.jpg',
    this.onHowToEarn,
    this.onBannerTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AppHeroBanner.rewards(
      imageAssetPath: imageAssetPath,
      onHowToEarn: onHowToEarn,
      onBannerTap: onBannerTap,
      borderRadius: borderRadius,
    );
  }
}
