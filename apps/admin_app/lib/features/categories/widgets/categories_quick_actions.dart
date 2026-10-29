import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Quick Actions panel for Categories & Target Exams screen.
/// Mapped accurately to Option 1 hierarchy:
/// Target Exam (Level 1) -> Subject (Level 2) -> Chapter (Level 3) -> Topic (Level 4)
class CategoriesQuickActions extends StatelessWidget {
  final VoidCallback onAddExam;
  final VoidCallback onAddSubject;
  final VoidCallback onManageChapters;
  final VoidCallback onImportSyllabus;
  final VoidCallback onReorderExams;
  final VoidCallback onDuplicateExam;
  final VoidCallback onBulkActions;
  final VoidCallback? onCustomize;
  final double? height;

  const CategoriesQuickActions({
    super.key,
    required this.onAddExam,
    required this.onAddSubject,
    required this.onManageChapters,
    required this.onImportSyllabus,
    required this.onReorderExams,
    required this.onDuplicateExam,
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
        // Level 1 Root: Add Target Exam
        QuickActionItemData(
          label: 'Add Target\nExam',
          icon: Icons.explore_outlined,
          iconColor: const Color(0xFF5636F5),
          cardColor: const Color(0xFFF5F3FF),
          onTap: onAddExam,
        ),
        // Level 2: Add Subject
        QuickActionItemData(
          label: 'Add\nSubject',
          icon: Icons.menu_book_rounded,
          iconColor: const Color(0xFF2563EB),
          cardColor: const Color(0xFFEFF6FF),
          onTap: onAddSubject,
        ),
        // Level 3: Manage Chapters
        QuickActionItemData(
          label: 'Manage\nChapters',
          icon: Icons.account_tree_outlined,
          iconColor: const Color(0xFF10B981),
          cardColor: const Color(0xFFD1FAE5),
          onTap: onManageChapters,
        ),
        // Import Curriculum / Syllabus
        QuickActionItemData(
          label: 'Import\nSyllabus',
          icon: Icons.file_upload_outlined,
          iconColor: const Color(0xFF0284C7),
          cardColor: const Color(0xFFDBEAFE),
          onTap: onImportSyllabus,
        ),
        // Reorder Target Exams
        QuickActionItemData(
          label: 'Reorder\nExams',
          icon: Icons.swap_vert_rounded,
          iconColor: const Color(0xFFF59E0B),
          cardColor: const Color(0xFFFFFBEB),
          onTap: onReorderExams,
        ),
        // Duplicate Exam
        QuickActionItemData(
          label: 'Duplicate\nExam',
          icon: Icons.content_copy_rounded,
          iconColor: const Color(0xFFF43F5E),
          cardColor: const Color(0xFFFCE7F3),
          onTap: onDuplicateExam,
        ),
        // Bulk Actions
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
