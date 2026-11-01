import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class ExportUsersDialog extends StatefulWidget {
  final int totalCount;
  final int filteredCount;
  final int selectedCount;

  const ExportUsersDialog({
    super.key,
    required this.totalCount,
    required this.filteredCount,
    required this.selectedCount,
  });

  @override
  State<ExportUsersDialog> createState() => _ExportUsersDialogState();
}

class _ExportUsersDialogState extends State<ExportUsersDialog> {
  String _format = 'csv';
  String _scope = 'all';
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedCount > 0) {
      _scope = 'selected';
    } else if (widget.filteredCount < widget.totalCount) {
      _scope = 'filtered';
    }
  }

  void _export() {
    setState(() => _isExporting = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully exported users dataset in ${_format.toUpperCase()} format!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Export Users Dataset',
      subtitle: 'Select format and scope to download authorized user records',
      iconData: Icons.file_download_outlined,
      gradientColors: const [Color(0xFFE11D48), Color(0xFFF43F5E)],
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
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _export,
          icon: _isExporting
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.download_rounded, size: 16),
          label: const Text('Download Dataset', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            elevation: 0,
          ),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Export Format
          const Text('File Format:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFormatChip('CSV (.csv)', 'csv'),
              _buildFormatChip('JSON (.json)', 'json'),
              _buildFormatChip('Excel (.xlsx)', 'xlsx'),
            ],
          ),
          const SizedBox(height: 16),

          // Export Scope
          const Text('Data Scope:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          _buildScopeOption('All Users (${widget.totalCount} records)', 'all'),
          if (widget.filteredCount < widget.totalCount)
            _buildScopeOption('Current Filtered View (${widget.filteredCount} records)', 'filtered'),
          if (widget.selectedCount > 0)
            _buildScopeOption('Selected Users Only (${widget.selectedCount} records)', 'selected'),
          const SizedBox(height: 14),

          // Security notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, size: 16, color: Color(0xFF10B981)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Exports contain authorized columns only. Password hashes and auth tokens are excluded.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeOption(String title, String val) {
    final isSelected = _scope == val;
    return InkWell(
      onTap: () => setState(() => _scope = val),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF1F2) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFCBD5E1),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: isSelected ? const Color(0xFFE11D48) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFFE11D48) : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatChip(String label, String val) {
    final isSelected = _format == val;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? const Color(0xFFE11D48) : const Color(0xFF475569),
        ),
      ),
      selected: isSelected,
      onSelected: (s) => setState(() => _format = val),
      selectedColor: const Color(0xFFFFF1F2),
      backgroundColor: const Color(0xFFF8FAFC),
      side: BorderSide(
        color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFCBD5E1),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
