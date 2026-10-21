import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class QuestionsQuickActions extends StatelessWidget {
  final VoidCallback onAddQuestion;
  final VoidCallback onImportQuestions;
  final VoidCallback onAiGenerateQuestions;
  final VoidCallback onManageQuestionSets;
  final VoidCallback onDuplicateQuestions;
  final VoidCallback onBulkActions;
  final VoidCallback? onCustomize;
  final double? height;

  const QuestionsQuickActions({
    super.key,
    required this.onAddQuestion,
    required this.onImportQuestions,
    required this.onAiGenerateQuestions,
    required this.onManageQuestionSets,
    required this.onDuplicateQuestions,
    required this.onBulkActions,
    this.onCustomize,
    this.height = 124,
  });

  @override
  Widget build(BuildContext context) {
    return QuickActionsCard(
      onCustomize: onCustomize,
      height: height,
      compact: true,
      actions: [
        QuickActionItemData(
          label: 'Add\nQuestion',
          icon: Icons.add_circle_outline_rounded,
          iconColor: const Color(0xFF5636F5),
          cardColor: const Color(0xFFF5F3FF),
          onTap: onAddQuestion,
        ),
        QuickActionItemData(
          label: 'Import\nQuestions',
          icon: Icons.file_upload_outlined,
          iconColor: const Color(0xFF0284C7),
          cardColor: const Color(0xFFDBEAFE),
          onTap: onImportQuestions,
        ),
        QuickActionItemData(
          label: 'AI Generate\nQuestions',
          icon: Icons.auto_awesome,
          iconColor: const Color(0xFF10B981),
          cardColor: const Color(0xFFD1FAE5),
          onTap: onAiGenerateQuestions,
        ),
        QuickActionItemData(
          label: 'Manage\nQuestion Sets',
          icon: Icons.folder_outlined,
          iconColor: const Color(0xFFF59E0B),
          cardColor: const Color(0xFFFFFBEB),
          onTap: onManageQuestionSets,
        ),
        QuickActionItemData(
          label: 'Duplicate\nQuestions',
          icon: Icons.content_copy_rounded,
          iconColor: const Color(0xFFF43F5E),
          cardColor: const Color(0xFFFCE7F3),
          onTap: onDuplicateQuestions,
        ),
        QuickActionItemData(
          label: 'Bulk\nActions',
          icon: Icons.tune_rounded,
          iconColor: const Color(0xFFEC4899),
          cardColor: const Color(0xFFFDF2F8),
          onTap: onBulkActions,
        ),
      ],
    );
  }
}
