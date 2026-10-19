import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class UsersTab extends StatefulWidget {
  final List<Map<String, dynamic>>? initialUsers;

  const UsersTab({super.key, this.initialUsers});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  String _searchQuery = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialUsers != null) {
      _users = widget.initialUsers!;
      _isLoading = false;
    } else {
      _loadUsers();
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final res = await client.from('profiles').select().order('created_at', ascending: false);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _users = (res as List).map((row) => {
          'userId': row['id']?.toString() ?? '',
          'name': row['name']?.toString() ?? 'Anonymous Candidate',
          'email': row['email']?.toString() ?? 'N/A',
          'phone': row['phone']?.toString() ?? 'N/A',
          'role': row['role']?.toString() ?? 'user',
          'subscriptionStatus': row['subscription_status']?.toString() ?? 'free',
          'coins': (row['coins'] as num?)?.toInt() ?? 0,
          'createdAt': row['created_at'] != null ? row['created_at'].toString().split('T').first : 'N/A',
          'status': row['status']?.toString() ?? 'active',
          'violationCount': (row['violation_count'] as num?)?.toInt() ?? 0,
        }).toList();
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _users.where((u) {
      final q = _searchQuery.toLowerCase();
      return _searchQuery.isEmpty ||
          (u['name'] as String).toLowerCase().contains(q) ||
          (u['email'] as String).toLowerCase().contains(q) ||
          (u['phone'] as String).toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Container matching React Admin
          _buildHeader(),
          const SizedBox(height: 20),

          // User Table Container
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.borderXl,
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: const [
                BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                _buildTableControls(),
                _buildUsersTable(filteredUsers),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary,
                  borderRadius: AppRadii.borderLg,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandPrimary.withAlpha(60),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.people_outline, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Registered Users', style: AppTypography.displayMedium),
                  SizedBox(height: 2),
                  Text('Manage and monitor candidate community & wallet permissions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              hintText: 'Search users by name, email, or phone...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF64748B)),
            tooltip: 'Refresh User Directory',
            onPressed: _loadUsers,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable(List<Map<String, dynamic>> users) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(48),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }
    if (users.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.person_off_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text('No registered users found in database.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
        dataRowMinHeight: 64,
        dataRowMaxHeight: 64,
        columns: const [
          DataColumn(label: Text('USER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.8))),
          DataColumn(label: Text('CONTACT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.8))),
          DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.8))),
          DataColumn(label: Text('JOINED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.8))),
          DataColumn(label: Text('COINS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.8))),
          DataColumn(label: Text('WALLET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.8))),
          DataColumn(label: Text('SAFETY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.8))),
        ],
        rows: users.map((u) {
          final isPremium = u['subscriptionStatus'] == 'premium';
          final isSuspended = u['status'] == 'suspended';
          final violations = (u['violationCount'] as int?) ?? 0;

          return DataRow(
            cells: [
              // 1. User Info
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFECFDF5),
                      child: Text(
                        u['name'][0],
                        style: const TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u['name'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                        Text(
                          u['role'] == 'admin' ? 'Administrator' : 'Student',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Contact
              DataCell(
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 12, color: Color(0xFF2563EB)),
                        const SizedBox(width: 4),
                        Text(u['email'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 12, color: Color(0xFF059669)),
                        const SizedBox(width: 4),
                        Text(u['phone'], style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Status
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPremium ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                    borderRadius: AppRadii.borderPill,
                    border: Border.all(color: isPremium ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    isPremium ? 'PRO PASS' : 'FREE TIER',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: isPremium ? const Color(0xFF059669) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),

              // 4. Joined
              DataCell(
                Text(u['createdAt'], style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ),

              // 5. Coins
              DataCell(
                Text(
                  '${u['coins']} Coins',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                ),
              ),

              // 6. Wallet Action
              DataCell(
                ElevatedButton.icon(
                  icon: const Icon(Icons.monetization_on_outlined, size: 14),
                  label: const Text('Add Coins', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFBEB),
                    foregroundColor: const Color(0xFFB45309),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFFDE68A)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
                  ),
                  onPressed: () => _showAddCoinsDialog(u),
                ),
              ),

              // 7. Safety Action
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isSuspended ? Icons.shield : Icons.shield_outlined,
                        size: 18,
                        color: isSuspended ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                      ),
                      tooltip: isSuspended ? 'Lift Suspension' : 'Suspend Candidate',
                      onPressed: () => _showSuspensionDialog(u),
                    ),
                    if (violations > 0)
                      Tooltip(
                        message: 'Cheating Warning: Detected $violations suspicious tab switches during live tests.',
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: AppRadii.borderSm,
                            border: Border.all(color: const Color(0xFFFCD34D)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFD97706)),
                              const SizedBox(width: 3),
                              Text('$violations', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFD97706))),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showAddCoinsDialog(Map<String, dynamic> user) {
    final amountController = TextEditingController(text: '100');
    final reasonController = TextEditingController(text: 'Admin bonus grant');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Adjust Coins: ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: 'Coins to Credit', controller: amountController, hintText: '100'),
            const SizedBox(height: 12),
            AppTextField(label: 'Reason for Adjustment', controller: reasonController, hintText: 'e.g. Compensation, referral bonus'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          AppButton(
            label: 'Credit Coins',
            onPressed: () {
              final val = int.tryParse(amountController.text) ?? 0;
              setState(() => user['coins'] = (user['coins'] as int) + val);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Credited $val coins to ${user['name']}. Balance: ${user['coins']}')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSuspensionDialog(Map<String, dynamic> user) {
    final isSuspended = user['status'] == 'suspended';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isSuspended ? 'Lift Suspension' : 'Suspend Account: ${user['name']}'),
        content: Text(
          isSuspended
            ? 'Are you sure you want to restore full access for ${user['name']}?'
            : 'Temporarily or permanently suspend this account for exam malpractice or terms violation.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          AppButton(
            label: isSuspended ? 'Restore Account' : 'Confirm Suspension',
            variant: isSuspended ? AppButtonVariant.primary : AppButtonVariant.destructive,
            onPressed: () {
              setState(() => user['status'] = isSuspended ? 'active' : 'suspended');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isSuspended ? 'Restored access for ${user['name']}' : 'Suspended ${user['name']}')),
              );
            },
          ),
        ],
      ),
    );
  }
}
