import 'package:flutter/material.dart';
import '../buttons/app_button.dart';
import '../../tokens/colors.dart';
import '../../tokens/icons.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// LiveContestCard strictly adhering to the centralized Rankearn Design System.
/// Supports both LIVE contests (Red theme) and UPCOMING / MEGA contests (Blue theme).
/// Uses centralized tokens for all colors, typography, spacing, radii, shadows, and icons.
class LiveContestCard extends StatelessWidget {
  final String title;
  final String tagline;
  final IconData? icon;
  final String questions;
  final String duration;
  final String joined;
  final String prizePool;
  final String entryFee;
  final String? endsIn;
  final String? countdownTime;
  final String? countdownLabel;
  final String startsAt;
  final bool isLive;
  final String? statusLabel;
  final Color? accentColor;
  final Color? accentLightColor;
  final Color? accentBorderColor;
  final String? primaryButtonLabel;
  final Widget? primaryButtonLeadingIcon;
  final VoidCallback? onJoin;
  final VoidCallback? onShare;

  const LiveContestCard({
    super.key,
    this.title = 'PHYSICS',
    this.tagline = 'TEST & WIN REWARDS!',
    this.icon,
    this.questions = '10 Qs',
    this.duration = '10 Mins',
    this.joined = '0 Joined',
    this.prizePool = '0',
    this.entryFee = '10',
    this.endsIn,
    this.countdownTime,
    this.countdownLabel,
    this.startsAt = '21 Oct, 05:38 am',
    this.isLive = true,
    this.statusLabel,
    this.accentColor,
    this.accentLightColor,
    this.accentBorderColor,
    this.primaryButtonLabel,
    this.primaryButtonLeadingIcon,
    this.onJoin,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? (isLive ? AppColors.liveRed : AppColors.brandBlue);
    final effectiveAccentLight = accentLightColor ?? (isLive ? AppColors.liveRedLight : AppColors.infoBlueLight);
    final effectiveAccentBorder = accentBorderColor ?? (isLive ? AppColors.liveRedBorder : AppColors.infoBlueBorder);
    final effectiveIcon = icon ?? (isLive ? AppIcons.live : Icons.emoji_events_rounded);
    final effectiveStatus = statusLabel ?? (isLive ? 'LIVE NOW' : 'UPCOMING');
    final effectiveCountdown = countdownTime ?? endsIn ?? '210:06:33';
    final effectiveCountdownLabel = countdownLabel ?? (isLive ? 'ENDS IN' : 'STARTS IN');
    final effectivePrimaryLabel = primaryButtonLabel ?? (isLive ? 'JOIN & WIN COINS' : 'NOTIFY ME');
    final effectivePrimaryIcon = primaryButtonLeadingIcon ??
        (isLive ? null : const Icon(Icons.notifications_none_rounded, size: 15, color: Colors.white));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderXl,
        border: Border.all(
          color: AppColors.border,
          width: 1.2,
        ),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Top-Left Curved Diagonal Corner Accent
          Positioned(
            top: 0,
            left: 0,
            child: CustomPaint(
              size: const Size(110, 110),
              painter: _CornerAccentPainter(color: effectiveAccent),
            ),
          ),

          // 2. Main Card Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Floating Broadcast / Award Icon + Title & Tagline
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Floating White Circle with Theme Signal / Trophy Icon
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        border: Border.all(
                          color: AppColors.borderSubtle,
                          width: 1.5,
                        ),
                        boxShadow: AppShadows.subtle,
                      ),
                      child: Center(
                        child: Icon(
                          effectiveIcon,
                          color: effectiveAccent,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Title & Tagline
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              title,
                              style: AppTypography.cardHeading.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.surfaceDark,
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                isLive ? AppIcons.trendingUp : Icons.stars_rounded,
                                color: isLive ? AppColors.brandOrange : effectiveAccent,
                                size: 14,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  tagline,
                                  style: AppTypography.captionBold.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Meta Row: Questions • Duration • Joined
                Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: _buildMetaPill(
                          icon: AppIcons.target,
                          accentColor: effectiveAccent,
                          label: questions,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: _buildMetaPill(
                          icon: AppIcons.timer,
                          accentColor: effectiveAccent,
                          label: duration,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: _buildMetaPill(
                          icon: AppIcons.participants,
                          accentColor: effectiveAccent,
                          label: joined,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Middle Stats Container: Prize Pool | Entry Fee | Ends / Starts In
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: AppRadii.borderLg,
                    border: Border.all(
                      color: AppColors.borderSubtle,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Column 1: PRIZE POOL
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'PRIZE POOL',
                              style: AppTypography.microTag.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: effectiveAccent,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '₹',
                                        style: AppTypography.microTag.copyWith(
                                          color: AppColors.textOnPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        prizePool,
                                        style: AppTypography.metricValue.copyWith(
                                          fontSize: 20,
                                          color: effectiveAccent,
                                          height: 1.0,
                                        ),
                                      ),
                                      Text(
                                        'COINS',
                                        style: AppTypography.microTag.copyWith(
                                          fontSize: 8,
                                          color: effectiveAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider 1
                      Container(
                        width: 1,
                        height: 36,
                        color: AppColors.border,
                      ),

                      // Column 2: ENTRY FEE
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'ENTRY FEE',
                              style: AppTypography.microTag.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    entryFee,
                                    style: AppTypography.metricValue.copyWith(
                                      fontSize: 20,
                                      color: AppColors.surfaceDark,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                                Text(
                                  entryFee == 'FREE' ? 'ENTRY' : 'COINS',
                                  style: AppTypography.microTag.copyWith(
                                    fontSize: 8,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Divider 2
                      Container(
                        width: 1,
                        height: 36,
                        color: AppColors.border,
                      ),

                      // Column 3: ENDS IN / STARTS IN
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              effectiveCountdownLabel,
                              style: AppTypography.microTag.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                effectiveCountdown,
                                style: AppTypography.metricValue.copyWith(
                                  fontSize: 17,
                                  color: effectiveAccent,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'HRS  MINS  SECS',
                                style: AppTypography.microTag.copyWith(
                                  fontSize: 8,
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
                const SizedBox(height: AppSpacing.md),

                // Starts At & Status Pill Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Starts At
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceMuted,
                            ),
                            child: const Center(
                              child: Icon(
                                AppIcons.calendar,
                                color: AppColors.textSecondary,
                                size: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STARTS:',
                                  style: AppTypography.microTag.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  startsAt,
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.surfaceDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),

                    // Status Badge (LIVE NOW / UPCOMING)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: effectiveAccentLight,
                          borderRadius: AppRadii.borderPill,
                          border: Border.all(
                            color: effectiveAccentBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              color: effectiveAccent,
                              size: 6,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              effectiveStatus,
                              style: AppTypography.microTag.copyWith(
                                color: effectiveAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Bottom Action Buttons: Primary + SHARE
                Row(
                  children: [
                    // Primary Button (Join or Notify)
                    Expanded(
                      flex: 12,
                      child: AppButton(
                        label: effectivePrimaryLabel,
                        size: AppButtonSize.medium,
                        leadingIcon: effectivePrimaryIcon,
                        backgroundColor: effectiveAccent,
                        foregroundColor: AppColors.textOnPrimary,
                        borderRadius: BorderRadius.circular(10),
                        onPressed: onJoin,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Share Button
                    Expanded(
                      flex: 7,
                      child: AppButton(
                        label: 'SHARE',
                        size: AppButtonSize.medium,
                        variant: AppButtonVariant.secondary,
                        leadingIcon: const Icon(
                          AppIcons.share,
                          color: AppColors.textSecondary,
                          size: 15,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        onPressed: onShare,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPill({
    required IconData icon,
    required Color accentColor,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: accentColor,
          size: 14,
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// CustomPainter for drawing the soft curved top-left accent flourish
class _CornerAccentPainter extends CustomPainter {
  final Color color;

  const _CornerAccentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.20,
        0,
        size.height,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerAccentPainter oldDelegate) =>
      oldDelegate.color != color;
}
