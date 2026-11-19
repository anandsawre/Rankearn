import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class FeaturesControlCard extends StatelessWidget {
  final Map<String, bool> featureStates;
  final void Function(String key, bool value) onFeatureToggled;

  const FeaturesControlCard({
    super.key,
    required this.featureStates,
    required this.onFeatureToggled,
  });

  static const List<Map<String, dynamic>> featuresList = [
    {'key': '1v1_battle', 'label': '1v1 Battle', 'icon': Icons.emoji_events_rounded, 'color': AppColors.adminWarning},
    {'key': 'multiplayer_battle', 'label': 'Multiplayer Battle', 'icon': Icons.group_rounded, 'color': AppColors.brandPurple},
    {'key': 'live_quiz', 'label': 'Live Quiz', 'icon': Icons.play_arrow_rounded, 'color': AppColors.adminSuccess},
    {'key': 'mock_test_series', 'label': 'Mock Test Series', 'icon': Icons.description_rounded, 'color': AppColors.adminSky},
    {'key': 'fortune_wheel', 'label': 'Fortune Wheel', 'icon': Icons.adjust_rounded, 'color': AppColors.brandPink},
    {'key': 'referral_earn', 'label': 'Referral & Earn', 'icon': Icons.share_rounded, 'color': AppColors.adminOrange},
    {'key': 'live_poll', 'label': 'Live Poll', 'icon': Icons.poll_rounded, 'color': AppColors.adminViolet},
    {'key': 'community', 'label': 'Community', 'icon': Icons.forum_rounded, 'color': AppColors.adminTeal},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: AppShadows.adminCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.adminPurpleLight,
                  borderRadius: AppRadii.adminControl,
                ),
                child: const Icon(Icons.dashboard_customize_rounded, size: 18, color: AppColors.adminPurple),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'App Features Control',
                  style: AppTypography.adminCardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...featuresList.map((f) {
            final key = f['key'] as String;
            final label = f['label'] as String;
            final icon = f['icon'] as IconData;
            final iconColor = f['color'] as Color;
            final isEnabled = featureStates[key] ?? true;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: iconColor),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.adminTablePrimary.copyWith(fontSize: 13),
                    ),
                  ),
                  AppSwitch.primary(
                    value: isEnabled,
                    onChanged: (val) => onFeatureToggled(key, val),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

