import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/user_management_item.dart';

class ImportUsersDialog extends StatefulWidget {
  final ValueChanged<List<UserManagementItem>> onImport;

  const ImportUsersDialog({super.key, required this.onImport});

  @override
  State<ImportUsersDialog> createState() => _ImportUsersDialogState();
}

class _ImportUsersDialogState extends State<ImportUsersDialog> {
  final TextEditingController _inputCtrl = TextEditingController();
  List<UserManagementItem> _previewRows = [];
  String? _parseError;

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  void _parseInput() {
    final raw = _inputCtrl.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _previewRows = [];
        _parseError = 'Paste CSV or JSON user records first.';
      });
      return;
    }

    try {
      final parsed = <UserManagementItem>[];
      if (raw.startsWith('[')) {
        final decoded = jsonDecode(raw);
        if (decoded is! List) {
          throw const FormatException('JSON root must be an array.');
        }
        for (int i = 0; i < decoded.length; i++) {
          final row = decoded[i];
          if (row is! Map) continue;
          final email = (row['email'] ?? '').toString().trim();
          final name = (row['name'] ?? row['full_name'] ?? '').toString().trim();
          if (email.isEmpty || name.isEmpty) continue;
          parsed.add(
            UserManagementItem(
              id: row['id']?.toString() ?? '',
              rowNumber: i + 1,
              name: name,
              email: email,
              phone: row['phone']?.toString().trim(),
              role: UserRole.fromString(row['role']?.toString()),
              status: UserStatus.fromString(row['status']?.toString()),
              joinedAt: DateTime.now(),
            ),
          );
        }
      } else {
        final lines = raw
            .split(RegExp(r'\r?\n'))
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();
        if (lines.length < 2) {
          throw const FormatException('CSV must include a header row and at least one data row.');
        }
        final headers = lines.first.split(',').map((h) => h.trim().toLowerCase()).toList();
        final nameIdx = headers.indexWhere((h) => h == 'name' || h == 'full_name');
        final emailIdx = headers.indexOf('email');
        final phoneIdx = headers.indexOf('phone');
        final roleIdx = headers.indexOf('role');
        final statusIdx = headers.indexOf('status');
        if (nameIdx == -1 || emailIdx == -1) {
          throw const FormatException('CSV header must contain name (or full_name) and email columns.');
        }

        for (int i = 1; i < lines.length; i++) {
          final cols = lines[i].split(',').map((c) => c.trim()).toList();
          if (cols.length <= nameIdx || cols.length <= emailIdx) continue;
          final name = cols[nameIdx];
          final email = cols[emailIdx];
          if (name.isEmpty || email.isEmpty) continue;
          parsed.add(
            UserManagementItem(
              id: '',
              rowNumber: parsed.length + 1,
              name: name,
              email: email,
              phone: phoneIdx >= 0 && phoneIdx < cols.length && cols[phoneIdx].isNotEmpty
                  ? cols[phoneIdx]
                  : null,
              role: roleIdx >= 0 && roleIdx < cols.length
                  ? UserRole.fromString(cols[roleIdx])
                  : UserRole.student,
              status: statusIdx >= 0 && statusIdx < cols.length
                  ? UserStatus.fromString(cols[statusIdx])
                  : UserStatus.active,
              joinedAt: DateTime.now(),
            ),
          );
        }
      }

      if (parsed.isEmpty) {
        setState(() {
          _previewRows = [];
          _parseError = 'No valid user rows found with both name and email.';
        });
        return;
      }

      setState(() {
        _previewRows = parsed;
        _parseError = null;
      });
    } catch (e) {
      setState(() {
        _previewRows = [];
        _parseError = 'Parse error: $e';
      });
    }
  }

  void _confirmImport() {
    if (_previewRows.isEmpty) return;
    widget.onImport(_previewRows);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Import Users (CSV / JSON)',
      subtitle: 'Batch update existing Supabase user profiles matched by email',
      iconData: Icons.cloud_upload_rounded,
      gradientColors: const [Color(0xFF0284C7), Color(0xFF0EA5E9)],
      maxWidth: 580,
      scrollable: true,
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
          onPressed: _previewRows.isNotEmpty ? _confirmImport : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          child: Text(
            'Sync ${_previewRows.isNotEmpty ? "(${_previewRows.length}) Rows" : ""}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Paste CSV or JSON array below (required fields: name/full_name, email; optional: phone, role, status). Only registered Auth users in profiles can be synced.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _inputCtrl,
            minLines: 6,
            maxLines: 10,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: Color(0xFF1E293B)),
            decoration: AppModalDialog.inputDecoration(
              'full_name,email,phone,role,status\nJane Doe,jane@example.com,+91...,premium,active',
              focusColor: const Color(0xFF0284C7),
              isMultiline: true,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _parseInput,
            icon: const Icon(Icons.analytics_outlined, size: 16),
            label: const Text('Validate & Parse Data', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
          if (_parseError != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDA4AF)),
              ),
              child: Text(
                _parseError!,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF9F1239), fontWeight: FontWeight.w600),
              ),
            ),
          ],
          if (_previewRows.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Data Preview (${_previewRows.length} parsed rows):',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 36,
                  dataRowMinHeight: 36,
                  dataRowMaxHeight: 40,
                  horizontalMargin: 12,
                  columnSpacing: 18,
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  columns: const [
                    DataColumn(label: Text('#', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Email', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Role', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                  ],
                  rows: _previewRows.map((u) {
                    return DataRow(
                      cells: [
                        DataCell(Text(u.rowNumber.toString(), style: const TextStyle(fontSize: 11))),
                        DataCell(Text(u.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        DataCell(Text(u.email, style: const TextStyle(fontSize: 11))),
                        DataCell(Text(u.role.label, style: TextStyle(fontSize: 11, color: u.role.color, fontWeight: FontWeight.w700))),
                        DataCell(Text(u.status.label, style: TextStyle(fontSize: 11, color: u.status.color, fontWeight: FontWeight.w700))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
