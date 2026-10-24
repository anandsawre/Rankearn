import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/leaderboard_model.dart';

/// Desktop Leaderboard Right Sidebar Component matching Reference Image 1
/// Contains:
/// 1. [Your Rank] Card with candidate avatar, level, tests, win rate & coins chips
/// 2. [Top 3 This Week] Card with weekly podium performers & View All
/// 3. [Leaderboard Filters] Card with scope segmented pills & subject/period dropdowns
/// 4. [How to Climb Ranks?] Card with 4 checklist items & growth trophy illustration
/// Built strictly following the Rankearn centralized design system.
class LeaderboardSidebar extends StatelessWidget {
  final LeaderboardUserEntry currentUser;
  final List<LeaderboardUserEntry> topWeekly;
  final LeaderboardScope selectedScope;
  final LeaderboardPeriod selectedPeriod;
  final String selectedSubject;
  final ValueChanged<LeaderboardScope> onScopeChanged;
  final ValueChanged<LeaderboardPeriod> onPeriodChanged;
  final ValueChanged<String> onSubjectChanged;
  final VoidCallback? onViewProfile;
  final VoidCallback? onViewAllWeekly;

  const LeaderboardSidebar({
    super.key,
    required this.currentUser,
    required this.topWeekly,
    required this.selectedScope,
    required this.selectedPeriod,
    required this.selectedSubject,
    required this.onScopeChanged,
    required this.onPeriodChanged,
    required this.onSubjectChanged,
    this.onViewProfile,
    this.onViewAllWeekly,
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
    return Column(
      children: [
        // Card 1: Your Rank
        _buildYourRankCard(),
        const SizedBox(height: AppSpacing.lg),

        // Card 2: Top 3 This Week
        _buildTopWeeklyCard(),
        const SizedBox(height: AppSpacing.lg),

        // Card 3: Leaderboard Filters
        _buildFilterCard(),
        const SizedBox(height: AppSpacing.lg),

        // Card 4: How to Climb Ranks?
        _buildClimbTipsCard(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 1. YOUR RANK CARD
  // ---------------------------------------------------------------------------
  Widget _buildYourRankCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.leaderboardBorder, width: 1.2),
        boxShadow: AppShadows.leaderboardCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.leaderboardAmber500,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Your Rank',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.leaderboardNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontFamilyFallback: AppTypography.fontFallbacks,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: onViewProfile,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'View Profile',
                      style: TextStyle(
                        color: AppColors.infoBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamilyFallback: AppTypography.fontFallbacks,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.infoBlue,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // User Avatar + Rank + Name
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.leaderboardGreen,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: AppShadows.subtle,
                ),
                child: const Icon(
                  Icons.sentiment_very_satisfied_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${currentUser.rank}',
                      style: const TextStyle(
                        color: AppColors.leaderboardGreenDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        fontFamilyFallback: AppTypography.fontFallbacks,
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            currentUser.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.leaderboardNavy,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              fontFamilyFallback: AppTypography.fontFallbacks,
                            ),
                          ),
                        ),
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
                              fontFamilyFallback: AppTypography.fontFallbacks,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currentUser.state,
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
          const SizedBox(height: 14),

          // 4 Stats Grid (Level, Tests, Win Rate, Coins Earned)
          Row(
            children: [
              Expanded(
                child: _buildPersonalStatPill(
                  label: 'Level',
                  value: 'Lv. ${currentUser.level}',
                  valueColor: AppColors.leaderboardGreenDark,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildPersonalStatPill(
                  label: 'Tests',
                  value: _formatNumber(currentUser.testsCompleted),
                  valueColor: AppColors.leaderboardSlate800,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildPersonalStatPill(
                  label: 'Win Rate',
                  value: '${currentUser.winRate}%',
                  valueColor: AppColors.leaderboardGreen,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildPersonalStatPill(
                  label: 'Coins Earned',
                  value: _formatNumber(currentUser.coinsEarned),
                  valueColor: AppColors.leaderboardDarkSlate,
                  isCoins: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalStatPill({
    required String label,
    required String value,
    required Color valueColor,
    bool isCoins = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.leaderboardSlate50,
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: AppColors.leaderboardBorder, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCoins)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.leaderboardGold,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.monetization_on_rounded,
                      color: AppColors.leaderboardGoldDark,
                      size: 8.5,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      fontFamilyFallback: AppTypography.fontFallbacks,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                fontFamilyFallback: AppTypography.fontFallbacks,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.leaderboardMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontFamilyFallback: AppTypography.fontFallbacks,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. TOP 3 THIS WEEK CARD
  // ---------------------------------------------------------------------------
  Widget _buildTopWeeklyCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.leaderboardBorder, width: 1.2),
        boxShadow: AppShadows.leaderboardCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.leaderboardAmber500,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Top 3 This Week',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.leaderboardNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontFamilyFallback: AppTypography.fontFallbacks,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: onViewAllWeekly,
                child: Row(
                  children: const [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: AppColors.infoBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamilyFallback: AppTypography.fontFallbacks,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.infoBlue,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 3 Performer Rows
          ...topWeekly.take(3).map((user) => _buildTopWeeklyRow(user)),
        ],
      ),
    );
  }

  Widget _buildTopWeeklyRow(LeaderboardUserEntry user) {
    Color medalColor = AppColors.leaderboardGold;
    if (user.rank == 2) medalColor = AppColors.leaderboardSilver;
    if (user.rank == 3) medalColor = AppColors.leaderboardBronze;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Medal
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: medalColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${user.rank}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                fontFamilyFallback: AppTypography.fontFallbacks,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Avatar
          CircleAvatar(
            radius: 14,
            backgroundColor: user.avatarBgColor,
            child: const Icon(
              Icons.person,
              color: AppColors.leaderboardNavy,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Name + State
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.leaderboardNavy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    fontFamilyFallback: AppTypography.fontFallbacks,
                  ),
                ),
                Text(
                  user.state,
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

          // Coins Won
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.leaderboardAmber100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: AppColors.leaderboardGoldDark,
                  size: 11,
                ),
                const SizedBox(width: 2),
                Text(
                  _formatNumber(user.coinsEarned),
                  style: const TextStyle(
                    color: AppColors.leaderboardGoldDark,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    fontFamilyFallback: AppTypography.fontFallbacks,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. LEADERBOARD FILTERS CARD
  // ---------------------------------------------------------------------------
  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.leaderboardBorder, width: 1.2),
        boxShadow: AppShadows.leaderboardCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tune_rounded, color: AppColors.infoBlue, size: 18),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Leaderboard Filters',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.leaderboardNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamilyFallback: AppTypography.fontFallbacks,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Scope Selector: Global, Friends, My State
          Container(
            decoration: const BoxDecoration(
              color: AppColors.leaderboardSlate100,
              borderRadius: AppRadii.borderMd,
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                _buildScopePill('Global', LeaderboardScope.global),
                _buildScopePill('Friends', LeaderboardScope.friends),
                _buildScopePill('My State', LeaderboardScope.myState),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Dropdown 1: All Subjects
          _buildDropdownTile(
            icon: Icons.menu_book_rounded,
            label: selectedSubject,
            items: const [
              'All Subjects',
              'BPSC Prelims',
              'History',
              'General Science',
            ],
            onChanged: (val) {
              if (val != null) onSubjectChanged(val);
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // Dropdown 2: Period
          _buildDropdownTile(
            icon: Icons.calendar_today_rounded,
            label: switch (selectedPeriod) {
              LeaderboardPeriod.allTime => 'All Time',
              LeaderboardPeriod.weekly => 'This Week',
              LeaderboardPeriod.monthly => 'This Month',
            },
            items: const ['All Time', 'This Week', 'This Month'],
            onChanged: (val) {
              if (val == 'All Time') {
                onPeriodChanged(LeaderboardPeriod.allTime);
              } else if (val == 'This Week') {
                onPeriodChanged(LeaderboardPeriod.weekly);
              } else if (val == 'This Month') {
                onPeriodChanged(LeaderboardPeriod.monthly);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScopePill(String title, LeaderboardScope scope) {
    final isSelected = selectedScope == scope;

    return Expanded(
      child: InkWell(
        onTap: () => onScopeChanged(scope),
        borderRadius: AppRadii.borderSm,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.leaderboardGreen : Colors.transparent,
            borderRadius: AppRadii.borderSm,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.leaderboardMuted,
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontFamilyFallback: AppTypography.fontFallbacks,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.leaderboardSlate50,
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: AppColors.leaderboardBorder, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(label) ? label : items.first,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.leaderboardMuted,
            size: 18,
          ),
          style: const TextStyle(
            color: AppColors.leaderboardNavy,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            fontFamilyFallback: AppTypography.fontFallbacks,
          ),
          onChanged: onChanged,
          items: items.map((val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Row(
                children: [
                  Icon(icon, color: AppColors.leaderboardMuted, size: 14),
                  const SizedBox(width: AppSpacing.sm),
                  Text(val),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. HOW TO CLIMB RANKS? CARD
  // ---------------------------------------------------------------------------
  Widget _buildClimbTipsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.leaderboardBorder, width: 1.2),
        boxShadow: AppShadows.leaderboardCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.insights_rounded,
                color: AppColors.leaderboardGreen,
                size: 18,
              ),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'How to Climb Ranks?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.leaderboardNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamilyFallback: AppTypography.fontFallbacks,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 4 Checklist items
              Expanded(
                flex: 6,
                child: Column(
                  children: const [
                    _TipCheckItem('Attempt more tests'),
                    SizedBox(height: AppSpacing.sm),
                    _TipCheckItem('Win 1v1 battles'),
                    SizedBox(height: AppSpacing.sm),
                    _TipCheckItem('Maintain high accuracy'),
                    SizedBox(height: AppSpacing.sm),
                    _TipCheckItem('Earn more coins'),
                  ],
                ),
              ),

              // Right trophy graphic with growth arrow
              Expanded(
                flex: 4,
                child: Container(
                  height: 90,
                  alignment: Alignment.centerRight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Green arrow up behind
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: AppColors.brandGreen.withAlpha(160),
                          size: 54,
                        ),
                      ),
                      // Golden trophy
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: AppColors.leaderboardAmber500,
                        size: 48,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TipCheckItem extends StatelessWidget {
  final String text;

  const _TipCheckItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: AppColors.leaderboardGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 11),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.leaderboardSlate700,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              fontFamilyFallback: AppTypography.fontFallbacks,
            ),
          ),
        ),
      ],
    );
  }
}
