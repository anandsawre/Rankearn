import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class LimitsRulesCard extends StatelessWidget {
  final TextEditingController battleLimitController;
  final TextEditingController coinLimitController;
  final TextEditingController withdrawalLimitController;
  final TextEditingController suspensionThresholdController;

  const LimitsRulesCard({
    super.key,
    required this.battleLimitController,
    required this.coinLimitController,
    required this.withdrawalLimitController,
    required this.suspensionThresholdController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.adminPurpleLight,
                  borderRadius: AppRadii.adminControl,
                ),
                child: const Icon(Icons.shield_outlined, size: 18, color: AppColors.adminPurple),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Limits & Rules',
                  style: AppTypography.adminCardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text('Daily Battle Limit (per user)', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: battleLimitController,
            hintText: '20',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.track_changes_rounded, size: 18, color: AppColors.adminPurple),
          ),
          const SizedBox(height: 10),

          Text('Daily Coin Earning Limit', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: coinLimitController,
            hintText: '1,000',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.paid_outlined, size: 18, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(height: 10),

          Text('Withdrawal Limit (per day)', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: withdrawalLimitController,
            hintText: '₹ 5,000',
            prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 18, color: AppColors.adminSuccess),
          ),
          const SizedBox(height: 10),

          Text('Account Suspension Threshold', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: suspensionThresholdController,
            hintText: '3 Violations',
            prefixIcon: const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.adminDanger),
          ),
        ],
      ),
    );
  }
}

