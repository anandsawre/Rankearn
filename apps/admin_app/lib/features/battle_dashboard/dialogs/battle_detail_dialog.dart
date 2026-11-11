import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/battle_dashboard_models.dart';
import '../services/battle_dashboard_service.dart';
import '../widgets/battle_player_avatar.dart';
import 'confirm_action_dialog.dart';

class BattleDetailDialog extends StatelessWidget {
  final BattleItem battle;

  const BattleDetailDialog({super.key, required this.battle});

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: '${battle.type.label} — #${battle.id}',
      subtitle: '${battle.subject} • Status: ${battle.status.label}',
      iconData: Icons.sports_kabaddi_rounded,
      gradientColors: const [Color(0xFF5636F5), Color(0xFF7C3AED)],
      maxWidth: 600,
      maxHeight: 700,
      actions: [
        if (battle.status == BattleStatus.waiting) ...[
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await BattleDashboardService().startSingleBattle(battle.id);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to start: $e'), backgroundColor: AppColors.liveRed),
                );
              }
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 16),
            label: const Text('Start Match', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (battle.status == BattleStatus.live) ...[
          ElevatedButton.icon(
            onPressed: () {
              AppModalDialog.show(
                context: context,
                builder: (_) => ConfirmActionDialog(
                  title: 'Complete Battle ${battle.id}?',
                  description: 'Mark this live battle as completed in Supabase.',
                  confirmLabel: 'Complete',
                  isDestructive: false,
                  onConfirm: (reason) async {
                    await BattleDashboardService().completeSingleBattle(battle.id, reason: reason);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              );
            },
            icon: const Icon(Icons.task_alt_rounded, size: 16),
            label: const Text('Complete', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (battle.status == BattleStatus.live || battle.status == BattleStatus.waiting)
          ElevatedButton.icon(
            onPressed: () {
              AppModalDialog.show(
                context: context,
                builder: (_) => ConfirmActionDialog(
                  title: 'Cancel Battle ${battle.id}?',
                  description: 'Sets this battle status to cancelled in Supabase and records an audit entry.',
                  confirmLabel: 'Cancel Match',
                  isDestructive: true,
                  onConfirm: (reason) async {
                    await BattleDashboardService().cancelSingleBattle(battle.id, reason);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              );
            },
            icon: const Icon(Icons.power_settings_new_rounded, size: 16),
            label: const Text('Cancel Match', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meta Info Grid
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetaCol('Topic Pool', battle.subject, Icons.category_rounded, const Color(0xFF5636F5)),
                _buildMetaCol('Duration', battle.formattedTimeLeft, Icons.timer_outlined, const Color(0xFFDC2626)),
                _buildMetaCol('Entry Fee', '${battle.entryFee} Coins', Icons.monetization_on_rounded, AppColors.warning),
                _buildMetaCol('Prize Pool', '${battle.prizePool} Coins', Icons.emoji_events_rounded, AppColors.brandGreen),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Participants List
          Text(
            'Participants (${battle.participants.length} / ${battle.maxPlayers})',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 10),

          if (battle.participants.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text('No participants joined yet.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            )
          else
            ...battle.participants.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    children: [
                      BattlePlayerAvatar(name: p.name, avatarUrl: p.avatarUrl, radius: 16),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                            ),
                            Text(
                              'Rank #${p.rank}${battle.winnerId == p.id ? ' • Winner' : ''}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${p.score} pts',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF5636F5)),
                        ),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 16),

          // Question Bank Info
          Text(
            'Question Bank Pool: ${battle.totalQuestions} battle questions',
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCol(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF101A3A))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
      ],
    );
  }
}
