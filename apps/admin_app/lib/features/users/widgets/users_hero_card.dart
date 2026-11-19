import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../users_hero_data.dart';

/// Users Management Hero Card fully tokenized using design system's [AdminHeroCard].
class UsersHeroCard extends StatelessWidget {
  final VoidCallback? onRefresh;

  const UsersHeroCard({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return AdminHeroCard(
      title: 'Users',
      titleAccent: 'Management',
      subtitle1: 'Manage platform users, view their activity, enrollments and performance.',
      subtitle2: 'Keep your user base engaged and growing.',
      onSync: onRefresh,
      syncTooltip: 'Refresh users data',
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160, maxHeight: 124),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: Image.memory(
            kUsersHeroIllustrationBytes,
            fit: BoxFit.contain,
            alignment: Alignment.centerRight,
            height: 124,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                width: 90,
                child: Icon(
                  Icons.people_alt_rounded,
                  size: 48,
                  color: AppColors.brandPurple,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
