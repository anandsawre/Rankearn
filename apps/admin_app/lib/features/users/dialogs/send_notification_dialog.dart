import 'package:flutter/material.dart';

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.send_rounded, color: Color(0xFFF59E0B), size: 19),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Send Broadcast Notification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101A3A),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Audience Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _targetAudience,
                  decoration: InputDecoration(
                    labelText: 'Target Audience',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All Platform Users (12,458)')),
                    const DropdownMenuItem(value: 'students', child: Text('Students Only (8,972)')),
                    const DropdownMenuItem(value: 'premium', child: Text('Premium Subscribers (2,241)')),
                    const DropdownMenuItem(value: 'teachers', child: Text('Teachers (623)')),
                    if (widget.selectedUsersCount > 0)
                      DropdownMenuItem(
                        value: 'selected',
                        child: Text('Selected Users (${widget.selectedUsersCount})'),
                      ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _targetAudience = val);
                  },
                ),
                const SizedBox(height: 14),

                // Title
                TextFormField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Notification Title *',
                    hintText: 'e.g. New All-India Mock Test is Live!',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 14),

                // Message Body
                TextFormField(
                  controller: _messageCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Message Body *',
                    hintText: 'Enter your notification details or announcement message here...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a message' : null,
                ),
                const SizedBox(height: 14),

                // Delivery Channel
                Row(
                  children: [
                    const Text('Channel: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('In-App Push', style: TextStyle(fontSize: 11)),
                      selected: _channel == 'in_app',
                      onSelected: (s) => setState(() => _channel = 'in_app'),
                      selectedColor: const Color(0xFFEDE9FE),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Email', style: TextStyle(fontSize: 11)),
                      selected: _channel == 'email',
                      onSelected: (s) => setState(() => _channel = 'email'),
                      selectedColor: const Color(0xFFEDE9FE),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSending ? null : _send,
                      icon: _isSending
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Send Broadcast'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5636F5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
