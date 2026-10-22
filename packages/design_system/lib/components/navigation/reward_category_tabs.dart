import 'package:flutter/material.dart';
import 'app_segmented_filter_nav.dart';

/// Filter categories for the Rewards Tab
enum RewardCategoryTab {
  all('All Tasks'),
  daily('Daily Tasks'),
  weekly('Weekly Tasks'),
  special('Special Tasks'),
  achievements('Achievements');

  final String label;
  const RewardCategoryTab(this.label);
}

/// Segmented tab navigation for the Rewards Tab
/// (All Tasks, Daily Tasks, Weekly Tasks, Special Tasks, Achievements)
class RewardCategoryTabs extends StatelessWidget {
  final RewardCategoryTab selectedTab;
  final ValueChanged<RewardCategoryTab> onTabSelected;

  const RewardCategoryTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppSegmentedFilterNav<RewardCategoryTab>(
      selectedValue: selectedTab,
      onSelect: onTabSelected,
      style: AppFilterNavStyle.chipPills,
      activeColor: const Color(0xFF10B981), // Emerald green
      activeTextColor: Colors.white,
      inactiveTextColor: const Color(0xFF111A4B),
      items: const [
        AppFilterNavItem<RewardCategoryTab>(
          value: RewardCategoryTab.all,
          label: 'All Tasks',
          icon: Icons.grid_view_rounded,
        ),
        AppFilterNavItem<RewardCategoryTab>(
          value: RewardCategoryTab.daily,
          label: 'Daily Tasks',
          icon: Icons.calendar_today_rounded,
        ),
        AppFilterNavItem<RewardCategoryTab>(
          value: RewardCategoryTab.weekly,
          label: 'Weekly Tasks',
          icon: Icons.star_border_rounded,
        ),
        AppFilterNavItem<RewardCategoryTab>(
          value: RewardCategoryTab.special,
          label: 'Special Tasks',
          icon: Icons.workspace_premium_rounded,
        ),
        AppFilterNavItem<RewardCategoryTab>(
          value: RewardCategoryTab.achievements,
          label: 'Achievements',
          icon: Icons.emoji_events_outlined,
        ),
      ],
    );
  }
}
