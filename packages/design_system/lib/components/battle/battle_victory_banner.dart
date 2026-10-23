import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Victory Celebratory Stadium Banner
/// Direct visual parity with Reference Image 1:
/// - Lush green stadium backdrop with floodlight rays & confetti
/// - 3D Golden trophy with glowing radial aura, golden laurels & crown
/// - 3D Emerald victory ribbon with golden typography
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
      duration: const Duration(seconds: 4),
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
        : (widget.isDraw ? 'MATCH TIED!' : 'DEFEAT');

    final bgGradient = widget.isVictory
        ? const LinearGradient(
            colors: [Color(0xFF034A29), Color(0xFF06723E), Color(0xFF02361D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : (widget.isDraw
            ? const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF172554)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF7F1D1D), Color(0xFFDC2626), Color(0xFF450A0A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ));

    return Container(
      height: 165,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final t = _animController.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. Stadium Lights & Sunburst Rays
              CustomPaint(
                size: const Size(double.infinity, 165),
                painter: _StadiumRaysPainter(
                  rotation: t * 2 * math.pi * 0.08,
                  isVictory: widget.isVictory,
                ),
              ),

              // 2. Confetti Particles
              if (widget.isVictory || widget.isDraw)
                CustomPaint(
                  size: const Size(double.infinity, 165),
                  painter: _ConfettiPainter(progress: t),
                ),

              // 3. Side Graphics: Practice Learn Earn & Small Steps Big Results signs
              Positioned(
                left: 14,
                bottom: 14,
                child: Opacity(
                  opacity: 0.85,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(80),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withAlpha(50)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('PRACTICE', style: TextStyle(color: Color(0xFF86EFAC), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        Text('LEARN • EARN', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 14,
                bottom: 14,
                child: Opacity(
                  opacity: 0.85,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(80),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withAlpha(50)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('SMALL STEPS', style: TextStyle(color: Color(0xFFFDE047), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        Text('BIG RESULTS!', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Center Trophy and Ribbon
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glowing Trophy with Laurels and Crown
                  SizedBox(
                    height: 82,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Radial Gold Glow
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                (widget.isVictory ? const Color(0xFFFACC15) : const Color(0xFF60A5FA)).withAlpha(120),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Golden Laurel Wreath (Vector Wings)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.rotate(
                              angle: -0.2,
                              child: Icon(
                                Icons.eco_rounded,
                                size: 30,
                                color: widget.isVictory ? const Color(0xFFEAB308) : const Color(0xFF93C5FD),
                              ),
                            ),
                            const SizedBox(width: 48),
                            Transform.rotate(
                              angle: 0.2,
                              child: Transform.scale(
                                scaleX: -1,
                                child: Icon(
                                  Icons.eco_rounded,
                                  size: 30,
                                  color: widget.isVictory ? const Color(0xFFEAB308) : const Color(0xFF93C5FD),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // 3D Trophy Cup
                        Icon(
                          widget.isVictory
                              ? Icons.emoji_events_rounded
                              : (widget.isDraw ? Icons.handshake_rounded : Icons.sentiment_dissatisfied_rounded),
                          size: 58,
                          color: widget.isVictory
                              ? const Color(0xFFFFD700)
                              : (widget.isDraw ? const Color(0xFF93C5FD) : const Color(0xFFFCA5A5)),
                        ),
                        // Golden Crown atop Trophy
                        if (widget.isVictory)
                          const Positioned(
                            top: 0,
                            child: Icon(
                              Icons.military_tech_rounded,
                              size: 20,
                              color: Color(0xFFFFFBEB),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 3D Ribbon Banner
                  Transform.translate(
                    offset: const Offset(0, -6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.isVictory
                              ? const [Color(0xFF00B96B), Color(0xFF006C3A)]
                              : (widget.isDraw
                                  ? const [Color(0xFF3B82F6), Color(0xFF1D4ED8)]
                                  : const [Color(0xFFEF4444), Color(0xFF991B1B)]),
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withAlpha(180),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFEF08A),
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
            ],
          );
        },
      ),
    );
  }
}

class _StadiumRaysPainter extends CustomPainter {
  final double rotation;
  final bool isVictory;

  _StadiumRaysPainter({required this.rotation, required this.isVictory});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.4);
    final paint = Paint()
      ..color = (isVictory ? const Color(0xFF4ADE80) : const Color(0xFF60A5FA)).withAlpha(22)
      ..style = PaintingStyle.fill;

    const numRays = 16;
    final angleStep = (2 * math.pi) / numRays;
    final radius = size.width * 0.8;

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
  bool shouldRepaint(covariant _StadiumRaysPainter oldDelegate) => true;
}

class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFFFFD54F),
      const Color(0xFF4ADE80),
      const Color(0xFFFFFFFF),
      const Color(0xFFF472B6),
      const Color(0xFF38BDF8),
    ];

    for (int i = 0; i < 24; i++) {
      final baseX = ((i * 37) % size.width.toInt()).toDouble();
      final startY = ((i * 19) % size.height.toInt()).toDouble();
      final speed = 1.0 + ((i % 3) * 0.4);
      final currentY = (startY + (progress * 140 * speed)) % size.height;
      final color = colors[i % colors.length];

      final paint = Paint()..color = color.withAlpha(200);

      canvas.save();
      canvas.translate(baseX, currentY);
      canvas.rotate(progress * math.pi * (i % 2 == 0 ? 2 : -2));

      if (i % 3 == 0) {
        canvas.drawCircle(Offset.zero, 3.0, paint);
      } else {
        canvas.drawRect(const Rect.fromLTWH(-2.5, -1.8, 5, 3.6), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
