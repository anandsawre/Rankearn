import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../tournaments_hero_data.dart';

/// Tournaments Management Hero Card
/// Recreating the exact gradient, typography, and 3D tournament illustration from the reference image.
class TournamentsHeroCard extends StatelessWidget {
  const TournamentsHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFECEFFE),
            Color(0xFFE5E9FE),
            Color(0xFFDCE2FD),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8DFFB), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x063B4896),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            // Soft background aura behind illustration
            Positioned(
              right: 60,
              top: -20,
              bottom: -20,
              width: 240,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(70),
                ),
              ),
            ),

            // Main Content Row
            Row(
              children: [
                // Left Column: Headlines & Subtitles
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 26, top: 18, bottom: 18, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main Title: "Tournaments Management"
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Tournaments ',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Management',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF5636F5),
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF5636F5).withAlpha(40),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle 1
                        const Text(
                          'Create and manage quiz tournaments for your platform.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),

                        // Subtitle 2
                        const Text(
                          'Run competitive events, track participants and reward winners.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Illustration: 3D Boy with trophy, podium & gifts
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 0),
                  child: Image.memory(
                    kTournamentsHeroIllustrationBytes,
                    height: 120,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomRight,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 140,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFF5636F5),
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
