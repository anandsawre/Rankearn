import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/leaderboard_model.dart';

/// Mobile Top-Three 3D Podium Component matching Reference Image 2
/// - 2nd place on left
/// - 1st place in center (elevated with golden laurel & crown)
/// - 3rd place on right
/// - Tiered 3D step platforms with rank crowns, user avatars, stats & coin badges
/// Strictly adhering to the Rankearn centralized design system tokens.
class LeaderboardPodium extends StatelessWidget {
  final LeaderboardUserEntry first;
  final LeaderboardUserEntry second;
  final LeaderboardUserEntry third;
  final void Function(LeaderboardUserEntry user)? onUserTap;

  const LeaderboardPodium({
    super.key,
    required this.first,
    required this.second,
    required this.third,
    this.onUserTap,
  });

  String _formatCoins(int amount) {
    if (amount >= 1000) {
      final s = amount.toString();
      final lastThree = s.substring(s.length - 3);
      final otherNumbers = s.substring(0, s.length - 3);
      return otherNumbers.isNotEmpty ? '$otherNumbers,$lastThree' : lastThree;
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place (Left)
          Expanded(
            child: _buildPodiumColumn(
              entry: second,
              rank: 2,
              stepHeight: 38,
              crownColor: AppColors.leaderboardSilver,
              cardGradient: AppColors.leaderboardPodiumSilver,
              stepColor: AppColors.leaderboardSlate300,
              stepGradient: AppColors.leaderboardStepSilver,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // 1st Place (Center - Visually Highest & Elevated)
          Expanded(
            child: _buildPodiumColumn(
              entry: first,
              rank: 1,
              stepHeight: 56,
              isFirstPlace: true,
              crownColor: AppColors.leaderboardGold,
              cardGradient: AppColors.leaderboardPodiumGold,
              stepColor: AppColors.leaderboardAmber500,
              stepGradient: AppColors.leaderboardStepGold,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // 3rd Place (Right)
          Expanded(
            child: _buildPodiumColumn(
              entry: third,
              rank: 3,
              stepHeight: 28,
              crownColor: AppColors.leaderboardBronze,
              cardGradient: AppColors.leaderboardPodiumBronze,
              stepColor: AppColors.leaderboardOrange300,
              stepGradient: AppColors.leaderboardStepBronze,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required LeaderboardUserEntry entry,
    required int rank,
    required double stepHeight,
    required Color crownColor,
    required Gradient cardGradient,
    required Color stepColor,
    required Gradient stepGradient,
    bool isFirstPlace = false,
  }) {
    final avatarRadius = isFirstPlace ? 28.0 : 24.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Upper Card
        InkWell(
          onTap: () => onUserTap?.call(entry),
          borderRadius: AppRadii.borderLg,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 6,
              vertical: isFirstPlace ? 12 : 10,
            ),
            decoration: BoxDecoration(
              gradient: cardGradient,
              borderRadius: AppRadii.borderLg,
              border: Border.all(
                color: isFirstPlace
                    ? AppColors.leaderboardGold
                    : AppColors.borderSubtle,
                width: isFirstPlace ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isFirstPlace
                      ? AppColors.leaderboardAmber500.withValues(alpha: 0.15)
                      : AppColors.leaderboardDarkSlate.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Crown Badge with Rank Number
                _buildCrownBadge(rank, crownColor, isFirstPlace),
                const SizedBox(height: AppSpacing.xs),

                // Avatar with optional laurel wreath for 1st place
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isFirstPlace)
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.leaderboardAmber500,
                        size: 64,
                      ),
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: entry.avatarBgColor,
                      child: Icon(
                        Icons.person,
                        color: AppColors.leaderboardNavy,
                        size: avatarRadius * 1.25,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // User Name
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.leaderboardNavy,
                    fontSize: isFirstPlace ? 13 : 12,
                    fontWeight: FontWeight.w800,
                    fontFamilyFallback: AppTypography.fontFallbacks,
                  ),
                ),

                // State / Region
                Text(
                  entry.state,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.leaderboardMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    fontFamilyFallback: AppTypography.fontFallbacks,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Level Badge (Star + Lv. XX)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.leaderboardAmber500,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Lv. ${entry.level}',
                        style: const TextStyle(
                          color: AppColors.leaderboardSlate800,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          fontFamilyFallback: AppTypography.fontFallbacks,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Coins Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.leaderboardAmber100,
                      width: 1,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 13,
                          height: 13,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.leaderboardGold,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.monetization_on_rounded,
                            color: AppColors.leaderboardGoldDark,
                            size: 10,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _formatCoins(entry.coinsEarned),
                          style: const TextStyle(
                            color: AppColors.leaderboardDarkSlate,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            fontFamilyFallback: AppTypography.fontFallbacks,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Stepped Base Platform (3D step effect)
        Container(
          height: stepHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: stepGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            boxShadow: AppShadows.subtle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$rank',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamilyFallback: AppTypography.fontFallbacks,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCrownBadge(int rank, Color color, bool isFirst) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.borderSm,
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFirst
                ? Icons.military_tech_rounded
                : Icons.workspace_premium_rounded,
            color: isFirst ? AppColors.leaderboardOrange900 : Colors.white,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            '$rank',
            style: TextStyle(
              color: isFirst ? AppColors.leaderboardOrange900 : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              fontFamilyFallback: AppTypography.fontFallbacks,
            ),
          ),
        ],
      ),
    );
  }
}
