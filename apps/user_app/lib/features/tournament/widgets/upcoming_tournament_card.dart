import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';

/// Upcoming Tournament Card with Remind Me CTA
class UpcomingTournamentCard extends StatefulWidget {
  final TestModel tournament;
  final bool isDesktop;
  final VoidCallback? onRemindMe;

  const UpcomingTournamentCard({
    super.key,
    required this.tournament,
    required this.isDesktop,
    this.onRemindMe,
  });

  @override
  State<UpcomingTournamentCard> createState() => _UpcomingTournamentCardState();
}

class _UpcomingTournamentCardState extends State<UpcomingTournamentCard> {
  bool _isReminded = false;

  @override
  Widget build(BuildContext context) {
    final entryFee = widget.tournament.entryFeeCoins;
    final isFree = entryFee == 0;
    final prizePool = widget.tournament.prizePoolInRupees > 0
        ? '₹${widget.tournament.prizePoolInRupees.toInt()}'
        : (widget.tournament.winningRewardCoins > 0
            ? '${widget.tournament.winningRewardCoins} Coins'
            : '₹5,000');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8FF), // Soft purple tint
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Row(
        children: [
          // Left Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Center Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.tournament.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.tournament.startsAt != null
                      ? 'Starts on ${widget.tournament.datesFormatted} • 10:00 AM'
                      : 'Starts on 25 Nov • 10:00 AM',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      size: 13,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      isFree ? 'Free' : '₹$entryFee',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isFree
                            ? const Color(0xFF10B981)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 13,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      prizePool,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right Remind Me Button
          InkWell(
            onTap: () {
              setState(() => _isReminded = !_isReminded);
              widget.onRemindMe?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isReminded
                        ? '🔔 Reminder set for ${widget.tournament.title}!'
                        : 'Reminder cancelled.',
                  ),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.brandPurple,
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: _isReminded
                    ? const Color(0xFF8B5CF6)
                    : const Color(0xFFFAF5FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF8B5CF6),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isReminded
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    size: 15,
                    color: _isReminded ? Colors.white : const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isReminded ? 'Reminded' : 'Remind Me',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _isReminded ? Colors.white : const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
