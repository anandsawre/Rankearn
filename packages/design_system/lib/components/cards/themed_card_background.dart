import 'package:flutter/material.dart';
import '../../tokens/radii.dart';

/// Clean, modern Card Background featuring a sleek Tech Dot-Matrix pattern,
/// ambient radial spotlight glow, and subtle watermark accent.
///
/// Designed to be crisp, elegant, and clutter-free across all screen densities.
class ThemedCardBackground extends StatelessWidget {
  /// The primary accent color defining the card's decorative hue.
  final Color accentColor;

  /// Optional base background color. If null, computed from [accentColor].
  final Color? backgroundColor;

  /// Optional watermark icon displayed faintly in the card background.
  final IconData? watermarkIcon;

  /// Rotation angle of the watermark icon in radians. Defaults to -0.12.
  final double watermarkAngle;

  /// Size of the watermark icon. Defaults to 52.
  final double watermarkSize;

  /// Explicit width of the card.
  final double? width;

  /// Explicit height of the card.
  final double? height;

  /// Internal padding for the card content.
  final EdgeInsetsGeometry? padding;

  /// Border radius of the card. Defaults to [AppRadii.borderLg] (16dp).
  final BorderRadius? borderRadius;

  /// Border around the card. Defaults to subtle [accentColor] outline.
  final BoxBorder? border;

  /// Custom shadow for the card. Defaults to a soft ambient accent glow.
  final List<BoxShadow>? boxShadow;

  /// Custom gradient override. If null, a multi-stop ambient gradient is generated.
  final Gradient? gradient;

  /// Optional tap callback. If provided, card is wrapped in [InkWell].
  final VoidCallback? onTap;

  /// Whether to render decorative ambient shapes (dot grid, radial glow).
  final bool showDecorations;

  /// Whether to render the background watermark icon if [watermarkIcon] is provided.
  final bool showWatermark;

  /// Main card content widget.
  final Widget child;

  const ThemedCardBackground({
    super.key,
    required this.accentColor,
    this.backgroundColor,
    this.watermarkIcon,
    this.watermarkAngle = -0.12,
    this.watermarkSize = 52,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
    this.onTap,
    this.showDecorations = true,
    this.showWatermark = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadii.borderLg;
    final effectiveBg = backgroundColor ?? accentColor.withAlpha(20);

    final effectiveGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(accentColor.withAlpha(28), Colors.white),
            Color.alphaBlend(accentColor.withAlpha(12), Colors.white),
            effectiveBg,
          ],
        );

    final effectiveBorder = border ??
        Border.all(
          color: accentColor.withAlpha(50),
          width: 1.1,
        );

    final effectiveShadow = boxShadow ??
        [
          BoxShadow(
            color: accentColor.withAlpha(22),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          const BoxShadow(
            color: Color(0x06101A3A),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ];

    Widget content = padding != null
        ? Padding(padding: padding!, child: child)
        : child;

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          child: content,
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        borderRadius: effectiveRadius,
        border: effectiveBorder,
        boxShadow: effectiveShadow,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Stack(
          children: [
            // --- 1. Ambient Tech Dot-Matrix & Halo Glow ---
            if (showDecorations)
              Positioned.fill(
                child: CustomPaint(
                  painter: _TechDotMatrixPainter(accentColor: accentColor),
                ),
              ),

            // --- 2. Watermark Icon ---
            if (showWatermark && watermarkIcon != null)
              Positioned(
                right: -6,
                bottom: 2,
                child: IgnorePointer(
                  child: Transform.rotate(
                    angle: watermarkAngle,
                    child: Icon(
                      watermarkIcon,
                      size: watermarkSize,
                      color: accentColor.withAlpha(22),
                    ),
                  ),
                ),
              ),

            // --- 3. Foreground Interactive Content ---
            content,
          ],
        ),
      ),
    );
  }
}

/// CustomPainter for rendering a subtle, modern Tech Dot-Matrix grid and halo
class _TechDotMatrixPainter extends CustomPainter {
  final Color accentColor;

  const _TechDotMatrixPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Soft Circular Halo in Top-Right
    final haloPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topRight,
        radius: 0.9,
        colors: [
          accentColor.withAlpha(24),
          accentColor.withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), haloPaint);

    // 2. Subtle Geometric Ring in Top-Right
    final ringPaint = Paint()
      ..color = accentColor.withAlpha(22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(w + 2, -2), w * 0.45, ringPaint);

    // 3. Modern Dot-Matrix Grid in Top-Right Corner (5 cols x 4 rows)
    final dotPaint = Paint()
      ..color = accentColor.withAlpha(40)
      ..style = PaintingStyle.fill;

    const spacing = 9.0;
    const dotRadius = 1.2;
    const cols = 5;
    const rows = 4;
    final startX = w - (cols * spacing) - 4;
    const startY = 8.0;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Fade out dots towards the interior
        final alphaFactor = (1.0 - (c * 0.15)) * (1.0 - (r * 0.15));
        if (alphaFactor > 0.1) {
          final p = Paint()
            ..color = accentColor.withAlpha((40 * alphaFactor).toInt())
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            Offset(startX + (c * spacing), startY + (r * spacing)),
            dotRadius,
            p,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TechDotMatrixPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor;
  }
}
