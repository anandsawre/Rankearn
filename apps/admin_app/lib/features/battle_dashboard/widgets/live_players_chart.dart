import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class LivePlayersChart extends StatelessWidget {
  const LivePlayersChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart Area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 16, 0),
            child: Stack(
              children: [
                // Custom Area Graph
                Positioned.fill(
                  child: CustomPaint(
                    painter: _BezierAreaChartPainter(),
                  ),
                ),

                // Peak Badge "8,742 Live"
                Positioned(
                  top: 2,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.battleAdminPurple,
                      borderRadius: AppRadii.borderSm,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.battleAdminPurple.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.textOnPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '8,742 Live',
                          style: AppTypography.captionBold.copyWith(
                            color: AppColors.textOnPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom X-Axis Timestamps
        Padding(
          padding: const EdgeInsets.only(left: 36, right: 16, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('10 AM', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
              Text('11 AM', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
              Text('12 PM', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
              Text('1 PM', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
              Text('2 PM', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
              Text('3 PM', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
              Text('4 PM', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BezierAreaChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Y-Axis Labels & Subtle Grid Lines
    final gridPaint = Paint()
      ..color = AppColors.borderSubtle
      ..strokeWidth = 1;

    final textStyle = AppTypography.captionBold.copyWith(
      color: AppColors.textMuted,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    final ySteps = ['10K', '8K', '6K', '4K', '2K', '0'];
    final leftMargin = 30.0;
    final graphWidth = size.width - leftMargin;
    final graphHeight = size.height - 10;

    for (int i = 0; i < ySteps.length; i++) {
      final y = (graphHeight / (ySteps.length - 1)) * i;

      // Label
      final span = TextSpan(text: ySteps[i], style: textStyle);
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));

      // Horizontal dashed/solid gridline
      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // 2. Data Points representing 10 AM to 4 PM (normalized 0 to 1)
    // 10K = 1.0, 0 = 0.0
    // Real points matching screenshot: ~2.8k, ~4.1k, ~3.7k, ~4.9k, ~6.1k, ~5.8k, ~8.7k
    final points = [0.28, 0.41, 0.37, 0.49, 0.61, 0.58, 0.87];

    final path = Path();
    final fillPath = Path();

    final stepX = graphWidth / (points.length - 1);

    List<Offset> offsets = [];
    for (int i = 0; i < points.length; i++) {
      final x = leftMargin + (i * stepX);
      final y = graphHeight - (points[i] * graphHeight);
      offsets.add(Offset(x, y));
    }

    // Bézier cubic interpolation
    path.moveTo(offsets[0].dx, offsets[0].dy);
    fillPath.moveTo(offsets[0].dx, graphHeight);
    fillPath.lineTo(offsets[0].dx, offsets[0].dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY1 = p0.dy;
      final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY2 = p1.dy;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
      fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
    }

    fillPath.lineTo(offsets.last.dx, graphHeight);
    fillPath.close();

    // 3. Paint Gradient Area Fill
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.battleAdminPurple.withValues(alpha: 0.35),
        AppColors.battleAdminPurpleSecondary.withValues(alpha: 0.12),
        AppColors.battleAdminPurpleLight.withValues(alpha: 0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(leftMargin, 0, graphWidth, graphHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 4. Paint Curve Stroke
    final strokePaint = Paint()
      ..color = AppColors.battleAdminPurple
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // 5. Draw circular markers
    final pointPaint = Paint()
      ..color = AppColors.battleAdminPurple
      ..style = PaintingStyle.fill;

    final pointInnerPaint = Paint()
      ..color = AppColors.textOnPrimary
      ..style = PaintingStyle.fill;

    for (int i = 0; i < offsets.length; i++) {
      final off = offsets[i];
      // Outer purple circle
      canvas.drawCircle(off, 4.5, pointPaint);
      // Inner white center
      canvas.drawCircle(off, 2.0, pointInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

