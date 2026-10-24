import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/typography.dart';

/// Rankearn Coin Display Pill (Header & Wallet) matching reference image
class AppCoinPill extends StatelessWidget {
  final int coins;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;
  final bool compact;

  const AppCoinPill({
    super.key,
    required this.coins,
    this.onTap,
    this.onAddTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7DC),
        borderRadius: AppRadii.borderPill,
        border: Border.all(color: const Color(0xFFFFE082), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.horizontal(
              left: const Radius.circular(999),
              right: compact ? const Radius.circular(999) : Radius.zero,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: compact ? 3 : 4,
                top: compact ? 2 : 3,
                bottom: compact ? 2 : 3,
                right: compact ? 6 : 6,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: compact ? 18 : 22,
                    height: compact ? 18 : 22,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: compact ? 13 : 16,
                      ),
                    ),
                  ),
                  SizedBox(width: compact ? 4 : 6),
                  Text(
                    _formatCoins(coins),
                    style: TextStyle(
                      fontSize: compact ? 11 : 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!compact)
            InkWell(
              onTap: onAddTap ?? onTap,
              borderRadius: AppRadii.borderPill,
              child: Container(
                margin: const EdgeInsets.only(right: 3, left: 2),
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.brandGreen,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.add, color: Colors.white, size: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatCoins(int amount) {
    if (amount >= 1000) {
      final str = amount.toString();
      final regex = RegExp(r'(\d+?)(?=(\d{3})+$)');
      return str.replaceAllMapped(regex, (match) => '${match[1]},');
    }
    return '$amount';
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

  factory AppStatusPill.active({String label = 'Active'}) => AppStatusPill(
    label: label,
    bg: AppColors.brandPrimaryLight,
    fg: AppColors.brandPrimaryDark,
  );

  factory AppStatusPill.pending({String label = 'Pending'}) => AppStatusPill(
    label: label,
    bg: AppColors.coinGoldLight,
    fg: const Color(0xFFB45309),
  );

  factory AppStatusPill.rejected({String label = 'Rejected'}) => AppStatusPill(
    label: label,
    bg: AppColors.errorRoseLight,
    fg: AppColors.errorRose,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadii.borderPill),
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
