import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';

/// 1v1 Arena Question Card & Round Stake Header Bar
class BattleQuestionCard extends StatelessWidget {
  final int currentRound;
  final int totalRounds;
  final int stakeCoins;
  final String subject;
  final int? timeLimitSeconds;
  final String questionText;
  final VoidCallback? onHintTap;

  const BattleQuestionCard({
    super.key,
    required this.currentRound,
    this.totalRounds = 5,
    required this.stakeCoins,
    this.subject = 'General Science',
    this.timeLimitSeconds = 12,
    required this.questionText,
    this.onHintTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentRound / totalRounds).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Round Info & Stake Row (Responsive, no overflow)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Bar chart icon + Round 4 of 5
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bar_chart_rounded, color: AppColors.battleSecondaryText, size: 20),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      'Round $currentRound of $totalRounds',
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
            ),
            const SizedBox(width: 8),

            // Right: Stake: 100 Coins pill
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: AppRadii.borderPill,
                  border: Border.all(color: const Color(0xFFFFE082), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Stake: $stakeCoins Coins',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB45309),
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Animated Round Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            height: 8,
            color: const Color(0xFFE5E7EB),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C975), Color(0xFF00A35E)],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // 2. Question Card Surface
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.borderXl,
            boxShadow: AppShadows.subtle,
            border: Border.all(color: AppColors.battleBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Yellow Bulb Hint Icon (Left of Question)
              GestureDetector(
                onTap: onHintTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14F59E0B),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lightbulb_rounded,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Question Text
              Expanded(
                child: Text(
                  questionText,
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.battleNavy,
                    height: 1.35,
                    letterSpacing: -0.2,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
