import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import 'battle_wave_card.dart';

/// 1v1 Battle Arena Player Versus Card
/// Features side-by-side players with crowns, score pills, round dots,
/// and a centered 3D VS badge with animated countdown ring.
class BattleVersusCard extends StatelessWidget {
  final String playerName;
  final int playerScore;
  final List<bool?> playerRounds;
  final bool isPlayerLeading;
  final String? playerAvatarUrl;

  final String opponentName;
  final int opponentScore;
  final List<bool?> opponentRounds;
  final bool isOpponentLeading;
  final String? opponentAvatarUrl;

  final int remainingSeconds;
  final int totalTurnSeconds;

  const BattleVersusCard({
    super.key,
    required this.playerName,
    required this.playerScore,
    this.playerRounds = const [null, null, null, null, null],
    this.isPlayerLeading = false,
    this.playerAvatarUrl,
    required this.opponentName,
    required this.opponentScore,
    this.opponentRounds = const [null, null, null, null, null],
    this.isOpponentLeading = false,
    this.opponentAvatarUrl,
    required this.remainingSeconds,
    this.totalTurnSeconds = 15,
  });

  @override
  Widget build(BuildContext context) {
    return BattleWaveCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Left Player (User)
          Expanded(
            child: _buildPlayerColumn(
              name: playerName,
              score: playerScore,
              rounds: playerRounds,
              isLeading: isPlayerLeading,
              isCurrentUser: true,
              avatarBg: const Color(0xFF34D399),
            ),
          ),

          // 2. Center VS & Circular Countdown Timer Ring
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 3D VS Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA000), Color(0xFFFF6F00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadii.borderPill,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6F00).withAlpha(80),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    '⚡ VS ⚡',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Circular Countdown Timer Ring
                _buildCircularTimerRing(),
              ],
            ),
          ),

          // 3. Right Player (Opponent)
          Expanded(
            child: _buildPlayerColumn(
              name: opponentName,
              score: opponentScore,
              rounds: opponentRounds,
              isLeading: isOpponentLeading,
              isCurrentUser: false,
              avatarBg: const Color(0xFFF87171),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerColumn({
    required String name,
    required int score,
    required List<bool?> rounds,
    required bool isLeading,
    required bool isCurrentUser,
    required Color avatarBg,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with Crown
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarBg.withAlpha(50),
                border: Border.all(
                  color: isLeading ? const Color(0xFFFFC107) : avatarBg,
                  width: isLeading ? 2.5 : 2.0,
                ),
              ),
              child: Center(
                child: Icon(
                  isCurrentUser ? Icons.face_rounded : Icons.face_5_rounded,
                  size: 38,
                  color: avatarBg,
                ),
              ),
            ),
            if (isLeading)
              Positioned(
                top: -10,
                left: -4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC107),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('👑', style: TextStyle(fontSize: 13)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        // Player Name
        Text(
          name,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.battleNavy,
            fontFamily: 'Inter',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Score Pill (Green for user/high, Red/Pink for opponent)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? const Color(0xFFD1FAE5)
                : const Color(0xFFFFE4E6),
            borderRadius: AppRadii.borderPill,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                color: isCurrentUser
                    ? const Color(0xFF059669)
                    : const Color(0xFFE11D48),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '$score pts',
                style: TextStyle(
                  color: isCurrentUser
                      ? const Color(0xFF065F46)
                      : const Color(0xFF9F1239),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // 5 Round Indicator Dots
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final result = index < rounds.length ? rounds[index] : null;
            Color dotColor;
            if (result == true) {
              dotColor = const Color(0xFF10B981); // Won
            } else if (result == false) {
              dotColor = const Color(0xFFEF4444); // Lost
            } else {
              dotColor = const Color(0xFFD1D5DB); // Pending
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCircularTimerRing() {
    final progress = (remainingSeconds / math.max(1, totalTurnSeconds)).clamp(
      0.0,
      1.0,
    );
    final isLowTime = remainingSeconds <= 4;
    final ringColor = isLowTime
        ? const Color(0xFFEF4444)
        : const Color(0xFF00C975);

    return Container(
      width: 58,
      height: 58,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          SizedBox(
            width: 54,
            height: 54,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 4.5,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFE5E7EB)),
            ),
          ),
          // Active progress arc
          SizedBox(
            width: 54,
            height: 54,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4.5,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation(ringColor),
            ),
          ),
          // Number in center
          Text(
            '$remainingSeconds',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isLowTime ? const Color(0xFFEF4444) : AppColors.battleNavy,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
