import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/live_poll_model.dart';

class LivePollPreviewPanel extends StatelessWidget {
  final LivePollData pollData;
  final VoidCallback? onOptionTap;

  const LivePollPreviewPanel({
    super.key,
    required this.pollData,
    this.onOptionTap,
  });

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatTimer(int seconds) {
    if (seconds <= 0) return '00:00';
    if (seconds >= 86400) {
      final d = seconds ~/ 86400;
      final h = (seconds % 86400) ~/ 3600;
      return '${d}d ${h}h left';
    }
    if (seconds >= 3600) {
      final h = seconds ~/ 3600;
      final m = (seconds % 3600) ~/ 60;
      final s = seconds % 60;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final leading = pollData.leadingOption;
    final leadingPct = leading != null && pollData.totalVotes > 0
        ? pollData.getPercentage(leading).round()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. TOP HERO POLL CANVAS
        Container(
          decoration: const BoxDecoration(
            borderRadius: AppRadii.pollCanvas,
            gradient: AppColors.pollCanvasGradient,
            boxShadow: AppShadows.pollCanvas,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Wave Background Painter
              Positioned.fill(
                child: CustomPaint(
                  painter: _PurpleWavePainter(),
                ),
              ),

              // Content inside the canvas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Bar: LIVE POLL + Viewer Count
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Red LIVE POLL badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: AppRadii.borderPill,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withAlpha(100),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, color: Colors.white, size: 8),
                              SizedBox(width: 6),
                              Text(
                                'LIVE POLL',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Viewer Count Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: AppRadii.borderPill,
                            border: Border.all(color: Colors.white.withAlpha(40)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.people_alt_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                '${_formatNumber(pollData.liveViewers)} Live',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Centered Question Text (Hindi / English)
                    Text(
                      pollData.question.isEmpty
                          ? 'Enter your poll question...'
                          : pollData.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Dynamic Answer Option Bars
                    Column(
                      children: pollData.options.map((opt) {
                        final isLeading = pollData.totalVotes > 0 && opt == leading;
                        final pct = pollData.getPercentage(opt).round();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isLeading
                                ? AppColors.pollLeadingGreen // Vibrant green highlight for winner token
                                : Colors.white.withAlpha(22), // Translucent glassmorphism
                            borderRadius: AppRadii.pollOption,
                            border: Border.all(
                              color: isLeading
                                  ? AppColors.pollLeadingGreenBorder
                                  : Colors.white.withAlpha(35),
                              width: 1,
                            ),
                            boxShadow: isLeading
                                ? [
                                    BoxShadow(
                                      color: AppColors.pollLeadingGreen.withAlpha(100),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Stack(
                            children: [
                              // Subtle background progress indicator when not leading
                              if (!isLeading && pollData.showLiveResult && pct > 0)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: pct * 3.5, // Visual indicator
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(15),
                                      borderRadius: AppRadii.pollOption,
                                    ),
                                  ),
                                ),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    // Option Circle Badge (A, B, C, D)
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: isLeading
                                            ? Colors.white.withAlpha(60)
                                            : Colors.white.withAlpha(40),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        opt.label,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Option Text
                                    Expanded(
                                      child: Text(
                                        opt.text.trim().isEmpty ? 'Option ${opt.label}' : opt.text,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isLeading ? FontWeight.w800 : FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                    // Percentage
                                    if (pollData.showLiveResult)
                                      Text(
                                        '$pct%',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. BOTTOM 4 METRICS CARDS (Responsive: 2x2 grid on mobile, 4-in-a-row on desktop)
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;

            final card1 = _buildMetricCard(
              icon: Icons.people_alt_rounded,
              iconColor: AppColors.pollPurplePrimary,
              iconBg: AppColors.pollPurpleLight,
              value: _formatNumber(pollData.totalVotes),
              label: 'Total Votes',
            );
            final card2 = _buildMetricCard(
              icon: Icons.visibility_rounded,
              iconColor: AppColors.pollLeadingGreen,
              iconBg: const Color(0xFFDCFCE7),
              value: _formatNumber(pollData.liveViewers),
              label: 'Live Viewers',
            );
            final card3 = _buildMetricCard(
              icon: Icons.bar_chart_rounded,
              iconColor: AppColors.coinGold,
              iconBg: AppColors.coinGoldLight,
              value: '$leadingPct%',
              label: 'Leading Option',
            );
            final card4 = _buildMetricCard(
              icon: Icons.access_time_rounded,
              iconColor: AppColors.brandBlue,
              iconBg: AppColors.brandBlueLight,
              value: _formatTimer(pollData.remainingSeconds),
              label: 'Time Left',
            );

            if (isNarrow) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: card1),
                      const SizedBox(width: 10),
                      Expanded(child: card2),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: card3),
                      const SizedBox(width: 10),
                      Expanded(child: card4),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: card1),
                const SizedBox(width: 12),
                Expanded(child: card2),
                const SizedBox(width: 12),
                Expanded(child: card3),
                const SizedBox(width: 12),
                Expanded(child: card4),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadii.borderSm,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the cosmic purple gradient wave background
class _PurpleWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = AppColors.pollCanvasWave1.withAlpha(35)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);
    path1.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.55,
      size.width * 0.65,
      size.height * 0.85,
    );
    path1.quadraticBezierTo(
      size.width * 0.85,
      size.height * 1.0,
      size.width,
      size.height * 0.75,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = AppColors.pollCanvasWave2.withAlpha(25)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.85);
    path2.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.95,
      size.width,
      size.height * 0.65,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

