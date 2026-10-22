import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// TopRewardsCard matching the Rankearn Live Tests reference dashboard sidebar
class TopRewardsCard extends StatelessWidget {
  final VoidCallback? onTap;
  final Function(String rewardType)? onRewardTap;

  const TopRewardsCard({
    super.key,
    this.onTap,
    this.onRewardTap,
  });

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
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    color: Color(0xFFF43F5E),
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

          // 4 Compact Reward Tiles
          Row(
            children: [
              Expanded(
                child: _buildRewardTile(
                  icon: Icons.monetization_on_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFFEF3C7),
                  label: 'Coins',
                  onTap: () => onRewardTap?.call('Coins'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRewardTile(
                  icon: Icons.emoji_events_rounded,
                  iconColor: const Color(0xFFEAB308),
                  bgColor: const Color(0xFFFEF9C3),
                  label: 'Rank Badges',
                  onTap: () => onRewardTap?.call('Rank Badges'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRewardTile(
                  icon: Icons.description_rounded,
                  iconColor: const Color(0xFF2587F8),
                  bgColor: const Color(0xFFE0F2FE),
                  label: 'Certificates',
                  onTap: () => onRewardTap?.call('Certificates'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRewardTile(
                  icon: Icons.redeem_rounded,
                  iconColor: const Color(0xFFEF4444),
                  bgColor: const Color(0xFFFFE4E6),
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

  Widget _buildRewardTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
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
