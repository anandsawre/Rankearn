import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/typography.dart';

/// Data model representing a single activity log item in [AppRecentActivityCard].
class RecentActivityItem {
  final IconData icon;
  final Color color;
  final String title;
  final String time;
  final VoidCallback? onTap;

  const RecentActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.time,
    this.onTap,
  });
}

/// Centralized, theme-tokenized Recent Activity Feed Card component.
///
/// Features:
/// - Header with shield icon, title, and "View All" link
/// - Activity items with colored action icons, description title, and relative timestamp
/// - Design token support (`AppColors`, `AppTypography`, `AppRadii`, `AppShadows`)
class AppRecentActivityCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<RecentActivityItem> activities;
  final VoidCallback? onViewAll;
  final String viewAllText;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final String emptyText;

  const AppRecentActivityCard({
    super.key,
    this.title = 'Recent Activity',
    this.icon = Icons.shield_outlined,
    this.iconColor = const Color(0xFFEF4444),
    this.activities = const [],
    this.onViewAll,
    this.viewAllText = 'View All',
    this.height = 300,
    this.padding,
    this.isLoading = false,
    this.emptyText = 'No recent platform activity',
  });

  @override
  Widget build(BuildContext context) {
    final isExpandedMode = height != null;

    Widget body;
    if (isLoading && activities.isEmpty) {
      body = const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
          ),
        ),
      );
    } else if (activities.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_rounded, size: 28, color: AppColors.textMuted),
              const SizedBox(height: 8),
              Text(
                emptyText,
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      final listColumn = Column(
        mainAxisSize: MainAxisSize.min,
        children: activities.map((act) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              onTap: act.onTap,
              borderRadius: AppRadii.borderSm,
              child: Row(
                children: [
                  Icon(act.icon, color: act.color, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      act.title,
                      style: TextStyle(
                        fontFamily: AppTypography.fontHeading,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    act.time,
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );

      body = isExpandedMode
          ? SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: listColumn,
            )
          : listColumn;
    }

    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: isExpandedMode ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, color: iconColor, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (onViewAll != null) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: onViewAll,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      viewAllText,
                      style: TextStyle(
                        fontFamily: AppTypography.fontHeading,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          if (isExpandedMode) Expanded(child: body) else body,
        ],
      ),
    );
  }
}
