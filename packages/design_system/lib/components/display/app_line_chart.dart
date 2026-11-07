import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/typography.dart';

/// Reusable smooth area / spline line chart component matching the Rankearn design system.
///
/// Features:
/// - Smooth cubic bezier curve with gradient fill
/// - Responsive horizontal grid lines with comma-formatted Y-axis labels
/// - Highlighted point with interactive / static floating tooltip card
/// - Design token support (`AppColors`, `AppTypography`, `AppRadii`)
class AppLineChart extends StatelessWidget {
  final List<String> dates;
  final List<double> values;
  final int? highlightedIndex;
  final String? tooltipDate;
  final String? tooltipValue;
  final double height;
  final Color lineColor;
  final Color? fillColor;
  final double? maxY;
  final List<double>? yLabels;

  const AppLineChart({
    super.key,
    this.dates = const ['Oct 12', 'Oct 13', 'Oct 14', 'Oct 15', 'Oct 16', 'Oct 17', 'Oct 18'],
    this.values = const [500, 650, 800, 950, 1200, 1520, 1400],
    this.highlightedIndex = 5,
    this.tooltipDate = 'Oct 17, 2026',
    this.tooltipValue = '1,520 attempts',
    this.height = 165,
    this.lineColor = const Color(0xFF6366F1),
    this.fillColor,
    this.maxY,
    this.yLabels,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, height),
          painter: _AppLineChartPainter(
            dates: dates,
            values: values,
            highlightedIndex: highlightedIndex,
            tooltipDate: tooltipDate,
            tooltipValue: tooltipValue,
            lineColor: lineColor,
            fillColor: fillColor,
            maxY: maxY,
            yLabels: yLabels,
          ),
        );
      },
    );
  }
}

class _AppLineChartPainter extends CustomPainter {
  final List<String> dates;
  final List<double> values;
  final int? highlightedIndex;
  final String? tooltipDate;
  final String? tooltipValue;
  final Color lineColor;
  final Color? fillColor;
  final double? maxY;
  final List<double>? yLabels;

  _AppLineChartPainter({
    required this.dates,
    required this.values,
    this.highlightedIndex,
    this.tooltipDate,
    this.tooltipValue,
    required this.lineColor,
    this.fillColor,
    this.maxY,
    this.yLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftMargin = 45.0;
    const bottomMargin = 22.0;
    const topMargin = 26.0;
    const rightMargin = 16.0;

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
      tp.paint(canvas, Offset(leftMargin - tp.width - 8, yPos - tp.height / 2));
    }

    // Points calculation
    final points = <Offset>[];
    final count = dates.length;
    final dx = count > 1 ? (chartWidth / (count - 1)) : 0.0;

    for (int i = 0; i < count; i++) {
      final x = leftMargin + (i * dx);
      final normalizedY = (values[i] / effectiveMaxY).clamp(0.0, 1.0);
      final y = topMargin + chartHeight - (normalizedY * chartHeight);
      points.add(Offset(x, y));

      // Draw X Label
      final tp = TextPainter(
        text: TextSpan(text: dates[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - tp.height));
    }

    if (points.isEmpty) return;

    // Build smooth cubic path
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final c1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final c2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p1.dx, p1.dy);
    }

    // Gradient fill path
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, topMargin + chartHeight)
      ..lineTo(points.first.dx, topMargin + chartHeight)
      ..close();

    final fillBase = fillColor ?? lineColor;
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          fillBase.withAlpha(60),
          fillBase.withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(leftMargin, topMargin, chartWidth, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke path
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    // Draw circular dots
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      if (i == highlightedIndex) continue;
      canvas.drawCircle(points[i], 3.5, dotPaint);
      canvas.drawCircle(points[i], 3.5, dotBorderPaint);
    }

    // Draw Highlighted Point & Tooltip
    if (highlightedIndex != null &&
        highlightedIndex! >= 0 &&
        highlightedIndex! < points.length) {
      final hlPoint = points[highlightedIndex!];

      // Outer glow ring
      canvas.drawCircle(
        hlPoint,
        6.5,
        Paint()
          ..color = lineColor.withAlpha(40)
          ..style = PaintingStyle.fill,
      );
      // Main circle
      canvas.drawCircle(
        hlPoint,
        4.5,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.fill,
      );
      // White center
      canvas.drawCircle(
        hlPoint,
        2.5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );

      // Tooltip Card
      final tooltipWidth = 96.0;
      final tooltipHeight = 36.0;
      final maxTtLeft = (size.width - rightMargin - tooltipWidth < leftMargin)
          ? leftMargin
          : size.width - rightMargin - tooltipWidth;
      final ttLeft = (hlPoint.dx - tooltipWidth / 2).clamp(leftMargin, maxTtLeft);
      final ttTop = (hlPoint.dy - tooltipHeight - 8).clamp(2.0, size.height);

      final shadowRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(ttLeft, ttTop, tooltipWidth, tooltipHeight),
        const Radius.circular(8),
      );

      // Shadow
      canvas.drawRRect(
        shadowRRect,
        Paint()
          ..color = Colors.black.withAlpha(20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Card surface
      canvas.drawRRect(
        shadowRRect,
        Paint()
          ..color = AppColors.surface
          ..style = PaintingStyle.fill,
      );

      // Card border
      canvas.drawRRect(
        shadowRRect,
        Paint()
          ..color = AppColors.borderSubtle
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      // Downward pointer arrow
      final arrowPath = Path()
        ..moveTo(hlPoint.dx - 5, ttTop + tooltipHeight)
        ..lineTo(hlPoint.dx + 5, ttTop + tooltipHeight)
        ..lineTo(hlPoint.dx, ttTop + tooltipHeight + 5)
        ..close();
      canvas.drawPath(arrowPath, Paint()..color = AppColors.surface);
      canvas.drawPath(
        Path()
          ..moveTo(hlPoint.dx - 5, ttTop + tooltipHeight)
          ..lineTo(hlPoint.dx, ttTop + tooltipHeight + 5)
          ..lineTo(hlPoint.dx + 5, ttTop + tooltipHeight),
        Paint()
          ..color = AppColors.borderSubtle
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      // Date Text
      final dateTp = TextPainter(
        text: TextSpan(
          text: tooltipDate ?? dates[highlightedIndex!],
          style: TextStyle(
            fontFamily: AppTypography.fontHeading,
            color: AppColors.textPrimary,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      dateTp.paint(canvas, Offset(ttLeft + (tooltipWidth - dateTp.width) / 2, ttTop + 4));

      // Value Text
      final valTp = TextPainter(
        text: TextSpan(
          text: tooltipValue ?? '${values[highlightedIndex!].round()}',
          style: TextStyle(
            fontFamily: AppTypography.fontHeading,
            color: lineColor,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valTp.paint(canvas, Offset(ttLeft + (tooltipWidth - valTp.width) / 2, ttTop + 18));
    }
  }

  @override
  bool shouldRepaint(covariant _AppLineChartPainter oldDelegate) {
    return oldDelegate.dates != dates ||
        oldDelegate.values != values ||
        oldDelegate.highlightedIndex != highlightedIndex ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.maxY != maxY;
  }
}

/// A centralized, reusable Line Chart Card component tokenized with
/// [AppColors], [AppRadii], [AppShadows], and [AppTypography].
class AppLineChartCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color iconColor;
  final Color? iconBg;
  final Widget? trailingHeader;
  final List<String> dates;
  final List<double> values;
  final int? highlightedIndex;
  final String? tooltipDate;
  final String? tooltipValue;
  final Color lineColor;
  final Color? fillColor;
  final double? maxY;
  final List<double>? yLabels;
  final double chartHeight;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const AppLineChartCard({
    super.key,
    required this.title,
    this.icon = Icons.bar_chart_rounded,
    this.iconColor = const Color(0xFF6366F1),
    this.iconBg,
    this.trailingHeader,
    this.dates = const ['Oct 12', 'Oct 13', 'Oct 14', 'Oct 15', 'Oct 16', 'Oct 17', 'Oct 18'],
    this.values = const [500, 650, 800, 950, 1200, 1520, 1400],
    this.highlightedIndex = 5,
    this.tooltipDate = 'Oct 17, 2026',
    this.tooltipValue = '1,520 attempts',
    this.lineColor = const Color(0xFF6366F1),
    this.fillColor,
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
            child: AppLineChart(
              dates: dates,
              values: values,
              highlightedIndex: highlightedIndex,
              tooltipDate: tooltipDate,
              tooltipValue: tooltipValue,
              height: chartHeight,
              lineColor: lineColor,
              fillColor: fillColor,
              maxY: maxY,
              yLabels: yLabels,
            ),
          ),
        ],
      ),
    );
  }
}

