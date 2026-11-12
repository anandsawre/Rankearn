import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/user_management_item.dart';

class AddUserDialog extends StatefulWidget {
  final UserManagementItem? initialUser;
  final ValueChanged<UserManagementItem> onSave;

  const AddUserDialog({
    super.key,
    this.initialUser,
    required this.onSave,
  });

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late UserRole _selectedRole;
  late UserStatus _selectedStatus;

  bool get _isEditing => widget.initialUser != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialUser?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.initialUser?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.initialUser?.phone ?? '');
    _selectedRole = widget.initialUser?.role ?? UserRole.student;
    _selectedStatus = widget.initialUser?.status ?? UserStatus.active;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final item = UserManagementItem(
      id: widget.initialUser?.id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
      rowNumber: widget.initialUser?.rowNumber ?? 1,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      role: _selectedRole,
      status: _selectedStatus,
      coins: widget.initialUser?.coins ?? 0,
      enrollmentsCount: widget.initialUser?.enrollmentsCount ?? 0,
      testsAttemptedCount: widget.initialUser?.testsAttemptedCount ?? 0,
      lastActive: widget.initialUser?.lastActive ?? 'Just now',
      joinedAt: widget.initialUser?.joinedAt ?? DateTime.now(),
    );

    widget.onSave(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: _isEditing ? 'Edit User Details' : 'Add New User',
      subtitle: _isEditing
          ? 'Update profile information, role & account status'
          : 'Create a new user account with credentials and role assignment',
      iconData: Icons.person_add_alt_1_rounded,
      gradientColors: const [Color(0xFFFF9500), Color(0xFFF59E0B)],
      maxWidth: 500,
      actions: [
        AppModalDialog.secondaryButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
        ),
        AppModalDialog.primaryButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Save Changes' : 'Create User', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full Name
            AppModalDialog.textField(
              controller: _nameCtrl,
              hint: 'Full Name *',
              prefixIcon: const Icon(Icons.badge_outlined, size: 17, color: Color(0xFF94A3B8)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 12),

            // Email
            AppModalDialog.textField(
              controller: _emailCtrl,
              hint: 'Email Address * (user@example.com)',
              prefixIcon: const Icon(Icons.email_outlined, size: 17, color: Color(0xFF94A3B8)),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter an email';
                if (!v.contains('@') || !v.contains('.')) return 'Invalid email address';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Phone
            AppModalDialog.textField(
              controller: _phoneCtrl,
              hint: 'Phone Number (Optional)',
              prefixIcon: const Icon(Icons.phone_outlined, size: 17, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),

            // Role & Status Dropdowns
            Row(
              children: [
                Expanded(
                  child: AppDropdown<UserRole>(
                    hint: 'Role',
                    value: _selectedRole,
                    items: UserRole.values.map((r) {
                      return AppDropdownItem<UserRole>(
                        value: r,
                        label: r.label,
                        leading: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: r.color, shape: BoxShape.circle),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRole = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdown<UserStatus>(
                    hint: 'Status',
                    value: _selectedStatus,
                    items: UserStatus.values.map((s) {
                      return AppDropdownItem<UserStatus>(
                        value: s,
                        label: s.label,
                        leading: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
