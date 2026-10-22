import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../buttons/app_button.dart';

/// LiveTestCard for the "Live Now" horizontal carousel in the Live Tests Tab
class LiveTestCard extends StatelessWidget {
  final String title;
  final String subject;
  final int questionsCount;
  final int durationMinutes;
  final String participants;
  final int coinsReward;
  final Widget? thumbnail;
  final Color? thumbnailBgColor;
  final IconData thumbnailIcon;
  final String? thumbnailBadgeText;
  final VoidCallback? onJoin;

  const LiveTestCard({
    super.key,
    required this.title,
    required this.subject,
    required this.questionsCount,
    required this.durationMinutes,
    required this.participants,
    required this.coinsReward,
    this.thumbnail,
    this.thumbnailBgColor,
    this.thumbnailIcon = Icons.sensors_rounded,
    this.thumbnailBadgeText,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Thumbnail Header with Badges
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail Box
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: thumbnailBgColor ?? const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                    gradient: thumbnailBgColor == null
                        ? const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: thumbnail ??
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            thumbnailIcon,
                            color: Colors.white,
                            size: 34,
                          ),
                          if (thumbnailBadgeText != null)
                            Positioned(
                              bottom: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(140),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  thumbnailBadgeText!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                ),
                const SizedBox(width: 10),

                // Badges Column: LIVE + Participants
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // LIVE pill badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF43F5E),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 11),
                                SizedBox(width: 2),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Participants badge on Right Top Corner
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.people_alt_rounded, color: Color(0xFF64748B), size: 10),
                                    const SizedBox(width: 3),
                                    Text(
                                      participants,
                                      style: const TextStyle(
                                        color: Color(0xFF475569),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Test Title
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),

                      // Subject & Questions
                      Text(
                        '$subject • $questionsCount Questions',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 2. Compact Meta Row: Duration • Participants • Coins
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetaItem(
                    icon: Icons.access_time_rounded,
                    label: '$durationMinutes min',
                  ),
                  const SizedBox(width: 8),
                  _buildMetaItem(
                    icon: Icons.people_outline_rounded,
                    label: participants,
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFB800),
                        ),
                        child: const Center(
                          child: Text(
                            '₹',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$coinsReward',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Full-width Join Now Button
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 4),
            child: AppButton(
              label: 'Join Now',
              size: AppButtonSize.medium,
              trailingIcon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15),
              backgroundColor: AppColors.brandGreen,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(10),
              fullWidth: true,
              onPressed: onJoin,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 13),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
