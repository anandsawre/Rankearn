import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/leaderboard_model.dart';

/// Reusable Leaderboard Filter Tabs
/// Adapts between Desktop segmented pill row and Mobile compact period pills
/// Built strictly following the Rankearn centralized design system.
class LeaderboardFilterTabs extends StatelessWidget {
  final LeaderboardScope selectedScope;
  final LeaderboardPeriod selectedPeriod;
  final ValueChanged<LeaderboardScope> onScopeChanged;
  final ValueChanged<LeaderboardPeriod> onPeriodChanged;
  final bool isDesktop;

  const LeaderboardFilterTabs({
    super.key,
    required this.selectedScope,
    required this.selectedPeriod,
    required this.onScopeChanged,
    required this.onPeriodChanged,
    this.isDesktop = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopTabs();
    } else {
      return _buildMobilePills();
    }
  }

  /// Desktop Filter Bar: [Global, Friends, Weekly, Monthly, All Time]
  Widget _buildDesktopTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // 1. Global Tab
          _buildDesktopTabButton(
            label: 'Global',
            icon: Icons.public_rounded,
            isSelected: selectedScope == LeaderboardScope.global,
            onTap: () => onScopeChanged(LeaderboardScope.global),
          ),
          const SizedBox(width: AppSpacing.md),

          // 2. Friends Tab
          _buildDesktopTabButton(
            label: 'Friends',
            icon: Icons.people_alt_rounded,
            isSelected: selectedScope == LeaderboardScope.friends,
            onTap: () => onScopeChanged(LeaderboardScope.friends),
          ),
          const SizedBox(width: AppSpacing.md),

          // 3. Weekly Tab
          _buildDesktopTabButton(
            label: 'Weekly',
            icon: Icons.calendar_today_rounded,
            isSelected: selectedPeriod == LeaderboardPeriod.weekly,
            onTap: () => onPeriodChanged(LeaderboardPeriod.weekly),
          ),
          const SizedBox(width: AppSpacing.md),

          // 4. Monthly Tab
          _buildDesktopTabButton(
            label: 'Monthly',
            icon: Icons.calendar_month_rounded,
            isSelected: selectedPeriod == LeaderboardPeriod.monthly,
            onTap: () => onPeriodChanged(LeaderboardPeriod.monthly),
          ),
          const SizedBox(width: AppSpacing.md),

          // 5. All Time Tab
          _buildDesktopTabButton(
            label: 'All Time',
            icon: Icons.workspace_premium_rounded,
            isSelected: selectedPeriod == LeaderboardPeriod.allTime,
            onTap: () => onPeriodChanged(LeaderboardPeriod.allTime),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.borderMd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.leaderboardGreen
              : Colors.transparent,
          borderRadius: AppRadii.borderMd,
          border: Border.all(
            color: isSelected
                ? AppColors.leaderboardGreen
                : AppColors.leaderboardBorder,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.leaderboardSubtle,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.leaderboardNavy,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontFamilyFallback: AppTypography.fontFallbacks,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mobile Pills Row: [All Time, This Week, This Month, Friends]
  Widget _buildMobilePills() {
    final pills = [
      (
        'All Time',
        selectedPeriod == LeaderboardPeriod.allTime &&
            selectedScope == LeaderboardScope.global,
        () {
          onScopeChanged(LeaderboardScope.global);
          onPeriodChanged(LeaderboardPeriod.allTime);
        },
      ),
      (
        'This Week',
        selectedPeriod == LeaderboardPeriod.weekly &&
            selectedScope == LeaderboardScope.global,
        () {
          onScopeChanged(LeaderboardScope.global);
          onPeriodChanged(LeaderboardPeriod.weekly);
        },
      ),
      (
        'This Month',
        selectedPeriod == LeaderboardPeriod.monthly &&
            selectedScope == LeaderboardScope.global,
        () {
          onScopeChanged(LeaderboardScope.global);
          onPeriodChanged(LeaderboardPeriod.monthly);
        },
      ),
      (
        'Friends',
        selectedScope == LeaderboardScope.friends,
        () {
          onScopeChanged(LeaderboardScope.friends);
        },
      ),
    ];

    return Row(
      children: [
        for (int i = 0; i < pills.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: InkWell(
              onTap: pills[i].$3,
              borderRadius: AppRadii.borderMd,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: pills[i].$2
                      ? AppColors.leaderboardGreen
                      : Colors.transparent,
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(
                    color: pills[i].$2
                        ? AppColors.leaderboardGreen
                        : AppColors.leaderboardBorder,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  pills[i].$1,
                  style: TextStyle(
                    color: pills[i].$2
                        ? Colors.white
                        : AppColors.leaderboardNavy,
                    fontSize: 12,
                    fontWeight:
                        pills[i].$2 ? FontWeight.w800 : FontWeight.w600,
                    fontFamilyFallback: AppTypography.fontFallbacks,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
