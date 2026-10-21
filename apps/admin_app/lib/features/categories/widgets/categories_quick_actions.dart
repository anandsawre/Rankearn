import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class CategoriesQuickActions extends StatelessWidget {
  final VoidCallback onAddCategory;
  final VoidCallback onImportCategories;
  final VoidCallback onManageSubcategories;
  final VoidCallback onReorderCategories;
  final VoidCallback onDuplicateCategory;
  final VoidCallback onBulkActions;
  final VoidCallback? onCustomize;
  final double? height;

  const CategoriesQuickActions({
    super.key,
    required this.onAddCategory,
    required this.onImportCategories,
    required this.onManageSubcategories,
    required this.onReorderCategories,
    required this.onDuplicateCategory,
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
          label: 'Add\nCategory',
          icon: Icons.add_circle_outline_rounded,
          iconColor: const Color(0xFF5636F5),
          cardColor: const Color(0xFFF5F3FF),
          onTap: onAddCategory,
        ),
        QuickActionItemData(
          label: 'Import\nCategories',
          icon: Icons.file_upload_outlined,
          iconColor: const Color(0xFF0284C7),
          cardColor: const Color(0xFFDBEAFE),
          onTap: onImportCategories,
        ),
        QuickActionItemData(
          label: 'Manage\nSubcategories',
          icon: Icons.account_tree_outlined,
          iconColor: const Color(0xFF10B981),
          cardColor: const Color(0xFFD1FAE5),
          onTap: onManageSubcategories,
        ),
        QuickActionItemData(
          label: 'Reorder\nCategories',
          icon: Icons.swap_vert_rounded,
          iconColor: const Color(0xFFF59E0B),
          cardColor: const Color(0xFFFFFBEB),
          onTap: onReorderCategories,
        ),
        QuickActionItemData(
          label: 'Duplicate\nCategory',
          icon: Icons.content_copy_rounded,
          iconColor: const Color(0xFFF43F5E),
          cardColor: const Color(0xFFFCE7F3),
          onTap: onDuplicateCategory,
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
