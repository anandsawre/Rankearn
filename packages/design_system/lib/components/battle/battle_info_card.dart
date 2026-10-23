import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';

/// Row of 3 Fair Matchmaking Benefit Cards
class MatchmakingFairCardsRow extends StatelessWidget {
  const MatchmakingFairCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _MatchInfoCard(
            icon: Icons.bolt_rounded,
            iconColor: Color(0xFF00C975),
            badgeColor: Color(0xFFE4FAF0),
            title: '1v1 Battle',
            subtitle: 'Real Players',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _MatchInfoCard(
            icon: Icons.emoji_events_rounded,
            iconColor: Color(0xFFF59E0B),
            badgeColor: Color(0xFFFFF7D6),
            title: 'Fair Match',
            subtitle: 'Similar Skill',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _MatchInfoCard(
            icon: Icons.verified_user_rounded,
            iconColor: Color(0xFF3B82F6),
            badgeColor: Color(0xFFEFF6FF),
            title: 'No Bots',
            subtitle: '100% Real',
          ),
        ),
      ],
    );
  }
}

class _MatchInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color badgeColor;
  final String title;
  final String subtitle;

  const _MatchInfoCard({
    required this.icon,
    required this.iconColor,
    required this.badgeColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        boxShadow: AppShadows.subtle,
        border: Border.all(color: AppColors.battleBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.battleNavy,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.battleSecondaryText,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// "Did you know?" Information Banner Card with 3D Coin Stack
class BattleTipBanner extends StatelessWidget {
  final String title;
  final String message;

  const BattleTipBanner({
    super.key,
    this.title = 'Did you know?',
    this.message = 'Win battles to earn coins and improve your global rank!',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE7FAF0),
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0xFFC7F3DD), width: 1.2),
      ),
      child: Row(
        children: [
          // Glowing lightbulb badge
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFD0F6E2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFF00B96B),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Message texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF008C52),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C5E47),
                    height: 1.25,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Professional Vector Gold Coin Medallion with Sparkle
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33FFB800),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.monetization_on_rounded,
                color: Color(0xFFFFB800),
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
