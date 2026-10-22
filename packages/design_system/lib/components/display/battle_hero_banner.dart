import 'package:flutter/material.dart';
import 'app_hero_banner.dart';

/// BattleHeroBanner matching the Rankearn 1v1 Quiz Battle reference design.
/// Powered by the unified [AppHeroBanner] engine.
class BattleHeroBanner extends StatelessWidget {
  final String? imageAssetPath;
  final VoidCallback? onStartBattle;
  final VoidCallback? onBannerTap;
  final BorderRadius? borderRadius;

  const BattleHeroBanner({
    super.key,
    this.imageAssetPath = 'assets/images/battle_hero_mascot.jpg',
    this.onStartBattle,
    this.onBannerTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AppHeroBanner.battle(
      imageAssetPath: imageAssetPath,
      onStartBattle: onStartBattle,
      onBannerTap: onBannerTap,
      borderRadius: borderRadius,
    );
  }
}
