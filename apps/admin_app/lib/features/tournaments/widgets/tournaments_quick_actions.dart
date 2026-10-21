import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Rankearn Quick Actions Card for the Tournaments Management tab.
/// Uses the centralized QuickActionsCard from the design system at fixed height: 124.
class TournamentsQuickActions extends StatelessWidget {
  final VoidCallback onCreateTournament;
  final VoidCallback onScheduleTournament;
  final VoidCallback onManageRewards;
  final VoidCallback onViewRegistrations;
  final VoidCallback onSendNotification;
  final VoidCallback onExportReport;
  final VoidCallback? onCustomize;
  final double? height;

  const TournamentsQuickActions({
    super.key,
    required this.onCreateTournament,
    required this.onScheduleTournament,
    required this.onManageRewards,
    required this.onViewRegistrations,
    required this.onSendNotification,
    required this.onExportReport,
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
          label: 'Create\nTournament',
          icon: Icons.add_circle_outline_rounded,
          iconColor: const Color(0xFF6C5CE7),
          cardColor: const Color(0xFFF3F0FF),
          onTap: onCreateTournament,
        ),
        QuickActionItemData(
          label: 'Schedule\nTournament',
          icon: Icons.calendar_month_rounded,
          iconColor: const Color(0xFF0084FF),
          cardColor: const Color(0xFFEFF6FF),
          onTap: onScheduleTournament,
        ),
        QuickActionItemData(
          label: 'Manage\nRewards',
          icon: Icons.card_giftcard_rounded,
          iconColor: const Color(0xFF00C48C),
          cardColor: const Color(0xFFECFDF5),
          onTap: onManageRewards,
        ),
        QuickActionItemData(
          label: 'View\nRegistrations',
          icon: Icons.group_outlined,
          iconColor: const Color(0xFFFF9F0A),
          cardColor: const Color(0xFFFFFBEB),
          onTap: onViewRegistrations,
        ),
        QuickActionItemData(
          label: 'Send\nNotification',
          icon: Icons.campaign_outlined,
          iconColor: const Color(0xFFF04483),
          cardColor: const Color(0xFFFFF1F2),
          onTap: onSendNotification,
        ),
        QuickActionItemData(
          label: 'Export\nReport',
          icon: Icons.description_outlined,
          iconColor: const Color(0xFFE11D48),
          cardColor: const Color(0xFFFFF1F2),
          onTap: onExportReport,
        ),
      ],
    );
  }
}
