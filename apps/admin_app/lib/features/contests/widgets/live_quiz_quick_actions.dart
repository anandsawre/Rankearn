import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Rankearn Quick Actions Card for the Live Quiz tab.
/// Uses the centralized QuickActionsCard from the design system at fixed height: 124.
class LiveQuizQuickActions extends StatelessWidget {
  final VoidCallback onCreateLiveQuiz;
  final VoidCallback onScheduleQuiz;
  final VoidCallback onManageQuestions;
  final VoidCallback onLiveNowDashboard;
  final VoidCallback onSendNotification;
  final VoidCallback onExportReports;
  final VoidCallback? onCustomize;
  final double? height;

  const LiveQuizQuickActions({
    super.key,
    required this.onCreateLiveQuiz,
    required this.onScheduleQuiz,
    required this.onManageQuestions,
    required this.onLiveNowDashboard,
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
          label: 'Create\nLive Quiz',
          icon: Icons.add_circle_outline_rounded,
          iconColor: const Color(0xFF6C5CE7),
          cardColor: const Color(0xFFF3F0FF),
          onTap: onCreateLiveQuiz,
        ),
        QuickActionItemData(
          label: 'Schedule\nQuiz',
          icon: Icons.schedule_rounded,
          iconColor: const Color(0xFF0084FF),
          cardColor: const Color(0xFFEFF6FF),
          onTap: onScheduleQuiz,
        ),
        QuickActionItemData(
          label: 'Manage\nQuestions',
          icon: Icons.person_outline_rounded,
          iconColor: const Color(0xFF00C48C),
          cardColor: const Color(0xFFECFDF5),
          onTap: onManageQuestions,
        ),
        QuickActionItemData(
          label: 'Live Now\nDashboard',
          icon: Icons.sensors_rounded,
          iconColor: const Color(0xFFFF9F0A),
          cardColor: const Color(0xFFFFFBEB),
          onTap: onLiveNowDashboard,
        ),
        QuickActionItemData(
          label: 'Send\nNotification',
          icon: Icons.campaign_outlined,
          iconColor: const Color(0xFFF04483),
          cardColor: const Color(0xFFFFF1F2),
          onTap: onSendNotification,
        ),
        QuickActionItemData(
          label: 'Export\nReports',
          icon: Icons.receipt_long_rounded,
          iconColor: const Color(0xFFE056FD),
          cardColor: const Color(0xFFFAF5FF),
          onTap: onExportReports,
        ),
      ],
    );
  }
}
