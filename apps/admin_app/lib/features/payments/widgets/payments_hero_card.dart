import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../payments_hero_data.dart';

/// Payments Management Hero Card
/// Recreating the exact gradient, typography, and 3D illustration from the reference image.
class PaymentsHeroCard extends StatelessWidget {
  const PaymentsHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFECEFFE),
            Color(0xFFE5E9FE),
            Color(0xFFDCE2FD),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8DFFB), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x063B4896),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            // Decorative background glowing circular accents
            Positioned(
              left: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(90),
                ),
              ),
            ),
            Positioned(
              right: 180,
              bottom: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF5636F5).withAlpha(15),
                ),
              ),
            ),

            // Content Row
            Row(
              children: [
                // Left Text Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, top: 18, bottom: 18, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Payments ',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF101A3A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Management',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF5636F5),
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF5636F5).withAlpha(40),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Subtitle 1
                        const Text(
                          'Track and manage all platform payments, transactions and revenue.',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),

                        // Subtitle 2
                        const Text(
                          'Monitor subscriptions, test series purchases, quiz fees and more.',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Illustration: 3D character with credit card, rupee coins, receipt
                Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 0),
                  child: Image.memory(
                    kPaymentsHeroIllustrationBytes,
                    height: 120,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomRight,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 140,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.credit_card_rounded,
                        color: Color(0xFF5636F5),
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
