import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'wallet_icons.dart';

/// Trophy & Coins Graphic for Daily Tasks Banner
class TrophyIllustration extends StatelessWidget {
  final double size;

  const TrophyIllustration({super.key, this.size = 54.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.35,
      height: size,
      child: Image.asset(
        'assets/images/daily_tasks_trophy.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return SizedBox(
      width: size * 1.25,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Background soft coin
          Positioned(
            left: 0,
            bottom: 4,
            child: RankearnCurrencyCoin(size: size * 0.46),
          ),
          // Foreground trophy icon
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFE082), width: 1.5),
            ),
            child: Center(
              child: Icon(
                Icons.emoji_events_rounded,
                size: size * 0.52,
                color: const Color(0xFFF59E0B),
              ),
            ),
          ),
          // Front small coin
          Positioned(
            right: 0,
            bottom: 2,
            child: RankearnCurrencyCoin(size: size * 0.4),
          ),
        ],
      ),
    );
  }
}

/// Gift Box Illustration for Refer & Earn Banner
class GiftBoxIllustration extends StatelessWidget {
  final double size;

  const GiftBoxIllustration({super.key, this.size = 54.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.35,
      height: size,
      child: Image.asset(
        'assets/images/refer_earn_gift.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return SizedBox(
      width: size * 1.25,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Background soft coin
          Positioned(
            left: 0,
            bottom: 2,
            child: RankearnCurrencyCoin(size: size * 0.46),
          ),
          // Foreground gift icon
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDDD6FE), width: 1.5),
            ),
            child: Center(
              child: Icon(
                Icons.card_giftcard_rounded,
                size: size * 0.52,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ),
          // Front small coin
          Positioned(
            right: 0,
            bottom: 2,
            child: RankearnCurrencyCoin(size: size * 0.4),
          ),
        ],
      ),
    );
  }
}

/// "Complete Daily Tasks" Promotional Banner
class DailyTasksBanner extends StatelessWidget {
  final VoidCallback onViewTasks;

  const DailyTasksBanner({super.key, required this.onViewTasks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8FDF2), Color(0xFFDCFCE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const TrophyIllustration(size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Complete Daily Tasks',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.walletNavy,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Earn more coins by playing tests, battles and spin wheel.',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.walletSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onViewTasks,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC928),
              foregroundColor: const Color(0xFF10194F),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'View Tasks',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Refer & Earn" Promotional Banner
class ReferEarnBanner extends StatelessWidget {
  final VoidCallback onReferNow;

  const ReferEarnBanner({super.key, required this.onReferNow});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDD6FE), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const GiftBoxIllustration(size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Refer & Earn',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.walletNavy,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Invite your friends and earn 200 coins per referral.',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.walletSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onReferNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Refer Now',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dual Promotional Banners side-by-side for Desktop, stacked for Tablet/Mobile
class DesktopPromotionalBannersSection extends StatelessWidget {
  final VoidCallback onViewTasks;
  final VoidCallback onReferNow;

  const DesktopPromotionalBannersSection({
    super.key,
    required this.onViewTasks,
    required this.onReferNow,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 740;

        if (isSmall) {
          return Column(
            children: [
              DailyTasksBanner(onViewTasks: onViewTasks),
              const SizedBox(height: 14),
              ReferEarnBanner(onReferNow: onReferNow),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: DailyTasksBanner(onViewTasks: onViewTasks)),
            const SizedBox(width: 20),
            Expanded(child: ReferEarnBanner(onReferNow: onReferNow)),
          ],
        );
      },
    );
  }
}
