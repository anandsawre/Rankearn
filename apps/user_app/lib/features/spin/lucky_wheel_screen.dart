import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class WheelSector {
  final String label;
  final int coins;
  final Color color;
  final Color textColor;
  final IconData icon;

  const WheelSector({
    required this.label,
    required this.coins,
    required this.color,
    required this.textColor,
    required this.icon,
  });
}

class LuckyWheelScreen extends StatefulWidget {
  final int currentCoins;
  final VoidCallback onBack;
  final void Function(int coinsWon)? onRewardClaimed;

  const LuckyWheelScreen({
    super.key,
    required this.currentCoins,
    required this.onBack,
    this.onRewardClaimed,
  });

  @override
  State<LuckyWheelScreen> createState() => _LuckyWheelScreenState();
}

class _LuckyWheelScreenState extends State<LuckyWheelScreen> with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  final List<WheelSector> _sectors = const [
    WheelSector(label: '50 Coins', coins: 50, color: Color(0xFF10B981), textColor: Colors.white, icon: Icons.monetization_on),
    WheelSector(label: 'Try Again', coins: 0, color: Color(0xFFF1F5F9), textColor: Color(0xFF64748B), icon: Icons.sentiment_neutral),
    WheelSector(label: '100 Coins', coins: 100, color: Color(0xFFF59E0B), textColor: Colors.white, icon: Icons.stars),
    WheelSector(label: '20 Coins', coins: 20, color: Color(0xFF059669), textColor: Colors.white, icon: Icons.monetization_on),
    WheelSector(label: 'Pass 🎁', coins: 0, color: Color(0xFF3B82F6), textColor: Colors.white, icon: Icons.card_giftcard),
    WheelSector(label: '250 Coins', coins: 250, color: Color(0xFFD97706), textColor: Colors.white, icon: Icons.emoji_events),
    WheelSector(label: '10 Coins', coins: 10, color: Color(0xFF34D399), textColor: Colors.white, icon: Icons.monetization_on),
    WheelSector(label: 'Better Luck', coins: 0, color: Color(0xFFE2E8F0), textColor: Color(0xFF475569), icon: Icons.refresh),
  ];

  bool _isSpinning = false;
  double _currentAngle = 0.0;
  int _spinsRemainingToday = 1;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning || _spinsRemainingToday <= 0) return;

    setState(() {
      _isSpinning = true;
      _spinsRemainingToday--;
    });

    // Random landing index (0-7)
    final random = math.Random();
    final targetIndex = random.nextInt(_sectors.length);
    final sectorAngle = (2 * math.pi) / _sectors.length;

    // Angle to align pointer (top center = 3*pi/2 or -pi/2) with selected sector
    final targetSectorCenter = (targetIndex * sectorAngle) + (sectorAngle / 2);
    const fullRotations = 5 * 2 * math.pi; // 5 full spins
    final targetAngle = _currentAngle + fullRotations + ((2 * math.pi) - targetSectorCenter) - (math.pi / 2);

    _spinAnimation = Tween<double>(
      begin: _currentAngle,
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    ));

    _spinController.reset();
    _spinController.forward().then((_) {
      setState(() {
        _currentAngle = targetAngle % (2 * math.pi);
        _isSpinning = false;
      });

      _handleSpinResult(_sectors[targetIndex]);
    });
  }

  void _handleSpinResult(WheelSector sector) {
    widget.onRewardClaimed?.call(sector.coins);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
        title: Center(
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: sector.coins > 0 ? AppColors.coinGoldLight : AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  sector.coins > 0 ? Icons.emoji_events : Icons.sentiment_satisfied,
                  color: sector.coins > 0 ? AppColors.coinGold : AppColors.textMuted,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                sector.coins > 0 ? 'Congratulations! 🎉' : 'Keep Trying! ✨',
                style: AppTypography.titleLarge,
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sector.coins > 0
                  ? 'You won ${sector.label} on the Lucky Wheel!'
                  : 'Better luck next time! Return tomorrow for a free spin.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            if (sector.coins > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimaryLight,
                  borderRadius: AppRadii.borderPill,
                ),
                child: Text(
                  '+${sector.coins} Coins credited to your wallet',
                  style: const TextStyle(color: AppColors.brandPrimaryDark, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          Center(
            child: AppButton(
              label: 'Claim & Continue',
              size: AppButtonSize.small,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daily Lucky Wheel 🎡'),
        backgroundColor: AppColors.brandPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: AppCoinPill(coins: widget.currentCoins),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          children: [
            // Banner header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: AppRadii.borderLg,
                boxShadow: AppShadows.emeraldGlow,
              ),
              child: Column(
                children: [
                  const Text(
                    'Spin the Wheel to Win Coins!',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Free daily spin available every 24 hours',
                    style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Wheel Container with Pointer Arrow
            Stack(
              alignment: Alignment.center,
              children: [
                // Wheel Circle Canvas
                SizedBox(
                  width: 320,
                  height: 320,
                  child: AnimatedBuilder(
                    animation: _spinController,
                    builder: (context, child) {
                      final angle = _isSpinning ? _spinAnimation.value : _currentAngle;
                      return Transform.rotate(
                        angle: angle,
                        child: CustomPaint(
                          painter: _WheelPainter(sectors: _sectors),
                        ),
                      );
                    },
                  ),
                ),

                // Top Pointer Arrow pointing DOWN at 12 o'clock
                Positioned(
                  top: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 4)),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_drop_down,
                      size: 48,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),

                // Center Gold Spin Hub
                GestureDetector(
                  onTap: _isSpinning ? null : _spinWheel,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Color(0x40000000), blurRadius: 10, offset: Offset(0, 4)),
                      ],
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _isSpinning ? '...' : 'SPIN',
                      style: const TextStyle(
                        color: Color(0xFF78350F),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Spin Status & Button
            Text(
              _spinsRemainingToday > 0 ? '1 Free Spin Available Today' : 'No Free Spins Remaining (Come back tomorrow)',
              style: AppTypography.titleSmall.copyWith(
                color: _spinsRemainingToday > 0 ? AppColors.brandPrimaryDark : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),

            AppButton(
              label: _isSpinning ? 'Spinning...' : 'SPIN FOR FREE',
              isLoading: _isSpinning,
              disabled: _spinsRemainingToday <= 0,
              width: 240,
              onPressed: _spinWheel,
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<WheelSector> sectors;

  _WheelPainter({required this.sectors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final arcAngle = (2 * math.pi) / sectors.length;

    // Outer gold border ring
    final borderPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius - 4, borderPaint);

    final sectorPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < sectors.length; i++) {
      final sector = sectors[i];
      final startAngle = i * arcAngle;

      sectorPaint.color = sector.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 8),
        startAngle,
        arcAngle,
        true,
        sectorPaint,
      );

      // Draw Sector Text
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + (arcAngle / 2));

      final textSpan = TextSpan(
        text: sector.label,
        style: TextStyle(
          color: sector.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Position text along the radius
      textPainter.paint(
        canvas,
        Offset(radius * 0.45, -textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
