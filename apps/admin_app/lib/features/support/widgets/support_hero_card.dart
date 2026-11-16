import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Hero banner for Support Ticket Management tab matching design tokens.
class SupportHeroCard extends StatelessWidget {
  final VoidCallback? onRefresh;

  const SupportHeroCard({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return AdminHeroCard(
      title: 'Support Ticket Management',
      subtitle1: 'Manage user queries, complaints and support requests in one centralized hub.',
      subtitle2: 'Resolve payment, verification, quiz, and account issues with live admin chat.',
      onSync: onRefresh,
      syncTooltip: 'Refresh ticket list',
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
                Icons.headset_mic_rounded,
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
