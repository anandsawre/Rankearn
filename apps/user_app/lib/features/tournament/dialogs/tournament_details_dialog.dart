import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';

/// Modal bottom sheet displaying comprehensive Tournament details, prize breakdown & action CTA.
/// Built using the centralized [AppBottomSheet] component from the Design System.
class TournamentDetailsDialog extends StatelessWidget {
  final TestModel tournament;
  final bool isRegistered;
  final VoidCallback onParticipate;

  const TournamentDetailsDialog({
    super.key,
    required this.tournament,
    required this.isRegistered,
    required this.onParticipate,
  });

  static Future<void> show(
    BuildContext context, {
    required TestModel tournament,
    required bool isRegistered,
    required VoidCallback onParticipate,
  }) {
    return AppBottomSheet.show(
      context: context,
      builder: (context) => TournamentDetailsDialog(
        tournament: tournament,
        isRegistered: isRegistered,
        onParticipate: onParticipate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entryFee = tournament.entryFeeCoins;
    final isFree = entryFee == 0;
    final prizePool = tournament.prizePoolInRupees > 0
        ? '₹${tournament.prizePoolInRupees.toInt()}'
        : (tournament.winningRewardCoins > 0
            ? '${tournament.winningRewardCoins} Coins'
            : '₹10,000');

    return AppBottomSheet(
      showDragHandle: true,
      showCloseButton: false,
      header: _buildHeader(),
      bottomAction: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          onParticipate();
        },
        icon: Icon(
          isRegistered
              ? Icons.play_arrow_rounded
              : Icons.how_to_reg_rounded,
          size: 20,
        ),
        label: Text(
          isRegistered ? 'Start Contest Quiz' : 'Participate Now',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.borderMd,
          ),
          elevation: 0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Key Specs Grid
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: AppRadii.borderMd,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSpecItem(
                    icon: Icons.calendar_today_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    label: 'Window',
                    value: tournament.datesFormatted,
                  ),
                ),
                Container(
                  width: 1,
                  height: 34,
                  color: AppColors.borderSubtle,
                ),
                Expanded(
                  child: _buildSpecItem(
                    icon: Icons.group_rounded,
                    iconColor: const Color(0xFF10B981),
                    label: 'Participants',
                    value: tournament.totalParticipants > 0
                        ? '${tournament.totalParticipants}+'
                        : '12,480+',
                  ),
                ),
                Container(
                  width: 1,
                  height: 34,
                  color: AppColors.borderSubtle,
                ),
                Expanded(
                  child: _buildSpecItem(
                    icon: Icons.confirmation_number_rounded,
                    iconColor: isFree
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                    label: 'Entry Fee',
                    value: isFree ? 'Free Entry' : '₹$entryFee',
                  ),
                ),
                Container(
                  width: 1,
                  height: 34,
                  color: AppColors.borderSubtle,
                ),
                Expanded(
                  child: _buildSpecItem(
                    icon: Icons.emoji_events_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Prize Pool',
                    value: prizePool,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2. Prize Pool Distribution
          const Text(
            'Prize Pool Distribution',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.borderMd,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                _buildPrizeRow('Rank 1', '₹5,000', const Color(0xFFF59E0B), isFirst: true),
                const Divider(color: AppColors.borderSubtle, height: 16),
                _buildPrizeRow('Rank 2', '₹2,500', const Color(0xFF8B5CF6)),
                const Divider(color: AppColors.borderSubtle, height: 16),
                _buildPrizeRow('Rank 3', '₹1,500', const Color(0xFFB45309)),
                const Divider(color: AppColors.borderSubtle, height: 16),
                _buildPrizeRow('Rank 4 - 10', '₹100 each', AppColors.textSecondary),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 3. Test Structure
          const Text(
            'Contest Structure',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.borderMd,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint('Total Questions', '${tournament.totalQuestions > 0 ? tournament.totalQuestions : 30} MCQs'),
                const SizedBox(height: 8),
                _buildBulletPoint('Duration', '${tournament.durationMinutes} Minutes'),
                const SizedBox(height: 8),
                _buildBulletPoint('Marking Scheme', '+2.0 for Correct, -0.66 for Incorrect'),
                const SizedBox(height: 8),
                _buildBulletPoint('Languages Available', 'English & Hindi (Bilingual)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF581C87), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadii.borderMd,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFFFBBF24),
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: tournament.isLive
                          ? const Color(0xFFEF4444)
                          : (tournament.isUpcoming
                              ? const Color(0xFF8B5CF6)
                              : const Color(0xFF64748B)),
                      borderRadius: AppRadii.borderPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (tournament.isLive) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
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
                  const SizedBox(width: 8),
                  if (tournament.category != null &&
                      tournament.category!.isNotEmpty)
                    Flexible(
                      child: Text(
                        tournament.category!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                tournament.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 19, color: iconColor),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPrizeRow(String rank, String reward, Color rankColor, {bool isFirst = false}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: rankColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          rank,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isFirst ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          reward,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: isFirst ? const Color(0xFFF59E0B) : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String title, String val) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 16,
            color: AppColors.brandGreen,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: '$title: ',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: val,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
