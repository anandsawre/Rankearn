import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Responsive Statistics Cards Tokenized with Centralized Design System
class TournamentStatsCards extends StatelessWidget {
  final bool isDesktop;
  final int activeCount;
  final int participationCount;
  final String myRank;
  final String totalRewards;

  const TournamentStatsCards({
    super.key,
    required this.isDesktop,
    required this.activeCount,
    required this.participationCount,
    required this.myRank,
    required this.totalRewards,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            child: _buildDesktopCard(
              icon: Icons.emoji_events_rounded,
              iconBgColor: AppColors.contestCoinAmber,
              watermarkIcon: Icons.emoji_events_rounded,
              title: 'Active\nContests',
              value: activeCount.toString(),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: _buildDesktopCard(
              icon: Icons.people_alt_rounded,
              iconBgColor: AppColors.contestBlue,
              watermarkIcon: Icons.people_alt_rounded,
              title: 'My Participation',
              value: participationCount.toString(),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: _buildDesktopCard(
              icon: Icons.workspace_premium_rounded,
              iconBgColor: AppColors.contestPurple,
              watermarkIcon: Icons.workspace_premium_rounded,
              title: 'My Rank',
              value: myRank,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: _buildDesktopCard(
              icon: Icons.card_giftcard_rounded,
              iconBgColor: AppColors.contestActiveGreen,
              watermarkIcon: Icons.card_giftcard_rounded,
              title: 'Total Rewards',
              value: totalRewards,
            ),
          ),
        ],
      );
    }

    // Mobile: 2 Cards Row
    return Row(
      children: [
        Expanded(
          child: _buildMobileCard(
            icon: Icons.emoji_events_rounded,
            iconBgColor: AppColors.contestCoinAmber,
            title: 'Active\nContests',
            value: activeCount.toString(),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildMobileCard(
            icon: Icons.people_alt_rounded,
            iconBgColor: AppColors.contestBlue,
            title: 'My Participation',
            value: participationCount.toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopCard({
    required IconData icon,
    required Color iconBgColor,
    required IconData watermarkIcon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.contestCardBg,
        borderRadius: AppRadii.contestCard,
        border: Border.all(color: AppColors.contestCardBorder),
        boxShadow: AppShadows.contestCard,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background subtle watermark icon
          Positioned(
            right: -6,
            bottom: -8,
            child: Icon(
              watermarkIcon,
              size: 54,
              color: AppColors.contestWatermark,
            ),
          ),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: AppRadii.contestThumb,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      style: AppTypography.contestStatLabel,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTypography.contestStatValue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.contestCardBg,
        borderRadius: AppRadii.contestCard,
        border: Border.all(color: AppColors.contestCardBorder),
        boxShadow: AppShadows.contestCardMobile,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -4,
            bottom: -6,
            child: Icon(
              icon,
              size: 46,
              color: AppColors.contestWatermark,
            ),
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: AppRadii.contestThumbSm,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.contestTextSecondary,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.contestTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
