import 'package:flutter/material.dart';
import 'app_segmented_filter_nav.dart';

enum LiveTestFilterTab {
  allLiveTests,
  upcoming,
  liveNow,
  myParticipations,
  leaderboards,
}

/// LiveTestNavigation tabs matching the Rankearn Live Tests reference screenshot.
/// Powered by the unified [AppSegmentedFilterNav] core engine.
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
    return AppSegmentedFilterNav<LiveTestFilterTab>(
      selectedValue: selectedTab,
      onSelect: onTabSelected,
      style: AppFilterNavStyle.chipPills,
      items: const [
        AppFilterNavItem<LiveTestFilterTab>(
          value: LiveTestFilterTab.allLiveTests,
          label: 'Live Tests',
          icon: Icons.sensors_rounded,
        ),
        AppFilterNavItem<LiveTestFilterTab>(
          value: LiveTestFilterTab.upcoming,
          label: 'Upcoming',
          icon: Icons.calendar_month_outlined,
        ),
        AppFilterNavItem<LiveTestFilterTab>(
          value: LiveTestFilterTab.liveNow,
          label: 'Live Now',
          icon: Icons.circle,
          iconColor: Color(0xFFF43F5E),
        ),
        AppFilterNavItem<LiveTestFilterTab>(
          value: LiveTestFilterTab.myParticipations,
          label: 'My Participations',
          icon: Icons.assignment_outlined,
        ),
        AppFilterNavItem<LiveTestFilterTab>(
          value: LiveTestFilterTab.leaderboards,
          label: 'Leaderboards',
          icon: Icons.emoji_events_outlined,
        ),
      ],
    );
  }
}
