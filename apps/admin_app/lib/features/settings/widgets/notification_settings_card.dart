import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class NotificationSettingsCard extends StatelessWidget {
  final bool enablePush;
  final bool enableInApp;
  final bool enableEmail;
  final bool enableSms;
  final ValueChanged<bool> onEnablePushChanged;
  final ValueChanged<bool> onEnableInAppChanged;
  final ValueChanged<bool> onEnableEmailChanged;
  final ValueChanged<bool> onEnableSmsChanged;

  const NotificationSettingsCard({
    super.key,
    required this.enablePush,
    required this.enableInApp,
    required this.enableEmail,
    required this.enableSms,
    required this.onEnablePushChanged,
    required this.onEnableInAppChanged,
    required this.onEnableEmailChanged,
    required this.onEnableSmsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
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
                child: const Icon(Icons.notifications_none_rounded, size: 18, color: AppColors.adminPurple),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Notification Settings',
                  style: AppTypography.adminCardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildToggleRow('Enable Push Notification', enablePush, onEnablePushChanged),
          const SizedBox(height: 6),
          _buildToggleRow('Enable In-App Notification', enableInApp, onEnableInAppChanged),
          const SizedBox(height: 6),
          _buildToggleRow('Enable Email Notification', enableEmail, onEnableEmailChanged),
          const SizedBox(height: 6),
          _buildToggleRow('Enable SMS (OTP/Alerts)', enableSms, onEnableSmsChanged),
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
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.adminPurple,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

