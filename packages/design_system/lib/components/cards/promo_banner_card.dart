import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// Promotional Banner for Daily Challenge and Fortune Wheel
class PromoBannerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String ctaLabel;
  final Widget leadingIllustration;
  final Gradient gradient;
  final VoidCallback onCtaPressed;
  final Widget? badge;
  final Color ctaColor;
  final Color ctaTextColor;

  const PromoBannerCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.leadingIllustration,
    required this.gradient,
    required this.onCtaPressed,
    this.badge,
    this.ctaColor = AppColors.brandYellow,
    this.ctaTextColor = AppColors.textPrimary,
  });

  factory PromoBannerCard.dailyChallenge({
    required VoidCallback onPlay,
    String duration = '5 min',
    String subtitle = '10 questions • Earn 50 coins',
  }) {
    return PromoBannerCard(
      title: 'Daily Challenge',
      subtitle: subtitle,
      ctaLabel: 'Play Now →',
      badge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(50),
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
      leadingIllustration: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0x33FFD633),
        ),
        child: const Center(
          child: Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFFFFD633),
            size: 36,
          ),
        ),
      ),
      gradient: AppColors.dailyChallengeGradient,
      onCtaPressed: onPlay,
      ctaColor: AppColors.brandYellow,
      ctaTextColor: AppColors.textPrimary,
    );
  }

  factory PromoBannerCard.fortuneWheel({
    required VoidCallback onSpin,
    String subtitle = 'Spin & Win Exciting Rewards',
  }) {
    return PromoBannerCard(
      title: 'Fortune Wheel',
      subtitle: subtitle,
      ctaLabel: 'Spin Now →',
      leadingIllustration: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              Color(0xFFFFD633),
              Color(0xFFF04483),
              Color(0xFF2587F8),
              Color(0xFF10B981),
              Color(0xFFFF9F0A),
              Color(0xFFFFD633),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Center(
              child: Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
            ),
          ),
        ),
      ),
      gradient: AppColors.fortuneWheelGradient,
      onCtaPressed: onSpin,
      ctaColor: Colors.white,
      ctaTextColor: const Color(0xFF0A6352),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 350;

        return Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: AppRadii.borderLg,
            boxShadow: const [
              BoxShadow(
                color: Color(0x15000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(isCompact ? 9 : 12),
          child: Row(
            children: [
              leadingIllustration,
              SizedBox(width: isCompact ? 8 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isCompact && badge != null)
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          badge!,
                        ],
                      )
                    else ...[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isCompact ? 13 : 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(height: 2),
                        badge!,
                      ],
                    ],
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withAlpha(220),
                        fontSize: isCompact ? 9.5 : 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isCompact ? 6 : 8),
              InkWell(
                onTap: onCtaPressed,
                borderRadius: AppRadii.borderPill,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ctaColor,
                    borderRadius: AppRadii.borderPill,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    ctaLabel,
                    style: TextStyle(
                      color: ctaTextColor,
                      fontSize: isCompact ? 10 : 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
