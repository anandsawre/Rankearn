import 'package:flutter/material.dart';

/// Smooth Rolling Coin Counter Motion Graphic
/// Counts smoothly from start to target amount with scale-pop on landing and optional floating delta chip.
class AnimatedCoinCounter extends StatefulWidget {
  final int targetCoins;
  final int startCoins;
  final Duration duration;
  final TextStyle? style;
  final bool showRupeeIcon;
  final bool showFloatingDelta;

  const AnimatedCoinCounter({
    super.key,
    required this.targetCoins,
    this.startCoins = 0,
    this.duration = const Duration(milliseconds: 1400),
    this.style,
    this.showRupeeIcon = true,
    this.showFloatingDelta = true,
  });

  @override
  State<AnimatedCoinCounter> createState() => _AnimatedCoinCounterState();
}

class _AnimatedCoinCounterState extends State<AnimatedCoinCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _popAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _popAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 70),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCoinCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetCoins != widget.targetCoins) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delta = widget.targetCoins - widget.startCoins;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final current = (widget.startCoins + (delta * _animation.value)).round();

        return ScaleTransition(
          scale: _popAnimation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.showRupeeIcon) ...[
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF78350F),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                '$current Coins',
                style: widget.style ??
                    const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
              ),
              if (widget.showFloatingDelta && delta > 0) ...[
                const SizedBox(width: 8),
                Opacity(
                  opacity: _animation.value.clamp(0.0, 1.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF86EFAC), width: 1),
                    ),
                    child: Text(
                      '+$delta',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

