import 'package:flutter/material.dart';
import '../users_hero_data.dart';

/// Users Management Hero Card with soft lavender gradient and mascot illustration
class UsersHeroCard extends StatelessWidget {
  const UsersHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEFF3FF),
            Color(0xFFE8EEFF),
            Color(0xFFDFE8FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE5FC), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x065636F5),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative gradient dots
          Positioned(
            left: 24,
            top: 20,
            child: Container(
              width: 140,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(50),
              ),
            ),
          ),

          // Content Row
          Row(
            children: [
              // Left: Title & Subtitle
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 28, top: 18, bottom: 18, right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Heading: Users Management
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Users ',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF101A3A),
                                letterSpacing: -0.6,
                                height: 1.1,
                              ),
                            ),
                            TextSpan(
                              text: 'Management',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF5636F5),
                                letterSpacing: -0.6,
                                height: 1.1,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF5636F5).withAlpha(40),
                                    blurRadius: 12,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Description
                      const Text(
                        'Manage platform users, view their activity, enrollments and performance.',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF536789),
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),

                      // Secondary line
                      const Text(
                        'Keep your user base engaged and growing.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF7B8DA8),
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // Right: Mascot Illustration
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Image.memory(
                  kUsersHeroIllustrationBytes,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                  height: 128,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 140,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.people_alt_rounded,
                        size: 56,
                        color: Color(0xFF5636F5),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
