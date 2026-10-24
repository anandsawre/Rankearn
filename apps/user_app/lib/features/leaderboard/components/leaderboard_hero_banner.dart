import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Desktop Leaderboard Hero Banner matching Reference Image 1
/// Powered by the unified [AppHeroBanner] engine from the centralized design system.
class LeaderboardHeroBanner extends StatelessWidget {
  final BorderRadius? borderRadius;

  const LeaderboardHeroBanner({super.key, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return AppHeroBanner.leaderboard(borderRadius: borderRadius);
  }
}
