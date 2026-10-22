import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// Unified reusable Metric Card component for user statistics
/// (Coins, Rank, Streak, Attempts, Accuracy, Live Tests, etc.).
class AppMetricCard extends StatelessWidget {
  /// Icon to display in the leading box.
  final IconData? icon;

  /// Custom leading icon widget (if provided, overrides [icon]).
  final Widget? iconWidget;

  /// Tint color for the icon.
  final Color iconColor;

  /// Background color of the icon container. Defaults to soft tint of [iconColor].
  final Color? iconBgColor;

  /// Optional shadow for the icon container.
  final List<BoxShadow>? iconShadow;

  /// Optional custom border radius for the icon container (defaults to 10).
  final BorderRadius? iconBorderRadius;

  /// Metric label (e.g. "Participants", "Rank Position", "Accuracy").
  final String label;

  /// Metric value string (e.g. "5.2K", "#1256", "84%").
  final String value;

  /// Card surface color. Defaults to Colors.white.
  final Color backgroundColor;

  /// Optional card border color.
  final Color? borderColor;

  /// Custom border radius for the outer card. Defaults to AppRadii.borderMd.
  final BorderRadius? borderRadius;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  /// Whether to display a trailing chevron arrow.
  final bool showChevron;

  /// Max lines for the label. Defaults to 2.
  final int maxLabelLines;

  /// Optional custom text style for the label.
  final TextStyle? labelStyle;

  /// Optional custom text style for the value.
  final TextStyle? valueStyle;

  const AppMetricCard({
    super.key,
    this.icon,
    this.iconWidget,
    this.iconColor = AppColors.brandBlue,
    this.iconBgColor,
    this.iconShadow,
    this.iconBorderRadius,
    required this.label,
    required this.value,
    this.backgroundColor = Colors.white,
    this.borderColor,
    this.borderRadius,
    this.onTap,
    this.showChevron = false,
    this.maxLabelLines = 2,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadii.borderMd;
    final effectiveIconBg = iconBgColor ?? iconColor.withValues(alpha: 0.12);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: borderColor ?? const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06101A3A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              children: [
                // Leading Icon Container
                if (iconWidget != null && icon == null)
                  iconWidget!
                else
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: effectiveIconBg,
                      borderRadius: iconBorderRadius ?? BorderRadius.circular(10),
                      boxShadow: iconShadow,
                    ),
                    child: Center(
                      child: iconWidget ??
                          Icon(
                            icon ?? Icons.analytics_rounded,
                            color: iconColor,
                            size: 20,
                          ),
                    ),
                  ),
                const SizedBox(width: 8),

                // Text info: Label & Value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: labelStyle ??
                            const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                        maxLines: maxLabelLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: valueStyle ??
                            const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Optional Chevron
                if (showChevron) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Responsive row or grid wrapper for 4 statistics metric cards.
/// Displays a 4-column row on desktop/tablet, and a 2x2 grid on mobile viewports.
class AppMetricsRow extends StatelessWidget {
  final List<Widget> cards;
  final double breakpoint;
  final double spacing;

  const AppMetricsRow({
    super.key,
    required this.cards,
    this.breakpoint = 640,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          // Horizontal 4-column row
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                Expanded(child: cards[i]),
                if (i < cards.length - 1) SizedBox(width: spacing),
              ],
            ],
          );
        }

        // 2x2 Grid for compact/mobile viewports
        return Column(
          children: [
            Row(
              children: [
                if (cards.isNotEmpty) Expanded(child: cards[0]),
                if (cards.length > 1) ...[
                  SizedBox(width: spacing),
                  Expanded(child: cards[1]),
                ],
              ],
            ),
            if (cards.length > 2) ...[
              SizedBox(height: spacing),
              Row(
                children: [
                  Expanded(child: cards[2]),
                  if (cards.length > 3) ...[
                    SizedBox(width: spacing),
                    Expanded(child: cards[3]),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
