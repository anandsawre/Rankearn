import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import '../models/user_management_item.dart';

class ExportUsersDialog extends StatefulWidget {
  final List<UserManagementItem> allUsers;
  final List<UserManagementItem> filteredUsers;
  final Set<String> selectedIds;

  const ExportUsersDialog({
    super.key,
    required this.allUsers,
    required this.filteredUsers,
    required this.selectedIds,
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
    if (widget.selectedIds.isNotEmpty) {
      _scope = 'selected';
    } else if (widget.filteredUsers.length < widget.allUsers.length) {
      _scope = 'filtered';
    }
  }

  List<UserManagementItem> get _targetRecords {
    switch (_scope) {
      case 'selected':
        return widget.allUsers.where((u) => widget.selectedIds.contains(u.id)).toList();
      case 'filtered':
        return widget.filteredUsers;
      case 'all':
      default:
        return widget.allUsers;
    }
  }

  String _escapeCsv(String value) {
    final clean = value.replaceAll('"', '""');
    return '"$clean"';
  }

  Future<void> _export() async {
    final records = _targetRecords;
    if (records.isEmpty) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No user records available in the selected scope.'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }

    setState(() => _isExporting = true);

    late final String payload;
    if (_format == 'json') {
      payload = const JsonEncoder.withIndent('  ').convert(
        records
            .map(
              (u) => {
                'id': u.id,
                'name': u.name,
                'email': u.email,
                'phone': u.phone,
                'role': u.role.label,
                'status': u.status.label,
                'coins': u.coins,
                'enrollments': u.enrollmentsCount,
                'tests_attempted': u.testsAttemptedCount,
                'joined_at': u.joinedAt.toIso8601String(),
              },
            )
            .toList(),
      );
    } else {
      final buffer = StringBuffer()
        ..writeln('id,name,email,phone,role,status,coins,enrollments,tests_attempted,joined_at');
      for (final u in records) {
        buffer.writeln([
          _escapeCsv(u.id),
          _escapeCsv(u.name),
          _escapeCsv(u.email),
          _escapeCsv(u.phone ?? ''),
          _escapeCsv(u.role.label),
          _escapeCsv(u.status.label),
          u.coins,
          u.enrollmentsCount,
          u.testsAttemptedCount,
          _escapeCsv(u.joinedAt.toIso8601String()),
        ].join(','));
      }
      payload = buffer.toString();
    }

    await Clipboard.setData(ClipboardData(text: payload));
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied ${records.length} user(s) as ${_format.toUpperCase()} to clipboard!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Export Users Dataset',
      subtitle: 'Copy live Supabase user records in CSV or JSON format',
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
              : const Icon(Icons.copy_rounded, size: 16),
          label: const Text('Copy Dataset', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
          const Text('File Format:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFormatChip('CSV (.csv)', 'csv'),
              _buildFormatChip('JSON (.json)', 'json'),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Data Scope:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          _buildScopeOption('All Users (${widget.allUsers.length} records)', 'all'),
          if (widget.filteredUsers.length < widget.allUsers.length)
            _buildScopeOption('Current Filtered View (${widget.filteredUsers.length} records)', 'filtered'),
          if (widget.selectedIds.isNotEmpty)
            _buildScopeOption('Selected Users Only (${widget.selectedIds.length} records)', 'selected'),
          const SizedBox(height: 14),
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
                    'Exports contain authorized profile columns only. Password hashes and auth tokens are excluded.',
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
