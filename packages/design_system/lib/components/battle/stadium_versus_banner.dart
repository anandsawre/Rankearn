import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// Stadium-themed 1v1 Versus Banner for Live Arena Quiz Battle
/// Matches Reference Image 2:
/// - Stadium field backdrop with floodlights, stadium lights, crowd silhouettes
/// - Center: Golden shield crest "1v1 Live Arena" with crown & crossed swords
/// - Dramatic 3D golden "VS" with electric lightning bolt
/// - Left Player: Vikram Singh with crown, 10 pts, 5 round dots
/// - Right Player: Amit Verma (Rank #3421), 0 pts, 5 round dots
class StadiumVersusBanner extends StatelessWidget {
  final String playerName;
  final int playerScore;
  final List<bool?> playerRounds;
  final bool isPlayerLeading;
  final String? playerAvatarUrl;

  final String opponentName;
  final int opponentScore;
  final String opponentRank;
  final List<bool?> opponentRounds;
  final bool isOpponentLeading;
  final String? opponentAvatarUrl;

  const StadiumVersusBanner({
    super.key,
    required this.playerName,
    required this.playerScore,
    this.playerRounds = const [true, true, true, null, null],
    this.isPlayerLeading = true,
    this.playerAvatarUrl,
    required this.opponentName,
    required this.opponentScore,
    this.opponentRank = 'Rank #3421',
    this.opponentRounds = const [false, null, null, null, null],
    this.isOpponentLeading = false,
    this.opponentAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;
        final isMobile = constraints.maxWidth < 600;

        return Container(
          width: double.infinity,
          height: isDesktop ? 154 : (isMobile ? 150 : 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A10194F),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // 1. Stadium Backdrop with Floodlights & Turf
                Positioned.fill(
                  child: CustomPaint(
                    painter: _StadiumBackdropPainter(),
                  ),
                ),

                // 2. Center Stadium Crest & 3D VS Lightning Emblem
                Positioned(
                  top: 6,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildCenterStadiumCrest(isDesktop),
                  ),
                ),

                // 3. Player Cards (Left & Right)
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 20 : 10,
                      vertical: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Player Card (Vikram Singh)
                        _buildPlayerPod(
                          name: playerName,
                          score: playerScore,
                          rounds: playerRounds,
                          isLeading: isPlayerLeading,
                          isCurrentUser: true,
                          isDesktop: isDesktop,
                        ),

                        // Center Spacer for Crest & VS
                        SizedBox(width: isDesktop ? 130 : (isMobile ? 70 : 90)),

                        // Right Player Card (Amit Verma)
                        _buildPlayerPod(
                          name: opponentName,
                          rank: opponentRank,
                          score: opponentScore,
                          rounds: opponentRounds,
                          isLeading: isOpponentLeading,
                          isCurrentUser: false,
                          isDesktop: isDesktop,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenterStadiumCrest(bool isDesktop) {
    final crestWidth = isDesktop ? 116.0 : 96.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Golden Shield Crest with Crown & Crossed Swords
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Shield Container
            Container(
              width: crestWidth,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                  bottom: Radius.circular(20),
                ),
                border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66FFD700),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '1v1',
                    style: TextStyle(
                      color: Color(0xFFFFE600),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B96B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Live Arena',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top Crown on Shield
            Positioned(
              top: -10,
              child: Container(
                padding: const EdgeInsets.all(3.5),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB800),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x66FFA000), blurRadius: 6),
                  ],
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),

        // 3D Golden VS with Lightning Bolt
        const Battle3DVsBadge(
          width: 44,
          height: 36,
        ),
      ],
    );
  }

  Widget _buildPlayerPod({
    required String name,
    String? rank,
    required int score,
    required List<bool?> rounds,
    required bool isLeading,
    required bool isCurrentUser,
    required bool isDesktop,
  }) {
    final podWidth = isDesktop ? 172.0 : 124.0;

    return Container(
      width: podWidth,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 10 : 6,
        vertical: isDesktop ? 5 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(240),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrentUser ? const Color(0xFF86EFAC) : const Color(0xFFFDA4AF),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 3D Cartoon Avatar with Crown
          BattlePlayerAvatar(
            size: isDesktop ? 40 : 34,
            isCurrentUser: isCurrentUser,
            hasCrown: isLeading,
            avatarUrl: isCurrentUser ? playerAvatarUrl : opponentAvatarUrl,
          ),
          const SizedBox(height: 3),

          // Name
          Text(
            name,
            style: TextStyle(
              fontSize: isDesktop ? 13 : 11.5,
              fontWeight: FontWeight.w900,
              color: AppColors.battleNavy,
              fontFamily: 'Inter',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          // Rank if available
          if (rank != null && isDesktop) ...[
            Text(
              rank,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.battleSecondaryText,
                fontFamily: 'Inter',
              ),
            ),
          ],
          const SizedBox(height: 3),

          // Score Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
                  size: 12,
                ),
                const SizedBox(width: 3),
                Text(
                  '$score pts',
                  style: TextStyle(
                    color: isCurrentUser ? const Color(0xFF008C52) : const Color(0xFFD61F3D),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // 5 Round Dots
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final result = index < rounds.length ? rounds[index] : null;
              Color dotColor;
              if (result == true) {
                dotColor = const Color(0xFF00B96B);
              } else if (result == false) {
                dotColor = const Color(0xFFFF385C);
              } else {
                dotColor = const Color(0xFFE2E8F0);
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6.5,
                height: 6.5,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Custom Stadium Backdrop Painter with floodlights, stadium lights & turf
class _StadiumBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep blue esports night sky & stadium stands
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0A192F), Color(0xFF1E3A8A), Color(0xFF065F46)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Stadium Floodlights Beams from top corners
    final beamPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x5560A5FA), Color(0x0060A5FA)],
        radius: 0.8,
      ).createShader(Rect.fromLTWH(0, 0, size.width * 0.4, size.height));
    canvas.drawCircle(Offset(size.width * 0.15, 0), size.width * 0.35, beamPaint);

    final beamPaintRight = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x5560A5FA), Color(0x0060A5FA)],
        radius: 0.8,
      ).createShader(Rect.fromLTWH(size.width * 0.6, 0, size.width * 0.4, size.height));
    canvas.drawCircle(Offset(size.width * 0.85, 0), size.width * 0.35, beamPaintRight);

    // 3. Green Turf Pitch in bottom center
    final turfPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF059669)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.45));

    final turfPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.72)
      ..quadraticBezierTo(size.width / 2, size.height * 0.52, size.width, size.height * 0.72)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(turfPath, turfPaint);

    // 4. Center Field White Arc
    final linePaint = Paint()
      ..color = Colors.white.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.85),
        width: 140,
        height: 70,
      ),
      0,
      3.14159,
      false,
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3D Golden VS Badge with Electric Lightning Bolt
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
              child: Text('VS', style: TextStyle(fontSize: 1)),
            ),
            CustomPaint(
              size: Size(width, height),
              painter: _Vs3DLightningPainter(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Vs3DLightningPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Electric Lightning Bolt
    final lPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF050), Color(0xFFFFB300)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final lGlow = Paint()
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

    canvas.drawPath(lPath, lGlow);
    canvas.drawPath(lPath, lPaint);

    // 2. 3D VS Text
    const textStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
      fontFamily: 'Inter',
      letterSpacing: -1.0,
    );

    final shadowSpan = TextSpan(
      text: 'VS',
      style: textStyle.copyWith(foreground: Paint()..color = const Color(0xFFB84000)),
    );
    final shadowPainter = TextPainter(text: shadowSpan, textDirection: TextDirection.ltr)..layout();
    shadowPainter.paint(canvas, Offset(cx - shadowPainter.width / 2 + 1.5, cy - shadowPainter.height / 2 + 1.5));

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
    final goldPainter = TextPainter(text: goldSpan, textDirection: TextDirection.ltr)..layout();
    goldPainter.paint(canvas, Offset(cx - goldPainter.width / 2, cy - goldPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Player Avatar with Crown Badge
class BattlePlayerAvatar extends StatelessWidget {
  final double size;
  final bool isCurrentUser;
  final bool hasCrown;
  final String? avatarUrl;

  const BattlePlayerAvatar({
    super.key,
    this.size = 64,
    this.isCurrentUser = true,
    this.hasCrown = false,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
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
            border: Border.all(
              color: isCurrentUser ? const Color(0xFF86EFAC) : const Color(0xFFFDA4AF),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withAlpha(50),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              isCurrentUser ? Icons.face_rounded : Icons.face_5_rounded,
              size: size * 0.65,
              color: Colors.white,
            ),
          ),
        ),

        // Golden Crown at top-left
        if (hasCrown)
          Positioned(
            top: -4,
            left: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Color(0xFFFFB800),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x33000000), blurRadius: 4),
                ],
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 13),
            ),
          ),
      ],
    );
  }
}
