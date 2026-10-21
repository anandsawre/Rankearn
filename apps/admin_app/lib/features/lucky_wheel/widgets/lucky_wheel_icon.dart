import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pixel-perfect 8-spoke Lucky Wheel Icon matching the Rankearn reference design.
class LuckyWheelIcon extends StatelessWidget {
  final double size;
  final Color color;

  const LuckyWheelIcon({
    super.key,
    this.size = 16,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LuckyWheelPainter(color: color),
      ),
    );
  }
}

class _LuckyWheelPainter extends CustomPainter {
  final Color color;
  const _LuckyWheelPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = (size.width * 0.12).clamp(1.2, 2.4);

    // 1. Outer wheel rim
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, ringPaint);

    // 2. 8 radial spokes connecting center hub to outer rim
    final spokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.95
      ..strokeCap = StrokeCap.round;

    final innerRadius = radius * 0.28;
    final outerRadius = radius - strokeWidth;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final p1 = center + Offset(innerRadius * math.cos(angle), innerRadius * math.sin(angle));
      final p2 = center + Offset(outerRadius * math.cos(angle), outerRadius * math.sin(angle));
      canvas.drawLine(p1, p2, spokePaint);
    }

    // 3. Center hub
    final hubPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.25, hubPaint);
  }

  @override
  bool shouldRepaint(covariant _LuckyWheelPainter oldDelegate) => oldDelegate.color != color;
}
