import 'package:flutter/material.dart';

/// Crisp vector-rendered 3D Gold Coin with star / crown and radial gleam
class WalletGoldCoin extends StatelessWidget {
  final double size;
  final bool hasCrown;

  const WalletGoldCoin({super.key, this.size = 48.0, this.hasCrown = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer shadow glow
          Container(
            width: size * 0.95,
            height: size * 0.95,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB800).withAlpha(100),
                  blurRadius: size * 0.25,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          // Coin Outer Edge Ring
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFFE066), Color(0xFFD48806)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Coin Rim Border
          Container(
            width: size * 0.88,
            height: size * 0.88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF3A8), Color(0xFFFFB800)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(
                color: const Color(0xFFF59E0B).withAlpha(180),
                width: size * 0.04,
              ),
            ),
          ),
          // Inner Coin Surface
          Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-0.2, -0.3),
                radius: 0.8,
                colors: [
                  Color(0xFFFFFDEB),
                  Color(0xFFFFD633),
                  Color(0xFFD97706),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
            child: Center(
              child: Icon(
                hasCrown ? Icons.military_tech_rounded : Icons.star_rounded,
                color: Colors.white,
                size: size * 0.44,
                shadows: const [
                  Shadow(
                    color: Color(0xFFB45309),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Official Rankearn Currency Coin: Warm golden-amber outer circle, pure white inner disc, golden dollar sign
class RankearnCurrencyCoin extends StatelessWidget {
  final double size;

  const RankearnCurrencyCoin({super.key, this.size = 32.0});

  @override
  Widget build(BuildContext context) {
    final innerWhiteSize = size * 0.66;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFFAE15),
      ),
      child: Center(
        child: Container(
          width: innerWhiteSize,
          height: innerWhiteSize,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              '\$',
              style: TextStyle(
                fontSize: size * 0.44,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFAE15),
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 3D Leather Wallet Graphic with gold coin stack spilling out
class WalletIllustration extends StatelessWidget {
  final double width;
  final double height;

  const WalletIllustration({super.key, this.width = 140, this.height = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerRight,
        children: [
          // Ambient glow
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              width: height * 0.9,
              height: height * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00B96B).withAlpha(40),
              ),
            ),
          ),
          // Sparkle 1
          Positioned(
            top: 6,
            left: width * 0.1,
            child: const Icon(
              Icons.auto_awesome,
              color: Color(0xFFFFD633),
              size: 16,
            ),
          ),
          // Sparkle 2
          Positioned(
            bottom: 8,
            right: 0,
            child: const Icon(
              Icons.auto_awesome,
              color: Color(0xFFFFD633),
              size: 14,
            ),
          ),
          // Coin 1 in background
          Positioned(
            left: width * 0.05,
            bottom: 12,
            child: Transform.rotate(
              angle: -0.15,
              child: const RankearnCurrencyCoin(size: 34),
            ),
          ),
          // Coin 2
          Positioned(
            left: width * 0.22,
            bottom: 18,
            child: const RankearnCurrencyCoin(size: 36),
          ),
          // Coin 3 in Wallet Top
          Positioned(
            right: 32,
            top: 2,
            child: Transform.rotate(
              angle: 0.1,
              child: const RankearnCurrencyCoin(size: 42),
            ),
          ),
          // Rich Brown Leather Wallet body
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              width: width * 0.52,
              height: height * 0.68,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF92400E),
                    Color(0xFF78350F),
                    Color(0xFF451A03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFB45309), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Wallet flap stitch lines
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Container(
                      height: 1,
                      color: const Color(0xFFD97706).withAlpha(120),
                    ),
                  ),
                  // Golden Clasp / Button
                  Positioned(
                    right: 12,
                    top: (height * 0.68 - 20) / 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFE066), Color(0xFFD97706)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x44000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF78350F),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mobile Hero Banner Coin Stacks Illustration
class MobileCoinsIllustration extends StatelessWidget {
  final double size;

  const MobileCoinsIllustration({super.key, this.size = 90.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.3,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Ambient soft glow
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFB800).withAlpha(40),
            ),
          ),
          // Left background coin
          Positioned(
            left: 0,
            bottom: 6,
            child: Transform.rotate(
              angle: -0.25,
              child: RankearnCurrencyCoin(size: size * 0.58),
            ),
          ),
          // Right background coin
          Positioned(
            right: 2,
            bottom: 8,
            child: Transform.rotate(
              angle: 0.2,
              child: RankearnCurrencyCoin(size: size * 0.6),
            ),
          ),
          // Foreground Large Coin
          Positioned(
            left: size * 0.22,
            bottom: 2,
            child: RankearnCurrencyCoin(size: size * 0.85),
          ),
          // Sparkles
          Positioned(
            top: 0,
            right: size * 0.2,
            child: const Icon(
              Icons.auto_awesome,
              color: Color(0xFFFFC928),
              size: 16,
            ),
          ),
          Positioned(
            bottom: size * 0.1,
            left: size * 0.1,
            child: const Icon(
              Icons.auto_awesome,
              color: Color(0xFFFFC928),
              size: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Official NPCI UPI Icon Badge (Authentic National Payments Corporation of India Mark)
class UpiIconBadge extends StatelessWidget {
  final double size;

  const UpiIconBadge({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/upi_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const CustomPaint(
            painter: _OfficialUpiChevronPainter(),
          );
        },
      ),
    );
  }
}

/// Precise Vector Painter for the Official NPCI UPI Dual Chevrons
/// Green right/bottom chevron (#097939) and Saffron left/top chevron (#ED752E).
class _OfficialUpiChevronPainter extends CustomPainter {
  const _OfficialUpiChevronPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Green (Right/Bottom) Chevron - Official NPCI India Green (#097939)
    final greenPaint = Paint()
      ..color = const Color(0xFF097939)
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    // NPCI 64x64 SVG: M55.05 32.542L38.715 0l-18.15 64z
    final greenPath = Path()
      ..moveTo(w * (55.050 / 64.0), h * (32.542 / 64.0))
      ..lineTo(w * (38.715 / 64.0), 0.0)
      ..lineTo(w * ((38.715 - 18.15) / 64.0), h)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Saffron/Orange (Left/Top) Chevron - Official NPCI Deep Saffron (#ED752E)
    final orangePaint = Paint()
      ..color = const Color(0xFFED752E)
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    // NPCI 64x64 SVG: M43.433 32.542L27.1 0 8.95 64z
    final orangePath = Path()
      ..moveTo(w * (43.433 / 64.0), h * (32.542 / 64.0))
      ..lineTo(w * (27.100 / 64.0), 0.0)
      ..lineTo(w * (8.950 / 64.0), h)
      ..close();
    canvas.drawPath(orangePath, orangePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

