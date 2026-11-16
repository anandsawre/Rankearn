import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class FeedbackDetailDialog extends StatelessWidget {
  final Map<String, dynamic> feedback;
  final VoidCallback onReply;

  const FeedbackDetailDialog({
    super.key,
    required this.feedback,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final rating = (feedback['rating'] as num?)?.toInt() ?? 5;
    final name = feedback['name']?.toString() ?? 'Candidate';
    final email = feedback['email']?.toString() ?? 'user@rankearn.app';
    final uid = feedback['uid']?.toString() ?? 'UID: ${feedback['id'] ?? 'RK-102'}';
    final comment = feedback['comment']?.toString() ?? '';
    final type = feedback['type']?.toString() ?? 'Feedback';
    final feature = feedback['feature']?.toString() ?? 'Mock Test';
    final date = feedback['date']?.toString() ?? 'Recent';

    return AppModalDialog(
      title: 'Feedback Details',
      subtitle: '$uid • Submitted $date',
      iconData: Icons.rate_review_rounded,
      maxWidth: 540,
      actions: [
        AppButton.adminSecondary(
          label: 'Close',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        AppButton.adminPrimary(
          label: 'Reply to User',
          leadingIcon: const Icon(Icons.reply_rounded, size: 16),
          onPressed: () {
            Navigator.pop(context);
            onReply();
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.adminPurpleLight,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.adminPurple),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.adminCardTitle),
                    Text(email, style: AppTypography.adminTableSecondary),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (starIdx) {
                  return Icon(
                    starIdx < rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 18,
                    color: const Color(0xFFF59E0B),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.adminPurpleLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Type: $type', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.adminPurple)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Module: $feature', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Candidate Comment', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.adminBackground,
              borderRadius: AppRadii.adminControl,
              border: Border.all(color: AppColors.adminBorder),
            ),
            child: Text(
              comment.isNotEmpty ? comment : 'No comment text provided.',
              style: const TextStyle(fontSize: 13, color: AppColors.adminPrimaryText, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
