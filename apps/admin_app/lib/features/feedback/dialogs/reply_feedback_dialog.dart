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
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.feedback['name']?.toString() ?? 'Candidate';

    return AppModalDialog(
      title: 'Reply to $name',
      subtitle: 'Send official feedback acknowledgement or clarification email',
      iconData: Icons.reply_rounded,
      maxWidth: 520,
      actions: [
        AppButton.adminSecondary(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        AppButton.adminPrimary(
          label: 'Send Email Reply',
          leadingIcon: const Icon(Icons.send_rounded, size: 16),
          onPressed: () {
            final text = _replyController.text.trim();
            if (text.isNotEmpty) {
              widget.onSendReply(text);
              Navigator.pop(context);
            }
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.adminBackground,
              borderRadius: AppRadii.adminControl,
              border: Border.all(color: AppColors.adminBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.format_quote_rounded, size: 18, color: AppColors.adminSecondaryText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.feedback['comment']?.toString() ?? '',
                    style: const TextStyle(fontSize: 12, color: AppColors.adminSecondaryText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('Admin Response Message *', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppTextField(
            controller: _replyController,
            hintText: 'Type your official response to candidate...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}
