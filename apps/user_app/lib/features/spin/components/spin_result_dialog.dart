import 'package:flutter/material.dart';
import '../models/spin_reward_model.dart';
import 'reward_art.dart';

/// Celebratory reward result modal dialog matching Rankearn aesthetic.
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating Decorative Glow & Reward Icon
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    reward.cardTint,
                    reward.cardTint.withAlpha(80),
                    Colors.white,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: reward.accentColor.withAlpha(50),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: RewardArtWidget(rewardId: reward.id, size: 58),
              ),
            ),
            const SizedBox(height: 18),

            // Congratulations Headline
            const Text(
              'Congratulations! 🎉',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF10194F),
                fontFamily: 'Inter',
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),

            // Reward Title & Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: reward.cardTint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: reward.accentColor.withAlpha(90)),
              ),
              child: Text(
                isCoins
                    ? '+${reward.coins} Coins'
                    : '${reward.title} ${reward.subtitle}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: reward.accentColor,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              reward.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF586B9B),
                height: 1.45,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 22),

            // Claim / Continue CTA Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B96B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
