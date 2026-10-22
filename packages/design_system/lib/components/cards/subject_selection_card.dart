import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

/// SubjectSelectionCard for the "Select Subject" section in the Tests tab
class SubjectSelectionCard extends StatelessWidget {
  final String title;
  final String? questionCount;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final double? width;
  final bool isSelected;
  final VoidCallback onTap;

  const SubjectSelectionCard({
    super.key,
    required this.title,
    this.questionCount,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    this.width = 108,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? accentColor : accentColor.withAlpha(50),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? accentColor.withAlpha(40)
                : const Color(0x05000000),
            blurRadius: isSelected ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Subject Icon inside subtle white squircle
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withAlpha(60),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withAlpha(30),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Subject Name
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                ),

                if (questionCount != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          questionCount!,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary.withAlpha(200),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withAlpha(35),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 11,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
