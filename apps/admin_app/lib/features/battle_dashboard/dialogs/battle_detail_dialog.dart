import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/battle_dashboard_models.dart';
import '../services/battle_dashboard_service.dart';
import 'confirm_action_dialog.dart';

class BattleDetailDialog extends StatelessWidget {
  final BattleItem battle;

  const BattleDetailDialog({super.key, required this.battle});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 580,
        constraints: const BoxConstraints(maxHeight: 650),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: AppRadii.borderTopLg,
                border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: battle.type.bgColor,
                      borderRadius: AppRadii.borderMd,
                    ),
                    child: Text(
                      battle.type.label,
                      style: AppTypography.captionBold.copyWith(
                        color: battle.type.color,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'ID: ${battle.id}',
                    style: AppTypography.headingSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.liveRedSubtle,
                      borderRadius: AppRadii.borderPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: AppColors.liveRed, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          battle.status.label,
                          style: AppTypography.captionBold.copyWith(color: AppColors.liveRed, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta Info Grid
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: AppRadii.borderLg,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetaCol('Subject', battle.subject, Icons.category_rounded, AppColors.battleAdminPurple),
                          _buildMetaCol('Time Remaining', battle.formattedTimeLeft, Icons.timer_outlined, AppColors.liveRed),
                          _buildMetaCol('Entry Fee', '${battle.entryFee} Coins', Icons.monetization_on_rounded, AppColors.warning),
                          _buildMetaCol('Prize Pool', '${battle.prizePool} Coins', Icons.emoji_events_rounded, AppColors.brandGreen),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Participants List
                    Text(
                      'Participants (${battle.participants.length} / ${battle.maxPlayers})',
                      style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),

                    if (battle.participants.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: AppRadii.borderMd,
                        ),
                        child: Text('No participants joined yet.', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                      )
                    else
                      ...battle.participants.map((p) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadii.borderMd,
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(p.avatarUrl),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                      ),
                                      Text(
                                        'Rank #${p.rank} • Correct: ${p.correctAnswers}',
                                        style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandPurpleLight,
                                    borderRadius: AppRadii.borderSm,
                                  ),
                                  child: Text(
                                    '${p.score} pts',
                                    style: AppTypography.captionBold.copyWith(color: AppColors.battleAdminPurple, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    const SizedBox(height: 16),

                    // Live Question Progress
                    Text(
                      'Live Progression: Question ${battle.currentQuestion} of ${battle.totalQuestions}',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: AppRadii.borderSm,
                      child: LinearProgressIndicator(
                        value: battle.currentQuestion / battle.totalQuestions,
                        backgroundColor: AppColors.borderSubtle,
                        color: AppColors.battleAdminPurple,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: AppRadii.borderBottomLg,
                border: Border(top: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      BattleDashboardService().addTimeToBattle(battle.id, 60);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.timer_rounded, size: 16, color: AppColors.battleAdminPurple),
                    label: Text('+60s Time', style: AppTypography.labelSmall.copyWith(color: AppColors.battleAdminPurple)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.battleAdminPurple),
                      shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
                    ),
                  ),
                  const Spacer(),
                  if (battle.status == BattleStatus.live) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        BattleDashboardService().pauseSingleBattle(battle.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.pause_rounded, size: 16),
                      label: Text('Pause', style: AppTypography.labelSmall.copyWith(color: AppColors.textOnPrimary)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: AppColors.textOnPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        BattleDashboardService().startSingleBattle(battle.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 16),
                      label: Text('Start', style: AppTypography.labelSmall.copyWith(color: AppColors.textOnPrimary)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandGreen,
                        foregroundColor: AppColors.textOnPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ConfirmActionDialog(
                          title: 'Terminate Battle ${battle.id}?',
                          description: 'This will instantly conclude the match and distribute rewards or issue refunds.',
                          confirmLabel: 'Force End',
                          isDestructive: true,
                          onConfirm: (reason) async {
                            BattleDashboardService().endSingleBattle(battle.id, true, reason);
                            Navigator.pop(context); // Close detail dialog
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.power_settings_new_rounded, size: 16),
                    label: Text('Force End', style: AppTypography.labelSmall.copyWith(color: AppColors.textOnPrimary)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.liveRed,
                      foregroundColor: AppColors.textOnPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaCol(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.captionBold.copyWith(fontSize: 10.5, color: AppColors.textSecondary)),
      ],
    );
  }
}
