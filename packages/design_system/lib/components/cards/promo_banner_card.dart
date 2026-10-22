import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import 'app_promo_card.dart';

/// Promotional Banner for Daily Challenge and Fortune Wheel.
/// Powered by the unified [AppPromoCard] engine.
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
    final card = AppPromoCard.dailyChallenge(
      onPlay: onPlay,
      duration: duration,
      subtitle: subtitle,
    );
    return PromoBannerCard(
      title: card.title,
      subtitle: card.subtitle,
      ctaLabel: '${card.ctaLabel} →',
      leadingIllustration: card.leading!,
      gradient: card.gradient,
      onCtaPressed: onPlay,
      badge: card.badge,
      ctaColor: card.ctaColor,
      ctaTextColor: card.ctaTextColor,
    );
  }

  factory PromoBannerCard.fortuneWheel({
    required VoidCallback onSpin,
    String badgeText = 'Free Spin',
    String subtitle = 'Spin daily & win up to 500 coins',
  }) {
    final card = AppPromoCard.fortuneWheel(
      onSpin: onSpin,
      badgeText: badgeText,
      subtitle: subtitle,
    );
    return PromoBannerCard(
      title: card.title,
      subtitle: card.subtitle,
      ctaLabel: '${card.ctaLabel} →',
      leadingIllustration: card.leading!,
      gradient: card.gradient,
      onCtaPressed: onSpin,
      badge: card.badge,
      ctaColor: card.ctaColor,
      ctaTextColor: card.ctaTextColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPromoCard(
      title: title,
      subtitle: subtitle,
      ctaLabel: ctaLabel.replaceAll(' →', '').replaceAll('→', ''),
      onCtaPressed: onCtaPressed,
      leading: leadingIllustration,
      gradient: gradient,
      badge: badge,
      ctaColor: ctaColor,
      ctaTextColor: ctaTextColor,
    );
  }
}
