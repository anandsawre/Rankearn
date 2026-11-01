import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SendWheelNotificationDialog extends StatefulWidget {
  const SendWheelNotificationDialog({super.key});

  @override
  State<SendWheelNotificationDialog> createState() => _SendWheelNotificationDialogState();
}

class _SendWheelNotificationDialogState extends State<SendWheelNotificationDialog> {
  final _titleController = TextEditingController(text: '🎡 Free Daily Spin is Ready!');
  final _messageController = TextEditingController(
    text: 'Spin the Lucky Wheel today to win up to 500 Coins and exclusive rewards. Don’t miss your lucky day!',
  );
  String _target = 'All Users';

  static const List<Map<String, String>> _targetOptions = [
    {'value': 'All Users', 'label': 'All Registered Users (24,560)'},
    {'value': 'Active Today', 'label': 'Active Today (6,820)'},
    {'value': 'Inactive Users', 'label': 'Inactive for >3 days (8,410)'},
    {'value': 'New Users', 'label': 'New Users (<7 days) (2,120)'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _send() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Push notification broadcasted to $_target!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Send Lucky Wheel Notification',
      subtitle: 'Remind users to spin the wheel and boost daily engagement',
      iconData: Icons.campaign_rounded,
      gradientColors: const [Color(0xFFF04483), Color(0xFFFB7185)],
      maxWidth: 520,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _send,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5636F5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          icon: const Icon(Icons.send_rounded, size: 16),
          label: const Text('Broadcast Notification'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          const Text('Notification Title', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF101A3A))),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Message
          const Text('Message Body', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF101A3A))),
          const SizedBox(height: 6),
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Target audience
          AppDropdown<String>(
            label: 'Target Audience',
            value: _target,
            items: _targetOptions.map((opt) {
              return AppDropdownItem(value: opt['value']!, label: opt['label']!);
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _target = val);
            },
          ),
        ],
      ),
    );
  }
}
