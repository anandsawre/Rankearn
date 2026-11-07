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
    return AppLineChart(
      dates: dates,
      values: values,
      highlightedIndex: highlightedIndex,
      tooltipDate: tooltipDate,
      tooltipValue: tooltipValue,
      height: height,
    );
  }
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
    return AppBarChart(
      dates: dates,
      values: values,
      height: height,
    );
  }
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

