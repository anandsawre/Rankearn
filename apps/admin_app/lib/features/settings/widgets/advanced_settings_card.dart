import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class AdvancedSettingsCard extends StatelessWidget {
  final bool maintenanceMode;
  final bool debugMode;
  final bool autoBackup;
  final bool activityLogs;
  final TextEditingController workerUrlController;
  final ValueChanged<bool> onMaintenanceChanged;
  final ValueChanged<bool> onDebugChanged;
  final ValueChanged<bool> onAutoBackupChanged;
  final ValueChanged<bool> onActivityLogsChanged;
  final VoidCallback onSaveWorkerUrl;

  const AdvancedSettingsCard({
    super.key,
    required this.maintenanceMode,
    required this.debugMode,
    required this.autoBackup,
    required this.activityLogs,
    required this.workerUrlController,
    required this.onMaintenanceChanged,
    required this.onDebugChanged,
    required this.onAutoBackupChanged,
    required this.onActivityLogsChanged,
    required this.onSaveWorkerUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: AppShadows.adminCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.adminPurpleLight,
                  borderRadius: AppRadii.adminControl,
                ),
                child: const Icon(Icons.code_rounded, size: 18, color: AppColors.adminPurple),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Advanced Settings',
                  style: AppTypography.adminCardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildToggleRow('Maintenance Mode', maintenanceMode, onMaintenanceChanged),
          const SizedBox(height: 6),
          _buildToggleRow('Debug Mode (Development Only)', debugMode, onDebugChanged),
          const SizedBox(height: 6),
          _buildToggleRow('Auto Backup (Firestore Export)', autoBackup, onAutoBackupChanged),
          const SizedBox(height: 6),
          _buildToggleRow('Enable Activity Logs', activityLogs, onActivityLogsChanged),
          const SizedBox(height: 14),

          Text('Edge Worker / AI Proxy URL', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: workerUrlController,
            hintText: 'https://testkarlo.alleduupdated.workers.dev',
          ),
          const SizedBox(height: 8),
          AppButton.adminSecondary(
            label: 'Save Worker Proxy',
            leadingIcon: const Icon(Icons.cloud_sync_rounded, size: 15),
            onPressed: onSaveWorkerUrl,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.adminTablePrimary.copyWith(fontSize: 13),
            ),
          ),
          AppSwitch.primary(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

