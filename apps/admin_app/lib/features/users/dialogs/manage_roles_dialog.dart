import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/user_management_item.dart';

class ManageRolesDialog extends StatelessWidget {
  const ManageRolesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    const roles = [
      _RolePermission(
        role: UserRole.student,
        description: 'Standard learner access: enroll in public tests, view personal scorecards & leaderboard rankings.',
        permissions: ['Take Public Tests', 'View Personal Analytics', 'Join Live Quizzes', 'Earn Badges & Coins'],
        badgeColor: Color(0xFF0284C7),
      ),
      _RolePermission(
        role: UserRole.premium,
        description: 'Subscribed member: unlimited access to all premium test series, detailed solution analytics & priority doubt resolution.',
        permissions: ['All Student Features', 'Unlock Premium Series', 'Deep AI Weakness Insights', 'No Ads & Priority Support'],
        badgeColor: Color(0xFF7C3AED),
      ),
      _RolePermission(
        role: UserRole.teacher,
        description: 'Instructor access: create questions, author mock test papers, and evaluate subjective test submissions.',
        permissions: ['Create & Edit Questions', 'Author Test Series', 'View Aggregate Class Analytics', 'Manage Subject Notes'],
        badgeColor: Color(0xFFF59E0B),
      ),
      _RolePermission(
        role: UserRole.moderator,
        description: 'Platform community moderator: review reported questions, monitor live quiz chat, and inspect flagged attempts.',
        permissions: ['Review Flagged Items', 'Moderate Quiz Comments', 'Temporary Suspension', 'View Audit Logs'],
        badgeColor: Color(0xFF10B981),
      ),
      _RolePermission(
        role: UserRole.admin,
        description: 'Full administrative governance: manage platform settings, role assignments, billing, and system migrations.',
        permissions: ['All System Permissions', 'Role & User Management', 'Billing & Payouts', 'Schema & System Config'],
        badgeColor: Color(0xFFEC4899),
      ),
    ];

    return AppModalDialog(
      title: 'Roles & Permissions Matrix',
      subtitle: '5 access tiers governing student, instructor & administrative access',
      iconData: Icons.shield_outlined,
      gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
      maxWidth: 680,
      scrollable: true,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
            elevation: 0,
          ),
          child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ],
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: roles.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final item = roles[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.role.bgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.role.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: item.role.color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${item.permissions.length} active permissions',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.3),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: item.permissions.map((p) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded, size: 11, color: Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          Text(p, style: const TextStyle(fontSize: 10, color: Color(0xFF334155))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RolePermission {
  final UserRole role;
  final String description;
  final List<String> permissions;
  final Color badgeColor;

  const _RolePermission({
    required this.role,
    required this.description,
    required this.permissions,
    required this.badgeColor,
  });
}
