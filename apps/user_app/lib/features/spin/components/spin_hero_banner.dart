import 'package:flutter/material.dart';

/// Rounded mint-green hero banner matching the Spin the Wheel reference:
/// - Title: "Spin the Wheel" ("Wheel" highlighted in emerald green)
/// - Subtitle: "Win coins, rewards and more!"
/// - Right: Cheering 3D student mascot with floating gold coins & sparkles
class SpinHeroBanner extends StatelessWidget {
  const SpinHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE8FDF5), // Soft pastel mint
            Color(0xFFD6F9EB), // Seafoam mint
            Color(0xFFE0FBF0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFA7F3D0).withAlpha(180),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C00B96B),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Ambient soft glow on top left
            Positioned(
              top: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(90),
                ),
              ),
            ),

            // Content Row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
              child: Row(
                children: [
                  // Left: Titles
                  Expanded(
                    flex: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Inter',
                              letterSpacing: -0.6,
                              height: 1.15,
                            ),
                            children: [
                              TextSpan(
                                text: 'Spin the ',
                                style: TextStyle(color: Color(0xFF10194F)),
                              ),
                              TextSpan(
                                text: 'Wheel',
                                style: TextStyle(color: Color(0xFF00B96B)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Win coins, rewards and more!',
                          style: TextStyle(
                            color: Color(0xFF586B9B),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: Mascot Illustration
                  Expanded(
                    flex: 9,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 96,
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/spin_hero_mascot.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackMascot(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackMascot() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFE8FDF5), Color(0xFFA7F3D0)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1500B96B),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Floating Gold Coin Top-Left
          Positioned(
            top: 6,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFD32A),
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
          // Floating Gold Coin Bottom-Right
          Positioned(
            bottom: 8,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF59E0B),
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 11,
              ),
            ),
          ),
          // Sparkle
          const Positioned(
            top: 8,
            right: 14,
            child: Icon(Icons.auto_awesome, color: Color(0xFF00B96B), size: 13),
          ),
          // Student Avatar in Green Hoodie Cheering
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00B96B),
                ),
                child: const Icon(
                  Icons.sentiment_very_satisfied_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF008C52),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'WINNER!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 8,
                    letterSpacing: 0.5,
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
