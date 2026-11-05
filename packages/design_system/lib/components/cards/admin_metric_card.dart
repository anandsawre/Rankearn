import 'package:flutter/material.dart';
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
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16);

    final cardContent = Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: effectiveRadius,
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Icon Squircle / Circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor ?? color,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor ?? Colors.white, size: 22),
          ),
          const SizedBox(width: 12),

          // 2. Middle Value and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (growth != null && growth!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: isGrowthPositive
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(4),
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
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              growth!,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isGrowthPositive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (badge != null) ...[
                      badge!,
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
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
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              height: 32,
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
