import 'package:flutter/material.dart';

/// Individual leaderboard entry row matching the Top Performers reference design
class LeaderboardRow extends StatelessWidget {
  final int rank;
  final String name;
  final int coins;
  final String? avatarUrl;
  final Color? avatarColor;
  final String? initial;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const LeaderboardRow({
    super.key,
    required this.rank,
    required this.name,
    required this.coins,
    this.avatarUrl,
    this.avatarColor,
    this.initial,
    this.isCurrentUser = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color rankBg;
    Color rankTextColor;

    switch (rank) {
      case 1:
        rankBg = const Color(0xFFFEF3C7); // Soft Gold
        rankTextColor = const Color(0xFFB45309);
        break;
      case 2:
        rankBg = const Color(0xFFF1F5F9); // Soft Silver
        rankTextColor = const Color(0xFF64748B);
        break;
      case 3:
        rankBg = const Color(0xFFFFEDD5); // Soft Bronze
        rankTextColor = const Color(0xFFC2410C);
        break;
      default:
        rankBg = const Color(0xFFF1F5F9); // Soft Grey
        rankTextColor = const Color(0xFF64748B);
    }

    final letter =
        initial ?? (name.isNotEmpty ? name.trim()[0].toUpperCase() : '?');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.5, horizontal: 14),
          child: Row(
            children: [
              // 1. Rank Circle Badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rankBg,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: rank >= 10 ? 11 : 12.5,
                      fontWeight: FontWeight.w700,
                      color: rankTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 2. Initial Avatar Circle
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: avatarColor ?? _getAvatarColor(rank),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 3. User Name
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 4. Coin Icon + Coin Amount
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _formatCoins(coins),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(int r) {
    const colors = [
      Color(0xFF3B82F6), // Blue
      Color(0xFFEC4899), // Pink
      Color(0xFF10B981), // Emerald
      Color(0xFF8B5CF6), // Purple
      Color(0xFFF97316), // Orange
      Color(0xFF06B6D4), // Cyan
      Color(0xFF6366F1), // Indigo
      Color(0xFFEF4444), // Red
      Color(0xFF14B8A6), // Teal
      Color(0xFF84CC16), // Lime
    ];
    return colors[(r - 1) % colors.length];
  }

  String _formatCoins(int count) {
    return count.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

/// Top Performers / Weekly Leaderboard Sidebar Card
class WeeklyLeaderboardCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> topUsers;
  final VoidCallback? onViewAll;
  final Function(Map<String, dynamic>)? onUserTap;

  static const List<Map<String, dynamic>> defaultTopUsers = [
    {
      'rank': 1,
      'name': 'Aarav Sharma',
      'coins': 3420,
      'avatarColor': Color(0xFF3B82F6),
      'initial': 'A',
    },
    {
      'rank': 2,
      'name': 'Priya Patel',
      'coins': 2980,
      'avatarColor': Color(0xFFEC4899),
      'initial': 'P',
    },
    {
      'rank': 3,
      'name': 'Vikram Singh (You)',
      'coins': 1450,
      'avatarColor': Color(0xFF10B981),
      'initial': 'V',
      'isCurrentUser': true,
    },
    {
      'rank': 4,
      'name': 'Ananya Mishra',
      'coins': 1320,
      'avatarColor': Color(0xFF8B5CF6),
      'initial': 'A',
    },
    {
      'rank': 5,
      'name': 'Rohan Verma',
      'coins': 1190,
      'avatarColor': Color(0xFFF97316),
      'initial': 'R',
    },
    {
      'rank': 6,
      'name': 'Sneha Reddy',
      'coins': 1050,
      'avatarColor': Color(0xFF06B6D4),
      'initial': 'S',
    },
    {
      'rank': 7,
      'name': 'Rahul Kumar',
      'coins': 980,
      'avatarColor': Color(0xFF6366F1),
      'initial': 'R',
    },
    {
      'rank': 8,
      'name': 'Pooja Gupta',
      'coins': 890,
      'avatarColor': Color(0xFFEF4444),
      'initial': 'P',
    },
    {
      'rank': 9,
      'name': 'Amit Deshmukh',
      'coins': 810,
      'avatarColor': Color(0xFF14B8A6),
      'initial': 'A',
    },
    {
      'rank': 10,
      'name': 'Neha Joshi',
      'coins': 750,
      'avatarColor': Color(0xFF84CC16),
      'initial': 'N',
    },
  ];

  const WeeklyLeaderboardCard({
    super.key,
    this.title = 'Weekly Leaderboard',
    this.topUsers = defaultTopUsers,
    this.onViewAll,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFF59E0B);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(accentColor.withAlpha(18), Colors.white),
            Colors.white,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withAlpha(45), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(14),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          const BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Soft Halo Glow in Top Right
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withAlpha(18),
              ),
            ),
          ),

          // 2. Concentric Arc Ring
          Positioned(
            top: -45,
            right: -45,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withAlpha(16),
                  width: 1.0,
                ),
              ),
            ),
          ),

          // 3. Faint Trophy Watermark Icon in lower-right
          Positioned(
            right: 14,
            bottom: 12,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: -0.12,
                child: Icon(
                  Icons.military_tech_rounded,
                  size: 92,
                  color: accentColor.withAlpha(18),
                ),
              ),
            ),
          ),

          // 4. Foreground Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row Inside the Card
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onViewAll != null)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onViewAll,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2587F8),
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: Color(0xFF2587F8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),

          // User list rows & dividers
          for (int i = 0; i < topUsers.length; i++) ...[
            LeaderboardRow(
              rank: topUsers[i]['rank'] as int,
              name: topUsers[i]['name'] as String,
              coins: topUsers[i]['coins'] as int,
              avatarUrl: topUsers[i]['avatarUrl'] as String?,
              avatarColor: topUsers[i]['avatarColor'] as Color?,
              initial: topUsers[i]['initial'] as String?,
              isCurrentUser: topUsers[i]['isCurrentUser'] as bool? ?? false,
              onTap: () => onUserTap?.call(topUsers[i]),
            ),
            if (i < topUsers.length - 1)
              const Divider(
                height: 1,
                thickness: 0.8,
                color: Color(0xFFF1F5F9),
              ),
          ],
        ],
      ),
        ],
      ),
    );
  }
}
