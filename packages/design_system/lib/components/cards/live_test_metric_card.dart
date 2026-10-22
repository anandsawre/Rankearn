import 'package:flutter/material.dart';
import 'app_metric_card.dart';

/// Individual statistics metric card for the Live Tests tab.
/// Powered by the unified [AppMetricCard] engine.
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
    return AppMetricCard(
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      label: label,
      value: value,
      onTap: onTap,
    );
  }
}

/// 4 Statistics Cards row for Live Tests Tab (Live Now, Participants, Coins, Rank)
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
    return AppMetricsRow(
      breakpoint: 640,
      spacing: 10,
      cards: [
        AppMetricCard(
          icon: Icons.sensors_rounded,
          iconColor: const Color(0xFFF43F5E),
          iconBgColor: const Color(0xFFFFE4E6),
          label: 'Live Now',
          value: '$liveNowCount',
          onTap: onLiveNowTap,
        ),
        AppMetricCard(
          icon: Icons.group_rounded,
          iconColor: const Color(0xFF0284C7),
          iconBgColor: const Color(0xFFE0F2FE),
          label: 'Participants',
          value: participants,
          onTap: onParticipantsTap,
        ),
        AppMetricCard(
          icon: Icons.monetization_on_rounded,
          iconColor: const Color(0xFFF59E0B),
          iconBgColor: const Color(0xFFFEF3C7),
          label: 'Coins Earned',
          value: coinsEarned,
          onTap: onCoinsTap,
        ),
        AppMetricCard(
          icon: Icons.workspace_premium_rounded,
          iconColor: const Color(0xFF8B5CF6),
          iconBgColor: const Color(0xFFEDE9FE),
          label: 'Rank Position',
          value: rankPosition,
          onTap: onRankTap,
        ),
      ],
    );
  }
}
