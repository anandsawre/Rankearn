import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

/// Reusable Feature Shortcut Widget (Icon Squircle + Label)
class FeatureShortcutCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBackgroundColor;
  final Color? cardBackgroundColor;
  final Color? cardBorderColor;
  final VoidCallback onTap;
  final double iconSize;

  const FeatureShortcutCard({
    super.key,
    required this.icon,
    required this.label,
    required this.iconBackgroundColor,
    this.cardBackgroundColor,
    this.cardBorderColor,
    required this.onTap,
    this.iconSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveCardBg =
        cardBackgroundColor ?? iconBackgroundColor.withAlpha(14);
    final effectiveBorderColor =
        cardBorderColor ?? iconBackgroundColor.withAlpha(45);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(iconBackgroundColor.withAlpha(24), Colors.white),
            Color.alphaBlend(iconBackgroundColor.withAlpha(10), Colors.white),
            effectiveCardBg,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: effectiveBorderColor, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: iconBackgroundColor.withAlpha(18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          const BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative background elements
            // 1. Top-Right Soft Orb
            Positioned(
              top: -18,
              right: -18,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBackgroundColor.withAlpha(18),
                ),
              ),
            ),

            // 2. Top-Right Concentric Ring
            Positioned(
              top: -26,
              right: -26,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconBackgroundColor.withAlpha(16),
                    width: 1.2,
                  ),
                ),
              ),
            ),

            // 3. Faint Watermark Icon
            Positioned(
              right: -6,
              bottom: 2,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: -0.15,
                  child: Icon(
                    icon,
                    size: 48,
                    color: iconBackgroundColor.withAlpha(20),
                  ),
                ),
              ),
            ),

            // 4. Subtle Accent Sparkle Dot
            Positioned(
              top: 12,
              left: 10,
              child: Container(
                width: 3.5,
                height: 3.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBackgroundColor.withAlpha(45),
                ),
              ),
            ),

            // Foreground Content
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: iconBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: iconBackgroundColor.withAlpha(70),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(icon, color: Colors.white, size: iconSize),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
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
    );
  }
}
