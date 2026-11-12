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
class AiTestRecentActivityCard extends StatelessWidget {
  final VoidCallback? onViewAll;
  final List<AiTestActivityItem> activities;
  final bool isLoading;

  const AiTestRecentActivityCard({
    super.key,
    this.onViewAll,
    this.activities = const [],
    this.isLoading = false,
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
                child: const Icon(Icons.history_rounded, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101A3A),
                  ),
                ),
              ),
              if (onViewAll != null)
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
          const SizedBox(height: 12),
          if (isLoading && activities.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No AI test activity recorded yet',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
            )
          else
            ...activities.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: item.iconBgColor,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      alignment: Alignment.center,
                      child: Icon(item.icon, color: item.iconColor, size: 14),
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
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            item.time,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
