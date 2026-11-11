import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../tabs/players_tab.dart';

class BattlePlayersDialog extends StatelessWidget {
  const BattlePlayersDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Player Management & Moderation',
      subtitle: 'Audit player win rates, duel rankings and Supabase account standing',
      iconData: Icons.people_outline_rounded,
      gradientColors: const [
        AppColors.battleAdminPurple,
        AppColors.battleAdminPurpleSecondary,
      ],
      maxWidth: 960,
      maxHeight: 740,
      scrollable: true,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 40),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: const Text(
            'Close',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
      child: const BattlePlayersTab(inDialog: true),
    );
  }
}

