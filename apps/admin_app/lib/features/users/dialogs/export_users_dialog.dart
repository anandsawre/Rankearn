import 'package:flutter/material.dart';

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.file_download_outlined, color: Color(0xFFF43F5E), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Export Users Dataset',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101A3A),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Export Format
              const Text('File Format:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildFormatChip('CSV (.csv)', 'csv'),
                  const SizedBox(width: 8),
                  _buildFormatChip('JSON (.json)', 'json'),
                  const SizedBox(width: 8),
                  _buildFormatChip('Excel (.xlsx)', 'xlsx'),
                ],
              ),
              const SizedBox(height: 16),

              // Export Scope
              const Text('Data Scope:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              const SizedBox(height: 8),
              // ignore: deprecated_member_use
              RadioListTile<String>(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('All Users (${widget.totalCount} records)', style: const TextStyle(fontSize: 13)),
                value: 'all',
                // ignore: deprecated_member_use
                groupValue: _scope,
                activeColor: const Color(0xFF5636F5),
                // ignore: deprecated_member_use
                onChanged: (v) => setState(() => _scope = v!),
              ),
              if (widget.filteredCount < widget.totalCount)
                // ignore: deprecated_member_use
                RadioListTile<String>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('Current Filtered View (${widget.filteredCount} records)', style: const TextStyle(fontSize: 13)),
                  value: 'filtered',
                  // ignore: deprecated_member_use
                  groupValue: _scope,
                  activeColor: const Color(0xFF5636F5),
                  // ignore: deprecated_member_use
                  onChanged: (v) => setState(() => _scope = v!),
                ),
              if (widget.selectedCount > 0)
                // ignore: deprecated_member_use
                RadioListTile<String>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('Selected Users Only (${widget.selectedCount} records)', style: const TextStyle(fontSize: 13)),
                  value: 'selected',
                  // ignore: deprecated_member_use
                  groupValue: _scope,
                  activeColor: const Color(0xFF5636F5),
                  // ignore: deprecated_member_use
                  onChanged: (v) => setState(() => _scope = v!),
                ),
              const SizedBox(height: 12),

              // Security notice
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
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
              const SizedBox(height: 22),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isExporting ? null : _export,
                    icon: _isExporting
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Download Dataset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5636F5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatChip(String label, String val) {
    final isSelected = _format == val;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
      selected: isSelected,
      onSelected: (s) => setState(() => _format = val),
      selectedColor: const Color(0xFFEDE9FE),
    );
  }
}
