import 'package:flutter/material.dart';
import '../../tokens/radii.dart';

/// LiveTestsHeroBanner matching the Rankearn Live Tests reference screenshot
class LiveTestsHeroBanner extends StatelessWidget {
  final String? imageAssetPath;
  final VoidCallback? onJoinLiveTest;
  final VoidCallback? onBannerTap;

  const LiveTestsHeroBanner({
    super.key,
    this.imageAssetPath = 'assets/images/live_tests_hero_mascot.jpg',
    this.onJoinLiveTest,
    this.onBannerTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
        final isVeryCompact = constraints.maxWidth < 360;
        final isDesktop = constraints.maxWidth >= 900;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0B0625), // Deep navy stage night
                Color(0xFF1B0E54), // Electric purple
                Color(0xFF281062), // Magenta purple ambient
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x331B0E54),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Ambient Neon Glows
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEC4899).withAlpha(45),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: 60,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF38BDF8).withAlpha(35),
                  ),
                ),
              ),

              // Main Layout Content
              Padding(
                padding: EdgeInsets.only(
                  left: isVeryCompact ? 14 : (isCompact ? 16 : 24),
                  top: isVeryCompact ? 14 : 20,
                  bottom: isVeryCompact ? 16 : 22,
                  right: isVeryCompact ? 8 : (isCompact ? 12 : 20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Column: LIVE badge, Title, Subtitle, CTA
                        Expanded(
                          flex: isCompact ? 13 : (isDesktop ? 10 : 11),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 1. LIVE Pill Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                                  ),
                                  borderRadius: AppRadii.borderPill,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x40F43F5E),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.sensors_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // 2. Main Title (Live in white, Tests in Gold)
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: isVeryCompact ? 24 : (isCompact ? 28 : 34),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.6,
                                    height: 1.15,
                                    fontFamily: 'Inter',
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Live ',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    TextSpan(
                                      text: 'Tests',
                                      style: TextStyle(color: Color(0xFFFFD633)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),

                              // 3. Subtitle description
                              Text(
                                'Compete in real-time with thousands of students and win exciting rewards!',
                                style: TextStyle(
                                  fontSize: isVeryCompact ? 11 : 12.5,
                                  color: const Color(0xFFE2E8F0),
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 14),

                              // 4. Join Live Test CTA Button
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: onJoinLiveTest ?? onBannerTap,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isVeryCompact ? 14 : 18,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD633),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x33FFD633),
                                            blurRadius: 10,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Join Live Test',
                                            style: TextStyle(
                                              color: const Color(0xFF101A3A),
                                              fontSize: isVeryCompact ? 12 : 13.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Color(0xFF101A3A),
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right Column: Mascot Illustration
                        const SizedBox(width: 8),
                        Expanded(
                          flex: isCompact ? 9 : (isDesktop ? 8 : 9),
                          child: Container(
                            height: isVeryCompact ? 140 : (isCompact ? 160 : (isDesktop ? 220 : 190)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: imageAssetPath != null
                                ? Image.asset(
                                    imageAssetPath!,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    errorBuilder: (context, error, stackTrace) => _buildFallbackIllustration(),
                                  )
                                : _buildFallbackIllustration(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Feature highlights row (Trophy, Gift, People)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withAlpha(20),
                          width: 1,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildHighlightItem(
                              icon: Icons.emoji_events_rounded,
                              iconColor: const Color(0xFFFFD633),
                              label: 'Real-time\nRanking',
                              isCompact: isVeryCompact,
                            ),
                            Container(width: 1, height: 24, color: Colors.white.withAlpha(30)),
                            _buildHighlightItem(
                              icon: Icons.card_giftcard_rounded,
                              iconColor: const Color(0xFFF43F5E),
                              label: 'Win\nCoins',
                              isCompact: isVeryCompact,
                            ),
                            Container(width: 1, height: 24, color: Colors.white.withAlpha(30)),
                            _buildHighlightItem(
                              icon: Icons.public_rounded,
                              iconColor: const Color(0xFF38BDF8),
                              label: 'Compete\nAcross India',
                              isCompact: isVeryCompact,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Carousel Dots (Active white pill, inactive dots)
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 18,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(80),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(80),
                              shape: BoxShape.circle,
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

  Widget _buildHighlightItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool isCompact,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: isCompact ? 15 : 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: isCompact ? 9.5 : 11,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackIllustration() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B1578), Color(0xFF1E105C)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.sensors_rounded,
          color: Color(0xFFFFD633),
          size: 64,
        ),
      ),
    );
  }
}
