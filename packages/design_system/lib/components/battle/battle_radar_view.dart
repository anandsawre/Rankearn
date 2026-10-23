import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

/// Animated Matchmaking Radar View
/// Features concentric rings, glowing orbiting dots, avatar orbiters,
/// and a pulsating central radar scanner icon.
class MatchmakingRadar extends StatefulWidget {
  final double size;
  final List<String>? avatarUrls;

  const MatchmakingRadar({
    super.key,
    this.size = 280,
    this.avatarUrls,
  });

  @override
  State<MatchmakingRadar> createState() => _MatchmakingRadarState();
}

class _MatchmakingRadarState extends State<MatchmakingRadar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return SizedBox(
      width: s,
      height: s,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final angle = progress * 2 * math.pi;

          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. Concentric Radial Background Circles
              CustomPaint(
                size: Size(s, s),
                painter: _RadarBackgroundPainter(progress: progress),
              ),

              // 2. Six Orbiting Player Avatars on circumference
              ...List.generate(6, (index) {
                final baseAngle = (index * 60) * (math.pi / 180);
                final currentAngle = baseAngle + (angle * (index % 2 == 0 ? 0.25 : -0.25));
                final radius = (s * 0.42);

                final x = radius * math.cos(currentAngle);
                final y = radius * math.sin(currentAngle);

                return Transform.translate(
                  offset: Offset(x, y),
                  child: _buildAvatarOrbiter(index),
                );
              }),

              // 3. Central Pulsing Radar Scanner Circle
              Container(
                width: s * 0.32,
                height: s * 0.32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD3F9E5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.battleGreen.withAlpha((40 + 25 * math.sin(angle * 2)).toInt()),
                      blurRadius: 18,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Container(
                  width: s * 0.24,
                  height: s * 0.24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF00C975), Color(0xFF009C5A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatarOrbiter(int index) {
    // Unique color palette and 3D avatars for the demo search orbiters
    final avatarColors = [
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF10B981),
      const Color(0xFF6366F1),
    ];
    final color = avatarColors[index % avatarColors.length];
    final assetPath = (index % 2 == 0)
        ? 'assets/images/battle_player_green.png'
        : 'assets/images/battle_player_red.png';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: color.withAlpha(120), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => CircleAvatar(
            backgroundColor: color.withAlpha(40),
            child: Icon(
              index % 2 == 0 ? Icons.face_rounded : Icons.face_3_rounded,
              color: color,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarBackgroundPainter extends CustomPainter {
  final double progress;

  _RadarBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // 1. Draw 3 static concentric guide rings
    final ringPaint = Paint()
      ..color = const Color(0xFFC7F3DD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, maxRadius * 0.45, ringPaint);
    canvas.drawCircle(center, maxRadius * 0.70, ringPaint);
    canvas.drawCircle(center, maxRadius * 0.95, ringPaint);

    // 2. Draw expanding radar ripple waves
    for (int i = 0; i < 2; i++) {
      final waveProgress = (progress + (i * 0.5)) % 1.0;
      final waveRadius = (maxRadius * 0.35) + (waveProgress * (maxRadius * 0.65));
      final waveAlpha = ((1.0 - waveProgress) * 70).toInt().clamp(0, 255);

      final wavePaint = Paint()
        ..color = AppColors.battleGreen.withAlpha(waveAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, waveRadius, wavePaint);
    }

    // 3. Draw small glowing green dots along the concentric rings
    final dotPaint = Paint()
      ..color = const Color(0xFF00C975)
      ..style = PaintingStyle.fill;

    final dotAngles = [0.4, 1.2, 2.1, 3.4, 4.3, 5.2];
    for (int i = 0; i < dotAngles.length; i++) {
      final r = maxRadius * (i % 2 == 0 ? 0.70 : 0.45);
      final a = dotAngles[i] + (progress * 2 * math.pi * (i % 2 == 0 ? 0.15 : -0.15));
      final dotCenter = Offset(
        center.dx + r * math.cos(a),
        center.dy + r * math.sin(a),
      );
      canvas.drawCircle(dotCenter, 4.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
