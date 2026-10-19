import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/typography.dart';

enum AppButtonVariant { primary, secondary, outlined, destructive, ghost }

enum AppButtonSize { small, medium, large }

/// Rankearn Reusable Button Component with variant, loading, and icon support
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
  });

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
        bg = AppColors.surfaceSubtle;
        fg = AppColors.textPrimary;
        break;
      case AppButtonVariant.outlined:
        bg = Colors.transparent;
        fg = AppColors.brandPrimary;
        border = const BorderSide(color: AppColors.brandPrimary, width: 1.5);
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

    if (!effectiveEnabled && !isLoading) {
      bg = bg == Colors.transparent ? Colors.transparent : AppColors.surfaceSubtle;
      fg = AppColors.textMuted;
      if (border != null) {
        border = const BorderSide(color: AppColors.borderSubtle);
      }
    }

    EdgeInsets padding;
    double height;
    TextStyle textStyle;

    switch (size) {
      case AppButtonSize.small:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        height = 36;
        textStyle = AppTypography.buttonText.copyWith(fontSize: 12);
        break;
      case AppButtonSize.medium:
        padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12);
        height = 46;
        textStyle = AppTypography.buttonText;
        break;
      case AppButtonSize.large:
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
        height = 54;
        textStyle = AppTypography.buttonText.copyWith(fontSize: 15);
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.borderMd,
          side: border ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: effectiveEnabled ? onPressed : null,
          borderRadius: AppRadii.borderMd,
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else if (leadingIcon != null) ...[
                  leadingIcon!,
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: textStyle.copyWith(color: fg),
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isLoading && trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  trailingIcon!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
