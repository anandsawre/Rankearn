import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

/// TestTypeNavigation for switching test filters in the Tests Tab
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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EAF7), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              _buildTabItem(i),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index) {
    final isSelected = selectedIndex == index;
    final item = items[index];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelect(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF10B981).withAlpha(80),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 17,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
