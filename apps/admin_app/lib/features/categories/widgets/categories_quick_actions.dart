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

  const CategoriesQuickActions({
    super.key,
    required this.onAddCategory,
    required this.onImportCategories,
    required this.onManageSubcategories,
    required this.onReorderCategories,
    required this.onDuplicateCategory,
    required this.onBulkActions,
    this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Quick Actions + Customize Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101A3A),
                    ),
                  ),
                ],
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onCustomize,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.settings_outlined, size: 12, color: Color(0xFF64748B)),
                      SizedBox(width: 4),
                      Text(
                        'Customize',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Action Buttons Row
          Builder(
            builder: (context) {
              final width = MediaQuery.sizeOf(context).width;
              final isSmall = width < 480;

              final actions = [
                _buildActionTile(
                  title: 'Add\nCategory',
                  icon: Icons.add_circle_outline_rounded,
                  iconBg: const Color(0xFF5636F5),
                  cardBg: const Color(0xFFF3F0FF),
                  onTap: onAddCategory,
                ),
                _buildActionTile(
                  title: 'Import\nCategories',
                  icon: Icons.file_upload_outlined,
                  iconBg: const Color(0xFF0284C7),
                  cardBg: const Color(0xFFEFF6FF),
                  onTap: onImportCategories,
                ),
                _buildActionTile(
                  title: 'Manage\nSubcategories',
                  icon: Icons.account_tree_outlined,
                  iconBg: const Color(0xFF10B981),
                  cardBg: const Color(0xFFECFDF5),
                  onTap: onManageSubcategories,
                ),
                _buildActionTile(
                  title: 'Reorder\nCategories',
                  icon: Icons.swap_vert_rounded,
                  iconBg: const Color(0xFFF59E0B),
                  cardBg: const Color(0xFFFFFBEB),
                  onTap: onReorderCategories,
                ),
                _buildActionTile(
                  title: 'Duplicate\nCategory',
                  icon: Icons.content_copy_rounded,
                  iconBg: const Color(0xFFF43F5E),
                  cardBg: const Color(0xFFFFF1F2),
                  onTap: onDuplicateCategory,
                ),
                _buildActionTile(
                  title: 'Bulk\nActions',
                  icon: Icons.tune_rounded,
                  iconBg: const Color(0xFFEC4899),
                  cardBg: const Color(0xFFFDF2F8),
                  onTap: onBulkActions,
                ),
              ];

              if (isSmall) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: actions
                        .map((a) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: SizedBox(width: 62, child: a),
                            ))
                        .toList(),
                  ),
                );
              }

              return Row(
                children: actions
                    .map((a) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.5),
                            child: a,
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required Color iconBg,
    required Color cardBg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: iconBg.withAlpha(20), width: 0.8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: iconBg.withAlpha(50),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 17),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
