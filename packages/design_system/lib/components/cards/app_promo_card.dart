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

  /// CTA trailing icon. Defaults to arrow forward.
  final IconData ctaIcon;

  /// Card corner radius. Defaults to 18.
  final double borderRadius;

  /// Internal padding.
  final EdgeInsetsGeometry padding;

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
    this.ctaIcon = Icons.arrow_forward_rounded,
    this.borderRadius = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  });

  /// Factory preset for Live Test Series banner
  factory AppPromoCard.liveTestSeries({VoidCallback? onViewSeries}) {
    return AppPromoCard(
      title: 'Live Test Series',
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
            Icons.flash_on_rounded,
            color: Color(0xFFFFD633),
            size: 28,
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
          child: Icon(
            Icons.donut_large_rounded,
            color: Color(0xFFFFD633),
            size: 28,
          ),
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
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.1)
            : null,
        boxShadow: boxShadow,
      ),
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
                    const SizedBox(width: 4),
                    Icon(ctaIcon, color: ctaTextColor, size: 13),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
