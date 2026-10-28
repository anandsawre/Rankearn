import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// ContinueLearningCard matching the Rankearn reference dashboard
class ContinueLearningCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress; // 0.0 to 1.0
  final String tag;
  final VoidCallback onContinue;
  final VoidCallback? onViewAll;

  const ContinueLearningCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.tag = 'RRB Technician',
    required this.onContinue,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.brandPurpleLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.brandPurple,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Continue Learning',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (onViewAll != null)
              InkWell(
                onTap: onViewAll,
                child: Row(
                  children: const [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandPurple,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.brandPurple,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Card Container with Themed Background Design
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(const Color(0xFF10B981).withAlpha(18), Colors.white),
                Colors.white,
              ],
            ),
            borderRadius: AppRadii.borderLg,
            border: Border.all(
              color: const Color(0xFF10B981).withAlpha(45),
              width: 1.1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1410B981),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
              BoxShadow(
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
                      color: const Color(0xFF10B981).withAlpha(18),
                    ),
                  ),
                ),

                // 2. Concentric Arc Ring
                Positioned(
                  top: -35,
                  right: -35,
                  child: Container(
                    width: 115,
                    height: 115,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF10B981).withAlpha(16),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),

                // 3. Tech Dot-Matrix Grid
                Positioned(
                  right: 65,
                  top: 10,
                  child: IgnorePointer(
                    child: CustomPaint(
                      size: const Size(40, 24),
                      painter: _ContinueDotPainter(
                        color: const Color(0xFF10B981).withAlpha(30),
                      ),
                    ),
                  ),
                ),

                // 4. Faint Book/Play Watermark Icon in background
                Positioned(
                  right: 18,
                  bottom: -8,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: -0.12,
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 64,
                        color: Color(0x2010B981),
                      ),
                    ),
                  ),
                ),

                // 5. Foreground Content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Thumbnail Box
                      Container(
                        width: 72,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: AppRadii.borderMd,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFF1E3A8A)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.train_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(120),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title, Subtitle, Progress Bar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: AppRadii.borderPill,
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: const Color(0xFFE2E8F0),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        AppColors.brandGreen,
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$percent%',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Round Green Play Button
                      InkWell(
                        onTap: onContinue,
                        borderRadius: AppRadii.borderPill,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.brandGreen,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x3310B981),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter for rendering subtle dot matrix grid on Continue Learning card
class _ContinueDotPainter extends CustomPainter {
  final Color color;

  const _ContinueDotPainter({required this.color});

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
  bool shouldRepaint(covariant _ContinueDotPainter oldDelegate) =>
      oldDelegate.color != color;
}
