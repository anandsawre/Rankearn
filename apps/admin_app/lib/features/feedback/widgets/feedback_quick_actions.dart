import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Quick Actions panel for User Feedback Management screen.
/// Fully tokenized using design system [AppColors], [AppSpacing], and [QuickActionsCard].
class FeedbackQuickActions extends StatelessWidget {
  final VoidCallback onReplyFeedback;
  final VoidCallback onFilterPositive;
  final VoidCallback onFilterIssues;
  final VoidCallback onExportCsv;
  final VoidCallback onManageRatings;
  final VoidCallback? onCustomize;
  final double? height;

  const FeedbackQuickActions({
    super.key,
    required this.onReplyFeedback,
    required this.onFilterPositive,
    required this.onFilterIssues,
    required this.onExportCsv,
    required this.onManageRatings,
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
          label: 'Reply\nFeedback',
          icon: Icons.reply_rounded,
          iconColor: AppColors.brandPurple,
          cardColor: AppColors.brandPurpleLight,
          onTap: onReplyFeedback,
        ),
        QuickActionItemData(
          label: 'Positive\nReviews',
          icon: Icons.thumb_up_alt_outlined,
          iconColor: AppColors.adminSuccess,
          cardColor: AppColors.adminSuccessLight,
          onTap: onFilterPositive,
        ),
        QuickActionItemData(
          label: 'Issues &\nBugs',
          icon: Icons.bug_report_outlined,
          iconColor: AppColors.brandPink,
          cardColor: AppColors.brandPinkLight,
          onTap: onFilterIssues,
        ),
        QuickActionItemData(
          label: 'Export\nCSV',
          icon: Icons.file_download_outlined,
          iconColor: AppColors.adminBlue,
          cardColor: AppColors.adminBlueLight,
          onTap: onExportCsv,
        ),
        QuickActionItemData(
          label: 'Manage\nRatings',
          icon: Icons.star_outline_rounded,
          iconColor: AppColors.adminWarning,
          cardColor: AppColors.adminAmberLight,
          onTap: onManageRatings,
        ),
      ],
    );
  }
}
