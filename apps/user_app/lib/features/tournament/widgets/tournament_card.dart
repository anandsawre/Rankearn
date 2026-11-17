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
            : '₹10,000');

    // Calculate dates & progress percentage
    final now = DateTime.now();
    final start = tournament.startsAt ?? now.subtract(const Duration(days: 4));
    final end = tournament.endsAt ?? now.add(const Duration(days: 5));
    final totalDays = (end.difference(start).inDays).clamp(1, 365);
    final passedDays = (now.difference(start).inDays + 1).clamp(1, totalDays);
    final progress = (passedDays / totalDays).clamp(0.05, 1.0);
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
                        decoration: const BoxDecoration(
                          color: AppColors.contestBadgeRed,
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
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEF2FF),
                            borderRadius: AppRadii.borderPill,
                          ),
                          child: const Text(
                            'LIVE TOURNAMENT',
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
                        text: tournament.totalParticipants > 0
                            ? '${tournament.totalParticipants}+'
                            : '12,480+',
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
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(
                    isRegistered ? 'Play Quiz' : 'Participate Now',
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
        : '10 – 20 Nov';

    final participantsCount = tournament.totalParticipants > 0
        ? '${tournament.totalParticipants}+'
        : '12,480+';

    final subtitle = (tournament.syllabus != null && tournament.syllabus!.isNotEmpty)
        ? tournament.syllabus!
        : 'Test Your Preparation • Compete • Win Rewards';

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
          // 1. Top Section: Header & Curved Trophy Illustration
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges Row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Running Tournament Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                size: 13,
                                color: Color(0xFF7C3AED),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Running Tournament',
                                style: TextStyle(
                                  color: Color(0xFF6D28D9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Live Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
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
                              const Text(
                                'Live',
                                style: TextStyle(
                                  color: Color(0xFF15803D),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title
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

                    // Subtitle
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

              // Curved Purple Wave with Trophy Graphic
              Container(
                width: 78,
                height: 64,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(28),
                    topLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFDE047).withValues(alpha: 0.45),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/daily_tasks_trophy.png',
                      width: 42,
                      height: 42,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFFDE047),
                        size: 34,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // 2. 3-Column Metadata Row (Calendar, Participants, Total Rewards)
          Row(
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
                label: 'Daily Quiz',
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
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Color(0xFF7C3AED),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isRegistered ? 'Play Quiz' : 'Participate Now',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 16,
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
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                height: 1.15,
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
}
