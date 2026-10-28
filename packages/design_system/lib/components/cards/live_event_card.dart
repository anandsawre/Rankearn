import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

enum LiveEventActionType { joinNow, notifyMe, register }

/// Reusable LiveEventCard for Upcoming Live Tests and Tournaments
class LiveEventCard extends StatelessWidget {
  final String title;
  final String dateTime;
  final String questionCount;
  final Widget icon;
  final bool isLive;
  final LiveEventActionType actionType;
  final VoidCallback onAction;

  final Color? accentColor;

  const LiveEventCard({
    super.key,
    required this.title,
    required this.dateTime,
    required this.questionCount,
    required this.icon,
    this.isLive = false,
    required this.actionType,
    required this.onAction,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ??
        (isLive ? const Color(0xFFF43F5E) : const Color(0xFF2587F8));

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(effectiveAccent.withAlpha(18), Colors.white),
            Colors.white,
          ],
        ),
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: effectiveAccent.withAlpha(45), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: effectiveAccent.withAlpha(14),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          const BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadii.borderLg,
        child: Stack(
          children: [
            // 1. Soft Halo Glow in Top Right
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: effectiveAccent.withAlpha(18),
                ),
              ),
            ),

            // 2. Concentric Arc Ring
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: effectiveAccent.withAlpha(16),
                    width: 1.0,
                  ),
                ),
              ),
            ),

            // 3. Faint Watermark Icon
            Positioned(
              right: 8,
              bottom: 34,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: -0.12,
                  child: Icon(
                    isLive ? Icons.calendar_month_rounded : Icons.emoji_events_rounded,
                    size: 52,
                    color: effectiveAccent.withAlpha(20),
                  ),
                ),
              ),
            ),

            // 4. Foreground Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      icon,
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLive) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE4E6),
                                  borderRadius: AppRadii.borderPill,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.circle,
                                      color: Color(0xFFE11D48),
                                      size: 5,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: Color(0xFFE11D48),
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateTime,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              questionCount,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildActionButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    switch (actionType) {
      case LiveEventActionType.joinNow:
        return SizedBox(
          width: double.infinity,
          height: 32,
          child: ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFE4E6),
              foregroundColor: const Color(0xFFE11D48),
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.borderPill),
            ),
            child: const Text(
              'Join Now',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        );
      case LiveEventActionType.notifyMe:
        return SizedBox(
          width: double.infinity,
          height: 32,
          child: ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.notifications_none_rounded, size: 14),
            label: const Text(
              'Notify Me',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEFF6FF),
              foregroundColor: const Color(0xFF2587F8),
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.borderPill),
            ),
          ),
        );
      case LiveEventActionType.register:
        return SizedBox(
          width: double.infinity,
          height: 32,
          child: ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3E8FF),
              foregroundColor: const Color(0xFF7C3AED),
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.borderPill),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Register',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14),
              ],
            ),
          ),
        );
    }
  }
}
