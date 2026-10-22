import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

enum LiveTestFilterTab {
  allLiveTests,
  upcoming,
  liveNow,
  myParticipations,
  leaderboards,
}

/// LiveTestNavigation tabs matching the Rankearn Live Tests reference screenshot
class LiveTestNavigation extends StatelessWidget {
  final LiveTestFilterTab selectedTab;
  final ValueChanged<LiveTestFilterTab> onTabSelected;

  const LiveTestNavigation({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (
        tab: LiveTestFilterTab.allLiveTests,
        label: 'Live Tests',
        icon: Icons.sensors_rounded,
        iconColor: null,
      ),
      (
        tab: LiveTestFilterTab.upcoming,
        label: 'Upcoming',
        icon: Icons.calendar_month_outlined,
        iconColor: null,
      ),
      (
        tab: LiveTestFilterTab.liveNow,
        label: 'Live Now',
        icon: Icons.circle,
        iconColor: const Color(0xFFF43F5E),
      ),
      (
        tab: LiveTestFilterTab.myParticipations,
        label: 'My Participations',
        icon: Icons.assignment_outlined,
        iconColor: null,
      ),
      (
        tab: LiveTestFilterTab.leaderboards,
        label: 'Leaderboards',
        icon: Icons.emoji_events_outlined,
        iconColor: null,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tabs.map((t) {
          final isSelected = selectedTab == t.tab;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onTabSelected(t.tab),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.brandGreen : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.brandGreen : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Color(0x3310B981),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        t.icon,
                        color: isSelected
                            ? Colors.white
                            : (t.iconColor ?? const Color(0xFF1E293B)),
                        size: t.icon == Icons.circle ? 7 : 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t.label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF334155),
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
