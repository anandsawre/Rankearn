import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/spin_reward_model.dart';
import 'reward_art.dart';

/// CustomPainter rendering the large circular green-and-gold Spin Wheel
/// strictly matching the Rankearn reference design:
/// - Thick emerald outer rim with 12 glowing circular white lights
/// - Inner gold/cream ring border
/// - 8 alternating cream (#FFFBEB) and emerald green (#00C26F) segments
/// - High-definition vector reward icons and typography along each radial axis
class WheelPainter extends CustomPainter {
  final List<SpinRewardItem> rewards;
  final double currentAngle;

  const WheelPainter({required this.rewards, required this.currentAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    const rimWidth = 24.0;
    final wheelRadius = outerRadius - rimWidth;

    // 1. Outer Wheel Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x35000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(
      center + const Offset(0, 6),
      outerRadius - 2,
      shadowPaint,
    );

    // 2. Thick Emerald Outer Rim
    final rimRect = Rect.fromCircle(center: center, radius: outerRadius);
    final rimPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00C26F), Color(0xFF009655), Color(0xFF007542)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rimRect);
    canvas.drawCircle(center, outerRadius - 2, rimPaint);

    // Outer and Inner Gold Trim Lines on Rim
    final goldTrim = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, outerRadius - 3, goldTrim);
    canvas.drawCircle(center, wheelRadius, goldTrim);

    // 3. 12 Glowing Circular White Lights around Rim
    _drawRimLights(canvas, center, outerRadius - (rimWidth / 2));

    // 4. Draw Segments (Rotated by currentAngle)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(currentAngle);

    final totalSectors = rewards.length;
    final sectorAngle = (2 * math.pi) / totalSectors;
    final arcRect = Rect.fromCircle(center: Offset.zero, radius: wheelRadius);

    // 4.1 First pass: Draw all 8 alternating Sector Wedges
    for (int i = 0; i < totalSectors; i++) {
      final startAngle = (i * sectorAngle) - (math.pi / 2) - (sectorAngle / 2);
      final isEven = (i % 2 == 0);

      final segmentPaint = Paint()..style = PaintingStyle.fill;
      if (isEven) {
        segmentPaint.color = const Color(0xFFFFFDEB); // Warm soft cream
      } else {
        segmentPaint.color = const Color(
          0xFF00B96B,
        ); // Clean vibrant emerald green
      }

      canvas.drawArc(arcRect, startAngle, sectorAngle, true, segmentPaint);
    }

    // 4.2 Second pass: Draw crisp White Sector Dividers
    final dividerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8;
    for (int i = 0; i < totalSectors; i++) {
      final startAngle = (i * sectorAngle) - (math.pi / 2) - (sectorAngle / 2);
      final edgeX = wheelRadius * math.cos(startAngle);
      final edgeY = wheelRadius * math.sin(startAngle);
      canvas.drawLine(Offset.zero, Offset(edgeX, edgeY), dividerPaint);
    }

    // 4.3 Third pass: Draw Content (Icon + Title + Subtitle) for each Sector
    // Content is drawn completely UPRIGHT in the wheel's coordinate space, matching reference design!
    final contentRadius = wheelRadius * 0.58;
    final iconSize = wheelRadius * 0.20;

    for (int i = 0; i < totalSectors; i++) {
      final reward = rewards[i];
      final isEven = (i % 2 == 0);
      final bisectorAngle = (i * sectorAngle) - (math.pi / 2);

      // Center position of sector i
      final cx = contentRadius * math.cos(bisectorAngle);
      final cy = contentRadius * math.sin(bisectorAngle);

      final iconCenter = Offset(cx, cy - (wheelRadius * 0.10));
      final titleCenter = Offset(cx, cy + (wheelRadius * 0.045));
      final subCenter = Offset(cx, cy + (wheelRadius * 0.13));

      // 1. Draw Reward Vector Illustration (Upright)
      RewardArtCanvas.draw(
        canvas: canvas,
        center: iconCenter,
        size: iconSize,
        rewardId: reward.id,
      );

      // 2. Draw Title (e.g. "100", "50", "Rank", "Surprise", "10", "500", "200", "Extra")
      final textColor = isEven ? const Color(0xFF10194F) : Colors.white;

      final titleSpan = TextSpan(
        text: reward.title,
        style: TextStyle(
          color: textColor,
          fontSize: wheelRadius * 0.088,
          fontWeight: FontWeight.w900,
          fontFamily: 'Inter',
          letterSpacing: -0.2,
        ),
      );
      final titlePainter = TextPainter(
        text: titleSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      titlePainter.paint(
        canvas,
        Offset(
          titleCenter.dx - (titlePainter.width / 2),
          titleCenter.dy - (titlePainter.height / 2),
        ),
      );

      // 3. Draw Subtitle (e.g. "Coins", "Booster", "Gift", "Attempt")
      final subSpan = TextSpan(
        text: reward.subtitle,
        style: TextStyle(
          color: textColor.withAlpha(isEven ? 230 : 255),
          fontSize: wheelRadius * 0.068,
          fontWeight: FontWeight.w800,
          fontFamily: 'Inter',
          letterSpacing: -0.1,
        ),
      );
      final subPainter = TextPainter(
        text: subSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      subPainter.paint(
        canvas,
        Offset(
          subCenter.dx - (subPainter.width / 2),
          subCenter.dy - (subPainter.height / 2),
        ),
      );
    }

    canvas.restore(); // Restore angle rotation
  }

  /// 12 Decorative Circular White Lights along the emerald rim
  void _drawRimLights(Canvas canvas, Offset center, double lightRadius) {
    const lightCount = 12;
    const lightStep = (2 * math.pi) / lightCount;

    for (int i = 0; i < lightCount; i++) {
      final angle = i * lightStep - (math.pi / 2);
      final x = center.dx + lightRadius * math.cos(angle);
      final y = center.dy + lightRadius * math.sin(angle);
      final lightOffset = Offset(x, y);

      // Ambient glow
      final glowPaint = Paint()
        ..color = Colors.white.withAlpha(90)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawCircle(lightOffset, 4.5, glowPaint);

      // Core light bulb
      final bulbPaint = Paint()..color = Colors.white;
      canvas.drawCircle(lightOffset, 3.2, bulbPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) =>
      oldDelegate.currentAngle != currentAngle ||
      oldDelegate.rewards != rewards;
}
