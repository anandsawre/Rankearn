import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Modal dialog displaying Tournament Rules & Eligibility Guidelines
class TournamentRulesDialog extends StatelessWidget {
  const TournamentRulesDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const TournamentRulesDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
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
                          'Tournament Rules & Eligibility',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Fair play guidelines and reward criteria',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textSecondary,
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.borderSubtle, height: 1),
              const SizedBox(height: 16),

              // Content List
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildRuleItem(
                      number: '1',
                      title: 'Eligibility & Entry',
                      description:
                          'Open to all verified registered users. Free tournaments require zero coins. Paid tournaments require the designated entry fee in Rankearn coins at the time of joining.',
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
                          'Only your first submitted attempt during the active tournament window counts toward the All-India leaderboard ranking and reward distribution.',
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
                          'Official ranks are locked at tournament completion. Winning coins and cash vouchers are credited automatically to your Rankearn wallet within 2 hours of results verification.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
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
                fontSize: 13,
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
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
