import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../ai_test_creator_hero_data.dart';

class AiTestCreatorHeroCard extends StatelessWidget {
  const AiTestCreatorHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
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
            // Decorative background glowing circular accents
            Positioned(
              left: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(90),
                ),
              ),
            ),
            Positioned(
              right: 180,
              bottom: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF5636F5).withAlpha(15),
                ),
              ),
            ),

            // Content Row
            Row(
              children: [
                // Left Text Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, top: 16, bottom: 16, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main Title with Purple Accent
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'AI Test ',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF101A3A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Creator',
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
                        const SizedBox(height: 5),

                        // Subtitle 1
                        const Text(
                          'Generate high-quality tests instantly using AI.',
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
                          'Create custom tests, choose subjects, topics, difficulty levels and get complete question sets with solutions.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMuted,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Illustration: 3D Student with AI Laptop, idea bulb & checklist
                Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 2),
                  child: Image.memory(
                    kAiTestCreatorHeroIllustrationBytes,
                    height: 118,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomRight,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 140,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.auto_awesome_rounded,
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
