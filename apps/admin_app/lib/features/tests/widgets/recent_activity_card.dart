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

  const RecentActivityCard({
    super.key,
    this.height,
    this.fillHeight = false,
    this.onViewAll,
    this.activities = const [
      ActivityItemData(
        icon: Icons.description_outlined,
        iconColor: Color(0xFF0284C7),
        iconBgColor: Color(0xFFE0F2FE),
        text: 'New test series created: RRB Technician',
        timeAgo: '2 minutes ago',
      ),
      ActivityItemData(
        icon: Icons.check_circle_rounded,
        iconColor: Color(0xFF10B981),
        iconBgColor: Color(0xFFDCFCE7),
        text: 'Test series published: Maths Practice',
        timeAgo: '15 minutes ago',
      ),
      ActivityItemData(
        icon: Icons.edit_rounded,
        iconColor: Color(0xFFF43F5E),
        iconBgColor: Color(0xFFFFE4E6),
        text: 'Test series updated: Reasoning Special',
        timeAgo: '1 hour ago',
      ),
      ActivityItemData(
        icon: Icons.people_alt_rounded,
        iconColor: Color(0xFF8B5CF6),
        iconBgColor: Color(0xFFEDE9FE),
        text: 'New enrollment: 5 users',
        timeAgo: '2 hours ago',
      ),
      ActivityItemData(
        icon: Icons.emoji_events_rounded,
        iconColor: Color(0xFFF59E0B),
        iconBgColor: Color(0xFFFEF3C7),
        text: 'Test series completed: Current Affairs',
        timeAgo: '3 hours ago',
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    final activityList = Column(
      mainAxisSize: MainAxisSize.min,
      children: activities.map((item) => _buildActivityRow(item)).toList(),
    );

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFF101A3A),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 13,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: onViewAll ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Viewing complete audit activity history.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5636F5),
                  ),
                ),
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: item.iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, color: item.iconColor, size: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.text,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            item.timeAgo,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
