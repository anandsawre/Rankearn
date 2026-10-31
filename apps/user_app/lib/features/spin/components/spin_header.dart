import 'package:flutter/material.dart';

/// Top App Bar matching the green header in the Spin & Win reference image.
/// - Left: Back arrow icon (<)
/// - Center: Red gift box icon (🎁) + "Spin & Win" (with "Win" highlighted in yellow)
/// - Right: Current coin balance chip with gold coin icon + add-coins (+) button
class SpinHeader extends StatelessWidget {
  final int coinBalance;
  final VoidCallback onBack;
  final VoidCallback? onOpenWallet;

  const SpinHeader({
    super.key,
    required this.coinBalance,
    required this.onBack,
    this.onOpenWallet,
  });

  String _formatCoins(int amount) {
    if (amount >= 1000) {
      final s = amount.toString();
      final lastThree = s.substring(s.length - 3);
      final otherNumbers = s.substring(0, s.length - 3);
      return otherNumbers.isNotEmpty ? '$otherNumbers,$lastThree' : lastThree;
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00B96B), Color(0xFF008C52)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x20008C52),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Left side: Back Button + 🎁 + "Spin & Win" (clustered left)
              Expanded(
                child: Row(
                  children: [
                    InkWell(
                      onTap: onBack,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('🎁', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Inter',
                            letterSpacing: -0.3,
                          ),
                          children: [
                            TextSpan(
                              text: 'Spin & ',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'Win',
                              style: TextStyle(color: Color(0xFFFFD32A)),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right side: Coin Balance Chip + Add (+) Button
              InkWell(
                onTap: onOpenWallet,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006B3D).withAlpha(160),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Gold Coin Icon
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFEA79), Color(0xFFFFB800)],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFF78350F),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Balance Text
                      Text(
                        _formatCoins(coinBalance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Green Plus (+) Circle
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00C875),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
