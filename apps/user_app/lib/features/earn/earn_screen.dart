import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

enum EarnSubTab {
  contests,
  battle,
  refer,
  leaderboard,
}

class EarnScreen extends StatefulWidget {
  final int userCoins;
  final VoidCallback onOpenBattle;
  final void Function(String contestTitle, int fee) onJoinContest;

  const EarnScreen({
    super.key,
    required this.userCoins,
    required this.onOpenBattle,
    required this.onJoinContest,
  });

  @override
  State<EarnScreen> createState() => _EarnScreenState();
}

class _EarnScreenState extends State<EarnScreen> {
  EarnSubTab _activeSubTab = EarnSubTab.contests;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Earn Section Sub-Tab Navigation Bar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.borderPill,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _buildTabButton(EarnSubTab.contests, 'Contests 🏆'),
                _buildTabButton(EarnSubTab.battle, '1v1 Battle ⚔️'),
                _buildTabButton(EarnSubTab.refer, 'Refer 🎁'),
                _buildTabButton(EarnSubTab.leaderboard, 'Ranks 🥇'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Active Tab View
          switch (_activeSubTab) {
            EarnSubTab.contests => _buildContestsView(),
            EarnSubTab.battle => _buildBattleArenaView(),
            EarnSubTab.refer => _buildReferralView(),
            EarnSubTab.leaderboard => _buildLeaderboardView(),
          },
        ],
      ),
    );
  }

  Widget _buildTabButton(EarnSubTab tab, String title) {
    final isSelected = _activeSubTab == tab;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeSubTab = tab),
        borderRadius: AppRadii.borderPill,
        child: AnimatedContainer(
          duration: AppMotion.shortDuration,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandPrimary : Colors.transparent,
            borderRadius: AppRadii.borderPill,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // --- 1. Contests & Tournaments View ---
  Widget _buildContestsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Active Competitive Leagues', style: AppTypography.titleLarge),
        const SizedBox(height: 4),
        Text('Participate in timed tournament mocks to win real coin rewards.', style: AppTypography.bodySmall),
        const SizedBox(height: 16),

        _buildContestCard(
          title: '70th BPSC Grand Mock League 🏆',
          status: 'LIVE NOW',
          isLive: true,
          prizePool: 5000,
          entryFee: 20,
          participants: 124,
          endsIn: '02h 15m remaining',
        ),
        const SizedBox(height: 12),

        _buildContestCard(
          title: 'SSC CGL General Awareness Super League ⚡',
          status: 'UPCOMING',
          isLive: false,
          prizePool: 2500,
          entryFee: 10,
          participants: 86,
          endsIn: 'Starts at 04:00 PM',
        ),
        const SizedBox(height: 12),

        _buildContestCard(
          title: 'Railway NTPC Speed Math Championship 🚆',
          status: 'UPCOMING',
          isLive: false,
          prizePool: 3000,
          entryFee: 15,
          participants: 62,
          endsIn: 'Starts Tomorrow 10:00 AM',
        ),
      ],
    );
  }

  Widget _buildContestCard({
    required String title,
    required String status,
    required bool isLive,
    required int prizePool,
    required int entryFee,
    required int participants,
    required String endsIn,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isLive ? AppColors.errorRoseLight : const Color(0xFFFFF7ED),
                  borderRadius: AppRadii.borderPill,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isLive ? AppColors.errorRose : const Color(0xFFF97316),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: isLive ? AppColors.errorRose : const Color(0xFFEA580C),
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(endsIn, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: AppTypography.titleMedium),
          const SizedBox(height: 14),

          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Prize Pool', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: AppColors.coinGold, size: 16),
                      const SizedBox(width: 2),
                      Text('$prizePool Coins', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Entry Fee', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  Text('$entryFee Coins', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.brandPrimaryDark)),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Joined', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  Text('$participants Candidates', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          AppButton(
            label: isLive ? 'Join Contest Now ($entryFee Coins)' : 'Register for Tournament',
            width: double.infinity,
            onPressed: () => widget.onJoinContest(title, entryFee),
          ),
        ],
      ),
    );
  }

  // --- 2. 1v1 Battle Arena View ---
  Widget _buildBattleArenaView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sports_kabaddi, color: AppColors.errorRose, size: 36),
              ),
              const SizedBox(height: 14),
              const Text('1v1 Speed Battle Arena ⚔️', style: AppTypography.titleLarge),
              const SizedBox(height: 6),
              const Text(
                'Challenge fellow candidates in a rapid 5-question face-off. Quickest correct answers win the coin pool!',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 20),

              // Stake Selection Pills
              const Text('Select Battle Stake:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StakeChip(coins: 10, isSelected: false),
                  SizedBox(width: 10),
                  _StakeChip(coins: 20, isSelected: true),
                  SizedBox(width: 10),
                  _StakeChip(coins: 50, isSelected: false),
                ],
              ),
              const SizedBox(height: 24),

              AppButton(
                label: 'Find Random Opponent ⚔️',
                width: double.infinity,
                onPressed: widget.onOpenBattle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 3. Refer & Earn View ---
  Widget _buildReferralView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Referral Master Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: AppRadii.borderLg,
            boxShadow: AppShadows.emeraldGlow,
          ),
          child: Column(
            children: [
              const Icon(Icons.card_giftcard, color: Colors.white, size: 48),
              const SizedBox(height: 10),
              const Text('Refer Friends & Earn 50 Coins! 🎁', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                'When your invited friend signs up and attempts their first test, you both get 50 bonus coins.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 12),
              ),
              const SizedBox(height: 20),

              // Referral Code Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.borderMd,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('RANKVIKRAM70', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.brandPrimaryDark)),
                    SizedBox(width: 12),
                    Icon(Icons.copy, size: 18, color: AppColors.brandPrimary),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Referral Stats
        const Row(
          children: [
            Expanded(
              child: AppStatCard(
                label: 'Friends Invited',
                value: '4 Users',
                icon: Icons.people_outline,
                iconColor: AppColors.infoBlue,
                iconBgColor: AppColors.infoBlueLight,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: AppStatCard(
                label: 'Coins Earned',
                value: '200 Coins',
                icon: Icons.monetization_on,
                iconColor: AppColors.coinGold,
                iconBgColor: AppColors.coinGoldLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 4. Leaderboard View ---
  Widget _buildLeaderboardView() {
    final topRankers = [
      ('1', 'Priya Sharma', 'Patna', '18,450 Coins', '142 Tests'),
      ('2', 'Amit Verma', 'Gaya', '16,200 Coins', '118 Tests'),
      ('3', 'Rohan Singh', 'Muzaffarpur', '14,800 Coins', '95 Tests'),
      ('4', 'Vikram Singh (You)', 'Patna', '1,450 Coins', '18 Tests'),
      ('5', 'Anjali Kumari', 'Darbhanga', '12,900 Coins', '82 Tests'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('All India Leaderboard 🏆', style: AppTypography.titleLarge),
        const SizedBox(height: 4),
        Text('Top performing candidates ranked by total coins and tests taken.', style: AppTypography.bodySmall),
        const SizedBox(height: 16),

        for (final ranker in topRankers)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: ranker.$1 == '1'
                          ? AppColors.coinGoldLight
                          : (ranker.$1 == '4' ? AppColors.brandPrimaryLight : AppColors.surfaceSubtle),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '#${ranker.$1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: ranker.$1 == '1' ? AppColors.coinGold : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ranker.$2, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ranker.$1 == '4' ? AppColors.brandPrimaryDark : AppColors.textPrimary)),
                        Text('${ranker.$3} • ${ranker.$5}', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  Text(
                    ranker.$4,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.coinGold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _StakeChip extends StatelessWidget {
  final int coins;
  final bool isSelected;

  const _StakeChip({required this.coins, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.brandPrimary : Colors.white,
        borderRadius: AppRadii.borderPill,
        border: Border.all(
          color: isSelected ? AppColors.brandPrimary : AppColors.border,
        ),
      ),
      child: Text(
        '$coins Coins',
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
