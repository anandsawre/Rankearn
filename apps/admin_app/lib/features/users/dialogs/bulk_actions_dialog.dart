import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/user_management_item.dart';

class BulkActionsDialog extends StatelessWidget {
  final int selectedCount;
  final ValueChanged<UserRole> onChangeRole;
  final ValueChanged<UserStatus> onChangeStatus;
  final VoidCallback onExportSelected;
  final VoidCallback onDeleteSelected;

  const BulkActionsDialog({
    super.key,
    required this.selectedCount,
    required this.onChangeRole,
    required this.onChangeStatus,
    required this.onExportSelected,
    required this.onDeleteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Bulk Actions',
      subtitle: '$selectedCount users currently selected for batch update',
      iconData: Icons.tune_rounded,
      gradientColors: const [Color(0xFF5636F5), Color(0xFF2587F8)],
      maxWidth: 480,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Action 1: Change Role
          _buildActionTile(
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFF6B4EFF),
            title: 'Change User Role',
            subtitle: 'Update role for all $selectedCount users',
            onTap: () {
              Navigator.of(context).pop();
              _showRoleSelection(context);
            },
          ),
          const SizedBox(height: 8),

          // Action 2: Change Status
          _buildActionTile(
            icon: Icons.toggle_on_outlined,
            iconColor: const Color(0xFF00B368),
            title: 'Update Account Status',
            subtitle: 'Activate, deactivate, or suspend accounts',
            onTap: () {
              Navigator.of(context).pop();
              _showStatusSelection(context);
            },
          ),
          const SizedBox(height: 8),

          // Action 3: Export
          _buildActionTile(
            icon: Icons.file_download_outlined,
            iconColor: const Color(0xFF0284C7),
            title: 'Export Selected Records',
            subtitle: 'Download $selectedCount rows as CSV / Excel',
            onTap: () {
              Navigator.of(context).pop();
              onExportSelected();
            },
          ),
          const SizedBox(height: 8),

          // Action 4: Delete
          _buildActionTile(
            icon: Icons.delete_outline_rounded,
            iconColor: const Color(0xFFE11D48),
            title: 'Delete Selected Users',
            subtitle: 'Permanently remove selected user accounts',
            isDestructive: true,
            onTap: () {
              Navigator.of(context).pop();
              _confirmDelete(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDestructive ? const Color(0xFFFECDD3) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDestructive ? const Color(0xFFE11D48) : const Color(0xFF101A3A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDestructive ? const Color(0xFFFDA4AF) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: isDestructive ? const Color(0xFFE11D48) : const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  void _showRoleSelection(BuildContext context) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) {
        return AppModalDialog(
          title: 'Select New Role',
          subtitle: 'Apply role to all $selectedCount selected users',
          iconData: Icons.shield_outlined,
          gradientColors: const [Color(0xFF5636F5), Color(0xFF2587F8)],
          maxWidth: 420,
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: UserRole.values.map((r) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: ListTile(
                  dense: true,
                  title: Text(r.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  leading: Container(width: 10, height: 10, decoration: BoxDecoration(color: r.color, shape: BoxShape.circle)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onChangeRole(r);
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showStatusSelection(BuildContext context) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) {
        return AppModalDialog(
          title: 'Select Account Status',
          subtitle: 'Apply status to all $selectedCount selected users',
          iconData: Icons.toggle_on_outlined,
          gradientColors: const [Color(0xFF00B368), Color(0xFF10B981)],
          maxWidth: 420,
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: UserStatus.values.map((s) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: ListTile(
                  dense: true,
                  title: Text(s.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  leading: Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onChangeStatus(s);
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => AppModalDialog(
        title: 'Delete Selected Users',
        subtitle: 'Destructive deletion warning',
        iconData: Icons.delete_outline_rounded,
        gradientColors: const [Color(0xFFDC2626), Color(0xFFEF4444)],
        maxWidth: 420,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onDeleteSelected();
            },
            child: const Text('Delete Users', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Are you sure you want to permanently delete $selectedCount selected users? This action cannot be undone.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
          ),
        ),
      ),
    );
  }
}
