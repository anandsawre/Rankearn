import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';

/// Upcoming Contest Card Tokenized with Centralized Design System
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
        color: AppColors.contestUpcomingBg,
        borderRadius: AppRadii.contestShortcut,
        border: Border.all(color: AppColors.contestUpcomingBorder),
      ),
      child: Row(
        children: [
          // Left Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.contestPurple,
              borderRadius: AppRadii.contestThumbSm,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

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
                    color: AppColors.contestTextPrimary,
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
                    color: AppColors.contestTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      size: 13,
                      color: AppColors.contestCoinAmber,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      isFree ? 'Free' : '₹$entryFee',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isFree
                            ? AppColors.contestActiveGreen
                            : AppColors.contestTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 13,
                      color: AppColors.contestCoinAmber,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      prizePool,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.contestTextPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

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
            borderRadius: AppRadii.contestThumbSm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: _isReminded
                    ? AppColors.contestPurple
                    : AppColors.contestUpcomingBg,
                borderRadius: AppRadii.contestThumbSm,
                border: Border.all(
                  color: AppColors.contestPurple,
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
                    color: _isReminded ? Colors.white : AppColors.contestPurple,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isReminded ? 'Reminded' : 'Remind Me',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _isReminded ? Colors.white : AppColors.contestPurple,
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
