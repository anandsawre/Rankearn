import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';

// ============================================================================
// 1. Test Result Header (Desktop & Mobile)
// ============================================================================
class TestResultHeader extends StatelessWidget implements PreferredSizeWidget {
  final int coins;
  final String studentName;
  final String? studentPhotoUrl;
  final int unreadNotifications;
  final VoidCallback? onBack;
  final VoidCallback? onAddCoins;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final ValueChanged<UserNavTab>? onNavTabSelected;

  const TestResultHeader({
    super.key,
    required this.coins,
    required this.studentName,
    this.studentPhotoUrl,
    this.unreadNotifications = 3,
    this.onBack,
    this.onAddCoins,
    this.onNotificationTap,
    this.onProfileTap,
    this.onNavTabSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 850;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 60.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2ECFA), width: 1.0),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24.0 : 12.0,
            ),
            alignment: Alignment.center,
            child: isDesktop
                ? _buildDesktopHeader(context)
                : _buildMobileHeader(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Row(
      children: [
        // Logo & Tagline
        InkWell(
          onTap: () => onNavTabSelected?.call(UserNavTab.home),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: AppRadii.borderMd,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFF59E0B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Rank',
                          style: TextStyle(
                            color: Color(0xFF10194F),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        TextSpan(
                          text: 'earn',
                          style: TextStyle(
                            color: Color(0xFF00B96B),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Learn · Practice · Earn',
                    style: TextStyle(
                      color: Color(0xFF586B9B),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),

        // Navigation Links (Tests Tab is Highlighted!)
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNavItem(
                  Icons.home_outlined,
                  'Home',
                  false,
                  () => onNavTabSelected?.call(UserNavTab.home),
                ),
                const SizedBox(width: 6),
                _buildNavItem(
                  Icons.feed_rounded,
                  'Tests',
                  true,
                  () => onNavTabSelected?.call(UserNavTab.tests),
                ),
                const SizedBox(width: 6),
                _buildNavItem(
                  Icons.sensors_rounded,
                  'Live',
                  false,
                  () => onNavTabSelected?.call(UserNavTab.live),
                ),
                const SizedBox(width: 6),
                _buildNavItem(
                  Icons.sports_esports_outlined,
                  '1v1 Battle',
                  false,
                  () => onNavTabSelected?.call(UserNavTab.battle),
                ),
                const SizedBox(width: 6),
                _buildNavItem(
                  Icons.leaderboard_outlined,
                  'Leaderboard',
                  false,
                  () => onNavTabSelected?.call(UserNavTab.leaderboard),
                ),
                const SizedBox(width: 6),
                _buildNavItem(
                  Icons.account_balance_wallet_outlined,
                  'Wallet',
                  false,
                  () => onNavTabSelected?.call(UserNavTab.wallet),
                ),
                const SizedBox(width: 6),
                _buildNavItem(
                  Icons.card_giftcard_outlined,
                  'Rewards',
                  false,
                  () => onNavTabSelected?.call(UserNavTab.rewards),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Coin Balance Pill
        _buildCoinPill(),
        const SizedBox(width: 12),

        // Notification Bell
        _buildNotificationButton(),
        const SizedBox(width: 16),

        // Student Profile Menu
        _buildProfileMenu(),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF10194F),
            size: 24,
          ),
          onPressed: onBack ?? () => Navigator.maybePop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          tooltip: 'Back',
        ),
        const SizedBox(width: 4),

        // Logo
        InkWell(
          onTap: () => onNavTabSelected?.call(UserNavTab.home),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFF59E0B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 6),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Rank',
                      style: TextStyle(
                        color: Color(0xFF10194F),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    TextSpan(
                      text: 'earn',
                      style: TextStyle(
                        color: Color(0xFF00B96B),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Coin Pill
        _buildCoinPill(compact: true),
        const SizedBox(width: 6),

        // Notification Bell
        _buildNotificationButton(),
      ],
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8FAF2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? const Color(0xFF00B96B)
                  : const Color(0xFF586B9B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                    ? const Color(0xFF008C52)
                    : const Color(0xFF586B9B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinPill({bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF10194F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFC928),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.star_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            coins.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
            ),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onAddCoins,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00B96B),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF586B9B),
            size: 24,
          ),
          onPressed: onNotificationTap,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          tooltip: 'Notifications',
        ),
        if (unreadNotifications > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Color(0xFFF52245),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              alignment: Alignment.center,
              child: Text(
                '$unreadNotifications',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileMenu() {
    return InkWell(
      onTap: onProfileTap,
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFE8FAF2),
            backgroundImage: studentPhotoUrl != null
                ? NetworkImage(studentPhotoUrl!)
                : null,
            child: studentPhotoUrl == null
                ? const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF00B96B),
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                studentName,
                style: const TextStyle(
                  color: Color(0xFF10194F),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'Student',
                style: TextStyle(
                  color: Color(0xFF586B9B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF586B9B),
            size: 18,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. Result Metric Card (Reusable)
// ============================================================================
class ResultMetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;
  final Widget? trailingBadge;

  const ResultMetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
    this.trailingBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2ECFA), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10194F).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF586B9B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          color: Color(0xFF10194F),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (trailingBadge != null) ...[
                        const SizedBox(width: 6),
                        trailingBadge!,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 3. Result Hero Banner (Celebratory Banner with Mascot & Metrics)
// ============================================================================
class ResultHeroBanner extends StatelessWidget {
  final TestResultModel result;
  final VoidCallback? onBackToTests;

  const ResultHeroBanner({super.key, required this.result, this.onBackToTests});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE6FAF1), Color(0xFFD6F5E9), Color(0xFFE2F8F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFB9F0DA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B96B).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      child: isDesktop ? _buildDesktopHero(context) : _buildMobileHero(context),
    );
  }

  Widget _buildDesktopHero(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Subject Badge & Test Date
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subject badge row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B96B),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF00B96B,
                          ).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.directions_run_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.testTitle,
                          style: const TextStyle(
                            color: Color(0xFF10194F),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          result.testSubtitle,
                          style: const TextStyle(
                            color: Color(0xFF008C52),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Date & Time
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF586B9B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      result.formattedDate,
                      style: const TextStyle(
                        color: Color(0xFF586B9B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Center Column: Large Congratulations Heading & Mascot
        Expanded(
          flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Great Job,\n',
                            style: TextStyle(
                              color: Color(0xFF10194F),
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: '${result.studentName}! 🎉',
                            style: const TextStyle(
                              color: Color(0xFF00B96B),
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You have completed the test. Keep practicing to improve your score!',
                      style: TextStyle(
                        color: Color(0xFF586B9B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Mascot Image
              _buildMascotImage(size: 130),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Right Column: New Best Score Badge & 2x2 Metric Cards Grid
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (result.isNewBestScore) ...[
                _buildNewBestScoreBadge(),
                const SizedBox(height: 8),
              ],
              _buildMetricsGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Subject Badge + Date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B96B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.directions_run_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.testTitle,
                          style: const TextStyle(
                            color: Color(0xFF10194F),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          result.testSubtitle,
                          style: const TextStyle(
                            color: Color(0xFF008C52),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: Color(0xFF586B9B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      result.formattedDate,
                      style: const TextStyle(
                        color: Color(0xFF586B9B),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Middle Row: Greeting + Mascot
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Great Job,\n',
                          style: TextStyle(
                            color: Color(0xFF10194F),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        TextSpan(
                          text: '${result.studentName}! 🎉',
                          style: const TextStyle(
                            color: Color(0xFF00B96B),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'You have completed the test. Keep practicing to improve your score!',
                    style: TextStyle(
                      color: Color(0xFF586B9B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildMascotImage(size: 110),
          ],
        ),
        const SizedBox(height: 16),

        // Bottom 2x2 Grid of Metrics
        _buildMetricsGrid(),
      ],
    );
  }

  Widget _buildMascotImage({required double size}) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/test_result_hero_mascot.jpg',
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, stack) => Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFFFC928),
              size: 50,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewBestScoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7D6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
          SizedBox(width: 4),
          Text(
            'New Best Score!',
            style: TextStyle(
              color: Color(0xFFB45309),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final halfWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            SizedBox(
              width: halfWidth,
              child: ResultMetricCard(
                icon: Icons.star_rounded,
                iconColor: const Color(0xFF00B96B),
                iconBgColor: const Color(0xFFE8FAF2),
                label: 'Your Score',
                value: result.formattedScore,
                trailingBadge:
                    result.isNewBestScore &&
                        MediaQuery.of(context).size.width < 1000
                    ? _buildNewBestScoreBadge()
                    : null,
              ),
            ),
            SizedBox(
              width: halfWidth,
              child: ResultMetricCard(
                icon: Icons.track_changes_rounded,
                iconColor: const Color(0xFFF52245),
                iconBgColor: const Color(0xFFFEECEE),
                label: 'Accuracy',
                value: result.formattedAccuracy,
              ),
            ),
            SizedBox(
              width: halfWidth,
              child: ResultMetricCard(
                icon: Icons.workspace_premium_rounded,
                iconColor: const Color(0xFFFFC928),
                iconBgColor: const Color(0xFFFEF9E6),
                label: 'Your Rank',
                value: result.formattedRank,
                trailingBadge: result.rankChange != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8FAF2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_drop_up_rounded,
                              color: Color(0xFF00B96B),
                              size: 16,
                            ),
                            Text(
                              '+${result.rankChange}',
                              style: const TextStyle(
                                color: Color(0xFF008C52),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
            SizedBox(
              width: halfWidth,
              child: ResultMetricCard(
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFF2587F8),
                iconBgColor: const Color(0xFFEFF6FF),
                label: 'Time Taken',
                value: result.formattedTimeTaken,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// 4. Answer Statistics Cards (Correct, Incorrect, Unattempted, Total, Score Comparison)
// ============================================================================
class AnswerStatisticsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final int count;
  final double percentage;
  final Color percentageColor;

  const AnswerStatisticsCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.count,
    required this.percentage,
    required this.percentageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2ECFA), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10194F).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF586B9B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$count',
                        style: const TextStyle(
                          color: Color(0xFF10194F),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: percentageColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreComparisonCard extends StatelessWidget {
  final double userScore;
  final double maxScore;
  final double classAverageScore;

  const ScoreComparisonCard({
    super.key,
    required this.userScore,
    required this.maxScore,
    required this.classAverageScore,
  });

  @override
  Widget build(BuildContext context) {
    final userFraction = maxScore > 0
        ? (userScore / maxScore).clamp(0.0, 1.0)
        : 0.0;
    final avgFraction = maxScore > 0
        ? (classAverageScore / maxScore).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2ECFA), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10194F).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: const [
              Icon(Icons.bar_chart_rounded, color: Color(0xFF586B9B), size: 16),
              SizedBox(width: 6),
              Text(
                'Score Comparison',
                style: TextStyle(
                  color: Color(0xFF10194F),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Your Score Progress Row
          Row(
            children: [
              const SizedBox(
                width: 80,
                child: Text(
                  'Your Score',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF586B9B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: userFraction,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2ECFA),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF00B96B),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${userScore.toInt()} / ${maxScore.toInt()}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF10194F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Class Average Progress Row
          Row(
            children: [
              const SizedBox(
                width: 80,
                child: Text(
                  'Class Average',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF586B9B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: avgFraction,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2ECFA),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF93C5FD),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${classAverageScore.toInt()} / ${maxScore.toInt()}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF586B9B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 5. Result Analysis Navigation Tabs
// ============================================================================
enum ResultAnalysisTab { questions, subjects, time, rankRewards }

class ResultAnalysisTabs extends StatelessWidget {
  final ResultAnalysisTab activeTab;
  final ValueChanged<ResultAnalysisTab> onTabChanged;

  const ResultAnalysisTabs({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 850;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2ECFA), width: 1.0),
      ),
      padding: const EdgeInsets.all(6),
      child: isDesktop ? _buildDesktopRow() : _buildMobileScrollableRow(),
    );
  }

  Widget _buildDesktopRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTabItem(
            tab: ResultAnalysisTab.questions,
            icon: Icons.checklist_rounded,
            label: 'Question Analysis',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTabItem(
            tab: ResultAnalysisTab.subjects,
            icon: Icons.bar_chart_rounded,
            label: 'Subject Analysis',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTabItem(
            tab: ResultAnalysisTab.time,
            icon: Icons.schedule_rounded,
            label: 'Time Analysis',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTabItem(
            tab: ResultAnalysisTab.rankRewards,
            icon: Icons.emoji_events_outlined,
            label: 'Rank & Rewards',
          ),
        ),
      ],
    );
  }

  Widget _buildMobileScrollableRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildTabItem(
            tab: ResultAnalysisTab.questions,
            icon: Icons.checklist_rounded,
            label: 'Question Analysis',
          ),
          const SizedBox(width: 6),
          _buildTabItem(
            tab: ResultAnalysisTab.subjects,
            icon: Icons.bar_chart_rounded,
            label: 'Subject Analysis',
          ),
          const SizedBox(width: 6),
          _buildTabItem(
            tab: ResultAnalysisTab.time,
            icon: Icons.schedule_rounded,
            label: 'Time Analysis',
          ),
          const SizedBox(width: 6),
          _buildTabItem(
            tab: ResultAnalysisTab.rankRewards,
            icon: Icons.emoji_events_outlined,
            label: 'Rank & Rewards',
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required ResultAnalysisTab tab,
    required IconData icon,
    required String label,
  }) {
    final isActive = activeTab == tab;

    return InkWell(
      onTap: () => onTabChanged(tab),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8FAF2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFF00B96B) : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? const Color(0xFF00B96B)
                    : const Color(0xFF586B9B),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive
                      ? const Color(0xFF008C52)
                      : const Color(0xFF586B9B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 6. Question Analysis Grid & Legend
// ============================================================================
class QuestionStatusLegend extends StatelessWidget {
  final int correctCount;
  final int incorrectCount;
  final int unattemptedCount;

  const QuestionStatusLegend({
    super.key,
    required this.correctCount,
    required this.incorrectCount,
    required this.unattemptedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 14,
      runSpacing: 6,
      children: [
        _buildDot(const Color(0xFF00B96B), 'Correct ($correctCount)'),
        _buildDot(const Color(0xFFF52245), 'Incorrect ($incorrectCount)'),
        _buildDot(const Color(0xFF93A2BA), 'Not Attempted ($unattemptedCount)'),
      ],
    );
  }

  Widget _buildDot(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF586B9B),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class QuestionAnalysisGrid extends StatefulWidget {
  final List<QuestionAnalysisItem> questions;
  final void Function(int questionIndex) onQuestionTap;

  const QuestionAnalysisGrid({
    super.key,
    required this.questions,
    required this.onQuestionTap,
  });

  @override
  State<QuestionAnalysisGrid> createState() => _QuestionAnalysisGridState();
}

class _QuestionAnalysisGridState extends State<QuestionAnalysisGrid> {
  String _activeFilter = 'all'; // 'all', 'correct', 'incorrect', 'unattempted'

  @override
  Widget build(BuildContext context) {
    final total = widget.questions.length;
    final correct = widget.questions.where((q) => q.isCorrect).length;
    final incorrect = widget.questions.where((q) => q.isIncorrect).length;
    final unattempted = widget.questions.where((q) => !q.isAttempted).length;

    final filtered = widget.questions.where((q) {
      if (_activeFilter == 'correct') return q.isCorrect;
      if (_activeFilter == 'incorrect') return q.isIncorrect;
      if (_activeFilter == 'unattempted') return !q.isAttempted;
      return true;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2ECFA), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10194F).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FAF2),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Color(0xFF00B96B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Question-wise Analysis',
                  style: TextStyle(
                    color: Color(0xFF10194F),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip('all', 'All ($total)'),
                const SizedBox(width: 8),
                _buildFilterChip('correct', 'Correct ($correct)'),
                const SizedBox(width: 8),
                _buildFilterChip('incorrect', 'Incorrect ($incorrect)'),
                const SizedBox(width: 8),
                _buildFilterChip('unattempted', 'Not Attempted ($unattempted)'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Numbered Questions Grid (10 Columns responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              final int columns = constraints.maxWidth >= 320 ? 10 : 8;
              final double spacing = 6.0;
              final double itemWidth =
                  (constraints.maxWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: filtered.map((item) {
                  return SizedBox(
                    width: itemWidth,
                    height: itemWidth.clamp(28.0, 36.0),
                    child: _buildQuestionBox(item),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),

          // Legend
          QuestionStatusLegend(
            correctCount: correct,
            incorrectCount: incorrect,
            unattemptedCount: unattempted,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _activeFilter == key;

    return InkWell(
      onTap: () => setState(() => _activeFilter = key),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B96B) : const Color(0xFFF2F8FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00B96B)
                : const Color(0xFFE2ECFA),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF586B9B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionBox(QuestionAnalysisItem item) {
    Color bg;
    Color text;

    if (!item.isAttempted) {
      bg = const Color(0xFFEDF3FB);
      text = const Color(0xFF586B9B);
    } else if (item.isCorrect) {
      bg = const Color(0xFFD6F5E8);
      text = const Color(0xFF008C52);
    } else {
      bg = const Color(0xFFFEDCDF);
      text = const Color(0xFFE5252A);
    }

    return InkWell(
      onTap: () => widget.onQuestionTap(item.questionNumber - 1),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          '${item.questionNumber}',
          style: TextStyle(
            color: text,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 7. Subject Performance Card (Desktop Table & Mobile Stacked Rows)
// ============================================================================
class SubjectPerformanceCard extends StatelessWidget {
  final List<SubjectPerformance> subjects;
  final void Function(SubjectPerformance subject)? onSubjectTap;

  const SubjectPerformanceCard({
    super.key,
    required this.subjects,
    this.onSubjectTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2ECFA), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10194F).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: Color(0xFF2587F8),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Subject-wise Performance',
                        style: TextStyle(
                          color: Color(0xFF10194F),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF586B9B),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Subject',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF586B9B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Correct / Total',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF586B9B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Accuracy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF586B9B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Score',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF586B9B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFE2ECFA), height: 1),
          const SizedBox(height: 8),

          // Subject Rows
          ...subjects.map((subj) => _buildSubjectRow(context, subj)),
        ],
      ),
    );
  }

  Widget _buildSubjectRow(BuildContext context, SubjectPerformance subj) {
    return InkWell(
      onTap: () => onSubjectTap?.call(subj),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            // Subject Icon & Name
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: subj.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(subj.icon, color: subj.color, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subj.subjectName,
                      style: const TextStyle(
                        color: Color(0xFF10194F),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Correct / Total + Progress Bar
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subj.formattedRatio,
                    style: const TextStyle(
                      color: Color(0xFF10194F),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: subj.totalQuestions > 0
                          ? (subj.correctCount / subj.totalQuestions)
                          : 0,
                      minHeight: 5,
                      backgroundColor: const Color(0xFFE2ECFA),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF00B96B),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Accuracy
            Expanded(
              flex: 2,
              child: Text(
                subj.formattedAccuracy,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF008C52),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            // Score
            Expanded(
              flex: 2,
              child: Text(
                subj.formattedScore,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: Color(0xFF10194F),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 8. Performance Insights Card
// ============================================================================
class PerformanceInsightCard extends StatelessWidget {
  final List<String> insights;

  const PerformanceInsightCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Performance Insights',
                        style: TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bullets with green checkmarks
          ...insights.map((insight) => _buildInsightBullet(insight)),
        ],
      ),
    );
  }

  Widget _buildInsightBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Color(0xFF00B96B),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check, color: Colors.white, size: 11),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF451A03),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 9. Result Action Buttons
// ============================================================================
class ResultActionButtons extends StatelessWidget {
  final VoidCallback onReviewAnswers;
  final VoidCallback onPracticeAgain;
  final VoidCallback onMoreTests;

  const ResultActionButtons({
    super.key,
    required this.onReviewAnswers,
    required this.onPracticeAgain,
    required this.onMoreTests,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackSecondary = constraints.maxWidth < 240;

        Widget buildPracticeBtn() => SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: onPracticeAgain,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF00B96B),
              side: const BorderSide(color: Color(0xFF00B96B), width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.sync_rounded, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Practice Again',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        );

        Widget buildMoreTestsBtn() => SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: onMoreTests,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7C3AED),
              side: const BorderSide(color: Color(0xFF7C3AED), width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.description_outlined, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'More Tests',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        );

        return Column(
          children: [
            // Primary Action: Review Answers
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onReviewAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B96B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.assignment_turned_in_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Review Answers',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Secondary Actions Row or Column
            if (stackSecondary) ...[
              SizedBox(width: double.infinity, child: buildPracticeBtn()),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: buildMoreTestsBtn()),
            ] else ...[
              Row(
                children: [
                  Expanded(child: buildPracticeBtn()),
                  const SizedBox(width: 12),
                  Expanded(child: buildMoreTestsBtn()),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
