import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Rankearn Quick Actions Card for the Tests tab.
/// Uses the reusable QuickActionsCard from the design system.
class TestSeriesQuickActions extends StatelessWidget {
  final VoidCallback onCreateTestSeries;
  final VoidCallback onAddTestPaper;
  final VoidCallback onManageSubjects;
  final VoidCallback onImportTests;
  final VoidCallback onAiGenerate;
  final double? height;

  const TestSeriesQuickActions({
    super.key,
    required this.onCreateTestSeries,
    required this.onAddTestPaper,
    required this.onManageSubjects,
    required this.onImportTests,
    required this.onAiGenerate,
    this.height = 124,
  });

  @override
  Widget build(BuildContext context) {
    return QuickActionsCard(
      height: height,
      compact: true,
      actions: [
        QuickActionItemData(
          label: 'Create\nTest Series',
          icon: Icons.add_circle_outline_rounded,
          iconColor: const Color(0xFF5C4EFA),
          cardColor: const Color(0xFFF5F6FF),
          onTap: onCreateTestSeries,
        ),
        QuickActionItemData(
          label: 'Add\nTest Paper',
          icon: Icons.description_outlined,
          iconColor: const Color(0xFF0084FF),
          cardColor: const Color(0xFFDBEAFE),
          onTap: onAddTestPaper,
        ),
        QuickActionItemData(
          label: 'Manage\nSubjects',
          icon: Icons.folder_outlined,
          iconColor: const Color(0xFF00B368),
          cardColor: const Color(0xFFD1FAE5),
          onTap: onManageSubjects,
        ),
        QuickActionItemData(
          label: 'Import\nTests',
          icon: Icons.cloud_upload_outlined,
          iconColor: const Color(0xFFFF9500),
          cardColor: const Color(0xFFFFFBEB),
          onTap: onImportTests,
        ),
        QuickActionItemData(
          label: 'AI Generate\nTest Series',
          icon: Icons.auto_awesome_rounded,
          iconColor: const Color(0xFFFF3385),
          cardColor: const Color(0xFFFCE7F3),
          onTap: onAiGenerate,
        ),
      ],
    );
  }
}
