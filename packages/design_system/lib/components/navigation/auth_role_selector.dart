import 'package:flutter/material.dart';
import '../../tokens/typography.dart';

enum AuthUserRole { student, teacher }

/// Rankearn Accessible Role Segmented Control (Student vs Teacher)
class AuthRoleSelector extends StatelessWidget {
  final AuthUserRole selectedRole;
  final ValueChanged<AuthUserRole> onRoleChanged;
  final String studentLabel;
  final String teacherLabel;

  const AuthRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    this.studentLabel = 'Student Login',
    this.teacherLabel = 'Teacher Login',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF1F5F9,
        ), // Light neutral background matching reference
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleTab(
              role: AuthUserRole.student,
              label: studentLabel,
              icon: Icons.school_rounded,
              isSelected: selectedRole == AuthUserRole.student,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildRoleTab(
              role: AuthUserRole.teacher,
              label: teacherLabel,
              icon: Icons.assignment_ind_rounded,
              isSelected: selectedRole == AuthUserRole.teacher,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTab({
    required AuthUserRole role,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onRoleChanged(role),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE4FFF0) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF86EFAC) : Colors.transparent,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF00B96B).withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? const Color(0xFF008C52)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.labelLarge.copyWith(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF008C52)
                        : const Color(0xFF64748B),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
