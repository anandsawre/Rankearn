import 'package:flutter/material.dart';
import 'app_hero_banner.dart';

/// LiveTestsHeroBanner matching the Rankearn Live Tests reference screenshot.
/// Powered by the unified [AppHeroBanner] engine.
class LiveTestsHeroBanner extends StatelessWidget {
  final String? imageAssetPath;
  final VoidCallback? onJoinLiveTest;
  final VoidCallback? onBannerTap;
  final BorderRadius? borderRadius;

  const LiveTestsHeroBanner({
    super.key,
    this.imageAssetPath = 'assets/images/live_tests_hero_mascot.jpg',
    this.onJoinLiveTest,
    this.onBannerTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AppHeroBanner.liveTests(
      imageAssetPath: imageAssetPath,
      onJoinLiveTest: onJoinLiveTest,
      onBannerTap: onBannerTap,
      borderRadius: borderRadius,
    );
  }
}
