import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../buttons/app_button.dart';

/// Right-side Matchmaking Progress Panel on Desktop (or integrated in Mobile)
/// Matches Reference Image 3:
/// - "Matchmaking in Progress" heading with live signal icon
/// - 3-stage progress stepper: 1 Finding Player -> 2 Checking Skill Level -> 3 Connecting To Arena
/// - Estimated Wait Time (10 - 30 seconds)
/// - Your Skill Level (Intermediate chip)
/// - Players Online (2,468 live dot)
class MatchmakingProgressPanel extends StatelessWidget {
  final int activeStage; // 1, 2, or 3
  final String waitTime;
  final String skillLevel;
  final String playersOnline;

  const MatchmakingProgressPanel({
    super.key,
    this.activeStage = 1,
    this.waitTime = '10 - 30 seconds',
    this.skillLevel = 'Intermediate',
    this.playersOnline = '2,468',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.battleBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C10194F),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Heading with Live Signal Icon
          Row(
            children: const [
              Icon(Icons.sensors_rounded, color: Color(0xFF00B96B), size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Matchmaking in Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.battleNavy,
                    letterSpacing: -0.2,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Searching for a fair match based on your skill level...',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.battleSecondaryText,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 18),

          // 2. Three-Stage Progress Stepper
          _buildStageStepper(),
          const SizedBox(height: 20),

          // 3. Status Rows (Wait Time, Skill Level, Players Online)
          _buildStatusRow(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFF00B96B),
            title: 'Estimated Wait Time',
            subtitle: waitTime,
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildStatusRow(
            icon: Icons.bar_chart_rounded,
            iconColor: const Color(0xFF00B96B),
            title: 'Your Skill Level',
            subtitle: skillLevel,
            isChip: true,
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildStatusRow(
            icon: Icons.groups_rounded,
            iconColor: const Color(0xFF00B96B),
            title: 'Players Online',
            subtitle: playersOnline,
            hasLiveDot: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStageStepper() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stage 1
        Expanded(
          child: _buildStageNode(
            stepNumber: 1,
            label: 'Finding\nPlayer',
            isCompleted: activeStage > 1,
            isActive: activeStage == 1,
          ),
        ),
        // Connecting line 1-2
        Container(
          width: 32,
          height: 2,
          margin: const EdgeInsets.only(top: 14),
          color: activeStage > 1 ? const Color(0xFF00B96B) : const Color(0xFFE2E8F0),
        ),
        // Stage 2
        Expanded(
          child: _buildStageNode(
            stepNumber: 2,
            label: 'Checking\nSkill Level',
            isCompleted: activeStage > 2,
            isActive: activeStage == 2,
          ),
        ),
        // Connecting line 2-3
        Container(
          width: 32,
          height: 2,
          margin: const EdgeInsets.only(top: 14),
          color: activeStage > 2 ? const Color(0xFF00B96B) : const Color(0xFFE2E8F0),
        ),
        // Stage 3
        Expanded(
          child: _buildStageNode(
            stepNumber: 3,
            label: 'Connecting\nTo Arena',
            isCompleted: false,
            isActive: activeStage == 3,
          ),
        ),
      ],
    );
  }

  Widget _buildStageNode({
    required int stepNumber,
    required String label,
    required bool isCompleted,
    required bool isActive,
  }) {
    Color circleColor;
    Color textColor;
    if (isCompleted || isActive) {
      circleColor = const Color(0xFF00B96B);
      textColor = Colors.white;
    } else {
      circleColor = const Color(0xFFF1F5F9);
      textColor = const Color(0xFF94A3B8);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: const Color(0xFF00B96B), width: 2)
                : null,
            boxShadow: isActive
                ? const [BoxShadow(color: Color(0x3300B96B), blurRadius: 6)]
                : null,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
              : Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? AppColors.battleNavy : const Color(0xFF64748B),
            height: 1.25,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isChip = false,
    bool hasLiveDot = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 2),
              if (isChip)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6F6E5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF008C52),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                )
              else if (hasLiveDot)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.battleNavy,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00B96B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.battleNavy,
                    fontFamily: 'Inter',
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 3 Bottom Feature Cards (1v1 Battle, Fair Match, No Bots) matching Reference Image 3
class MatchmakingDesktopCardsRow extends StatelessWidget {
  const MatchmakingDesktopCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        if (isDesktop) {
          return Row(
            children: [
              Expanded(
                child: _buildCard(
                  icon: Icons.bolt_rounded,
                  iconColor: const Color(0xFF00B96B),
                  iconBg: const Color(0xFFE6FAF0),
                  title: '1v1 Battle',
                  badge: 'Real Players',
                  description: 'Compete with students across India and show your skills.',
                  badgeColor: const Color(0xFF008C52),
                  badgeBg: const Color(0xFFD6F6E5),
                  illustrationIcon: Icons.sports_esports_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildCard(
                  icon: Icons.emoji_events_rounded,
                  iconColor: const Color(0xFFFFB800),
                  iconBg: const Color(0xFFFEF3C7),
                  title: 'Fair Match',
                  badge: 'Similar Skill',
                  description: 'Get matched with players of your skill level for balanced battles.',
                  badgeColor: const Color(0xFFB45309),
                  badgeBg: const Color(0xFFFEF3C7),
                  illustrationIcon: Icons.military_tech_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildCard(
                  icon: Icons.verified_user_rounded,
                  iconColor: const Color(0xFF2587F8),
                  iconBg: const Color(0xFFEFF6FF),
                  title: 'No Bots',
                  badge: '100% Real',
                  description: 'Play with real students only. No bots, no unfair matches.',
                  badgeColor: const Color(0xFF1D4ED8),
                  badgeBg: const Color(0xFFDBEAFE),
                  illustrationIcon: Icons.groups_rounded,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildCard(
                icon: Icons.bolt_rounded,
                iconColor: const Color(0xFF00B96B),
                iconBg: const Color(0xFFE6FAF0),
                title: '1v1 Battle',
                badge: 'Real Players',
                description: 'Compete with students across India and show your skills.',
                badgeColor: const Color(0xFF008C52),
                badgeBg: const Color(0xFFD6F6E5),
                illustrationIcon: Icons.sports_esports_rounded,
              ),
              const SizedBox(height: 10),
              _buildCard(
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFFFFB800),
                iconBg: const Color(0xFFFEF3C7),
                title: 'Fair Match',
                badge: 'Similar Skill',
                description: 'Get matched with players of your skill level for balanced battles.',
                badgeColor: const Color(0xFFB45309),
                badgeBg: const Color(0xFFFEF3C7),
                illustrationIcon: Icons.military_tech_rounded,
              ),
              const SizedBox(height: 10),
              _buildCard(
                icon: Icons.verified_user_rounded,
                iconColor: const Color(0xFF2587F8),
                iconBg: const Color(0xFFEFF6FF),
                title: 'No Bots',
                badge: '100% Real',
                description: 'Play with real students only. No bots, no unfair matches.',
                badgeColor: const Color(0xFF1D4ED8),
                badgeBg: const Color(0xFFDBEAFE),
                illustrationIcon: Icons.groups_rounded,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String badge,
    required String description,
    required Color badgeColor,
    required Color badgeBg,
    required IconData illustrationIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.battleBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A10194F),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Pill
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),

          // Title & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.battleNavy,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: badgeColor,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                    height: 1.3,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Illustration icon on right
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              illustrationIcon,
              color: iconColor.withAlpha(160),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

/// Red Outlined Cancel Button matching Reference Image 3
/// Standardized through Rankearn AppButton and centralized Design System tokens
class MatchmakingCancelButton extends StatelessWidget {
  final VoidCallback? onCancel;

  const MatchmakingCancelButton({super.key, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppButton(
        label: 'Cancel Matchmaking',
        onPressed: onCancel,
        variant: AppButtonVariant.outlined,
        size: AppButtonSize.large,
        height: 48.0,
        width: 250,
        borderRadius: AppRadii.borderPill,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.battleErrorRed,
        borderColor: const Color(0xFFFDA4AF),
        leadingIcon: const Icon(
          Icons.close_rounded,
          color: AppColors.battleErrorRed,
          size: 18,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        customTextStyle: const TextStyle(
          color: AppColors.battleErrorRed,
          fontSize: 14.5,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
