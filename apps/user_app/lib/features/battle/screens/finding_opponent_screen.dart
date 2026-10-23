import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'live_arena_screen.dart';

/// Screen A: 1v1 Arena Matchmaking Dashboard
/// Direct responsive parity with Reference Image 3:
/// - Desktop: 3-column top hero card (Status/Highlights, Animated Radar, Progress Stepper & Stats),
///   3 Benefit feature cards, motivational tip banner, and centered Cancel Matchmaking button.
/// - Mobile: Fluid single-column layout preserving all interactive components with zero overflow.
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
  Timer? _stageTimer;
  Timer? _searchTimer;
  int _activeStage = 1;

  @override
  void initState() {
    super.initState();
    _startMatchmakingHandshake();
  }

  void _startMatchmakingHandshake() {
    // Stage 1 -> 2 transition after 1.2s
    _stageTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _activeStage = 2);
    });

    // Final handshake & battle creation
    _searchTimer = Timer(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      setState(() => _activeStage = 3);

      final res = await _repository.createLiveBattleSession(
        playerName: widget.profile.name.isEmpty ? 'Vikram Singh' : widget.profile.name,
        opponentName: 'Amit Verma',
        entryFee: widget.entryFee,
        opponentRank: 'Rank #3421',
      );

      if (!mounted) return;

      if (res is Success<BattleSession>) {
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
    _stageTimer?.cancel();
    _searchTimer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppHeader(
        coins: widget.userCoins,
        userName: widget.profile.name.isEmpty ? 'Vikram Singh' : widget.profile.name,
        currentTab: UserNavTab.battle,
        unreadNotifications: 3,
        showMenuButton: false,
        onMenuTap: _cancelMatchmaking,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            final isTablet = constraints.maxWidth >= 600 && !isDesktop;
            final canFitWithoutScroll = isDesktop && constraints.maxHeight >= 540;

            final content = ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1200 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Top Matchmaking Hero Dashboard Card
                  _buildTopHeroDashboard(isDesktop),
                  const SizedBox(height: 12),

                  // 2. Three Feature Cards Row (1v1 Battle, Fair Match, No Bots)
                  const MatchmakingDesktopCardsRow(),
                  const SizedBox(height: 10),

                  // 3. Did You Know Banner
                  const BattleTipBanner(),
                  const SizedBox(height: 14),

                  // 4. Centered Cancel Matchmaking Button
                  MatchmakingCancelButton(
                    onCancel: _cancelMatchmaking,
                  ),
                ],
              ),
            );

            if (canFitWithoutScroll) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: content,
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24 : (isTablet ? 18 : 12),
                vertical: isDesktop ? 12 : 12,
              ),
              child: Center(child: content),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopHeroDashboard(bool isDesktop) {
    if (isDesktop) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.battleBorder, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C10194F),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Status & Value Bullets
            Expanded(
              flex: 4,
              child: _buildLeftStatusColumn(),
            ),
            const SizedBox(width: 14),

            // Center Radar Animation
            Expanded(
              flex: 4,
              child: Center(
                child: MatchmakingRadar(size: 200),
              ),
            ),
            const SizedBox(width: 14),

            // Right Matchmaking Progress Stepper & Live Stats
            Expanded(
              flex: 4,
              child: MatchmakingProgressPanel(
                activeStage: _activeStage,
                waitTime: '10 - 30 seconds',
                skillLevel: 'Intermediate',
                playersOnline: '2,468',
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile / Tablet Stacked Layout
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.battleBorder, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C10194F),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildLeftStatusColumn(),
            const SizedBox(height: 14),
            Center(
              child: MatchmakingRadar(size: 210),
            ),
            const SizedBox(height: 16),
            MatchmakingProgressPanel(
              activeStage: _activeStage,
              waitTime: '10 - 30 seconds',
              skillLevel: 'Intermediate',
              playersOnline: '2,468',
            ),
          ],
        ),
      );
    }
  }

  Widget _buildLeftStatusColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1v1 Live Arena Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
          decoration: BoxDecoration(
            color: const Color(0xFFD6F6E5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.sports_esports_rounded, color: Color(0xFF00B96B), size: 15),
              SizedBox(width: 5),
              Text(
                '1v1 Live Arena',
                style: TextStyle(
                  color: Color(0xFF008C52),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Finding Opponent Title
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
        const SizedBox(height: 4),

        // Subtitle
        const Text(
          'Looking for a player near your skill level',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppColors.battleSecondaryText,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 12),

        // Feature Bullets
        _buildBulletItem(Icons.bolt_rounded, const Color(0xFF00B96B), 'Real Players Only'),
        const SizedBox(height: 7),
        _buildBulletItem(Icons.verified_user_rounded, const Color(0xFF00B96B), 'Fair & Balanced Match'),
        const SizedBox(height: 7),
        _buildBulletItem(Icons.groups_rounded, const Color(0xFF00B96B), 'Similar Skill Level'),
      ],
    );
  }

  Widget _buildBulletItem(IconData icon, Color color, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.battleNavy,
              fontFamily: 'Inter',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
