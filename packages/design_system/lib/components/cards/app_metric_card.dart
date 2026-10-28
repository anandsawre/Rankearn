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

  /// Optional watermark icon to show faintly in the background.
  final IconData? watermarkIcon;

  /// Whether to render decorative ambient background shapes (gradient, orb, ring, watermark).
  final bool showDecorativeBackground;

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
    this.watermarkIcon,
    this.showDecorativeBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadii.borderMd;
    final effectiveIconBg = iconBgColor ?? iconColor.withValues(alpha: 0.12);
    final themeColor = iconBgColor ?? iconColor;

    final effectiveGradient = showDecorativeBackground
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(themeColor.withAlpha(26), Colors.white),
              Color.alphaBlend(themeColor.withAlpha(10), Colors.white),
              backgroundColor,
            ],
          )
        : null;

    final effectiveBorderColor = borderColor ??
        (showDecorativeBackground
            ? themeColor.withAlpha(50)
            : const Color(0xFFE2E8F0));

    final effectiveShadow = [
      if (showDecorativeBackground)
        BoxShadow(
          color: themeColor.withAlpha(20),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      const BoxShadow(
        color: Color(0x06101A3A),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: effectiveGradient == null ? backgroundColor : null,
        gradient: effectiveGradient,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: effectiveBorderColor,
          width: 1.1,
        ),
        boxShadow: effectiveShadow,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Stack(
          children: [
            // Decorative background elements
            if (showDecorativeBackground) ...[
              // 1. Soft Halo Glow in Top Right
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeColor.withAlpha(20),
                  ),
                ),
              ),

              // 2. Subtle Concentric Arc Ring
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: themeColor.withAlpha(18),
                      width: 1.0,
                    ),
                  ),
                ),
              ),

              // 3. Faint Watermark Icon
              if (watermarkIcon != null || icon != null)
                Positioned(
                  right: showChevron ? 20 : 6,
                  bottom: -4,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: -0.12,
                      child: Icon(
                        watermarkIcon ?? icon,
                        size: 46,
                        color: themeColor.withAlpha(22),
                      ),
                    ),
                  ),
                ),
            ],

            // Card Interactive Content
            Material(
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
                            borderRadius:
                                iconBorderRadius ?? BorderRadius.circular(10),
                            boxShadow: iconShadow,
                          ),
                          child: Center(
                            child:
                                iconWidget ??
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
                              style:
                                  labelStyle ??
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
                              style:
                                  valueStyle ??
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

                      // Optional Themed Chevron Pill
                      if (showChevron) ...[
                        const SizedBox(width: 4),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: themeColor.withAlpha(24),
                            border: Border.all(
                              color: themeColor.withAlpha(50),
                              width: 0.8,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 14,
                              color: themeColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
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
