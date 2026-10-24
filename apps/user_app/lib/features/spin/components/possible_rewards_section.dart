import 'package:flutter/material.dart';
import '../models/spin_reward_model.dart';
import 'reward_art.dart';

/// Bottom showcase of the 8 possible rewards matching the reference:
/// - 10 Coins
/// - 50 Coins
/// - 100 Coins
/// - 200 Coins
/// - 500 Coins
/// - Rank Booster
/// - Extra Attempt
/// - Surprise Gift
class PossibleRewardsSection extends StatelessWidget {
  final List<SpinRewardItem> rewards;
  final ValueChanged<SpinRewardItem>? onRewardTap;

  const PossibleRewardsSection({
    super.key,
    this.rewards = SpinRewardItem.showcaseList,
    this.onRewardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDFECFA), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0610194F),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title: 🎁 Possible Rewards
          Row(
            children: const [
              Text('🎁', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Possible Rewards',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10194F),
                  fontFamily: 'Inter',
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 8 Horizontal Reward Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 640;

              if (isWide) {
                // Desktop / Tablet: Spread all 8 evenly
                return Row(
                  children: rewards.map((r) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildRewardCard(r),
                      ),
                    );
                  }).toList(),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: rewards.map((r) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(width: 76, child: _buildRewardCard(r)),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(SpinRewardItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: item.cardTint.withAlpha(80),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: item.accentColor.withAlpha(45), width: 1.1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Reward Icon
          SizedBox(
            width: 38,
            height: 38,
            child: RewardArtWidget(rewardId: item.id, size: 34),
          ),
          const SizedBox(height: 6),

          // Title (e.g. 10, 50, Rank, Extra)
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF10194F),
              fontFamily: 'Inter',
              letterSpacing: -0.2,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          // Subtitle (e.g. Coins, Booster, Attempt)
          Text(
            item.subtitle,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF586B9B),
              fontFamily: 'Inter',
              height: 1.15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
