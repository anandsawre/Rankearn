import 'package:flutter/material.dart';
import '../../tokens/radii.dart';

/// Primary Battle Action Button (Green Gradient, Paper Plane or Home Icon)
class BattlePrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;

  const BattlePrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final active = isEnabled && !isLoading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: active ? onPressed : null,
        borderRadius: AppRadii.borderPill,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56.0,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF00C975), Color(0xFF009C5A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
                  ),
            borderRadius: AppRadii.borderPill,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF009C5A).withAlpha(80),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Secondary Battle Action Button (Outlined or Soft Tinted)
class BattleSecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSoftTint; // If true: soft pastel mint background (Cancel button in Screen 1)

  const BattleSecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isSoftTint = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadii.borderPill,
        child: Container(
          height: 54.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isSoftTint ? const Color(0xFFD5F7E6) : Colors.white,
            borderRadius: AppRadii.borderPill,
            border: isSoftTint
                ? null
                : Border.all(color: const Color(0xFF00B96B), width: 2.0),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: const Color(0xFF00A859), size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00A859),
                  letterSpacing: -0.2,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
