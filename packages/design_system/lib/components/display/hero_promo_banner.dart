import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// Hero Promotional Banner matching the Rankearn Home Dashboard reference
class HeroPromoBanner extends StatelessWidget {
  final VoidCallback onStartLearning;
  final String? imageAssetPath;

  const HeroPromoBanner({
    super.key,
    required this.onStartLearning,
    this.imageAssetPath = 'assets/images/hero_mascot.jpg',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x333920C9),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Background ambient glowing circles
              Positioned(
                top: -40,
                right: 40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(20),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: 80,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandPurpleLight.withAlpha(25),
                  ),
                ),
              ),

              // Main Layout Content
              Padding(
                padding: EdgeInsets.only(
                  left: isCompact ? 12 : 18,
                  top: isCompact ? 14 : 20,
                  bottom: isCompact ? 14 : 18,
                  right: isCompact ? 8 : 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Column: Headlines, Subtitle, CTA, Stat Tags
                    Expanded(
                      flex: isCompact ? 14 : (constraints.maxWidth < 600 ? 13 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bold Title with Golden highlight
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: isCompact ? 20 : 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                                height: 1.15,
                                fontFamily: 'Inter',
                              ),
                              children: const [
                                TextSpan(text: 'Learn\nPractice\n', style: TextStyle(color: Colors.white)),
                                TextSpan(
                                  text: 'Earn Rewards',
                                  style: TextStyle(
                                    color: Color(0xFFFFD633),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Description Subtitle
                          Text(
                            'Take tests, improve your skills\nand earn coins with Rankearn.',
                            style: TextStyle(
                              color: Colors.white.withAlpha(220),
                              fontSize: isCompact ? 10 : 11,
                              fontWeight: FontWeight.w500,
                              height: 1.25,
                            ),
                          ),
                          SizedBox(height: isCompact ? 10 : 14),

                          // CTA Button: "Start Learning →"
                          InkWell(
                            onTap: onStartLearning,
                            borderRadius: AppRadii.borderPill,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD633),
                                borderRadius: AppRadii.borderPill,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Start Learning',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: const Color(0xFF101A3A),
                                        fontSize: isCompact ? 11.0 : 12.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF101A3A),
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: isCompact ? 12 : 18),

                          // Bottom Feature Micro-Tags with Wrap
                          Wrap(
                            spacing: isCompact ? 6 : 10,
                            runSpacing: 4,
                            children: [
                              _buildMicroFeature(
                                icon: Icons.bar_chart_rounded,
                                label: 'Practice\nTests',
                              ),
                              _buildMicroFeature(
                                icon: Icons.monetization_on_rounded,
                                label: 'Win\nCoins',
                              ),
                              _buildMicroFeature(
                                icon: Icons.track_changes_rounded,
                                label: 'Track\nProgress',
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                      // Carousel Page Indicators (•••)
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppRadii.borderPill,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 5,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(100),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 5,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(100),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right Column: Mascot Illustration with floating rewards
                Expanded(
                  flex: 9,
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      // Mascot Image Container
                      Container(
                        height: 200,
                        constraints: const BoxConstraints(maxWidth: 360),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageAssetPath != null
                            ? Image.asset(
                                imageAssetPath!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildFallbackIllustration(),
                              )
                            : _buildFallbackIllustration(),
                      ),

                      // Floating Crown & Script text ("Small Steps Big Results!")
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(80),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withAlpha(40), width: 0.8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Icon(Icons.military_tech_rounded, color: Color(0xFFFFD633), size: 14),
                              Text(
                                'Small Steps',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Text(
                                'Big Results!',
                                style: TextStyle(
                                  color: Color(0xFFFFD633),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
);
}

  Widget _buildMicroFeature({required IconData icon, required String label}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white.withAlpha(220), size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(220),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackIllustration() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF673BF6), Color(0xFF3920C9)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.school_rounded, color: Colors.white, size: 48),
            SizedBox(height: 8),
            Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD633), size: 36),
          ],
        ),
      ),
    );
  }
}
