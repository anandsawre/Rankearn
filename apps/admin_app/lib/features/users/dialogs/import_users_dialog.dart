import 'package:flutter/material.dart';
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
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
                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF0284C7), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Import Users (CSV / JSON)',
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

              // Upload Drag/Drop Box
              InkWell(
                onTap: _simulateFileSelect,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.file_upload_outlined, size: 36, color: Color(0xFF6B4EFF)),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFileName ?? 'Click to browse or drop CSV/JSON file here',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _selectedFileName != null ? FontWeight.w700 : FontWeight.w500,
                          color: _selectedFileName != null ? const Color(0xFF101A3A) : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Expected columns: name, email, phone, role, status (Max 5MB)',
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Preview Section if file selected
              if (_previewRows.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Previewing ${_previewRows.length} records ready to import',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                    const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 140),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _previewRows.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, i) {
                      final item = _previewRows[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Row(
                          children: [
                            Text('${i + 1}.', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Text(item.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(item.email, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: item.role.bgColor, borderRadius: BorderRadius.circular(4)),
                              child: Text(item.role.label, style: TextStyle(fontSize: 10, color: item.role.color, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

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
                    onPressed: _previewRows.isEmpty || _isProcessing ? null : _confirmImport,
                    icon: _isProcessing
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Confirm Import'),
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
}
