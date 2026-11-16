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
    {'key': '1v1_battle', 'label': '1v1 Battle', 'icon': Icons.emoji_events_rounded, 'color': Color(0xFFF59E0B)},
    {'key': 'multiplayer_battle', 'label': 'Multiplayer Battle', 'icon': Icons.group_rounded, 'color': Color(0xFF6366F1)},
    {'key': 'live_quiz', 'label': 'Live Quiz', 'icon': Icons.play_arrow_rounded, 'color': Color(0xFF10B981)},
    {'key': 'mock_test_series', 'label': 'Mock Test Series', 'icon': Icons.description_rounded, 'color': Color(0xFF0284C7)},
    {'key': 'fortune_wheel', 'label': 'Fortune Wheel', 'icon': Icons.adjust_rounded, 'color': Color(0xFFEC4899)},
    {'key': 'referral_earn', 'label': 'Referral & Earn', 'icon': Icons.share_rounded, 'color': Color(0xFFF97316)},
    {'key': 'live_poll', 'label': 'Live Poll', 'icon': Icons.poll_rounded, 'color': Color(0xFF8B5CF6)},
    {'key': 'community', 'label': 'Community', 'icon': Icons.forum_rounded, 'color': Color(0xFF0D9488)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
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
          const SizedBox(height: 14),

          ...featuresList.map((f) {
            final key = f['key'] as String;
            final label = f['label'] as String;
            final icon = f['icon'] as IconData;
            final iconColor = f['color'] as Color;
            final isEnabled = featureStates[key] ?? true;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: iconColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.adminTablePrimary.copyWith(fontSize: 13),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: isEnabled,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.adminPurple,
                      onChanged: (val) => onFeatureToggled(key, val),
                    ),
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

