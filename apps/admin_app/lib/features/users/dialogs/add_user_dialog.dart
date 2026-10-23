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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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
                        color: const Color(0xFF6B4EFF).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF6B4EFF), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isEditing ? 'Edit User Details' : 'Add New User',
                        style: const TextStyle(
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
                const SizedBox(height: 20),

                // Full Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'e.g. Rahul Sharma',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.badge_outlined, size: 18),
                    isDense: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 14),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email Address *',
                    hintText: 'e.g. rahul.sharma@example.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.email_outlined, size: 18),
                    isDense: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter an email';
                    if (!v.contains('@') || !v.contains('.')) return 'Invalid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Phone
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    hintText: 'e.g. +91 98765 43210',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 14),

                // Role & Status Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: AppDropdown<UserRole>(
                        label: 'Role',
                        value: _selectedRole,
                        isDense: true,
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
                        label: 'Status',
                        value: _selectedStatus,
                        isDense: true,
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
                const SizedBox(height: 24),

                // Footer Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5636F5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      ),
                      onPressed: _submit,
                      child: Text(_isEditing ? 'Save Changes' : 'Create User'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
