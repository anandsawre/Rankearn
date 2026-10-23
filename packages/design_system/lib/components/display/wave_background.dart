import 'package:flutter/material.dart';

/// Premium Multi-Layer Harmonic Wave Background Component for Rankearn
/// Creates elegant, smoothly blended organic curved waves with brand gradients.
class WaveBackground extends StatelessWidget {
  final Widget? child;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final double intensity;

  const WaveBackground({
    super.key,
    this.child,
    this.primaryColor = const Color(0xFF00B96B), // Rankearn Green
    this.secondaryColor = const Color(0xFF1677FF), // Brand Blue
    this.accentColor = const Color(0xFF38BDF8), // Cyan / Sky Blue
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final background = RepaintBoundary(
      child: CustomPaint(
        painter: _MultiLayerWavePainter(
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          accentColor: accentColor,
          intensity: intensity,
        ),
        size: Size.infinite,
      ),
    );

    if (child == null) {
      return background;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        background,
        child!,
      ],
    );
  }
}

class _MultiLayerWavePainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final double intensity;

  _MultiLayerWavePainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // -------------------------------------------------------------------------
    // 1. Ambient Glow 1: Top-Left Mint & Emerald Radial Gradient Blend
    // -------------------------------------------------------------------------
    final glow1Rect = Rect.fromCircle(
      center: Offset(w * 0.12, h * 0.15),
      radius: (w * 0.42).clamp(240.0, 520.0),
    );
    final glow1Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: 0.14 * intensity),
          primaryColor.withValues(alpha: 0.05 * intensity),
          primaryColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(glow1Rect);
    canvas.drawCircle(glow1Rect.center, glow1Rect.width / 2, glow1Paint);

    // -------------------------------------------------------------------------
    // 2. Ambient Glow 2: Bottom-Right Azure & Cyan Radial Gradient Blend
    // -------------------------------------------------------------------------
    final glow2Rect = Rect.fromCircle(
      center: Offset(w * 0.88, h * 0.85),
      radius: (w * 0.46).clamp(260.0, 580.0),
    );
    final glow2Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          secondaryColor.withValues(alpha: 0.12 * intensity),
          accentColor.withValues(alpha: 0.04 * intensity),
          secondaryColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(glow2Rect);
    canvas.drawCircle(glow2Rect.center, glow2Rect.width / 2, glow2Paint);

    // -------------------------------------------------------------------------
    // 3. Layer 1: Sweeping Deep Harmonic Wave (Bottom-to-Mid Backdrop)
    // -------------------------------------------------------------------------
    final path1 = Path();
    path1.moveTo(0, h * 0.65);
    path1.cubicTo(
      w * 0.22, h * 0.52,
      w * 0.42, h * 0.76,
      w * 0.68, h * 0.62,
    );
    path1.cubicTo(
      w * 0.84, h * 0.53,
      w * 0.94, h * 0.60,
      w, h * 0.56,
    );
    path1.lineTo(w, h);
    path1.lineTo(0, h);
    path1.close();

    final shader1 = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor.withValues(alpha: 0.06 * intensity),
        accentColor.withValues(alpha: 0.08 * intensity),
        secondaryColor.withValues(alpha: 0.04 * intensity),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(0, h * 0.5, w, h * 0.5));

    final paint1 = Paint()
      ..shader = shader1
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(path1, paint1);

    // -------------------------------------------------------------------------
    // 4. Layer 2: Mid-Height Crest Wave with Counter-Curve Flow
    // -------------------------------------------------------------------------
    final path2 = Path();
    path2.moveTo(0, h * 0.78);
    path2.cubicTo(
      w * 0.28, h * 0.88,
      w * 0.55, h * 0.68,
      w * 0.78, h * 0.82,
    );
    path2.cubicTo(
      w * 0.90, h * 0.89,
      w * 0.96, h * 0.82,
      w, h * 0.80,
    );
    path2.lineTo(w, h);
    path2.lineTo(0, h);
    path2.close();

    final shader2 = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        primaryColor.withValues(alpha: 0.08 * intensity),
        accentColor.withValues(alpha: 0.06 * intensity),
        const Color(0xFF6EE7B7).withValues(alpha: 0.05 * intensity),
      ],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromLTWH(0, h * 0.65, w, h * 0.35));

    final paint2 = Paint()
      ..shader = shader2
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(path2, paint2);

    // -------------------------------------------------------------------------
    // 5. Layer 3: Organic Top-Corner Flowing Crest (Subtle Framing)
    // -------------------------------------------------------------------------
    final path3 = Path();
    path3.moveTo(0, 0);
    path3.lineTo(w * 0.58, 0);
    path3.cubicTo(
      w * 0.44, h * 0.22,
      w * 0.22, h * 0.28,
      0, h * 0.38,
    );
    path3.close();

    final shader3 = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        primaryColor.withValues(alpha: 0.07 * intensity),
        const Color(0xFF86EFAC).withValues(alpha: 0.04 * intensity),
        primaryColor.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.65, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, w * 0.58, h * 0.38));

    final paint3 = Paint()
      ..shader = shader3
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(path3, paint3);

    // -------------------------------------------------------------------------
    // 6. Layer 4: Delicate Golden-Emerald Accent Stroke Ribbon
    // -------------------------------------------------------------------------
    final ribbonPath = Path();
    ribbonPath.moveTo(0, h * 0.68);
    ribbonPath.cubicTo(
      w * 0.24, h * 0.55,
      w * 0.45, h * 0.78,
      w * 0.72, h * 0.65,
    );
    ribbonPath.cubicTo(
      w * 0.86, h * 0.58,
      w * 0.95, h * 0.63,
      w, h * 0.60,
    );

    final ribbonPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withValues(alpha: 0.22 * intensity),
          accentColor.withValues(alpha: 0.28 * intensity),
          secondaryColor.withValues(alpha: 0.15 * intensity),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.55, w, h * 0.25))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..isAntiAlias = true;
    canvas.drawPath(ribbonPath, ribbonPaint);
  }

  @override
  bool shouldRepaint(covariant _MultiLayerWavePainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.intensity != intensity;
  }
}
