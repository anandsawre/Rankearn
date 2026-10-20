import 'package:flutter/material.dart';
import '../models/user_management_item.dart';

class ManageRolesDialog extends StatelessWidget {
  const ManageRolesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = [
      _RolePermission(
        role: UserRole.student,
        description: 'Standard learner access: enroll in public tests, view personal scorecards & leaderboard rankings.',
        permissions: ['Take Public Tests', 'View Personal Analytics', 'Join Live Quizzes', 'Earn Badges & Coins'],
        badgeColor: const Color(0xFF0284C7),
      ),
      _RolePermission(
        role: UserRole.premium,
        description: 'Subscribed member: unlimited access to all premium test series, detailed solution analytics & priority doubt resolution.',
        permissions: ['All Student Features', 'Unlock Premium Series', 'Deep AI Weakness Insights', 'No Ads & Priority Support'],
        badgeColor: const Color(0xFF7C3AED),
      ),
      _RolePermission(
        role: UserRole.teacher,
        description: 'Instructor access: create questions, author mock test papers, and evaluate subjective test submissions.',
        permissions: ['Create & Edit Questions', 'Author Test Series', 'View Aggregate Class Analytics', 'Manage Subject Notes'],
        badgeColor: const Color(0xFFF59E0B),
      ),
      _RolePermission(
        role: UserRole.moderator,
        description: 'Platform community moderator: review reported questions, monitor live quiz chat, and inspect flagged attempts.',
        permissions: ['Review Flagged Items', 'Moderate Quiz Comments', 'Temporary Suspension', 'View Audit Logs'],
        badgeColor: const Color(0xFF10B981),
      ),
      _RolePermission(
        role: UserRole.admin,
        description: 'Full administrative governance: manage platform settings, role assignments, billing, and system migrations.',
        permissions: ['All System Permissions', 'Role & User Management', 'Billing & Payouts', 'Schema & System Config'],
        badgeColor: const Color(0xFFEC4899),
      ),
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Roles & Permissions Matrix',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101A3A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'RBAC hierarchy and permissions enforced by Supabase Row Level Security',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Roles List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: roles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final item = roles[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
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
              ),
              const SizedBox(height: 18),

              // Close
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5636F5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
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
