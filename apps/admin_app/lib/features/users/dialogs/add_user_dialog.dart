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
      coins: widget.initialUser?.coins ?? 100,
      enrollmentsCount: widget.initialUser?.enrollmentsCount ?? 0,
      testsAttemptedCount: widget.initialUser?.testsAttemptedCount ?? 0,
      lastActive: widget.initialUser?.lastActive ?? 'Just now',
      joinedAt: widget.initialUser?.joinedAt ?? DateTime.now(),
    );

    widget.onSave(item);
    Navigator.of(context).pop();
  }

  InputDecoration _inputDec({required String hintText, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(prefixIcon, size: 18, color: const Color(0xFF64748B)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF5636F5), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: _isEditing ? 'Edit User Details' : 'Add New User',
      subtitle: _isEditing
          ? 'Update profile information, role & account status'
          : 'Create a new user account with credentials and role assignment',
      iconData: Icons.person_add_alt_1_rounded,
      gradientColors: const [Color(0xFF5636F5), Color(0xFF2587F8)],
      maxWidth: 500,
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5636F5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          onPressed: _submit,
          child: Text(_isEditing ? 'Save Changes' : 'Create User', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full Name
            const Text('Full Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
              decoration: _inputDec(hintText: 'e.g. Rahul Sharma', prefixIcon: Icons.badge_outlined),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 14),

            // Email
            const Text('Email Address *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailCtrl,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
              decoration: _inputDec(hintText: 'e.g. rahul.sharma@example.com', prefixIcon: Icons.email_outlined),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter an email';
                if (!v.contains('@') || !v.contains('.')) return 'Invalid email address';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Phone
            const Text('Phone Number (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneCtrl,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
              decoration: _inputDec(hintText: 'e.g. +91 98765 43210', prefixIcon: Icons.phone_outlined),
            ),
            const SizedBox(height: 14),

            // Role & Status Dropdowns
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Role', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                      const SizedBox(height: 6),
                      AppDropdown<UserRole>(
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
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                      const SizedBox(height: 6),
                      AppDropdown<UserStatus>(
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
                    ],
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
