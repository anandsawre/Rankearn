import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Quick Actions panel for Community Post Management screen.
/// Fully tokenized using design system [AppColors], [AppSpacing], and [QuickActionsCard].
class CommunityQuickActions extends StatelessWidget {
  final VoidCallback onCommunityPost;
  final VoidCallback onPoll;
  final VoidCallback onComments;
  final VoidCallback onReports;
  final VoidCallback onSettings;
  final VoidCallback? onCustomize;
  final double? height;

  const CommunityQuickActions({
    super.key,
    required this.onCommunityPost,
    required this.onPoll,
    required this.onComments,
    required this.onReports,
    required this.onSettings,
    this.onCustomize,
    this.height = AppSpacing.adminHeroHeight,
  });

  @override
  Widget build(BuildContext context) {
    return QuickActionsCard(
      title: 'Community Management',
      titleIcon: Icons.forum_rounded,
      onCustomize: onCustomize,
      height: height,
      compact: true,
      actions: [
        QuickActionItemData(
          label: 'Community\nPost',
          icon: Icons.article_outlined,
          iconColor: AppColors.brandPurple,
          cardColor: AppColors.brandPurpleLight,
          onTap: onCommunityPost,
        ),
        QuickActionItemData(
          label: 'Live\nPoll',
          icon: Icons.poll_outlined,
          iconColor: AppColors.adminBlue,
          cardColor: AppColors.adminBlueLight,
          onTap: onPoll,
        ),
        QuickActionItemData(
          label: 'User\nComments',
          icon: Icons.chat_bubble_outline_rounded,
          iconColor: AppColors.adminWarning,
          cardColor: AppColors.adminAmberLight,
          onTap: onComments,
        ),
        QuickActionItemData(
          label: 'Flagged\nReports',
          icon: Icons.flag_outlined,
          iconColor: AppColors.brandPink,
          cardColor: AppColors.brandPinkLight,
          onTap: onReports,
        ),
        QuickActionItemData(
          label: 'Community\nSettings',
          icon: Icons.settings_outlined,
          iconColor: AppColors.adminSuccess,
          cardColor: AppColors.adminSuccessLight,
          onTap: onSettings,
        ),
      ],
    );
  }
}
