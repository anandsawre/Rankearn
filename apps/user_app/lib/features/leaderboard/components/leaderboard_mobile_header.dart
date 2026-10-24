import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/leaderboard_model.dart';

/// Mobile Top Green Header matching the Spin & Win Header design.
/// - Emerald-green vertical gradient with soft elevation shadow
/// - Left: Circular gold trophy badge with "Leaderboard" title and tagline
/// - Right: Frosted-glass pill dropdown for selecting scope [🌐 Global ⌵]
class LeaderboardMobileHeader extends StatelessWidget {
  final LeaderboardScope selectedScope;
  final ValueChanged<LeaderboardScope> onScopeChanged;

  const LeaderboardMobileHeader({
    super.key,
    required this.selectedScope,
    required this.onScopeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00B96B), Color(0xFF008C52)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x20008C52),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Left: Trophy Icon + Title & Tagline
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(35),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(60),
                          width: 1.2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFFFFD32A),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Leaderboard',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFamilyFallback: AppTypography.fontFallbacks,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Compete, improve and earn more coins',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFFD1FAE5),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              fontFamilyFallback: AppTypography.fontFallbacks,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // 2. Right: Frosted-Glass Scope Selector Pill [ 🌐 Global ⌵ ]
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF006B3D).withAlpha(160),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withAlpha(60),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: PopupMenuButton<LeaderboardScope>(
                  initialValue: selectedScope,
                  tooltip: 'Change Leaderboard Scope',
                  onSelected: onScopeChanged,
                  offset: const Offset(0, 36),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.borderMd,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: LeaderboardScope.global,
                      child: Row(
                        children: [
                          Icon(
                            Icons.public_rounded,
                            color: AppColors.leaderboardGreen,
                            size: 16,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Global',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: LeaderboardScope.friends,
                      child: Row(
                        children: [
                          Icon(
                            Icons.people_alt_rounded,
                            color: AppColors.leaderboardBlue600,
                            size: 16,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Friends',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: LeaderboardScope.myState,
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: AppColors.leaderboardAmber500,
                            size: 16,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'My State (Bihar)',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.public_rounded,
                        color: Color(0xFFFFD32A),
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        switch (selectedScope) {
                          LeaderboardScope.global => 'Global',
                          LeaderboardScope.friends => 'Friends',
                          LeaderboardScope.myState => 'My State',
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          fontFamilyFallback: AppTypography.fontFallbacks,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
