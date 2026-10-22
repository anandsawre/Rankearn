import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// TestsHeroBanner matching the Rankearn Tests Tab reference screenshot
class TestsHeroBanner extends StatelessWidget {
  final String? imageAssetPath;
  final VoidCallback? onBannerTap;
  final VoidCallback? onStartPracticing;

  const TestsHeroBanner({
    super.key,
    this.imageAssetPath = 'assets/images/tests_hero_mascot.jpg',
    this.onBannerTap,
    this.onStartPracticing,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE8F4FD), // Soft sky blue
                Color(0xFFF0FDF8), // Soft mint green
                Color(0xFFF7FAFE), // Soft neutral
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFD6E4F0),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Ambient soft circular glows
              Positioned(
                top: -30,
                left: -20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF38BDF8).withAlpha(35),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                right: 80,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF34D399).withAlpha(30),
                  ),
                ),
              ),

              // Main content: Headlines on Left, 3D Character Illustration on Right
              Padding(
                padding: EdgeInsets.only(
                  left: isCompact ? 16 : 24,
                  top: isCompact ? 16 : 22,
                  bottom: isCompact ? 16 : 22,
                  right: isCompact ? 8 : 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Column: Big Headline & Subtitle & CTA Button
                    Expanded(
                      flex: isCompact ? 12 : 11,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Tests',
                            style: TextStyle(
                              fontSize: isCompact ? 28 : 34,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.8,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Practice smarter, score higher\nand earn real rewards.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isCompact ? 12 : 13.5,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                          if (onStartPracticing != null) ...[
                            const SizedBox(height: 14),
                            InkWell(
                              onTap: onStartPracticing,
                              borderRadius: AppRadii.borderPill,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 12 : 16,
                                  vertical: isCompact ? 6 : 8,
                                ),
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
                                  children: const [
                                    Flexible(
                                      child: Text(
                                        'Start Practicing',
                                        style: TextStyle(
                                          color: Color(0xFF101A3A),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Color(0xFF101A3A),
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Right Column: 3D Educational Mascot Illustration with floating script badge
                    Expanded(
                      flex: 10,
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Container(
                            height: isCompact ? 140 : 175,
                            constraints: const BoxConstraints(maxWidth: 260),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: imageAssetPath != null
                                ? Image.asset(
                                    imageAssetPath!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildFallbackIllustration(),
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
                                color: Colors.black.withAlpha(75),
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

  Widget _buildFallbackIllustration() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 40),
            SizedBox(height: 6),
            Icon(Icons.checklist_rtl_rounded, color: Color(0xFF10B981), size: 32),
          ],
        ),
      ),
    );
  }
}
