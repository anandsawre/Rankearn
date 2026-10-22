import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// Individual leaderboard entry row
class LeaderboardRow extends StatelessWidget {
  final int rank;
  final String name;
  final int coins;
  final String? avatarUrl;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const LeaderboardRow({
    super.key,
    required this.rank,
    required this.name,
    required this.coins,
    this.avatarUrl,
    this.isCurrentUser = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color rankBg;
    Color rankTextColor;

    switch (rank) {
      case 1:
        rankBg = const Color(0xFFFEF3C7);
        rankTextColor = const Color(0xFFD97706);
        break;
      case 2:
        rankBg = const Color(0xFFF1F5F9);
        rankTextColor = const Color(0xFF64748B);
        break;
      case 3:
        rankBg = const Color(0xFFFFEDD5);
        rankTextColor = const Color(0xFFEA580C);
        break;
      default:
        rankBg = const Color(0xFFF8FAFC);
        rankTextColor = const Color(0xFF94A3B8);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
        child: Row(
          children: [
            // Rank Badge Circle
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rankBg,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: rank >= 10 ? 10.5 : 12,
                    fontWeight: FontWeight.w900,
                    color: rankTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // User Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEDE9FE),
                border: Border.all(
                  color: isCurrentUser ? AppColors.brandGreen : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              child: ClipOval(
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: const Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // User Name
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isCurrentUser ? FontWeight.w900 : FontWeight.w700,
                  color: isCurrentUser ? AppColors.brandGreen : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Coin Indicator + Value
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFEF3C7),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.monetization_on_rounded,
                      color: Color(0xFFF59E0B),
                      size: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _formatCoins(coins),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCoins(int count) {
    if (count >= 1000) {
      final whole = count ~/ 1000;
      final remainder = (count % 1000) ~/ 100;
      if (remainder == 0) {
        return '$whole,000';
      }
      return count.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    }
    return '$count';
  }
}

/// Weekly Leaderboard Sidebar Card
class WeeklyLeaderboardCard extends StatelessWidget {
  final List<Map<String, dynamic>> topUsers;
  final VoidCallback? onViewAll;
  final Function(Map<String, dynamic>)? onUserTap;

  const WeeklyLeaderboardCard({
    super.key,
    this.topUsers = const [
      {'rank': 1, 'name': 'Aarav Sharma', 'coins': 3420},
      {'rank': 2, 'name': 'Priya Patel', 'coins': 2980},
      {'rank': 3, 'name': 'Vikram Singh', 'coins': 1450},
      {'rank': 4, 'name': 'Rohit Rai', 'coins': 1320},
      {'rank': 5, 'name': 'Sneha Verma', 'coins': 1210},
      {'rank': 6, 'name': 'Amit Kumar', 'coins': 1150},
      {'rank': 7, 'name': 'Ananya Gupta', 'coins': 980},
      {'rank': 8, 'name': 'Rahul Mishra', 'coins': 890},
      {'rank': 9, 'name': 'Pooja Yadav', 'coins': 760},
      {'rank': 10, 'name': 'Karan Mehta', 'coins': 650},
    ],
    this.onViewAll,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(
          color: const Color(0xFFE3EAF7),
          width: 1.1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06101A3A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.bar_chart_rounded,
                      color: Color(0xFF2587F8),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Weekly Leaderboard',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
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
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: const [
                          Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: Color(0xFF6366F1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // User list
          Column(
            children: topUsers.map((user) {
              return LeaderboardRow(
                rank: user['rank'] as int,
                name: user['name'] as String,
                coins: user['coins'] as int,
                avatarUrl: user['avatarUrl'] as String?,
                isCurrentUser: user['isCurrentUser'] as bool? ?? false,
                onTap: () => onUserTap?.call(user),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
