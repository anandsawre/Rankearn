import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Single particle representing a coin, star, or ribbon confetti.
class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double rotation;
  double rotationSpeed;
  double size;
  Color color;
  bool isCoin;
  double opacity;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.isCoin,
    this.opacity = 1.0,
  });
}

/// Production-grade GPU-accelerated Confetti & Golden Coin Shower Motion Graphic
/// Runs at 60-120fps with zero third-party package dependencies.
class CelebrationConfettiMotion extends StatefulWidget {
  final Widget? child;
  final bool autoStart;
  final Duration duration;
  final int particleCount;
  final VoidCallback? onComplete;

  const CelebrationConfettiMotion({
    super.key,
    this.child,
    this.autoStart = true,
    this.duration = const Duration(milliseconds: 3200),
    this.particleCount = 45,
    this.onComplete,
  });

  @override
  State<CelebrationConfettiMotion> createState() => CelebrationConfettiMotionState();
}

class CelebrationConfettiMotionState extends State<CelebrationConfettiMotion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  static const List<Color> _confettiColors = [
    Color(0xFFFFD700), // Gold
    Color(0xFFFFA500), // Orange/Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF3B82F6), // Blue
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _controller.addListener(() {
      _updateParticles();
      if (mounted) setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.autoStart) {
      // Trigger after build layout
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) trigger();
      });
    }
  }

  void trigger() {
    _initParticles();
    _controller.forward(from: 0.0);
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      // Angle: shoot upwards with a pleasant fan spread (-45 to -135 degrees)
      final angle = -math.pi / 2 + (_random.nextDouble() - 0.5) * 1.5;
      final speed = 3.6 + _random.nextDouble() * 5.4;
      final isCoin = _random.nextDouble() < 0.78; // 78% are gold coins for full coin shower

      _particles.add(
        ConfettiParticle(
          x: 0.5 + (_random.nextDouble() - 0.5) * 0.12, // Start around center coin
          y: 0.22 + (_random.nextDouble() - 0.5) * 0.08,
          vx: math.cos(angle) * speed * 0.0028,
          vy: math.sin(angle) * speed * 0.0032,
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.20,
          size: isCoin
              ? 16.0 + _random.nextDouble() * 9.0
              : 8.0 + _random.nextDouble() * 6.0,
          color: isCoin
              ? const Color(0xFFFFD700)
              : _confettiColors[_random.nextInt(_confettiColors.length)],
          isCoin: isCoin,
        ),
      );
    }
  }

  void _updateParticles() {
    final t = _controller.value;
    // Real physical gravity so coins arc up and shower all the way down to bottom
    const gravity = 0.00045;

    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += gravity; // Continuous gravitational pull downwards
      p.vx *= 0.988; // Natural horizontal drag
      p.rotation += p.rotationSpeed;

      // Smooth fade out in the final 18% of duration as coins complete their fall
      if (t > 0.82) {
        p.opacity = ((1.0 - t) / 0.18).clamp(0.0, 1.0);
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (widget.child != null) widget.child!,
        if (_controller.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(particles: _particles),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final coinPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFFD97706);

    for (final p in particles) {
      if (p.opacity <= 0.0) continue;

      final posX = p.x * size.width;
      final posY = p.y * size.height;

      canvas.save();
      canvas.translate(posX, posY);
      canvas.rotate(p.rotation);

      if (p.isCoin) {
        // 3D Coin Tumbling Flip effect
        final flip = math.cos(p.rotation * 1.5).abs();
        canvas.scale(1.0, math.max(0.20, flip));

        // Draw 3D Shimmering Golden Coin
        coinPaint.color = p.color.withValues(alpha: p.opacity);
        final r = p.size / 2;

        // Outer coin base
        canvas.drawCircle(Offset.zero, r, coinPaint);
        // Border
        strokePaint.color = const Color(0xFFD97706).withValues(alpha: p.opacity);
        canvas.drawCircle(Offset.zero, r, strokePaint);

        // Center rupee symbol (rendered when coin face is facing viewer)
        if (flip > 0.35) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: '₹',
              style: TextStyle(
                color: const Color(0xFF92400E).withValues(alpha: p.opacity),
                fontSize: r * 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(-textPainter.width / 2, -textPainter.height / 2),
          );
        }
      } else {
        // Ribbon / Confetti rectangle
        coinPaint.color = p.color.withValues(alpha: p.opacity);
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.45,
        );
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), coinPaint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

