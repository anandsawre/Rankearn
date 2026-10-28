import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import 'themed_card_background.dart';

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
    return ThemedCardBackground(
      width: 104,
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      watermarkIcon: icon,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Subject Icon Box
              Flexible(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withAlpha(50),
                        width: 1.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withAlpha(25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(icon, size: 21, color: accentColor),
                    ),
                  ),
                ),
              ),

              // 2. Subject Title
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

              // 3. Question Count Pill
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      questionCount,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: accentColor.withAlpha(220),
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Chevron Circle Button
              Flexible(
                flex: 2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withAlpha(35),
                    border: Border.all(
                      color: accentColor.withAlpha(50),
                      width: 1,
                    ),
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
    );
  }
}
