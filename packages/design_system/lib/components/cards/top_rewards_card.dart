import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// TopRewardsCard matching the Rankearn Live Tests reference dashboard sidebar
class TopRewardsCard extends StatelessWidget {
  final VoidCallback? onTap;
  final Function(String rewardType)? onRewardTap;

  const TopRewardsCard({super.key, this.onTap, this.onRewardTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(
          color: const Color(0xFFFCE7F3), // Subtle soft pink border
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08F43F5E),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Pink Gift Icon + Title & Subtitle
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF43F5E), // Solid rose color
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.28),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    color: Colors.white, // White icon
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Top Rewards',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Win exciting rewards in live tests!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 Reward Tiles: Fade outer card, solid icon container, white icon
          Row(
            children: [
              Expanded(
                child: _RewardTile(
                  icon: Icons.monetization_on_rounded,
                  solidColor: const Color(0xFFF59E0B),
                  fadeColor: const Color(0xFFFFFBEB),
                  borderColor: const Color(0xFFFDE68A),
                  label: 'Coins',
                  onTap: () => onRewardTap?.call('Coins'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RewardTile(
                  icon: Icons.emoji_events_rounded,
                  solidColor: const Color(0xFFEAB308),
                  fadeColor: const Color(0xFFFEFCE8),
                  borderColor: const Color(0xFFFEF08A),
                  label: 'Rank Badges',
                  onTap: () => onRewardTap?.call('Rank Badges'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RewardTile(
                  icon: Icons.description_rounded,
                  solidColor: const Color(0xFF2587F8),
                  fadeColor: const Color(0xFFEFF6FF),
                  borderColor: const Color(0xFFBFDBFE),
                  label: 'Certificates',
                  onTap: () => onRewardTap?.call('Certificates'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RewardTile(
                  icon: Icons.card_giftcard_rounded,
                  solidColor: const Color(0xFFF43F5E),
                  fadeColor: const Color(0xFFFFF1F2),
                  borderColor: const Color(0xFFFECDD3),
                  label: 'Exciting Prizes',
                  onTap: () => onRewardTap?.call('Exciting Prizes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardTile extends StatefulWidget {
  final IconData icon;
  final Color solidColor;
  final Color fadeColor;
  final Color borderColor;
  final String label;
  final VoidCallback onTap;

  const _RewardTile({
    required this.icon,
    required this.solidColor,
    required this.fadeColor,
    required this.borderColor,
    required this.label,
    required this.onTap,
  });

  @override
  State<_RewardTile> createState() => _RewardTileState();
}

class _RewardTileState extends State<_RewardTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: widget.fadeColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovering
                  ? widget.solidColor.withValues(alpha: 0.5)
                  : widget.borderColor,
              width: 1.1,
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: widget.solidColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Solid icon square with white icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: widget.solidColor,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: widget.solidColor.withValues(
                        alpha: _hovering ? 0.40 : 0.25,
                      ),
                      blurRadius: _hovering ? 7 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(widget.icon, color: Colors.white, size: 19),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
