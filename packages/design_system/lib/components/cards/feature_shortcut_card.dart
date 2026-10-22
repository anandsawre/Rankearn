import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

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
    final effectiveCardBg = cardBackgroundColor ?? iconBackgroundColor.withAlpha(14);
    final effectiveBorderColor = cardBorderColor ?? iconBackgroundColor.withAlpha(40);

    return Container(
      decoration: BoxDecoration(
        color: effectiveCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: effectiveBorderColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
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
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: iconSize,
                    ),
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
    );
  }
}
