import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class CategoryRecentActivityCard extends StatelessWidget {
  final bool fillHeight;
  final VoidCallback? onViewAll;

  const CategoryRecentActivityCard({
    super.key,
    this.fillHeight = false,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final activities = [
      const _ActivityData(
        icon: Icons.check_circle_rounded,
        iconColor: Color(0xFF10B981),
        bgColor: Color(0xFFECFDF5),
        title: 'New category created: Skill Development',
        time: '10 minutes ago',
      ),
      const _ActivityData(
        icon: Icons.edit_note_rounded,
        iconColor: Color(0xFFF59E0B),
        bgColor: Color(0xFFFFFBEB),
        title: 'Category updated: General Awareness',
        time: '1 hour ago',
      ),
      const _ActivityData(
        icon: Icons.bookmark_add_rounded,
        iconColor: Color(0xFF0084FF),
        bgColor: Color(0xFFEFF6FF),
        title: 'Subject added to Competitive Exams',
        time: '3 hours ago',
      ),
      const _ActivityData(
        icon: Icons.archive_rounded,
        iconColor: Color(0xFFF43F5E),
        bgColor: Color(0xFFFFF1F2),
        title: 'Category archived: Practice & Mock Tests',
        time: '5 hours ago',
      ),
    ];

    final content = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B5CF6),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.description_rounded, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101A3A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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

          // Activity Items
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: activities.map((item) {
                return Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: item.bgColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(item.icon, color: item.iconColor, size: 13),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.time,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );

    if (fillHeight) return content;
    return SizedBox(height: 155, child: content);
  }
}

class _ActivityData {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String time;

  const _ActivityData({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.time,
  });
}
