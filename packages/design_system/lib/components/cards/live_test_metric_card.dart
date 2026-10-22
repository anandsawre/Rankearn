import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// Individual statistics metric card for the Live Tests tab
class LiveTestMetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const LiveTestMetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderMd,
        border: Border.all(
          color: const Color(0xFFE3EAF7),
          width: 1.1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06101A3A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.borderMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // Leading Icon Container
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Label and Value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Trailing Arrow
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Row of 4 metric cards matching the Live Tests desktop dashboard
class LiveTestMetricsRow extends StatelessWidget {
  final int liveNowCount;
  final String participants;
  final String coinsEarned;
  final String rankPosition;
  final VoidCallback? onLiveNowTap;
  final VoidCallback? onParticipantsTap;
  final VoidCallback? onCoinsTap;
  final VoidCallback? onRankTap;

  const LiveTestMetricsRow({
    super.key,
    this.liveNowCount = 3,
    this.participants = '5.2K',
    this.coinsEarned = '1,250',
    this.rankPosition = '#1256',
    this.onLiveNowTap,
    this.onParticipantsTap,
    this.onCoinsTap,
    this.onRankTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          LiveTestMetricCard(
            icon: Icons.sensors_rounded,
            iconColor: const Color(0xFFF43F5E),
            iconBgColor: const Color(0xFFFFE4E6),
            label: 'Live Now',
            value: '$liveNowCount',
            onTap: onLiveNowTap,
          ),
          LiveTestMetricCard(
            icon: Icons.group_rounded,
            iconColor: const Color(0xFF0284C7),
            iconBgColor: const Color(0xFFE0F2FE),
            label: 'Participants',
            value: participants,
            onTap: onParticipantsTap,
          ),
          LiveTestMetricCard(
            icon: Icons.monetization_on_rounded,
            iconColor: const Color(0xFFF59E0B),
            iconBgColor: const Color(0xFFFEF3C7),
            label: 'Coins Earned',
            value: coinsEarned,
            onTap: onCoinsTap,
          ),
          LiveTestMetricCard(
            icon: Icons.workspace_premium_rounded,
            iconColor: const Color(0xFF8B5CF6),
            iconBgColor: const Color(0xFFEDE9FE),
            label: 'Rank Position',
            value: rankPosition,
            onTap: onRankTap,
          ),
        ];

        // On desktop and wide screens, show 4 cards side by side in a row
        if (constraints.maxWidth >= 640) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }

        // On mobile, show 2x2 grid
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 10),
                Expanded(child: cards[1]),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: cards[2]),
                const SizedBox(width: 10),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      },
    );
  }
}
