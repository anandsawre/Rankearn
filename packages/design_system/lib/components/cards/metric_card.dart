import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import 'app_metric_card.dart';

/// MetricCard for user statistics (My Coins, Daily Streak, Tests Attempted, My Rank).
/// Powered by the unified [AppMetricCard] core engine.
class MetricCard extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final Color backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool showChevron;

  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.backgroundColor = Colors.white,
    this.borderColor,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppMetricCard(
      iconWidget: icon,
      label: label,
      value: value,
      backgroundColor: backgroundColor,
      borderColor: borderColor ?? AppColors.borderSubtle,
      borderRadius: AppRadii.borderLg,
      onTap: onTap,
      showChevron: showChevron,
      maxLabelLines: 1,
      labelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
      valueStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }
}
