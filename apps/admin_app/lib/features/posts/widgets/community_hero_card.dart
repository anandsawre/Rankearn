import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Hero banner for Community Post Management tab matching design tokens.
class CommunityHeroCard extends StatelessWidget {
  final VoidCallback? onRefresh;

  const CommunityHeroCard({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return AdminHeroCard(
      title: 'Community Post Management',
      subtitle1: 'Publish daily practice questions, study notes, polls, and announcements.',
      subtitle2: 'Engage thousands of active learners and track discussion community interactions.',
      onSync: onRefresh,
      syncTooltip: 'Refresh community posts',
      trailing: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandPurple.withValues(alpha: 0.1),
              ),
            ),
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.adminViolet, AppColors.brandPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: AppShadows.card,
              ),
              child: const Icon(
                Icons.groups_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
