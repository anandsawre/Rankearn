import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../buttons/app_button.dart';

/// Primary Battle Action Button
/// Standardized through Rankearn centralized AppButton (variant: primary)
class BattlePrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const BattlePrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 48.0,
    this.borderRadius = AppRadii.borderMd,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
      size: AppButtonSize.large,
      isLoading: isLoading,
      disabled: !isEnabled,
      fullWidth: width == null,
      width: width,
      height: height,
      borderRadius: borderRadius,
      leadingIcon: icon != null
          ? Icon(icon, color: AppColors.textOnPrimary, size: 20)
          : null,
    );
  }
}

/// Secondary Battle Action Button (Outlined or Soft Tinted)
/// Standardized through Rankearn centralized AppButton (variant: outlined / secondary)
class BattleSecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSoftTint;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const BattleSecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isSoftTint = false,
    this.width,
    this.height = 48.0,
    this.borderRadius = AppRadii.borderMd,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isSoftTint ? const Color(0xFF00A859) : AppColors.brandPrimary;

    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: isSoftTint ? AppButtonVariant.secondary : AppButtonVariant.outlined,
      size: AppButtonSize.large,
      backgroundColor: isSoftTint ? const Color(0xFFD5F7E6) : Colors.white,
      foregroundColor: fg,
      borderColor: isSoftTint ? null : AppColors.brandPrimary,
      fullWidth: width == null,
      width: width,
      height: height,
      borderRadius: borderRadius,
      leadingIcon: icon != null
          ? Icon(icon, color: fg, size: 20)
          : null,
    );
  }
}
