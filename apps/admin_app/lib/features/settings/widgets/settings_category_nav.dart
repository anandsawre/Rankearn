import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SettingsCategoryNav extends StatelessWidget {
  final String activeCategory;
  final ValueChanged<String> onCategoryChanged;

  const SettingsCategoryNav({
    super.key,
    required this.activeCategory,
    required this.onCategoryChanged,
  });

  static const categories = [
    {'id': 'all', 'label': 'General', 'icon': Icons.settings_rounded},
    {'id': 'features', 'label': 'Features', 'icon': Icons.dashboard_customize_rounded},
    {'id': 'rewards', 'label': 'Rewards & Coins', 'icon': Icons.toll_rounded},
    {'id': 'battles', 'label': 'Battles & Games', 'icon': Icons.sports_esports_rounded},
    {'id': 'payments', 'label': 'Payments', 'icon': Icons.credit_card_rounded},
    {'id': 'notifications', 'label': 'Notifications', 'icon': Icons.notifications_none_rounded},
    {'id': 'limits', 'label': 'Limits & Rules', 'icon': Icons.shield_outlined},
    {'id': 'appearance', 'label': 'Appearance', 'icon': Icons.palette_outlined},
    {'id': 'advanced', 'label': 'Advanced', 'icon': Icons.code_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = activeCategory == cat['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => onCategoryChanged(cat['id'] as String),
              borderRadius: AppRadii.adminControl,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.adminPurple : Colors.white,
                  borderRadius: AppRadii.adminControl,
                  border: Border.all(
                    color: isSelected ? AppColors.adminPurple : AppColors.adminBorder,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.adminPurple.withAlpha(50),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.adminSecondaryText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.adminPrimaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
