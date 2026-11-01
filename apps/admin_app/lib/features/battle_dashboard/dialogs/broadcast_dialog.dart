import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../services/battle_dashboard_service.dart';

class BroadcastDialog extends StatefulWidget {
  const BroadcastDialog({super.key});

  @override
  State<BroadcastDialog> createState() => _BroadcastDialogState();
}

class _BroadcastDialogState extends State<BroadcastDialog> {
  final _titleController = TextEditingController(text: 'Scheduled Battle Alert');
  final _messageController = TextEditingController(
    text: 'Mega 50-Player Battle is starting in 5 minutes! Join from lobby to win up to 4,500 coins.',
  );
  String _target = 'All Players';

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleTransmit() {
    final title = _titleController.text.trim();
    final msg = _messageController.text.trim();
    if (title.isEmpty || msg.isEmpty) return;

    BattleDashboardService().broadcastMessage(title, msg, _target);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Broadcast sent to active players!'),
        backgroundColor: AppColors.brandGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 480,
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
                    color: AppColors.brandGreenLight,
                    borderRadius: AppRadii.borderMd,
                  ),
                  child: const Icon(Icons.campaign_rounded, color: AppColors.brandGreenDark, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Broadcast Battle Alert',
                        style: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'In-game notification transmission',
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

            Text('Alert Header', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: _inputDecoration('Title'),
            ),
            const SizedBox(height: 14),

            Text('Target Audience', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _target,
              decoration: _inputDecoration(''),
              items: [
                DropdownMenuItem(value: 'All Players', child: Text('All Online Players', style: AppTypography.bodyMedium)),
                DropdownMenuItem(value: 'In Battles Only', child: Text('In Live Battles Only', style: AppTypography.bodyMedium)),
                DropdownMenuItem(value: 'In Rooms Only', child: Text('In Custom Rooms Only', style: AppTypography.bodyMedium)),
              ],
              onChanged: (v) => setState(() => _target = v!),
            ),
            const SizedBox(height: 14),

            Text('Message Body', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: _messageController,
              maxLines: 3,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: _inputDecoration('Notification message content...'),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _handleTransmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandGreenDark,
                foregroundColor: AppColors.textOnPrimary,
                minimumSize: const Size(double.infinity, 42),
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderSm),
                elevation: 0,
              ),
              child: Text('Transmit Broadcast', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textOnPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surfaceSubtle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: AppRadii.borderMd,
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadii.borderMd,
        borderSide: const BorderSide(color: AppColors.brandGreenDark, width: 1.5),
      ),
    );
  }
}
