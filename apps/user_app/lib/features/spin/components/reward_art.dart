import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable high-definition vector illustration renderer for the 8 Spin & Win rewards.
/// Usable both as a standalone Flutter widget and as a direct Canvas drawing utility.
class RewardArtWidget extends StatelessWidget {
  final String rewardId;
  final double size;

  const RewardArtWidget({super.key, required this.rewardId, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RewardArtPainter(rewardId: rewardId),
    );
  }
}

class _RewardArtPainter extends CustomPainter {
  final String rewardId;

  const _RewardArtPainter({required this.rewardId});

  @override
  void paint(Canvas canvas, Size size) {
    RewardArtCanvas.draw(
      canvas: canvas,
      center: Offset(size.width / 2, size.height / 2),
      size: size.width,
      rewardId: rewardId,
    );
  }

  @override
  bool shouldRepaint(covariant _RewardArtPainter oldDelegate) =>
      oldDelegate.rewardId != rewardId;
}

/// Canvas drawing engine for crisp vector rendering on the Spin Wheel and cards.
class RewardArtCanvas {
  RewardArtCanvas._();

  static void draw({
    required Canvas canvas,
    required Offset center,
    required double size,
    required String rewardId,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    final s = size / 40.0; // Normalized to 40x40 coordinate space
    canvas.scale(s, s);

    if (rewardId.contains('10_coins') || rewardId == 'showcase_10') {
      _drawSingleStarCoin(canvas);
    } else if (rewardId.contains('50_coins') || rewardId == 'showcase_50') {
      _drawDoubleCoinStack(canvas);
    } else if (rewardId.contains('100_coins') || rewardId == 'showcase_100') {
      _drawTripleCoinStack(canvas);
    } else if (rewardId.contains('200_coins')) {
      _drawGoldCrown(canvas);
    } else if (rewardId == 'showcase_200') {
      _drawQuadCoinStack(canvas);
    } else if (rewardId.contains('500_coins') || rewardId == 'showcase_500') {
      _drawJackpotCoinStack(canvas);
    } else if (rewardId.contains('rank_booster') || rewardId.contains('rank')) {
      _drawGoldCrown(canvas);
    } else if (rewardId.contains('extra_attempt') ||
        rewardId.contains('attempt')) {
      _drawBlueStarTicket(canvas);
    } else if (rewardId.contains('surprise') || rewardId.contains('gift')) {
      _drawRedGiftBox(canvas);
    } else {
      _drawSingleStarCoin(canvas);
    }

    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // 1. Single Gold Star Coin (10 Coins)
  // ---------------------------------------------------------------------------
  static void _drawSingleStarCoin(Canvas canvas) {
    // Outer shadow
    final shadowPaint = Paint()
      ..color = const Color(0x30B45309)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(const Offset(0, 2), 16, shadowPaint);

    // Coin base gradient
    final coinRect = Rect.fromCircle(center: Offset.zero, radius: 16);
    final coinPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFE066), Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(coinRect);
    canvas.drawCircle(Offset.zero, 16, coinPaint);

    // Inner rim
    final rimPaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset.zero, 13, rimPaint);

    // Embossed center star
    _drawStar(canvas, Offset.zero, 7.5, const Color(0xFFFFFBEB));
  }

  // ---------------------------------------------------------------------------
  // 2. Double Coin Stack (50 Coins)
  // ---------------------------------------------------------------------------
  static void _drawDoubleCoinStack(Canvas canvas) {
    // Base coin 1 (lower left)
    _drawCylinderCoin(
      canvas,
      const Offset(-4, 5),
      13,
      const Color(0xFFD97706),
      const Color(0xFFFBBF24),
    );
    // Base coin 2 (upper right)
    _drawCylinderCoin(
      canvas,
      const Offset(3, -3),
      13.5,
      const Color(0xFFD97706),
      const Color(0xFFFCD34D),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Triple Coin Stack (100 Coins)
  // ---------------------------------------------------------------------------
  static void _drawTripleCoinStack(Canvas canvas) {
    // Bottom coin
    _drawCylinderCoin(
      canvas,
      const Offset(0, 6),
      13.5,
      const Color(0xFFB45309),
      const Color(0xFFF59E0B),
    );
    // Middle coin
    _drawCylinderCoin(
      canvas,
      const Offset(-5, 0),
      13.5,
      const Color(0xFFD97706),
      const Color(0xFFFBBF24),
    );
    // Top front coin
    _drawCylinderCoin(
      canvas,
      const Offset(4, -5),
      14,
      const Color(0xFFD97706),
      const Color(0xFFFDE047),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Quad Coin Stack (200 Coins)
  // ---------------------------------------------------------------------------
  static void _drawQuadCoinStack(Canvas canvas) {
    _drawCylinderCoin(
      canvas,
      const Offset(-5, 6),
      12.5,
      const Color(0xFFB45309),
      const Color(0xFFF59E0B),
    );
    _drawCylinderCoin(
      canvas,
      const Offset(5, 5),
      12.5,
      const Color(0xFFB45309),
      const Color(0xFFFBBF24),
    );
    _drawCylinderCoin(
      canvas,
      const Offset(-4, -2),
      13,
      const Color(0xFFD97706),
      const Color(0xFFFBBF24),
    );
    _drawCylinderCoin(
      canvas,
      const Offset(3, -6),
      13.5,
      const Color(0xFFD97706),
      const Color(0xFFFDE047),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Jackpot Mega Coin Stack (500 Coins)
  // ---------------------------------------------------------------------------
  static void _drawJackpotCoinStack(Canvas canvas) {
    // Glow behind
    final glow = Paint()
      ..color = const Color(0x40FBBF24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset.zero, 18, glow);

    _drawCylinderCoin(
      canvas,
      const Offset(-7, 7),
      12,
      const Color(0xFF92400E),
      const Color(0xFFF59E0B),
    );
    _drawCylinderCoin(
      canvas,
      const Offset(7, 7),
      12,
      const Color(0xFF92400E),
      const Color(0xFFF59E0B),
    );
    _drawCylinderCoin(
      canvas,
      const Offset(0, 2),
      13,
      const Color(0xFFB45309),
      const Color(0xFFFBBF24),
    );
    _drawCylinderCoin(
      canvas,
      const Offset(-5, -4),
      13,
      const Color(0xFFD97706),
      const Color(0xFFFCD34D),
    );
    _drawCylinderCoin(
      canvas,
      const Offset(4, -7),
      13.5,
      const Color(0xFFD97706),
      const Color(0xFFFEF08A),
    );

    // Tiny sparkle
    _drawSparkle(canvas, const Offset(-12, -10), 3, Colors.white);
    _drawSparkle(canvas, const Offset(13, -11), 3.5, const Color(0xFFFEF08A));
  }

  static void _drawCylinderCoin(
    Canvas canvas,
    Offset pos,
    double radius,
    Color edgeColor,
    Color topColor,
  ) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    // Thickness / edge rim
    final edgePaint = Paint()..color = edgeColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: const Offset(0, 2.5),
          width: radius * 2,
          height: radius * 1.5,
        ),
        Radius.circular(radius * 0.8),
      ),
      edgePaint,
    );

    // Top face
    final topPaint = Paint()
      ..shader = LinearGradient(
        colors: [topColor, Color.lerp(topColor, edgeColor, 0.4)!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 2,
        height: radius * 1.5,
      ),
      topPaint,
    );

    // Top inner groove
    final groovePaint = Paint()
      ..color = Colors.white.withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: (radius - 2.5) * 2,
        height: (radius - 2) * 1.5,
      ),
      groovePaint,
    );

    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // 6. Gold 3D Crown (Rank Booster)
  // ---------------------------------------------------------------------------
  static void _drawGoldCrown(Canvas canvas) {
    final crownPath = Path()
      ..moveTo(-16, 10)
      ..lineTo(-15, -6)
      ..lineTo(-7, 2)
      ..lineTo(0, -12)
      ..lineTo(7, 2)
      ..lineTo(15, -6)
      ..lineTo(16, 10)
      ..close();

    // Crown shadow
    final shadowPaint = Paint()
      ..color = const Color(0x35B45309)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(crownPath.shift(const Offset(0, 2)), shadowPaint);

    // Crown gradient
    final crownPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFDE047), Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-16, -12, 32, 24));
    canvas.drawPath(crownPath, crownPaint);

    // Crown base band
    final bandPaint = Paint()..color = const Color(0xFFB45309);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-16, 6, 32, 5),
        const Radius.circular(2.5),
      ),
      bandPaint,
    );

    // Jewels on crown peaks
    final jewelPaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(-15, -6), 2.2, jewelPaint);
    canvas.drawCircle(const Offset(0, -12), 2.8, jewelPaint);
    canvas.drawCircle(const Offset(15, -6), 2.2, jewelPaint);

    // Center ruby jewel
    final rubyPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(const Offset(0, 8.5), 1.8, rubyPaint);
  }

  // ---------------------------------------------------------------------------
  // 7. Blue Star Ticket (Extra Attempt)
  // ---------------------------------------------------------------------------
  static void _drawBlueStarTicket(Canvas canvas) {
    canvas.save();
    canvas.rotate(-0.15); // Dynamic tilted badge angle

    // Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x300284C7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-17, -10, 34, 22),
        const Radius.circular(4),
      ),
      shadowPaint,
    );

    // Ticket body gradient
    final ticketPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF0284C7), Color(0xFF0369A1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(-17, -11, 34, 22));

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-17, -11, 34, 22),
          const Radius.circular(4),
        ),
      );

    canvas.drawPath(path, ticketPaint);

    // Cutout circles on sides
    final cutoutPaint = Paint()
      ..color = const Color(0x30000000)
      ..blendMode = BlendMode.dstOut;
    canvas.drawCircle(const Offset(-17, 0), 3.5, cutoutPaint);
    canvas.drawCircle(const Offset(17, 0), 3.5, cutoutPaint);

    // Perforated line
    final linePaint = Paint()
      ..color = Colors.white.withAlpha(160)
      ..strokeWidth = 1.0;
    for (double y = -8; y <= 8; y += 4) {
      canvas.drawLine(Offset(-6, y), Offset(-6, y + 2), linePaint);
    }

    // Embossed center star
    _drawStar(canvas, const Offset(4, 0), 5.5, Colors.white);

    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // 8. Red Gift Box with Yellow Ribbon (Surprise Gift)
  // ---------------------------------------------------------------------------
  static void _drawRedGiftBox(Canvas canvas) {
    // Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x30E11D48)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-14, -6, 28, 22),
        const Radius.circular(4),
      ),
      shadowPaint,
    );

    // Box body gradient
    final boxPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF2A6D), Color(0xFFE11D48), Color(0xFFBE123C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(-14, -6, 28, 22));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-13, -3, 26, 18),
        const Radius.circular(3.5),
      ),
      boxPaint,
    );

    // Box lid
    final lidPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF4D88), Color(0xFFF43F5E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(-15, -9, 30, 7));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-15, -9, 30, 7),
        const Radius.circular(2.5),
      ),
      lidPaint,
    );

    // Yellow ribbon vertical stripe
    final ribbonPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFEF08A), Color(0xFFFACC15), Color(0xFFEAB308)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-3.5, -9, 7, 24));
    canvas.drawRect(const Rect.fromLTWH(-3.5, -9, 7, 24), ribbonPaint);

    // Ribbon bow at top
    final bowPaint = Paint()..color = const Color(0xFFFDE047);
    canvas.drawOval(const Rect.fromLTWH(-7, -14, 6.5, 6), bowPaint);
    canvas.drawOval(const Rect.fromLTWH(0.5, -14, 6.5, 6), bowPaint);
    canvas.drawCircle(
      const Offset(0, -9),
      2.5,
      Paint()..color = const Color(0xFFEAB308),
    );
  }

  // Helper: 5-point star
  static void _drawStar(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final path = Path();
    final double innerRadius = radius * 0.42;

    for (int i = 0; i < 10; i++) {
      final double r = (i % 2 == 0) ? radius : innerRadius;
      final double angle = (i * math.pi / 5) - (math.pi / 2);
      final double x = center.dx + r * math.cos(angle);
      final double y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  // Helper: 4-point sparkle
  static void _drawSparkle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }
}
