import 'package:flutter/material.dart';

/// UpcomingLiveTestCard matching the exact visual design in the Rankearn reference screenshot:
/// Date Tile on Left | Title, Badges & Questions | Vertical Divider | Starts in Countdown | Notify Me Button on Far Right
class UpcomingLiveTestCard extends StatelessWidget {
  final String day;
  final String month;
  final String title;
  final String typeBadge;
  final Color? typeBadgeColor;
  final int questionsCount;
  final int durationMinutes;
  final String startsIn;
  final bool isNotified;
  final VoidCallback? onToggleNotification;

  const UpcomingLiveTestCard({
    super.key,
    required this.day,
    required this.month,
    required this.title,
    required this.typeBadge,
    this.typeBadgeColor,
    required this.questionsCount,
    required this.durationMinutes,
    required this.startsIn,
    this.isNotified = false,
    this.onToggleNotification,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;

        if (isDesktop) {
          return _buildDesktopLayout();
        }
        return _buildMobileLayout();
      },
    );
  }

  // --- Exact Desktop Layout Matching Attached Screenshot ---
  Widget _buildDesktopLayout() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8EEF8),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06101A3A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Date Tile on the Left (Light Blue Rounded Box)
          _buildDateTile(),
          const SizedBox(width: 16),

          // 2. Middle Content: Title, Badges (LIVE + TYPE), Questions & Duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101A3A),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                _buildBadgesRow(),
                const SizedBox(height: 4),
                _buildMetadataText(),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // 3. Vertical Divider Line
          Container(
            width: 1,
            height: 42,
            color: const Color(0xFFE2E8F0),
          ),
          const SizedBox(width: 20),

          // 4. Starts In Countdown (Starts in / 2h 15m)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Starts in',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5B6B8B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                startsIn,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF101A3A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // 5. Notify Me Action Button on the Far Right
          _buildNotifyButton(),
        ],
      ),
    );
  }

  // --- Mobile Responsive Layout (Stacked cleanly to prevent overflow) ---
  Widget _buildMobileLayout() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8EEF8),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06101A3A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildDateTile(isCompact: true),
              const SizedBox(width: 10),
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
                        color: Color(0xFF101A3A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildBadgesRow(),
                    const SizedBox(height: 3),
                    _buildMetadataText(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Starts in: ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5B6B8B),
                      ),
                    ),
                    Text(
                      startsIn,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF101A3A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                _buildNotifyButton(isCompact: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile({bool isCompact = false}) {
    return Container(
      width: isCompact ? 50 : 58,
      height: isCompact ? 52 : 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: isCompact ? 18 : 20,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF101A3A),
              height: 1.1,
            ),
          ),
          Text(
            month,
            style: TextStyle(
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5B6B8B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesRow() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // LIVE status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.circle, color: Color(0xFFF43F5E), size: 6),
                SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFFF43F5E),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Specific test type pill (SCORE BASED, ALL INDIA, RANK BASED)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              typeBadge,
              style: TextStyle(
                color: typeBadgeColor ?? const Color(0xFF2587F8),
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataText() {
    final prefix = questionsCount >= 100 ? '• ' : '';
    return Text(
      '$prefix$questionsCount Questions  •  $durationMinutes Minutes',
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: Color(0xFF5B6B8B),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildNotifyButton({bool isCompact = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggleNotification,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 20,
            vertical: isCompact ? 7 : 11,
          ),
          decoration: BoxDecoration(
            color: isNotified ? const Color(0xFFECFDF5) : const Color(0xFFF0F6FE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNotified ? Icons.check_circle_rounded : Icons.notifications_none_rounded,
                size: isCompact ? 16 : 20,
                color: isNotified ? const Color(0xFF10B981) : const Color(0xFF2587F8),
              ),
              const SizedBox(width: 8),
              Text(
                isNotified ? 'Notified' : 'Notify Me',
                style: TextStyle(
                  fontSize: isCompact ? 11.5 : 13.5,
                  fontWeight: FontWeight.w800,
                  color: isNotified ? const Color(0xFF10B981) : const Color(0xFF2587F8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
