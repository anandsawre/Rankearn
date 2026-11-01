import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

enum BulkOperation {
  publish('Publish Selected'),
  draft('Set to Draft'),
  archive('Archive Selected'),
  assignTest('Assign to Test Series'),
  delete('Delete Selected');

  final String label;
  const BulkOperation(this.label);
}

class BulkActionsDialog extends StatefulWidget {
  final int selectedCount;
  final ValueChanged<BulkOperation> onExecute;

  const BulkActionsDialog({
    super.key,
    required this.selectedCount,
    required this.onExecute,
  });

  @override
  State<BulkActionsDialog> createState() => _BulkActionsDialogState();
}

class _BulkActionsDialogState extends State<BulkActionsDialog> {
  BulkOperation _selectedOperation = BulkOperation.publish;

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Bulk Actions',
      subtitle: '${widget.selectedCount} questions selected for batch operation',
      iconData: Icons.tune_rounded,
      gradientColors: const [Color(0xFFDB2777), Color(0xFFEC4899)],
      maxWidth: 480,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedOperation == BulkOperation.delete
                ? const Color(0xFFDC2626)
                : const Color(0xFFDB2777),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            elevation: 0,
          ),
          onPressed: () {
            widget.onExecute(_selectedOperation);
            Navigator.of(context).pop();
          },
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
                    '${widget.selectedCount} questions selected for bulk operation.',
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

          for (final op in BulkOperation.values)
            InkWell(
              onTap: () => setState(() => _selectedOperation = op),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: _selectedOperation == op ? const Color(0xFFFDF2F8) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedOperation == op ? const Color(0xFFEC4899) : const Color(0xFFCBD5E1),
                    width: _selectedOperation == op ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedOperation == op ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 18,
                      color: _selectedOperation == op ? const Color(0xFFEC4899) : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      op.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: op == BulkOperation.delete ? const Color(0xFFDC2626) : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
