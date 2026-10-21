import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class TournamentActivityItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String timeAgo;

  const TournamentActivityItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.timeAgo,
  });
}

/// Recent Activity Card
/// Displays tournament events with accurate icons and time labels matching the reference image.
class TournamentsRecentActivityCard extends StatelessWidget {
  final VoidCallback? onViewAll;
  final List<TournamentActivityItem> activities;

  const TournamentsRecentActivityCard({
    super.key,
    this.onViewAll,
    this.activities = const [
      TournamentActivityItem(
        icon: Icons.emoji_events_rounded,
        iconColor: Color(0xFF6B4EFF),
        iconBgColor: Color(0xFFF3F0FF),
        title: 'New tournament created: RRB Technician',
        timeAgo: '10 minutes ago',
      ),
      TournamentActivityItem(
        icon: Icons.people_alt_rounded,
        iconColor: Color(0xFF2587F8),
        iconBgColor: Color(0xFFEFF6FF),
        title: '500 new participants joined',
        timeAgo: '25 minutes ago',
      ),
      TournamentActivityItem(
        icon: Icons.check_circle_rounded,
        iconColor: Color(0xFFFF9F0A),
        iconBgColor: Color(0xFFFFFBEB),
        title: 'Tournament completed: Maths Master',
        timeAgo: '1 hour ago',
      ),
      TournamentActivityItem(
        icon: Icons.edit_note_rounded,
        iconColor: Color(0xFF6C5CE7),
        iconBgColor: Color(0xFFF3F0FF),
        title: 'Tournament updated: General Science',
        timeAgo: '3 hours ago',
      ),
      TournamentActivityItem(
        icon: Icons.archive_outlined,
        iconColor: Color(0xFFF04483),
        iconBgColor: Color(0xFFFFF1F2),
        title: 'Tournament archived: Biology Battle',
        timeAgo: '5 hours ago',
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
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
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
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Activity Items List
          Column(
            children: activities.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.5),
                child: Row(
                  children: [
                    // Icon Box
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: item.iconBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        item.icon,
                        color: item.iconColor,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Title
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Time Ago
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
            }).toList(),
          ),
        ],
      ),
    );
  }
}
