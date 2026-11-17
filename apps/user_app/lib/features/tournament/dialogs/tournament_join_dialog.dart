import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';

/// Modal bottom sheet confirming entry & coin deduction for a tournament/contest.
/// Built using the centralized [AppBottomSheet] component from the Design System.
class TournamentJoinDialog extends StatelessWidget {
  final TestModel tournament;
  final int userCoins;

  const TournamentJoinDialog({
    super.key,
    required this.tournament,
    required this.userCoins,
  });

  static Future<bool?> show(
    BuildContext context, {
    required TestModel tournament,
    required int userCoins,
  }) {
    return AppBottomSheet.show<bool>(
      context: context,
      builder: (context) => TournamentJoinDialog(
        tournament: tournament,
        userCoins: userCoins,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entryFee = tournament.entryFeeCoins;
    final isFree = entryFee == 0;
    final hasInsufficientCoins = !isFree && userCoins < entryFee;

    return AppBottomSheet(
      showDragHandle: true,
      showCloseButton: false,
      header: _buildHeader(isFree),
      bottomAction: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.borderSubtle),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.borderMd,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: hasInsufficientCoins
                  ? null
                  : () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.disabled,
                disabledForegroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.borderMd,
                ),
                elevation: 0,
              ),
              child: Text(
                isFree ? 'Confirm & Join' : 'Pay $entryFee Coins & Join',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Contest Specs Container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: AppRadii.borderMd,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSpecPill(
                    icon: Icons.help_outline_rounded,
                    label: 'Questions',
                    value: '${tournament.totalQuestions > 0 ? tournament.totalQuestions : 10} Qs',
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                Container(width: 1, height: 32, color: AppColors.borderSubtle),
                Expanded(
                  child: _buildSpecPill(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: '${tournament.durationMinutes > 0 ? tournament.durationMinutes : 15} Mins',
                    color: AppColors.brandPurple,
                  ),
                ),
                Container(width: 1, height: 32, color: AppColors.borderSubtle),
                Expanded(
                  child: _buildSpecPill(
                    icon: Icons.emoji_events_outlined,
                    label: 'Prize Pool',
                    value: tournament.prizePoolInRupees > 0
                        ? '₹${tournament.prizePoolInRupees.toInt()}'
                        : '${tournament.winningRewardCoins > 0 ? tournament.winningRewardCoins : 1000} Coins',
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Fee & Balance Breakdown Card
          const Text(
            'Payment & Wallet Details',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.borderMd,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                _buildFeeRow(
                  label: 'Contest Entry Fee',
                  value: isFree ? 'FREE (0 Coins)' : '$entryFee Coins',
                  valueColor: isFree ? AppColors.brandGreen : AppColors.surfaceDark,
                  isHighlight: true,
                ),
                const Divider(color: AppColors.borderSubtle, height: 16),
                _buildFeeRow(
                  label: 'Your Current Balance',
                  value: '$userCoins Coins',
                  valueColor: AppColors.textSecondary,
                ),
                if (!isFree) ...[
                  const Divider(color: AppColors.borderSubtle, height: 16),
                  _buildFeeRow(
                    label: 'Remaining Balance After Joining',
                    value: '${(userCoins - entryFee).clamp(0, 999999999)} Coins',
                    valueColor: (userCoins >= entryFee)
                        ? AppColors.brandGreen
                        : const Color(0xFFDC2626),
                    isBold: true,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 3. Status Note or Warning
          if (isFree)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F8EF),
                borderRadius: AppRadii.borderMd,
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.brandGreen,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Registration is completely FREE! Compete for the All-India leaderboard rank and prize pool.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF065F46),
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (hasInsufficientCoins)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: AppRadii.borderMd,
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFDC2626),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Insufficient coin balance! You need ${entryFee - userCoins} more coins to join. Earn coins or top up your wallet.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFFB91C1C),
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: AppRadii.borderMd,
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.brandGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$entryFee Coins will be securely deducted from your wallet upon confirmation.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF166534),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isFree) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isFree
                ? const Color(0xFFE6F8EF)
                : const Color(0xFFFEF3C7),
            borderRadius: AppRadii.borderMd,
          ),
          alignment: Alignment.center,
          child: Icon(
            isFree
                ? Icons.celebration_rounded
                : Icons.monetization_on_rounded,
            color: isFree ? AppColors.brandGreen : const Color(0xFFD97706),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFree ? 'Join Free Contest' : 'Confirm Contest Entry',
                style: AppTypography.bottomSheetTitle,
              ),
              const SizedBox(height: 3),
              Text(
                tournament.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bottomSheetSubtitle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: AppColors.surfaceDark,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeeRow({
    required String label,
    required String value,
    required Color valueColor,
    bool isHighlight = false,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 14.5 : 13.5,
            fontWeight: isHighlight || isBold ? FontWeight.w800 : FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
