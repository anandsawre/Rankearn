import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class CategoryActivityData {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String time;

  const CategoryActivityData({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.time,
  });
}

class CategoryRecentActivityCard extends StatelessWidget {
  final bool fillHeight;
  final VoidCallback? onViewAll;
  final List<CategoryActivityData> activities;
  final bool isLoading;

  const CategoryRecentActivityCard({
    super.key,
    this.fillHeight = false,
    this.onViewAll,
    this.activities = const [],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (isLoading && activities.isEmpty) {
      body = const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      );
    } else if (activities.isEmpty) {
      body = const Center(
        child: Text(
          'No recent exam activity',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
      );
    } else {
      body = SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: activities.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
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
              ),
            );
          }).toList(),
        ),
      );
    }

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
              if (onViewAll != null) ...[
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
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: body),
        ],
      ),
    );

    if (fillHeight) return content;
    return SizedBox(height: 165, child: content);
  }
}
