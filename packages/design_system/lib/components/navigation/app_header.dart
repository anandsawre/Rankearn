import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/typography.dart';
import '../display/badge_pill.dart';

/// Rankearn Top Header Navigation Bar
/// Direct visual parity with React `header` in `apps/user/src/App.tsx`.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final int coins;
  final String? userName;
  final String? userPhotoUrl;
  final bool isPro;
  final int unreadNotifications;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onCoinsTap;
  final VoidCallback? onMenuTap;
  final bool showMenuButton;

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
    this.onMenuTap,
    this.showMenuButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.0,
      decoration: const BoxDecoration(
        color: AppColors.brandPrimary,
        border: Border(
          bottom: BorderSide(color: AppColors.brandPrimaryHover, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (showMenuButton) ...[
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: onMenuTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
            ],

            // Logo & Title
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.borderMd,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'R',
                    style: TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rankearn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'START LEARNING WITH EARNING',
                      style: AppTypography.microTag.copyWith(
                        color: Colors.white.withAlpha(200),
                        fontSize: 7,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // Coin Badge
            AppCoinPill(
              coins: coins,
              onTap: onCoinsTap,
            ),
            const SizedBox(width: 8),

            // Notification Bell with badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                  onPressed: onNotificationTap,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
                if (unreadNotifications > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.errorRose,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      alignment: Alignment.center,
                      child: Text(
                        unreadNotifications > 9 ? '9+' : '$unreadNotifications',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),

            // Vertical divider
            Container(
              height: 28,
              width: 1,
              color: Colors.white.withAlpha(60),
            ),
            const SizedBox(width: 10),

            // User Profile Chip
            InkWell(
              onTap: onProfileTap,
              borderRadius: AppRadii.borderPill,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPro) ...[
                    const AppProBadge(scale: 0.85),
                    const SizedBox(width: 6),
                  ],
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: Colors.white.withAlpha(60),
                    backgroundImage: userPhotoUrl != null && userPhotoUrl!.isNotEmpty
                        ? NetworkImage(userPhotoUrl!)
                        : null,
                    child: userPhotoUrl == null || userPhotoUrl!.isEmpty
                        ? Text(
                            (userName != null && userName!.isNotEmpty) ? userName![0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
