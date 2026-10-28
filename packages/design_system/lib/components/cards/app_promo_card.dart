import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../tokens/radii.dart';

/// Standardized, reusable Compact Action / Promotional Card component across Rankearn.
/// Used for dual-banner rows, feature highlights, and actionable promos (e.g., Test Series,
/// Create a Live Test, Daily Challenge, Fortune Wheel).
class AppPromoCard extends StatelessWidget {
  /// Main title string.
  final String title;

  /// Custom title widget (if provided, overrides [title]).
  final Widget? titleWidget;

  /// Subtitle or short descriptive text.
  final String subtitle;

  /// Primary action button label (e.g., "View Series", "Create Now", "Play Now").
  final String ctaLabel;

  /// Primary action callback.
  final VoidCallback? onCtaPressed;

  /// Optional leading graphic or icon (e.g., circular badge with icon).
  final Widget? leading;

  /// Optional badge rendered next to the title (e.g., LIVE pill, Timer badge).
  final Widget? badge;

  /// Background gradient of the promotional card.
  final Gradient gradient;

  /// Optional border color.
  final Color? borderColor;

  /// Card box shadows.
  final List<BoxShadow>? boxShadow;

  /// CTA button background color. Defaults to Gold (#FFD633).
  final Color ctaColor;

  /// CTA button text and icon color. Defaults to Navy (#101A3A).
  final Color ctaTextColor;

  /// CTA trailing icon. Defaults to null (no arrow icon).
  final IconData? ctaIcon;

  /// Card corner radius. Defaults to 18.
  final double borderRadius;

  /// Internal padding.
  final EdgeInsetsGeometry padding;

  /// Optional background watermark icon.
  final IconData? watermarkIcon;

  /// Whether to render decorative background shapes (halo, rings, dot-grid).
  final bool showBackgroundDecorations;

  const AppPromoCard({
    super.key,
    required this.title,
    this.titleWidget,
    required this.subtitle,
    required this.ctaLabel,
    this.onCtaPressed,
    this.leading,
    this.badge,
    required this.gradient,
    this.borderColor,
    this.boxShadow,
    this.ctaColor = const Color(0xFFFFD633),
    this.ctaTextColor = const Color(0xFF101A3A),
    this.ctaIcon,
    this.borderRadius = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    this.watermarkIcon,
    this.showBackgroundDecorations = true,
  });

  /// Factory preset for Live Test Series banner
  factory AppPromoCard.liveTestSeries({VoidCallback? onViewSeries}) {
    return AppPromoCard(
      title: 'Live Test Series',
      watermarkIcon: Icons.emoji_events_rounded,
      badge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF43F5E),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 10),
            SizedBox(width: 2),
            Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      subtitle: 'Daily live tests with rewards and certificates.',
      ctaLabel: 'View Series',
      onCtaPressed: onViewSeries,
      gradient: const LinearGradient(
        colors: [
          Color(0xFF3B0764), // Deep royal purple
          Color(0xFF6B21A8), // Rich magenta purple
          Color(0xFF9333EA), // Bright purple
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x256B21A8),
          blurRadius: 14,
          offset: Offset(0, 4),
        ),
      ],
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        child: const Center(
          child: Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFFFFD633),
            size: 30,
          ),
        ),
      ),
    );
  }

  /// Factory preset for Create a Live Test banner
  factory AppPromoCard.createLiveTest({VoidCallback? onCreateLiveTest}) {
    return AppPromoCard(
      title: 'Create a Live Test',
      watermarkIcon: Icons.group_add_rounded,
      subtitle: 'Host tests, invite friends, compete together.',
      ctaLabel: 'Create Now',
      onCtaPressed: onCreateLiveTest,
      gradient: const LinearGradient(
        colors: [
          Color(0xFF1E1B4B), // Deep indigo
          Color(0xFF3730A3), // Rich indigo
          Color(0xFF4F46E5), // Electric indigo
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x254F46E5),
          blurRadius: 14,
          offset: Offset(0, 4),
        ),
      ],
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        child: const Center(
          child: Icon(
            Icons.add_circle_outline_rounded,
            color: Color(0xFF38BDF8),
            size: 30,
          ),
        ),
      ),
    );
  }

  /// Factory preset for Daily Challenge banner
  factory AppPromoCard.dailyChallenge({
    required VoidCallback onPlay,
    String duration = '5 min',
    String subtitle = '10 questions • Earn 50 coins',
  }) {
    return AppPromoCard(
      title: 'Daily Challenge',
      watermarkIcon: Icons.assignment_rounded,
      subtitle: subtitle,
      ctaLabel: 'Play Now',
      onCtaPressed: onPlay,
      gradient: const LinearGradient(
        colors: [Color(0xFF312E81), Color(0xFF4338CA), Color(0xFF6366F1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      badge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: AppRadii.borderPill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_outlined, color: Colors.white, size: 12),
            const SizedBox(width: 4),
            Text(
              duration,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        child: const Center(
          child: Icon(
            Icons.assignment_rounded,
            color: Color(0xFFFFD633),
            size: 26,
          ),
        ),
      ),
    );
  }

  /// Factory preset for Fortune Wheel banner
  factory AppPromoCard.fortuneWheel({
    required VoidCallback onSpin,
    String badgeText = 'Free Spin',
    String subtitle = 'Spin daily & win up to 500 coins',
  }) {
    return AppPromoCard(
      title: 'Fortune Wheel',
      watermarkIcon: null,
      subtitle: subtitle,
      ctaLabel: 'Spin Now',
      onCtaPressed: onSpin,
      gradient: const LinearGradient(
        colors: [Color(0xFF831843), Color(0xFF9D174D), Color(0xFFDB2777)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      badge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: AppRadii.borderPill,
        ),
        child: Text(
          badgeText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        child: const Center(
          child: FortuneWheelVectorIcon(size: 36),
        ),
      ),
    );
  }

  /// Convenience helper to render two action promo cards in a responsive layout.
  /// Renders side-by-side (Row) on desktop/tablet (>= breakpoint), and stacked (Column) on mobile.
  static Widget responsivePair({
    required Widget first,
    required Widget second,
    double breakpoint = 720,
    double spacing = 14,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return Row(
            children: [
              Expanded(child: first),
              SizedBox(width: spacing),
              Expanded(child: second),
            ],
          );
        }
        return Column(
          children: [
            first,
            SizedBox(height: spacing - 2),
            second,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.1)
            : Border.all(color: Colors.white.withAlpha(30), width: 1),
        boxShadow: boxShadow ??
            const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // --- Background Decorative Designs (Themed to Card Gradient) ---
            if (showBackgroundDecorations) ...[
              // 1. Top-Right Soft Glowing Halo
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(15),
                  ),
                ),
              ),

              // 2. Concentric Geometric Rings
              Positioned(
                top: -45,
                right: -45,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(18),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -65,
                right: -65,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(12),
                      width: 1.0,
                    ),
                  ),
                ),
              ),

              // 3. Modern Tech Dot-Matrix Pattern in Background
              Positioned(
                right: 85,
                top: 10,
                child: IgnorePointer(
                  child: CustomPaint(
                    size: const Size(55, 35),
                    painter: _PromoDotGridPainter(),
                  ),
                ),
              ),

              // 4. Large Faint Watermark Icon near CTA / right side
              if (watermarkIcon != null)
                Positioned(
                  right: 32,
                  bottom: -12,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: -0.15,
                      child: Icon(
                        watermarkIcon,
                        size: 76,
                        color: Colors.white.withAlpha(20),
                      ),
                    ),
                  ),
                ),

              // 5. Top Glass Sheen / Highlight
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 1.2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withAlpha(90),
                        Colors.white.withAlpha(30),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // --- Foreground Content ---
            Padding(
              padding: padding,
              child: Row(
                children: [
                  // 1. Leading Graphic
                  if (leading != null) ...[leading!, const SizedBox(width: 12)],

                  // 2. Title & Subtitle Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title Row with optional Badge
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (titleWidget != null)
                                titleWidget!
                              else
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              if (badge != null) ...[const SizedBox(width: 6), badge!],
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),

                        // Subtitle
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 3. CTA Action Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onCtaPressed,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: ctaColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: ctaColor.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ctaLabel,
                              style: TextStyle(
                                color: ctaTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (ctaIcon != null) ...[
                              const SizedBox(width: 4),
                              Icon(ctaIcon, color: ctaTextColor, size: 13),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter for rendering subtle dot matrix grid on promotional cards
class _PromoDotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 9.0;
    const dotRadius = 1.1;
    const cols = 5;
    const rows = 3;
    final dotPaint = Paint()
      ..color = Colors.white.withAlpha(25)
      ..style = PaintingStyle.fill;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(c * spacing, r * spacing),
          dotRadius,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Clean, high-definition vector illustration of a spinning prize Fortune Wheel
class FortuneWheelVectorIcon extends StatelessWidget {
  final double size;
  const FortuneWheelVectorIcon({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FortuneWheelVectorPainter(),
      ),
    );
  }
}

class _FortuneWheelVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final wheelRadius = radius - 1.5;

    // 1. Subtle drop shadow under wheel
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(center + const Offset(0, 1), wheelRadius, shadowPaint);

    // 2. 8 Distinct colorful wheel sectors
    const sectorCount = 8;
    const sweep = (2 * math.pi) / sectorCount;
    const colors = [
      Color(0xFFFFD633), // Gold
      Color(0xFFF43F5E), // Coral Red
      Color(0xFF38BDF8), // Sky Blue
      Color(0xFF10B981), // Emerald
      Color(0xFFA855F7), // Purple
      Color(0xFFFF9F0A), // Orange
      Color(0xFF06B6D4), // Cyan
      Color(0xFFEC4899), // Pink
    ];

    final sectorPaint = Paint()..style = PaintingStyle.fill;
    final spokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCircle(center: center, radius: wheelRadius);

    for (int i = 0; i < sectorCount; i++) {
      sectorPaint.color = colors[i % colors.length];
      final startAngle = (i * sweep) - (math.pi / 2);
      canvas.drawArc(rect, startAngle, sweep, true, sectorPaint);

      // Radial spoke line
      final x = center.dx + wheelRadius * math.cos(startAngle);
      final y = center.dy + wheelRadius * math.sin(startAngle);
      canvas.drawLine(center, Offset(x, y), spokePaint);
    }

    // 3. Outer golden ring border
    final borderPaint = Paint()
      ..color = const Color(0xFFFFE066)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(center, wheelRadius, borderPaint);

    // 4. Center Gold & White Hub
    final hubBorderPaint = Paint()
      ..color = const Color(0xFFFFD633)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.28, hubBorderPaint);

    final hubCenterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.16, hubCenterPaint);

    // 5. Top indicator stopper / ticker (triangle pointer at 12 o'clock)
    final pointerWidth = radius * 0.28;
    final pointerPath = Path()
      ..moveTo(center.dx, radius * 0.36) // pointy tip pointing downward towards center
      ..lineTo(center.dx - pointerWidth / 2, 0)
      ..lineTo(center.dx + pointerWidth / 2, 0)
      ..close();

    final pointerShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    canvas.drawPath(pointerPath, pointerShadow);

    final pointerPaint = Paint()
      ..color = const Color(0xFFFFD633)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pointerPath, pointerPaint);

    final pointerBorderPaint = Paint()
      ..color = const Color(0xFFB45309)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawPath(pointerPath, pointerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
