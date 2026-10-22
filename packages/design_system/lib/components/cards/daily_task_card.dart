import 'package:flutter/material.dart';
import '../../tokens/radii.dart';

enum DailyTaskActionType {
  goNow,
  progressPill,
  claim,
  completed,
}

/// Single Daily Task Card for the Rewards Tab matching the reference UI.
class DailyTaskCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String description;
  final int coinsReward;
  final DailyTaskActionType actionType;
  final String progressText;
  final VoidCallback? onAction;

  const DailyTaskCard({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.coinsReward,
    this.actionType = DailyTaskActionType.goNow,
    this.progressText = '0/1',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isVeryCompact = constraints.maxWidth < 360;

          if (isVeryCompact) {
            // Stacked layout for ultra-compact widths
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildIcon(),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextContent()),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCoinBadge(),
                    _buildActionButton(),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              // 1. Task Icon Container
              _buildIcon(),
              const SizedBox(width: 14),

              // 2. Title & Subtitle
              Expanded(
                child: _buildTextContent(),
              ),
              const SizedBox(width: 12),

              // 3. Coin Reward Pill
              _buildCoinBadge(),
              const SizedBox(width: 16),

              // 4. Action Button / Status Pill
              _buildActionButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: iconBgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: iconBgColor.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111A4B),
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCoinBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFFC928),
          ),
          child: const Center(
            child: Icon(
              Icons.monetization_on_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '+$coinsReward',
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111A4B),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (actionType == DailyTaskActionType.goNow) {
      return Material(
        color: const Color(0xFF00B96B), // Reference emerald green
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            constraints: const BoxConstraints(minWidth: 84),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Go Now',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 3),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (actionType == DailyTaskActionType.claim) {
      return Material(
        color: const Color(0xFFFFC928),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            constraints: const BoxConstraints(minWidth: 84),
            child: const Center(
              child: Text(
                'Claim',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111A4B),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Default: Progress Pill (e.g., '0/1')
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      constraints: const BoxConstraints(minWidth: 84),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Center(
        child: Text(
          progressText,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
