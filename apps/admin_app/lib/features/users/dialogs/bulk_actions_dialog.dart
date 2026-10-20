import 'package:flutter/material.dart';
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
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
                      color: const Color(0xFF5636F5).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.tune_rounded, color: Color(0xFF5636F5), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bulk Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101A3A),
                          ),
                        ),
                        Text(
                          '$selectedCount users currently selected',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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
              const SizedBox(height: 20),

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
              const SizedBox(height: 10),

              // Action 2: Change Status
              _buildActionTile(
                icon: Icons.toggle_on_outlined,
                iconColor: const Color(0xFF10B981),
                title: 'Change Account Status',
                subtitle: 'Activate, deactivate, or block selected accounts',
                onTap: () {
                  Navigator.of(context).pop();
                  _showStatusSelection(context);
                },
              ),
              const SizedBox(height: 10),

              // Action 3: Export Selected
              _buildActionTile(
                icon: Icons.file_download_outlined,
                iconColor: const Color(0xFF0284C7),
                title: 'Export Selected Users',
                subtitle: 'Download selected $selectedCount records as CSV/JSON',
                onTap: () {
                  Navigator.of(context).pop();
                  onExportSelected();
                },
              ),
              const SizedBox(height: 10),

              // Action 4: Delete Selected
              _buildActionTile(
                icon: Icons.delete_outline_rounded,
                iconColor: const Color(0xFFF43F5E),
                title: 'Delete Selected Accounts',
                subtitle: 'Permanently remove selected user records',
                isDestructive: true,
                onTap: () {
                  Navigator.of(context).pop();
                  onDeleteSelected();
                },
              ),
              const SizedBox(height: 16),

              // Cancel
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                ),
              ),
            ],
          ),
        ),
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
          border: Border.all(color: isDestructive ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 18),
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDestructive ? const Color(0xFFFB7185) : const Color(0xFF64748B),
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
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Select New Role', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: UserRole.values.map((r) {
              return ListTile(
                dense: true,
                title: Text(r.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                leading: Container(width: 10, height: 10, decoration: BoxDecoration(color: r.color, shape: BoxShape.circle)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onChangeRole(r);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showStatusSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Select Account Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: UserStatus.values.map((s) {
              return ListTile(
                dense: true,
                title: Text(s.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                leading: Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onChangeStatus(s);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
