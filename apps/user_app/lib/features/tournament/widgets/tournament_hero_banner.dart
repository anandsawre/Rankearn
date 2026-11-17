import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Purple Contest Hero Banner tokenized strictly with Centralized Design System
class TournamentHeroBanner extends StatelessWidget {
  final bool isDesktop;
  final VoidCallback? onExploreTap;

  const TournamentHeroBanner({
    super.key,
    required this.isDesktop,
    this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.contestHeroGradient,
        borderRadius: AppRadii.contestHero,
        boxShadow: AppShadows.contestHero,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background decorative circular patterns / glow
          Positioned(
            right: isDesktop ? 60 : 20,
            top: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: isDesktop ? 120 : 50,
            bottom: -30,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.contestHeroGlow.withValues(alpha: 0.08),
              ),
            ),
          ),

          // Main Banner Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? AppSpacing.xxxl : 18,
              vertical: isDesktop ? 28 : 18,
            ),
            child: Row(
              children: [
                // Left Text Section
                Expanded(
                  flex: isDesktop ? 6 : 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Desktop Pill Tag
                      if (isDesktop) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.contestGold,
                            borderRadius: AppRadii.borderPill,
                            boxShadow: AppShadows.contestTag,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                color: AppColors.contestGoldText,
                                size: 14,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Contests',
                                style: AppTypography.contestHeroTag,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Title
                      Text(
                        isDesktop
                            ? 'Compete in Live Contests'
                            : 'Contests',
                        style: isDesktop
                            ? AppTypography.contestHeroTitleDesktop
                            : AppTypography.contestHeroTitleMobile,
                      ),
                      const SizedBox(height: 6),

                      // Subtitle
                      Text(
                        isDesktop
                            ? 'Test your knowledge, beat top players and win exciting rewards!'
                            : 'Compete, participate and win rewards.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isDesktop ? 13.5 : 12,
                          color: Colors.white.withValues(alpha: 0.88),
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 16 : 12),

                      // Explore Button
                      InkWell(
                        onTap: onExploreTap,
                        borderRadius: AppRadii.borderPill,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 18 : 14,
                            vertical: isDesktop ? 9 : 7,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.contestGold,
                            borderRadius: AppRadii.borderPill,
                            boxShadow: AppShadows.contestTag,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explore Contests',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Color(0xFF1E293B),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Right 3D Trophy Graphic Section
                Expanded(
                  flex: isDesktop ? 4 : 5,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 180 : 130,
                        maxHeight: isDesktop ? 140 : 110,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft gold glow behind trophy
                          Container(
                            width: isDesktop ? 110 : 80,
                            height: isDesktop ? 110 : 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.contestGold.withValues(alpha: 0.35),
                                  blurRadius: 32,
                                  spreadRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          // Laurel leaves & trophy
                          Image.asset(
                            'assets/images/tournaments_hero_illustration.jpg',
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Image.asset(
                              'assets/images/daily_tasks_trophy.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.emoji_events_rounded,
                                size: 80,
                                color: AppColors.contestGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
