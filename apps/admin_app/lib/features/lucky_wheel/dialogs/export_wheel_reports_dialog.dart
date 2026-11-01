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

  static const List<String> _reportTypeOptions = [
    'Campaign Performance Summary',
    'Spin Audit & Reward Ledger',
    'Participant Engagement Report',
    'Coin Balance & Cost Distribution',
  ];

  static const List<String> _dateScopeOptions = [
    'Last 7 Days',
    'Last 30 Days',
    'This Month (October 2026)',
    'All Time',
  ];

  static const List<String> _formatOptions = [
    'CSV (.csv)',
    'Excel Spreadsheet (.xlsx)',
    'PDF Document (.pdf)',
  ];

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
    return AppModalDialog(
      title: 'Export Lucky Wheel Reports',
      subtitle: 'Download spin logs, reward disbursement, and user metrics',
      iconData: Icons.description_outlined,
      gradientColors: const [Color(0xFFE11D48), Color(0xFFFB7185)],
      maxWidth: 500,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        const SizedBox(width: 8),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Report Type
          AppDropdown<String>(
            label: 'Report Type',
            value: _reportType,
            items: _reportTypeOptions.map((opt) => AppDropdownItem(value: opt, label: opt)).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _reportType = val);
            },
          ),
          const SizedBox(height: 14),

          // Date Scope
          AppDropdown<String>(
            label: 'Time Period',
            value: _dateScope,
            items: _dateScopeOptions.map((opt) => AppDropdownItem(value: opt, label: opt)).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _dateScope = val);
            },
          ),
          const SizedBox(height: 14),

          // Format
          AppDropdown<String>(
            label: 'File Format',
            value: _format,
            items: _formatOptions.map((opt) => AppDropdownItem(value: opt, label: opt)).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _format = val);
            },
          ),
        ],
      ),
    );
  }
}
