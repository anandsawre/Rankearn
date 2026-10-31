import 'package:flutter/material.dart';

/// Glowing Concentric Pulsing Ring Motion Graphic
/// Ideal for "LIVE NOW", countdown indicators, and real-time status badges.
class LivePulseMotion extends StatefulWidget {
  final Widget child;
  final Color pulseColor;
  final double maxRadius;
  final Duration duration;

  const LivePulseMotion({
    super.key,
    required this.child,
    this.pulseColor = const Color(0xFFEF4444), // Crimson Red
    this.maxRadius = 14.0,
    this.duration = const Duration(milliseconds: 1600),
  });

  @override
  State<LivePulseMotion> createState() => _LivePulseMotionState();
}

class _LivePulseMotionState extends State<LivePulseMotion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final spread = progress * widget.maxRadius;
        final alpha = (1.0 - progress).clamp(0.0, 1.0) * 0.45;

        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.pulseColor.withValues(alpha: alpha),
                blurRadius: spread * 1.5,
                spreadRadius: spread,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

