import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF6),
        borderRadius: AppRadii.borderPill,
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.2),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.battleNavy,
                fontFamily: 'Inter',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Final Player Comparison Card on Victory Screen
/// Direct visual parity with Reference Image 1:
/// - Left: Vikram Singh (User) with crown, 10 pts green badge, 5 round status indicators
/// - Center: 3D electric lightning bolt VS emblem
/// - Right: Amit Verma (Rank #4) with red avatar ring, score badge, 5 round status indicators
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
    // Current user is always on the left, opponent on the right
    final leftName = isWinnerCurrentUser ? winnerName : loserName;
    final leftScore = isWinnerCurrentUser ? winnerScore : loserScore;
    final rightName = isWinnerCurrentUser ? loserName : winnerName;
    final rightScore = isWinnerCurrentUser ? loserScore : winnerScore;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: AppColors.battleBorder, width: 1.2),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Player: Current User (Vikram Singh)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD1FAE5),
                        border: Border.all(color: const Color(0xFF10B981), width: 2.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.face_rounded, size: 34, color: Color(0xFF059669)),
                      ),
                    ),
                    if (isWinnerCurrentUser)
                      Positioned(
                        top: -6,
                        left: -4,
                        child: Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFB800),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        leftName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.battleNavy,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: AppRadii.borderPill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFF059669), size: 13),
                            const SizedBox(width: 3),
                            Text(
                              '$leftScore pts',
                              style: const TextStyle(
                                color: Color(0xFF065F46),
                                fontWeight: FontWeight.w900,
                                fontSize: 11.5,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      // 5 Question status dots
                      Row(
                        children: const [
                          _Dot(color: Color(0xFF10B981)),
                          SizedBox(width: 4),
                          _Dot(color: Color(0xFF10B981)),
                          SizedBox(width: 4),
                          _Dot(color: Color(0xFF10B981)),
                          SizedBox(width: 4),
                          _Dot(color: Color(0xFFCBD5E1)),
                          SizedBox(width: 4),
                          _Dot(color: Color(0xFFCBD5E1)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Center 3D Electric VS Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadii.borderPill,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33EA580C),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                  Text(
                    'VS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),

          // Right Player: Opponent (Amit Verma)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        rightName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.battleNavy,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4E6),
                          borderRadius: AppRadii.borderPill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFE11D48), size: 13),
                            const SizedBox(width: 3),
                            Text(
                              '$rightScore pts',
                              style: const TextStyle(
                                color: Color(0xFF9F1239),
                                fontWeight: FontWeight.w900,
                                fontSize: 11.5,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      // 5 Question status dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          _Dot(color: Color(0xFFEF4444)),
                          SizedBox(width: 4),
                          _Dot(color: Color(0xFFCBD5E1)),
                          SizedBox(width: 4),
                          _Dot(color: Color(0xFFCBD5E1)),
                          SizedBox(width: 4),
                          _Dot(color: Color(0xFFCBD5E1)),
                          SizedBox(width: 4),
                          _Dot(color: Color(0xFFCBD5E1)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFE4E6),
                    border: Border.all(color: const Color(0xFFF43F5E), width: 2.0),
                  ),
                  child: const Center(
                    child: Icon(Icons.face_5_rounded, size: 34, color: Color(0xFFE11D48)),
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

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Reward Summary Card: Coin Stack + "+100 Coins"
/// Direct visual parity with Reference Image 1:
/// - Left: 3D Golden coin stack with sparkles
/// - Right: "You won", "+100 Coins" and encouragement pill
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: AppColors.battleBorder, width: 1.2),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          // 3D Coin Stack Medallion
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFDE047), Color(0xFFCA8A04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33CA8A04),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.monetization_on_rounded, color: Colors.white, size: 34),
            ),
          ),
          const SizedBox(width: 16),

          // Win Text & Encouragement
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isVictory ? 'You won' : (coinsWon == 0 ? 'Match Tied' : 'Entry Lost'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.battleSecondaryText,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      isVictory ? '+$coinsWon Coins' : (coinsWon == 0 ? '0 Coins' : '-$coinsWon Coins'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isVictory
                            ? const Color(0xFF008C52)
                            : (coinsWon == 0 ? const Color(0xFF2563EB) : const Color(0xFFDC2626)),
                        fontFamily: 'Inter',
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: AppRadii.borderPill,
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Text(
                          isVictory ? 'Great job! Keep playing to climb the ranks.' : 'Review answers and challenge another player.',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                            fontFamily: 'Inter',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
}
