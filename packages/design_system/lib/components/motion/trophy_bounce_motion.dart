import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ultra-Premium Victory Trophy & 3D Golden Rupee Coin Motion Graphic
/// Features:
/// 1. Elastic spring entry bounce with GPU acceleration.
/// 2. 360-degree rotating tapered radiant sunburst with soft radial falloff.
/// 3. Ambient vertical floating hover.
/// 4. Dynamic diagonal glossy light sheen sweep.
/// 5. Embossed 3D metallic golden coin rendering with '₹' and sparkles.
class TrophyBounceMotion extends StatefulWidget {
  final double size;
  final IconData? icon;
  final bool isCoin;
  final Color primaryColor;
  final Color secondaryColor;
  final String? badgeText;

  const TrophyBounceMotion({
    super.key,
    this.size = 100,
    this.icon,
    this.isCoin = false,
    this.primaryColor = const Color(0xFFFFB800),
    this.secondaryColor = const Color(0xFFEA580C),
    this.badgeText,
  });

  @override
  State<TrophyBounceMotion> createState() => _TrophyBounceMotionState();
}

class _TrophyBounceMotionState extends State<TrophyBounceMotion>
    with TickerProviderStateMixin {
  late AnimationController _springController;
  late Animation<double> _scaleAnimation;

  late AnimationController _auraController;
  late AnimationController _hoverController;
  late AnimationController _sheenController;
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();

    // 1. Spring Entrance
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _springController,
      curve: Curves.elasticOut,
    );
    _springController.forward();

    // 2. Rotating Aura
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    // 3. Gentle Hover
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // 4. Glossy Light Sweep Sheen
    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // 5. Sparkle Twinkle
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _springController.dispose();
    _auraController.dispose();
    _hoverController.dispose();
    _sheenController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auraSize = widget.size * 1.8;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _auraController,
        _hoverController,
        _sheenController,
        _sparkleController,
      ]),
      builder: (context, child) {
        final hoverOffset = math.sin(_hoverController.value * math.pi * 2) * 3.5;
        final sheenProgress = _sheenController.value;

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: Offset(0, hoverOffset),
            child: SizedBox(
              width: auraSize,
              height: auraSize,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // 1. Radiant Rotating Sunburst Aura with Soft Radial Falloff
                  Transform.rotate(
                    angle: _auraController.value * math.pi * 2,
                    child: CustomPaint(
                      size: Size(auraSize, auraSize),
                      painter: _AuraSunburstPainter(
                        color: widget.primaryColor,
                      ),
                    ),
                  ),

                  // 2. Twinkling Ambient Sparkle Stars
                  CustomPaint(
                    size: Size(auraSize, auraSize),
                    painter: _SparklePainter(
                      progress: _sparkleController.value,
                      auraSize: auraSize,
                    ),
                  ),

                  // 3. Main Center Badge / 3D Coin
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.primaryColor.withValues(alpha: 0.45),
                          blurRadius: 22,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (widget.isCoin)
                          // Custom 3D Embossed Gold Rupee Coin
                          CustomPaint(
                            size: Size(widget.size, widget.size),
                            painter: _Coin3DPainter(),
                          )
                        else
                          // Trophy / Custom Icon Circle
                          Container(
                            width: widget.size,
                            height: widget.size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [widget.primaryColor, widget.secondaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                widget.icon ?? Icons.emoji_events_rounded,
                                size: widget.size * 0.55,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        // Diagonal Light Sheen Sweep
                        ClipOval(
                          child: CustomPaint(
                            size: Size(widget.size, widget.size),
                            painter: _SheenPainter(progress: sheenProgress),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. Optional Floating Badge Chip
                  if (widget.badgeText != null)
                    Positioned(
                      bottom: (auraSize - widget.size) / 2 - 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.badgeText!,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Soft Radial Tapered God-Rays / Sunburst
class _AuraSunburstPainter extends CustomPainter {
  final Color color;

  _AuraSunburstPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const rayCount = 14;

    final rayPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.45),
          color.withValues(alpha: 0.20),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.25, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    for (int i = 0; i < rayCount; i++) {
      final startAngle = (i * 2 * math.pi) / rayCount;
      const sweepAngle = (2 * math.pi) / (rayCount * 2.4); // Tapered elegant rays
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AuraSunburstPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Embossed 3D Metallic Golden Rupee Coin Painter
class _Coin3DPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Outer Metallic Rim Gradient
    final outerPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFFDF00), // Bright Gold
          Color(0xFFF59E0B), // Warm Amber
          Color(0xFFD97706), // Deep Bronze Gold
        ],
        stops: [0.7, 0.92, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, outerPaint);

    // 2. Outer Rim Highlight Line
    final rimStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFBEB), Color(0xFFB45309)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 1.0, rimStroke);

    // 3. Inner Concentric Groove
    final innerRadius = radius * 0.82;
    final innerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFDE68A), // Light Gold
          Color(0xFFF59E0B), // Rich Amber
          Color(0xFFB45309), // Bronze Shadow
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: innerRadius));
    canvas.drawCircle(center, innerRadius, innerPaint);

    // Inner Bevel Stroke
    final innerBevel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFD97706).withValues(alpha: 0.6);
    canvas.drawCircle(center, innerRadius, innerBevel);

    // 4. Center Embossed Rupee Symbol '₹'
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '₹',
        style: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 48,
          fontWeight: FontWeight.w900,
          fontFamily: 'Inter',
          shadows: [
            Shadow(
              color: Color(0xFF78350F),
              offset: Offset(0, 2),
              blurRadius: 3,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _Coin3DPainter oldDelegate) => false;
}

/// Twinkling 4-point Sparkle Stars
class _SparklePainter extends CustomPainter {
  final double progress;
  final double auraSize;

  _SparklePainter({required this.progress, required this.auraSize});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFFFFFBEB).withValues(alpha: 0.4 + (progress * 0.5))
      ..style = PaintingStyle.fill;

    // Draw 4 distinct sparkle stars around the coin
    final starOffsets = [
      Offset(center.dx - (auraSize * 0.32), center.dy - (auraSize * 0.30)),
      Offset(center.dx + (auraSize * 0.34), center.dy - (auraSize * 0.22)),
      Offset(center.dx - (auraSize * 0.28), center.dy + (auraSize * 0.28)),
      Offset(center.dx + (auraSize * 0.30), center.dy + (auraSize * 0.32)),
    ];

    for (int i = 0; i < starOffsets.length; i++) {
      final pos = starOffsets[i];
      final starSize = (i.isEven ? 8.0 : 6.0) * (0.8 + (progress * 0.4));
      _drawStar(canvas, pos, starSize, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset pos, double size, Paint paint) {
    final path = Path();
    path.moveTo(pos.dx, pos.dy - size);
    path.quadraticBezierTo(pos.dx, pos.dy, pos.dx + size, pos.dy);
    path.quadraticBezierTo(pos.dx, pos.dy, pos.dx, pos.dy + size);
    path.quadraticBezierTo(pos.dx, pos.dy, pos.dx - size, pos.dy);
    path.quadraticBezierTo(pos.dx, pos.dy, pos.dx, pos.dy - size);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _SheenPainter extends CustomPainter {
  final double progress;

  _SheenPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress > 0.6) return;

    final normalized = progress / 0.6;
    final x = (normalized * (size.width * 2)) - size.width;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.45),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(x - 25, 0, 50, size.height));

    canvas.save();
    canvas.rotate(0.45);
    canvas.drawRect(Rect.fromLTWH(x, -size.height, 40, size.height * 3), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SheenPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
