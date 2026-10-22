import 'package:flutter/material.dart';

enum BattleType {
  quick,
  ranked,
  friends,
}

/// BattleTypeCard matching the "Choose Battle Type" section in the Rankearn reference.
class BattleTypeCard extends StatelessWidget {
  final BattleType type;
  final String title;
  final String subtitle;
  final String rewardLabel;
  final String ctaLabel;
  final Widget iconWidget;
  final Color accentColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onAction;

  const BattleTypeCard({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.rewardLabel,
    required this.ctaLabel,
    required this.iconWidget,
    required this.accentColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onAction,
  });

  /// Factory for "Quick Battle" preset
  factory BattleTypeCard.quick({required VoidCallback onPlay}) {
    return BattleTypeCard(
      type: BattleType.quick,
      title: 'Quick Battle',
      subtitle: 'Random opponent\nInstant match',
      rewardLabel: 'Win 50 Coins',
      ctaLabel: 'Play Now',
      accentColor: const Color(0xFF10B981),
      backgroundColor: const Color(0xFFF0FDF4),
      borderColor: const Color(0xFFBBF7D0),
      onAction: onPlay,
      iconWidget: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.rocket_launch_rounded,
            size: 34,
            color: Color(0xFF047857),
          ),
        ),
      ),
    );
  }

  /// Factory for "Ranked Battle" preset
  factory BattleTypeCard.ranked({required VoidCallback onPlay}) {
    return BattleTypeCard(
      type: BattleType.ranked,
      title: 'Ranked Battle',
      subtitle: 'Play with skilled players\nImprove your rank',
      rewardLabel: 'Win 100 Coins',
      ctaLabel: 'Play Now',
      accentColor: const Color(0xFF8B5CF6),
      backgroundColor: const Color(0xFFF5F3FF),
      borderColor: const Color(0xFFDDD6FE),
      onAction: onPlay,
      iconWidget: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FE),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.workspace_premium_rounded,
            size: 34,
            color: Color(0xFFEAB308),
          ),
        ),
      ),
    );
  }

  /// Factory for "Friends Battle" preset
  factory BattleTypeCard.friends({required VoidCallback onCreateRoom}) {
    return BattleTypeCard(
      type: BattleType.friends,
      title: 'Friends Battle',
      subtitle: 'Challenge your friends\nCreate a room',
      rewardLabel: 'Win Custom Coins',
      ctaLabel: 'Create Room',
      accentColor: const Color(0xFFF97316),
      backgroundColor: const Color(0xFFFFF7ED),
      borderColor: const Color(0xFFFED7AA),
      onAction: onCreateRoom,
      iconWidget: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEDD5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF97316).withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.group_add_rounded,
            size: 34,
            color: Color(0xFFEA580C),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Top Graphic / 3D Icon
          iconWidget,
          const SizedBox(height: 12),

          // 2. Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111A4B),
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // 3. Subtitle description
          SizedBox(
            height: 32,
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF566797),
                height: 1.25,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 10),

          // 4. Reward pill badge
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: Color(0xFFF59E0B),
                  size: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  rewardLabel,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 5. CTA Button
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shadowColor: accentColor.withValues(alpha: 0.4),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ctaLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
