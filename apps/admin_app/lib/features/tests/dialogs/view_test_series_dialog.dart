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
    return AppModalDialog(
      title: item.title,
      subtitle: item.subject,
      iconData: item.icon,
      gradientColors: const [Color(0xFFFF9500), Color(0xFFF59E0B)],
      maxWidth: 540,
      actions: [
        if (onViewQuestions != null)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9500),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              elevation: 0,
            ),
            icon: const Icon(Icons.format_list_bulleted_rounded, size: 16),
            label: Text('View Questions (${item.totalQuestions})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            icon: const Icon(Icons.post_add_rounded, size: 16),
            label: const Text('Add Questions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
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
          child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Description & Syllabus',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          Text(
            item.description.isNotEmpty ? item.description : 'No description provided.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), height: 1.45),
          ),
          const SizedBox(height: 18),
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
          const SizedBox(height: 10),
          Row(
            children: [
              _buildInfoTile('Enrollments', '${item.enrollments} Students'),
              _buildInfoTile('Status', item.status.label),
              _buildInfoTile('Created On', _formatDate(item.createdAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: onTap != null ? const Color(0xFF5636F5) : const Color(0xFF94A3B8),
                    ),
                  ),
                  if (onTap != null)
                    const Icon(Icons.arrow_forward_rounded, size: 10, color: Color(0xFF5636F5)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
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
