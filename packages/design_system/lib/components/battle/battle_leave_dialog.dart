import 'package:flutter/material.dart';
import '../../tokens/radii.dart';
import '../buttons/app_button.dart';

/// Confirmation dialog when leaving an in-progress battle
class BattleLeaveDialog extends StatelessWidget {
  final int entryFee;
  final VoidCallback onConfirmLeave;

  const BattleLeaveDialog({
    super.key,
    required this.entryFee,
    required this.onConfirmLeave,
  });

  static Future<bool?> show(BuildContext context, {required int entryFee}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => BattleLeaveDialog(
        entryFee: entryFee,
        onConfirmLeave: () => Navigator.of(ctx).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadii.borderXl),
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 26),
          SizedBox(width: 10),
          Text(
            'Leave Battle?',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Color(0xFF10194F),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
      content: Text(
        'If you leave now, you will forfeit this match and lose your $entryFee coins stake. Are you sure you want to surrender?',
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF64748B),
          height: 1.4,
          fontFamily: 'Inter',
        ),
      ),
      actions: [
        AppButton(
          label: 'Keep Playing',
          variant: AppButtonVariant.ghost,
          size: AppButtonSize.small,
          foregroundColor: const Color(0xFF00B96B),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: 'Leave Match',
          variant: AppButtonVariant.destructive,
          size: AppButtonSize.small,
          borderRadius: AppRadii.borderMd,
          onPressed: onConfirmLeave,
        ),
      ],
    );
  }
}
