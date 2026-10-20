import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Complete Redesign: Ultra-Modern Multi-Layered Fluid Harmonic Waves
/// A brand-new, completely fresh architectural wave design:
/// - 4 Layered Sinusoidal & Cubic Bezier Ocean Waves with depth, shadows & gradients
/// - Dual Asymmetrical Top-Right Energy Arc Waves behind Login Card
/// - Ambient Radial Aurora Glows (Electric Indigo, Cyan, Violet)
/// - Crisp Luminous Wave Crest Highlights (Neon Edge Sheen)
/// - Modern Tech Grid Matrix and Bokeh Floating Light Accents
class AdminBackgroundWaves extends StatelessWidget {
  const AdminBackgroundWaves({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _AdminBackgroundWavesPainter(),
      ),
    );
  }
}

class _AdminBackgroundWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // =========================================================================
    // 1. BASE CANVAS: Smooth Executive Light Mesh Canvas
    // =========================================================================
    final baseRect = Rect.fromLTWH(0, 0, w, h);
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.35, 0.70, 1.0],
        colors: [
          Color(0xFFF0F4FF), // Crisp top-left periwinkle tint
          Color(0xFFF8FAFC), // Pure center slate
          Color(0xFFEEF2FF), // Soft indigo wash
          Color(0xFFE0E7FE), // Vibrant bottom-right gradient
        ],
      ).createShader(baseRect);
    canvas.drawRect(baseRect, basePaint);

    // =========================================================================
    // 2. AMBIENT AURORA GLOWS (Volumetric Light Spheres)
    // =========================================================================
    // Glow 1: Top-Right Deep Violet Glow (Behind Login Card)
    final trGlowCenter = Offset(w * 0.85, h * 0.30);
    final trGlowPaint = Paint()
      ..shader = RadialGradient(
        radius: 0.90,
        colors: [
          const Color(0xFF6366F1).withAlpha(65),  // Indigo core
          const Color(0xFF8B5CF6).withAlpha(40),  // Violet halo
          const Color(0xFFC4B5FD).withAlpha(15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: trGlowCenter, radius: w * 0.42));
    canvas.drawCircle(trGlowCenter, w * 0.42, trGlowPaint);

    // Glow 2: Center-Left Cyan/Sky Illumination (Behind Mascot & Features)
    final clGlowCenter = Offset(w * 0.45, h * 0.45);
    final clGlowPaint = Paint()
      ..shader = RadialGradient(
        radius: 0.80,
        colors: [
          const Color(0xFF38BDF8).withAlpha(50),  // Neon sky blue
          const Color(0xFF818CF8).withAlpha(30),  // Soft periwinkle
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: clGlowCenter, radius: w * 0.35));
    canvas.drawCircle(clGlowCenter, w * 0.35, clGlowPaint);

    // Glow 3: Bottom-Left Lavender Accent
    final blGlowCenter = Offset(w * 0.15, h * 0.85);
    final blGlowPaint = Paint()
      ..shader = RadialGradient(
        radius: 0.70,
        colors: [
          const Color(0xFFA5B4FC).withAlpha(45),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: blGlowCenter, radius: w * 0.28));
    canvas.drawCircle(blGlowCenter, w * 0.28, blGlowPaint);

    // =========================================================================
    // 3. TOP-RIGHT ASYMMETRIC FLUID ARCS (Dynamic Energy)
    // =========================================================================
    // Outer Arc Wave
    final topArc1 = Path()
      ..moveTo(w * 0.62, 0)
      ..cubicTo(
        w * 0.70, h * 0.12,
        w * 0.82, h * 0.22,
        w, h * 0.26,
      )
      ..lineTo(w, 0)
      ..close();

    final topArc1Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF818CF8).withAlpha(160),
          const Color(0xFFC7D2FE).withAlpha(90),
        ],
      ).createShader(Rect.fromLTWH(w * 0.62, 0, w * 0.38, h * 0.26));
    canvas.drawPath(topArc1, topArc1Paint);

    // Inner Sleek Accent Arc
    final topArc2 = Path()
      ..moveTo(w * 0.76, 0)
      ..cubicTo(
        w * 0.82, h * 0.08,
        w * 0.90, h * 0.14,
        w, h * 0.16,
      )
      ..lineTo(w, 0)
      ..close();

    final topArc2Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF6366F1).withAlpha(180),
          const Color(0xFF8B5CF6).withAlpha(130),
        ],
      ).createShader(Rect.fromLTWH(w * 0.76, 0, w * 0.24, h * 0.16));
    canvas.drawPath(topArc2, topArc2Paint);

    // Top Arc Crest Hairline
    final topArcStroke = Path()
      ..moveTo(w * 0.62, 0)
      ..cubicTo(
        w * 0.70, h * 0.12,
        w * 0.82, h * 0.22,
        w, h * 0.26,
      );
    final topArcStrokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
        colors: [
          Colors.white.withAlpha(220),
          const Color(0xFF818CF8).withAlpha(120),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(w * 0.62, 0, w * 0.38, h * 0.26));
    canvas.drawPath(topArcStroke, topArcStrokePaint);

    // =========================================================================
    // 4. WAVE LAYER 1: Deep Background Sine Wave (Mid-Elevation)
    // =========================================================================
    final wave1 = Path()
      ..moveTo(0, h * 0.44)
      ..cubicTo(
        w * 0.18, h * 0.38,
        w * 0.36, h * 0.48,
        w * 0.54, h * 0.42,
      )
      ..cubicTo(
        w * 0.72, h * 0.36,
        w * 0.86, h * 0.46,
        w, h * 0.40,
      )
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final wave1Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFC7D2FE).withAlpha(100),
          const Color(0xFFE0E7FF).withAlpha(60),
          const Color(0xFFEEF2FF).withAlpha(20),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, h * 0.36, w, h * 0.64));
    canvas.drawPath(wave1, wave1Paint);

    // =========================================================================
    // 5. WAVE LAYER 2: Luminous Indigo-Cyan Harmonic Ribbon
    // =========================================================================
    final wave2 = Path()
      ..moveTo(0, h * 0.54)
      ..cubicTo(
        w * 0.22, h * 0.62,
        w * 0.40, h * 0.46,
        w * 0.60, h * 0.58,
      )
      ..cubicTo(
        w * 0.78, h * 0.68,
        w * 0.90, h * 0.54,
        w, h * 0.58,
      )
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    // Soft drop shadow for layer 2
    canvas.drawShadow(wave2, const Color(0x184F46E5), 24, true);

    final wave2Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF818CF8).withAlpha(140),
          const Color(0xFF67E8F9).withAlpha(90),
          const Color(0xFFA5B4FC).withAlpha(70),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, h * 0.46, w, h * 0.54));
    canvas.drawPath(wave2, wave2Paint);

    // Wave 2 Crest Neon Glow Line
    final wave2Crest = Path()
      ..moveTo(0, h * 0.54)
      ..cubicTo(
        w * 0.22, h * 0.62,
        w * 0.40, h * 0.46,
        w * 0.60, h * 0.58,
      )
      ..cubicTo(
        w * 0.78, h * 0.68,
        w * 0.90, h * 0.54,
        w, h * 0.58,
      );

    final wave2CrestPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF818CF8).withAlpha(180),
          const Color(0xFF38BDF8).withAlpha(220),
          Colors.white.withAlpha(240),
          const Color(0xFF818CF8).withAlpha(140),
        ],
        stops: const [0.0, 0.45, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, h * 0.46, w, 20));
    canvas.drawPath(wave2Crest, wave2CrestPaint);

    // =========================================================================
    // 6. WAVE LAYER 3: Rich Fluid Kinetic Wave (Diagonal Motion)
    // =========================================================================
    final wave3 = Path()
      ..moveTo(0, h * 0.68)
      ..cubicTo(
        w * 0.26, h * 0.60,
        w * 0.48, h * 0.74,
        w * 0.70, h * 0.66,
      )
      ..cubicTo(
        w * 0.84, h * 0.61,
        w * 0.93, h * 0.69,
        w, h * 0.72,
      )
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawShadow(wave3, const Color(0x1F312E81), 28, true);

    final wave3Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF6366F1).withAlpha(160),
          const Color(0xFF818CF8).withAlpha(120),
          const Color(0xFFC7D2FE).withAlpha(90),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.60, w, h * 0.40));
    canvas.drawPath(wave3, wave3Paint);

    // Wave 3 Luminous Crest Stroke
    final wave3Crest = Path()
      ..moveTo(0, h * 0.68)
      ..cubicTo(
        w * 0.26, h * 0.60,
        w * 0.48, h * 0.74,
        w * 0.70, h * 0.66,
      )
      ..cubicTo(
        w * 0.84, h * 0.61,
        w * 0.93, h * 0.69,
        w, h * 0.72,
      );

    final wave3CrestPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..shader = LinearGradient(
        colors: [
          Colors.white.withAlpha(240),
          const Color(0xFFA5B4FC).withAlpha(200),
          Colors.white.withAlpha(255),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.60, w, 15));
    canvas.drawPath(wave3Crest, wave3CrestPaint);

    // =========================================================================
    // 7. WAVE LAYER 4: Pristine Foreground Horizon Wave (Cradles Stats & Quote)
    // =========================================================================
    final wave4 = Path()
      ..moveTo(0, h * 0.79)
      ..cubicTo(
        w * 0.28, h * 0.74,
        w * 0.52, h * 0.82,
        w * 0.75, h * 0.77,
      )
      ..cubicTo(
        w * 0.88, h * 0.74,
        w * 0.95, h * 0.80,
        w, h * 0.83,
      )
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    // High-end diffused elevation shadow for foreground wave
    canvas.drawShadow(wave4, const Color(0x180F172A), 36, true);

    final wave4Paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFAFCFF),
          Color(0xFFF1F6FE),
          Color(0xFFE6EEFC),
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, h * 0.74, w, h * 0.26));
    canvas.drawPath(wave4, wave4Paint);

    // Wave 4 Pure Glass Edge Sheen
    final wave4Crest = Path()
      ..moveTo(0, h * 0.79)
      ..cubicTo(
        w * 0.28, h * 0.74,
        w * 0.52, h * 0.82,
        w * 0.75, h * 0.77,
      )
      ..cubicTo(
        w * 0.88, h * 0.74,
        w * 0.95, h * 0.80,
        w, h * 0.83,
      );

    final wave4CrestPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = LinearGradient(
        colors: [
          Colors.white,
          const Color(0xFFC7D2FE).withAlpha(180),
          Colors.white,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, h * 0.74, w, 15));
    canvas.drawPath(wave4Crest, wave4CrestPaint);

    // =========================================================================
    // 8. HAIRLINE VECTOR CONTOURS (Modern Tech Wave Lines)
    // =========================================================================
    final techLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF6366F1).withAlpha(0),
          const Color(0xFF6366F1).withAlpha(70),
          const Color(0xFF38BDF8).withAlpha(85),
          const Color(0xFF6366F1).withAlpha(0),
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(Rect.fromLTWH(0, h * 0.30, w * 0.80, h * 0.40));

    final techLine1 = Path()
      ..moveTo(0, h * 0.38)
      ..cubicTo(
        w * 0.20, h * 0.32,
        w * 0.42, h * 0.44,
        w * 0.65, h * 0.36,
      );
    canvas.drawPath(techLine1, techLinePaint);

    // =========================================================================
    // 9. MODERN TECH DOT MATRIX GRID
    // =========================================================================
    final dotStartX = w * 0.40;
    final dotStartY = h * 0.08;
    const dotCols = 8;
    const dotRows = 5;
    const dotSpacing = 14.0;

    for (int r = 0; r < dotRows; r++) {
      for (int c = 0; c < dotCols; c++) {
        // Radial alpha falloff from center
        final dist = math.sqrt(
          math.pow((c - (dotCols - 1) / 2) / ((dotCols - 1) / 2), 2) +
          math.pow((r - (dotRows - 1) / 2) / ((dotRows - 1) / 2), 2),
        );
        final alpha = (math.max(0.0, 1.0 - (dist * 0.5)) * 170).toInt().clamp(0, 255);

        final dotPaint = Paint()..color = const Color(0xFF6366F1).withAlpha(alpha);
        canvas.drawCircle(
          Offset(dotStartX + c * dotSpacing, dotStartY + r * dotSpacing),
          1.8,
          dotPaint,
        );
      }
    }

    // =========================================================================
    // 10. BOKEH LIGHT PARTICLES & MICRO SPARKLES (+)
    // =========================================================================
    // Floating Soft Bokeh Orbs
    _drawBokehOrb(canvas, Offset(w * 0.32, h * 0.24), 18.0, const Color(0xFF818CF8).withAlpha(35));
    _drawBokehOrb(canvas, Offset(w * 0.68, h * 0.42), 24.0, const Color(0xFF38BDF8).withAlpha(30));
    _drawBokehOrb(canvas, Offset(w * 0.52, h * 0.68), 20.0, const Color(0xFFC7D2FE).withAlpha(40));

    // Crisp 4-point Micro-Sparkles (+)
    _drawSparkle(canvas, Offset(w * 0.35, h * 0.14), 7.5, const Color(0xFF6366F1).withAlpha(170));
    _drawSparkle(canvas, Offset(w * 0.65, h * 0.18), 8.0, const Color(0xFF38BDF8).withAlpha(180));
    _drawSparkle(canvas, Offset(w * 0.48, h * 0.52), 6.5, const Color(0xFF818CF8).withAlpha(160));
    _drawSparkle(canvas, Offset(w * 0.94, h * 0.45), 7.0, const Color(0xFFF59E0B).withAlpha(150));
  }

  /// Draws a soft blurred bokeh light orb
  void _drawBokehOrb(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withAlpha(0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  /// Draws a crisp 4-point geometric sparkle cross (+) with core dot
  void _drawSparkle(Canvas canvas, Offset center, double size, Color color) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(center.dx - size, center.dy)
      ..lineTo(center.dx + size, center.dy)
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx, center.dy + size);

    canvas.drawPath(path, linePaint);
    canvas.drawCircle(center, 1.3, Paint()..color = color.withAlpha(240));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
