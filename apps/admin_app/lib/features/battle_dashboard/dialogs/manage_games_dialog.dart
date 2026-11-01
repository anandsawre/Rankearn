import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'create_battle_dialog.dart';

class ManageGamesDialog extends StatelessWidget {
  const ManageGamesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.coinGoldLight,
                    borderRadius: AppRadii.borderMd,
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.coinGold, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Game Modes & Arenas',
                        style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Quick deploy and battle parameters',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 18),

            _buildModeTile(
              context,
              title: '1 vs 1 Rapid Duel',
              subtitle: 'Head-to-head match with automated bot matchmaking & 10s timer.',
              tag: '856 Active',
              tagColor: AppColors.battleAdminPurple,
              tagBg: AppColors.brandPurpleLight,
              icon: Icons.sports_kabaddi_rounded,
            ),
            const SizedBox(height: 12),

            _buildModeTile(
              context,
              title: 'Multiplayer Rumble',
              subtitle: '3 to 100 players concurrent quiz battle with dynamic live leaderboard.',
              tag: '328 Active',
              tagColor: AppColors.coinGold,
              tagBg: AppColors.coinGoldLight,
              icon: Icons.groups_rounded,
            ),
            const SizedBox(height: 12),

            _buildModeTile(
              context,
              title: 'Private Custom Room',
              subtitle: 'Code-based custom rooms with customizable stakes and subjects.',
              tag: '140 Active',
              tagColor: AppColors.brandBlue,
              tagBg: AppColors.brandBlueLight,
              icon: Icons.meeting_room_rounded,
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required Color tagBg,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tagBg,
              borderRadius: AppRadii.borderMd,
            ),
            child: Icon(icon, color: tagColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: tagBg, borderRadius: AppRadii.borderSm),
                      child: Text(tag, style: AppTypography.captionBold.copyWith(fontSize: 9.5, color: tagColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(context: context, builder: (_) => const CreateBattleDialog());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.battleAdminPurple,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: AppRadii.borderSm),
              elevation: 0,
            ),
            child: Text('Deploy', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textOnPrimary)),
          ),
        ],
      ),
    );
  }
}
