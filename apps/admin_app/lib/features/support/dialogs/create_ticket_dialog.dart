import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class CreateTicketDialog extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> ticket) onCreate;

  const CreateTicketDialog({super.key, required this.onCreate});

  @override
  State<CreateTicketDialog> createState() => _CreateTicketDialogState();
}

class _CreateTicketDialogState extends State<CreateTicketDialog> {
  final _formKey = GlobalKey<FormState>();
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

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

    try {
      await widget.onCreate(newTicket);
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Create Ticket for User',
      subtitle: 'Open manual inquiry or support case on behalf of candidate',
      iconData: Icons.person_add_alt_1_rounded,
      maxWidth: 560,
      scrollable: true,
      actions: [
        AppModalDialog.cancelButton(context, label: 'Cancel'),
        AppModalDialog.primaryButton(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : null,
          child: Text(
            _isSubmitting ? 'Creating...' : 'Create Ticket',
            style: const TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppModalDialog.textField(
                    controller: _nameController,
                    hint: 'Candidate Name *',
                    prefixIcon: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.adminSecondaryText),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter candidate name' : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppModalDialog.textField(
                    controller: _emailController,
                    hint: 'Email Address *',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.adminSecondaryText),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter email';
                      if (!v.contains('@') || !v.contains('.')) return 'Enter valid email address';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: AppDropdown<String>(
                    inlineLabel: true,
                    value: _category,
                    prefixIcon: const Icon(Icons.category_rounded, size: 16, color: AppColors.adminSecondaryText),
                    items: const [
                      AppDropdownItem(value: 'Payment', label: 'Category: Payment & Coins'),
                      AppDropdownItem(value: 'Verification', label: 'Category: Verification'),
                      AppDropdownItem(value: 'Referral', label: 'Category: Referral'),
                      AppDropdownItem(value: 'Technical', label: 'Category: Technical'),
                      AppDropdownItem(value: 'Withdrawal', label: 'Category: Withdrawal'),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _category = v);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppDropdown<String>(
                    inlineLabel: true,
                    value: _priority,
                    prefixIcon: const Icon(Icons.flag_rounded, size: 16, color: AppColors.adminSecondaryText),
                    items: const [
                      AppDropdownItem(value: 'high', label: 'Priority: High Priority'),
                      AppDropdownItem(value: 'medium', label: 'Priority: Medium Priority'),
                      AppDropdownItem(value: 'low', label: 'Priority: Low Priority'),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _priority = v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            AppModalDialog.textField(
              controller: _subjectController,
              hint: 'Ticket Subject Line * (e.g. Coins not added after payment)',
              prefixIcon: const Icon(Icons.title_rounded, size: 18, color: AppColors.adminSecondaryText),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter subject line' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            AppModalDialog.textField(
              controller: _messageController,
              hint: 'Initial Query / Issue Notes *',
              maxLines: 4,
              minLines: 3,
              prefixIcon: const Icon(Icons.notes_rounded, size: 18, color: AppColors.adminSecondaryText),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter issue notes' : null,
            ),
          ],
        ),
      ),
    );
  }
}
