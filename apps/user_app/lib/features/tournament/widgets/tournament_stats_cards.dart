import 'package:flutter/material.dart';

/// Responsive Statistics Cards (4 cards on Desktop, 2 on Mobile)
class TournamentStatsCards extends StatelessWidget {
  final bool isDesktop;
  final int activeCount;
  final int participationCount;
  final String myRank;
  final String totalRewards;

  const TournamentStatsCards({
    super.key,
    required this.isDesktop,
    required this.activeCount,
    required this.participationCount,
    required this.myRank,
    required this.totalRewards,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            child: _buildDesktopCard(
              icon: Icons.emoji_events_rounded,
              iconBgColor: const Color(0xFFF59E0B),
              watermarkIcon: Icons.emoji_events_rounded,
              title: 'Active\nContests',
              value: activeCount.toString(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDesktopCard(
              icon: Icons.people_alt_rounded,
              iconBgColor: const Color(0xFF3B82F6),
              watermarkIcon: Icons.people_alt_rounded,
              title: 'My Participation',
              value: participationCount.toString(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDesktopCard(
              icon: Icons.workspace_premium_rounded,
              iconBgColor: const Color(0xFF8B5CF6),
              watermarkIcon: Icons.workspace_premium_rounded,
              title: 'My Rank',
              value: myRank,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDesktopCard(
              icon: Icons.card_giftcard_rounded,
              iconBgColor: const Color(0xFF10B981),
              watermarkIcon: Icons.card_giftcard_rounded,
              title: 'Total Rewards',
              value: totalRewards,
            ),
          ),
        ],
      );
    }

    // Mobile: 2 Cards Row
    return Row(
      children: [
        Expanded(
          child: _buildMobileCard(
            icon: Icons.emoji_events_rounded,
            iconBgColor: const Color(0xFFF59E0B),
            title: 'Active\nContests',
            value: activeCount.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMobileCard(
            icon: Icons.people_alt_rounded,
            iconBgColor: const Color(0xFF3B82F6),
            title: 'My Participation',
            value: participationCount.toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopCard({
    required IconData icon,
    required Color iconBgColor,
    required IconData watermarkIcon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background subtle watermark icon
          Positioned(
            right: -6,
            bottom: -8,
            child: Icon(
              watermarkIcon,
              size: 54,
              color: const Color(0xFFF1F5F9),
            ),
          ),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -4,
            bottom: -6,
            child: Icon(
              icon,
              size: 46,
              color: const Color(0xFFF1F5F9),
            ),
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
