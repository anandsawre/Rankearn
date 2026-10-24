import 'package:flutter/material.dart';

/// Complete Multi-Layered Fluid Harmonic Wave Background matching reference
/// - 4 Layered Sinusoidal & Cubic Bezier Ocean Waves with depth, shadows & gradients
/// - Dual Asymmetrical Top-Right Energy Arc Waves behind Login Card
/// - Ambient Radial Aurora Glows (Electric Indigo, Cyan, Violet)
/// - Crisp Luminous Wave Crest Highlights (Neon Edge Sheen)
/// - Modern Tech Grid Matrix and Bokeh Floating Light Accents
class AuthBackgroundWaves extends StatelessWidget {
  const AuthBackgroundWaves({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _AuthBackgroundWavesPainter()),
    );
  }
}

class _AuthBackgroundWavesPainter extends CustomPainter {
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
          const Color(0xFF6366F1).withAlpha(65), // Indigo core
          const Color(0xFF8B5CF6).withAlpha(40), // Violet halo
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
          const Color(0xFF38BDF8).withAlpha(50), // Neon sky blue
          const Color(0xFF818CF8).withAlpha(30), // Soft periwinkle
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
        colors: [const Color(0xFFA5B4FC).withAlpha(45), Colors.transparent],
      ).createShader(Rect.fromCircle(center: blGlowCenter, radius: w * 0.28));
    canvas.drawCircle(blGlowCenter, w * 0.28, blGlowPaint);

    // =========================================================================
    // 3. TOP-RIGHT ASYMMETRIC FLUID ARCS (Dynamic Energy)
    // =========================================================================
    // Outer Arc Wave
    final topArc1 = Path()
      ..moveTo(w * 0.62, 0)
      ..cubicTo(w * 0.70, h * 0.12, w * 0.82, h * 0.22, w, h * 0.26)
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
      ..cubicTo(w * 0.82, h * 0.08, w * 0.90, h * 0.14, w, h * 0.16)
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
      ..cubicTo(w * 0.70, h * 0.12, w * 0.82, h * 0.22, w, h * 0.26);
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
      ..moveTo(0, h * 0.52)
      ..cubicTo(w * 0.22, h * 0.44, w * 0.42, h * 0.60, w * 0.68, h * 0.50)
      ..cubicTo(w * 0.84, h * 0.43, w * 0.94, h * 0.54, w, h * 0.48)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final wave1Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFC7D2FE).withAlpha(70), // Light indigo mist
          const Color(0xFFE0E7FF).withAlpha(120),
          const Color(0xFFF1F5F9).withAlpha(180),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, h * 0.44, w, h * 0.56));
    canvas.drawPath(wave1, wave1Paint);

    // =========================================================================
    // 5. TECH MATRIX: Precision Micro-Dot Matrix Accent Grid
    // Positioned strategically above the mascot near w*0.42, h*0.12
    // =========================================================================
    final dotPaint = Paint()..color = const Color(0xFF818CF8).withAlpha(70);
    const int cols = 6;
    const int rows = 4;
    const double spacing = 14.0;
    final double startX = w * 0.39;
    final double startY = h * 0.08;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(startX + (c * spacing), startY + (r * spacing)),
          1.6,
          dotPaint,
        );
      }
    }

    // =========================================================================
    // 6. WAVE LAYER 2: Midground Oceanic Fluid Wave (Rich Violet-Indigo)
    // =========================================================================
    final wave2 = Path()
      ..moveTo(0, h * 0.66)
      ..cubicTo(w * 0.16, h * 0.54, w * 0.36, h * 0.50, w * 0.58, h * 0.64)
      ..cubicTo(w * 0.74, h * 0.74, w * 0.88, h * 0.62, w, h * 0.70)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final wave2Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF818CF8).withAlpha(120), // Periwinkle wave
          const Color(0xFF6366F1).withAlpha(80), // Indigo body
          const Color(0xFFC7D2FE).withAlpha(110), // Soft base
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, h * 0.50, w, h * 0.50));
    canvas.drawPath(wave2, wave2Paint);

    // Wave 2 Crest Sheen
    final wave2Stroke = Path()
      ..moveTo(0, h * 0.66)
      ..cubicTo(w * 0.16, h * 0.54, w * 0.36, h * 0.50, w * 0.58, h * 0.64)
      ..cubicTo(w * 0.74, h * 0.74, w * 0.88, h * 0.62, w, h * 0.70);
    final wave2StrokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..shader = LinearGradient(
        colors: [
          Colors.white.withAlpha(180),
          const Color(0xFF818CF8).withAlpha(150),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.50, w, h * 0.25));
    canvas.drawPath(wave2Stroke, wave2StrokePaint);

    // =========================================================================
    // 7. WAVE LAYER 3: Dynamic Foreground Sweeping Ribbon Wave
    // Sweeps from bottom-left up across under the mascot and across right
    // =========================================================================
    final wave3 = Path()
      ..moveTo(0, h * 0.78)
      ..cubicTo(w * 0.14, h * 0.72, w * 0.32, h * 0.79, w * 0.52, h * 0.74)
      ..cubicTo(w * 0.72, h * 0.68, w * 0.88, h * 0.82, w, h * 0.78)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final wave3Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF6366F1).withAlpha(100), // Indigo-violet
          const Color(0xFF4F46E5).withAlpha(50),
          const Color(0xFFE0E7FF).withAlpha(90),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.68, w, h * 0.32));
    canvas.drawPath(wave3, wave3Paint);

    // =========================================================================
    // 8. WAVE LAYER 4: Bottom-Left Harmonic Primary Wave (Vibrant Crest)
    // Directly mirrors the bold left-side sweep in the reference mockup
    // =========================================================================
    final wave4 = Path()
      ..moveTo(0, h * 0.68)
      ..cubicTo(w * 0.08, h * 0.67, w * 0.15, h * 0.75, w * 0.28, h * 0.77)
      ..cubicTo(w * 0.44, h * 0.79, w * 0.60, h * 0.94, w * 0.82, h * 0.90)
      ..cubicTo(w * 0.92, h * 0.88, w * 0.98, h * 0.96, w, h * 0.95)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final wave4Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF6366F1).withAlpha(140), // Bold indigo surge
          const Color(0xFF818CF8).withAlpha(90),
          const Color(0xFFA5B4FC).withAlpha(40),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, h * 0.67, w, h * 0.33));
    canvas.drawPath(wave4, wave4Paint);

    // Wave 4 Ultra-Crisp Crest Highlight (Neon Luminous Sheen)
    final wave4Highlight = Path()
      ..moveTo(0, h * 0.68)
      ..cubicTo(w * 0.08, h * 0.67, w * 0.15, h * 0.75, w * 0.28, h * 0.77)
      ..cubicTo(w * 0.44, h * 0.79, w * 0.60, h * 0.94, w * 0.82, h * 0.90);
    final wave4HighlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = LinearGradient(
        colors: [
          Colors.white.withAlpha(240),
          const Color(0xFFC7D2FE).withAlpha(200),
          const Color(0xFF818CF8).withAlpha(100),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, h * 0.67, w * 0.82, h * 0.27));
    canvas.drawPath(wave4Highlight, wave4HighlightPaint);

    // =========================================================================
    // 9. BOKEH PARTICLES & LIGHT ACCENTS (Subtle Luminous Bubbles)
    // =========================================================================
    final bokehPaint = Paint()..style = PaintingStyle.fill;

    // Bokeh 1: Center-left light dot
    bokehPaint.color = Colors.white.withAlpha(110);
    canvas.drawCircle(Offset(w * 0.34, h * 0.38), 3.0, bokehPaint);

    // Bokeh 2: Upper cyan flare
    bokehPaint.color = const Color(0xFF38BDF8).withAlpha(80);
    canvas.drawCircle(Offset(w * 0.58, h * 0.22), 4.5, bokehPaint);

    // Bokeh 3: Violet floating mote
    bokehPaint.color = const Color(0xFF8B5CF6).withAlpha(70);
    canvas.drawCircle(Offset(w * 0.26, h * 0.56), 2.5, bokehPaint);

    // Bokeh 4: Tiny spark near login card
    bokehPaint.color = Colors.white.withAlpha(140);
    canvas.drawCircle(Offset(w * 0.68, h * 0.35), 2.0, bokehPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
