import 'package:flutter/material.dart';

/// Pure Vector CustomPainter for Free Test Card illustration
/// (Full-card ambient waves + geometric watermark + tilted document sheet with checkmark)
/// NO raster image files used.
class FreeTestCardDecorationPainter extends CustomPainter {
  final bool isMobile;
  final double? customDocY;

  const FreeTestCardDecorationPainter({
    this.isMobile = false,
    this.customDocY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Ambient Left Corner Geometric Rings Watermark (Top-Left)
    final ringPaint = Paint()
      ..color = const Color(0xFF10B981).withAlpha(14)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(-12, -12), 70, ringPaint);

    final ringStrokePaint = Paint()
      ..color = const Color(0xFF10B981).withAlpha(25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(const Offset(-12, -12), 92, ringStrokePaint);

    // 2. Full-Card Sweeping Ambient Waves (flowing from left across the card)
    final wavePaint = Paint()
      ..color = const Color(0xFFD1FAE5).withAlpha(isMobile ? 55 : 70)
      ..style = PaintingStyle.fill;

    final wavePath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.25, size.height)
      ..cubicTo(
        size.width * 0.45,
        size.height * 0.95,
        size.width * 0.60,
        size.height * 0.35,
        size.width,
        size.height * 0.15,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(wavePath, wavePaint);

    final waveInnerPaint = Paint()
      ..color = const Color(0xFFA7F3D0).withAlpha(isMobile ? 35 : 45)
      ..style = PaintingStyle.fill;

    final waveInnerPath = Path()
      ..moveTo(size.width * 0.40, size.height)
      ..cubicTo(
        size.width * 0.60,
        size.height * 0.90,
        size.width * 0.72,
        size.height * 0.25,
        size.width,
        size.height * 0.40,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(waveInnerPath, waveInnerPaint);

    // 3. Subtle floating particles / accent dots
    final dotPaint1 = Paint()
      ..color = const Color(0xFF34D399).withAlpha(isMobile ? 100 : 140)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.28), 3.0, dotPaint1);

    final dotPaint2 = Paint()
      ..color = const Color(0xFF10B981).withAlpha(isMobile ? 80 : 120)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.78), 2.5, dotPaint2);

    // 4. Tilted Document Sheet (Right side)
    final docCenter = Offset(
      size.width - (isMobile ? 56 : 95),
      customDocY ?? (size.height * (isMobile ? 0.38 : 0.45)),
    );

    // Ambient radial glow behind the document
    final glowPaint = Paint()
      ..color = const Color(0xFF6EE7B7).withAlpha(isMobile ? 40 : 60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(docCenter, isMobile ? 38 : 50, glowPaint);

    canvas.save();
    canvas.translate(docCenter.dx, docCenter.dy);
    if (isMobile) {
      canvas.scale(0.68);
    }
    canvas.rotate(-0.18); // ~ -10.5 degrees

    final docRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 66, height: 86),
      const Radius.circular(11),
    );

    // Soft blur shadow
    final docShadowPaint = Paint()
      ..color = const Color(0x1800B67A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(docRect.shift(const Offset(0, 3)), docShadowPaint);

    // White document body
    final docPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(docRect, docPaint);

    // Subtle border
    final docBorderPaint = Paint()
      ..color = const Color(0xFFD1FAE5)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(docRect, docBorderPaint);

    // Text lines inside document
    final linePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(-20, -26), const Offset(20, -26), linePaint);
    canvas.drawLine(const Offset(-20, -15), const Offset(14, -15), linePaint);
    canvas.drawLine(const Offset(-20, -4), const Offset(8, -4), linePaint);
    canvas.drawLine(const Offset(-20, 7), const Offset(-2, 7), linePaint);

    // Circular green checkmark badge at bottom-right
    const badgeCenter = Offset(20, 26);
    final badgePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(badgeCenter, 13.5, badgePaint);

    // White checkmark
    final checkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final checkPath = Path()
      ..moveTo(badgeCenter.dx - 4.5, badgeCenter.dy - 0.5)
      ..lineTo(badgeCenter.dx - 1, badgeCenter.dy + 3.5)
      ..lineTo(badgeCenter.dx + 4.5, badgeCenter.dy - 3);
    canvas.drawPath(checkPath, checkPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FreeTestCardDecorationPainter oldDelegate) =>
      oldDelegate.isMobile != isMobile || oldDelegate.customDocY != customDocY;
}

/// Pure Vector CustomPainter for Paid/Coins Test Card illustration
/// (Full-card ambient waves + golden watermark + 3D isometric coin stack + front upright coin with ₹)
/// NO raster image files used.
class CoinsTestCardDecorationPainter extends CustomPainter {
  final bool isMobile;
  final double? customStackY;

  const CoinsTestCardDecorationPainter({
    this.isMobile = false,
    this.customStackY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Ambient Left Corner Geometric Rings Watermark (Top-Left)
    final ringPaint = Paint()
      ..color = const Color(0xFFF59E0B).withAlpha(14)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(-12, -12), 70, ringPaint);

    final ringStrokePaint = Paint()
      ..color = const Color(0xFFF59E0B).withAlpha(25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(const Offset(-12, -12), 92, ringStrokePaint);

    // 2. Full-Card Sweeping Ambient Waves (flowing from left across the card)
    final wavePaint = Paint()
      ..color = const Color(0xFFFEF3C7).withAlpha(isMobile ? 65 : 85)
      ..style = PaintingStyle.fill;

    final wavePath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.25, size.height)
      ..cubicTo(
        size.width * 0.45,
        size.height * 0.95,
        size.width * 0.60,
        size.height * 0.35,
        size.width,
        size.height * 0.15,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(wavePath, wavePaint);

    final waveInnerPaint = Paint()
      ..color = const Color(0xFFFDE68A).withAlpha(isMobile ? 35 : 50)
      ..style = PaintingStyle.fill;

    final waveInnerPath = Path()
      ..moveTo(size.width * 0.40, size.height)
      ..cubicTo(
        size.width * 0.60,
        size.height * 0.90,
        size.width * 0.72,
        size.height * 0.25,
        size.width,
        size.height * 0.40,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(waveInnerPath, waveInnerPaint);

    // 3. Subtle floating sparkle dots
    final dotPaint1 = Paint()
      ..color = const Color(0xFFF59E0B).withAlpha(isMobile ? 90 : 130)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.28), 3.0, dotPaint1);

    final dotPaint2 = Paint()
      ..color = const Color(0xFFFBBF24).withAlpha(isMobile ? 80 : 120)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.78), 2.5, dotPaint2);

    // 4. Isometric Coins Stack (Right side)
    final stackBase = Offset(
      size.width - (isMobile ? 58 : 95),
      customStackY ?? (size.height * (isMobile ? 0.58 : 0.64)),
    );

    // Ambient radial glow behind coins
    final glowPaint = Paint()
      ..color = const Color(0xFFFDE68A).withAlpha(isMobile ? 60 : 90)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(stackBase, isMobile ? 38 : 50, glowPaint);

    canvas.save();
    if (isMobile) {
      canvas.translate(stackBase.dx, stackBase.dy);
      canvas.scale(0.68);
      canvas.translate(-stackBase.dx, -stackBase.dy);
    }

    void drawFlatCoin(Offset center, double width, double height) {
      final rect = Rect.fromCenter(center: center, width: width, height: height);
      final edgeRect = Rect.fromCenter(center: center + const Offset(0, 4), width: width, height: height);

      final edgePaint = Paint()
        ..color = const Color(0xFFFBBF24)
        ..style = PaintingStyle.fill;
      canvas.drawOval(edgeRect, edgePaint);

      final topPaint = Paint()
        ..color = const Color(0xFFFEF08A)
        ..style = PaintingStyle.fill;
      canvas.drawOval(rect, topPaint);

      final rimPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawOval(rect, rimPaint);
    }

    drawFlatCoin(stackBase + const Offset(-16, 8), 40, 17);
    drawFlatCoin(stackBase + const Offset(-16, 0), 40, 17);
    drawFlatCoin(stackBase + const Offset(-16, -8), 40, 17);

    // 5. Upright Front Coin with ₹ symbol
    final frontCoinCenter = stackBase + const Offset(12, -8);
    const radius = 23.0;

    // Drop shadow
    final shadowPaint = Paint()
      ..color = const Color(0x22F59E0B)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(frontCoinCenter + const Offset(0, 4), radius, shadowPaint);

    // Outer coin disc with gradient
    final outerCoinPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFEF08A), Color(0xFFF59E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: frontCoinCenter, radius: radius));
    canvas.drawCircle(frontCoinCenter, radius, outerCoinPaint);

    // Inner rim
    final innerRimPaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(frontCoinCenter, radius - 4, innerRimPaint);

    // Rupee symbol
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '₹',
        style: TextStyle(
          color: Color(0xFFD97706),
          fontSize: 21,
          fontWeight: FontWeight.w900,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      frontCoinCenter - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CoinsTestCardDecorationPainter oldDelegate) =>
      oldDelegate.isMobile != isMobile || oldDelegate.customStackY != customStackY;
}

/// Pure Vector CustomPainter for Cards with Themed Ambient Waves & Accents (NO Coins/Sheets)
/// Matches the exact test list wave & ring geometry, colored dynamically:
/// - Red for Live Contests
/// - Blue for Upcoming / Mega Contests
class ThemedWaveCardDecorationPainter extends CustomPainter {
  final Color accentColor;
  final bool isMobile;

  const ThemedWaveCardDecorationPainter({
    required this.accentColor,
    this.isMobile = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Ambient Left Corner Geometric Rings Watermark (Top-Left)
    final ringPaint = Paint()
      ..color = accentColor.withAlpha(14)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(-12, -12), 70, ringPaint);

    final ringStrokePaint = Paint()
      ..color = accentColor.withAlpha(25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(const Offset(-12, -12), 92, ringStrokePaint);

    // 2. Full-Card Sweeping Ambient Waves (flowing from left across the card in theme color)
    final wavePaint = Paint()
      ..color = accentColor.withAlpha(isMobile ? 24 : 32)
      ..style = PaintingStyle.fill;

    final wavePath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.25, size.height)
      ..cubicTo(
        size.width * 0.45,
        size.height * 0.95,
        size.width * 0.60,
        size.height * 0.35,
        size.width,
        size.height * 0.15,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(wavePath, wavePaint);

    final waveInnerPaint = Paint()
      ..color = accentColor.withAlpha(isMobile ? 14 : 20)
      ..style = PaintingStyle.fill;

    final waveInnerPath = Path()
      ..moveTo(size.width * 0.40, size.height)
      ..cubicTo(
        size.width * 0.60,
        size.height * 0.90,
        size.width * 0.72,
        size.height * 0.25,
        size.width,
        size.height * 0.40,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(waveInnerPath, waveInnerPaint);

    // 3. Top-Right Concentric Geometric Rings
    final ring1 = Paint()
      ..color = accentColor.withAlpha(22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(size.width - 24, 30), 45, ring1);

    final ring2 = Paint()
      ..color = accentColor.withAlpha(14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(size.width - 24, 30), 75, ring2);

    // 4. Subtle floating sparkle dots
    final dotPaint1 = Paint()
      ..color = accentColor.withAlpha(isMobile ? 90 : 130)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.28), 3.0, dotPaint1);

    final dotPaint2 = Paint()
      ..color = accentColor.withAlpha(isMobile ? 80 : 120)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.78), 2.5, dotPaint2);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.58), 2.2, dotPaint2);
  }

  @override
  bool shouldRepaint(covariant ThemedWaveCardDecorationPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor || oldDelegate.isMobile != isMobile;
}

