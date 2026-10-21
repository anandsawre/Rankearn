import 'package:flutter/material.dart';
import '../lucky_wheel_hero_data.dart';

class LuckyWheelHeroCard extends StatelessWidget {
  const LuckyWheelHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEFF4FF),
            Color(0xFFF3EEFF),
            Color(0xFFF8F5FF),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F8), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x065636F5),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background soft circles
          Positioned(
            top: -20,
            left: 200,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5636F5).withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: 260,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF9F0A).withValues(alpha: 0.05),
              ),
            ),
          ),

          // Content Row
          Row(
            children: [
              // Left: Title and Subtitles
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Lucky Wheel ',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF101A3A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'Management',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF5636F5),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Subtitle line 1
                      const Text(
                        'Create and manage lucky wheel campaigns for your platform.',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF536789),
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Subtitle line 2
                      const Text(
                        'Set rewards, spin rules, track participation and boost user engagement.',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF536789),
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // Right: 3D Illustration
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
                child: Image.memory(
                  kLuckyWheelHeroIllustrationBytes,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => Image.asset(
                    'assets/images/lucky_wheel_hero_illustration.png',
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.donut_large_rounded,
                      size: 80,
                      color: Color(0xFF5636F5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
