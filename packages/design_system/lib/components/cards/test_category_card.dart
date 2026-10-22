import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

/// TestCategoryCard matching the 6 cards under "Test Categories" in the Tests tab
class TestCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String testsCount;
  final String questionsCount;
  final IconData? leftMetaIcon;
  final IconData? rightMetaIcon;
  final Color accentColor;
  final Color? cardBackgroundColor;
  final VoidCallback onTap;

  const TestCategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.testsCount,
    required this.questionsCount,
    this.leftMetaIcon = Icons.description_outlined,
    this.rightMetaIcon = Icons.trending_up_rounded,
    required this.accentColor,
    this.cardBackgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Squircle Icon, Title & Description, Circular Arrow Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Squircle Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withAlpha(70),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Title & Description Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Circular Chevron Arrow Button
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withAlpha(30),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Inset Divider / Metadata Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFEDF2F7),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Left Meta: Tests Count
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              leftMetaIcon ?? Icons.description_outlined,
                              size: 13,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                testsCount,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Vertical Separator
                      Container(
                        width: 1,
                        height: 12,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        color: const Color(0xFFCBD5E1),
                      ),

                      // Right Meta: Questions Count
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              rightMetaIcon ?? Icons.bar_chart_rounded,
                              size: 13,
                              color: accentColor,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                questionsCount,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
