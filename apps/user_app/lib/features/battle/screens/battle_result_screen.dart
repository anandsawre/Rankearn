import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'finding_opponent_screen.dart';

/// Screen Three: Victory / Battle Result Screen
/// Direct pixel-accurate match with Reference Image 3.
/// Features celebratory trophy & confetti, player comparison card,
/// coin reward breakdown, Return to Hub, and Play Again rematch flow.
class BattleResultScreen extends StatelessWidget {
  final BattleResult result;
  final int userCoins;
  final UserProfile profile;
  final int entryFee;
  final void Function(int coinsDelta)? onCoinUpdate;

  const BattleResultScreen({
    super.key,
    required this.result,
    required this.userCoins,
    required this.profile,
    this.entryFee = 100,
    this.onCoinUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _returnToHub(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F8FF),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      children: [
                        // 1. Victory Banner with Celebratory Trophy, Ribbon & Confetti
                        VictoryBanner(
                          isVictory: result.isVictory,
                          isDraw: result.isDraw,
                        ),
                        const SizedBox(height: 12),

                        // 2. Result Announcement Card
                        BattleResultAnnouncementCard(
                          text: result.message,
                        ),
                        const SizedBox(height: 16),

                        // 3. Player Comparison Card (Side by side with VS)
                        BattleResultComparisonCard(
                          winnerName: result.isVictory ? result.playerName : result.opponentName,
                          winnerScore: result.isVictory ? result.playerScore : result.opponentScore,
                          loserName: result.isVictory ? result.opponentName : result.playerName,
                          loserScore: result.isVictory ? result.opponentScore : result.playerScore,
                          isWinnerCurrentUser: result.isVictory,
                        ),
                        const SizedBox(height: 16),

                        // 4. Reward Summary Card (+100 Coins with Coin Stack)
                        BattleRewardSummaryCard(
                          coinsWon: result.coinsWon,
                          isVictory: result.isVictory,
                        ),
                        const SizedBox(height: 24),

                        // 5. Action Buttons: Return to Hub & Play Again
                        BattlePrimaryButton(
                          label: 'Return to Hub',
                          icon: Icons.home_rounded,
                          onPressed: () => _returnToHub(context),
                        ),
                        const SizedBox(height: 12),
                        BattleSecondaryButton(
                          label: 'Play Again',
                          icon: Icons.refresh_rounded,
                          onPressed: () => _playAgain(context),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _returnToHub(BuildContext context) {
    // Pop back to the Battle Hub Screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _playAgain(BuildContext context) {
    // Start fresh matchmaking session
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FindingOpponentScreen(
          userCoins: userCoins,
          profile: profile,
          entryFee: entryFee,
          onCoinUpdate: onCoinUpdate,
        ),
      ),
    );
  }
}
