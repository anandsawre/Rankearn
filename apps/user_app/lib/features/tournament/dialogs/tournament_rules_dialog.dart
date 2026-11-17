import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Modal bottom sheet displaying Contest Rules & Eligibility Guidelines.
/// Built using the centralized [AppBottomSheet] component from the Design System.
class TournamentRulesDialog extends StatelessWidget {
  const TournamentRulesDialog({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      builder: (context) => const TournamentRulesDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      showDragHandle: true,
      showCloseButton: false,
      header: _buildHeader(),
      bottomAction: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.borderMd,
          ),
          elevation: 0,
        ),
        child: const Text(
          'I Understand & Agree',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRuleItem(
            number: '1',
            title: 'Eligibility & Entry',
            description:
                'Open to all verified registered users. Free contests require zero coins. Paid contests require the designated entry fee in Rankearn coins at the time of joining.',
          ),
          _buildRuleItem(
            number: '2',
            title: 'Scoring & Accuracy',
            description:
                'Each correct response awards standard question marks (+2). Incorrect responses incur negative marking (-0.66) as per exam standards. Ties are resolved by fastest completion time.',
          ),
          _buildRuleItem(
            number: '3',
            title: 'Single Official Attempt',
            description:
                'Only your first submitted attempt during the active contest window counts toward the All-India leaderboard ranking and reward distribution.',
          ),
          _buildRuleItem(
            number: '4',
            title: 'Fair Play & Anti-Cheat',
            description:
                'Switching tabs, minimizing the app, or abnormal background activity triggers automated warnings. Excessive violations result in immediate disqualification and forfeiture of prizes.',
          ),
          _buildRuleItem(
            number: '5',
            title: 'Prize Pool Distribution',
            description:
                'Official ranks are locked at contest completion. Winning coins and cash vouchers are credited automatically to your Rankearn wallet within 2 hours of results verification.',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius: AppRadii.borderMd,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.gavel_rounded,
            color: AppColors.brandPurple,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contest Rules & Eligibility',
                style: AppTypography.bottomSheetTitle,
              ),
              SizedBox(height: 3),
              Text(
                'Fair play guidelines and reward criteria',
                style: AppTypography.bottomSheetSubtitle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFFE6F8EF),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.brandGreen,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
