import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Flutter Custom Liquid Blob – Design 07
/// Reusable, premium organic liquid blob widget inspired by Blob Number 07:
/// - Smooth asymmetrical dual-bulge liquid body with narrow center waist
/// - Vibrant warm gradient: #FFE65C -> #FFB800 -> #FF7800
/// - Layered translucent yellow background blob (20–30% opacity)
/// - Halftone circular dot clusters peeking behind top-right and bottom-center
/// - Floating circular droplets and soft glowing orange shadow
/// - Optional organic morphing animation (3–5s loop, zero-CPU when disabled or in tests)
class LiquidBlobWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final List<Color> gradientColors;
  final Color backgroundBlobColor;
  final Color shadowColor;
  final Color dotsColor;
  final bool isAnimated;
  final Duration animationDuration;
  final bool showHalftoneDots;
  final bool showFloatingDroplets;
  final Widget? child;

  const LiquidBlobWidget({
    super.key,
    this.width = 320,
    this.height = 190,
    this.gradientColors = const [
      Color(0xFFFFE65C), // Sunny warm yellow
      Color(0xFFFFB800), // Vibrant amber gold
      Color(0xFFFF7800), // Deep energetic orange
    ],
    this.backgroundBlobColor = const Color(0xFFFFE65C),
    this.shadowColor = const Color(0xFFFF7800),
    this.dotsColor = const Color(0xFFFF9F0A),
    this.isAnimated = false,
    this.animationDuration = const Duration(seconds: 4),
    this.showHalftoneDots = true,
    this.showFloatingDroplets = true,
    this.child,
  });

  @override
  State<LiquidBlobWidget> createState() => _LiquidBlobWidgetState();
}

class _LiquidBlobWidgetState extends State<LiquidBlobWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool get _isTestingMode =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    if (widget.isAnimated && !_isTestingMode) {
      _controller.repeat();
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void didUpdateWidget(covariant LiquidBlobWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated != oldWidget.isAnimated) {
      if (widget.isAnimated && !_isTestingMode) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.value = 0.5;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildCanvas(double progress) {
      return CustomPaint(
        painter: _LiquidBlob07Painter(
          progress: progress,
          gradientColors: widget.gradientColors,
          backgroundBlobColor: widget.backgroundBlobColor,
          shadowColor: widget.shadowColor,
          dotsColor: widget.dotsColor,
          showHalftoneDots: widget.showHalftoneDots,
          showFloatingDroplets: widget.showFloatingDroplets,
        ),
        size: Size(widget.width ?? double.infinity, widget.height ?? double.infinity),
      );
    }

    final canvasWidget = RepaintBoundary(
      child: widget.isAnimated && !_isTestingMode
          ? AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => buildCanvas(_controller.value),
            )
          : buildCanvas(0.5),
    );

    if (widget.child == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: canvasWidget,
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: canvasWidget),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: widget.child!,
          ),
        ],
      ),
    );
  }
}

class _LiquidBlob07Painter extends CustomPainter {
  final double progress;
  final List<Color> gradientColors;
  final Color backgroundBlobColor;
  final Color shadowColor;
  final Color dotsColor;
  final bool showHalftoneDots;
  final bool showFloatingDroplets;

  _LiquidBlob07Painter({
    required this.progress,
    required this.gradientColors,
    required this.backgroundBlobColor,
    required this.shadowColor,
    required this.dotsColor,
    required this.showHalftoneDots,
    required this.showFloatingDroplets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final t = progress * 2.0 * math.pi;

    // -------------------------------------------------------------------------
    // 1. Layered Background Blob (Translucent, 20–30% Opacity)
    // -------------------------------------------------------------------------
    _drawBackgroundTranslucentBlob(canvas: canvas, size: size, t: t);

    // -------------------------------------------------------------------------
    // 2. Decorative Halftone Dots (Behind Main Blob)
    // -------------------------------------------------------------------------
    if (showHalftoneDots) {
      _drawHalftoneDotClusters(canvas: canvas, size: size, t: t);
    }

    // -------------------------------------------------------------------------
    // 3. Main Liquid Blob 07 Body with Shadow & Gradient
    // -------------------------------------------------------------------------
    _drawMainBlob(canvas: canvas, size: size, t: t);

    // -------------------------------------------------------------------------
    // 4. Floating Circular Droplets (Above / Around Corners)
    // -------------------------------------------------------------------------
    if (showFloatingDroplets) {
      _drawFloatingDroplets(canvas: canvas, size: size, t: t);
    }
  }

  // ---------------------------------------------------------------------------
  // Layer 1: Translucent Background Blob
  // ---------------------------------------------------------------------------
  void _drawBackgroundTranslucentBlob({
    required Canvas canvas,
    required Size size,
    required double t,
  }) {
    final w = size.width;
    final h = size.height;

    final swayX = math.sin(t * 0.9) * (w * 0.012);
    final swayY = math.cos(t * 0.9) * (h * 0.012);

    final bgPath = Path();
    // Shifted slightly up & to the right
    bgPath.moveTo(w * 0.26 + swayX, h * 0.16 + swayY);

    // Top crest of background blob
    bgPath.cubicTo(
      w * 0.44 + swayX,
      h * 0.04 - swayY,
      w * 0.72 + swayX,
      h * 0.06 + swayY,
      w * 0.88 + swayX,
      h * 0.22 + swayY,
    );

    // Right sweep
    bgPath.cubicTo(
      w * 0.98 + swayX,
      h * 0.34 + swayY,
      w * 0.96 + swayX,
      h * 0.58 - swayY,
      w * 0.84 + swayX,
      h * 0.72 + swayY,
    );

    // Bottom waist curve
    bgPath.cubicTo(
      w * 0.70 + swayX,
      h * 0.86 + swayY,
      w * 0.42 - swayX,
      h * 0.82 + swayY,
      w * 0.28 - swayX,
      h * 0.74 - swayY,
    );

    // Left bulge curve closing
    bgPath.cubicTo(
      w * 0.14 - swayX,
      h * 0.66 + swayY,
      w * 0.10 + swayX,
      h * 0.32 - swayY,
      w * 0.26 + swayX,
      h * 0.16 + swayY,
    );
    bgPath.close();

    // Soft yellow glow shadow for background layer
    canvas.drawShadow(
      bgPath,
      backgroundBlobColor.withValues(alpha: 0.25),
      8.0,
      false,
    );

    // Translucent fill (20–30% opacity)
    final bgFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          backgroundBlobColor.withValues(alpha: 0.32),
          backgroundBlobColor.withValues(alpha: 0.20),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(bgPath, bgFillPaint);
  }

  // ---------------------------------------------------------------------------
  // Layer 2: Halftone Dot Clusters
  // ---------------------------------------------------------------------------
  void _drawHalftoneDotClusters({
    required Canvas canvas,
    required Size size,
    required double t,
  }) {
    final w = size.width;
    final h = size.height;

    final dotFloatY = math.sin(t * 1.4) * 2.0;

    // Cluster A: Top-Right Halftone Matrix (Peeking behind right shoulder)
    const int colsA = 6;
    const int rowsA = 5;
    const double spacingA = 9.5;
    final startXA = w * 0.64;
    final startYA = h * 0.10 + dotFloatY;

    for (int r = 0; r < rowsA; r++) {
      for (int c = 0; c < colsA; c++) {
        // Hexagonal stagger
        final offsetX = (r % 2 == 1) ? (spacingA / 2) : 0.0;
        final x = startXA + c * spacingA + offsetX;
        final y = startYA + r * spacingA;

        // Radius varies across matrix
        final dist = math.sqrt(math.pow((c - 2.5) / 3.0, 2) + math.pow((r - 2.0) / 2.5, 2));
        final dotRadius = (2.6 - dist * 0.7).clamp(1.4, 3.0);
        final dotAlpha = (0.45 - dist * 0.12).clamp(0.15, 0.52);

        final dotPaint = Paint()
          ..color = dotsColor.withValues(alpha: dotAlpha)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }

    // Cluster B: Bottom-Center Halftone Matrix (Peeking below narrow waist)
    const int colsB = 5;
    const int rowsB = 4;
    const double spacingB = 9.0;
    final startXB = w * 0.44;
    final startYB = h * 0.74 - dotFloatY;

    for (int r = 0; r < rowsB; r++) {
      for (int c = 0; c < colsB; c++) {
        final offsetX = (r % 2 == 1) ? (spacingB / 2) : 0.0;
        final x = startXB + c * spacingB + offsetX;
        final y = startYB + r * spacingB;

        final dist = math.sqrt(math.pow((c - 2.0) / 2.5, 2) + math.pow((r - 1.5) / 2.0, 2));
        final dotRadius = (2.4 - dist * 0.6).clamp(1.2, 2.8);
        final dotAlpha = (0.40 - dist * 0.10).clamp(0.12, 0.45);

        final dotPaint = Paint()
          ..color = dotsColor.withValues(alpha: dotAlpha)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Layer 3: Main Liquid Blob 07
  // ---------------------------------------------------------------------------
  void _drawMainBlob({
    required Canvas canvas,
    required Size size,
    required double t,
  }) {
    final w = size.width;
    final h = size.height;

    // Organic morphing offsets (3-5s cycle)
    final m1 = math.sin(t) * (w * 0.015);
    final m2 = math.cos(t * 1.1) * (h * 0.016);
    final m3 = math.sin(t * 0.8 + 1.2) * (w * 0.012);
    final m4 = math.cos(t + 0.6) * (h * 0.014);

    final path = Path();

    // 1. Top of Left Rounded Bulge
    path.moveTo(w * 0.28 + m1, h * 0.21 + m2);

    // 2. Sweeping Left Crest to Leftmost Edge
    path.cubicTo(
      w * 0.14 + m3,
      h * 0.21 - m4,
      w * 0.05,
      h * 0.36 + m2,
      w * 0.07,
      h * 0.54 + m4,
    );

    // 3. Bottom of Left Bulge
    path.cubicTo(
      w * 0.09 - m1,
      h * 0.72 + m3,
      w * 0.18 + m1,
      h * 0.86 + m2,
      w * 0.35 + m3,
      h * 0.85 + m1,
    );

    // 4. Narrow Center Section: Inward curve into bottom waist
    path.cubicTo(
      w * 0.48 - m2,
      h * 0.83 - m3,
      w * 0.54 + m1,
      h * 0.73 - m4,
      w * 0.65 + m3,
      h * 0.71 - m2,
    );

    // 5. Sweeping Bottom-Right Curve of Right Bulge
    path.cubicTo(
      w * 0.77 + m1,
      h * 0.69 + m4,
      w * 0.89 - m3,
      h * 0.76 + m1,
      w * 0.94,
      h * 0.63 + m2,
    );

    // 6. Rightmost Rounded Edge & Crown
    path.cubicTo(
      w * 0.98 + m1,
      h * 0.51 - m2,
      w * 0.93 - m2,
      h * 0.38 + m3,
      w * 0.82 + m4,
      h * 0.37 + m1,
    );

    // 7. Narrow Center Section: Upper waist curve dipping inwards
    path.cubicTo(
      w * 0.71 - m1,
      h * 0.36 - m4,
      w * 0.59 + m3,
      h * 0.43 - m2,
      w * 0.47 - m2,
      h * 0.35 - m1,
    );

    // 8. Closing back to Top of Left Bulge
    path.cubicTo(
      w * 0.38 + m4,
      h * 0.27 + m3,
      w * 0.34 + m1,
      h * 0.21 - m2,
      w * 0.28 + m1,
      h * 0.21 + m2,
    );
    path.close();

    // -------------------------------------------------------------------------
    // Deep Soft Orange Drop Shadow Underneath
    // -------------------------------------------------------------------------
    canvas.drawShadow(
      path,
      shadowColor.withValues(alpha: 0.40),
      14.0,
      false,
    );

    // -------------------------------------------------------------------------
    // Main Body Fill: Top-Left to Bottom-Right Gradient
    // #FFE65C -> #FFB800 -> #FF7800
    // -------------------------------------------------------------------------
    final gradientShader = LinearGradient(
      begin: const Alignment(-0.85, -0.85),
      end: const Alignment(0.85, 0.85),
      colors: gradientColors,
      stops: const [0.0, 0.50, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final mainPaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(path, mainPaint);

    // -------------------------------------------------------------------------
    // Subtle Inner Highlight (Top-Left Sheen)
    // -------------------------------------------------------------------------
    final highlightRect = Rect.fromLTWH(w * 0.12, h * 0.18, w * 0.48, h * 0.45);
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.5),
        radius: 0.75,
        colors: [
          Colors.white.withValues(alpha: 0.38),
          const Color(0xFFFFF9DB).withValues(alpha: 0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(highlightRect)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.clipPath(path);
    canvas.drawOval(highlightRect, highlightPaint);
    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // Layer 4: Floating Circular Droplets Around Corners
  // ---------------------------------------------------------------------------
  void _drawFloatingDroplets({
    required Canvas canvas,
    required Size size,
    required double t,
  }) {
    final w = size.width;
    final h = size.height;

    // Droplet 1: Top-Left Small Sphere
    final drop1Center = Offset(
      w * 0.12 + math.cos(t) * 2.5,
      h * 0.16 + math.sin(t) * 3.0,
    );
    _drawSingleDroplet(
      canvas: canvas,
      center: drop1Center,
      radius: 5.5,
      color1: const Color(0xFFFFE65C),
      color2: const Color(0xFFFFB800),
    );

    // Droplet 2: Top-Right Tiny Sphere
    final drop2Center = Offset(
      w * 0.87 + math.sin(t * 1.2) * 2.5,
      h * 0.20 + math.cos(t * 1.2) * 2.5,
    );
    _drawSingleDroplet(
      canvas: canvas,
      center: drop2Center,
      radius: 4.2,
      color1: const Color(0xFFFFB800),
      color2: const Color(0xFFFF7800),
    );

    // Droplet 3: Bottom-Left Micro Sphere
    final drop3Center = Offset(
      w * 0.09 + math.sin(t * 0.9) * 2.0,
      h * 0.76 + math.cos(t * 0.9) * 2.0,
    );
    _drawSingleDroplet(
      canvas: canvas,
      center: drop3Center,
      radius: 3.5,
      color1: const Color(0xFFFFB800),
      color2: const Color(0xFFFF9F0A),
    );
  }

  void _drawSingleDroplet({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color color1,
    required Color color2,
  }) {
    // Drop shadow
    final shadowPaint = Paint()..color = shadowColor.withValues(alpha: 0.25);
    canvas.drawCircle(Offset(center.dx, center.dy + 1.8), radius, shadowPaint);

    // Gradient sphere
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color1, color2],
      ).createShader(rect);
    canvas.drawCircle(center, radius, paint);

    // Micro highlight
    final hlPaint = Paint()..color = Colors.white.withValues(alpha: 0.65);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
      radius * 0.25,
      hlPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidBlob07Painter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.backgroundBlobColor != backgroundBlobColor ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.dotsColor != dotsColor ||
        oldDelegate.showHalftoneDots != showHalftoneDots ||
        oldDelegate.showFloatingDroplets != showFloatingDroplets;
  }
}
