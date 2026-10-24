import 'package:flutter/material.dart';

/// Individual player ranking card for the "Top Players" leaderboard section.
class BattlePlayerCard extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final String? avatarAssetPath;
  final Color avatarBgColor;
  final VoidCallback? onTap;

  const BattlePlayerCard({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
    this.avatarAssetPath,
    this.avatarBgColor = const Color(0xFFE0F2FE),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EAF8), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                // 1. Rank Badge
                _buildRankBadge(rank),
                const SizedBox(width: 6),

                // 2. Avatar
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: avatarBgColor,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(
                    child: avatarAssetPath != null
                        ? Image.asset(
                            avatarAssetPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildAvatarFallback(),
                          )
                        : _buildAvatarFallback(),
                  ),
                ),
                const SizedBox(width: 6),

                // 3. Name & Coins
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111A4B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.monetization_on_rounded,
                            color: Color(0xFFF59E0B),
                            size: 13,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              _formatScore(score),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111A4B),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Icon(
      rank % 2 == 0 ? Icons.face_3_rounded : Icons.face_rounded,
      color: Colors.white,
      size: 24,
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    Color textColor = Colors.white;

    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFF59E0B); // Gold
        break;
      case 2:
        badgeColor = const Color(0xFF94A3B8); // Silver
        break;
      case 3:
        badgeColor = const Color(0xFFD97706); // Bronze
        break;
      default:
        badgeColor = const Color(0xFFCBD5E1); // Slate
        textColor = const Color(0xFF475569);
        break;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.military_tech_rounded, color: badgeColor, size: 26),
        Positioned(
          top: 3,
          child: Text(
            '$rank',
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  String _formatScore(int num) {
    if (num >= 1000) {
      final str = num.toString();
      final length = str.length;
      return '${str.substring(0, length - 3)},${str.substring(length - 3)}';
    }
    return '$num';
  }
}
