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
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderXl),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Bulk Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101A3A),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

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
              const SizedBox(height: 8),

              for (final op in BulkOperation.values)
                InkWell(
                  onTap: () => setState(() => _selectedOperation = op),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: _selectedOperation == op ? const Color(0xFFFDF2F8) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedOperation == op ? const Color(0xFFEC4899) : const Color(0xFFE2E8F0),
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
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: op == BulkOperation.delete ? Colors.red : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedOperation == BulkOperation.delete
                          ? Colors.red
                          : const Color(0xFFEC4899),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () {
                      widget.onExecute(_selectedOperation);
                      Navigator.of(context).pop();
                    },
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
