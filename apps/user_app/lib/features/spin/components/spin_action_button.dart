import 'package:flutter/material.dart';

/// Large green gradient action button matching the Spin Now button in the reference:
/// - Play icon (▶)
/// - "Spin Now" label
/// - Yellow badge showing remaining free spins (e.g. "1 Free Spin")
class SpinActionButton extends StatelessWidget {
  final bool isSpinning;
  final int spinsRemaining;
  final VoidCallback? onSpin;
  final String? cooldownText;

  const SpinActionButton({
    super.key,
    required this.isSpinning,
    required this.spinsRemaining,
    required this.onSpin,
    this.cooldownText,
  });

  @override
  Widget build(BuildContext context) {
    final canSpin = !isSpinning && spinsRemaining > 0 && onSpin != null;

    final badgeLabel = isSpinning
        ? 'Spinning...'
        : (spinsRemaining > 0
              ? '$spinsRemaining Free Spin'
              : (cooldownText ?? 'Cooldown'));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canSpin ? onSpin : null,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: canSpin
                ? const LinearGradient(
                    colors: [
                      Color(0xFF00C875),
                      Color(0xFF00A86B),
                      Color(0xFF008C52),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF94A3B8), Color(0xFF64748B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: canSpin
                    ? const Color(0x3500B96B)
                    : const Color(0x18000000),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Play Icon + "Spin Now" Label
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isSpinning
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF00A86B),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.play_arrow_rounded,
                                color: Color(0xFF008C52),
                                size: 22,
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        isSpinning ? 'Good Luck!' : 'Spin Now',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Inter',
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right: Yellow Free Spin Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6.5,
                ),
                decoration: BoxDecoration(
                  gradient: canSpin
                      ? const LinearGradient(
                          colors: [Color(0xFFFFF070), Color(0xFFFFD32A)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    color: canSpin
                        ? const Color(0xFF10194F)
                        : const Color(0xFF475569),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Inter',
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
