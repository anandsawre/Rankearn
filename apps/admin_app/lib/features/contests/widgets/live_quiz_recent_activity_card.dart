import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class LiveQuizActivityItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String timeAgo;

  const LiveQuizActivityItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.timeAgo,
  });
}

/// Recent Activity Card
/// Displays live quiz events with accurate icons and time labels matching the reference image.
class LiveQuizRecentActivityCard extends StatelessWidget {
  final VoidCallback? onViewAll;
  final List<LiveQuizActivityItem> activities;

  const LiveQuizRecentActivityCard({
    super.key,
    this.onViewAll,
    this.activities = const [
      LiveQuizActivityItem(
        icon: Icons.play_arrow_rounded,
        iconColor: Color(0xFF10B981),
        iconBgColor: Color(0xFFDCFCE7),
        title: 'Live quiz started: Current Affairs Live Quiz',
        timeAgo: '10 minutes ago',
      ),
      LiveQuizActivityItem(
        icon: Icons.people_alt_rounded,
        iconColor: Color(0xFF2587F8),
        iconBgColor: Color(0xFFEFF6FF),
        title: '500 new participants joined',
        timeAgo: '25 minutes ago',
      ),
      LiveQuizActivityItem(
        icon: Icons.emoji_events_rounded,
        iconColor: Color(0xFFFF9F0A),
        iconBgColor: Color(0xFFFFFBEB),
        title: 'Live quiz completed: General Science',
        timeAgo: '1 hour ago',
      ),
      LiveQuizActivityItem(
        icon: Icons.edit_note_rounded,
        iconColor: Color(0xFF6C5CE7),
        iconBgColor: Color(0xFFF3F0FF),
        title: 'Quiz updated: RRB Technician Mega Quiz',
        timeAgo: '2 hours ago',
      ),
      LiveQuizActivityItem(
        icon: Icons.calendar_today_rounded,
        iconColor: Color(0xFFF04483),
        iconBgColor: Color(0xFFFFF1F2),
        title: 'New quiz scheduled: Maths Challenge',
        timeAgo: '3 hours ago',
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Icon + Title + "View All"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5636F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.feed_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: onViewAll,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5636F5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Activity Items List
          Column(
            children: activities.map((item) => _buildItem(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(LiveQuizActivityItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Circle
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: item.iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 12, color: item.iconColor),
          ),
          const SizedBox(width: 8),

          // Title & Time
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
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
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
