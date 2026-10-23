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
  final int timeLimitSeconds;
  final String questionText;

  const BattleQuestionCard({
    super.key,
    required this.currentRound,
    this.totalRounds = 5,
    required this.stakeCoins,
    this.subject = 'General Science',
    this.timeLimitSeconds = 12,
    required this.questionText,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.borderXl,
            boxShadow: AppShadows.subtle,
            border: Border.all(color: AppColors.battleBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Subject Badge + Question Timer Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Subject Chip (e.g. 📖 General Science)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: AppRadii.borderPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📖', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 5),
                        Text(
                          subject,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF047857),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Timer Badge (e.g. ⏱️ 12s)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: AppRadii.borderPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⏱️', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 5),
                        Text(
                          '${timeLimitSeconds}s',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Question Text
              Text(
                questionText,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppColors.battleNavy,
                  height: 1.35,
                  letterSpacing: -0.2,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
