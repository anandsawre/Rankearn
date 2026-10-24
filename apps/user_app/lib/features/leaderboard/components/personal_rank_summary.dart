import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/leaderboard_model.dart';

/// Mobile Highlighted Personal Rank Summary Card matching Reference Image 2
/// Displays the current authenticated user's rank #7, tests, win rate, coins,
/// and trailing action arrow to profile.
/// Strictly adhering to the Rankearn centralized design system.
class PersonalRankSummary extends StatelessWidget {
  final LeaderboardUserEntry userEntry;
  final VoidCallback? onTap;

  const PersonalRankSummary({super.key, required this.userEntry, this.onTap});

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
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.borderLg,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.leaderboardMintBg,
              AppColors.leaderboardGreen100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadii.borderLg,
          border: Border.all(color: AppColors.brandGreenMuted, width: 1.2),
          boxShadow: AppShadows.leaderboardCard,
        ),
        child: Row(
          children: [
            // Avatar in green hoodie
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.leaderboardGreen,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: AppShadows.subtle,
              ),
              child: const Icon(
                Icons.sentiment_very_satisfied_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Rank #7 + Name + Region
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Your Rank',
                          style: TextStyle(
                            color: AppColors.leaderboardGreenDark,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            fontFamilyFallback: AppTypography.fontFallbacks,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '#${userEntry.rank}',
                          style: const TextStyle(
                            color: AppColors.leaderboardGreenDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            fontFamilyFallback: AppTypography.fontFallbacks,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    userEntry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.leaderboardNavy,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      fontFamilyFallback: AppTypography.fontFallbacks,
                    ),
                  ),
                  Text(
                    userEntry.state,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.leaderboardMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      fontFamilyFallback: AppTypography.fontFallbacks,
                    ),
                  ),
                ],
              ),
            ),

            // Stat 1: Tests
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${userEntry.testsCompleted}',
                    style: const TextStyle(
                      color: AppColors.leaderboardGreenDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      fontFamilyFallback: AppTypography.fontFallbacks,
                    ),
                  ),
                  const Text(
                    'Tests',
                    style: TextStyle(
                      color: AppColors.leaderboardMuted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      fontFamilyFallback: AppTypography.fontFallbacks,
                    ),
                  ),
                ],
              ),
            ),

            // Stat 2: Win Rate
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${userEntry.winRate}%',
                    style: const TextStyle(
                      color: AppColors.leaderboardGreenDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      fontFamilyFallback: AppTypography.fontFallbacks,
                    ),
                  ),
                  const Text(
                    'Win Rate',
                    style: TextStyle(
                      color: AppColors.leaderboardMuted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      fontFamilyFallback: AppTypography.fontFallbacks,
                    ),
                  ),
                ],
              ),
            ),

            // Stat 3: Coins
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
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
                            size: 9,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _formatCoins(userEntry.coinsEarned),
                          style: const TextStyle(
                            color: AppColors.leaderboardDarkSlate,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            fontFamilyFallback: AppTypography.fontFallbacks,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Coins',
                    style: TextStyle(
                      color: AppColors.leaderboardMuted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      fontFamilyFallback: AppTypography.fontFallbacks,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing Chevron
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.leaderboardGreen,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
