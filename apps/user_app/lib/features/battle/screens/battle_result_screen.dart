import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'finding_opponent_screen.dart';

/// Screen C: Victory 1v1 Battle Dashboard
/// Direct responsive parity with Reference Image 1:
/// - Desktop: Two-column dashboard:
///   - Main Column: Stadium celebration victory banner, announcement, player comparison card,
///     reward summary card (+100 Coins with coin stacks), Return to Hub & Play Again action buttons.
///   - Right Sidebar: Battle Summary, Rank Impact (+28, 3 wins streak), and Keep Going motivational card.
/// - Mobile: Fluid single-column responsive layout stacking all summary metrics and controls.
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
        backgroundColor: const Color(0xFFF0F7FF),
        appBar: AppHeader(
          coins: userCoins,
          userName: profile.name.isEmpty ? 'Vikram Singh' : profile.name,
          currentTab: UserNavTab.battle,
          unreadNotifications: 3,
          showMenuButton: false,
          onMenuTap: () => _returnToHub(context),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 960;
              final isTablet = constraints.maxWidth >= 650 && !isDesktop;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : (isTablet ? 20 : 14),
                  vertical: isDesktop ? 24 : 14,
                ),
                child: isDesktop
                    ? _buildDesktopTwoColumn(context)
                    : _buildMobileStacked(context),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Desktop Two-Column Dashboard (Image 1)
  Widget _buildDesktopTwoColumn(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Column: Victory Artwork, Announcement, Comparison, Reward, Action Buttons
        Expanded(
          flex: 65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Victory Stadium Banner with Laurel & Confetti
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

              // 4. Reward Summary Card (+100 Coins with Coin Stacks)
              BattleRewardSummaryCard(
                coinsWon: result.coinsWon,
                isVictory: result.isVictory,
              ),
              const SizedBox(height: 20),

              // 5. Horizontal Action Buttons (Return to Hub & Play Again)
              Row(
                children: [
                  Expanded(
                    child: BattlePrimaryButton(
                      label: 'Return to Hub',
                      icon: Icons.home_rounded,
                      onPressed: () => _returnToHub(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BattleSecondaryButton(
                      label: 'Play Again',
                      icon: Icons.refresh_rounded,
                      onPressed: () => _playAgain(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        const SizedBox(width: 24),

        // Right Column: Battle Summary, Rank Impact, Keep Going Card
        Expanded(
          flex: 35,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Battle Summary Card
              const BattleSummaryCard(
                subject: 'General Science',
                totalQuestions: 5,
                yourCorrect: 4,
                opponentCorrect: 0,
                timeTaken: '1 min 12 sec',
                result: 'You Won',
              ),
              const SizedBox(height: 18),

              // 2. Rank Impact Card
              const RankImpactCard(
                yourRank: '#1256',
                newRank: '#1228',
                rankChange: '+28',
                winningStreak: '3 Wins',
                totalBattles: 12,
              ),
              const SizedBox(height: 18),

              // 3. Keep Going Card
              const KeepGoingCard(),
            ],
          ),
        ),
      ],
    );
  }

  /// Mobile Stacked Layout
  Widget _buildMobileStacked(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Victory Banner
        VictoryBanner(
          isVictory: result.isVictory,
          isDraw: result.isDraw,
        ),
        const SizedBox(height: 12),

        // 2. Result Announcement Card
        BattleResultAnnouncementCard(
          text: result.message,
        ),
        const SizedBox(height: 14),

        // 3. Player Comparison Card
        BattleResultComparisonCard(
          winnerName: result.isVictory ? result.playerName : result.opponentName,
          winnerScore: result.isVictory ? result.playerScore : result.opponentScore,
          loserName: result.isVictory ? result.opponentName : result.playerName,
          loserScore: result.isVictory ? result.opponentScore : result.playerScore,
          isWinnerCurrentUser: result.isVictory,
        ),
        const SizedBox(height: 14),

        // 4. Reward Summary Card
        BattleRewardSummaryCard(
          coinsWon: result.coinsWon,
          isVictory: result.isVictory,
        ),
        const SizedBox(height: 18),

        // 5. Action Buttons (Stacked on mobile for comfortable tapping)
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
        const SizedBox(height: 22),

        // 6. Battle Summary Card
        const BattleSummaryCard(
          subject: 'General Science',
          totalQuestions: 5,
          yourCorrect: 4,
          opponentCorrect: 0,
          timeTaken: '1 min 12 sec',
          result: 'You Won',
        ),
        const SizedBox(height: 16),

        // 7. Rank Impact Card
        const RankImpactCard(
          yourRank: '#1256',
          newRank: '#1228',
          rankChange: '+28',
          winningStreak: '3 Wins',
          totalBattles: 12,
        ),
        const SizedBox(height: 16),

        // 8. Keep Going Card
        const KeepGoingCard(),
        const SizedBox(height: 24),
      ],
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
          entryFee: entryFee,
          onCoinUpdate: onCoinUpdate,
        ),
      ),
    );
  }
}
