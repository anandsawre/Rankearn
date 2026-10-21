import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class AiTestActivityItem {
  final String title;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const AiTestActivityItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

/// Recent Activity Card for AI Test Creator
/// Displays 5 generation events with color-coded square icon badges matching the reference image.
class AiTestRecentActivityCard extends StatelessWidget {
  final VoidCallback? onViewAll;
  final List<AiTestActivityItem> activities;

  const AiTestRecentActivityCard({
    super.key,
    this.onViewAll,
    this.activities = const [
      AiTestActivityItem(
        title: 'New test generated: RRB Technician Mock',
        time: '2 minutes ago',
        icon: Icons.description_rounded,
        iconColor: Color(0xFF5636F5),
        iconBgColor: Color(0xFFEEF0FF),
      ),
      AiTestActivityItem(
        title: 'Test published: Railway Maths Practice',
        time: '15 minutes ago',
        icon: Icons.check_circle_rounded,
        iconColor: Color(0xFF10B981),
        iconBgColor: Color(0xFFECFDF5),
      ),
      AiTestActivityItem(
        title: 'Test updated: Reasoning Speed Test',
        time: '1 hour ago',
        icon: Icons.edit_note_rounded,
        iconColor: Color(0xFF2587F8),
        iconBgColor: Color(0xFFEFF6FF),
      ),
      AiTestActivityItem(
        title: 'Test deleted: Old Biology Test',
        time: '2 hours ago',
        icon: Icons.delete_outline_rounded,
        iconColor: Color(0xFFEF4444),
        iconBgColor: Color(0xFFFFF1F2),
      ),
      AiTestActivityItem(
        title: 'Test generated: Current Affairs Weekly',
        time: '3 hours ago',
        icon: Icons.auto_awesome_rounded,
        iconColor: Color(0xFF6366F1),
        iconBgColor: Color(0xFFEEF2FF),
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EAF7), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
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
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101A3A),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
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
          ...activities.map((item) => _buildActivityTile(item)),
        ],
      ),
    );
  }

  Widget _buildActivityTile(AiTestActivityItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              size: 15,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101A3A),
                    height: 1.25,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  item.time,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
