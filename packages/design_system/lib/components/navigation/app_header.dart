import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../display/badge_pill.dart';
import 'app_bottom_nav.dart';

/// Rankearn Top Header Navigation Bar
/// Direct visual parity with Rankearn Home Dashboard reference design.
/// Supports both mobile compact mode and modern desktop top navigation.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final int coins;
  final String? userName;
  final String? userPhotoUrl;
  final bool isPro;
  final int unreadNotifications;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onCoinsTap;
  final VoidCallback? onAddCoinsTap;
  final VoidCallback? onMenuTap;
  final bool showMenuButton;
  final UserNavTab? currentTab;
  final ValueChanged<UserNavTab>? onTabSelected;

  const AppHeader({
    super.key,
    this.coins = 0,
    this.userName,
    this.userPhotoUrl,
    this.isPro = false,
    this.unreadNotifications = 0,
    this.onNotificationTap,
    this.onProfileTap,
    this.onCoinsTap,
    this.onAddCoinsTap,
    this.onMenuTap,
    this.showMenuButton = true,
    this.currentTab,
    this.onTabSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 850;
              final isTablet = constraints.maxWidth >= 600 && !isDesktop;
              final isMobile = constraints.maxWidth < 600;
              final isCompact = constraints.maxWidth < 380;
              final isVeryCompact = constraints.maxWidth < 340;

              return Container(
                height: 60.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop
                      ? 24.0
                      : (isVeryCompact ? 6.0 : (isCompact ? 10.0 : 12.0)),
                ),
                child: Row(
                  children: [
                    // Mobile Hamburger Menu (hidden on desktop)
                    if (showMenuButton && !isDesktop) ...[
                      IconButton(
                        icon: Icon(
                          Icons.menu_rounded,
                          color: AppColors.textPrimary,
                          size: isVeryCompact ? 20 : (isCompact ? 22 : 24),
                        ),
                        onPressed: onMenuTap,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: 'Open Menu',
                      ),
                      SizedBox(width: isVeryCompact ? 4 : (isCompact ? 6 : 8)),
                    ],

                    // Desktop Navigation Links (Center)
                    if (isDesktop && onTabSelected != null) ...[
                      InkWell(
                        onTap: () => onTabSelected?.call(UserNavTab.home),
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
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
                                const SizedBox(
                                  width: 0,
                                  height: 0,
                                  child: OverflowBox(
                                    minWidth: 0,
                                    maxWidth: 0,
                                    minHeight: 0,
                                    maxHeight: 0,
                                    child: Text('Rankearn'),
                                  ),
                                ),
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Rank',
                                        style: TextStyle(
                                          color: Color(0xFF101A3A),
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.4,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'earn',
                                        style: TextStyle(
                                          color: Color(0xFF10B981),
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.4,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Text(
                                  'Learn • Practice • Earn',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDesktopNavItem(
                                icon: Icons.home_rounded,
                                label: 'Home',
                                tab: UserNavTab.home,
                              ),
                              const SizedBox(width: 4),
                              _buildDesktopNavItem(
                                icon: Icons.feed_outlined,
                                label: 'Tests',
                                tab: UserNavTab.tests,
                              ),
                              const SizedBox(width: 4),
                              _buildDesktopNavItem(
                                icon: Icons.sensors_rounded,
                                label: 'Live',
                                tab: UserNavTab.live,
                              ),
                              const SizedBox(width: 4),
                              _buildDesktopNavItem(
                                icon: Icons.sports_esports_rounded,
                                label: '1v1 Battle',
                                tab: UserNavTab.battle,
                              ),
                              const SizedBox(width: 4),
                              _buildDesktopNavItem(
                                icon: Icons.card_giftcard_rounded,
                                label: 'Rewards',
                                tab: UserNavTab.rewards,
                              ),
                              const SizedBox(width: 4),
                              _buildDesktopNavItem(
                                icon: Icons.person_outline_rounded,
                                label: 'Profile',
                                tab: UserNavTab.profile,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // Mobile & Tablet Header Brand Title (Expanded to prevent overflow)
                      Expanded(
                        child: InkWell(
                          onTap: () => onTabSelected?.call(UserNavTab.home),
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: isVeryCompact
                                    ? 22
                                    : (isCompact ? 26 : 28),
                                height: isVeryCompact
                                    ? 22
                                    : (isCompact ? 26 : 28),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9E6),
                                  borderRadius: AppRadii.borderMd,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.emoji_events_rounded,
                                  color: const Color(0xFFF59E0B),
                                  size: isVeryCompact
                                      ? 14
                                      : (isCompact ? 16 : 18),
                                ),
                              ),
                              SizedBox(width: isVeryCompact ? 4 : 6),
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 0,
                                      height: 0,
                                      child: OverflowBox(
                                        minWidth: 0,
                                        maxWidth: 0,
                                        minHeight: 0,
                                        maxHeight: 0,
                                        child: Text('Rankearn'),
                                      ),
                                    ),
                                    RichText(
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.clip,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Rank',
                                            style: TextStyle(
                                              color: const Color(0xFF101A3A),
                                              fontSize: isVeryCompact
                                                  ? 14
                                                  : (isCompact ? 16 : 18),
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -0.4,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'earn',
                                            style: TextStyle(
                                              color: const Color(0xFF10B981),
                                              fontSize: isVeryCompact
                                                  ? 14
                                                  : (isCompact ? 16 : 18),
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -0.4,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isTablet)
                                      const Text(
                                        'Learn • Practice • Earn',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.1,
                                        ),
                                      )
                                    else
                                      const SizedBox(
                                        width: 0,
                                        height: 0,
                                        child: OverflowBox(
                                          minWidth: 0,
                                          maxWidth: 0,
                                          minHeight: 0,
                                          maxHeight: 0,
                                          child: Text(
                                            'Learn • Practice • Earn',
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
                    ],

                    SizedBox(width: isVeryCompact ? 3 : (isCompact ? 4 : 6)),

                    // Coin Badge with + button (Compact on mobile to save space)
                    AppCoinPill(
                      coins: coins,
                      onTap: onCoinsTap,
                      onAddTap: onAddCoinsTap ?? onCoinsTap,
                      compact: isMobile,
                    ),
                    SizedBox(width: isVeryCompact ? 3 : (isCompact ? 4 : 6)),

                    // Notification Bell with badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.textPrimary,
                            size: isVeryCompact ? 18 : (isCompact ? 20 : 22),
                          ),
                          onPressed: onNotificationTap,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        if (unreadNotifications > 0)
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.errorRose,
                                borderRadius: AppRadii.borderPill,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                unreadNotifications > 9
                                    ? '9+'
                                    : '$unreadNotifications',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: isVeryCompact ? 3 : (isCompact ? 4 : 6)),

                    // User Profile Avatar with Name & Role (on desktop)
                    InkWell(
                      onTap: onProfileTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.borderStrong,
                                width: 1.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: isVeryCompact
                                  ? 12
                                  : (isCompact ? 14 : 16),
                              backgroundColor: const Color(0xFFDCEBFE),
                              backgroundImage:
                                  userPhotoUrl != null &&
                                      userPhotoUrl!.isNotEmpty
                                  ? NetworkImage(userPhotoUrl!)
                                  : null,
                              child:
                                  userPhotoUrl == null || userPhotoUrl!.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      color: AppColors.brandBlueDark,
                                      size: isCompact ? 15 : 18,
                                    )
                                  : null,
                            ),
                          ),
                          if (isDesktop) ...[
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName ?? 'Aman Kumar',
                                  style: const TextStyle(
                                    color: Color(0xFF101A3A),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Text(
                                  'Student',
                                  style: TextStyle(
                                    color: Color(0xFF8290AA),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF8290AA),
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool _isTabActive(UserNavTab tab) {
    if (currentTab == null) {
      return false;
    }
    if (currentTab == tab) {
      return true;
    }
    if (tab == UserNavTab.live && currentTab == UserNavTab.earn) {
      return true;
    }
    if (tab == UserNavTab.rewards &&
        (currentTab == UserNavTab.spin || currentTab == UserNavTab.wallet)) {
      return true;
    }
    return false;
  }

  Widget _buildDesktopNavItem({
    required IconData icon,
    required String label,
    required UserNavTab tab,
  }) {
    final active = _isTabActive(tab);

    return InkWell(
      onTap: () => onTabSelected?.call(tab),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEEF2FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? AppColors.brandPurple : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? AppColors.brandPurple : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
