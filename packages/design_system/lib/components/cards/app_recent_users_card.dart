import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/typography.dart';

/// Data model representing a single user item in [AppRecentUsersCard].
class RecentUserItem {
  final String initials;
  final String name;
  final String email;
  final String date;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const RecentUserItem({
    required this.initials,
    required this.name,
    required this.email,
    required this.date,
    required this.color,
    this.onTap,
    this.onMoreTap,
  });
}

/// Centralized, theme-tokenized Recent Users Card component.
///
/// Features:
/// - Header with icon, title, and "View All" link
/// - User rows with initials avatar, full name, email, registration date, and options menu
/// - Design token support (`AppColors`, `AppTypography`, `AppRadii`, `AppShadows`)
class AppRecentUsersCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<RecentUserItem> users;
  final VoidCallback? onViewAll;
  final String viewAllText;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final String emptyText;

  const AppRecentUsersCard({
    super.key,
    this.title = 'Recent Users',
    this.icon = Icons.people_alt_rounded,
    this.iconColor = const Color(0xFF3B82F6),
    this.users = const [],
    this.onViewAll,
    this.viewAllText = 'View All',
    this.height = 300,
    this.padding,
    this.isLoading = false,
    this.emptyText = 'No registered users yet',
  });

  @override
  Widget build(BuildContext context) {
    final isExpandedMode = height != null;

    Widget body;
    if (isLoading && users.isEmpty) {
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
    } else if (users.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_outline_rounded, size: 28, color: AppColors.textMuted),
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
        children: users.map((user) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              onTap: user.onTap,
              borderRadius: AppRadii.borderSm,
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: user.color,
                    child: Text(
                      user.initials,
                      style: TextStyle(
                        fontFamily: AppTypography.fontHeading,
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Name & Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontFamily: AppTypography.fontHeading,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontFamily: AppTypography.fontHeading,
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Date
                  Text(
                    user.date,
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (user.onMoreTap != null) ...[
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: user.onMoreTap,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.more_vert, size: 16, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
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
                    Icon(icon, color: iconColor, size: 19),
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
