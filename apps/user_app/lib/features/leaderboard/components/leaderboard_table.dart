import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/leaderboard_model.dart';

/// Desktop 7-Column Leaderboard Rankings Table matching Reference Image 1
/// Columns: [#] [User] [Level] [Tests] [Win Rate] [Coins Earned] [Badge]
/// Strictly built with the Rankearn centralized design system.
class LeaderboardTable extends StatelessWidget {
  final List<LeaderboardUserEntry> entries;
  final bool isLoading;
  final Widget? filterTabs;
  final void Function(LeaderboardUserEntry user)? onUserTap;

  const LeaderboardTable({
    super.key,
    required this.entries,
    this.isLoading = false,
    this.filterTabs,
    this.onUserTap,
  });

  String _formatNumber(int amount) {
    if (amount >= 1000) {
      final s = amount.toString();
      final lastThree = s.substring(s.length - 3);
      final otherNumbers = s.substring(0, s.length - 3);
      return otherNumbers.isNotEmpty ? '$otherNumbers,$lastThree' : lastThree;
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.leaderboardBorder, width: 1.2),
        boxShadow: AppShadows.leaderboardCard,
      ),
      child: ClipRRect(
        borderRadius: AppRadii.borderLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section: Filter Tabs (Inside the User List Card)
            if (filterTabs != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: filterTabs!,
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.leaderboardBorder,
              ),
            ],

            // Table Header Row
            _buildTableHeader(),

            // Table Body or Loading Indicator
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.huge),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.leaderboardGreen,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.leaderboardSlate100,
                ),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return _buildTableRow(entry);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Table Header Row
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.leaderboardSlate50,
        border: Border(
          bottom: BorderSide(color: AppColors.leaderboardBorder, width: 1),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              '#',
              style: TextStyle(
                color: AppColors.leaderboardMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamilyFallback: AppTypography.fontFallbacks,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              'User',
              style: TextStyle(
                color: AppColors.leaderboardMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamilyFallback: AppTypography.fontFallbacks,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Level',
              style: TextStyle(
                color: AppColors.leaderboardMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamilyFallback: AppTypography.fontFallbacks,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Tests',
              style: TextStyle(
                color: AppColors.leaderboardMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamilyFallback: AppTypography.fontFallbacks,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Win Rate',
              style: TextStyle(
                color: AppColors.leaderboardMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamilyFallback: AppTypography.fontFallbacks,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'Coins Earned',
              style: TextStyle(
                color: AppColors.leaderboardMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamilyFallback: AppTypography.fontFallbacks,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Badge',
              style: TextStyle(
                color: AppColors.leaderboardMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamilyFallback: AppTypography.fontFallbacks,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Individual User Row
  Widget _buildTableRow(LeaderboardUserEntry entry) {
    final isCurrentUser = entry.isCurrentUser;

    return InkWell(
      onTap: () => onUserTap?.call(entry),
      child: Container(
        color: isCurrentUser ? AppColors.leaderboardMintBg : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // 1. Rank / Medal
            SizedBox(width: 44, child: _buildRankBadge(entry.rank)),

            // 2. User Avatar + Name + State + Verified / You Badge
            Expanded(
              flex: 6,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: entry.avatarBgColor,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.leaderboardNavy,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                entry.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.leaderboardNavy,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  fontFamilyFallback:
                                      AppTypography.fontFallbacks,
                                ),
                              ),
                            ),
                            if (entry.isVerified) ...[
                              const SizedBox(width: AppSpacing.xs),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.leaderboardSky600,
                                size: 14,
                              ),
                            ],
                            if (isCurrentUser) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.leaderboardGreen,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'You',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    fontFamilyFallback:
                                        AppTypography.fontFallbacks,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.state,
                          style: const TextStyle(
                            color: AppColors.leaderboardMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamilyFallback: AppTypography.fontFallbacks,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Level Pill
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.leaderboardMintBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Lv. ${entry.level}',
                    style: const TextStyle(
                      color: AppColors.leaderboardGreenDark,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      fontFamilyFallback: AppTypography.fontFallbacks,
                    ),
                  ),
                ),
              ),
            ),

            // 4. Tests Completed
            Expanded(
              flex: 3,
              child: Text(
                _formatNumber(entry.testsCompleted),
                style: const TextStyle(
                  color: AppColors.leaderboardSlate700,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamilyFallback: AppTypography.fontFallbacks,
                ),
              ),
            ),

            // 5. Win Rate
            Expanded(
              flex: 3,
              child: Text(
                '${entry.winRate}%',
                style: const TextStyle(
                  color: AppColors.leaderboardGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  fontFamilyFallback: AppTypography.fontFallbacks,
                ),
              ),
            ),

            // 6. Coins Earned
            Expanded(
              flex: 4,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.leaderboardGold,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.monetization_on_rounded,
                        color: AppColors.leaderboardGoldDark,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatNumber(entry.coinsEarned),
                      style: const TextStyle(
                        color: AppColors.leaderboardDarkSlate,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        fontFamilyFallback: AppTypography.fontFallbacks,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 7. Achievement Badge
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: entry.badgeBgColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: entry.badgeColor.withAlpha(80),
                      width: 0.8,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          entry.badgeIcon,
                          color: entry.badgeColor,
                          size: 13,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          entry.badgeLabel,
                          style: TextStyle(
                            color: entry.badgeColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            fontFamilyFallback: AppTypography.fontFallbacks,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Medal icon for Top 3 or plain number for ranks 4+
  Widget _buildRankBadge(int rank) {
    if (rank == 1) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.leaderboardGold,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          '1',
          style: TextStyle(
            color: AppColors.leaderboardOrange900,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            fontFamilyFallback: AppTypography.fontFallbacks,
          ),
        ),
      );
    }
    if (rank == 2) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.leaderboardSilver,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          '2',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            fontFamilyFallback: AppTypography.fontFallbacks,
          ),
        ),
      );
    }
    if (rank == 3) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.leaderboardBronze,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          '3',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            fontFamilyFallback: AppTypography.fontFallbacks,
          ),
        ),
      );
    }
    return Text(
      '$rank',
      style: const TextStyle(
        color: AppColors.leaderboardSlate800,
        fontWeight: FontWeight.w700,
        fontSize: 13,
        fontFamilyFallback: AppTypography.fontFallbacks,
      ),
    );
  }
}
