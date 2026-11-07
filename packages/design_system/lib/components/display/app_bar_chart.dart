import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/typography.dart';

/// Reusable vertical bar chart component matching the Rankearn design system.
///
/// Features:
/// - Rounded pill-top bars with smooth vertical gradient
/// - Responsive horizontal grid lines with comma-formatted Y-axis labels
/// - Design token support (`AppColors`, `AppTypography`, `AppRadii`)
class AppBarChart extends StatelessWidget {
  final List<String> dates;
  final List<double> values;
  final double height;
  final List<Color> barColors;
  final double? maxY;
  final List<double>? yLabels;

  const AppBarChart({
    super.key,
    this.dates = const ['Oct 12', 'Oct 13', 'Oct 14', 'Oct 15', 'Oct 16', 'Oct 17', 'Oct 18'],
    this.values = const [620, 780, 940, 1220, 1480, 1720, 1590],
    this.height = 165,
    this.barColors = const [
      Color(0xFF34D399), // lighter emerald green top
      Color(0xFF10B981), // rich emerald green bottom
    ],
    this.maxY,
    this.yLabels,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, height),
          painter: _AppBarChartPainter(
            dates: dates,
            values: values,
            barColors: barColors,
            maxY: maxY,
            yLabels: yLabels,
          ),
        );
      },
    );
  }
}

class _AppBarChartPainter extends CustomPainter {
  final List<String> dates;
  final List<double> values;
  final List<Color> barColors;
  final double? maxY;
  final List<double>? yLabels;

  _AppBarChartPainter({
    required this.dates,
    required this.values,
    required this.barColors,
    this.maxY,
    this.yLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftMargin = 40.0;
    const bottomMargin = 22.0;
    const topMargin = 18.0;
    const rightMargin = 12.0;

    final chartWidth = size.width - leftMargin - rightMargin;
    final chartHeight = size.height - topMargin - bottomMargin;

    if (chartWidth <= 10 || chartHeight <= 10 || values.isEmpty) return;

    final effectiveMaxY = maxY ?? () {
      final maxVal = values.fold<double>(0, (m, v) => math.max(m, v));
      return (maxVal <= 0 ? 100.0 : maxVal * 1.25);
    }();

    final effectiveYLabels = yLabels ?? [
      effectiveMaxY,
      effectiveMaxY * 0.75,
      effectiveMaxY * 0.5,
      effectiveMaxY * 0.25,
      0.0,
    ];

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      fontFamily: AppTypography.fontHeading,
      color: AppColors.textSecondary,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    // Draw Y grid lines & labels
    for (int i = 0; i < effectiveYLabels.length; i++) {
      final yVal = effectiveYLabels[i];
      final yPos = topMargin + (chartHeight * (i / (effectiveYLabels.length - 1)));

      canvas.drawLine(
        Offset(leftMargin, yPos),
        Offset(size.width - rightMargin, yPos),
        gridPaint,
      );

      final formattedVal = yVal == 0
          ? '0'
          : yVal.round().toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (m) => '${m[1]},',
              );

      final tp = TextPainter(
        text: TextSpan(text: formattedVal, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftMargin - tp.width - 6, yPos - tp.height / 2));
    }

    // Draw Bars
    final barCount = dates.length;
    final slotWidth = chartWidth / barCount;
    final barWidth = math.min(slotWidth * 0.58, 28.0);

    for (int i = 0; i < barCount; i++) {
      final normalized = (values[i] / effectiveMaxY).clamp(0.0, 1.0);
      final barHeight = normalized * chartHeight;
      final x = leftMargin + (i * slotWidth) + (slotWidth - barWidth) / 2;
      final y = topMargin + chartHeight - barHeight;

      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      );

      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: barColors.length == 1 ? [barColors.first, barColors.first] : barColors,
        ).createShader(rect);

      canvas.drawRRect(rrect, barPaint);

      // Draw X Label
      final tp = TextPainter(
        text: TextSpan(text: dates[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(leftMargin + (i * slotWidth) + (slotWidth - tp.width) / 2, size.height - tp.height),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AppBarChartPainter oldDelegate) {
    return oldDelegate.dates != dates ||
        oldDelegate.values != values ||
        oldDelegate.barColors != barColors ||
        oldDelegate.maxY != maxY;
  }
}

/// A centralized, reusable Bar Chart Card component tokenized with
/// [AppColors], [AppRadii], [AppShadows], and [AppTypography].
class AppBarChartCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color iconColor;
  final Color? iconBg;
  final Widget? trailingHeader;
  final List<String> dates;
  final List<double> values;
  final List<Color> barColors;
  final double? maxY;
  final List<double>? yLabels;
  final double chartHeight;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const AppBarChartCard({
    super.key,
    required this.title,
    this.icon = Icons.people_alt_rounded,
    this.iconColor = const Color(0xFF3B82F6),
    this.iconBg,
    this.trailingHeader,
    this.dates = const ['Oct 12', 'Oct 13', 'Oct 14', 'Oct 15', 'Oct 16', 'Oct 17', 'Oct 18'],
    this.values = const [620, 780, 940, 1220, 1480, 1720, 1590],
    this.barColors = const [
      Color(0xFF34D399),
      Color(0xFF10B981),
    ],
    this.maxY,
    this.yLabels,
    this.chartHeight = 165,
    this.height = 260,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (icon != null) ...[
                      if (iconBg != null)
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: iconBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Icon(icon, color: Colors.white, size: 16),
                        )
                      else
                        Icon(icon, color: iconColor, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingHeader != null) ...[
                const SizedBox(width: 8),
                trailingHeader!,
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Chart Area
          Expanded(
            child: AppBarChart(
              dates: dates,
              values: values,
              height: chartHeight,
              barColors: barColors,
              maxY: maxY,
              yLabels: yLabels,
            ),
          ),
        ],
      ),
    );
  }
}

