import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

enum BulkCategoryActionType {
  makeActive('Mark as Active', Icons.check_circle_outline_rounded, Color(0xFF10B981)),
  makeDraft('Mark as Draft', Icons.edit_note_rounded, Color(0xFFF59E0B)),
  makeArchived('Mark as Archived', Icons.archive_outlined, Color(0xFF8B5CF6)),
  delete('Delete Selected', Icons.delete_outline_rounded, Color(0xFFF43F5E));

  final String label;
  final IconData icon;
  final Color color;

  const BulkCategoryActionType(this.label, this.icon, this.color);
}

class BulkCategoriesActionDialog extends StatefulWidget {
  final int selectedCount;
  final ValueChanged<BulkCategoryActionType> onApplyAction;

  const BulkCategoriesActionDialog({
    super.key,
    required this.selectedCount,
    required this.onApplyAction,
  });

  @override
  State<BulkCategoriesActionDialog> createState() => _BulkCategoriesActionDialogState();
}

class _BulkCategoriesActionDialogState extends State<BulkCategoriesActionDialog> {
  BulkCategoryActionType _selected = BulkCategoryActionType.makeActive;

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Bulk Exam Actions',
      subtitle: '${widget.selectedCount} target exams selected for batch operation',
      iconData: Icons.tune_rounded,
      gradientColors: const [Color(0xFFDB2777), Color(0xFFEC4899)],
      maxWidth: 480,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            widget.onApplyAction(_selected);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _selected.color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            elevation: 0,
          ),
          child: const Text('Apply Action', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF2F8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFBCFE8)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFFEC4899), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.selectedCount} target exams selected for bulk update.',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9D174D)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Operation to Apply:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 10),

          ...BulkCategoryActionType.values.map((action) {
            final isSel = _selected == action;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: isSel ? action.color.withAlpha(15) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSel ? action.color : const Color(0xFFCBD5E1),
                  width: isSel ? 1.4 : 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => setState(() => _selected = action),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Icon(action.icon, color: action.color, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            action.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        Icon(
                          isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 18,
                          color: isSel ? action.color : const Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
