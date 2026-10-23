import 'package:flutter/material.dart';

/// Crisp multi-color Google 'G' icon rendered with vector CustomPainter
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 20.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final paintBlue = Paint()..color = const Color(0xFF4285F4);
    final paintRed = Paint()..color = const Color(0xFFEA4335);
    final paintYellow = Paint()..color = const Color(0xFFFBBC05);
    final paintGreen = Paint()..color = const Color(0xFF34A853);

    final rect = Rect.fromCircle(center: center, radius: radius * 0.9);
    final strokeWidth = size.width * 0.18;

    // Red arc (Top)
    final redPaint = Paint()
      ..color = paintRed.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, -2.6, 2.0, false, redPaint);

    // Yellow arc (Left)
    final yellowPaint = Paint()
      ..color = paintYellow.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, -0.6, 1.3, false, yellowPaint);

    // Green arc (Bottom)
    final greenPaint = Paint()
      ..color = paintGreen.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0.7, 1.8, false, greenPaint);

    // Blue arc (Right) + Horizontal crossbar
    final bluePaint = Paint()
      ..color = paintBlue.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 2.5, 0.9, false, bluePaint);

    // Crossbar
    final barPaint = Paint()
      ..color = paintBlue.color
      ..style = PaintingStyle.fill;
    final barHeight = strokeWidth;
    final barWidth = radius * 0.9;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx, center.dy - barHeight / 2, barWidth, barHeight),
        Radius.circular(barHeight / 4),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
