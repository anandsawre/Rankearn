import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// 1v1 Battle Arena Player Versus Card
/// Direct pixel-accurate match with Reference Image 2:
/// - Dual-ambient tinted white card (soft mint left, soft rose right)
/// - 3D Pixar-style cartoon boy avatars with gold crown badge
/// - 3D metallic golden VS emblem with lightning bolt
/// - Circular countdown timer ring with bold seconds in center
/// - Star score pills (mint green for player, soft rose for opponent)
/// - 5 round progress dots
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
    this.totalTurnSeconds = 12,
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

            // Main Content Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
                    ),
                  ),

                  // 2. Center 3D VS & Circular Countdown Timer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 3D Metallic VS with Lightning Bolt
                        const Battle3DVsBadge(
                          width: 52,
                          height: 48,
                        ),
                        const SizedBox(height: 2),

                        // Circular Countdown Timer
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

  Widget _buildPlayerColumn({
    required String name,
    required int score,
    required List<bool?> rounds,
    required bool isLeading,
    required bool isCurrentUser,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 3D Cartoon Avatar with Crown
        BattlePlayerAvatar(
          size: 64,
          isCurrentUser: isCurrentUser,
          hasCrown: isLeading,
          avatarUrl: isCurrentUser ? playerAvatarUrl : opponentAvatarUrl,
        ),
        const SizedBox(height: 8),

        // Player Name (Single line with ellipsis)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            name,
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

        // Score Pill with Star Icon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isCurrentUser ? const Color(0xFFD6F6E5) : const Color(0xFFFFE5E8),
            borderRadius: AppRadii.borderPill,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                color: isCurrentUser ? const Color(0xFF00B96B) : const Color(0xFFFF385C),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '$score pts',
                style: TextStyle(
                  color: isCurrentUser ? const Color(0xFF008C52) : const Color(0xFFD61F3D),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: -0.2,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 5 Round Indicator Dots
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final result = index < rounds.length ? rounds[index] : null;
            Color dotColor;
            if (result == true) {
              dotColor = const Color(0xFF00B96B); // Won
            } else if (result == false) {
              dotColor = const Color(0xFFFF385C); // Lost
            } else {
              dotColor = const Color(0xFFE2E8F0); // Pending
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7.5,
              height: 7.5,
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
    final progress = (remainingSeconds / math.max(1, totalTurnSeconds)).clamp(0.0, 1.0);
    final isLowTime = remainingSeconds <= 3;
    final ringColor = isLowTime ? const Color(0xFFFF385C) : const Color(0xFF00C975);

    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background grey-blue circular track
          SizedBox(
            width: 54,
            height: 54,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 5.5,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFE8EEF5)),
            ),
          ),
          // Active emerald green progress arc
          SizedBox(
            width: 54,
            height: 54,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5.5,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation(ringColor),
            ),
          ),
          // Bold Seconds in center
          Text(
            '$remainingSeconds',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: isLowTime ? const Color(0xFFFF385C) : AppColors.battleNavy,
              letterSpacing: -0.5,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

/// 3D Pixar-Style Character Avatar with Golden Crown Badge
class BattlePlayerAvatar extends StatelessWidget {
  final double size;
  final bool isCurrentUser;
  final bool hasCrown;
  final String? avatarUrl;
  final String? customAsset;

  const BattlePlayerAvatar({
    super.key,
    this.size = 64,
    this.isCurrentUser = true,
    this.hasCrown = false,
    this.avatarUrl,
    this.customAsset,
  });

  @override
  Widget build(BuildContext context) {
    final defaultAsset = isCurrentUser
        ? 'assets/images/battle_player_green.png'
        : 'assets/images/battle_player_red.png';
    final assetPath = customAsset ?? defaultAsset;

    final baseColor = isCurrentUser ? const Color(0xFF00B96B) : const Color(0xFFFF5C5C);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: baseColor,
            boxShadow: [
              BoxShadow(
                color: baseColor.withAlpha(50),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              assetPath,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildVectorFallback(size, isCurrentUser);
              },
            ),
          ),
        ),

        // 3D Golden Crown Badge at top-left
        if (hasCrown)
          Positioned(
            top: -4,
            left: -4,
            child: Container(
              width: size * 0.38,
              height: size * 0.38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFDF00), Color(0xFFFFA000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: CustomPaint(
                  size: Size(size * 0.20, size * 0.16),
                  painter: _CrownSilhouettePainter(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVectorFallback(double size, bool isCurrentUser) {
    final bgColor = isCurrentUser ? const Color(0xFF00B96B) : const Color(0xFFFF5C5C);
    return Container(
      width: size,
      height: size,
      color: bgColor,
      child: Center(
        child: Icon(
          Icons.face_rounded,
          size: size * 0.65,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// 3-Pointed Crown Silhouette Painter
class _CrownSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.85)
      ..lineTo(0, size.height * 0.25)
      ..lineTo(size.width * 0.28, size.height * 0.55)
      ..lineTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.72, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.25)
      ..lineTo(size.width, size.height * 0.85)
      ..close();

    canvas.drawPath(path, paint);

    // Bottom base band
    final bandPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25),
        const Radius.circular(1.5),
      ),
      bandPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3D Metallic Golden VS with Lightning Bolt
class Battle3DVsBadge extends StatelessWidget {
  final double width;
  final double height;

  const Battle3DVsBadge({
    super.key,
    this.width = 52,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'VS',
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Opacity(
              opacity: 0.0,
              child: Text(
                'VS',
                style: TextStyle(fontSize: 1),
              ),
            ),
            Image.asset(
              'assets/images/battle_vs_lightning.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return CustomPaint(
                  size: Size(width, height),
                  painter: _Vs3DLightningPainter(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Fallback 3D Metallic VS Painter with Lightning Bolt
class _Vs3DLightningPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Draw glowing electric yellow lightning bolt in center
    final lightningPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF050), Color(0xFFFFB300)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final lightningGlow = Paint()
      ..color = const Color(0x66FFB300)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final lPath = Path()
      ..moveTo(cx + 2, 0)
      ..lineTo(cx - 8, cy - 2)
      ..lineTo(cx - 1, cy - 1)
      ..lineTo(cx - 7, size.height)
      ..lineTo(cx + 8, cy + 3)
      ..lineTo(cx + 1, cy + 1)
      ..close();

    canvas.drawPath(lPath, lightningGlow);
    canvas.drawPath(lPath, lightningPaint);

    // 2. Draw 3D Metallic 'VS' Text
    const textStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
      fontFamily: 'Inter',
      letterSpacing: -1.0,
    );

    // Dark orange 3D extrusion shadow
    final shadowSpan = TextSpan(
      text: 'VS',
      style: textStyle.copyWith(
        foreground: Paint()..color = const Color(0xFFB84000),
      ),
    );
    final shadowPainter = TextPainter(
      text: shadowSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    shadowPainter.paint(canvas, Offset(cx - shadowPainter.width / 2 + 1.5, cy - shadowPainter.height / 2 + 1.5));

    // Metallic golden face
    final goldSpan = TextSpan(
      text: 'VS',
      style: textStyle.copyWith(
        foreground: Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFEA79), Color(0xFFFF9900)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
      ),
    );
    final goldPainter = TextPainter(
      text: goldSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    goldPainter.paint(canvas, Offset(cx - goldPainter.width / 2, cy - goldPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
