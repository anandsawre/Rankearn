import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/typography.dart';

/// Standardized, reusable Hero Banner component across the Rankearn app.
/// Ensures consistent vertical height, typography hierarchy, responsive padding,
/// and mascot illustration sizing across all tabs (Home, Tests, Live Tests, etc.).
class AppHeroBanner extends StatelessWidget {
  /// Main title string. If [titleWidget] is provided, this is ignored.
  final String? title;

  /// Custom title widget (e.g., RichText with multi-colored spans).
  final Widget? titleWidget;

  /// Subtitle or short description text.
  final String? subtitle;

  /// Optional badge displayed above the title (e.g., LIVE pill, NEW pill).
  final Widget? badge;

  /// Primary CTA button label (e.g., "Start Practicing", "Join Live Test").
  final String? ctaLabel;

  /// Primary CTA click callback. If null, the button is not rendered.
  final VoidCallback? onCtaPressed;

  /// Primary CTA button background color. Defaults to Gold/Yellow (#FFD633).
  final Color ctaColor;

  /// Primary CTA button text/icon color. Defaults to Navy (#101A3A).
  final Color ctaTextColor;

  /// Primary CTA icon. Defaults to arrow forward.
  final IconData ctaIcon;

  /// Path to the 3D character mascot illustration asset.
  final String? imageAssetPath;

  /// Optional floating badge overlay on the mascot (e.g., "Small Steps Big Results!").
  final Widget? floatingMascotBadge;

  /// Fallback illustration if image is missing or loading fails.
  final Widget? fallbackIllustration;

  /// Background gradient of the hero card.
  final Gradient gradient;

  /// Border color of the hero card.
  final Color? borderColor;

  /// Box shadows for the card.
  final List<BoxShadow>? boxShadow;

  /// Optional ambient glowing background shapes in Stack.
  final List<Widget>? ambientGlows;

  /// Optional micro-feature chips or highlight items (rendered below CTA).
  final List<Widget>? features;

  /// Height of the mascot on desktop viewports. Defaults to 175px (total card ~219px).
  final double desktopMascotHeight;

  /// Height of the mascot on compact mobile viewports. Defaults to 140px.
  final double mobileMascotHeight;

  /// Optional leading emblem on the left (e.g. 3D Trophy Ribbon for Leaderboard).
  final Widget? leadingEmblem;

  /// Card border radius. Defaults to 16px (AppRadii.borderLg).
  final BorderRadius? borderRadius;

  const AppHeroBanner({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.badge,
    this.leadingEmblem,
    this.ctaLabel,
    this.onCtaPressed,
    this.ctaColor = const Color(0xFFFFD633),
    this.ctaTextColor = const Color(0xFF101A3A),
    this.ctaIcon = Icons.arrow_forward_rounded,
    this.imageAssetPath,
    this.floatingMascotBadge,
    this.fallbackIllustration,
    required this.gradient,
    this.borderColor,
    this.boxShadow,
    this.ambientGlows,
    this.features,
    this.desktopMascotHeight = 175,
    this.mobileMascotHeight = 140,
    this.borderRadius,
  });

  /// Factory preset for the Tests Tab Hero Banner
  factory AppHeroBanner.tests({
    String? imageAssetPath = 'assets/images/tests_hero_mascot.jpg',
    VoidCallback? onStartPracticing,
    BorderRadius? borderRadius,
  }) {
    return AppHeroBanner(
      title: 'Tests',
      subtitle: 'Practice smarter, score higher\nand earn real rewards.',
      ctaLabel: onStartPracticing != null ? 'Start Practicing' : null,
      onCtaPressed: onStartPracticing,
      imageAssetPath: imageAssetPath,
      borderRadius: borderRadius,
      gradient: const LinearGradient(
        colors: [
          Color(0xFFE8F4FD), // Soft sky blue
          Color(0xFFF0FDF8), // Soft mint green
          Color(0xFFF7FAFE), // Soft neutral
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: const Color(0xFFD6E4F0),
      boxShadow: const [
        BoxShadow(
          color: Color(0x06000000),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
      ambientGlows: [
        Positioned(
          top: -30,
          left: -20,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF38BDF8).withAlpha(35),
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          right: 80,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF34D399).withAlpha(30),
            ),
          ),
        ),
      ],
      floatingMascotBadge: _buildDefaultScriptBadge(),
      fallbackIllustration: _buildFallbackIconIllustration(
        Icons.checklist_rtl_rounded,
        const Color(0xFF10B981),
      ),
    );
  }

  /// Factory preset for the Live Tests Tab Hero Banner
  factory AppHeroBanner.liveTests({
    String? imageAssetPath = 'assets/images/live_tests_hero_mascot.jpg',
    VoidCallback? onJoinLiveTest,
    VoidCallback? onBannerTap,
    BorderRadius? borderRadius,
  }) {
    return AppHeroBanner(
      badge: _buildLivePillBadge(),
      titleWidget: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            height: 1.1,
            fontFamily: 'Inter',
          ),
          children: [
            TextSpan(
              text: 'Live ',
              style: TextStyle(color: Colors.white),
            ),
            TextSpan(
              text: 'Tests',
              style: TextStyle(color: Color(0xFFFFD633)),
            ),
          ],
        ),
      ),
      subtitle: 'Compete in real-time and win exciting rewards!',
      ctaLabel: 'Join Live Test',
      onCtaPressed: onJoinLiveTest ?? onBannerTap,
      imageAssetPath: imageAssetPath,
      borderRadius: borderRadius,
      gradient: const LinearGradient(
        colors: [
          Color(0xFF0B0625), // Deep navy stage night
          Color(0xFF1B0E54), // Electric purple
          Color(0xFF281062), // Magenta purple ambient
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x331B0E54),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
      ambientGlows: [
        Positioned(
          top: -30,
          right: -20,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEC4899).withAlpha(45),
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          left: 60,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF38BDF8).withAlpha(35),
            ),
          ),
        ),
      ],
      features: [
        _buildHighlightTag(
          icon: Icons.emoji_events_rounded,
          iconColor: const Color(0xFFFFD633),
          label: 'Real-time\nRanking',
        ),
        _buildHighlightTag(
          icon: Icons.card_giftcard_rounded,
          iconColor: const Color(0xFFF43F5E),
          label: 'Win\nCoins',
        ),
        _buildHighlightTag(
          icon: Icons.public_rounded,
          iconColor: const Color(0xFF38BDF8),
          label: 'Compete\nAcross India',
        ),
      ],
      fallbackIllustration: _buildFallbackIconIllustration(
        Icons.sensors_rounded,
        const Color(0xFFFFD633),
      ),
    );
  }

  /// Factory preset for the Rewards Tab Hero Banner matching reference design
  factory AppHeroBanner.rewards({
    String? imageAssetPath = 'assets/images/rewards_hero_mascot.jpg',
    VoidCallback? onHowToEarn,
    VoidCallback? onBannerTap,
    BorderRadius? borderRadius,
  }) {
    return AppHeroBanner(
      titleWidget: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            height: 1.05,
            fontFamily: 'Inter',
          ),
          children: [
            TextSpan(
              text: 'Earn\n',
              style: TextStyle(color: Colors.white),
            ),
            TextSpan(
              text: 'More Rewards',
              style: TextStyle(color: Color(0xFFFFD633)),
            ),
          ],
        ),
      ),
      subtitle: 'Complete tasks, play tests and\nrefer friends to earn coins.',
      ctaLabel: 'How to Earn?',
      onCtaPressed: onHowToEarn ?? onBannerTap,
      imageAssetPath: imageAssetPath,
      borderRadius: borderRadius,
      gradient: const LinearGradient(
        colors: [
          Color(0xFF0F0728), // Deep cosmic navy
          Color(0xFF26105A), // Electric purple
          Color(0xFF381475), // Magenta purple
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x3326105A),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
      ambientGlows: [
        Positioned(
          top: -30,
          right: -20,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF3978).withAlpha(40),
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          left: 60,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF38BDF8).withAlpha(35),
            ),
          ),
        ),
      ],
      floatingMascotBadge: Positioned(
        top: 6,
        right: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xCC1A0C42),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 0.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFFFFD633),
                size: 16,
              ),
              SizedBox(height: 2),
              Text(
                'Learn\nPractice\nPlay\nEarn',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Factory preset for the 1v1 Quiz Battle Tab Hero Banner
  factory AppHeroBanner.battle({
    String? imageAssetPath = 'assets/images/battle_hero_mascot.jpg',
    VoidCallback? onStartBattle,
    VoidCallback? onBannerTap,
    BorderRadius? borderRadius,
  }) {
    return AppHeroBanner(
      titleWidget: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            height: 1.05,
            fontFamily: 'Inter',
          ),
          children: [
            TextSpan(
              text: '1v1\n',
              style: TextStyle(color: Color(0xFFFFD633)),
            ),
            TextSpan(
              text: 'Quiz Battle',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      subtitle:
          'Challenge real players,\nshow your skills and\nwin exciting rewards!',
      ctaLabel: 'Start Battle',
      onCtaPressed: onStartBattle ?? onBannerTap,
      imageAssetPath: imageAssetPath,
      borderRadius: borderRadius,
      gradient: const LinearGradient(
        colors: [
          Color(0xFF0F0728), // Deep stage navy
          Color(0xFF26105A), // Electric purple
          Color(0xFF3B1578), // Magenta purple ambient
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x3326105A),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
      ambientGlows: [
        Positioned(
          top: -30,
          right: -20,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF3978).withAlpha(40),
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          left: 60,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF38BDF8).withAlpha(35),
            ),
          ),
        ),
      ],
      floatingMascotBadge: Positioned(
        top: 6,
        right: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xCC1A0C42),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 0.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFFFD633),
                size: 16,
              ),
              SizedBox(height: 2),
              Text(
                'Play\nCompete\nEarn',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
      features: [
        _buildHighlightTag(
          icon: Icons.people_rounded,
          iconColor: const Color(0xFFFF3978),
          label: 'Real Players\nOnline',
        ),
        _buildHighlightTag(
          icon: Icons.bolt_rounded,
          iconColor: const Color(0xFF38BDF8),
          label: 'Instant\nMatch',
        ),
        _buildHighlightTag(
          icon: Icons.monetization_on_rounded,
          iconColor: const Color(0xFFFFD633),
          label: 'Win\nCoins',
        ),
      ],
      fallbackIllustration: _buildFallbackIconIllustration(
        Icons.sports_esports_rounded,
        const Color(0xFFFFD633),
      ),
    );
  }

  /// Factory preset for the Leaderboard Tab Hero Banner matching Reference Image 1
  factory AppHeroBanner.leaderboard({
    String? mascotAssetPath = 'assets/images/leaderboard_hero_mascot.jpg',
    String? emblemAssetPath = 'assets/images/leaderboard_trophy_ribbon.jpg',
    BorderRadius? borderRadius,
  }) {
    return AppHeroBanner(
      leadingEmblem: _buildLeaderboardEmblem(emblemAssetPath),
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Top Learners',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              height: 1.1,
              color: Colors.white,
              fontFamilyFallback: AppTypography.fontFallbacks,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Compete • Improve • Earn More',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
              color: Color(0xFFFFD633),
              fontFamilyFallback: AppTypography.fontFallbacks,
            ),
          ),
        ],
      ),
      subtitle:
          'Climb the ranks by attempting tests, playing battles and earning coins.',
      imageAssetPath: mascotAssetPath,
      borderRadius: borderRadius,
      gradient: const LinearGradient(
        colors: [Color(0xFF00B96B), Color(0xFF009C59), Color(0xFF007E47)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33008C52),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
      ambientGlows: [
        Positioned(
          top: -30,
          left: -20,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(25),
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          right: 120,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD32A).withAlpha(30),
            ),
          ),
        ),
      ],
      fallbackIllustration: Image.asset(
        'assets/images/tests_hero_mascot.jpg',
        fit: BoxFit.contain,
        alignment: Alignment.centerRight,
        errorBuilder: (context, error, stackTrace) =>
            _buildLeaderboardMascotFallback(),
      ),
    );
  }

  static Widget _buildLeaderboardMascotFallback() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.emoji_events_rounded,
          color: Color(0xFFFFD633),
          size: 64,
        ),
      ),
    );
  }

  static Widget _buildLeaderboardEmblem(String? emblemAssetPath) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(35),
        border: Border.all(color: Colors.white.withAlpha(60), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: emblemAssetPath != null
          ? Image.asset(
              emblemAssetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  _buildTrophyWithRibbonFallback(),
            )
          : _buildTrophyWithRibbonFallback(),
    );
  }

  static Widget _buildTrophyWithRibbonFallback() {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(
          Icons.workspace_premium_rounded,
          color: Color(0xFFFFD633),
          size: 66,
        ),
        const Icon(
          Icons.emoji_events_rounded,
          color: Color(0xFFFFFBEB),
          size: 42,
        ),
        Positioned(
          bottom: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626),
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x30000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: const Text(
              'LEADERBOARD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Factory preset for the Home Dashboard Hero Banner
  factory AppHeroBanner.home({
    String? imageAssetPath,
    required VoidCallback onStartLearning,
    BorderRadius? borderRadius,
  }) {
    final hasImage = imageAssetPath != null;
    return AppHeroBanner(
      titleWidget: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            height: 1.1,
            fontFamily: 'Inter',
          ),
          children: [
            TextSpan(
              text: 'Learn & Practice\n',
              style: TextStyle(color: Colors.white),
            ),
            TextSpan(
              text: 'Earn Rewards',
              style: TextStyle(color: Color(0xFFFFD633)),
            ),
          ],
        ),
      ),
      subtitle: 'Take tests, improve your skills and earn coins with Rankearn.',
      ctaLabel: 'Start Learning',
      onCtaPressed: onStartLearning,
      imageAssetPath: imageAssetPath,
      borderRadius: borderRadius,
      gradient: AppColors.heroGradient,
      boxShadow: const [
        BoxShadow(
          color: Color(0x333920C9),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
      ambientGlows: [
        // 1. Soft glowing radiant halo (top right)
        Positioned(
          top: -50,
          right: 10,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.16),
                  const Color(0xFF6366F1).withValues(alpha: 0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // 2. Secondary halo (bottom left)
        Positioned(
          bottom: -35,
          left: 60,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandPurpleLight.withValues(alpha: 0.15),
            ),
          ),
        ),

        // 3. Concentric Arc Ring (outer)
        Positioned(
          top: -60,
          right: -30,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.5,
              ),
            ),
          ),
        ),

        // 4. Concentric Arc Ring (inner)
        Positioned(
          top: -25,
          right: 5,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.2,
              ),
            ),
          ),
        ),

        // 5. Tech Dot-Matrix Grid (top right)
        Positioned(
          top: 18,
          right: 28,
          child: SizedBox(
            width: 100,
            height: 60,
            child: CustomPaint(
              painter: _HeroDotGridPainter(),
            ),
          ),
        ),

        // 6. Subtle Educational Watermark (right side)
        Positioned(
          right: 15,
          bottom: -15,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: -0.10,
              child: Icon(
                Icons.school_rounded,
                size: 130,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
        ),

        // 7. Subtle floating star sparkle
        Positioned(
          top: 30,
          right: 140,
          child: Icon(
            Icons.auto_awesome,
            color: const Color(0xFFFFD633).withValues(alpha: 0.35),
            size: 20,
          ),
        ),
      ],
      floatingMascotBadge: hasImage ? _buildDefaultScriptBadge() : null,
      features: [
        _buildHighlightTag(
          icon: Icons.bar_chart_rounded,
          iconColor: Colors.white,
          label: 'Practice\nTests',
        ),
        _buildHighlightTag(
          icon: Icons.monetization_on_rounded,
          iconColor: Colors.white,
          label: 'Win\nCoins',
        ),
        _buildHighlightTag(
          icon: Icons.track_changes_rounded,
          iconColor: Colors.white,
          label: 'Track\nProgress',
        ),
      ],
      fallbackIllustration: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
        final isVeryCompact = constraints.maxWidth < 360;

        final hasMascot = imageAssetPath != null ||
            fallbackIllustration != null ||
            floatingMascotBadge != null;

        final mascotHeight = isCompact
            ? mobileMascotHeight
            : desktopMascotHeight;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 1)
                : null,
            boxShadow: boxShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Ambient Glowing Circles
              ...?ambientGlows,

              // Main Content Padding (Standardized across all banners)
              Padding(
                padding: EdgeInsets.only(
                  left: isVeryCompact ? 14 : (isCompact ? 16 : 24),
                  top: isCompact ? 16 : 22,
                  bottom: isCompact ? 16 : 22,
                  right: isVeryCompact ? 8 : (isCompact ? 12 : 16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (leadingEmblem != null) ...[
                      leadingEmblem!,
                      SizedBox(
                        width: isVeryCompact ? 10 : (isCompact ? 14 : 20),
                      ),
                    ],
                    // Left Column: Badge, Title, Subtitle, CTA, Features
                    Expanded(
                      flex: hasMascot ? (isCompact ? 13 : 11) : 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Optional Badge (e.g. LIVE pill)
                          if (badge != null) ...[
                            badge!,
                            const SizedBox(height: 6),
                          ],

                          // 2. Title
                          if (titleWidget != null)
                            titleWidget!
                          else if (title != null)
                            Text(
                              title!,
                              style: TextStyle(
                                fontSize: isVeryCompact
                                    ? 26
                                    : (isCompact ? 28 : 34),
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.8,
                                height: 1.1,
                              ),
                            ),
                          const SizedBox(height: 6),

                          // 3. Subtitle
                          if (subtitle != null) ...[
                            Text(
                              subtitle!,
                              style: TextStyle(
                                color: _isDarkGradient()
                                    ? const Color(0xFFE2E8F0)
                                    : AppColors.textSecondary,
                                fontSize: isVeryCompact
                                    ? 11
                                    : (isCompact ? 12 : 13),
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                          ],

                          // 4. CTA Button & Feature Chips
                          if (ctaLabel != null ||
                              (features != null && features!.isNotEmpty))
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (ctaLabel != null) ...[
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: onCtaPressed,
                                        borderRadius: AppRadii.borderPill,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isVeryCompact ? 12 : 16,
                                            vertical: 7.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ctaColor,
                                            borderRadius: AppRadii.borderPill,
                                            boxShadow: [
                                              BoxShadow(
                                                color: ctaColor.withValues(
                                                  alpha: 0.35,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                ctaLabel!,
                                                style: TextStyle(
                                                  color: ctaTextColor,
                                                  fontSize: isVeryCompact
                                                      ? 11.5
                                                      : 12.5,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Icon(
                                                ctaIcon,
                                                color: ctaTextColor,
                                                size: 14,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (features != null &&
                                        features!.isNotEmpty)
                                      const SizedBox(width: 14),
                                  ],
                                  if (features != null &&
                                      features!.isNotEmpty) ...[
                                    for (
                                      int i = 0;
                                      i < features!.length;
                                      i++
                                    ) ...[
                                      features![i],
                                      if (i < features!.length - 1)
                                        const SizedBox(width: 10),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    if (hasMascot)
                      // Right Column: Mascot Illustration (Standardized height)
                      Expanded(
                        flex: 10,
                        child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Container(
                            height: mascotHeight,
                            constraints: const BoxConstraints(maxWidth: 260),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: imageAssetPath != null
                                ? Image.asset(
                                    imageAssetPath!,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.centerRight,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            fallbackIllustration ??
                                            const SizedBox.shrink(),
                                  )
                                : (fallbackIllustration ??
                                      const SizedBox.shrink()),
                          ),
                          ?floatingMascotBadge,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isDarkGradient() {
    if (gradient is LinearGradient) {
      final lg = gradient as LinearGradient;
      if (lg.colors.isNotEmpty) {
        return lg.colors.first.computeLuminance() < 0.4;
      }
    }
    return false;
  }

  // Helper: Live Pill Badge
  static Widget _buildLivePillBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
        ),
        borderRadius: AppRadii.borderPill,
        boxShadow: const [
          BoxShadow(
            color: Color(0x40F43F5E),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.sensors_rounded, color: Colors.white, size: 12),
          SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Highlight Tag
  static Widget _buildHighlightTag({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 15),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  // Helper: Floating Crown / Script Badge
  static Widget _buildDefaultScriptBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(75),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withAlpha(40), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Icon(
              Icons.military_tech_rounded,
              color: Color(0xFFFFD633),
              size: 14,
            ),
            Text(
              'Small Steps',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              'Big Results!',
              style: TextStyle(
                color: Color(0xFFFFD633),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Fallback illustration
  static Widget _buildFallbackIconIllustration(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E105C).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: Icon(icon, color: color, size: 48)),
    );
  }
}

/// CustomPainter for rendering subtle dot matrix grid on hero banners
class _HeroDotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 11.0;
    const dotRadius = 1.2;
    const cols = 6;
    const rows = 4;
    final dotPaint = Paint()
      ..color = Colors.white.withAlpha(35)
      ..style = PaintingStyle.fill;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(c * spacing, r * spacing),
          dotRadius,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
