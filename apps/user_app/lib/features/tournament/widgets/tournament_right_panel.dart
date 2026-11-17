import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import 'upcoming_tournament_card.dart';

/// Desktop Right-side Information Panel Tokenized with Centralized Design System
class TournamentRightPanel extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboardUsers;
  final TestModel? upcomingTournament;
  final int streakDays;
  final int completedToday;
  final VoidCallback onViewAllRankers;

  const TournamentRightPanel({
    super.key,
    required this.leaderboardUsers,
    required this.upcomingTournament,
    required this.streakDays,
    required this.completedToday,
    required this.onViewAllRankers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Today's Goal Card
        _buildTodaysGoalCard(),
        const SizedBox(height: AppSpacing.contestItemGap),

        // 2. Daily Streak Card
        _buildDailyStreakCard(),
        const SizedBox(height: AppSpacing.contestItemGap),

        // 3. Top Contest Rankers Card
        _buildTopRankersCard(context),
        const SizedBox(height: AppSpacing.contestItemGap),

        // 4. Upcoming Contest Card
        if (upcomingTournament != null) ...[
          _buildUpcomingSection(),
        ],
      ],
    );
  }

  Widget _buildTodaysGoalCard() {
    final progress = (completedToday / 5).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.contestCardBg,
        borderRadius: AppRadii.contestCard,
        border: Border.all(color: AppColors.contestCardBorder),
        boxShadow: AppShadows.contestCard,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.flag_rounded,
                  color: AppColors.contestBlue,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  "Today's Goal",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.contestTextPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4), // soft green tint
                borderRadius: AppRadii.contestThumb,
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.track_changes_rounded,
                      color: AppColors.contestBadgeRed,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Today's Goal",
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            Text(
                              '$completedToday/5 Contests',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.contestTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete 5 contests today to earn 50 coins!',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.contestTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStreakCard() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final activeCount = streakDays.clamp(1, 7);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.contestCardBg,
        borderRadius: AppRadii.contestCard,
        border: Border.all(color: AppColors.contestCardBorder),
        boxShadow: AppShadows.contestCard,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF7ED),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFFF97316),
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Streak',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.contestTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '$streakDays Days',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.contestTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(days.length, (index) {
                final isCompleted = index < activeCount;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.contestActiveGreen
                            : AppColors.contestWatermark,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRankersCard(BuildContext context) {
    final top5 = leaderboardUsers.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.contestCardBg,
        borderRadius: AppRadii.contestCard,
        border: Border.all(color: AppColors.contestCardBorder),
        boxShadow: AppShadows.contestCard,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.military_tech_rounded,
                  color: AppColors.contestCoinAmber,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Top Contest Rankers',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.contestTextPrimary,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: onViewAllRankers,
                  child: const Text(
                    'View All >',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.contestBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (top5.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'No rankers yet. Be the first!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: top5.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = top5[index];
                  final rank = index + 1;
                  final name = (user['name'] ?? user['email'] ?? 'Aspirant')
                      .toString();
                  final coins = (user['coins'] as num?)?.toInt() ?? 0;

                  return Row(
                    children: [
                      // Rank Indicator
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _getRankBadgeColor(rank),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          rank.toString(),
                          style: TextStyle(
                            color: rank <= 3 ? Colors.white : const Color(0xFF475569),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Avatar
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: _getAvatarBg(index),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Name
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),

                      // Coins
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.monetization_on_rounded,
                            size: 14,
                            color: AppColors.contestCoinAmber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            coins.toString(),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.contestTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: AppColors.contestPurple,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Upcoming Contest',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.contestTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        UpcomingTournamentCard(
          tournament: upcomingTournament!,
          isDesktop: true,
        ),
      ],
    );
  }

  Color _getRankBadgeColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.contestCoinAmber;
      case 2:
        return AppColors.contestPurple;
      case 3:
        return AppColors.contestBronze;
      default:
        return AppColors.contestWatermark;
    }
  }

  Color _getAvatarBg(int index) {
    const colors = [
      AppColors.contestBlue,
      Color(0xFFEC4899),
      Color(0xFFF97316),
      AppColors.contestActiveGreen,
      AppColors.contestPurple,
    ];
    return colors[index % colors.length];
  }
}
