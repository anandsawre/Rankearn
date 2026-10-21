import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class ExportWheelReportsDialog extends StatefulWidget {
  const ExportWheelReportsDialog({super.key});

  @override
  State<ExportWheelReportsDialog> createState() => _ExportWheelReportsDialogState();
}

class _ExportWheelReportsDialogState extends State<ExportWheelReportsDialog> {
  String _reportType = 'Campaign Performance Summary';
  String _format = 'CSV (.csv)';
  String _dateScope = 'Last 30 Days';

  void _export() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting $_reportType ($_format) for $_dateScope... Download will begin shortly.'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.description_outlined, color: Color(0xFFE11D48), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Export Lucky Wheel Reports',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF101A3A),
                            ),
                          ),
                          Text(
                            'Download spin logs, reward disbursement, and user metrics',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 14),

              // Report Type
              const Text('Report Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _reportType,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Campaign Performance Summary', child: Text('Campaign Performance Summary')),
                  DropdownMenuItem(value: 'Spin Audit & Reward Ledger', child: Text('Spin Audit & Reward Ledger')),
                  DropdownMenuItem(value: 'Participant Engagement Report', child: Text('Participant Engagement Report')),
                  DropdownMenuItem(value: 'Coin Balance & Cost Distribution', child: Text('Coin Balance & Cost Distribution')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _reportType = val);
                },
              ),
              const SizedBox(height: 12),

              // Date Scope
              const Text('Time Period', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _dateScope,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days')),
                  DropdownMenuItem(value: 'Last 30 Days', child: Text('Last 30 Days')),
                  DropdownMenuItem(value: 'This Month (October 2026)', child: Text('This Month (October 2026)')),
                  DropdownMenuItem(value: 'All Time', child: Text('All Time')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _dateScope = val);
                },
              ),
              const SizedBox(height: 12),

              // Format
              const Text('File Format', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _format,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: 'CSV (.csv)', child: Text('CSV (.csv)')),
                  DropdownMenuItem(value: 'Excel Spreadsheet (.xlsx)', child: Text('Excel Spreadsheet (.xlsx)')),
                  DropdownMenuItem(value: 'PDF Document (.pdf)', child: Text('PDF Document (.pdf)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _format = val);
                },
              ),
              const Spacer(),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _export,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5636F5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: const Text('Download Report'),
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
