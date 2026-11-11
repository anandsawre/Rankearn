import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class ActivityItemData {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String text;
  final String timeAgo;

  const ActivityItemData({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.text,
    required this.timeAgo,
  });
}

/// Recent Activity Card
/// Displays real-time operational feeds and recent changes with timestamps.
class RecentActivityCard extends StatelessWidget {
  final double? height;
  final bool fillHeight;
  final VoidCallback? onViewAll;
  final List<ActivityItemData> activities;
  final bool isLoading;

  const RecentActivityCard({
    super.key,
    this.height,
    this.fillHeight = false,
    this.onViewAll,
    this.activities = const [],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final activityList = (isLoading && activities.isEmpty)
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
                ),
              ),
            ),
          )
        : activities.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No recent activity recorded',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: activities.map((item) => _buildActivityRow(item)).toList(),
              );

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: (height != null || fillHeight) ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Header: Icon + Title + View All
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontFamily: AppTypography.fontHeading,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onViewAll != null) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: onViewAll,
                  child: Text(
                    'Refresh',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // 5 Activity Items
          if (height != null || fillHeight)
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: activityList,
              ),
            )
          else
            activityList,
        ],
      ),
    );
  }

  Widget _buildActivityRow(ActivityItemData item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: item.iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, color: item.iconColor, size: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.text,
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            item.timeAgo,
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
