import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Quick Actions panel for Support Ticket Management screen.
/// Fully tokenized using design system [AppColors], [AppSpacing], and [QuickActionsCard].
class SupportQuickActions extends StatelessWidget {
  final VoidCallback onCreateTicket;
  final VoidCallback onBulkReply;
  final VoidCallback onFilterOpen;
  final VoidCallback onFilterHighPriority;
  final VoidCallback onFaqHelp;
  final VoidCallback? onCustomize;
  final double? height;

  const SupportQuickActions({
    super.key,
    required this.onCreateTicket,
    required this.onBulkReply,
    required this.onFilterOpen,
    required this.onFilterHighPriority,
    required this.onFaqHelp,
    this.onCustomize,
    this.height = AppSpacing.adminHeroHeight,
  });

  @override
  Widget build(BuildContext context) {
    return QuickActionsCard(
      onCustomize: onCustomize,
      height: height,
      compact: true,
      actions: [
        QuickActionItemData(
          label: 'Create\nTicket',
          icon: Icons.add_task_rounded,
          iconColor: AppColors.brandPurple,
          cardColor: AppColors.brandPurpleLight,
          onTap: onCreateTicket,
        ),
        QuickActionItemData(
          label: 'Bulk\nReply',
          icon: Icons.forum_outlined,
          iconColor: AppColors.adminBlue,
          cardColor: AppColors.adminBlueLight,
          onTap: onBulkReply,
        ),
        QuickActionItemData(
          label: 'Open\nTickets',
          icon: Icons.mark_email_unread_outlined,
          iconColor: AppColors.adminWarning,
          cardColor: AppColors.adminAmberLight,
          onTap: onFilterOpen,
        ),
        QuickActionItemData(
          label: 'High\nPriority',
          icon: Icons.priority_high_rounded,
          iconColor: AppColors.brandPink,
          cardColor: AppColors.brandPinkLight,
          onTap: onFilterHighPriority,
        ),
        QuickActionItemData(
          label: 'FAQ / Help\nCenter',
          icon: Icons.help_outline_rounded,
          iconColor: AppColors.adminSuccess,
          cardColor: AppColors.adminSuccessLight,
          onTap: onFaqHelp,
        ),
      ],
    );
  }
}
