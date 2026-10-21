import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class UsersQuickActions extends StatelessWidget {
  final VoidCallback onAddUser;
  final VoidCallback onImportUsers;
  final VoidCallback onManageRoles;
  final VoidCallback onSendNotification;
  final VoidCallback onExportUsers;
  final VoidCallback onBulkActions;
  final VoidCallback? onCustomize;
  final double? height;

  const UsersQuickActions({
    super.key,
    required this.onAddUser,
    required this.onImportUsers,
    required this.onManageRoles,
    required this.onSendNotification,
    required this.onExportUsers,
    required this.onBulkActions,
    this.onCustomize,
    this.height = 124,
  });

  @override
  Widget build(BuildContext context) {
    return QuickActionsCard(
      onCustomize: onCustomize,
      height: height,
      compact: true,
      actions: [
        QuickActionItemData(
          label: 'Add\nUser',
          icon: Icons.person_add_rounded,
          iconColor: const Color(0xFF5636F5),
          cardColor: const Color(0xFFEDE9FE),
          onTap: onAddUser,
        ),
        QuickActionItemData(
          label: 'Import\nUsers',
          icon: Icons.file_upload_outlined,
          iconColor: const Color(0xFF0284C7),
          cardColor: const Color(0xFFDBEAFE),
          onTap: onImportUsers,
        ),
        QuickActionItemData(
          label: 'Manage\nRoles',
          icon: Icons.manage_accounts_outlined,
          iconColor: const Color(0xFF10B981),
          cardColor: const Color(0xFFD1FAE5),
          onTap: onManageRoles,
        ),
        QuickActionItemData(
          label: 'Send\nNotification',
          icon: Icons.mark_email_unread_outlined,
          iconColor: const Color(0xFFF59E0B),
          cardColor: const Color(0xFFFFFBEB),
          onTap: onSendNotification,
        ),
        QuickActionItemData(
          label: 'Export\nUsers',
          icon: Icons.file_download_outlined,
          iconColor: const Color(0xFFF43F5E),
          cardColor: const Color(0xFFFCE7F3),
          onTap: onExportUsers,
        ),
        QuickActionItemData(
          label: 'Bulk\nActions',
          icon: Icons.tune_rounded,
          iconColor: const Color(0xFFEC4899),
          cardColor: const Color(0xFFFDF2F8),
          onTap: onBulkActions,
        ),
      ],
    );
  }
}
