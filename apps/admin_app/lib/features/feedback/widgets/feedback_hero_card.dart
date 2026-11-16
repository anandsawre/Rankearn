import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Hero banner for User Feedback & Review Management tab matching design tokens.
class FeedbackHeroCard extends StatelessWidget {
  final VoidCallback? onRefresh;

  const FeedbackHeroCard({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return AdminHeroCard(
      title: 'User Feedback Management',
      subtitle1: 'Collect, review and manage user feedback, ratings and suggestions in real time.',
      subtitle2: 'Monitor student sentiment across mock tests, quizzes, and platform features.',
      onSync: onRefresh,
      syncTooltip: 'Refresh feedback logs',
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
                Icons.rate_review_rounded,
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
