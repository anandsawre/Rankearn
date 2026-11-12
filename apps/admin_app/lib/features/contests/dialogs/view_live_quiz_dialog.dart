import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/live_quiz_item.dart';

class ViewLiveQuizDialog extends StatelessWidget {
  final LiveQuizItem item;

  const ViewLiveQuizDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: item.title,
      subtitle: '${item.category} • ${item.statusLabel}',
      iconData: Icons.podcasts_rounded,
      maxWidth: 580,
      scrollable: true,
      actions: [
        AppModalDialog.cancelButton(context, label: 'Close'),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Description
          Text(
            item.description.isNotEmpty ? item.description : 'Live competitive showdown with instant ranking & coin distribution.',
            style: AppTypography.bodySmall.copyWith(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),

          // Key Parameters Grid
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: AppRadii.cardSubtle,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildParam('Category', item.category),
                    _buildParam('Status', item.statusLabel),
                    _buildParam('Duration', '${item.durationMinutes} min'),
                  ],
                ),
                const Divider(height: 20, color: AppColors.border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildParam('Participants', item.participantsCount.toString()),
                    _buildParam('Questions', item.questionsCount.toString()),
                    _buildParam('Reward Coins', '${item.rewardCoins} pts'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Top Leaderboard Preview
          Text(
            'Top Participants / Leaderboard',
            style: AppTypography.titleSmall.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          _buildLeaderboardRow(rank: 1, name: 'Priya Sharma', score: '98 pts', time: '12m 40s', avatarColor: AppColors.brandPurple),
          _buildLeaderboardRow(rank: 2, name: 'Amit Verma', score: '94 pts', time: '13m 15s', avatarColor: AppColors.brandBlue),
          _buildLeaderboardRow(rank: 3, name: 'Rahul Kumar', score: '91 pts', time: '14m 02s', avatarColor: AppColors.brandGreen),
        ],
      ),
    );
  }

  Widget _buildParam(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow({
    required int rank,
    required String name,
    required String score,
    required String time,
    required Color avatarColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.button,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: rank == 1 ? AppColors.coinBadgeBackground : AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: rank == 1 ? AppColors.coinGold : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: AppTypography.bodySmall.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
          Text(
            score,
            style: AppTypography.bodySmall.copyWith(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.brandGreen),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: AppTypography.bodySmall.copyWith(fontSize: 10.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
