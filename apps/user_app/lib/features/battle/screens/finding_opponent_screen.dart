import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import '../../wallet/components/wallet_modals.dart';
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
  Timer? _pollTimer;
  String? _waitingBattleId;
  bool _isFinalizing = false;
  bool _botFallback = true;
  double _botAccuracy = 0.65;

  @override
  void initState() {
    super.initState();
    _startMatchmakingHandshake();
  }

  Future<void> _startMatchmakingHandshake() async {
    final settings = await _repository.getBattleSettings();
    if (!mounted) return;

    final maintenanceMode = settings['maintenanceMode'] == true;
    if (maintenanceMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Battle Arena is temporarily under maintenance.'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    _botFallback = settings['botFallback'] as bool? ?? true;
    _botAccuracy = (settings['botAccuracy'] as num?)?.toDouble() ?? 0.65;
    final timeoutSecs =
        ((settings['matchmakingTimeout'] as num?)?.toInt() ?? 10).clamp(5, 30);

    // 1. Check for an existing real waiting player or create a waiting room
    final queueRes = await _repository.findOrCreateWaitingBattle(
      userId: widget.profile.id,
      entryFee: widget.entryFee,
    );
    if (!mounted || _isFinalizing) return;

    _waitingBattleId = queueRes['battle_id']?.toString();
    final immediatelyMatched = queueRes['matched'] == true;

    if (immediatelyMatched) {
      await _launchMatch(
        battleId: _waitingBattleId!,
        opponentId: queueRes['opponent_id']?.toString(),
        opponentName: queueRes['opponent_name']?.toString(),
        isBotFallback: false,
      );
      return;
    }

    // 2. Poll every 1.5s during the radar scan window to see if a real opponent joins
    _pollTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) async {
      if (!mounted || _isFinalizing || _waitingBattleId == null) return;
      final match = await _repository.checkWaitingBattleMatched(
        battleId: _waitingBattleId!,
      );
      if (match != null && match['matched'] == true && mounted && !_isFinalizing) {
        await _launchMatch(
          battleId: _waitingBattleId!,
          opponentId: match['opponent_id']?.toString(),
          opponentName: match['opponent_name']?.toString(),
          isBotFallback: false,
        );
      }
    });

    // 3. After timeout (default 10s), either fall back to bot (if enabled) or cancel
    _searchTimer = Timer(Duration(seconds: timeoutSecs), () async {
      if (!mounted || _isFinalizing) return;
      _pollTimer?.cancel();

      if (_botFallback && _waitingBattleId != null) {
        await _launchMatch(
          battleId: _waitingBattleId!,
          isBotFallback: true,
        );
      } else {
        _isFinalizing = true;
        if (_waitingBattleId != null) {
          await _repository.cancelWaitingBattle(battleId: _waitingBattleId!);
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No opponent found right now. Please try again.'),
            backgroundColor: Color(0xFFD97706),
          ),
        );
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _launchMatch({
    required String battleId,
    String? opponentId,
    String? opponentName,
    required bool isBotFallback,
  }) async {
    if (_isFinalizing) return;
    _isFinalizing = true;
    _pollTimer?.cancel();
    _searchTimer?.cancel();

    final res = await _repository.buildSessionForBattle(
      battleId: battleId,
      userId: widget.profile.id,
      playerName: widget.profile.name.isEmpty ? 'Player' : widget.profile.name,
      opponentId: opponentId,
      opponentName: opponentName,
      entryFee: widget.entryFee,
      isBotFallback: isBotFallback,
    );

    if (!mounted) return;

    if (res is Success<BattleSession>) {
      if (widget.entryFee > 0) {
        await _repository.deductBattleEntryFee(
          userId: widget.profile.id,
          entryFee: widget.entryFee,
          battleId: res.data.id,
          battleTitle: widget.battleType,
        );
        widget.onCoinUpdate?.call(-widget.entryFee);
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LiveArenaScreen(
            initialSession: res.data,
            userCoins: widget.userCoins - widget.entryFee,
            userProfile: widget.profile,
            onCoinUpdate: widget.onCoinUpdate,
            botAccuracy: res.data.botAccuracy ?? _botAccuracy,
          ),
        ),
      );
    } else if (res is Failure<BattleSession>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _cancelMatchmaking() {
    _isFinalizing = true;
    _pollTimer?.cancel();
    _searchTimer?.cancel();
    if (_waitingBattleId != null) {
      _repository.cancelWaitingBattle(battleId: _waitingBattleId!);
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchTimer?.cancel();
    if (!_isFinalizing && _waitingBattleId != null) {
      _repository.cancelWaitingBattle(battleId: _waitingBattleId!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FF),
      appBar: BattleAppBar(
        coins: widget.userCoins,
        onBack: _cancelMatchmaking,
        onAddCoins: () {
          WalletModals.showBuyCoinsModal(
            context,
            profile: widget.profile,
          );
        },
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 768;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: AppSpacing.pagePadding(context, top: 16, bottom: 16),
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
            );
          },
        ),
      ),
    );
  }
}
