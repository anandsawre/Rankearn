import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

enum AppButtonVariant { primary, secondary, outlined, destructive, ghost }

enum AppButtonSize { small, medium, large }

/// Rankearn Reusable Button Component with variant, loading, and icon support.
/// Centrally bound to design system tokens with sleek, modern proportions.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool disabled;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double? width;
  final double? height;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final TextStyle? customTextStyle;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.disabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height,
    this.fullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.customTextStyle,
    this.gradient,
    this.boxShadow,
  });

  /// Factory constructor for Admin Dashboard primary purple gradient action buttons
  const AppButton.adminPrimary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = AppSpacing.adminControlHeight,
    this.fullWidth = false,
  })  : variant = AppButtonVariant.primary,
        size = AppButtonSize.medium,
        backgroundColor = AppColors.adminPurple,
        foregroundColor = Colors.white,
        borderColor = null,
        borderRadius = AppRadii.adminControl,
        customTextStyle = AppTypography.adminButtonPrimary,
        gradient = AppColors.adminPurpleGradient,
        boxShadow = AppShadows.adminPrimaryButton;

  /// Factory constructor for Admin Dashboard secondary white/outlined buttons
  const AppButton.adminSecondary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = AppSpacing.adminControlHeight,
    this.fullWidth = false,
  })  : variant = AppButtonVariant.secondary,
        size = AppButtonSize.medium,
        backgroundColor = Colors.white,
        foregroundColor = AppColors.adminPrimaryText,
        borderColor = AppColors.adminBorder,
        borderRadius = AppRadii.adminControl,
        customTextStyle = AppTypography.adminButtonSecondary,
        gradient = null,
        boxShadow = const [
          BoxShadow(
            color: Color(0x0B0F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ];

  /// Factory constructor for Admin Dashboard ghost/reset buttons
  const AppButton.adminGhost({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = AppSpacing.adminControlHeight,
    this.fullWidth = false,
  })  : variant = AppButtonVariant.ghost,
        size = AppButtonSize.medium,
        backgroundColor = Colors.transparent,
        foregroundColor = AppColors.adminSecondaryText,
        borderColor = null,
        borderRadius = AppRadii.adminControl,
        customTextStyle = AppTypography.adminButtonGhost,
        gradient = null,
        boxShadow = null;

  /// Factory constructor for Admin Dashboard outline/reset buttons with crisp border
  const AppButton.adminOutline({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = AppSpacing.adminControlHeight,
    this.fullWidth = false,
    this.borderColor = AppColors.adminBorder,
    this.foregroundColor = AppColors.adminSecondaryText,
  })  : variant = AppButtonVariant.outlined,
        size = AppButtonSize.medium,
        backgroundColor = Colors.transparent,
        borderRadius = AppRadii.adminControl,
        customTextStyle = AppTypography.adminButtonGhost,
        gradient = null,
        boxShadow = null;

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = !disabled && onPressed != null && !isLoading;

    Color bg;
    Color fg;
    BorderSide? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.brandPrimary;
        fg = AppColors.textOnPrimary;
        break;
      case AppButtonVariant.secondary:
        bg = AppColors.surface;
        fg = AppColors.textPrimary;
        border = const BorderSide(color: AppColors.border, width: 1.2);
        break;
      case AppButtonVariant.outlined:
        bg = Colors.transparent;
        fg = AppColors.brandPrimary;
        border = const BorderSide(color: AppColors.brandPrimary, width: 1.2);
        break;
      case AppButtonVariant.destructive:
        bg = AppColors.errorRose;
        fg = Colors.white;
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.textSecondary;
        break;
    }

    if (effectiveEnabled) {
      if (backgroundColor != null) {
        bg = backgroundColor!;
      }
      if (foregroundColor != null) {
        fg = foregroundColor!;
      }
      if (borderColor != null) {
        border = BorderSide(color: borderColor!, width: 1.0);
      }
    }

    if (!effectiveEnabled && !isLoading) {
      bg = bg == Colors.transparent
          ? Colors.transparent
          : AppColors.surfaceSubtle;
      fg = AppColors.textMuted;
      if (border != null) {
        border = const BorderSide(color: AppColors.borderSubtle);
      }
    }

    EdgeInsets padding;
    double defaultHeight;
    TextStyle textStyle;

    switch (size) {
      case AppButtonSize.small:
        padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
        defaultHeight = 32;
        textStyle = AppTypography.buttonText.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        );
        break;
      case AppButtonSize.medium:
        padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8);
        defaultHeight = 38;
        textStyle = AppTypography.buttonText.copyWith(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        );
        break;
      case AppButtonSize.large:
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
        defaultHeight = 48;
        textStyle = AppTypography.buttonText.copyWith(
          fontSize: 14.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        );
        break;
    }

    if (customTextStyle != null) {
      textStyle = customTextStyle!;
    }

    if (height != null) {
      padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 0);
    }

    final effectiveRadius = borderRadius ?? AppRadii.borderMd;
    final effectiveWidth = fullWidth ? double.infinity : width;
    final effectiveHeight = height ?? defaultHeight;

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: gradient == null ? bg : null,
        gradient: gradient,
        borderRadius: effectiveRadius,
        border: border != null ? Border.fromBorderSide(border) : null,
        boxShadow: effectiveEnabled ? boxShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveEnabled ? onPressed : null,
          borderRadius: effectiveRadius,
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: effectiveWidth == null
                  ? MainAxisSize.min
                  : MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  ),
                  const SizedBox(width: 6),
                ] else if (leadingIcon != null) ...[
                  IconTheme.merge(
                    data: IconThemeData(
                      color: fg,
                      size: size == AppButtonSize.small ? 16 : 18,
                    ),
                    child: leadingIcon!,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: textStyle.copyWith(color: fg),
                      maxLines: 1,
                    ),
                  ),
                ),
                if (!isLoading && trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  IconTheme.merge(
                    data: IconThemeData(
                      color: fg,
                      size: size == AppButtonSize.small ? 16 : 18,
                    ),
                    child: trailingIcon!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
