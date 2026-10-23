import 'package:flutter/material.dart';
import '../../tokens/radii.dart';
import '../buttons/app_button.dart';

/// Primary Battle Action Button
/// Centrally standardized through Rankearn AppButton (variant: primary)
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
    this.height = 46.0,
    this.borderRadius = AppRadii.borderPill,
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
          ? Icon(icon, size: 19)
          : null,
    );
  }
}

/// Secondary Battle Action Button
/// Centrally standardized through Rankearn AppButton (variant: outlined / secondary)
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
    this.height = 46.0,
    this.borderRadius = AppRadii.borderPill,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: isSoftTint ? AppButtonVariant.secondary : AppButtonVariant.outlined,
      size: AppButtonSize.large,
      fullWidth: width == null,
      width: width,
      height: height,
      borderRadius: borderRadius,
      leadingIcon: icon != null
          ? Icon(icon, size: 19)
          : null,
    );
  }
}
