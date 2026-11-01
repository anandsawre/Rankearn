import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/category_item.dart';

class ViewCategoryDialog extends StatelessWidget {
  final CategoryItem item;
  final VoidCallback onEdit;

  const ViewCategoryDialog({
    super.key,
    required this.item,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: item.name,
      subtitle: 'ID: ${item.id} • Slug: /${item.slug}',
      iconData: item.iconData,
      gradientColors: const [Color(0xFF5636F5), Color(0xFF2587F8)],
      maxWidth: 520,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('Close', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onEdit();
          },
          icon: const Icon(Icons.edit_rounded, size: 15),
          label: const Text('Edit Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5636F5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            elevation: 0,
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status and metadata chip
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.status.bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: item.status.color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Display Order: #${item.displayOrder}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
              ),
              const Spacer(),
              Text('Created: ${_formatDate(item.createdAt)}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 14),

          // Description
          const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Text(
              item.description.isNotEmpty ? item.description : 'No description provided.',
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.4),
            ),
          ),
          const SizedBox(height: 16),

          // Metrics Grid
          Row(
            children: [
              _buildMetricTile('Subcategories', item.subcategoriesCount.toString(), const Color(0xFF0284C7)),
              const SizedBox(width: 8),
              _buildMetricTile('Subjects', item.subjectsCount.toString(), const Color(0xFF8B5CF6)),
              const SizedBox(width: 8),
              _buildMetricTile('Tests', item.totalTests.toString(), const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _buildMetricTile('Questions', item.totalQuestions.toString(), const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }
}
