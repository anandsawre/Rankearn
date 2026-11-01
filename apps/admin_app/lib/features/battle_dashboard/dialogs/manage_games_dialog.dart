import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'create_battle_dialog.dart';

class ManageGamesDialog extends StatelessWidget {
  const ManageGamesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Game Modes & Arenas',
      subtitle: 'Quick deploy and battle parameters',
      iconData: Icons.tune_rounded,
      gradientColors: const [Color(0xFFD97706), Color(0xFFF59E0B)],
      maxWidth: 540,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD97706),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
        ],
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Icon(icon, color: tagColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(4)),
                      child: Text(tag, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: tagColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.35)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 20, color: Color(0xFF5636F5)),
            tooltip: 'Deploy Arena',
            onPressed: () {
              Navigator.pop(context);
              AppModalDialog.show(context: context, builder: (_) => const CreateBattleDialog());
            },
          ),
        ],
      ),
    );
  }
}
