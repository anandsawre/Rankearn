import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../tests/test_series_hero_data.dart';

/// Live Quiz Management Hero Card
/// Recreates the lavender-blue gradient, typography, and live-quiz educational illustration.
class LiveQuizHeroCard extends StatelessWidget {
  const LiveQuizHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFEEF2FF),
            Color(0xFFE5EBFE),
            Color(0xFFDCE3FD),
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

            // Main Row: Left Text + Right Illustration with Live Badges
            Row(
              children: [
                // Left Column: Headlines & Subtitles
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 26, top: 16, bottom: 16, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main Title: "Live Quiz Management"
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Live Quiz ',
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
                                      color: const Color(0xFF5636F5).withAlpha(45),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Subtitle 1
                        const Text(
                          'Create, manage and conduct live quiz sessions for your platform.',
                          style: TextStyle(
                            fontSize: 11.5,
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
                          'Engage users with real-time quizzes, leaderboards and exciting rewards.',
                          style: TextStyle(
                            fontSize: 11.5,
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

                // Right Illustration: 3D Student at laptop with LIVE pill and floating badges
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: SizedBox(
                    width: 220,
                    height: 124,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      clipBehavior: Clip.none,
                      children: [
                        // Student Image
                        Positioned(
                          right: 0,
                          bottom: 0,
                          top: 4,
                          child: Image.memory(
                            kTestSeriesHeroStudentBytes,
                            height: 116,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomRight,
                          ),
                        ),

                        // Floating Student Profile Cards (on the left of laptop)
                        Positioned(
                          left: 10,
                          top: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(220),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFD8DFFB), width: 1),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x105636F5),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildAvatarDot(const Color(0xFF6C5CE7)),
                                const SizedBox(height: 3),
                                _buildAvatarDot(const Color(0xFF00C48C)),
                                const SizedBox(height: 3),
                                _buildAvatarDot(const Color(0xFF2587F8)),
                              ],
                            ),
                          ),
                        ),

                        // Red LIVE Badge pill floating above laptop
                        Positioned(
                          right: 80,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF3B30), Color(0xFFE02424)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF3B30).withAlpha(120),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.white,
                                  size: 6,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Lightbulb floating top right
                        Positioned(
                          right: 12,
                          top: 10,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withAlpha(90),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.lightbulb_rounded,
                              color: Color(0xFFD97706),
                              size: 13,
                            ),
                          ),
                        ),
                      ],
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

  static Widget _buildAvatarDot(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.person,
        size: 9,
        color: Colors.white,
      ),
    );
  }
}
