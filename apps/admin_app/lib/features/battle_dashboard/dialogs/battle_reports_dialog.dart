import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../tabs/reports_tab.dart';

class BattleReportsDialog extends StatelessWidget {
  const BattleReportsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Battle Analytics & Performance Reports',
      subtitle: 'Computed directly from live Supabase battles, wallet payouts and audit logs',
      iconData: Icons.bar_chart_rounded,
      gradientColors: const [
        AppColors.battleAdminPurple,
        AppColors.battleAdminPurpleSecondary,
      ],
      maxWidth: 980,
      maxHeight: 760,
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
      child: const BattleReportsTab(inDialog: true),
    );
  }
}

