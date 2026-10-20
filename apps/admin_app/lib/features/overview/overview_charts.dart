import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'dart:math' as math;

// ==========================================
// 1. MINI SPARKLINE CHART
// ==========================================
class SparklineChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double width;
  final double height;

  const SparklineChart({
    super.key,
    required this.data,
    required this.color,
    this.width = 70,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(data: data, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minVal = data.reduce(math.min);
    final maxVal = data.reduce(math.max);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final path = Path();
    final points = <Offset>[];

    final dx = size.width / (data.length - 1);
    for (int i = 0; i < data.length; i++) {
      final normalized = (data[i] - minVal) / range;
      final y = size.height - (normalized * (size.height - 8)) - 4;
      points.add(Offset(i * dx, y));
    }

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}

// ==========================================
// 2. QUIZ ATTEMPTS OVERVIEW (LINE CHART)
// ==========================================
class QuizAttemptsLineChart extends StatelessWidget {
  final List<String> dates;
  final List<double> values;
  final int highlightedIndex;
  final String tooltipDate;
  final String tooltipValue;
  final double height;

  const QuizAttemptsLineChart({
    super.key,
    this.dates = const ['Oct 12', 'Oct 13', 'Oct 14', 'Oct 15', 'Oct 16', 'Oct 17', 'Oct 18'],
    this.values = const [500, 650, 800, 950, 1200, 1520, 1400],
    this.highlightedIndex = 5, // Oct 17
    this.tooltipDate = 'Oct 17, 2026',
    this.tooltipValue = '1,520 attempts',
    this.height = 165,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, height),
          painter: _LineChartPainter(
            dates: dates,
            values: values,
            highlightedIndex: highlightedIndex,
            tooltipDate: tooltipDate,
            tooltipValue: tooltipValue,
          ),
        );
      },
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<String> dates;
  final List<double> values;
  final int highlightedIndex;
  final String tooltipDate;
  final String tooltipValue;

  _LineChartPainter({
    required this.dates,
    required this.values,
    required this.highlightedIndex,
    required this.tooltipDate,
    required this.tooltipValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftMargin = 45.0;
    const bottomMargin = 22.0;
    const topMargin = 26.0;
    const rightMargin = 16.0;

    final chartWidth = size.width - leftMargin - rightMargin;
    final chartHeight = size.height - topMargin - bottomMargin;

    final yLabels = [2000, 1500, 1000, 500, 0];
    const maxY = 2000.0;

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    final textStyle = const TextStyle(
      color: Color(0xFF94A3B8),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    // Draw Y grid lines & labels
    for (int i = 0; i < yLabels.length; i++) {
      final yVal = yLabels[i];
      final yPos = topMargin + (chartHeight * (i / (yLabels.length - 1)));

      // Grid line
      canvas.drawLine(
        Offset(leftMargin, yPos),
        Offset(size.width - rightMargin, yPos),
        gridPaint,
      );

      // Y Label
      final tp = TextPainter(
        text: TextSpan(
          text: yVal == 0 ? '0' : yVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftMargin - tp.width - 8, yPos - tp.height / 2));
    }

    // Points calculation
    final points = <Offset>[];
    final dx = chartWidth / (dates.length - 1);
    for (int i = 0; i < dates.length; i++) {
      final x = leftMargin + (i * dx);
      final normalizedY = (values[i] / maxY).clamp(0.0, 1.0);
      final y = topMargin + chartHeight - (normalizedY * chartHeight);
      points.add(Offset(x, y));

      // Draw X Label
      final tp = TextPainter(
        text: TextSpan(text: dates[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - tp.height));
    }

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

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF6366F1).withAlpha(60),
          const Color(0xFF6366F1).withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(leftMargin, topMargin, chartWidth, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke path
    final strokePaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    // Draw circular dots
    final dotPaint = Paint()
      ..color = const Color(0xFF6366F1)
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

    // Draw Highlighted Point (Oct 17)
    if (highlightedIndex >= 0 && highlightedIndex < points.length) {
      final hlPoint = points[highlightedIndex];

      // Outer ring
      canvas.drawCircle(
        hlPoint,
        6.5,
        Paint()
          ..color = const Color(0xFF6366F1).withAlpha(40)
          ..style = PaintingStyle.fill,
      );
      // Main circle
      canvas.drawCircle(
        hlPoint,
        4.5,
        Paint()
          ..color = const Color(0xFF4F46E5)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        hlPoint,
        2.5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );

      // Tooltip Card
      final tooltipWidth = 92.0;
      final tooltipHeight = 36.0;
      final ttLeft = (hlPoint.dx - tooltipWidth / 2).clamp(leftMargin, size.width - rightMargin - tooltipWidth);
      final ttTop = (hlPoint.dy - tooltipHeight - 8).clamp(2.0, size.height);

      // Card shadow
      final shadowRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(ttLeft, ttTop, tooltipWidth, tooltipHeight),
        const Radius.circular(8),
      );
      canvas.drawRRect(
        shadowRRect,
        Paint()
          ..color = Colors.black.withAlpha(20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Card background
      canvas.drawRRect(
        shadowRRect,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );

      // Card border
      canvas.drawRRect(
        shadowRRect,
        Paint()
          ..color = const Color(0xFFE2E8F0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      // Downward pointer triangle
      final arrowPath = Path()
        ..moveTo(hlPoint.dx - 5, ttTop + tooltipHeight)
        ..lineTo(hlPoint.dx + 5, ttTop + tooltipHeight)
        ..lineTo(hlPoint.dx, ttTop + tooltipHeight + 5)
        ..close();
      canvas.drawPath(arrowPath, Paint()..color = Colors.white);
      canvas.drawPath(
        Path()
          ..moveTo(hlPoint.dx - 5, ttTop + tooltipHeight)
          ..lineTo(hlPoint.dx, ttTop + tooltipHeight + 5)
          ..lineTo(hlPoint.dx + 5, ttTop + tooltipHeight),
        Paint()
          ..color = const Color(0xFFE2E8F0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      // Date Text
      final dateTp = TextPainter(
        text: TextSpan(
          text: tooltipDate,
          style: const TextStyle(
            color: Color(0xFF1E293B),
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
          text: tooltipValue,
          style: const TextStyle(
            color: Color(0xFF4F46E5),
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
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => true;
}

// ==========================================
// 3. USER GROWTH (VERTICAL BAR CHART)
// ==========================================
class UserGrowthBarChart extends StatelessWidget {
  final List<String> dates;
  final List<double> values;
  final double height;

  const UserGrowthBarChart({
    super.key,
    this.dates = const ['Oct 12', 'Oct 13', 'Oct 14', 'Oct 15', 'Oct 16', 'Oct 17', 'Oct 18'],
    this.values = const [620, 780, 940, 1220, 1480, 1720, 1590],
    this.height = 165,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, height),
          painter: _BarChartPainter(dates: dates, values: values),
        );
      },
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<String> dates;
  final List<double> values;

  _BarChartPainter({required this.dates, required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    const leftMargin = 40.0;
    const bottomMargin = 22.0;
    const topMargin = 18.0;
    const rightMargin = 12.0;

    final chartWidth = size.width - leftMargin - rightMargin;
    final chartHeight = size.height - topMargin - bottomMargin;

    final yLabels = [2000, 1500, 1000, 500, 0];
    const maxY = 2000.0;

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    final textStyle = const TextStyle(
      color: Color(0xFF94A3B8),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    // Draw Y grid lines & labels
    for (int i = 0; i < yLabels.length; i++) {
      final yVal = yLabels[i];
      final yPos = topMargin + (chartHeight * (i / (yLabels.length - 1)));

      canvas.drawLine(
        Offset(leftMargin, yPos),
        Offset(size.width - rightMargin, yPos),
        gridPaint,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: yVal == 0 ? '0' : yVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftMargin - tp.width - 6, yPos - tp.height / 2));
    }

    // Draw Bars
    final barCount = dates.length;
    final slotWidth = chartWidth / barCount;
    final barWidth = math.min(slotWidth * 0.58, 28.0);

    for (int i = 0; i < barCount; i++) {
      final normalized = (values[i] / maxY).clamp(0.0, 1.0);
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
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF34D399), // lighter emerald green top
            Color(0xFF10B981), // rich emerald green bottom
          ],
        ).createShader(rect);

      canvas.drawRRect(rrect, barPaint);

      // X Label
      final tp = TextPainter(
        text: TextSpan(text: dates[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftMargin + (i * slotWidth) + (slotWidth - tp.width) / 2, size.height - tp.height));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => true;
}

// ==========================================
// 4. CATEGORY WISE QUIZZES (DONUT CHART)
// ==========================================
class CategoryWiseDonutChart extends StatelessWidget {
  final int totalCount;
  final List<({String name, double percentage, Color color})> categories;

  const CategoryWiseDonutChart({
    super.key,
    this.totalCount = 386,
    this.categories = const [
      (name: 'General Science', percentage: 28, color: Color(0xFF3B82F6)),
      (name: 'Mathematics', percentage: 22, color: Color(0xFF8B5CF6)),
      (name: 'Reasoning', percentage: 18, color: Color(0xFFF59E0B)),
      (name: 'Current Affairs', percentage: 14, color: Color(0xFF06B6D4)),
      (name: 'Technical', percentage: 10, color: Color(0xFFEC4899)),
      (name: 'Others', percentage: 8, color: Color(0xFF94A3B8)),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 280;
        final slices = categories
            .map((c) => DonutSlice(
                  label: c.name,
                  percentage: c.percentage,
                  color: c.color,
                ))
            .toList();

        return AppDonutChart(
          slices: slices,
          totalCount: totalCount,
          totalLabel: 'Total',
          chartSize: isCompact ? 130 : 155,
          strokeWidth: isCompact ? 18.0 : 22.0,
          strokeCap: StrokeCap.round,
          legendSpacing: 14.0,
        );
      },
    );
  }
}

