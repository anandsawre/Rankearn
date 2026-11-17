import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Category Filter Chips Tokenized with Centralized Design System
class TournamentFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final int totalCount;

  const TournamentFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('all', 'All', null),
      ('running', 'Running', Icons.circle),
      ('upcoming', 'Upcoming', Icons.calendar_today_rounded),
      ('completed', 'Completed', Icons.check_rounded),
      ('free', 'Free Entry', Icons.confirmation_number_outlined),
      ('paid', 'Paid Entry', Icons.monetization_on_outlined),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = selectedFilter == f.$1;
          final isRunning = f.$1 == 'running';

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: InkWell(
              onTap: () => onFilterChanged(f.$1),
              borderRadius: AppRadii.borderPill,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.contestActiveGreen
                      : AppColors.contestCardBg,
                  borderRadius: AppRadii.borderPill,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.contestActiveGreen
                        : AppColors.contestCardBorder,
                  ),
                  boxShadow: isSelected ? AppShadows.contestPillActive : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isRunning) ...[
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : AppColors.contestBadgeRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ] else if (f.$3 != null) ...[
                      Icon(
                        f.$3,
                        size: 13,
                        color: isSelected
                            ? Colors.white
                            : AppColors.contestTextSecondary,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      f.$2,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
