import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class LuckyWheelQuickActions extends StatelessWidget {
  final VoidCallback onCreateLuckyWheel;
  final VoidCallback onSetRewards;
  final VoidCallback onManageCampaigns;
  final VoidCallback onSpinHistory;
  final VoidCallback onSendNotification;
  final VoidCallback onExportReports;
  final VoidCallback? onCustomize;
  final double? height;

  const LuckyWheelQuickActions({
    super.key,
    required this.onCreateLuckyWheel,
    required this.onSetRewards,
    required this.onManageCampaigns,
    required this.onSpinHistory,
    required this.onSendNotification,
    required this.onExportReports,
    this.onCustomize,
    this.height = 124,
  });

  @override
  Widget build(BuildContext context) {
    return QuickActionsCard(
      height: height,
      compact: true,
      onCustomize: onCustomize,
      actions: [
        QuickActionItemData(
          label: 'Create\nLucky Wheel',
          icon: Icons.add_circle_outline_rounded,
          iconColor: const Color(0xFF5636F5),
          cardColor: const Color(0xFFF3F0FF),
          onTap: onCreateLuckyWheel,
        ),
        QuickActionItemData(
          label: 'Set\nRewards',
          icon: Icons.card_giftcard_rounded,
          iconColor: const Color(0xFF2587F8),
          cardColor: const Color(0xFFEFF6FF),
          onTap: onSetRewards,
        ),
        QuickActionItemData(
          label: 'Manage\nCampaigns',
          icon: Icons.folder_outlined,
          iconColor: const Color(0xFF00C48C),
          cardColor: const Color(0xFFECFDF5),
          onTap: onManageCampaigns,
        ),
        QuickActionItemData(
          label: 'Spin\nHistory',
          icon: Icons.history_rounded,
          iconColor: const Color(0xFFFF9F0A),
          cardColor: const Color(0xFFFFFBEB),
          onTap: onSpinHistory,
        ),
        QuickActionItemData(
          label: 'Send\nNotification',
          icon: Icons.campaign_rounded,
          iconColor: const Color(0xFFF04483),
          cardColor: const Color(0xFFFFF1F2),
          onTap: onSendNotification,
        ),
        QuickActionItemData(
          label: 'Export\nReports',
          icon: Icons.description_outlined,
          iconColor: const Color(0xFFE11D48),
          cardColor: const Color(0xFFFFF1F2),
          onTap: onExportReports,
        ),
      ],
    );
  }
}
