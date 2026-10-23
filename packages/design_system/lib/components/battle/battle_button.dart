import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../buttons/app_button.dart';

/// Primary Battle Action Button (Green Gradient, Paper Plane or Home Icon)
/// Centrally standardized through Rankearn AppButton and Design System Tokens
class BattlePrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double height;

  const BattlePrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 56.0,
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
      borderRadius: AppRadii.borderPill,
      gradient: const LinearGradient(
        colors: [AppColors.battleGreen, AppColors.battleGreenDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      boxShadow: isEnabled && !isLoading
          ? const [
              BoxShadow(
                color: Color(0x33008C52),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ]
          : null,
      leadingIcon: icon != null
          ? Icon(icon, color: Colors.white, size: 20)
          : null,
      customTextStyle: const TextStyle(
        fontSize: 16.5,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.2,
        fontFamily: 'Inter',
      ),
    );
  }
}

/// Secondary Battle Action Button (Outlined White or Soft Tinted)
/// Centrally standardized through Rankearn AppButton and Design System Tokens
class BattleSecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSoftTint;
  final double? width;
  final double height;

  const BattleSecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isSoftTint = false,
    this.width,
    this.height = 54.0,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: AppButtonVariant.outlined,
      size: AppButtonSize.large,
      fullWidth: width == null,
      width: width,
      height: height,
      borderRadius: AppRadii.borderPill,
      backgroundColor: isSoftTint ? AppColors.battleMintBg : Colors.white,
      foregroundColor: AppColors.battleGreenDark,
      borderColor: isSoftTint ? Colors.transparent : AppColors.battleGreen,
      leadingIcon: icon != null
          ? Icon(icon, color: AppColors.battleGreenDark, size: 20)
          : null,
      customTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.battleGreenDark,
        letterSpacing: -0.2,
        fontFamily: 'Inter',
      ),
    );
  }
}
