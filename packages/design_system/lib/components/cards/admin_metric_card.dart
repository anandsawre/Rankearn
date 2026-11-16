import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/typography.dart';
import '../display/sparkline_painter.dart';

/// AdminMetricCard represents a high-density, pixel-perfect KPI summary card
/// designed for the Admin Dashboard overview and analytics panels.
class AdminMetricCard extends StatelessWidget {
  /// The title label of the metric (e.g. "Total Users", "Active Players").
  final String title;

  /// The primary numeric or formatted string value (e.g. "12,458", "2").
  final String value;

  /// The primary thematic color for the icon background and sparkline curve.
  final Color color;

  /// Optional custom background color for the circular icon box. Defaults to [color].
  final Color? iconBgColor;

  /// Optional icon color. Defaults to Colors.white.
  final Color? iconColor;

  /// The leading icon displayed inside the colored circular container.
  final IconData icon;

  /// Optional contextual description or trend subtitle (e.g. "Registered platform users").
  final String subtitle;

  /// Optional percentage or growth label (e.g. "+12%"). If null or empty, no growth badge is shown.
  final String? growth;

  /// Whether the growth percentage is positive (green upward) or negative (red downward).
  final bool isGrowthPositive;

  /// Optional custom badge widget (e.g. animated live pill) rendered alongside value/growth.
  final Widget? badge;

  /// Optional 5-10 numeric points for rendering the smooth trailing sparkline chart.
  final List<double>? sparklineData;

  /// Custom trailing widget if replacing the default sparkline chart.
  final Widget? trailing;

  /// Callback when the card is pressed.
  final VoidCallback? onTap;

  /// Explicit card width. If null, the card sizes to parent constraints.
  final double? width;

  /// Border radius for the outer card. Defaults to 16.
  final BorderRadius? borderRadius;

  const AdminMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.iconBgColor,
    this.iconColor,
    this.growth,
    this.isGrowthPositive = true,
    this.badge,
    this.sparklineData,
    this.trailing,
    this.onTap,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadii.adminCard;
    final effectiveIconBg = iconBgColor ?? color.withValues(alpha: 0.12);
    final effectiveIconColor = iconColor ?? color;

    final cardContent = Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: effectiveRadius,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: AppShadows.adminCard,
      ),
      child: Row(
        children: [
          // 1. Icon Squircle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: effectiveIconBg,
              borderRadius: AppRadii.adminControl,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: effectiveIconColor, size: 20),
          ),
          const SizedBox(width: 10),

          // 2. Middle Value and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.adminMetricLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: AppTypography.adminMetricValue,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    if (growth != null && growth!.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: isGrowthPositive
                              ? AppColors.adminSuccessLight
                              : AppColors.adminDangerLight,
                          borderRadius: AppRadii.badge,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isGrowthPositive
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              size: 9,
                              color: isGrowthPositive
                                  ? AppColors.adminSuccess
                                  : AppColors.adminDanger,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              growth!,
                              style: AppTypography.adminBadge.copyWith(
                                fontSize: 9.5,
                                color: isGrowthPositive
                                    ? AppColors.adminSuccess
                                    : AppColors.adminDanger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (badge != null) ...[
                      const SizedBox(width: 4),
                      badge!,
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.adminTableSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 3. Trailing Sparkline or Custom Widget
          if (trailing != null)
            trailing!
          else if (sparklineData != null && sparklineData!.length >= 2) ...[
            const SizedBox(width: 6),
            SizedBox(
              width: 54,
              height: 28,
              child: CustomPaint(
                painter: SparklinePainter(
                  data: sparklineData!,
                  lineColor: color,
                  strokeWidth: 2.0,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: effectiveRadius,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
