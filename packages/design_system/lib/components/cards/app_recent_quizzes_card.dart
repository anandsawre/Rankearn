import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/typography.dart';

/// Data model representing a single quiz item in [AppRecentQuizzesCard].
class RecentQuizItem {
  final String title;
  final String subtitle;
  final String status;
  final bool isPublished;
  final String date;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const RecentQuizItem({
    required this.title,
    required this.subtitle,
    required this.status,
    this.isPublished = true,
    required this.date,
    required this.icon,
    required this.color,
    this.onTap,
    this.onMoreTap,
  });
}

/// Centralized, theme-tokenized Recent Quizzes Card component.
///
/// Features:
/// - Header with category icon, title, and "View All" link
/// - Responsive quiz rows with rounded icon badge, title/subtitle, status badge, date, and options menu
/// - Design token support (`AppColors`, `AppTypography`, `AppRadii`, `AppShadows`)
class AppRecentQuizzesCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<RecentQuizItem> quizzes;
  final VoidCallback? onViewAll;
  final String viewAllText;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const AppRecentQuizzesCard({
    super.key,
    this.title = 'Recent Quizzes',
    this.icon = Icons.description_outlined,
    this.iconColor = const Color(0xFFEF4444),
    this.quizzes = const [
      RecentQuizItem(
        title: 'General Science Mock Test',
        subtitle: 'General Science • 50 Questions',
        status: 'Published',
        isPublished: true,
        date: 'Oct 18, 2026',
        icon: Icons.science_outlined,
        color: Color(0xFF6366F1),
      ),
      RecentQuizItem(
        title: 'Current Affairs - October 2026',
        subtitle: 'Current Affairs • 30 Questions',
        status: 'Published',
        isPublished: true,
        date: 'Oct 17, 2026',
        icon: Icons.public_outlined,
        color: Color(0xFFF59E0B),
      ),
      RecentQuizItem(
        title: 'Basic Mathematics',
        subtitle: 'Mathematics • 40 Questions',
        status: 'Draft',
        isPublished: false,
        date: 'Oct 16, 2026',
        icon: Icons.calculate_outlined,
        color: Color(0xFFEC4899),
      ),
      RecentQuizItem(
        title: 'Reasoning Practice Set',
        subtitle: 'Reasoning • 35 Questions',
        status: 'Published',
        isPublished: true,
        date: 'Oct 15, 2026',
        icon: Icons.psychology_outlined,
        color: Color(0xFF0EA5E9),
      ),
      RecentQuizItem(
        title: 'Physics - Important Questions',
        subtitle: 'Physics • 50 Questions',
        status: 'Published',
        isPublished: true,
        date: 'Oct 14, 2026',
        icon: Icons.biotech_outlined,
        color: Color(0xFF8B5CF6),
      ),
    ],
    this.onViewAll,
    this.viewAllText = 'View All',
    this.height = 300,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: height != null ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, color: iconColor, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (onViewAll != null) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: onViewAll,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      viewAllText,
                      style: TextStyle(
                        fontFamily: AppTypography.fontHeading,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Quizzes List (Compact)
          ...quizzes.map((quiz) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                onTap: quiz.onTap,
                borderRadius: AppRadii.borderSm,
                child: Row(
                  children: [
                    // Leading Icon Box
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: quiz.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(quiz.icon, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),

                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.title,
                            style: TextStyle(
                              fontFamily: AppTypography.fontHeading,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            quiz.subtitle,
                            style: TextStyle(
                              fontFamily: AppTypography.fontHeading,
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Status & Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: quiz.isPublished
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            quiz.status,
                            style: TextStyle(
                              fontFamily: AppTypography.fontHeading,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: quiz.isPublished
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          quiz.date,
                          style: TextStyle(
                            fontFamily: AppTypography.fontHeading,
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),

                    // More Action
                    InkWell(
                      onTap: quiz.onMoreTap,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.more_vert, size: 16, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
