import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/spin_reward_model.dart';

/// Pure Vector CustomPainter for Spin Result Dialog background decoration
/// (Ambient watermark rings on top-left + flowing waves on top-right + floating particle accents)
class _SpinDialogBackgroundPainter extends CustomPainter {
  final Color themeColor;

  const _SpinDialogBackgroundPainter({required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Top-Left Concentric Watermark Rings
    final ringPaint1 = Paint()
      ..color = themeColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(0, 0), 85, ringPaint1);

    final ringStrokePaint = Paint()
      ..color = themeColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(const Offset(0, 0), 110, ringStrokePaint);

    // 2. Top-Right Ambient Flowing Waves
    final wavePaint = Paint()
      ..color = themeColor.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    final wavePath = Path()
      ..moveTo(size.width * 0.40, 0)
      ..cubicTo(
        size.width * 0.62,
        size.height * 0.12,
        size.width * 0.76,
        size.height * 0.20,
        size.width,
        size.height * 0.13,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(wavePath, wavePaint);

    final waveInnerPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    final waveInnerPath = Path()
      ..moveTo(size.width * 0.60, 0)
      ..cubicTo(
        size.width * 0.76,
        size.height * 0.15,
        size.width * 0.86,
        size.height * 0.24,
        size.width,
        size.height * 0.20,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(waveInnerPath, waveInnerPaint);

    // 3. Subtle floating celebratory sparkle dots
    final dotPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.88, 38), 3.0, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.24, 48), 2.5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.10, 115), 2.0, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.92, 110), 2.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _SpinDialogBackgroundPainter oldDelegate) =>
      oldDelegate.themeColor != themeColor;
}

/// Ultra-Premium Celebratory Reward Modal Dialog
/// Completely aligned with Rankearn design system & dialog standards.
class SpinResultDialog extends StatelessWidget {
  final SpinRewardItem reward;
  final VoidCallback onClaim;

  const SpinResultDialog({
    super.key,
    required this.reward,
    required this.onClaim,
  });

  static Future<void> show({
    required BuildContext context,
    required SpinRewardItem reward,
    required VoidCallback onClaim,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SpinResultDialog(reward: reward, onClaim: onClaim),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCoins = reward.type == SpinRewardType.coins || reward.coins > 0;
    const themeColor = Color(0xFFF59E0B); // Amber / Gold theme

    return CelebrationConfettiMotion(
      particleCount: 50,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        elevation: 16,
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Stack(
            children: [
              // 1. Background Vector Decoration (Waves + Concentric Rings)
              Positioned.fill(
                child: CustomPaint(
                  painter: _SpinDialogBackgroundPainter(themeColor: themeColor),
                ),
              ),

              // 2. Main Dialog Content
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Floating 3D Coin / Trophy Motion Graphic
                    TrophyBounceMotion(
                      size: 88,
                      isCoin: isCoins,
                      icon: isCoins ? null : Icons.card_giftcard_rounded,
                      primaryColor: const Color(0xFFFFB800),
                      secondaryColor: const Color(0xFFEA580C),
                      badgeText: null, // Clean, no overlapping pill!
                    ),
                    const SizedBox(height: 12),

                    // Top Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars_rounded, size: 13, color: Color(0xFFD97706)),
                          SizedBox(width: 4),
                          Text(
                            'LUCKY REWARD UNLOCKED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFB45309),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Congratulations Headline
                    const Text(
                      'Congratulations! 🎉',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Inter',
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Dedicated Gleaming Reward Card (Zero-Overflow Guaranteed)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isCoins ? const Color(0xFFFFFBEB) : reward.cardTint,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isCoins
                              ? const Color(0xFFFDE68A)
                              : reward.accentColor.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08F59E0B),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: isCoins
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 3D Rupee Coin Icon
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '₹',
                                        style: TextStyle(
                                          color: Color(0xFF78350F),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${reward.coins} Coins',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFB45309),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF86EFAC),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          size: 12,
                                          color: Color(0xFF15803D),
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          'CREDITED',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF15803D),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Text(
                                '${reward.title} ${reward.subtitle}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: reward.accentColor,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),

                    // Clear, friendly description
                    Text(
                      isCoins
                          ? '${reward.coins} Bonus Coins have been added to your balance.\nUse them to enter live tournaments & practice tests!'
                          : reward.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                        height: 1.45,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 3D Elevated Golden Claim & Continue Button (Matching Large Coin)
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFF6A1), // Shimmering top rim highlight
                            Color(0xFFFFDF00), // Vibrant golden face
                            Color(0xFFF59E0B), // Rich amber mid-tone
                            Color(0xFFD97706), // Deep metallic gold
                          ],
                          stops: [0.0, 0.22, 0.68, 1.0],
                        ),
                        border: Border.all(
                          color: const Color(0xFFFFFBEB),
                          width: 1.5,
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onClaim();
                        },
                        child: const Text(
                          'Claim & Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Inter',
                            letterSpacing: 0.3,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Color(0xFF78350F),
                                offset: Offset(0, 1.8),
                                blurRadius: 3,
                              ),
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
      ),
    );
  }
}
