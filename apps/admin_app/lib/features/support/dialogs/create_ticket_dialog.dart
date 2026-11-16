import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class CreateTicketDialog extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> ticket) onCreate;

  const CreateTicketDialog({super.key, required this.onCreate});

  @override
  State<CreateTicketDialog> createState() => _CreateTicketDialogState();
}

class _CreateTicketDialogState extends State<CreateTicketDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _category = 'Payment';
  String _priority = 'high';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty || _subjectController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    final newTicket = {
      'id': 'TK-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'subject': _subjectController.text.trim(),
      'category': _category,
      'priority': _priority,
      'status': 'open',
      'lastTime': 'Just Now',
      'lastMsg': _messageController.text.trim(),
      'messages': [
        {
          'isUser': true,
          'text': _messageController.text.trim(),
          'time': 'Just Now',
        }
      ],
    };

    await widget.onCreate(newTicket);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Create Ticket for User',
      subtitle: 'Open manual inquiry or support case on behalf of candidate',
      iconData: Icons.person_add_alt_1_rounded,
      maxWidth: 520,
      actions: [
        AppButton.adminSecondary(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        AppButton.adminPrimary(
          label: _isSubmitting ? 'Creating...' : 'Create Ticket',
          leadingIcon: const Icon(Icons.check_rounded, size: 16),
          onPressed: _isSubmitting ? null : _submit,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _nameController,
                  hintText: 'Candidate Name *',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppTextField(
                  controller: _emailController,
                  hintText: 'User Email Address *',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppDropdown<String>(
                  inlineLabel: true,
                  value: _category,
                  items: const [
                    AppDropdownItem(value: 'Payment', label: 'Payment & Coins'),
                    AppDropdownItem(value: 'Verification', label: 'Verification'),
                    AppDropdownItem(value: 'Referral', label: 'Referral'),
                    AppDropdownItem(value: 'Technical', label: 'Technical'),
                    AppDropdownItem(value: 'Withdrawal', label: 'Withdrawal'),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _category = v);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppDropdown<String>(
                  inlineLabel: true,
                  value: _priority,
                  items: const [
                    AppDropdownItem(value: 'high', label: 'High Priority'),
                    AppDropdownItem(value: 'medium', label: 'Medium Priority'),
                    AppDropdownItem(value: 'low', label: 'Low Priority'),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _priority = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _subjectController,
            hintText: 'Ticket Subject Line *',
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _messageController,
            hintText: 'Initial query description / issue notes...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}
