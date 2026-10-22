import 'package:flutter/material.dart';
import 'app_segmented_filter_nav.dart';

/// TestTypeNavigation for switching test filters in the Tests Tab.
/// Powered by the unified [AppSegmentedFilterNav] core engine.
class TestTypeNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final List<({IconData icon, String label})> items;

  const TestTypeNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.items = const [
      (icon: Icons.grid_view_rounded, label: 'All Tests'),
      (icon: Icons.local_fire_department_rounded, label: 'Daily Test'),
      (icon: Icons.description_outlined, label: 'Mock Tests'),
      (icon: Icons.menu_book_rounded, label: 'Previous Year'),
      (icon: Icons.layers_rounded, label: 'Chapter Wise'),
      (icon: Icons.bookmark_border_rounded, label: 'My Tests'),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return AppSegmentedFilterNav<int>(
      selectedValue: selectedIndex,
      onSelect: onSelect,
      style: AppFilterNavStyle.segmentedTrack,
      items: [
        for (int i = 0; i < items.length; i++)
          AppFilterNavItem<int>(
            value: i,
            label: items[i].label,
            icon: items[i].icon,
          ),
      ],
    );
  }
}
