import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class UsersRecentActivityCard extends StatelessWidget {
  final bool fillHeight;
  final VoidCallback? onViewAll;

  const UsersRecentActivityCard({
    super.key,
    this.fillHeight = false,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final activities = [
      const _UserActivityData(
        icon: Icons.check_circle_rounded,
        iconColor: Color(0xFF10B981),
        bgColor: Color(0xFFECFDF5),
        prefix: 'New user registered: ',
        userName: 'Rahul Sharma',
        time: '5 minutes ago',
      ),
      const _UserActivityData(
        icon: Icons.workspace_premium_rounded,
        iconColor: Color(0xFFF59E0B),
        bgColor: Color(0xFFFFFBEB),
        prefix: 'User upgraded to premium: ',
        userName: 'Priya Verma',
        time: '1 hour ago',
      ),
      const _UserActivityData(
        icon: Icons.assignment_turned_in_rounded,
        iconColor: Color(0xFF2587F8),
        bgColor: Color(0xFFEFF6FF),
        prefix: 'User completed test: ',
        userName: 'Amit Kumar',
        time: '2 hours ago',
      ),
      const _UserActivityData(
        icon: Icons.manage_accounts_rounded,
        iconColor: Color(0xFF3B82F6),
        bgColor: Color(0xFFEFF6FF),
        prefix: 'User profile updated: ',
        userName: 'Neha Singh',
        time: '3 hours ago',
      ),
      const _UserActivityData(
        icon: Icons.block_rounded,
        iconColor: Color(0xFFF43F5E),
        bgColor: Color(0xFFFFF1F2),
        prefix: 'User account blocked: ',
        userName: 'Saurabh Gupta',
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
                        color: Color(0xFF6B4EFF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.history_rounded, color: Colors.white, size: 14),
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
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          text: item.prefix,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF334155),
                          ),
                          children: [
                            TextSpan(
                              text: item.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
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
    return SizedBox(height: 175, child: content);
  }
}

class _UserActivityData {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String prefix;
  final String userName;
  final String time;

  const _UserActivityData({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.prefix,
    required this.userName,
    required this.time,
  });
}
