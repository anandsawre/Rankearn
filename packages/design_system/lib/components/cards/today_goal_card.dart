import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// TodayGoalCard matching the Rankearn reference dashboard
class TodayGoalCard extends StatelessWidget {
  final int completed;
  final int target;
  final String? subtitle;
  final String unitLabel;
  final VoidCallback onTap;

  final Color accentColor;

  const TodayGoalCard({
    super.key,
    required this.completed,
    required this.target,
    this.subtitle,
    this.unitLabel = 'Tests',
    required this.onTap,
    this.accentColor = const Color(0xFF10B981),
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (completed / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(accentColor.withAlpha(20), Colors.white),
            Colors.white,
          ],
        ),
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: accentColor.withAlpha(45), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          const BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadii.borderLg,
        child: Stack(
          children: [
            // 1. Soft Halo Glow in Top Right
            Positioned(
              top: -25,
              right: -25,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withAlpha(20),
                ),
              ),
            ),

            // 2. Concentric Arc Ring
            Positioned(
              top: -35,
              right: -35,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withAlpha(18),
                    width: 1.0,
                  ),
                ),
              ),
            ),

            // 3. Dot-Matrix Tech Grid
            Positioned(
              right: 28,
              top: 10,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(40, 24),
                  painter: _CardMiniDotPainter(color: accentColor.withAlpha(35)),
                ),
              ),
            ),

            // 4. Faint Target Bullseye Watermark Icon
            Positioned(
              right: 18,
              bottom: -8,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: -0.12,
                  child: Icon(
                    Icons.track_changes_rounded,
                    size: 64,
                    color: accentColor.withAlpha(20),
                  ),
                ),
              ),
            ),

            // 5. Foreground Content
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: AppRadii.borderLg,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
              // Target Dartboard Icon
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF0FDF4),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Target Bullseye circles
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE11D48),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22E11D48),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                      // Dart arrow
                      const Positioned(
                        right: 4,
                        top: 4,
                        child: Icon(
                          Icons.navigation_rounded,
                          size: 20,
                          color: Color(0xFF2587F8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Goal Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            "Today's Goal",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                          fontFamily: 'Inter',
                        ),
                        children: [
                          TextSpan(text: '$completed/$target '),
                          TextSpan(
                            text: unitLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: AppRadii.borderPill,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.brandGreen,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle ??
                          'Complete $target tests today to earn 50 coins!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter for rendering subtle dot matrix grid on cards
class _CardMiniDotPainter extends CustomPainter {
  final Color color;

  const _CardMiniDotPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 8.0;
    const dotRadius = 1.0;
    const cols = 5;
    const rows = 3;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(c * spacing, r * spacing),
          dotRadius,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CardMiniDotPainter oldDelegate) =>
      oldDelegate.color != color;
}
