import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SendNotificationDialog extends StatefulWidget {
  final int selectedUsersCount;

  const SendNotificationDialog({super.key, this.selectedUsersCount = 0});

  @override
  State<SendNotificationDialog> createState() => _SendNotificationDialogState();
}

class _SendNotificationDialogState extends State<SendNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _targetAudience = 'all';
  String _channel = 'in_app';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedUsersCount > 0) {
      _targetAudience = 'selected';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _send() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification broadcast scheduled successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Send Broadcast Notification',
      subtitle: 'Dispatch immediate push alerts and in-app notices to users',
      iconData: Icons.notifications_active_outlined,
      gradientColors: const [Color(0xFFD97706), Color(0xFFF59E0B)],
      maxWidth: 520,
      scrollable: true,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12.5)),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _isSending ? null : _send,
          icon: _isSending
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send_rounded, size: 16),
          label: const Text('Send Broadcast', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD97706),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Audience Dropdown
            const Text('Target Audience *', style: _labelStyle),
            const SizedBox(height: 6),
            AppDropdown<String>(
              value: _targetAudience,
              items: [
                const AppDropdownItem(value: 'all', label: 'All Platform Users (12,458)'),
                const AppDropdownItem(value: 'students', label: 'Students Only (8,972)'),
                const AppDropdownItem(value: 'premium', label: 'Premium Subscribers (2,241)'),
                const AppDropdownItem(value: 'teachers', label: 'Teachers (623)'),
                if (widget.selectedUsersCount > 0)
                  AppDropdownItem(value: 'selected', label: 'Selected Users (${widget.selectedUsersCount})'),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _targetAudience = val);
              },
            ),
            const SizedBox(height: 14),

            // Title
            const Text('Notification Title *', style: _labelStyle),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleCtrl,
              decoration: _inputDecoration('e.g. New All-India Mock Test is Live!'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 14),

            // Message Body
            const Text('Message Body *', style: _labelStyle),
            const SizedBox(height: 6),
            TextFormField(
              controller: _messageCtrl,
              maxLines: 3,
              decoration: _inputDecoration('Enter notification announcement details...'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a message' : null,
            ),
            const SizedBox(height: 14),

            // Delivery Channel
            Row(
              children: [
                const Text('Channel: ', style: _labelStyle),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('In-App Push', style: TextStyle(fontSize: 11)),
                  selected: _channel == 'in_app',
                  onSelected: (s) => setState(() => _channel = 'in_app'),
                  selectedColor: const Color(0xFFFEF3C7),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Email', style: TextStyle(fontSize: 11)),
                  selected: _channel == 'email',
                  onSelected: (s) => setState(() => _channel = 'email'),
                  selectedColor: const Color(0xFFFEF3C7),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334155),
  );

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
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
        borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5),
      ),
    );
  }
}
