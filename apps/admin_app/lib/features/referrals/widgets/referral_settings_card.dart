import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class ReferralSettingsCard extends StatelessWidget {
  final TextEditingController referrerRewardController;
  final TextEditingController signupBonusController;
  final TextEditingController minWithdrawalController;
  final bool enableProgram;
  final ValueChanged<bool> onEnableProgramChanged;
  final bool autoCredit;
  final ValueChanged<bool> onAutoCreditChanged;
  final bool rewardOnFirstTx;
  final ValueChanged<bool> onRewardOnFirstTxChanged;
  final bool isSaving;
  final VoidCallback onReset;
  final VoidCallback onSave;

  const ReferralSettingsCard({
    super.key,
    required this.referrerRewardController,
    required this.signupBonusController,
    required this.minWithdrawalController,
    required this.enableProgram,
    required this.onEnableProgramChanged,
    required this.autoCredit,
    required this.onAutoCreditChanged,
    required this.rewardOnFirstTx,
    required this.onRewardOnFirstTxChanged,
    required this.isSaving,
    required this.onReset,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: AppRadii.adminCard,
        border: Border.fromBorderSide(BorderSide(color: AppColors.adminBorder)),
        boxShadow: AppShadows.adminCard,
      ),
      padding: AppSpacing.adminCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.adminPurpleLight,
                  borderRadius: AppRadii.adminControl,
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.adminPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Referral Program Settings',
                      style: AppTypography.adminCardTitle,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Configure reward quotas, auto credit rules & payouts',
                      style: AppTypography.adminCardSubtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // 3 Inputs in responsive row or column
          LayoutBuilder(
            builder: (context, constraints) {
              final isThree = constraints.maxWidth >= 640;
              if (isThree) {
                return Row(
                  children: [
                    Expanded(child: _buildRewardInput('Referral Reward (Referrer)', referrerRewardController, '50', 'Coins')),
                    const SizedBox(width: 14),
                    Expanded(child: _buildRewardInput('Signup Bonus (Referee)', signupBonusController, '25', 'Coins')),
                    const SizedBox(width: 14),
                    Expanded(child: _buildRewardInput('Min. Withdrawal', minWithdrawalController, '100', '₹')),
                  ],
                );
              }
              return Column(
                children: [
                  _buildRewardInput('Referral Reward (Referrer)', referrerRewardController, '50', 'Coins'),
                  const SizedBox(height: 14),
                  _buildRewardInput('Signup Bonus (Referee)', signupBonusController, '25', 'Coins'),
                  const SizedBox(height: 14),
                  _buildRewardInput('Min. Withdrawal', minWithdrawalController, '100', '₹'),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Toggles
          const Divider(color: AppColors.adminBorder, height: 1),
          const SizedBox(height: 18),

          _buildToggleTile(
            title: 'Enable Referral Program',
            subtitle: 'Users can generate invite links and earn rewards',
            value: enableProgram,
            activeColor: AppColors.adminPurple,
            onChanged: onEnableProgramChanged,
          ),
          const SizedBox(height: 12),
          _buildToggleTile(
            title: 'Auto Credit Reward',
            subtitle: 'Instantly transfer coins to wallet upon verified phone signup',
            value: autoCredit,
            activeColor: AppColors.adminSuccess,
            onChanged: onAutoCreditChanged,
          ),
          const SizedBox(height: 12),
          _buildToggleTile(
            title: 'Reward on First Transaction',
            subtitle: 'Require referee to participate in 1 test or contest before release',
            value: rewardOnFirstTx,
            activeColor: AppColors.adminBlue,
            onChanged: onRewardOnFirstTxChanged,
          ),
          const SizedBox(height: 24),

          // Bottom Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButton.adminGhost(
                label: 'Reset Defaults',
                leadingIcon: const Icon(Icons.refresh_rounded, size: 16),
                onPressed: isSaving ? null : onReset,
              ),
              AppButton.adminPrimary(
                label: isSaving ? 'Saving...' : 'Save Settings',
                isLoading: isSaving,
                leadingIcon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                onPressed: isSaving ? null : onSave,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardInput(
    String label,
    TextEditingController controller,
    String hint,
    String unit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.adminFieldLabelSmall,
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: controller,
          hintText: hint,
          keyboardType: TextInputType.number,
          prefixIcon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              unit,
              style: AppTypography.adminTableAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.adminFieldLabel,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.adminTableSecondary,
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: Colors.white,
          activeTrackColor: activeColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
