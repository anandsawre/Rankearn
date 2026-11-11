import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'create_battle_dialog.dart';

class CreateRoomDialog extends StatelessWidget {
  const CreateRoomDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Custom Battle Rooms',
      subtitle: 'Supabase schema capability check',
      iconData: Icons.meeting_room_rounded,
      gradientColors: const [
        AppColors.battleAdminPurpleSecondary,
        AppColors.battleAdminPurple,
      ],
      maxWidth: 480,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
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
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            AppModalDialog.show(
              context: context,
              builder: (_) => const CreateBattleDialog(),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.battleAdminPurple,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: const Text(
            'Create 1v1 Battle Instead',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.brandBlueLight,
          borderRadius: AppRadii.borderMd,
          border: Border.all(color: AppColors.brandBlue.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.brandBlueDark, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Custom battle rooms are not backed by a database table in the current Supabase schema (public.battles only provisions 1 vs 1 duels). Add a battle_rooms migration before deploying room creation.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.brandBlueDark,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
