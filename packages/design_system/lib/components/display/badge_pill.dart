import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/typography.dart';

/// Rankearn Coin Display Pill (Header & Wallet)
class AppCoinPill extends StatelessWidget {
  final int coins;
  final VoidCallback? onTap;

  const AppCoinPill({
    super.key,
    required this.coins,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.coinGoldLight,
      borderRadius: AppRadii.borderPill,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.borderPill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: AppRadii.borderPill,
            border: Border.all(color: AppColors.coinGold.withAlpha(100), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on, color: AppColors.coinGold, size: 16),
              const SizedBox(width: 5),
              Text(
                '$coins',
                style: AppTypography.titleSmall.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFB45309), // Amber 700
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rankearn PRO Member Badge
class AppProBadge extends StatelessWidget {
  final double scale;

  const AppProBadge({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: AppRadii.borderPill,
        boxShadow: [
          BoxShadow(
            color: AppColors.coinGold.withAlpha(80),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.white, size: 10 * scale),
          SizedBox(width: 3 * scale),
          Text(
            'PRO',
            style: AppTypography.microTag.copyWith(
              color: Colors.white,
              fontSize: 9 * scale,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic Status Pill (Active, Pending, Suspended, Completed, etc.)
class AppStatusPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const AppStatusPill({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
  });

  factory AppStatusPill.active({String label = 'Active'}) =>
      AppStatusPill(label: label, bg: AppColors.brandPrimaryLight, fg: AppColors.brandPrimaryDark);

  factory AppStatusPill.pending({String label = 'Pending'}) =>
      AppStatusPill(label: label, bg: AppColors.coinGoldLight, fg: const Color(0xFFB45309));

  factory AppStatusPill.rejected({String label = 'Rejected'}) =>
      AppStatusPill(label: label, bg: AppColors.errorRoseLight, fg: AppColors.errorRose);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.borderPill,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.microTag.copyWith(
          color: fg,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
