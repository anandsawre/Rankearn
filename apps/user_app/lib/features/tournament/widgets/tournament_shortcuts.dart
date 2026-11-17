import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Navigation Shortcut Cards Tokenized with Centralized Design System
class TournamentShortcuts extends StatelessWidget {
  final bool isDesktop;
  final String activeShortcut; // 'all', 'my', 'leaderboard', 'rewards', 'rules'
  final ValueChanged<String> onShortcutTap;

  const TournamentShortcuts({
    super.key,
    required this.isDesktop,
    required this.activeShortcut,
    required this.onShortcutTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            child: _buildDesktopPill(
              keyName: 'all',
              icon: Icons.emoji_events_rounded,
              label: 'All Contests',
            ),
          ),
          const SizedBox(width: AppSpacing.sm * 1.75),
          Expanded(
            child: _buildDesktopPill(
              keyName: 'my',
              icon: Icons.assignment_outlined,
              label: 'My Contests',
            ),
          ),
          const SizedBox(width: AppSpacing.sm * 1.75),
          Expanded(
            child: _buildDesktopPill(
              keyName: 'leaderboard',
              icon: Icons.bar_chart_rounded,
              label: 'Leaderboard',
            ),
          ),
          const SizedBox(width: AppSpacing.sm * 1.75),
          Expanded(
            child: _buildDesktopPill(
              keyName: 'rewards',
              icon: Icons.card_giftcard_rounded,
              label: 'Rewards',
            ),
          ),
          const SizedBox(width: AppSpacing.sm * 1.75),
          Expanded(
            child: _buildDesktopPill(
              keyName: 'rules',
              icon: Icons.info_outline_rounded,
              label: 'Rules & Eligibility',
            ),
          ),
        ],
      );
    }

    // Mobile: 4 Colored Pods (Row of 4 equal pods)
    return Row(
      children: [
        Expanded(
          child: _buildMobilePod(
            keyName: 'all',
            label: 'All\nContests',
            icon: Icons.emoji_events_rounded,
            bgColor: AppColors.contestShortcutPurpleBg,
            iconBgColor: AppColors.contestShortcutPurpleIcon,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildMobilePod(
            keyName: 'my',
            label: 'My\nContests',
            icon: Icons.assignment_outlined,
            bgColor: AppColors.contestShortcutPinkBg,
            iconBgColor: AppColors.contestShortcutPinkIcon,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildMobilePod(
            keyName: 'leaderboard',
            label: 'Leaderboard\n',
            icon: Icons.bar_chart_rounded,
            bgColor: AppColors.contestShortcutGreenBg,
            iconBgColor: AppColors.contestShortcutGreenIcon,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildMobilePod(
            keyName: 'rules',
            label: 'Rules &\nRewards',
            icon: Icons.card_giftcard_rounded,
            bgColor: AppColors.contestShortcutAmberBg,
            iconBgColor: AppColors.contestShortcutAmberIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopPill({
    required String keyName,
    required IconData icon,
    required String label,
  }) {
    final isSelected = activeShortcut == keyName;

    return InkWell(
      onTap: () => onShortcutTap(keyName),
      borderRadius: AppRadii.contestShortcut,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.contestActiveGreen : AppColors.contestCardBg,
          borderRadius: AppRadii.contestShortcut,
          border: Border.all(
            color: isSelected
                ? AppColors.contestActiveGreen
                : AppColors.contestCardBorder,
          ),
          boxShadow: isSelected ? AppShadows.contestPillActive : AppShadows.subtle,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePod({
    required String keyName,
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color iconBgColor,
  }) {
    return InkWell(
      onTap: () => onShortcutTap(keyName),
      borderRadius: AppRadii.contestShortcut,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadii.contestShortcut,
          border: Border.all(
            color: activeShortcut == keyName
                ? iconBgColor
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: AppRadii.contestThumbSm,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
