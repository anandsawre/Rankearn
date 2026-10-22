import 'package:flutter/material.dart';
import 'app_hero_banner.dart';

/// Hero Promotional Banner matching the Rankearn Home Dashboard reference.
/// Powered by the unified [AppHeroBanner] engine.
class HeroPromoBanner extends StatelessWidget {
  final VoidCallback onStartLearning;
  final String? imageAssetPath;
  final BorderRadius? borderRadius;

  const HeroPromoBanner({
    super.key,
    required this.onStartLearning,
    this.imageAssetPath = 'assets/images/hero_mascot.jpg',
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AppHeroBanner.home(
      imageAssetPath: imageAssetPath,
      onStartLearning: onStartLearning,
      borderRadius: borderRadius,
    );
  }
}
