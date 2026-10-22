import 'package:flutter/material.dart';
import 'app_hero_banner.dart';

/// TestsHeroBanner matching the Rankearn Tests Tab reference screenshot.
/// Powered by the unified [AppHeroBanner] engine.
class TestsHeroBanner extends StatelessWidget {
  final String? imageAssetPath;
  final VoidCallback? onBannerTap;
  final VoidCallback? onStartPracticing;
  final BorderRadius? borderRadius;

  const TestsHeroBanner({
    super.key,
    this.imageAssetPath = 'assets/images/tests_hero_mascot.jpg',
    this.onBannerTap,
    this.onStartPracticing,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AppHeroBanner.tests(
      imageAssetPath: imageAssetPath,
      onStartPracticing: onStartPracticing ?? onBannerTap,
      borderRadius: borderRadius,
    );
  }
}
