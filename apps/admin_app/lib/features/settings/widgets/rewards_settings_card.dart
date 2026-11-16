import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class RewardsSettingsCard extends StatelessWidget {
  final TextEditingController signupBonusController;
  final TextEditingController referralRewardController;
  final TextEditingController battleRewardController;
  final TextEditingController spinMinController;
  final TextEditingController spinMaxController;
  final TextEditingController minWithdrawalController;
  final TextEditingController coinRateController;

  const RewardsSettingsCard({
    super.key,
    required this.signupBonusController,
    required this.referralRewardController,
    required this.battleRewardController,
    required this.spinMinController,
    required this.spinMaxController,
    required this.minWithdrawalController,
    required this.coinRateController,
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
                child: const Icon(Icons.toll_rounded, size: 18, color: AppColors.adminPurple),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Rewards & Coins Settings',
                  style: AppTypography.adminCardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text('Signup Bonus (Coins)', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: signupBonusController,
            hintText: '100',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.monetization_on_outlined, size: 18, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(height: 10),

          Text('Referral Reward (per user)', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: referralRewardController,
            hintText: '10',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.monetization_on_outlined, size: 18, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(height: 10),

          Text('Battle Win Reward (default)', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: battleRewardController,
            hintText: '50',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.monetization_on_outlined, size: 18, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(height: 10),

          Text('Spin Reward (Min – Max)', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: spinMinController,
                  hintText: '5',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.casino_outlined, size: 18, color: AppColors.adminSecondaryText),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppTextField(
                  controller: spinMaxController,
                  hintText: '50',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.casino_outlined, size: 18, color: AppColors.adminSecondaryText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text('Minimum Withdrawal (Coins)', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: minWithdrawalController,
            hintText: '1000',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 18, color: AppColors.adminPurple),
          ),
          const SizedBox(height: 10),

          Text('Coin to Cash Rate', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: coinRateController,
            hintText: '100 Coins = ₹1',
            prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 18, color: AppColors.adminSuccess),
          ),
        ],
      ),
    );
  }
}

