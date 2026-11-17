import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';

/// Comprehensive Running & Active Tournament Card for Desktop & Mobile
class TournamentCard extends StatelessWidget {
  final TestModel tournament;
  final bool isDesktop;
  final bool isRegistered;
  final VoidCallback onParticipate;
  final VoidCallback onViewDetails;

  const TournamentCard({
    super.key,
    required this.tournament,
    required this.isDesktop,
    required this.isRegistered,
    required this.onParticipate,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final entryFee = tournament.entryFeeCoins;
    final isFree = entryFee == 0;
    final prizePool = tournament.prizePoolInRupees > 0
        ? '₹${tournament.prizePoolInRupees.toInt()}'
        : (tournament.winningRewardCoins > 0
            ? '${tournament.winningRewardCoins} Coins'
            : '₹10,000');

    // Calculate progress percentage and day count
    final now = DateTime.now();
    final start = tournament.startsAt ?? now.subtract(const Duration(days: 4));
    final end = tournament.endsAt ?? now.add(const Duration(days: 6));
    final totalDays = (end.difference(start).inDays).clamp(1, 365);
    final passedDays = (now.difference(start).inDays + 1).clamp(1, totalDays);
    final progress = (passedDays / totalDays).clamp(0.1, 1.0);
    final progressPercent = (progress * 100).round();

    if (isDesktop) {
      return _buildDesktopCard(
        context: context,
        isFree: isFree,
        entryFee: entryFee,
        prizePool: prizePool,
        passedDays: passedDays,
        totalDays: totalDays,
        progress: progress,
        progressPercent: progressPercent,
      );
    }

    return _buildMobileCard(
      context: context,
      isFree: isFree,
      entryFee: entryFee,
      prizePool: prizePool,
      passedDays: passedDays,
      totalDays: totalDays,
      progress: progress,
      progressPercent: progressPercent,
    );
  }

  Widget _buildDesktopCard({
    required BuildContext context,
    required bool isFree,
    required int entryFee,
    required String prizePool,
    required int passedDays,
    required int totalDays,
    required double progress,
    required int progressPercent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 170,
                height: 110,
                child: _buildThumbnail(),
              ),
            ),
            const SizedBox(width: 18),

            // Middle Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Badge & Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444), // red running
                          borderRadius: AppRadii.borderPill,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Running',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (tournament.isLiveContest) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: AppRadii.borderPill,
                          ),
                          child: const Text(
                            'LIVE CONTEST',
                            style: TextStyle(
                              color: AppColors.brandPurple,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),

                  Text(
                    tournament.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Meta Row
                  Row(
                    children: [
                      _buildMetaChip(
                        icon: Icons.calendar_today_rounded,
                        text: tournament.datesFormatted,
                      ),
                      const SizedBox(width: 16),
                      _buildMetaChip(
                        icon: Icons.group_rounded,
                        text: tournament.totalParticipants > 0
                            ? '${tournament.totalParticipants}+'
                            : '12,480+',
                      ),
                      const SizedBox(width: 16),
                      _buildMetaChip(
                        icon: Icons.monetization_on_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        text: isFree ? 'Entry: Free' : 'Entry: ₹$entryFee',
                        textColor: isFree
                            ? const Color(0xFF10B981)
                            : const Color(0xFF0F172A),
                        isBoldText: true,
                      ),
                      const SizedBox(width: 16),
                      _buildMetaChip(
                        icon: Icons.emoji_events_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        text: 'Prize Pool: $prizePool',
                        isBoldText: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Progress Row
                  Row(
                    children: [
                      Text(
                        'Day $passedDays of $totalDays',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$progressPercent%',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Action Buttons (Column)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: onParticipate,
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(
                    isRegistered ? 'Play Quiz' : 'Participate Now',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFF475569),
                  ),
                  label: const Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCard({
    required BuildContext context,
    required bool isFree,
    required int entryFee,
    required String prizePool,
    required int passedDays,
    required int totalDays,
    required double progress,
    required int progressPercent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Square thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 78,
                    height: 78,
                    child: _buildThumbnail(),
                  ),
                ),
                const SizedBox(width: 12),

                // Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: AppRadii.borderPill,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 5, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Running',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tournament.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.monetization_on_rounded,
                                size: 14,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                isFree ? 'Entry: Free' : '₹$entryFee',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: isFree
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.group_rounded,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                tournament.totalParticipants > 0
                                    ? '${tournament.totalParticipants}+'
                                    : '12,480+',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emoji_events_rounded,
                                size: 14,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                prizePool,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dates & Day Tag & Progress
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  tournament.datesFormatted,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: AppRadii.borderPill,
                  ),
                  child: Text(
                    'Day $passedDays of $totalDays',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$progressPercent%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF10B981),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: onParticipate,
                    icon: const Icon(Icons.play_arrow_rounded, size: 17),
                    label: Text(
                      isRegistered ? 'Play' : 'Participate Now',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: onViewDetails,
                    icon: const Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: Color(0xFF475569),
                    ),
                    label: const Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final hasImg = tournament.thumbnailUrl != null &&
        tournament.thumbnailUrl!.trim().isNotEmpty;

    if (hasImg) {
      return Image.network(
        AppFormatters.webSafeImageUrl(tournament.thumbnailUrl!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallbackThumbnail(),
      );
    }

    return _buildFallbackThumbnail();
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.emoji_events_rounded,
              size: 60,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFFBBF24),
                  size: 26,
                ),
                const SizedBox(height: 4),
                Text(
                  tournament.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    Color? iconColor,
    required String text,
    Color? textColor,
    bool isBoldText = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: iconColor ?? const Color(0xFF64748B),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBoldText ? FontWeight.w800 : FontWeight.w600,
            color: textColor ?? const Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}
