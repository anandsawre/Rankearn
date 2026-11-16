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
      maxWidth: 560,
      actions: [
        AppModalDialog.cancelButton(context, label: 'Close'),
        AppModalDialog.primaryButton(
          onPressed: () {
            Navigator.pop(context);
            onReply();
          },
          icon: const Icon(Icons.reply_rounded, size: 16),
          child: const Text(
            'Reply to User',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
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
              const SizedBox(width: AppSpacing.md),
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
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.adminPurpleLight,
                  borderRadius: AppRadii.badge,
                ),
                child: Text(
                  'Type: $type',
                  style: AppTypography.adminBadge.copyWith(color: AppColors.adminPurple),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: AppRadii.badge,
                ),
                child: Text(
                  'Module: $feature',
                  style: AppTypography.adminBadge.copyWith(color: const Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Candidate Comment', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: AppRadii.adminCardInner,
              border: Border.all(color: AppColors.adminBorder),
            ),
            child: Text(
              comment.isNotEmpty ? comment : 'No comment text provided.',
              style: AppTypography.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.adminPrimaryText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
