import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import 'app_metric_card.dart';

/// TestMetricCard matching the 4 statistics cards in the Tests screen.
/// Powered by the unified [AppMetricCard] core engine.
class TestMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool showChevron;

  const TestMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
    required this.backgroundColor,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppMetricCard(
      icon: icon,
      iconColor: Colors.white,
      iconBgColor: accentColor,
      iconBorderRadius: BorderRadius.circular(12),
      iconShadow: [
        BoxShadow(
          color: accentColor.withAlpha(70),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
      label: label,
      value: value,
      backgroundColor: backgroundColor,
      borderColor: accentColor.withAlpha(45),
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      showChevron: showChevron,
      maxLabelLines: 2,
      labelStyle: const TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        height: 1.15,
      ),
      valueStyle: const TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }
}
