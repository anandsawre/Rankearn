import 'package:flutter/material.dart';

/// Style variants for Match / Battle Card wave background
enum BattleWaveStyle { layeredWave, subtleClean }

/// Premium Reusable Match Card with Layered Wave Background.
/// Integrates a multi-layer organic wave background matching the Rankearn reference specification.
class BattleWaveCard extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Color leftGlowColor;
  final Color centerGlowColor;
  final Color rightGlowColor;
  final double waveIntensity;
  final BattleWaveStyle style;

  const BattleWaveCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.backgroundColor = Colors.white,
    this.border,
    this.boxShadow,
    this.leftGlowColor = const Color(0xFF10B981),
    this.centerGlowColor = const Color(0xFFF59E0B),
    this.rightGlowColor = const Color(0xFFEF4444),
    this.waveIntensity = 1.0,
    this.style = BattleWaveStyle.layeredWave,
  });

  @override
  Widget build(BuildContext context) {
    // 28px rounded corners matching the reference image perfectly
    final effectiveRadius = borderRadius ?? BorderRadius.circular(28.0);
    final effectiveBorder =
        border ??
        Border.all(color: const Color(0xFFE2E8F0).withAlpha(160), width: 1.0);
    final effectiveShadow =
        boxShadow ??
        const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: effectiveRadius,
        border: effectiveBorder,
        boxShadow: effectiveShadow,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Stack(
          children: [
            // Layered Wave Custom Painter
            Positioned.fill(
              child: CustomPaint(
                painter: MatchCardWavePainter(
                  leftColor: leftGlowColor,
                  centerColor: centerGlowColor,
                  rightColor: rightGlowColor,
                  intensity: waveIntensity,
                ),
              ),
            ),
            if (padding != null)
              Padding(padding: padding!, child: child)
            else
              child,
          ],
        ),
      ),
    );
  }
}

/// Backward compatibility typedef
typedef BattleBlendedWavesPainter = MatchCardWavePainter;

/// Premium Layered Wave Custom Painter for 1v1 Player Versus Match Cards.
/// Features multiple translucent organic wave ribbons, specular white highlights,
/// and a warm sunny-yellow center gradient that matches the reference image.
class MatchCardWavePainter extends CustomPainter {
  final Color leftColor;
  final Color centerColor;
  final Color rightColor;
  final double intensity;
  final BattleWaveStyle style;

  const MatchCardWavePainter({
    this.leftColor = const Color(0xFF10B981),
    this.centerColor = const Color(0xFFF59E0B),
    this.rightColor = const Color(0xFFEF4444),
    this.intensity = 1.0,
    this.style = BattleWaveStyle.layeredWave,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // -------------------------------------------------------------------------
    // 0. Soft Ambient Halos Behind Avatars
    // -------------------------------------------------------------------------
    final leftHalo = Paint()
      ..isAntiAlias = true
      ..shader =
          RadialGradient(
            colors: [
              const Color(
                0xFF34D399,
              ).withAlpha((20 * intensity).round().clamp(0, 255)),
              const Color(0xFF34D399).withAlpha(0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(w * 0.20, h * 0.32),
              radius: w * 0.26,
            ),
          );
    canvas.drawCircle(Offset(w * 0.20, h * 0.32), w * 0.26, leftHalo);

    final rightHalo = Paint()
      ..isAntiAlias = true
      ..shader =
          RadialGradient(
            colors: [
              const Color(
                0xFFFB7185,
              ).withAlpha((18 * intensity).round().clamp(0, 255)),
              const Color(0xFFFB7185).withAlpha(0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(w * 0.80, h * 0.32),
              radius: w * 0.26,
            ),
          );
    canvas.drawCircle(Offset(w * 0.80, h * 0.32), w * 0.26, rightHalo);

    // -------------------------------------------------------------------------
    // 1. LEFT SIDE - Layer 1: Background Mint Wave (Enters at y = 0.38 * h)
    // -------------------------------------------------------------------------
    final leftWave1 = Path();
    leftWave1.moveTo(0, h * 0.38);
    leftWave1.cubicTo(
      w * 0.10,
      h * 0.48,
      w * 0.20,
      h * 0.72,
      w * 0.34,
      h * 0.76,
    );
    leftWave1.cubicTo(
      w * 0.44,
      h * 0.80,
      w * 0.52,
      h * 0.86,
      w * 0.62,
      h * 0.92,
    );
    leftWave1.cubicTo(w * 0.70, h * 0.96, w * 0.82, h * 0.98, w, h * 0.98);
    leftWave1.lineTo(w, h);
    leftWave1.lineTo(0, h);
    leftWave1.close();

    final leftPaint1 = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        colors: [
          const Color(
            0xFFD1FAE5,
          ).withAlpha((145 * intensity).round().clamp(0, 255)),
          const Color(
            0xFFA7F3D0,
          ).withAlpha((100 * intensity).round().clamp(0, 255)),
          const Color(
            0xFFFEF08A,
          ).withAlpha((50 * intensity).round().clamp(0, 255)),
          const Color(0xFFFEF08A).withAlpha(0),
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(leftWave1, leftPaint1);

    // -------------------------------------------------------------------------
    // 2. RIGHT SIDE - Layer 1: Background Blush Pink Wave (Enters high at y = 0.24 * h)
    // -------------------------------------------------------------------------
    final rightWave1 = Path();
    rightWave1.moveTo(w, h * 0.24);
    rightWave1.cubicTo(
      w * 0.90,
      h * 0.36,
      w * 0.80,
      h * 0.66,
      w * 0.66,
      h * 0.76,
    );
    rightWave1.cubicTo(
      w * 0.54,
      h * 0.84,
      w * 0.44,
      h * 0.90,
      w * 0.32,
      h * 0.94,
    );
    rightWave1.cubicTo(w * 0.20, h * 0.97, w * 0.10, h * 0.98, 0, h * 0.98);
    rightWave1.lineTo(0, h);
    rightWave1.lineTo(w, h);
    rightWave1.close();

    final rightPaint1 = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        colors: [
          const Color(
            0xFFFFCCD5,
          ).withAlpha((150 * intensity).round().clamp(0, 255)),
          const Color(
            0xFFFFE4E6,
          ).withAlpha((100 * intensity).round().clamp(0, 255)),
          const Color(
            0xFFFED7AA,
          ).withAlpha((50 * intensity).round().clamp(0, 255)),
          const Color(0xFFFED7AA).withAlpha(0),
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(rightWave1, rightPaint1);

    // -------------------------------------------------------------------------
    // 3. CENTER BOTTOM - Sunny Golden Yellow Sunset Glow
    // -------------------------------------------------------------------------
    final centerBlend = Paint()
      ..isAntiAlias = true
      ..shader =
          RadialGradient(
            colors: [
              const Color(
                0xFFFDE047,
              ).withAlpha((105 * intensity).round().clamp(0, 255)),
              const Color(
                0xFFFED7AA,
              ).withAlpha((60 * intensity).round().clamp(0, 255)),
              const Color(0xFFFFF7ED).withAlpha(0),
            ],
            stops: const [0.0, 0.50, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: Offset(w * 0.50, h * 0.90),
              radius: w * 0.28,
            ),
          );
    canvas.drawCircle(Offset(w * 0.50, h * 0.90), w * 0.28, centerBlend);

    // -------------------------------------------------------------------------
    // 4. LEFT SIDE - Layer 2: Mid Emerald Wave (Enters at y = 0.52 * h)
    // -------------------------------------------------------------------------
    final leftWave2 = Path();
    leftWave2.moveTo(0, h * 0.52);
    leftWave2.cubicTo(
      w * 0.08,
      h * 0.62,
      w * 0.18,
      h * 0.82,
      w * 0.30,
      h * 0.84,
    );
    leftWave2.cubicTo(
      w * 0.40,
      h * 0.86,
      w * 0.48,
      h * 0.94,
      w * 0.56,
      h * 0.96,
    );
    leftWave2.cubicTo(w * 0.64, h * 0.98, w * 0.72, h * 1.0, w * 0.80, h * 1.0);
    leftWave2.lineTo(w * 0.80, h);
    leftWave2.lineTo(0, h);
    leftWave2.close();

    final leftPaint2 = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        colors: [
          const Color(
            0xFF6EE7B7,
          ).withAlpha((135 * intensity).round().clamp(0, 255)),
          const Color(
            0xFFA7F3D0,
          ).withAlpha((85 * intensity).round().clamp(0, 255)),
          const Color(
            0xFFFEF08A,
          ).withAlpha((40 * intensity).round().clamp(0, 255)),
          const Color(0xFFFEF08A).withAlpha(0),
        ],
        stops: const [0.0, 0.40, 0.80, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(leftWave2, leftPaint2);

    // Razor-clean Left White Highlight Stroke along Wave L2
    final leftHighlight = Path();
    leftHighlight.moveTo(0, h * 0.52);
    leftHighlight.cubicTo(
      w * 0.08,
      h * 0.62,
      w * 0.18,
      h * 0.82,
      w * 0.30,
      h * 0.84,
    );
    leftHighlight.cubicTo(
      w * 0.40,
      h * 0.86,
      w * 0.48,
      h * 0.94,
      w * 0.56,
      h * 0.96,
    );
    final leftHighlightPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          Colors.white.withAlpha((225 * intensity).round().clamp(0, 255)),
          Colors.white.withAlpha((150 * intensity).round().clamp(0, 255)),
          Colors.white.withAlpha(0),
        ],
        stops: const [0.0, 0.65, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, h * 0.52, w * 0.56, h * 0.48));
    canvas.drawPath(leftHighlight, leftHighlightPaint);

    // -------------------------------------------------------------------------
    // 5. RIGHT SIDE - Layer 2: Mid Coral Wave (Enters at y = 0.44 * h)
    // -------------------------------------------------------------------------
    final rightWave2 = Path();
    rightWave2.moveTo(w, h * 0.44);
    rightWave2.cubicTo(
      w * 0.91,
      h * 0.56,
      w * 0.82,
      h * 0.78,
      w * 0.70,
      h * 0.82,
    );
    rightWave2.cubicTo(
      w * 0.60,
      h * 0.86,
      w * 0.52,
      h * 0.94,
      w * 0.44,
      h * 0.96,
    );
    rightWave2.cubicTo(
      w * 0.36,
      h * 0.98,
      w * 0.28,
      h * 1.0,
      w * 0.20,
      h * 1.0,
    );
    rightWave2.lineTo(w * 0.20, h);
    rightWave2.lineTo(w, h);
    rightWave2.close();

    final rightPaint2 = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        colors: [
          const Color(
            0xFFFDA4AF,
          ).withAlpha((135 * intensity).round().clamp(0, 255)),
          const Color(
            0xFFFFCCD5,
          ).withAlpha((85 * intensity).round().clamp(0, 255)),
          const Color(
            0xFFFED7AA,
          ).withAlpha((40 * intensity).round().clamp(0, 255)),
          const Color(0xFFFED7AA).withAlpha(0),
        ],
        stops: const [0.0, 0.40, 0.80, 1.0],
        begin: Alignment.centerRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(rightWave2, rightPaint2);

    // Razor-clean Right White Highlight Stroke along Wave R2
    final rightHighlight = Path();
    rightHighlight.moveTo(w, h * 0.44);
    rightHighlight.cubicTo(
      w * 0.91,
      h * 0.56,
      w * 0.82,
      h * 0.78,
      w * 0.70,
      h * 0.82,
    );
    rightHighlight.cubicTo(
      w * 0.60,
      h * 0.86,
      w * 0.52,
      h * 0.94,
      w * 0.44,
      h * 0.96,
    );
    final rightHighlightPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          Colors.white.withAlpha((225 * intensity).round().clamp(0, 255)),
          Colors.white.withAlpha((150 * intensity).round().clamp(0, 255)),
          Colors.white.withAlpha(0),
        ],
        stops: const [0.0, 0.65, 1.0],
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
      ).createShader(Rect.fromLTWH(w * 0.44, h * 0.44, w * 0.56, h * 0.56));
    canvas.drawPath(rightHighlight, rightHighlightPaint);

    // -------------------------------------------------------------------------
    // 6. LEFT SIDE - Layer 3: Corner Saturated Mint Wave (Enters at y = 0.68 * h)
    // -------------------------------------------------------------------------
    final leftWave3 = Path();
    leftWave3.moveTo(0, h * 0.68);
    leftWave3.cubicTo(
      w * 0.08,
      h * 0.78,
      w * 0.16,
      h * 0.92,
      w * 0.28,
      h * 0.96,
    );
    leftWave3.cubicTo(w * 0.36, h * 0.98, w * 0.42, h * 1.0, w * 0.48, h * 1.0);
    leftWave3.lineTo(w * 0.48, h);
    leftWave3.lineTo(0, h);
    leftWave3.close();

    final leftPaint3 = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        colors: [
          const Color(
            0xFF34D399,
          ).withAlpha((105 * intensity).round().clamp(0, 255)),
          const Color(
            0xFF6EE7B7,
          ).withAlpha((55 * intensity).round().clamp(0, 255)),
          Colors.transparent,
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, h * 0.68, w * 0.48, h * 0.32));
    canvas.drawPath(leftWave3, leftPaint3);

    // -------------------------------------------------------------------------
    // 7. RIGHT SIDE - Layer 3: Corner Saturated Coral Wave (Enters at y = 0.62 * h)
    // -------------------------------------------------------------------------
    final rightWave3 = Path();
    rightWave3.moveTo(w, h * 0.62);
    rightWave3.cubicTo(
      w * 0.92,
      h * 0.74,
      w * 0.84,
      h * 0.90,
      w * 0.72,
      h * 0.95,
    );
    rightWave3.cubicTo(
      w * 0.64,
      h * 0.98,
      w * 0.58,
      h * 1.0,
      w * 0.52,
      h * 1.0,
    );
    rightWave3.lineTo(w * 0.52, h);
    rightWave3.lineTo(w, h);
    rightWave3.close();

    final rightPaint3 = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        colors: [
          const Color(
            0xFFFB7185,
          ).withAlpha((105 * intensity).round().clamp(0, 255)),
          const Color(
            0xFFFDA4AF,
          ).withAlpha((55 * intensity).round().clamp(0, 255)),
          Colors.transparent,
        ],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      ).createShader(Rect.fromLTWH(w * 0.52, h * 0.62, w * 0.48, h * 0.38));
    canvas.drawPath(rightWave3, rightPaint3);
  }

  @override
  bool shouldRepaint(covariant MatchCardWavePainter oldDelegate) =>
      oldDelegate.leftColor != leftColor ||
      oldDelegate.centerColor != centerColor ||
      oldDelegate.rightColor != rightColor ||
      oldDelegate.intensity != intensity ||
      oldDelegate.style != style;
}
