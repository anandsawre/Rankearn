import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'live_arena_screen.dart';

/// Screen One: Finding Opponent Screen
/// Direct pixel-accurate match with Reference Image 2.
/// Features circular matchmaking radar, fair-match info cards,
/// motivational tip banner, and safe cancellation flow.
class FindingOpponentScreen extends StatefulWidget {
  final int userCoins;
  final UserProfile profile;
  final String battleType;
  final int entryFee;
  final void Function(int coinsDelta)? onCoinUpdate;

  const FindingOpponentScreen({
    super.key,
    required this.userCoins,
    required this.profile,
    this.battleType = '1v1 Battle',
    this.entryFee = 100,
    this.onCoinUpdate,
  });

  @override
  State<FindingOpponentScreen> createState() => _FindingOpponentScreenState();
}

class _FindingOpponentScreenState extends State<FindingOpponentScreen> {
  final BattleRepository _repository = BattleRepository();
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _startMatchmakingHandshake();
  }

  void _startMatchmakingHandshake() {
    // 2.5 second simulated radar scan before matching real opponent
    _searchTimer = Timer(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;

      final res = await _repository.createLiveBattleSession(
        playerName: widget.profile.name.isEmpty ? 'Vikram Singh' : widget.profile.name,
        opponentName: 'Amit Verma (Rank #4)',
        entryFee: widget.entryFee,
        opponentRank: 'Rank #4',
      );

      if (!mounted) return;

      if (res is Success<BattleSession>) {
        // Transition to Live Arena
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LiveArenaScreen(
              initialSession: res.data,
              userCoins: widget.userCoins,
              userProfile: widget.profile,
              onCoinUpdate: widget.onCoinUpdate,
            ),
          ),
        );
      }
    });
  }

  void _cancelMatchmaking() {
    _searchTimer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FF),
      appBar: BattleAppBar(
        coins: widget.userCoins,
        onBack: _cancelMatchmaking,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 768;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Central Radar Visualization
                      const SizedBox(height: 10),
                      MatchmakingRadar(
                        size: isDesktop ? 300 : 260,
                      ),
                      const SizedBox(height: 22),

                      // 2. Search Status Heading & Subtitle
                      const Text(
                        'Finding Opponent...',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.battleNavy,
                          letterSpacing: -0.3,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Looking for a player near your skill level',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.battleSecondaryText,
                          fontFamily: 'Inter',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // 3. Fair Match 3 Cards Row
                      const MatchmakingFairCardsRow(),
                      const SizedBox(height: 20),

                      // 4. "Did you know?" Banner Card
                      const BattleTipBanner(),
                      const SizedBox(height: 24),

                      // 5. Full-width Soft Mint Cancel Button
                      BattleSecondaryButton(
                        label: 'Cancel',
                        isSoftTint: true,
                        onPressed: _cancelMatchmaking,
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
    );
  }
}
