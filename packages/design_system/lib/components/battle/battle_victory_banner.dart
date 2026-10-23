import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Victory Celebratory Banner with Sunburst Rays, Golden Trophy,
/// Laurel Wreath, 3D Green Victory Ribbon, and Confetti particles.
class VictoryBanner extends StatefulWidget {
  final bool isVictory;
  final bool isDraw;

  const VictoryBanner({
    super.key,
    this.isVictory = true,
    this.isDraw = false,
  });

  @override
  State<VictoryBanner> createState() => _VictoryBannerState();
}

class _VictoryBannerState extends State<VictoryBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isVictory
        ? 'VICTORY!'
        : (widget.isDraw ? 'MATCH DRAW!' : 'DEFEAT!');

    return SizedBox(
      height: 230,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final t = _animController.value;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Radiant Green Sunburst / Background Glow
              CustomPaint(
                size: const Size(double.infinity, 230),
                painter: _SunburstPainter(
                  rotation: t * 2 * math.pi * 0.1,
                  isVictory: widget.isVictory,
                ),
              ),

              // 2. Floating Confetti Particles
              if (widget.isVictory)
                CustomPaint(
                  size: const Size(double.infinity, 230),
                  painter: _ConfettiPainter(progress: t),
                ),

              // 3. Central Trophy Artwork
              Positioned(
                top: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trophy Cup with Crown & Laurels
                    SizedBox(
                      width: 140,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Laurel Wreath
                          Text(
                            widget.isVictory ? '🌿 🏆 🌿' : (widget.isDraw ? '🤝' : '💔'),
                            style: const TextStyle(fontSize: 56),
                          ),
                          if (widget.isVictory)
                            const Positioned(
                              top: 2,
                              child: Text('👑', style: TextStyle(fontSize: 22)),
                            ),
                          if (widget.isVictory)
                            const Positioned(
                              top: 6,
                              right: 12,
                              child: Text('✨', style: TextStyle(fontSize: 16)),
                            ),
                          if (widget.isVictory)
                            const Positioned(
                              bottom: 12,
                              left: 10,
                              child: Text('✨', style: TextStyle(fontSize: 14)),
                            ),
                        ],
                      ),
                    ),

                    // 4. Curved Green 3D Ribbon with VICTORY!
                    Transform.translate(
                      offset: const Offset(0, -10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.isVictory
                                ? const [Color(0xFF00C975), Color(0xFF007A43)]
                                : (widget.isDraw
                                    ? const [Color(0xFF3B82F6), Color(0xFF1D4ED8)]
                                    : const [Color(0xFFEF4444), Color(0xFF991B1B)]),
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (widget.isVictory
                                      ? const Color(0xFF007A43)
                                      : const Color(0xFF991B1B))
                                  .withAlpha(120),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withAlpha(80),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFEB3B),
                            letterSpacing: 1.5,
                            fontFamily: 'Inter',
                            shadows: [
                              Shadow(
                                color: Color(0x99000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  final double rotation;
  final bool isVictory;

  _SunburstPainter({required this.rotation, required this.isVictory});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 70);
    final paint = Paint()
      ..color = (isVictory ? const Color(0xFF00C975) : const Color(0xFFEF4444)).withAlpha(20)
      ..style = PaintingStyle.fill;

    const numRays = 16;
    final angleStep = (2 * math.pi) / numRays;
    final radius = size.width * 0.7;

    for (int i = 0; i < numRays; i += 2) {
      final startAngle = rotation + (i * angleStep);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          angleStep,
          false,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) => true;
}

class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFFFFD54F),
      const Color(0xFF00E676),
      const Color(0xFFFFFFFF),
      const Color(0xFFFF80AB),
      const Color(0xFF40C4FF),
    ];

    final random = math.Random(42);

    for (int i = 0; i < 28; i++) {
      final baseX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * 200;
      final speed = 1.0 + (random.nextDouble() * 1.5);
      final currentY = (startY + (progress * 180 * speed)) % 220;
      final color = colors[i % colors.length];

      final paint = Paint()..color = color.withAlpha(200);

      canvas.save();
      canvas.translate(baseX, currentY);
      canvas.rotate(progress * math.pi * (i % 2 == 0 ? 2 : -2));

      if (i % 3 == 0) {
        canvas.drawCircle(Offset.zero, 3.5, paint);
      } else {
        canvas.drawRect(const Rect.fromLTWH(-3, -2, 6, 4), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
