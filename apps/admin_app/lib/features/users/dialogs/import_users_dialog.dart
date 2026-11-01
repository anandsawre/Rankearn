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
  String? _selectedFileName;
  List<UserManagementItem> _previewRows = [];
  bool _isProcessing = false;

  void _simulateFileSelect() {
    setState(() {
      _selectedFileName = 'users_batch_import_2026.csv';
      _previewRows = [
        UserManagementItem(
          id: 'imp_1',
          rowNumber: 1,
          name: 'Arjun Verma',
          email: 'arjun.verma@example.com',
          phone: '+91 98111 22233',
          role: UserRole.student,
          status: UserStatus.active,
          enrollmentsCount: 0,
          testsAttemptedCount: 0,
          lastActive: 'Offline',
          joinedAt: DateTime.now(),
        ),
        UserManagementItem(
          id: 'imp_2',
          rowNumber: 2,
          name: 'Pooja Reddy',
          email: 'pooja.reddy@example.com',
          phone: '+91 98222 33344',
          role: UserRole.premium,
          status: UserStatus.active,
          enrollmentsCount: 1,
          testsAttemptedCount: 0,
          lastActive: 'Offline',
          joinedAt: DateTime.now(),
        ),
        UserManagementItem(
          id: 'imp_3',
          rowNumber: 3,
          name: 'Rohan Mehra',
          email: 'rohan.mehra@example.com',
          phone: '+91 98333 44455',
          role: UserRole.teacher,
          status: UserStatus.active,
          enrollmentsCount: 0,
          testsAttemptedCount: 0,
          lastActive: 'Offline',
          joinedAt: DateTime.now(),
        ),
      ];
    });
  }

  void _confirmImport() {
    if (_previewRows.isEmpty) return;
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      widget.onImport(_previewRows);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully imported ${_previewRows.length} users!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Import Users (CSV / JSON)',
      subtitle: 'Upload structured CSV or JSON to batch import user accounts',
      iconData: Icons.cloud_upload_rounded,
      gradientColors: const [Color(0xFF0284C7), Color(0xFF0EA5E9)],
      maxWidth: 580,
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
          onPressed: _previewRows.isNotEmpty && !_isProcessing ? _confirmImport : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          child: _isProcessing
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Import ${_previewRows.isNotEmpty ? "(${_previewRows.length}) Rows" : ""}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Upload Drag/Drop Box
          InkWell(
            onTap: _simulateFileSelect,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.file_upload_outlined, size: 36, color: Color(0xFF0284C7)),
                  const SizedBox(height: 8),
                  Text(
                    _selectedFileName ?? 'Click to browse CSV / Excel file or drag & drop',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _selectedFileName != null ? const Color(0xFF0284C7) : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Supported columns: full_name, email, phone, role, status',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preview Table if file selected
          if (_previewRows.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Data Preview (${_previewRows.length} valid rows found):',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _selectedFileName = null;
                    _previewRows.clear();
                  }),
                  child: const Text('Clear File', style: TextStyle(color: Color(0xFFE11D48), fontSize: 11.5)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
            ),
          ],
        ],
      ),
    );
  }
}
