import 'package:flutter/material.dart';

class UsersQuickActions extends StatelessWidget {
  final VoidCallback onAddUser;
  final VoidCallback onImportUsers;
  final VoidCallback onManageRoles;
  final VoidCallback onSendNotification;
  final VoidCallback onExportUsers;
  final VoidCallback onBulkActions;
  final VoidCallback? onCustomize;

  const UsersQuickActions({
    super.key,
    required this.onAddUser,
    required this.onImportUsers,
    required this.onManageRoles,
    required this.onSendNotification,
    required this.onExportUsers,
    required this.onBulkActions,
    this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Quick Actions + Customize Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101A3A),
                    ),
                  ),
                ],
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onCustomize,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.settings_outlined, size: 12, color: Color(0xFF64748B)),
                      SizedBox(width: 4),
                      Text(
                        'Customize',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Action Buttons Row (6 Actions)
          Builder(
            builder: (context) {
              final width = MediaQuery.sizeOf(context).width;
              final isSmall = width < 480;

              final actions = [
                _buildActionTile(
                  title: 'Add\nUser',
                  icon: Icons.person_add_rounded,
                  iconBg: const Color(0xFF5636F5),
                  cardBg: const Color(0xFFF3F0FF),
                  onTap: onAddUser,
                ),
                _buildActionTile(
                  title: 'Import\nUsers',
                  icon: Icons.file_upload_outlined,
                  iconBg: const Color(0xFF0284C7),
                  cardBg: const Color(0xFFEFF6FF),
                  onTap: onImportUsers,
                ),
                _buildActionTile(
                  title: 'Manage\nRoles',
                  icon: Icons.manage_accounts_outlined,
                  iconBg: const Color(0xFF10B981),
                  cardBg: const Color(0xFFECFDF5),
                  onTap: onManageRoles,
                ),
                _buildActionTile(
                  title: 'Send\nNotification',
                  icon: Icons.mark_email_unread_outlined,
                  iconBg: const Color(0xFFF59E0B),
                  cardBg: const Color(0xFFFFFBEB),
                  onTap: onSendNotification,
                ),
                _buildActionTile(
                  title: 'Export\nUsers',
                  icon: Icons.file_download_outlined,
                  iconBg: const Color(0xFFF43F5E),
                  cardBg: const Color(0xFFFFF1F2),
                  onTap: onExportUsers,
                ),
                _buildActionTile(
                  title: 'Bulk\nActions',
                  icon: Icons.tune_rounded,
                  iconBg: const Color(0xFFEC4899),
                  cardBg: const Color(0xFFFDF2F8),
                  onTap: onBulkActions,
                ),
              ];

              if (isSmall) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: actions
                        .map((a) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: SizedBox(width: 60, child: a),
                            ))
                        .toList(),
                  ),
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: actions.map((a) => Expanded(child: a)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required Color iconBg,
    required Color cardBg,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: iconBg.withAlpha(50),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
                height: 1.15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
