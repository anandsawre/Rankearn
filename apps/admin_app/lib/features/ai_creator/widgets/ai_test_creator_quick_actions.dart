import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class AiTestCreatorQuickActions extends StatelessWidget {
  final VoidCallback onGenerateTest;
  final VoidCallback onCustomPrompt;
  final VoidCallback onManageTemplates;
  final VoidCallback onSavedTests;
  final VoidCallback onQuestionBank;
  final VoidCallback onExportTest;
  final VoidCallback? onCustomize;
  final double? height;

  const AiTestCreatorQuickActions({
    super.key,
    required this.onGenerateTest,
    required this.onCustomPrompt,
    required this.onManageTemplates,
    required this.onSavedTests,
    required this.onQuestionBank,
    required this.onExportTest,
    this.onCustomize,
    this.height = 124,
  });

  @override
  Widget build(BuildContext context) {
    return QuickActionsCard(
      height: height,
      compact: true,
      onCustomize: onCustomize,
      actions: [
        QuickActionItemData(
          label: 'Generate\nTest',
          icon: Icons.auto_awesome_rounded,
          iconColor: const Color(0xFF5636F5),
          cardColor: const Color(0xFFF3F0FF),
          onTap: onGenerateTest,
        ),
        QuickActionItemData(
          label: 'Custom\nPrompt',
          icon: Icons.edit_note_rounded,
          iconColor: const Color(0xFF0084FF),
          cardColor: const Color(0xFFEFF6FF),
          onTap: onCustomPrompt,
        ),
        QuickActionItemData(
          label: 'Manage\nTemplates',
          icon: Icons.folder_outlined,
          iconColor: const Color(0xFF00C48C),
          cardColor: const Color(0xFFECFDF5),
          onTap: onManageTemplates,
        ),
        QuickActionItemData(
          label: 'Saved\nTests',
          icon: Icons.bookmark_outline_rounded,
          iconColor: const Color(0xFFFF9F0A),
          cardColor: const Color(0xFFFFFBEB),
          onTap: onSavedTests,
        ),
        QuickActionItemData(
          label: 'Question\nBank',
          icon: Icons.storage_rounded,
          iconColor: const Color(0xFFF04483),
          cardColor: const Color(0xFFFFF1F2),
          onTap: onQuestionBank,
        ),
        QuickActionItemData(
          label: 'Export\nTest',
          icon: Icons.ios_share_rounded,
          iconColor: const Color(0xFFF43F5E),
          cardColor: const Color(0xFFFFF1F2),
          onTap: onExportTest,
        ),
      ],
    );
  }
}
