import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'finding_opponent_screen.dart';

/// Screen Three: Victory / Battle Result Screen
/// Direct pixel-accurate match with Reference Image 3.
/// Features celebratory trophy & confetti, win-streak multiplier banner,
/// player comparison card, coin reward breakdown, WhatsApp challenge share,
/// Return to Hub, and Play Again rematch flow.
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

                        // 2. Win Streak Banner (Active on Victory)
                        if (result.isVictory) ...[
                          _buildStreakBanner(),
                          const SizedBox(height: 12),
                        ],

                        // 3. Result Announcement Card
                        BattleResultAnnouncementCard(
                          text: result.message,
                        ),
                        const SizedBox(height: 16),

                        // 4. Player Comparison Card (Side by side with VS)
                        BattleResultComparisonCard(
                          winnerName: result.isVictory ? result.playerName : result.opponentName,
                          winnerScore: result.isVictory ? result.playerScore : result.opponentScore,
                          loserName: result.isVictory ? result.opponentName : result.playerName,
                          loserScore: result.isVictory ? result.opponentScore : result.playerScore,
                          isWinnerCurrentUser: result.isVictory,
                        ),
                        const SizedBox(height: 16),

                        // 5. Reward Summary Card (+100 Coins with Coin Stack)
                        BattleRewardSummaryCard(
                          coinsWon: result.coinsWon,
                          isVictory: result.isVictory,
                        ),
                        const SizedBox(height: 20),

                        // 6. Action Buttons: Return to Hub & Play Again
                        BattlePrimaryButton(
                          label: 'Return to Hub',
                          icon: Icons.home_rounded,
                          onPressed: () => _returnToHub(context),
                        ),
                        const SizedBox(height: 10),
                        BattleSecondaryButton(
                          label: 'Play Again',
                          icon: Icons.refresh_rounded,
                          onPressed: () => _playAgain(context),
                        ),
                        const SizedBox(height: 10),

                        // 7. 1-Click WhatsApp Challenge Button (Viral Growth)
                        _buildWhatsAppChallengeButton(context),
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

  Widget _buildStreakBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEA580C), Color(0xFFF97316), Color(0xFFFBBF24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33EA580C),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFEA580C), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '🔥 3x WIN STREAK ACTIVE!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '+25 Bonus Coins Multiplier Unlocked',
                  style: TextStyle(
                    color: Color(0xFFFEF3C7),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '3 WINS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppChallengeButton(BuildContext context) {
    return InkWell(
      onTap: () {
        final shareText =
            'I just won a Quiz Battle on Rankearn with ${result.playerScore} points! 🏆\n'
            'Think you can beat me? Challenge me now on Rankearn: https://rankearn.in/battle\n'
            'Let\'s see who knows more! ⚔️';
        Clipboard.setData(ClipboardData(text: shareText));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Challenge text copied! Paste & share on WhatsApp/Telegram!'),
            backgroundColor: Color(0xFF25D366),
            duration: Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.share_rounded, size: 16, color: Color(0xFF15803D)),
            SizedBox(width: 8),
            Text(
              'Challenge Friends on WhatsApp',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF15803D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _returnToHub(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _playAgain(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FindingOpponentScreen(
          userCoins: userCoins,
          profile: profile,
          battleType: '1v1 Battle',
          entryFee: entryFee,
          onCoinUpdate: onCoinUpdate,
        ),
      ),
    );
  }
}
