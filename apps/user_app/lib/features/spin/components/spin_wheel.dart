import 'package:flutter/material.dart';
import '../models/spin_reward_model.dart';
import 'wheel_painter.dart';

/// Interactive Main Spin Wheel matching the Rankearn reference design.
/// - Houses the animated Canvas wheel
/// - Top golden fixed pointer arrow pointing down
/// - Central Gold SPIN Button with "1 Free Spin" subtitle
class SpinWheel extends StatelessWidget {
  final List<SpinRewardItem> rewards;
  final AnimationController controller;
  final Animation<double>? animation;
  final double currentAngle;
  final bool isSpinning;
  final int spinsRemaining;
  final VoidCallback? onSpin;
  final double size;

  const SpinWheel({
    super.key,
    required this.rewards,
    required this.controller,
    this.animation,
    required this.currentAngle,
    required this.isSpinning,
    required this.spinsRemaining,
    required this.onSpin,
    this.size = 340,
  });

  @override
  Widget build(BuildContext context) {
    final wheelSize = size;
    final hubSize = wheelSize * 0.28;

    return Center(
      child: SizedBox(
        width: wheelSize,
        height: wheelSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. Static Outer Rim Frame (Cached once via RepaintBoundary)
            RepaintBoundary(
              child: CustomPaint(
                size: Size(wheelSize, wheelSize),
                painter: const WheelRimPainter(),
              ),
            ),

            // 2. GPU Hardware-Accelerated Rotational Slices (Rotated directly by GPU matrix)
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final double angle;
                if (controller.isAnimating) {
                  if (animation != null) {
                    angle = animation!.value;
                  } else {
                    angle = currentAngle + (controller.value * 2 * 3.141592653589793);
                  }
                } else {
                  angle = currentAngle;
                }
                return Transform.rotate(
                  angle: angle,
                  child: child,
                );
              },
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size(wheelSize, wheelSize),
                  painter: WheelSlicesPainter(rewards: rewards),
                ),
              ),
            ),

            // 2. Center Gold Interactive Hub ("SPIN / 1 Free Spin")
            _buildCenterHub(hubSize),

            // 3. Fixed Top Golden Pointer
            _buildTopPointer(wheelSize),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Central Gold Hub / Button
  // ---------------------------------------------------------------------------
  Widget _buildCenterHub(double hubSize) {
    final canTap = !isSpinning && spinsRemaining > 0 && onSpin != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canTap ? onSpin : null,
        borderRadius: BorderRadius.circular(hubSize / 2),
        child: Container(
          width: hubSize,
          height: hubSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFFFFFBEB), Color(0xFFFFD32A), Color(0xFFF59E0B)],
              stops: [0.0, 0.65, 1.0],
            ),
            border: Border.all(color: Colors.white, width: 3.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x35000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD97706), width: 1.2),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isSpinning ? '...' : 'SPIN',
                  style: const TextStyle(
                    color: Color(0xFF006B3D),
                    fontWeight: FontWeight.w900,
                    fontSize: 16.5,
                    letterSpacing: 0.5,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  spinsRemaining > 0 ? '$spinsRemaining Free Spin' : 'Cooldown',
                  style: const TextStyle(
                    color: Color(0xFF10194F),
                    fontWeight: FontWeight.w700,
                    fontSize: 9.5,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Inverted Golden Pointer Arrow (12 o'clock)
  // ---------------------------------------------------------------------------
  Widget _buildTopPointer(double wheelSize) {
    const pointerWidth = 34.0;
    const pointerHeight = 36.0;

    return Positioned(
      top: 6,
      child: CustomPaint(
        size: const Size(pointerWidth, pointerHeight),
        painter: _PointerPainter(),
      ),
    );
  }
}

/// Custom painter for the top golden triangle pointer with drop shadow & trim
class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.1, 0)
      ..lineTo(w * 0.9, 0)
      ..lineTo(w * 0.5, h)
      ..close();

    // Drop shadow
    final shadowPaint = Paint()
      ..color = const Color(0x35000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);

    // Golden gradient body
    final pointerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFEA79), Color(0xFFFFD32A), Color(0xFFF59E0B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, pointerPaint);

    // Green/gold accent border
    final borderPaint = Paint()
      ..color = const Color(0xFF007542)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
