import 'package:flutter/material.dart';

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899).withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.tune_rounded, color: Color(0xFFEC4899), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Bulk Actions',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101A3A),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFE2E8F0)),

              Text(
                'Apply operation to ${widget.selectedCount} selected categories:',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 12),

              ...BulkCategoryActionType.values.map((action) {
                final isSel = _selected == action;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isSel ? action.color.withAlpha(12) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSel ? action.color : const Color(0xFFE2E8F0),
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
                                  fontSize: 12.5,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            // ignore: deprecated_member_use
                            Radio<BulkCategoryActionType>(
                              value: action,
                              // ignore: deprecated_member_use
                              groupValue: _selected,
                              activeColor: action.color,
                              // ignore: deprecated_member_use
                              onChanged: (val) {
                                if (val != null) setState(() => _selected = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
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
                    ),
                    child: const Text('Apply Action'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
