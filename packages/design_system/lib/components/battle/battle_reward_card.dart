import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import 'battle_wave_card.dart';

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
    return BattleWaveCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          // Left Player (Winner)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF34D399).withAlpha(50),
                        border: Border.all(color: const Color(0xFFFFC107), width: 2.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.face_rounded, size: 38, color: Color(0xFF059669)),
                      ),
                    ),
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
                const SizedBox(height: 8),
                Text(
                  winnerName,
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
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: AppRadii.borderPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFF059669), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$winnerScore pts',
                          style: const TextStyle(
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          ),

          // Right Player (Loser / Opponent)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF87171).withAlpha(50),
                    border: Border.all(color: const Color(0xFFF87171), width: 2.0),
                  ),
                  child: const Center(
                    child: Icon(Icons.face_5_rounded, size: 38, color: Color(0xFFDC2626)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loserName,
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
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: AppRadii.borderPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFE11D48), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$loserScore pts',
                          style: const TextStyle(
                            color: Color(0xFF9F1239),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
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
    );
  }
}



/// Reward Summary Card: Minted Gold Coin + "+100 Coins" with Royal Violet & Sunset Amber Waves
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: const Color(0xFFE2E8F0).withAlpha(180), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
          BoxShadow(
            color: Color(0x087C3AED),
            blurRadius: 22,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Stack(
          children: [
            // Royal Violet & Sunset Amber Wave Background
            Positioned.fill(
              child: CustomPaint(
                painter: _RewardCardWavePainter(isVictory: isVictory),
              ),
            ),

            // Foreground Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  // 3D Minted Gold Coin Badge with Temple Emblem
                  _RewardCoinBadge(isVictory: isVictory),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.battleSecondaryText,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isVictory ? '+$coinsWon Coins' : (coinsWon == 0 ? '0 Coins' : '-$coinsWon Coins'),
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              color: isVictory
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFDC2626),
                              letterSpacing: -0.3,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: isVictory ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                            borderRadius: AppRadii.borderPill,
                            border: Border.all(
                              color: isVictory
                                  ? const Color(0xFFA7F3D0)
                                  : const Color(0xFFFED7AA),
                              width: 0.9,
                            ),
                          ),
                          child: Text(
                            isVictory
                                ? 'Great job! Keep playing to climb the ranks.'
                                : 'Review answers and challenge another player.',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: isVictory ? const Color(0xFF047857) : const Color(0xFFC2410C),
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
            ),
          ],
        ),
      ),
    );
  }
}

/// 3D Minted Gold Medallion Badge with Greek Temple Emblem
class _RewardCoinBadge extends StatelessWidget {
  final bool isVictory;

  const _RewardCoinBadge({required this.isVictory});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFFFFFBEB),
            Color(0xFFFEF3C7),
            Color(0xFFFDE68A),
          ],
        ),
        border: Border.all(color: const Color(0xFFFBBF24), width: 2.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withAlpha(70),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFDF00),
                Color(0xFFF59E0B),
                Color(0xFFD97706),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(35),
                blurRadius: 3,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Inner coin rim
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFEF08A).withAlpha(180),
                    width: 1.2,
                  ),
                ),
              ),
              // Embossed classical temple emblem matching reference
              Icon(
                Icons.account_balance_rounded,
                size: 22,
                color: const Color(0xFFFFFBEB),
                shadows: [
                  Shadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Royal Violet and Sunset Amber Dual-Ribbon Wave Custom Painter for Reward Card
class _RewardCardWavePainter extends CustomPainter {
  final bool isVictory;

  const _RewardCardWavePainter({required this.isVictory});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // -------------------------------------------------------------------------
    // 0. Ambient Halos
    // -------------------------------------------------------------------------
    // Warm Golden Sunburst behind the coin badge on the left
    final coinGlow = Paint()
      ..isAntiAlias = true
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFBBF24).withAlpha(55),
          const Color(0xFFF59E0B).withAlpha(25),
          const Color(0xFFF59E0B).withAlpha(0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.12, h * 0.50), radius: w * 0.30));
    canvas.drawCircle(Offset(w * 0.12, h * 0.50), w * 0.30, coinGlow);

    // Soft Electric Violet Ambient Halo on the right
    final violetHalo = Paint()
      ..isAntiAlias = true
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFC4B5FD).withAlpha(45),
          const Color(0xFF8B5CF6).withAlpha(20),
          Colors.transparent,
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.88, h * 0.40), radius: w * 0.32));
    canvas.drawCircle(Offset(w * 0.88, h * 0.40), w * 0.32, violetHalo);

    // -------------------------------------------------------------------------
    // 1. LEFT SIDE - Sunset Amber / Golden Honey Wave (Layer 1)
    // Enters left edge at y = 0.36 * h, curves gently under the coin and across
    // -------------------------------------------------------------------------
    final goldWave1 = Path();
    goldWave1.moveTo(0, h * 0.36);
    goldWave1.cubicTo(
      w * 0.12, h * 0.50,
      w * 0.24, h * 0.78,
      w * 0.45, h * 0.84,
    );
    goldWave1.cubicTo(
      w * 0.65, h * 0.90,
      w * 0.82, h * 0.96,
      w, h * 0.98,
    );
    goldWave1.lineTo(w, h);
    goldWave1.lineTo(0, h);
    goldWave1.close();

    final goldPaint1 = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFEF3C7).withAlpha(190),
          const Color(0xFFFDE68A).withAlpha(140),
          const Color(0xFFFBBF24).withAlpha(80),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(goldWave1, goldPaint1);

    // -------------------------------------------------------------------------
    // 2. RIGHT SIDE - Royal Purple / Electric Violet Wave (Layer 1)
    // Enters right edge high at y = 0.22 * h, curves across towards the left
    // -------------------------------------------------------------------------
    final purpleWave1 = Path();
    purpleWave1.moveTo(w, h * 0.22);
    purpleWave1.cubicTo(
      w * 0.88, h * 0.38,
      w * 0.76, h * 0.68,
      w * 0.58, h * 0.78,
    );
    purpleWave1.cubicTo(
      w * 0.42, h * 0.86,
      w * 0.24, h * 0.94,
      0, h * 0.98,
    );
    purpleWave1.lineTo(0, h);
    purpleWave1.lineTo(w, h);
    purpleWave1.close();

    final purplePaint1 = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFEDE9FE).withAlpha(200),
          const Color(0xFFDDD6FE).withAlpha(150),
          const Color(0xFFC4B5FD).withAlpha(90),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(purpleWave1, purplePaint1);

    // -------------------------------------------------------------------------
    // 3. CENTER BOTTOM - Warm Amber-Violet Harmonic Blend Glow
    // -------------------------------------------------------------------------
    final centerBlend = Paint()
      ..isAntiAlias = true
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFDE68A).withAlpha(110),
          const Color(0xFFDDD6FE).withAlpha(70),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.50, h * 0.92), radius: w * 0.26));
    canvas.drawCircle(Offset(w * 0.50, h * 0.92), w * 0.26, centerBlend);

    // -------------------------------------------------------------------------
    // 4. LEFT SIDE - Rich Amber Gold Crest Wave (Layer 2)
    // Enters at y = 0.54 * h
    // -------------------------------------------------------------------------
    final goldWave2 = Path();
    goldWave2.moveTo(0, h * 0.54);
    goldWave2.cubicTo(
      w * 0.10, h * 0.66,
      w * 0.22, h * 0.86,
      w * 0.38, h * 0.88,
    );
    goldWave2.cubicTo(
      w * 0.50, h * 0.90,
      w * 0.62, h * 0.96,
      w * 0.75, h * 0.98,
    );
    goldWave2.lineTo(w * 0.75, h);
    goldWave2.lineTo(0, h);
    goldWave2.close();

    final goldPaint2 = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFBBF24).withAlpha(150),
          const Color(0xFFF59E0B).withAlpha(100),
          const Color(0xFFD97706).withAlpha(50),
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 0.75, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(goldWave2, goldPaint2);

    // Specular White Highlight along Gold Wave L2
    final goldHighlight = Path();
    goldHighlight.moveTo(0, h * 0.54);
    goldHighlight.cubicTo(
      w * 0.10, h * 0.66,
      w * 0.22, h * 0.86,
      w * 0.38, h * 0.88,
    );
    goldHighlight.cubicTo(
      w * 0.50, h * 0.90,
      w * 0.62, h * 0.96,
      w * 0.70, h * 0.98,
    );
    final goldHighlightPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          Colors.white.withAlpha(235),
          Colors.white.withAlpha(150),
          Colors.white.withAlpha(0),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, h * 0.54, w * 0.70, h * 0.46));
    canvas.drawPath(goldHighlight, goldHighlightPaint);

    // -------------------------------------------------------------------------
    // 5. RIGHT SIDE - Vibrant Deep Violet / Amethyst Wave (Layer 2)
    // Enters at y = 0.42 * h
    // -------------------------------------------------------------------------
    final purpleWave2 = Path();
    purpleWave2.moveTo(w, h * 0.42);
    purpleWave2.cubicTo(
      w * 0.89, h * 0.55,
      w * 0.78, h * 0.78,
      w * 0.64, h * 0.84,
    );
    purpleWave2.cubicTo(
      w * 0.52, h * 0.88,
      w * 0.40, h * 0.95,
      w * 0.28, h * 0.98,
    );
    purpleWave2.lineTo(w * 0.28, h);
    purpleWave2.lineTo(w, h);
    purpleWave2.close();

    final purplePaint2 = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFA78BFA).withAlpha(160),
          const Color(0xFF8B5CF6).withAlpha(110),
          const Color(0xFF7C3AED).withAlpha(55),
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 0.75, 1.0],
        begin: Alignment.centerRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(purpleWave2, purplePaint2);

    // Specular White Highlight along Purple Wave R2
    final purpleHighlight = Path();
    purpleHighlight.moveTo(w, h * 0.42);
    purpleHighlight.cubicTo(
      w * 0.89, h * 0.55,
      w * 0.78, h * 0.78,
      w * 0.64, h * 0.84,
    );
    purpleHighlight.cubicTo(
      w * 0.52, h * 0.88,
      w * 0.40, h * 0.95,
      w * 0.32, h * 0.98,
    );
    final purpleHighlightPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          Colors.white.withAlpha(235),
          Colors.white.withAlpha(150),
          Colors.white.withAlpha(0),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(w * 0.32, h * 0.42, w * 0.68, h * 0.58));
    canvas.drawPath(purpleHighlight, purpleHighlightPaint);
  }

  @override
  bool shouldRepaint(covariant _RewardCardWavePainter oldDelegate) =>
      oldDelegate.isVictory != isVictory;
}
