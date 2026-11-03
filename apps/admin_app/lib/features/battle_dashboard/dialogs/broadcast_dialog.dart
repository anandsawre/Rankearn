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
    return AppModalDialog(
      title: 'Broadcast Battle Alert',
      subtitle: 'In-game real-time notification transmission',
      iconData: Icons.campaign_rounded,
      gradientColors: const [Color(0xFF0D9488), Color(0xFF14B8A6)],
      maxWidth: 500,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12.5)),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _handleTransmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D9488),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            elevation: 0,
          ),
          icon: const Icon(Icons.send_rounded, size: 16),
          label: const Text('Transmit Alert', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Alert Header', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          SizedBox(
            height: 48,
            child: TextField(
              controller: _titleController,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 12.5),
              decoration: _inputDecoration('Title'),
            ),
          ),
          const SizedBox(height: 14),

          const Text('Target Audience', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          AppDropdown<String>(
            value: _target,
            items: const [
              AppDropdownItem(value: 'All Players', label: 'All Online Players'),
              AppDropdownItem(value: '1 vs 1 Players Only', label: '1 vs 1 Players Only'),
              AppDropdownItem(value: 'Tournament Players Only', label: 'Tournament Players Only'),
              AppDropdownItem(value: 'VIP & High-Tier Rankers', label: 'VIP & High-Tier Rankers'),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _target = v);
            },
          ),
          const SizedBox(height: 14),

          const Text('Message Body', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          TextField(
            controller: _messageController,
            maxLines: 3,
            style: const TextStyle(fontSize: 12.5),
            decoration: _inputDecoration('Enter alert notification text...'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) =>
      AppModalDialog.inputDecoration(hint, focusColor: const Color(0xFF0D9488));
}
