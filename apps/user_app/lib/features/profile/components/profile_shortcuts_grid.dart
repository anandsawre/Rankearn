import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Six Profile Shortcut Cards:
/// 1. Edit Profile
/// 2. My Progress
/// 3. My Achievements
/// 4. Test History
/// 5. Downloads
/// 6. My Wishlist
class ProfileShortcutsGrid extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onMyProgress;
  final VoidCallback onMyAchievements;
  final VoidCallback onTestHistory;
  final VoidCallback onDownloads;
  final VoidCallback onMyWishlist;
  final bool isDesktop;

  const ProfileShortcutsGrid({
    super.key,
    required this.onEditProfile,
    required this.onMyProgress,
    required this.onMyAchievements,
    required this.onTestHistory,
    required this.onDownloads,
    required this.onMyWishlist,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _ShortcutItem(
        title: 'Edit Profile',
        icon: Icons.person_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFFB7185), Color(0xFFF43F5E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: onEditProfile,
      ),
      _ShortcutItem(
        title: 'My Progress',
        icon: Icons.bar_chart_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: onMyProgress,
      ),
      _ShortcutItem(
        title: 'My Achievements',
        icon: Icons.military_tech_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: onMyAchievements,
      ),
      _ShortcutItem(
        title: 'Test History',
        icon: Icons.access_time_filled_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: onTestHistory,
      ),
      _ShortcutItem(
        title: 'Downloads',
        icon: Icons.file_download_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF34D399), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: onDownloads,
      ),
      _ShortcutItem(
        title: 'My Wishlist',
        icon: Icons.favorite_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFF87171), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: onMyWishlist,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isDesktop && constraints.maxWidth >= 520) {
          // Desktop: Single horizontal row of 6 items
          return Row(
            children: items.map((item) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildShortcutCard(item),
                ),
              );
            }).toList(),
          );
        }

        // Mobile: 3 columns x 2 rows
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildShortcutCard(items[0])),
                const SizedBox(width: 10),
                Expanded(child: _buildShortcutCard(items[1])),
                const SizedBox(width: 10),
                Expanded(child: _buildShortcutCard(items[2])),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildShortcutCard(items[3])),
                const SizedBox(width: 10),
                Expanded(child: _buildShortcutCard(items[4])),
                const SizedBox(width: 10),
                Expanded(child: _buildShortcutCard(items[5])),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildShortcutCard(_ShortcutItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border, width: 1.2),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Vibrant Squircle Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: item.gradient,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: item.gradient.colors.last.withAlpha(50),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(item.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 10),

              // Title Label
              Text(
                item.title,
                style: AppTypography.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutItem {
  final String title;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ShortcutItem({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });
}
