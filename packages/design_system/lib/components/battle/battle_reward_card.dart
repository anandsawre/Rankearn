import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import 'battle_versus_card.dart';

/// Announcement Card: "You defeated Amit Verma (Rank #4) in 1v1 Battle! 🏆"
class BattleResultAnnouncementCard extends StatelessWidget {
  final String text;

  const BattleResultAnnouncementCard({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF6),
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0xFFD1FAE5), width: 1.2),
        boxShadow: AppShadows.subtle,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.battleNavy,
          height: 1.35,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

/// Final Player Comparison Card on Victory Screen
class BattleResultComparisonCard extends StatelessWidget {
  final String winnerName;
  final int winnerScore;
  final String? winnerAvatar;
  final String loserName;
  final int loserScore;
  final String? loserAvatar;
  final bool isWinnerCurrentUser;

  const BattleResultComparisonCard({
    super.key,
    required this.winnerName,
    required this.winnerScore,
    this.winnerAvatar,
    required this.loserName,
    required this.loserScore,
    this.loserAvatar,
    this.isWinnerCurrentUser = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE4F0EA), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D10194F),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26.5),
        child: Stack(
          children: [
            // Left subtle mint ambient gradient glow
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 140,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE6FAF0), Color(0x00FFFFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // Right subtle rose ambient gradient glow
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 140,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFF0F2), Color(0x00FFFFFF)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                children: [
                  // Left Player (Winner)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BattlePlayerAvatar(
                          size: 64,
                          isCurrentUser: isWinnerCurrentUser,
                          hasCrown: true,
                          avatarUrl: winnerAvatar,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            winnerName,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.battleNavy,
                              letterSpacing: -0.2,
                              fontFamily: 'Inter',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6F6E5),
                              borderRadius: AppRadii.borderPill,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFF00B96B), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '$winnerScore pts',
                                  style: const TextStyle(
                                    color: Color(0xFF008C52),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center 3D VS
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Battle3DVsBadge(width: 52, height: 48),
                  ),

                  // Right Player (Loser / Opponent)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BattlePlayerAvatar(
                          size: 64,
                          isCurrentUser: !isWinnerCurrentUser,
                          hasCrown: false,
                          avatarUrl: loserAvatar,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            loserName,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.battleNavy,
                              letterSpacing: -0.2,
                              fontFamily: 'Inter',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE5E8),
                              borderRadius: AppRadii.borderPill,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFFFF385C), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '$loserScore pts',
                                  style: const TextStyle(
                                    color: Color(0xFFD61F3D),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
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
    );
  }
}

/// Reward Summary Card: Coin Stack + "+100 Coins"
class BattleRewardSummaryCard extends StatelessWidget {
  final int coinsWon;
  final bool isVictory;

  const BattleRewardSummaryCard({
    super.key,
    required this.coinsWon,
    this.isVictory = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: AppColors.battleBorder, width: 1.2),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          // 3D Coin Stack with sparkles
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFFFFBEB),
              shape: BoxShape.circle,
            ),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 6,
                  right: 6,
                  child: Text('✨', style: TextStyle(fontSize: 13)),
                ),
                Positioned(
                  bottom: 10,
                  child: Text('🪙', style: TextStyle(fontSize: 38)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Win Text & Encouragement
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isVictory ? 'You won' : (coinsWon == 0 ? 'Match Tied' : 'Entry Lost'),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.battleSecondaryText,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 5),
                      Text(
                        isVictory ? '+$coinsWon Coins' : (coinsWon == 0 ? '0 Coins' : '-$coinsWon Coins'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isVictory ? const Color(0xFF00A859) : const Color(0xFFEF4444),
                          letterSpacing: -0.3,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FBF2),
                    borderRadius: AppRadii.borderPill,
                  ),
                  child: Text(
                    isVictory
                        ? 'Great job! Keep playing to climb the ranks.'
                        : 'Review answers and challenge another player.',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF047857),
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
