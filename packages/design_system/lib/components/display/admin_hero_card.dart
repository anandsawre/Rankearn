import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// Standardized Admin Hero Card component powered strictly by Rankearn design tokens.
///
/// Features:
/// - Fixed height `AppSpacing.adminHeroHeight` (124px)
/// - `AppColors.adminHeroGradient` pastel lavender-indigo background
/// - `AppRadii.adminCard` (16px) with `AppColors.border` border
/// - `AppShadows.card` elevation
/// - Two-tone RichText title using `AppTypography.adminHeroTitle` and `AppTypography.adminHeroTitleAccent`
/// - Optional live Sync pill button with tooltip
/// - Subtitle lines using `AppTypography.adminHeroSubtitle`
/// - Right-side circular background aura and trailing visual / mascot illustration
class AdminHeroCard extends StatelessWidget {
  final String title;
  final String? titleAccent;
  final String? subtitle1;
  final String? subtitle2;
  final Widget? trailing;
  final VoidCallback? onSync;
  final String syncTooltip;
  final double? height;

  const AdminHeroCard({
    super.key,
    required this.title,
    this.titleAccent,
    this.subtitle1,
    this.subtitle2,
    this.trailing,
    this.onSync,
    this.syncTooltip = 'Refresh live data',
    this.height = AppSpacing.adminHeroHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: AppColors.adminHeroGradient,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: AppRadii.adminCard,
        child: Stack(
          children: [
            // Soft background aura behind illustration
            Positioned(
              right: 60,
              top: -20,
              bottom: -20,
              width: 240,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(70),
                ),
              ),
            ),

            // Main Row: Left Text + Right Trailing Widget
            Row(
              children: [
                // Left Column: Headlines & Subtitles
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.xxl,
                      top: AppSpacing.lg,
                      bottom: AppSpacing.lg,
                      right: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main Title with Sync Tooltip Button
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: titleAccent != null ? '$title ' : title,
                                      style: AppTypography.adminHeroTitle,
                                    ),
                                    if (titleAccent != null)
                                      TextSpan(
                                        text: titleAccent!,
                                        style: AppTypography.adminHeroTitleAccent.copyWith(
                                          shadows: const [
                                            Shadow(
                                              color: Color(0x335636F5),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (onSync != null) ...[
                                const SizedBox(width: AppSpacing.sm),
                                Tooltip(
                                  message: syncTooltip,
                                  child: InkWell(
                                    onTap: onSync,
                                    borderRadius: AppRadii.borderSm,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        borderRadius: AppRadii.borderSm,
                                        border: Border.all(color: AppColors.borderSubtle),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.refresh_rounded,
                                            size: 13,
                                            color: AppColors.brandPurple,
                                          ),
                                          SizedBox(width: AppSpacing.xs),
                                          Text(
                                            'Sync',
                                            style: TextStyle(
                                              fontFamily: AppTypography.fontHeading,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.brandPurple,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (subtitle1 != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            subtitle1!,
                            style: AppTypography.adminHeroSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (subtitle2 != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle2!,
                            style: AppTypography.adminHeroSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Right Trailing illustration
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.lg),
                    child: trailing!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
