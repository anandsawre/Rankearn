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
  final String? userId;
  final VoidCallback onBack;
  final void Function(int coinsWon)? onRewardClaimed;
  final VoidCallback? onOpenWallet;
  final List<SpinRewardItem>? initialRewards;

  const LuckyWheelScreen({
    super.key,
    required this.currentCoins,
    this.userId,
    required this.onBack,
    this.onRewardClaimed,
    this.onOpenWallet,
    this.initialRewards,
  });

  @override
  State<LuckyWheelScreen> createState() => _LuckyWheelScreenState();
}

class _LuckyWheelScreenState extends State<LuckyWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  Animation<double>? _spinAnimation;

  List<SpinRewardItem> _rewards = [];
  bool _isLoading = true;
  bool _isSpinning = false;
  double _currentAngle = 0.0;
  late SpinStateModel _spinState;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _spinState = SpinService.getSpinState();
    if (widget.initialRewards != null && widget.initialRewards!.isNotEmpty) {
      _rewards = widget.initialRewards!;
      _isLoading = false;
    } else {
      _initDynamicWheel();
    }

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
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

  Future<void> _initDynamicWheel() async {
    setState(() => _isLoading = true);
    final active = await SpinService.loadActiveRewards();
    final authUserId = widget.userId ?? 'current_user';
    final state = await SpinService.fetchSpinState(userId: authUserId);
    if (mounted) {
      setState(() {
        _rewards = active;
        _spinState = state;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // AUTHORITATIVE SINGLE-STAGE BUTTER-SMOOTH SPIN CONTROLLER
  // ---------------------------------------------------------------------------
  Future<void> _handleSpin() async {
    if (_isSpinning || !_spinState.hasSpinsLeft) return;

    setState(() {
      _isSpinning = true;
      _spinAnimation = null;
    });

    // 1. Instant smooth continuous rotation on button tap (zero latency, zero freeze)
    _spinController.duration = const Duration(milliseconds: 550);
    _spinController.repeat();

    // 2. Authoritative request (RPC execution)
    final requestId = 'SPIN_${DateTime.now().millisecondsSinceEpoch}';
    final res = await SpinService.requestSpin(
      userId: widget.userId ?? 'user_current',
      transactionRequestId: requestId,
    );

    if (!mounted) return;

    if (res.isFailure) {
      _spinController.stop();
      setState(() {
        _isSpinning = false;
        _spinAnimation = null;
      });
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

    // 3. Capture current visual angle without snapping
    final currentVisualAngle =
        _currentAngle + (_spinController.value * 2 * math.pi);
    _spinController.stop();

    // 4. Compute target angle
    final totalSectors = _rewards.isNotEmpty ? _rewards.length : 8;
    final sectorAngle = (2 * math.pi) / totalSectors;
    final currentNorm = currentVisualAngle % (2 * math.pi);
    final targetNorm =
        (2 * math.pi - (targetIndex * sectorAngle) % (2 * math.pi)) %
            (2 * math.pi);

    double delta = targetNorm - currentNorm;
    if (delta < 0) {
      delta += 2 * math.pi;
    }

    // 5 full dramatic turns + precise target alignment
    final targetAngle = currentVisualAngle + (5 * 2 * math.pi) + delta;

    // 5. Silky smooth physical ease-out deceleration curve
    _spinController.duration = const Duration(milliseconds: 3600);
    _spinAnimation = Tween<double>(
      begin: currentVisualAngle,
      end: targetAngle,
    ).animate(
      CurvedAnimation(
        parent: _spinController,
        curve: Curves.easeOutCubic,
      ),
    );

    _spinController.reset();
    await _spinController.forward();

    if (!mounted) return;

    final authUserId = widget.userId ?? 'current_user';
    final refreshedState = await SpinService.fetchSpinState(userId: authUserId);

    if (!mounted) return;

    setState(() {
      _currentAngle = targetAngle % (2 * math.pi);
      _spinAnimation = null;
      _isSpinning = false;
      _spinState = refreshedState;
    });

    // 6. Show Celebration Result Dialog
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
                  if (_isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: Color(0xFF00B96B)),
                      ),
                    );
                  }

                  if (_rewards.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.casino_outlined,
                                size: 48,
                                color: Color(0xFF00B96B),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'No Active Lucky Wheel Campaign',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                                color: Color(0xFF1E293B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'The Lucky Wheel is currently resting or being configured. Please check back soon!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                height: 1.45,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 22),
                            ElevatedButton.icon(
                              onPressed: _initDynamicWheel,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Refresh Wheel'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00B96B),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

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
                              animation: _isSpinning ? _spinAnimation : null,
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
