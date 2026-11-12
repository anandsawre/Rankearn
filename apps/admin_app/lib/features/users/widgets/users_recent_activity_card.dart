import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class UserActivityData {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String prefix;
  final String userName;
  final String time;

  const UserActivityData({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.prefix,
    required this.userName,
    required this.time,
  });
}

class UsersRecentActivityCard extends StatelessWidget {
  final bool fillHeight;
  final VoidCallback? onViewAll;
  final List<UserActivityData> activities;
  final bool isLoading;

  const UsersRecentActivityCard({
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
          'No recent user activity',
          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
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
                    width: 22,
                    height: 22,
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
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF1E293B),
                          fontFamily: 'Inter',
                        ),
                        children: [
                          TextSpan(
                            text: item.prefix,
                            style: const TextStyle(fontWeight: FontWeight.w400),
                          ),
                          TextSpan(
                            text: item.userName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
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

    if (fillHeight) {
      return Expanded(child: content);
    }
    return SizedBox(height: 175, child: content);
  }
}
