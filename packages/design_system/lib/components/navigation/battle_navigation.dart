import 'package:flutter/material.dart';
import 'app_segmented_filter_nav.dart';

enum BattleNavTab { oneVOne, twoPlayers, customRoom, history }

/// Segmented tab navigation for the 1v1 Battle Tab
/// (1v1 Battle, 2 Players, Custom Room, History)
class BattleNavigationTabs extends StatelessWidget {
  final BattleNavTab selectedTab;
  final ValueChanged<BattleNavTab> onTabSelected;

  const BattleNavigationTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppSegmentedFilterNav<BattleNavTab>(
      selectedValue: selectedTab,
      onSelect: onTabSelected,
      style: AppFilterNavStyle.chipPills,
      activeColor: const Color(0xFF10B981),
      activeTextColor: Colors.white,
      inactiveTextColor: const Color(0xFF111A4B),
      items: const [
        AppFilterNavItem<BattleNavTab>(
          value: BattleNavTab.oneVOne,
          label: '1v1 Battle',
          icon: Icons.sports_esports_rounded,
        ),
        AppFilterNavItem<BattleNavTab>(
          value: BattleNavTab.twoPlayers,
          label: '2 Players',
          icon: Icons.groups_rounded,
        ),
        AppFilterNavItem<BattleNavTab>(
          value: BattleNavTab.customRoom,
          label: 'Custom Room',
          icon: Icons.meeting_room_rounded,
        ),
        AppFilterNavItem<BattleNavTab>(
          value: BattleNavTab.history,
          label: 'History',
          icon: Icons.history_rounded,
        ),
      ],
    );
  }
}
