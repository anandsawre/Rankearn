import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'models/spin_reward_model.dart';
import 'services/spin_service.dart';
import 'components/spin_header.dart';
import 'components/spin_hero_banner.dart';
import 'components/spin_stats_row.dart';
import 'components/spin_wheel.dart';
import 'components/spin_action_button.dart';
import 'components/spin_result_dialog.dart';

/// Top-level Screen alias for Spin & Win
typedef SpinAndWinScreen = LuckyWheelScreen;

/// Production-ready Spin & Win screen strictly matching the Rankearn reference design.
/// - Top green header with gift icon, "Spin & Win" title and wallet balance chip
/// - Mint pastel hero banner with 3D cheering mascot
/// - Compact stat cards: "Today's Spins (1 / 3)" and "Next Spin In (14h 25m)"
/// - 8-segment emerald & cream circular wheel with glowing rim lights & pointer
/// - Full-width "Spin Now" action button with free spins badge
/// - 8 Possible Rewards showcase cards
/// - Celebratory claim result dialog
class LuckyWheelScreen extends StatefulWidget {
  final int currentCoins;
  final VoidCallback onBack;
  final void Function(int coinsWon)? onRewardClaimed;
  final VoidCallback? onOpenWallet;

  const LuckyWheelScreen({
    super.key,
    required this.currentCoins,
    required this.onBack,
    this.onRewardClaimed,
    this.onOpenWallet,
  });

  @override
  State<LuckyWheelScreen> createState() => _LuckyWheelScreenState();
}

class _LuckyWheelScreenState extends State<LuckyWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  final List<SpinRewardItem> _rewards = SpinRewardItem.defaultRewards;

  bool _isSpinning = false;
  double _currentAngle = 0.0;
  late SpinStateModel _spinState;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _spinState = SpinService.getSpinState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );

    // Refresh cooldown countdown every minute
    _cooldownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _spinState = SpinService.getSpinState();
        });
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // AUTHORITATIVE SPIN CONTROLLER
  // ---------------------------------------------------------------------------
  Future<void> _handleSpin() async {
    if (_isSpinning || !_spinState.hasSpinsLeft) return;

    setState(() {
      _isSpinning = true;
    });

    // 1. Authoritative request from trusted service
    final requestId = 'SPIN_${DateTime.now().millisecondsSinceEpoch}';
    final res = await SpinService.requestSpin(
      userId: 'user_current',
      transactionRequestId: requestId,
    );

    if (!mounted) return;

    if (res.isFailure) {
      setState(() => _isSpinning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.errorOrNull ?? 'Could not complete spin request.'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    final outcome = res.dataOrNull!;
    final targetIndex = outcome.targetIndex;
    final reward = outcome.reward;

    // 2. Compute exact rotation physics so pointer lands in targetIndex center
    // Sector 0 is centered at 12 o'clock (-pi/2).
    // Clockwise rotation brings Sector k to 12 o'clock when rotated by (2*pi - k * sectorAngle).
    const sectorAngle = (2 * math.pi) / 8;
    const fullRotations = 6 * 2 * math.pi; // 6 full dramatic spins
    final targetSectorOffset = (2 * math.pi) - (targetIndex * sectorAngle);

    final normalizedCurrent = _currentAngle % (2 * math.pi);
    final targetAngle =
        _currentAngle + fullRotations + targetSectorOffset - normalizedCurrent;

    _spinAnimation = Tween<double>(begin: _currentAngle, end: targetAngle)
        .animate(
          CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
        );

    _spinController.reset();
    await _spinController.forward();

    if (!mounted) return;

    setState(() {
      _currentAngle = targetAngle % (2 * math.pi);
      _isSpinning = false;
      _spinState = SpinService.getSpinState();
    });

    // 3. Show Celebration Result Dialog
    await SpinResultDialog.show(
      context: context,
      reward: reward,
      onClaim: () {
        if (reward.coins > 0) {
          widget.onRewardClaimed?.call(reward.coins);
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FF), // Light blue-white canvas
      body: Column(
        children: [
          // 1. Green Top Header (Back, Spin & Win, Coin Balance)
          SpinHeader(
            coinBalance: widget.currentCoins,
            onBack: widget.onBack,
            onOpenWallet: widget.onOpenWallet,
          ),

          // 2. Main Scrollable Content Area with Fluid Wave Background
          Expanded(
            child: WaveBackground(
              primaryColor: const Color(0xFF00B96B),
              secondaryColor: const Color(0xFF38BDF8),
              accentColor: const Color(0xFFFFD32A),
              intensity: 0.85,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 900;
                  final maxContentWidth = isDesktop ? 680.0 : double.infinity;
                  final hPadding = isDesktop ? 24.0 : 16.0;

                  // Responsive wheel sizing
                  final wheelSize = (constraints.maxWidth * 0.85).clamp(
                    290.0,
                    360.0,
                  );

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: hPadding,
                      vertical: 16,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 2.1 Hero Banner (Mint gradient + Mascot)
                            const SpinHeroBanner(),
                            const SizedBox(height: 16),

                            // 2.2 Spin Statistics Row (Today's Spins + Next Spin In)
                            SpinStatsRow(
                              spinsUsedToday: _spinState.spinsUsedToday,
                              maxSpinsPerDay: _spinState.maxSpinsPerDay,
                              formattedCooldown: _spinState.formattedCooldown,
                            ),
                            const SizedBox(height: 20),

                            // 2.3 Main Interactive Spin Wheel
                            SpinWheel(
                              rewards: _rewards,
                              controller: _spinController,
                              animation: _isSpinning
                                  ? _spinAnimation
                                  : const AlwaysStoppedAnimation(0),
                              currentAngle: _currentAngle,
                              isSpinning: _isSpinning,
                              spinsRemaining: _spinState.spinsRemaining,
                              onSpin: _handleSpin,
                              size: wheelSize,
                            ),
                            const SizedBox(height: 22),

                            // 2.4 Spin Now Action Button
                            SpinActionButton(
                              isSpinning: _isSpinning,
                              spinsRemaining: _spinState.spinsRemaining,
                              onSpin: _handleSpin,
                              cooldownText: _spinState.formattedCooldown,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
