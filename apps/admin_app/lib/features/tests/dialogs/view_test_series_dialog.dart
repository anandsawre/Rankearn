import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/test_series_item.dart';

class ViewTestSeriesDialog extends StatelessWidget {
  final TestSeriesItem item;
  final VoidCallback? onAddQuestion;
  final VoidCallback? onViewQuestions;

  const ViewTestSeriesDialog({
    super.key,
    required this.item,
    this.onAddQuestion,
    this.onViewQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final studentUnit = item.enrollments == 1 ? 'Student' : 'Students';
    final testUnit = item.totalTests == 1 ? 'Test' : 'Tests';
    final mcqUnit = item.totalQuestions == 1 ? 'MCQ' : 'MCQs';

    return AppModalDialog(
      title: item.title,
      subtitle: item.subject,
      iconData: item.icon,
      maxWidth: 540,
      actions: [
        if (onViewQuestions != null)
          AppModalDialog.primaryButton(
            icon: const Icon(Icons.format_list_bulleted_rounded, size: 16),
            child: Text(
              'View Questions (${item.totalQuestions})',
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              onViewQuestions!();
            },
          ),
        if (onAddQuestion != null)
          AppModalDialog.secondaryButton(
            borderColor: AppColors.brandPurple,
            foregroundColor: AppColors.brandPurple,
            icon: const Icon(Icons.post_add_rounded, size: 16),
            child: const Text(
              'Add Questions',
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              onAddQuestion!();
            },
          ),
        AppModalDialog.cancelButton(context, label: 'Close'),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Description & Syllabus',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.description.isNotEmpty
                ? item.description
                : 'No description provided.',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildInfoTile('Total Tests', '${item.totalTests} $testUnit'),
              _buildInfoTile(
                'Questions',
                '${item.totalQuestions} $mcqUnit',
                onTap: onViewQuestions != null
                    ? () {
                        Navigator.pop(context);
                        onViewQuestions!();
                      }
                    : null,
              ),
              _buildInfoTile('Price', '₹${item.priceInr}'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildInfoTile('Enrollments', '${item.enrollments} $studentUnit'),
              _buildInfoTile('Status', item.status.label),
              _buildInfoTile('Created On', _formatDate(item.createdAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {VoidCallback? onTap}) {
    final isInteractive = onTap != null;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.borderSm,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isInteractive
                ? AppColors.brandPurpleLight
                : AppColors.surfaceSubtle,
            borderRadius: AppRadii.borderSm,
            border: Border.all(
              color: isInteractive
                  ? AppColors.brandPurple.withValues(alpha: 0.3)
                  : AppColors.borderSubtle,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isInteractive
                          ? AppColors.brandPurple
                          : AppColors.textMuted,
                    ),
                  ),
                  if (isInteractive)
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 10,
                      color: AppColors.brandPurple,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isInteractive
                      ? AppColors.brandPurple
                      : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[dt.month - 1];
    final d = dt.day.toString().padLeft(2, '0');
    return '$m $d, ${dt.year}';
  }
}
