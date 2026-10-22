import 'package:flutter/material.dart';

/// Quick Actions & Rewards sidebar card for the Rewards tab matching reference design
class QuickActionsRewardsCard extends StatelessWidget {
  final VoidCallback? onSpinWheel;
  final VoidCallback? onQuizBattle;

  const QuickActionsRewardsCard({
    super.key,
    this.onSpinWheel,
    this.onQuizBattle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section Header Row: Lightning Icon + Title
        Row(
          children: const [
            Icon(
              Icons.bolt_rounded,
              color: Color(0xFFF59E0B),
              size: 22,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Quick Actions & Rewards',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111A4B),
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Action Card 1: Spin Lucky Wheel
        _buildActionTile(
          title: 'Spin Lucky Wheel',
          subtitle: 'Win up to 500 Coins today',
          bgColor: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFEF3C7),
          iconWidget: _buildRainbowWheelIcon(),
          chevronColor: const Color(0xFFF59E0B),
          onTap: onSpinWheel,
        ),
        const SizedBox(height: 10),

        // Action Card 2: 1v1 Quiz Battle
        _buildActionTile(
          title: '1v1 Quiz Battle',
          subtitle: 'Challenge live aspirants now',
          bgColor: const Color(0xFFF5F3FF),
          borderColor: const Color(0xFFEDE9FE),
          iconWidget: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.sports_esports_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          chevronColor: const Color(0xFF8B5CF6),
          onTap: onQuizBattle,
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required Color bgColor,
    required Color borderColor,
    required Widget iconWidget,
    required Color chevronColor,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                iconWidget,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111A4B),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: chevronColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRainbowWheelIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [
            Color(0xFFEF4444),
            Color(0xFFF59E0B),
            Color(0xFF10B981),
            Color(0xFF06B6D4),
            Color(0xFF3B82F6),
            Color(0xFF8B5CF6),
            Color(0xFFEC4899),
            Color(0xFFEF4444),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: const Center(
            child: Icon(
              Icons.stars_rounded,
              color: Color(0xFFF59E0B),
              size: 12,
            ),
          ),
        ),
      ),
    );
  }
}
