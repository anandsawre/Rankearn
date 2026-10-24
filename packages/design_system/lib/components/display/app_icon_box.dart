import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

enum AppIconBoxVariant {
  solid, // Vibrant solid background with white icon (e.g. Quick Actions style)
  soft, // Subtle tinted background with colored icon (e.g. Metric cards style)
  outline, // Border with transparent background
  flat, // Plain transparent background
}

enum AppIconBoxShape {
  rounded, // Rounded rectangle (borderMd / radius 14)
  circle, // Full circle (pill)
  square, // Sharp corners
}

/// Centralized Rankearn Icon Container Component
class AppIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final AppIconBoxVariant variant;
  final AppIconBoxShape shape;
  final BorderRadius? customBorderRadius;
  final VoidCallback? onTap;
  final String? tooltip;
  final String? badge;

  const AppIconBox({
    super.key,
    required this.icon,
    this.color = AppColors.brandPrimary,
    this.iconColor,
    this.size = 48.0,
    this.iconSize = 24.0,
    this.variant = AppIconBoxVariant.solid,
    this.shape = AppIconBoxShape.rounded,
    this.customBorderRadius,
    this.onTap,
    this.tooltip,
    this.badge,
  });

  /// Factory for Quick Action style icon boxes (solid flat vibrant background)
  factory AppIconBox.action({
    Key? key,
    required IconData icon,
    required Color color,
    double size = 48.0,
    double iconSize = 24.0,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    return AppIconBox(
      key: key,
      icon: icon,
      color: color,
      iconColor: Colors.white,
      size: size,
      iconSize: iconSize,
      variant: AppIconBoxVariant.solid,
      shape: AppIconBoxShape.rounded,
      onTap: onTap,
      tooltip: tooltip,
    );
  }

  /// Factory for metric/analytics style icon boxes (soft tinted background)
  factory AppIconBox.metric({
    Key? key,
    required IconData icon,
    required Color color,
    double size = 42.0,
    double iconSize = 20.0,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    return AppIconBox(
      key: key,
      icon: icon,
      color: color,
      iconColor: color,
      size: size,
      iconSize: iconSize,
      variant: AppIconBoxVariant.soft,
      shape: AppIconBoxShape.rounded,
      onTap: onTap,
      tooltip: tooltip,
    );
  }

  BorderRadius _getBorderRadius() {
    if (customBorderRadius != null) return customBorderRadius!;
    switch (shape) {
      case AppIconBoxShape.circle:
        return AppRadii.borderPill;
      case AppIconBoxShape.square:
        return BorderRadius.zero;
      case AppIconBoxShape.rounded:
        return BorderRadius.circular(size * 0.29); // ~14px for 48px
    }
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case AppIconBoxVariant.solid:
        return color;
      case AppIconBoxVariant.soft:
        return color.withAlpha(25); // ~10% opacity soft tint
      case AppIconBoxVariant.outline:
      case AppIconBoxVariant.flat:
        return Colors.transparent;
    }
  }

  Color _getEffectiveIconColor() {
    if (iconColor != null) return iconColor!;
    switch (variant) {
      case AppIconBoxVariant.solid:
        return Colors.white;
      case AppIconBoxVariant.soft:
      case AppIconBoxVariant.outline:
      case AppIconBoxVariant.flat:
        return color;
    }
  }

  Border? _getBorder() {
    if (variant == AppIconBoxVariant.outline) {
      return Border.all(color: color, width: 1.5);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = _getBorderRadius();
    Widget content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: borderRadius,
        border: _getBorder(),
      ),
      child: Center(
        child: Icon(icon, size: iconSize, color: _getEffectiveIconColor()),
      ),
    );

    if (badge != null && badge!.isNotEmpty) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.errorRose,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: content,
        ),
      );
    }

    if (tooltip != null) {
      content = Tooltip(message: tooltip!, child: content);
    }

    return content;
  }
}
