import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/leaderboard_model.dart';

/// Mobile Ranked User List Component matching Reference Image 2
/// Displays ranked candidates from Rank 4 downward in a compact card list
/// with column headers [#] [User] [Level] [Win Rate] [Coins]
/// and highlighted row for the current authenticated user.
/// Strictly adhering to the Rankearn centralized design system.
class LeaderboardMobileList extends StatelessWidget {
  final List<LeaderboardUserEntry> entries;
  final bool isLoading;
  final Widget? filterTabs;
  final void Function(LeaderboardUserEntry user)? onUserTap;

  const LeaderboardMobileList({
    super.key,
    required this.entries,
    this.isLoading = false,
    this.filterTabs,
    this.onUserTap,
  });

  String _formatCoins(int amount) {
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
    // Only show ranks 4+ in the list below the podium
    final listEntries = entries.where((e) => e.rank >= 4).toList();

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
            // Top Section: Filter Tabs (Inside the Mobile User List Card)
            if (filterTabs != null) ...[
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: filterTabs!,
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.leaderboardBorder,
              ),
            ],

            // List Header Row
            _buildListHeader(),

            // User Rows or Loading Indicator
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
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
                itemCount: listEntries.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 0.8,
                  color: AppColors.leaderboardSlate100,
                ),
                itemBuilder: (context, index) {
                  final entry = listEntries[index];
                  return _buildUserRow(entry);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.leaderboardSlate50,
        border: Border(
          bottom: BorderSide(color: AppColors.leaderboardBorder, width: 1),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#',
              style: TextStyle(
                color: AppColors.leaderboardMuted,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                fontFamilyFallback: AppTypography.fontFallbacks,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              'User',
              style: TextStyle(
                color: AppColors.leaderboardMuted,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                fontFamilyFallback: AppTypography.fontFallbacks,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                'Level',
                style: TextStyle(
                  color: AppColors.leaderboardMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  fontFamilyFallback: AppTypography.fontFallbacks,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                'Win Rate',
                style: TextStyle(
                  color: AppColors.leaderboardMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  fontFamilyFallback: AppTypography.fontFallbacks,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Coins',
                style: TextStyle(
                  color: AppColors.leaderboardMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  fontFamilyFallback: AppTypography.fontFallbacks,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(LeaderboardUserEntry entry) {
    final isCurrentUser = entry.isCurrentUser;

    return InkWell(
      onTap: () => onUserTap?.call(entry),
      child: Container(
        color: isCurrentUser ? AppColors.leaderboardMintBg : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            // 1. Rank Number
            SizedBox(
              width: 28,
              child: Text(
                '${entry.rank}',
                style: TextStyle(
                  color: isCurrentUser
                      ? AppColors.leaderboardGreenDark
                      : AppColors.leaderboardSlate800,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  fontFamilyFallback: AppTypography.fontFallbacks,
                ),
              ),
            ),

            // 2. Avatar + Name + State + You Badge
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: entry.avatarBgColor,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.leaderboardNavy,
                      size: 20,
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
                                  color: AppColors.leaderboardDarkSlate,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  fontFamilyFallback:
                                      AppTypography.fontFallbacks,
                                ),
                              ),
                            ),
                            if (isCurrentUser) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.leaderboardGreen,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  'You',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    fontFamilyFallback:
                                        AppTypography.fontFallbacks,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          entry.state,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.leaderboardMuted,
                            fontSize: 10,
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

            // 3. Level Badge Pill
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.leaderboardMintBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Lv. ${entry.level}',
                    style: const TextStyle(
                      color: AppColors.leaderboardGreenDark,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      fontFamilyFallback: AppTypography.fontFallbacks,
                    ),
                  ),
                ),
              ),
            ),

            // 4. Win Rate
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  '${entry.winRate}%',
                  style: const TextStyle(
                    color: AppColors.leaderboardGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    fontFamilyFallback: AppTypography.fontFallbacks,
                  ),
                ),
              ),
            ),

            // 5. Coins Earned
            Expanded(
              flex: 3,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.leaderboardGold,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.monetization_on_rounded,
                        color: AppColors.leaderboardGoldDark,
                        size: 10,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _formatCoins(entry.coinsEarned),
                      style: const TextStyle(
                        color: AppColors.leaderboardDarkSlate,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        fontFamilyFallback: AppTypography.fontFallbacks,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
