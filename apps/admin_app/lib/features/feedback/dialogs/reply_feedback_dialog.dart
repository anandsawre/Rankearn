import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class ReplyFeedbackDialog extends StatefulWidget {
  final Map<String, dynamic> feedback;
  final ValueChanged<String> onSendReply;

  const ReplyFeedbackDialog({
    super.key,
    required this.feedback,
    required this.onSendReply,
  });

  @override
  State<ReplyFeedbackDialog> createState() => _ReplyFeedbackDialogState();
}

class _ReplyFeedbackDialogState extends State<ReplyFeedbackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _replyController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    widget.onSendReply(text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.feedback['name']?.toString() ?? 'Candidate';

    return AppModalDialog(
      title: 'Reply to $name',
      subtitle: 'Send official feedback acknowledgement or clarification email',
      iconData: Icons.reply_rounded,
      maxWidth: 540,
      actions: [
        AppModalDialog.cancelButton(context, label: 'Cancel'),
        AppModalDialog.primaryButton(
          onPressed: _isSending ? null : _submit,
          icon: const Icon(Icons.send_rounded, size: 16),
          child: Text(
            _isSending ? 'Sending...' : 'Send Email Reply',
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: AppRadii.adminCardInner,
                border: Border.all(color: AppColors.adminBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.format_quote_rounded, size: 18, color: AppColors.adminSecondaryText),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      widget.feedback['comment']?.toString() ?? '',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.adminSecondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Admin Response Message *', style: AppTypography.adminFieldLabelSmall),
            const SizedBox(height: AppSpacing.xs),
            AppModalDialog.textField(
              controller: _replyController,
              hint: 'Type your official response to candidate...',
              maxLines: 4,
              minLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter response message' : null,
            ),
          ],
        ),
      ),
    );
  }
}
