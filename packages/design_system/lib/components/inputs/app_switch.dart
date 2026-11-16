import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// Semantic color variants for [AppSwitch].
enum AppSwitchVariant {
  /// Admin/Brand purple accent (#7628E8). Ideal for settings, toggles, features.
  primary,

  /// Semantic green accent (#10B981). Ideal for status toggles (Active / Inactive).
  success,

  /// Consumer brand purple (#5636F5).
  brand,

  /// Warning / Destructive red (#F43F5E).
  danger,
}

/// Sizing scale for [AppSwitch], aligned with Rankearn design system icon metrics.
enum AppSwitchSize {
  /// Regular size: scaled to match standard app form & field icon size (18–20px thumb).
  regular,

  /// Compact small size: scaled to match table, badge & dense row icon size (14–15px thumb).
  small,
}

/// Rankearn Centralized Design System - Tokenized Switch / Toggle Component.
///
/// Implements pixel-perfect, design-token-aligned toggle switches with
/// crisp state colors, smooth physics, and proportions calibrated to match
/// the application's icon sizing (18-20px standard, 14-15px dense).
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.variant = AppSwitchVariant.primary,
    this.size = AppSwitchSize.regular,
    this.scale,
    this.activeTrackColor,
    this.activeThumbColor,
    this.inactiveTrackColor,
    this.inactiveThumbColor,
    this.autofocus = false,
    this.focusNode,
  });

  /// Success variant (Emerald Green track #10B981, White thumb).
  /// Perfect for Active / Inactive status switches.
  const AppSwitch.success({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = AppSwitchSize.regular,
    this.scale,
    this.activeTrackColor,
    this.activeThumbColor,
    this.inactiveTrackColor,
    this.inactiveThumbColor,
    this.autofocus = false,
    this.focusNode,
  }) : variant = AppSwitchVariant.success;

  /// Primary / Admin Purple variant (#7628E8 track, White thumb).
  /// Perfect for admin forms, settings, and scheduling toggles.
  const AppSwitch.primary({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = AppSwitchSize.regular,
    this.scale,
    this.activeTrackColor,
    this.activeThumbColor,
    this.inactiveTrackColor,
    this.inactiveThumbColor,
    this.autofocus = false,
    this.focusNode,
  }) : variant = AppSwitchVariant.primary;

  /// Compact small switch for tight spaces, tables, or modal dialogs.
  const AppSwitch.small({
    super.key,
    required this.value,
    required this.onChanged,
    this.variant = AppSwitchVariant.primary,
    this.scale,
    this.activeTrackColor,
    this.activeThumbColor,
    this.inactiveTrackColor,
    this.inactiveThumbColor,
    this.autofocus = false,
    this.focusNode,
  }) : size = AppSwitchSize.small;

  final bool value;
  final ValueChanged<bool>? onChanged;
  final AppSwitchVariant variant;
  final AppSwitchSize size;

  /// Optional custom scale multiplier. Defaults to 0.72 for regular and 0.60 for small.
  final double? scale;

  final Color? activeTrackColor;
  final Color? activeThumbColor;
  final Color? inactiveTrackColor;
  final Color? inactiveThumbColor;
  final bool autofocus;
  final FocusNode? focusNode;

  Color _resolveActiveTrackColor() {
    if (activeTrackColor != null) return activeTrackColor!;
    switch (variant) {
      case AppSwitchVariant.success:
        return AppColors.adminSuccess;
      case AppSwitchVariant.primary:
        return AppColors.adminPurple;
      case AppSwitchVariant.brand:
        return AppColors.brandPurple;
      case AppSwitchVariant.danger:
        return AppColors.adminDanger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveActiveTrack = _resolveActiveTrackColor();
    final effectiveActiveThumb = activeThumbColor ?? Colors.white;
    final effectiveInactiveTrack = inactiveTrackColor ?? const Color(0xFFE4E4E7);
    final effectiveInactiveThumb = inactiveThumbColor ?? AppColors.adminSecondaryText;

    // Scale calibrated directly against app icon scale:
    // Regular: 0.72x scale gives ~18px thumb & 23px track height (matching 18-20px icons).
    // Small: 0.60x scale gives ~15px thumb & 19px track height (matching 14-15px dense icons).
    final effectiveScale = scale ?? (size == AppSwitchSize.small ? 0.60 : 0.72);
    final boxWidth = size == AppSwitchSize.small ? 34.0 : 40.0;
    final boxHeight = size == AppSwitchSize.small ? 22.0 : 26.0;

    final switchWidget = Switch(
      value: value,
      onChanged: onChanged,
      autofocus: autofocus,
      focusNode: focusNode,
      activeThumbColor: effectiveActiveThumb,
      activeTrackColor: effectiveActiveTrack,
      inactiveThumbColor: effectiveInactiveThumb,
      inactiveTrackColor: effectiveInactiveTrack,
      trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        if (states.contains(WidgetState.disabled)) {
          return AppColors.adminBorder.withValues(alpha: 0.5);
        }
        return AppColors.adminSecondaryText.withValues(alpha: 0.35);
      }),
      trackOutlineWidth: WidgetStateProperty.resolveWith<double?>((states) {
        if (states.contains(WidgetState.selected)) {
          return 0.0;
        }
        return 1.5;
      }),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return SizedBox(
      width: boxWidth,
      height: boxHeight,
      child: Center(
        child: Transform.scale(
          scale: effectiveScale,
          alignment: Alignment.center,
          child: switchWidget,
        ),
      ),
    );
  }
}

/// Tokenized Admin Status Switch Field matching standard single-line controls
/// (AppTextField, AppDropdown) with height [AppSpacing.adminControlHeight].
///
/// Features:
/// - Semantic active/inactive status icon and text label on the left.
/// - Emerald green tokenized [AppSwitch] on the right.
/// - Full-box tap-to-toggle interaction.
/// - Tokenized background, rounded borders, and hover states.
class AppStatusSwitchField extends StatelessWidget {
  const AppStatusSwitchField({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeLabel = 'Status: Active',
    this.inactiveLabel = 'Status: Inactive',
    this.activeIcon = Icons.check_circle_rounded,
    this.inactiveIcon = Icons.pause_circle_rounded,
    this.activeColor = AppColors.adminSuccess,
    this.inactiveColor = AppColors.adminSecondaryText,
    this.height = AppSpacing.adminControlHeight,
    this.backgroundColor = AppColors.adminBackground,
    this.borderColor = AppColors.adminBorder,
    this.borderRadius = AppRadii.adminControl,
    this.padding = const EdgeInsets.symmetric(horizontal: 14),
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String activeLabel;
  final String inactiveLabel;
  final IconData? activeIcon;
  final IconData? inactiveIcon;
  final Color activeColor;
  final Color inactiveColor;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final currentColor = value ? activeColor : inactiveColor;
    final currentIcon = value ? activeIcon : inactiveIcon;
    final currentLabel = value ? activeLabel : inactiveLabel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
        borderRadius: borderRadius,
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currentIcon != null) ...[
                      Icon(
                        currentIcon,
                        size: 18,
                        color: currentColor,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        currentLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: currentColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppSwitch.success(
                value: value,
                onChanged: enabled ? onChanged : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tokenized Setting Switch Tile for rows with an optional icon, title,
/// optional subtitle, and trailing [AppSwitch].
class AppSwitchTile extends StatelessWidget {
  const AppSwitchTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.variant = AppSwitchVariant.primary,
    this.enabled = true,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 6),
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final AppSwitchVariant variant;
  final bool enabled;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
      borderRadius: AppRadii.borderMd,
      child: Padding(
        padding: contentPadding,
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 18, color: AppColors.adminSecondaryText),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.adminTablePrimary.copyWith(fontSize: 13),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.adminTableSecondary,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            AppSwitch(
              value: value,
              variant: variant,
              size: AppSwitchSize.small,
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}
