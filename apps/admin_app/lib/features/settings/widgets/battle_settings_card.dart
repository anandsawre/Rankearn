import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class BattleSettingsCard extends StatelessWidget {
  final String questionTime;
  final String battleDuration;
  final TextEditingController maxPlayersController;
  final TextEditingController entryFeeController;
  final TextEditingController winningRewardController;
  final ValueChanged<String?> onQuestionTimeChanged;
  final ValueChanged<String?> onBattleDurationChanged;

  const BattleSettingsCard({
    super.key,
    required this.questionTime,
    required this.battleDuration,
    required this.maxPlayersController,
    required this.entryFeeController,
    required this.winningRewardController,
    required this.onQuestionTimeChanged,
    required this.onBattleDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: AppShadows.adminCard,
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
                child: const Icon(Icons.sports_esports_rounded, size: 18, color: AppColors.adminPurple),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Battle & Game Settings',
                  style: AppTypography.adminCardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text('Default Question Time', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppDropdown<String>(
            inlineLabel: true,
            value: questionTime,
            items: const [
              AppDropdownItem(value: '3Seconds', label: '3 Seconds'),
              AppDropdownItem(value: '5Seconds', label: '5 Seconds'),
              AppDropdownItem(value: '10Seconds', label: '10 Seconds'),
              AppDropdownItem(value: '15Seconds', label: '15 Seconds'),
              AppDropdownItem(value: '30Seconds', label: '30 Seconds'),
            ],
            prefixIcon: const Icon(Icons.timer_outlined, size: 18, color: AppColors.adminPurple),
            onChanged: onQuestionTimeChanged,
          ),
          const SizedBox(height: 10),

          Text('Default Battle Duration', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppDropdown<String>(
            inlineLabel: true,
            value: battleDuration,
            items: const [
              AppDropdownItem(value: '1Minutes', label: '1 Minute'),
              AppDropdownItem(value: '2Minutes', label: '2 Minutes'),
              AppDropdownItem(value: '3Minutes', label: '3 Minutes'),
              AppDropdownItem(value: '5Minutes', label: '5 Minutes'),
            ],
            prefixIcon: const Icon(Icons.alarm_rounded, size: 18, color: AppColors.adminPurple),
            onChanged: onBattleDurationChanged,
          ),
          const SizedBox(height: 10),

          Text('Max Players (Multiplayer)', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: maxPlayersController,
            hintText: '100',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.groups_rounded, size: 18, color: AppColors.adminSecondaryText),
          ),
          const SizedBox(height: 10),

          Text('Entry Fee (Default)', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: entryFeeController,
            hintText: '10 Coins',
            prefixIcon: const Icon(Icons.monetization_on_rounded, size: 18, color: AppColors.coinGold),
          ),
          const SizedBox(height: 10),

          Text('Winning Reward (Default)', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: winningRewardController,
            hintText: '50 Coins',
            prefixIcon: const Icon(Icons.emoji_events_rounded, size: 18, color: AppColors.coinGold),
          ),
        ],
      ),
    );
  }
}

