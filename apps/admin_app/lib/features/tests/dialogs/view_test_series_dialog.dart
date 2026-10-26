import 'package:flutter/material.dart';
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: item.iconColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF101A3A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.subject,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: item.iconColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),
            const Text(
              'Description & Syllabus',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoTile('Total Tests', '${item.totalTests} Tests'),
                _buildInfoTile(
                  'Questions',
                  '${item.totalQuestions} MCQs',
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
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoTile('Enrollments', '${item.enrollments} Students'),
                _buildInfoTile('Status', item.status.label),
                _buildInfoTile('Created On', _formatDate(item.createdAt)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        if (onViewQuestions != null)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5636F5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            icon: const Icon(Icons.format_list_bulleted_rounded, size: 16),
            label: Text('View Questions (${item.totalQuestions})', style: const TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () {
              Navigator.pop(context);
              onViewQuestions!();
            },
          ),
        if (onAddQuestion != null)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5636F5),
              side: const BorderSide(color: Color(0xFF5636F5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            icon: const Icon(Icons.post_add_rounded, size: 16),
            label: const Text('Add Questions', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () {
              Navigator.pop(context);
              onAddQuestion!();
            },
          ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF64748B),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: onTap != null ? const Color(0xFFF5F6FF) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: onTap != null ? const Color(0xFFC7D2FE) : const Color(0xFFE2E8F0)),
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
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: onTap != null ? const Color(0xFF5636F5) : const Color(0xFF94A3B8),
                    ),
                  ),
                  if (onTap != null)
                    const Icon(Icons.arrow_forward_rounded, size: 10, color: Color(0xFF5636F5)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: onTap != null ? const Color(0xFF5636F5) : const Color(0xFF101A3A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[dt.month - 1];
    final d = dt.day.toString().padLeft(2, '0');
    return '$m $d, ${dt.year}';
  }
}
