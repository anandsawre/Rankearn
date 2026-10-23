import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';

/// 3 Horizontal Quick Status Cards (Round, Time Left, Stake)
class BattleQuickStatusCardsRow extends StatelessWidget {
  final int currentRound;
  final int totalRounds;
  final int remainingSeconds;
  final int stakeCoins;

  const BattleQuickStatusCardsRow({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    required this.remainingSeconds,
    required this.stakeCoins,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Round
        Expanded(
          child: _buildItem(
            icon: Icons.bar_chart_rounded,
            iconColor: const Color(0xFF2587F8),
            iconBg: const Color(0xFFEFF6FF),
            label: 'Round',
            value: '$currentRound of $totalRounds',
          ),
        ),
        const SizedBox(width: 8),

        // 2. Time Left
        Expanded(
          child: _buildItem(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFFFF385C),
            iconBg: const Color(0xFFFFF1F2),
            label: 'Time Left',
            value: '${remainingSeconds}s',
            valueColor: const Color(0xFFFF385C),
          ),
        ),
        const SizedBox(width: 8),

        // 3. Stake
        Expanded(
          child: _buildItem(
            icon: Icons.monetization_on_rounded,
            iconColor: const Color(0xFFFFB800),
            iconBg: const Color(0xFFFFFBEB),
            label: 'Stake',
            value: '$stakeCoins Coins',
          ),
        ),
      ],
    );
  }

  Widget _buildItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.battleBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0810194F),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.battleSecondaryText,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: valueColor ?? AppColors.battleNavy,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Battle Info Card (Win, Correct, Wrong rewards)
class BattleInfoCard extends StatelessWidget {
  final int winReward;
  final int correctReward;
  final int wrongReward;

  const BattleInfoCard({
    super.key,
    this.winReward = 100,
    this.correctReward = 10,
    this.wrongReward = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.battleBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A10194F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.sports_esports_rounded, color: Color(0xFF2587F8), size: 18),
              SizedBox(width: 8),
              Text(
                'Battle Info',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.battleNavy,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRow(
            icon: Icons.emoji_events_rounded,
            iconColor: const Color(0xFFFFB800),
            label: 'Win this Battle',
            coins: '+$winReward Coins',
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildRow(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFFB800),
            label: 'Correct Answer',
            coins: '+$correctReward Coins',
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildRow(
            icon: Icons.close_rounded,
            iconColor: const Color(0xFFFF385C),
            label: 'Wrong Answer',
            coins: '$wrongReward Coins',
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String coins,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFB800), size: 15),
            const SizedBox(width: 4),
            Text(
              coins,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.battleNavy,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Live Players Online Card
class PlayersOnlineCard extends StatelessWidget {
  final String count;

  const PlayersOnlineCard({
    super.key,
    this.count = '2,468',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.battleBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A10194F),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: const [
                Icon(Icons.groups_rounded, color: Color(0xFF00B96B), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Players Online',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.battleNavy,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.battleNavy,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00B96B),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x6600B96B), blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Recent Battles Card with Win/Loss tags
class RecentBattlesCard extends StatelessWidget {
  final VoidCallback? onViewAll;

  const RecentBattlesCard({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.battleBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A10194F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.history_rounded, color: Color(0xFF2587F8), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recent Battles',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.battleNavy,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onViewAll,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2587F8),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildItem(
            name: 'Rohit vs Priya',
            coinsDelta: '+100',
            isWin: true,
            avatarBg: const Color(0xFF3B82F6),
          ),
          const Divider(height: 14, color: Color(0xFFF1F5F9)),
          _buildItem(
            name: 'Aman vs Neha',
            coinsDelta: '-50',
            isWin: false,
            avatarBg: const Color(0xFFFF5C5C),
          ),
          const Divider(height: 14, color: Color(0xFFF1F5F9)),
          _buildItem(
            name: 'You vs Karan',
            coinsDelta: '+100',
            isWin: true,
            avatarBg: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String name,
    required String coinsDelta,
    required bool isWin,
    required Color avatarBg,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: avatarBg.withAlpha(40),
                child: Icon(Icons.person, size: 16, color: avatarBg),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              coinsDelta,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: isWin ? const Color(0xFF00B96B) : const Color(0xFFFF385C),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isWin ? const Color(0xFFD6F6E5) : const Color(0xFFFFE5E8),
                borderRadius: AppRadii.borderPill,
              ),
              child: Text(
                isWin ? '🏆 Win' : '❌ Lose',
                style: TextStyle(
                  color: isWin ? const Color(0xFF008C52) : const Color(0xFFD61F3D),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Battle Summary Card (for Victory Screen)
class BattleSummaryCard extends StatelessWidget {
  final String subject;
  final int totalQuestions;
  final int yourCorrect;
  final int opponentCorrect;
  final String timeTaken;
  final String result;

  const BattleSummaryCard({
    super.key,
    this.subject = 'General Science',
    this.totalQuestions = 5,
    this.yourCorrect = 4,
    this.opponentCorrect = 0,
    this.timeTaken = '1 min 12 sec',
    this.result = 'You Won',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.battleBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A10194F),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.bar_chart_rounded, color: Color(0xFF00B96B), size: 20),
              SizedBox(width: 8),
              Text(
                'Battle Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.battleNavy,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRow('Subject', subject, isChip: true, chipColor: const Color(0xFFE6FAF0), textColor: const Color(0xFF008C52)),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildRow('Total Questions', '$totalQuestions'),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildRow('Your Correct Answers', '$yourCorrect', valueColor: const Color(0xFF00B96B)),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildRow('Opponent Correct Answers', '$opponentCorrect', valueColor: const Color(0xFFFF385C)),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildRow('Time Taken', timeTaken, isChip: true, chipColor: const Color(0xFFEFF6FF), textColor: const Color(0xFF2587F8)),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildRow('Result', result, isChip: true, chipColor: const Color(0xFFD6F6E5), textColor: const Color(0xFF008C52)),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    Color? valueColor,
    bool isChip = false,
    Color? chipColor,
    Color? textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
              fontFamily: 'Inter',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        if (isChip)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
            decoration: BoxDecoration(
              color: chipColor ?? const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: textColor ?? AppColors.battleNavy,
                fontFamily: 'Inter',
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.battleNavy,
              fontFamily: 'Inter',
            ),
          ),
      ],
    );
  }
}

/// Rank Impact Card (for Victory Screen)
class RankImpactCard extends StatelessWidget {
  final String yourRank;
  final String newRank;
  final String rankChange;
  final String winningStreak;
  final int totalBattles;

  const RankImpactCard({
    super.key,
    this.yourRank = '#1256',
    this.newRank = '#1228',
    this.rankChange = '+28',
    this.winningStreak = '3 Wins',
    this.totalBattles = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.battleBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A10194F),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFB800), size: 20),
              SizedBox(width: 8),
              Text(
                'Rank Impact',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.battleNavy,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Your Rank',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$yourRank → ',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    '$newRank ▲',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF00B96B),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildRow('Rank Change', rankChange, valueColor: const Color(0xFF00B96B)),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildRow('Current Winning Streak', winningStreak, valueColor: const Color(0xFFF59E0B)),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildRow('Total Battles Played', '$totalBattles'),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
              fontFamily: 'Inter',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.battleNavy,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

/// Keep Going! Motivational Card with 3D illustration
class KeepGoingCard extends StatelessWidget {
  const KeepGoingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD1FAE5), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0810194F),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.track_changes_rounded, color: Color(0xFF00B96B), size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Keep Going!',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.battleNavy,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Win more battles to earn coins, improve your rank and challenge top players across India!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                    height: 1.35,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Color(0x33F59E0B), blurRadius: 8),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFF59E0B),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
