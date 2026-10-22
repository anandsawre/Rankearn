import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// SubjectCard for "Explore by Subject"
class SubjectCard extends StatelessWidget {
  final String title;
  final String questionCount;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.title,
    required this.questionCount,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadii.borderLg,
        border: Border.all(
          color: accentColor.withAlpha(50),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.borderLg,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Subject Icon
                Flexible(
                  flex: 3,
                  child: Icon(
                    icon,
                    size: 24,
                    color: accentColor,
                  ),
                ),

                // Subject Title
                Flexible(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),

                // Question Count
                Flexible(
                  flex: 2,
                  child: Text(
                    questionCount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary.withAlpha(200),
                    ),
                  ),
                ),

                // Small Chevron Circle Button
                Flexible(
                  flex: 2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withAlpha(40),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 13,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
