import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'screens/finding_opponent_screen.dart';

export 'screens/finding_opponent_screen.dart';
export 'screens/live_arena_screen.dart';
export 'screens/battle_result_screen.dart';

/// Legacy BattleScreen wrapper routing directly to the Master FindingOpponentScreen flow
class BattleScreen extends StatelessWidget {
  final String playerName;
  final String opponentName;
  final int entryFeeCoins;
  final VoidCallback onExit;
  final void Function(int coinsDelta)? onMatchFinished;

  const BattleScreen({
    super.key,
    this.playerName = 'Vikram Singh',
    this.opponentName = 'Amit Verma (Rank #4)',
    this.entryFeeCoins = 100,
    required this.onExit,
    this.onMatchFinished,
  });

  @override
  Widget build(BuildContext context) {
    return FindingOpponentScreen(
      userCoins: 1250,
      profile: UserProfile(
        id: 'user_current',
        name: playerName.isEmpty ? 'Vikram Singh' : playerName,
        email: 'user@rankearn.com',
        coins: 1250,
        createdAt: DateTime.now(),
      ),
      battleType: '1v1 Battle',
      entryFee: entryFeeCoins,
      onCoinUpdate: onMatchFinished,
    );
  }
}
