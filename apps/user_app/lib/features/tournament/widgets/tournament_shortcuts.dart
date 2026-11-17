import 'package:flutter/material.dart';

/// Navigation Shortcut Cards (5 pills on Desktop, 4 colored pods on Mobile)
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
          const SizedBox(width: 14),
          Expanded(
            child: _buildDesktopPill(
              keyName: 'my',
              icon: Icons.assignment_outlined,
              label: 'My Contests',
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildDesktopPill(
              keyName: 'leaderboard',
              icon: Icons.bar_chart_rounded,
              label: 'Leaderboard',
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildDesktopPill(
              keyName: 'rewards',
              icon: Icons.card_giftcard_rounded,
              label: 'Rewards',
            ),
          ),
          const SizedBox(width: 14),
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
            bgColor: const Color(0xFFF3E8FF), // Light purple
            iconBgColor: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMobilePod(
            keyName: 'my',
            label: 'My\nContests',
            icon: Icons.assignment_outlined,
            bgColor: const Color(0xFFFFE4E6), // Light pink/red
            iconBgColor: const Color(0xFFF43F5E),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMobilePod(
            keyName: 'leaderboard',
            label: 'Leaderboard\n',
            icon: Icons.bar_chart_rounded,
            bgColor: const Color(0xFFDCFCE7), // Light green
            iconBgColor: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMobilePod(
            keyName: 'rules',
            label: 'Rules &\nRewards',
            icon: Icons.card_giftcard_rounded,
            bgColor: const Color(0xFFFEF3C7), // Light yellow
            iconBgColor: const Color(0xFFF59E0B),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0x2410B981)
                  : const Color(0x06000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
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
                borderRadius: BorderRadius.circular(10),
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
