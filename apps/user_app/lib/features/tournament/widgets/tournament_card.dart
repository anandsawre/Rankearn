import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';

/// Responsive Tournament Card:
/// - Desktop: Original horizontal layout with left thumbnail, middle metadata, and right action buttons.
/// - Mobile: Redesigned based on reference design (media_1794906325104_8041b3e2.jpg).
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
        ? '₹${tournament.prizePoolInRupees.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
        : (tournament.winningRewardCoins > 0
            ? '${tournament.winningRewardCoins} Coins'
            : (tournament.entryFeeCoins > 0 ? '₹${tournament.entryFeeCoins * 10}' : 'Rewards Pool'));

    // Real date & progress calculation without fake date subtraction
    final now = DateTime.now();
    final start = tournament.startsAt;
    final end = tournament.endsAt;
    final int totalDays;
    final int passedDays;
    final double progress;

    if (start != null && end != null) {
      totalDays = (end.difference(start).inDays + 1).clamp(1, 365);
      passedDays = (now.difference(start).inDays + 1).clamp(1, totalDays);
      progress = (passedDays / totalDays).clamp(0.0, 1.0);
    } else if (start != null) {
      totalDays = 1;
      passedDays = now.isAfter(start) ? 1 : 0;
      progress = passedDays.toDouble();
    } else {
      totalDays = 1;
      passedDays = 1;
      progress = 1.0;
    }
    final progressPercent = (progress * 100).round();

    // Desktop view: Original desktop layout preserved
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

    // Mobile view: Newly redesigned layout
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

  // ==========================================
  // DESKTOP LAYOUT (PRESERVED AS IT WAS)
  // ==========================================
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
        color: AppColors.contestCardBg,
        borderRadius: AppRadii.contestCard,
        border: Border.all(color: AppColors.contestCardBorder),
        boxShadow: AppShadows.contestCard,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Thumbnail
            ClipRRect(
              borderRadius: AppRadii.contestThumb,
              child: SizedBox(
                width: 170,
                height: 110,
                child: _buildThumbnail(),
              ),
            ),
            const SizedBox(width: AppSpacing.lg + 2),

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
                          color: tournament.isLive
                              ? AppColors.contestBadgeRed
                              : (tournament.isUpcoming
                                  ? const Color(0xFF7C3AED)
                                  : const Color(0xFF64748B)),
                          borderRadius: AppRadii.borderPill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tournament.isLive
                                  ? Icons.circle
                                  : (tournament.isUpcoming
                                      ? Icons.calendar_today_rounded
                                      : Icons.check_circle_outline_rounded),
                              size: 7,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tournament.isLive
                                  ? 'Running'
                                  : (tournament.isUpcoming
                                      ? 'Upcoming'
                                      : 'Completed'),
                              style: const TextStyle(
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
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEF2FF),
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
                    style: AppTypography.contestCardTitle,
                  ),
                  const SizedBox(height: 8),

                  // Meta Row
                  Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildMetaChip(
                        icon: Icons.calendar_today_rounded,
                        text: tournament.datesFormatted,
                      ),
                      _buildMetaChip(
                        icon: Icons.group_rounded,
                        text: '${tournament.totalParticipants} Participants',
                      ),
                      _buildMetaChip(
                        icon: Icons.monetization_on_rounded,
                        iconColor: AppColors.contestCoinAmber,
                        text: isFree ? 'Entry: Free' : 'Entry: ₹$entryFee',
                        textColor: isFree
                            ? AppColors.contestActiveGreen
                            : AppColors.contestTextPrimary,
                        isBoldText: true,
                      ),
                      _buildMetaChip(
                        icon: Icons.emoji_events_rounded,
                        iconColor: AppColors.contestCoinAmber,
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
                          color: AppColors.contestTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: AppColors.contestCardBorder,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.contestActiveGreen,
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
                          color: AppColors.contestTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xl),

            // Action Buttons (Column)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: onParticipate,
                  icon: Icon(
                    tournament.isPast
                        ? Icons.leaderboard_rounded
                        : (tournament.isUpcoming
                            ? (isRegistered ? Icons.check_circle_outline_rounded : Icons.calendar_today_rounded)
                            : Icons.play_arrow_rounded),
                    size: 18,
                  ),
                  label: Text(
                    tournament.isPast
                        ? 'View Results'
                        : (tournament.isUpcoming
                            ? (isRegistered ? 'Registered' : 'Register Now')
                            : (isRegistered ? 'Play Quiz' : 'Participate Now')),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.contestActiveGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.contestThumbSm,
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
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.contestThumbSm,
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

  // ==========================================
  // MOBILE LAYOUT (REDESIGNED)
  // ==========================================
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
    final datesText = tournament.datesFormatted.isNotEmpty
        ? tournament.datesFormatted
        : 'Live Today';

    final participantsCount = '${tournament.totalParticipants}';

    final subtitle = (tournament.syllabus != null && tournament.syllabus!.isNotEmpty)
        ? tournament.syllabus!
        : 'Compete • Live Ranking • Rewards';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEDE9FE),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B21A8).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Section: Title & Right-aligned Animated Live Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tournament.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _buildStatusBadge(),
            ],
          ),

          const SizedBox(height: 12),

          // 2. 3-Column Metadata Pod (Calendar, Participants, Total Rewards)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // 1. Calendar
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: Color(0xFF7C3AED),
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          datesText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical Divider 1
                Container(
                  width: 1,
                  height: 24,
                  color: const Color(0xFFE2E8F0),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                ),

                // 2. Participants
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.people_alt_rounded,
                        color: Color(0xFF7C3AED),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              participantsCount,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const Text(
                              'Participants',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical Divider 2
                Container(
                  width: 1,
                  height: 24,
                  color: const Color(0xFFE2E8F0),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                ),

                // 3. Total Rewards
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.card_giftcard_rounded,
                        color: Color(0xFFF43F5E),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              prizePool,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const Text(
                              'Total Rewards',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. Progress Bar Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Day $passedDays of $totalDays',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
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
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 4. Four Benefit Pods Row
          Row(
            children: [
              _buildMobileBenefitPod(
                icon: Icons.track_changes_rounded,
                label: 'Daily\nQuiz',
                bgColor: const Color(0xFFEFF6FF),
                borderColor: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF0284C7),
              ),
              const SizedBox(width: 6),
              _buildMobileBenefitPod(
                icon: Icons.bar_chart_rounded,
                label: 'Live\nLeaderboard',
                bgColor: const Color(0xFFFEFCE8),
                borderColor: const Color(0xFFFEF08A),
                iconColor: const Color(0xFFD97706),
              ),
              const SizedBox(width: 6),
              _buildMobileBenefitPod(
                icon: Icons.card_giftcard_rounded,
                label: 'Exciting\nRewards',
                bgColor: const Color(0xFFFFF1F2),
                borderColor: const Color(0xFFFECDD3),
                iconColor: const Color(0xFFE11D48),
              ),
              const SizedBox(width: 6),
              _buildMobileBenefitPod(
                icon: Icons.workspace_premium_rounded,
                label: 'E-Certificate\nfor Rankers',
                bgColor: const Color(0xFFFAF5FF),
                borderColor: const Color(0xFFE9D5FF),
                iconColor: const Color(0xFF7C3AED),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 5. Action Buttons Row
          Row(
            children: [
              // Participate Now Button
              Expanded(
                flex: 5,
                child: InkWell(
                  onTap: onParticipate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            tournament.isPast
                                ? Icons.leaderboard_rounded
                                : (tournament.isUpcoming
                                    ? (isRegistered ? Icons.check_circle_outline_rounded : Icons.calendar_today_rounded)
                                    : Icons.play_arrow_rounded),
                            color: const Color(0xFF7C3AED),
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            tournament.isPast
                                ? 'View Results'
                                : (tournament.isUpcoming
                                    ? (isRegistered ? 'Registered' : 'Register Now')
                                    : (isRegistered ? 'Play Quiz' : 'Participate Now')),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // View Details Button
              Expanded(
                flex: 4,
                child: InkWell(
                  onTap: onViewDetails,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFC7D2FE),
                        width: 1.2,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF4338CA),
                          size: 15,
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'View Details',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF4338CA),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBenefitPod({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers for Desktop Thumbnail & Metadata ---
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
                  color: AppColors.contestGold,
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
          color: iconColor ?? AppColors.contestTextSecondary,
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

  Widget _buildStatusBadge() {
    if (tournament.isLive) {
      return _buildLiveBadge();
    } else if (tournament.isUpcoming) {
      return _buildUpcomingBadge();
    } else if (tournament.isPast) {
      return _buildCompletedBadge();
    }
    return _buildLiveBadge();
  }

  Widget _buildUpcomingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED), // Royal Purple
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.2,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 10, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'UPCOMING',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFF64748B), // Slate Grey
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.2,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 10, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'ENDED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626), // Vibrant Crimson Red
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.2,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _LiveWaveDot(),
          SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated pulsing ripple dot for the LIVE badge
class _LiveWaveDot extends StatefulWidget {
  const _LiveWaveDot();

  @override
  State<_LiveWaveDot> createState() => _LiveWaveDotState();
}

class _LiveWaveDotState extends State<_LiveWaveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        return SizedBox(
          width: 14,
          height: 14,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1.0 - val).clamp(0.0, 1.0),
                child: Container(
                  width: 6.0 + (val * 8.0),
                  height: 6.0 + (val * 8.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
