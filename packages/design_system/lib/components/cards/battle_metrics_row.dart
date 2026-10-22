import 'package:flutter/material.dart';
import 'app_metric_card.dart';
import 'test_metric_card.dart';

/// 4 Statistics Cards row for the 1v1 Battle Tab
/// (Players Online, Battles Played, Your Wins, Win Rate).
/// Powered by the unified [AppMetricsRow] engine.
class BattleMetricsRow extends StatelessWidget {
  final String playersOnline;
  final String battlesPlayed;
  final String yourWins;
  final String winRate;
  final VoidCallback? onPlayersOnlineTap;
  final VoidCallback? onBattlesPlayedTap;
  final VoidCallback? onWinsTap;
  final VoidCallback? onWinRateTap;

  const BattleMetricsRow({
    super.key,
    this.playersOnline = '2,468',
    this.battlesPlayed = '12,540',
    this.yourWins = '186',
    this.winRate = '72%',
    this.onPlayersOnlineTap,
    this.onBattlesPlayedTap,
    this.onWinsTap,
    this.onWinRateTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppMetricsRow(
      breakpoint: 640,
      spacing: 8,
      cards: [
        TestMetricCard(
          icon: Icons.groups_rounded,
          label: 'Players Online',
          value: playersOnline,
          accentColor: const Color(0xFFF43F5E),
          backgroundColor: const Color(0xFFFFF1F2),
          onTap: onPlayersOnlineTap,
        ),
        TestMetricCard(
          icon: Icons.sports_esports_rounded,
          label: 'Battles Played',
          value: battlesPlayed,
          accentColor: const Color(0xFF10B981),
          backgroundColor: const Color(0xFFECFDF5),
          onTap: onBattlesPlayedTap,
        ),
        TestMetricCard(
          icon: Icons.emoji_events_rounded,
          label: 'Your Wins',
          value: yourWins,
          accentColor: const Color(0xFFF59E0B),
          backgroundColor: const Color(0xFFFFFBEB),
          onTap: onWinsTap,
        ),
        TestMetricCard(
          icon: Icons.star_rounded,
          label: 'Win Rate',
          value: winRate,
          accentColor: const Color(0xFF8B5CF6),
          backgroundColor: const Color(0xFFF5F3FF),
          onTap: onWinRateTap,
        ),
      ],
    );
  }
}
