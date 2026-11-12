import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';

class SendNotificationDialog extends StatefulWidget {
  final int totalUsersCount;
  final int studentsCount;
  final int premiumCount;
  final List<String> selectedUserIds;

  const SendNotificationDialog({
    super.key,
    this.totalUsersCount = 0,
    this.studentsCount = 0,
    this.premiumCount = 0,
    this.selectedUserIds = const [],
  });

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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.selectedUserIds.isNotEmpty) {
      _targetAudience = 'selected';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      setState(() => _errorMessage = 'Database connection is not initialized.');
      return;
    }

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    final now = DateTime.now();
    final title = _titleCtrl.text.trim();
    final message = _messageCtrl.text.trim();
    final notifType = _channel == 'email' ? 'announcement' : 'info';

    try {
      if (_targetAudience == 'selected' && widget.selectedUserIds.isNotEmpty) {
        final rows = widget.selectedUserIds.asMap().entries.map((entry) {
          return {
            'id': 'notif_${now.millisecondsSinceEpoch}_${entry.key}',
            'user_id': entry.value,
            'title': title,
            'message': message,
            'type': notifType,
            'target_segment': 'selected',
            'created_at': now.toUtc().toIso8601String(),
          };
        }).toList();
        await client.from('notifications').insert(rows);
      } else {
        await client.from('notifications').insert({
          'id': 'notif_${now.millisecondsSinceEpoch}',
          'user_id': 'global',
          'title': title,
          'message': message,
          'type': notifType,
          'target_segment': _targetAudience,
          'created_at': now.toUtc().toIso8601String(),
        });
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification saved & dispatched to Supabase!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _errorMessage = 'Failed to dispatch notification: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Send Broadcast Notification',
      subtitle: 'Dispatch immediate in-app alerts stored in Supabase notifications',
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
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDA4AF)),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF9F1239), fontWeight: FontWeight.w600),
                ),
              ),
            ],
            const Text('Target Audience *', style: _labelStyle),
            const SizedBox(height: 6),
            AppDropdown<String>(
              value: _targetAudience,
              items: [
                AppDropdownItem(value: 'all', label: 'All Platform Users (${widget.totalUsersCount})'),
                AppDropdownItem(value: 'students', label: 'Students (${widget.studentsCount})'),
                AppDropdownItem(value: 'premium', label: 'Premium Subscribers (${widget.premiumCount})'),
                if (widget.selectedUserIds.isNotEmpty)
                  AppDropdownItem(value: 'selected', label: 'Selected Users (${widget.selectedUserIds.length})'),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _targetAudience = val);
              },
            ),
            const SizedBox(height: 14),
            const Text('Notification Title *', style: _labelStyle),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleCtrl,
              decoration: _inputDecoration('Enter notification title...'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 14),
            const Text('Message Body *', style: _labelStyle),
            const SizedBox(height: 6),
            TextFormField(
              controller: _messageCtrl,
              maxLines: 3,
              decoration: _inputDecoration('Enter notification announcement details...'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a message' : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text('Type: ', style: _labelStyle),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('In-App Push', style: TextStyle(fontSize: 11)),
                  selected: _channel == 'in_app',
                  onSelected: (s) => setState(() => _channel = 'in_app'),
                  selectedColor: const Color(0xFFFEF3C7),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Announcement', style: TextStyle(fontSize: 11)),
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

  static InputDecoration _inputDecoration(String hint) =>
      AppModalDialog.inputDecoration(hint, focusColor: const Color(0xFFD97706));
}
