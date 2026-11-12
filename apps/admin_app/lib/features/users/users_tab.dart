import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import 'models/user_management_item.dart';
import 'widgets/users_hero_card.dart';
import 'widgets/users_quick_actions.dart';
import 'widgets/users_metrics_row.dart';
import 'widgets/users_table_card.dart';
import 'widgets/role_wise_users_donut_card.dart';
import 'widgets/user_growth_bar_chart.dart';
import 'widgets/users_recent_activity_card.dart';
import 'dialogs/add_user_dialog.dart';
import 'dialogs/import_users_dialog.dart';
import 'dialogs/manage_roles_dialog.dart';
import 'dialogs/send_notification_dialog.dart';
import 'dialogs/export_users_dialog.dart';
import 'dialogs/bulk_actions_dialog.dart';
import 'dialogs/view_user_dialog.dart';
import 'dialogs/adjust_coins_dialog.dart';

/// Users Management Screen for Rankearn Admin Panel
/// Fully backed by live Supabase `profiles`, `user_roles`, `attempts`, and `unlocked_tests`.
class UsersTab extends StatefulWidget {
  final List<Map<String, dynamic>>? initialUsers;

  const UsersTab({super.key, this.initialUsers});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  late List<UserManagementItem> _allUsers;
  List<UserActivityData> _recentActivities = [];
  final Set<String> _selectedIds = {};

  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String _roleFilter = 'all';
  String _statusFilter = 'all';
  String _registrationFilter = 'all';

  int _currentPage = 1;
  int _pageSize = 7;

  @override
  void initState() {
    super.initState();
    if (widget.initialUsers != null) {
      _allUsers = widget.initialUsers!
          .asMap()
          .entries
          .map((e) => UserManagementItem.fromMap(e.value, e.key + 1))
          .toList();
      _recentActivities = _buildActivities(_allUsers, const []);
      _isLoading = false;
    } else {
      _allUsers = [];
      _loadFromSupabase();
    }
  }

  Future<void> _loadFromSupabase() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Database connection is not initialized.';
        });
      }
      return;
    }

    try {
      final results = await Future.wait([
        client.from('profiles').select().order('created_at', ascending: false),
        client.from('user_roles').select('user_id, role'),
        client
            .from('attempts')
            .select('user_id, created_at')
            .order('created_at', ascending: false)
            .limit(3000),
        client.from('unlocked_tests').select('user_id').limit(3000),
      ]);

      final profileRows = List<Map<String, dynamic>>.from(results[0] as List);
      final roleRows = List<Map<String, dynamic>>.from(results[1] as List);
      final attemptRows = List<Map<String, dynamic>>.from(results[2] as List);
      final unlockedRows = List<Map<String, dynamic>>.from(results[3] as List);

      // Build highest role per user from `user_roles`
      final roleLookup = <String, UserRole>{};
      for (final r in roleRows) {
        final uid = r['user_id']?.toString() ?? '';
        final rName = r['role']?.toString() ?? '';
        if (uid.isEmpty) continue;
        final mapped = UserRole.fromString(rName);
        final prev = roleLookup[uid];
        if (mapped == UserRole.admin ||
            (mapped == UserRole.moderator && prev != UserRole.admin)) {
          roleLookup[uid] = mapped;
        }
      }

      // Count real attempts & latest attempt timestamp per user
      final attemptsCount = <String, int>{};
      final latestAttemptAt = <String, DateTime>{};
      for (final a in attemptRows) {
        final uid = a['user_id']?.toString() ?? '';
        if (uid.isEmpty) continue;
        attemptsCount[uid] = (attemptsCount[uid] ?? 0) + 1;
        final dt = DateTime.tryParse(a['created_at']?.toString() ?? '')?.toLocal();
        if (dt != null &&
            (latestAttemptAt[uid] == null || dt.isAfter(latestAttemptAt[uid]!))) {
          latestAttemptAt[uid] = dt;
        }
      }

      // Count unlocked enrollments per user
      final enrollmentsCount = <String, int>{};
      for (final u in unlockedRows) {
        final uid = u['user_id']?.toString() ?? '';
        if (uid.isEmpty) continue;
        enrollmentsCount[uid] = (enrollmentsCount[uid] ?? 0) + 1;
      }

      final loadedUsers = profileRows.asMap().entries.map((entry) {
        final map = entry.value;
        final uid = map['id']?.toString() ?? '';
        final rawSub = map['subscription_status']?.toString().toLowerCase().trim();
        final resolvedRole = roleLookup[uid] ??
            (rawSub == 'premium' ? UserRole.premium : UserRole.student);
        return UserManagementItem.fromMap(
          map,
          entry.key + 1,
          resolvedRole,
          enrollmentsCount[uid] ?? 0,
          attemptsCount[uid] ?? 0,
          latestAttemptAt[uid],
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _allUsers = loadedUsers;
        _recentActivities = _buildActivities(loadedUsers, attemptRows);
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load users from Supabase: $e';
      });
    }
  }

  List<UserActivityData> _buildActivities(
    List<UserManagementItem> users,
    List<Map<String, dynamic>> attemptRows,
  ) {
    final nameById = <String, String>{for (final u in users) u.id: u.name};
    final rawEvents = <({
      DateTime at,
      IconData icon,
      Color iconColor,
      Color bgColor,
      String prefix,
      String userName,
    })>[];

    for (final u in users.take(6)) {
      if (u.status == UserStatus.blocked || u.status == UserStatus.inactive) {
        rawEvents.add((
          at: u.joinedAt,
          icon: Icons.block_rounded,
          iconColor: const Color(0xFFF43F5E),
          bgColor: const Color(0xFFFFF1F2),
          prefix: 'User ${u.status.label.toLowerCase()}: ',
          userName: u.name,
        ));
      } else if (u.role == UserRole.premium) {
        rawEvents.add((
          at: u.joinedAt,
          icon: Icons.workspace_premium_rounded,
          iconColor: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFFFBEB),
          prefix: 'Premium member: ',
          userName: u.name,
        ));
      } else {
        rawEvents.add((
          at: u.joinedAt,
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF10B981),
          bgColor: const Color(0xFFECFDF5),
          prefix: 'User registered: ',
          userName: u.name,
        ));
      }
    }

    for (final a in attemptRows.take(5)) {
      final uid = a['user_id']?.toString() ?? '';
      final dt = DateTime.tryParse(a['created_at']?.toString() ?? '')?.toLocal();
      final name = nameById[uid];
      if (dt != null && name != null) {
        rawEvents.add((
          at: dt,
          icon: Icons.assignment_turned_in_rounded,
          iconColor: const Color(0xFF2587F8),
          bgColor: const Color(0xFFEFF6FF),
          prefix: 'Test completed by ',
          userName: name,
        ));
      }
    }

    rawEvents.sort((a, b) => b.at.compareTo(a.at));
    return rawEvents.take(5).map((e) {
      return UserActivityData(
        icon: e.icon,
        iconColor: e.iconColor,
        bgColor: e.bgColor,
        prefix: e.prefix,
        userName: e.userName,
        time: _formatTimeAgo(e.at),
      );
    }).toList();
  }

  static String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${_months[dt.month - 1]} ${dt.day}';
  }

  List<UserManagementItem> get _filteredUsers {
    return _allUsers.where((u) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = u.name.toLowerCase().contains(q);
        final matchesEmail = u.email.toLowerCase().contains(q);
        final matchesPhone = u.phone?.toLowerCase().contains(q) ?? false;
        if (!matchesName && !matchesEmail && !matchesPhone) return false;
      }

      if (_roleFilter != 'all' &&
          u.role.name.toLowerCase() != _roleFilter.toLowerCase()) {
        return false;
      }

      if (_statusFilter != 'all' &&
          u.status.name.toLowerCase() != _statusFilter.toLowerCase()) {
        return false;
      }

      if (_registrationFilter != 'all') {
        final now = DateTime.now();
        switch (_registrationFilter) {
          case 'today':
            if (u.joinedAt.year != now.year ||
                u.joinedAt.month != now.month ||
                u.joinedAt.day != now.day) {
              return false;
            }
            break;
          case 'week':
            if (now.difference(u.joinedAt).inDays > 7) return false;
            break;
          case 'month':
            if (u.joinedAt.year != now.year || u.joinedAt.month != now.month) {
              return false;
            }
            break;
          case 'year':
            if (u.joinedAt.year != now.year) return false;
            break;
        }
      }

      return true;
    }).toList();
  }

  List<UserManagementItem> get _paginatedUsers {
    final filtered = _filteredUsers;
    final startIndex = (_currentPage - 1) * _pageSize;
    if (startIndex >= filtered.length) return [];
    final endIndex = (startIndex + _pageSize).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  ({String growth, bool isPositive, List<double> sparkline}) _computeGrowthAndSparkline(
    List<DateTime> dates, {
    int totalCount = 0,
  }) {
    if (dates.isEmpty) {
      return (growth: '', isPositive: true, sparkline: const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]);
    }
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = todayStart.subtract(const Duration(days: 6));
    final fourteenDaysAgo = todayStart.subtract(const Duration(days: 13));

    int cur = 0;
    int prev = 0;
    final buckets = List<double>.filled(7, 0.0);

    for (final dt in dates) {
      if (!dt.isBefore(sevenDaysAgo)) {
        cur++;
      } else if (!dt.isBefore(fourteenDaysAgo)) {
        prev++;
      }
      final dayOnly = DateTime(dt.year, dt.month, dt.day);
      final diff = todayStart.difference(dayOnly).inDays;
      if (diff >= 0 && diff < 7) {
        buckets[6 - diff] += 1;
      }
    }

    String growth = '';
    bool isPos = true;
    if (prev > 0) {
      final pct = (((cur - prev) / prev) * 100).round();
      isPos = pct >= 0;
      growth = '${pct >= 0 ? '+' : ''}$pct%';
    } else if (cur > 0 && totalCount > 0) {
      final pct = ((cur / totalCount) * 100).round();
      growth = '+$pct%';
    }
    return (growth: growth, isPositive: isPos, sparkline: buckets);
  }

  List<UserGrowthBarPoint> get _growthBars {
    if (_allUsers.isEmpty) return const [];
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final counts = List<int>.filled(7, 0);

    for (final u in _allUsers) {
      final d = DateTime(u.joinedAt.year, u.joinedAt.month, u.joinedAt.day);
      final diff = todayStart.difference(d).inDays;
      if (diff >= 0 && diff < 7) {
        counts[6 - diff] += 1;
      }
    }

    return List.generate(7, (i) {
      final day = todayStart.subtract(Duration(days: 6 - i));
      return UserGrowthBarPoint(
        label: '${_months[day.month - 1]} ${day.day}',
        value: counts[i],
      );
    });
  }

  List<DonutSlice> get _roleSlices {
    if (_allUsers.isEmpty) return const [];
    final counts = <UserRole, int>{};
    for (final u in _allUsers) {
      counts[u.role] = (counts[u.role] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) {
      return DonutSlice(
        label: e.key.label,
        percentage: (e.value / _allUsers.length) * 100,
        count: e.value,
        color: e.key.color,
      );
    }).toList();
  }

  void _showSnack(String message, {bool isError = false, Color? bg}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : (bg ?? const Color(0xFF10B981)),
      ),
    );
  }

  Future<void> _syncUserRoleInDb(dynamic client, String userId, UserRole role) async {
    await client.from('user_roles').delete().eq('user_id', userId);
    if (role == UserRole.admin || role == UserRole.moderator) {
      await client.from('user_roles').insert({
        'user_id': userId,
        'role': role.dbRoleName,
      });
    }
  }

  void _openAddUserDialog([UserManagementItem? userToEdit]) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => AddUserDialog(
        initialUser: userToEdit,
        onSave: (savedUser) async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot save user.', isError: true);
            return;
          }

          try {
            if (userToEdit != null) {
              await client
                  .from('profiles')
                  .update(savedUser.toProfileUpdateMap())
                  .eq('id', savedUser.id);
              await _syncUserRoleInDb(client, savedUser.id, savedUser.role);
              if (!mounted) return;
              await _loadFromSupabase();
              _showSnack('Updated user "${savedUser.name}" in Supabase.');
            } else {
              // profiles.id references auth.users(id); client-side without service_role cannot mint auth users silently.
              await client.from('profiles').insert({
                'id': savedUser.id,
                'name': savedUser.name,
                'email': savedUser.email,
                ...savedUser.toProfileUpdateMap(),
              });
              if (!mounted) return;
              await _loadFromSupabase();
              _showSnack('Created user "${savedUser.name}" in Supabase.');
            }
          } catch (e) {
            _showSnack(
              userToEdit != null
                  ? 'Failed to update user: $e'
                  : 'User creation requires an existing Auth user in Supabase: $e',
              isError: true,
            );
          }
        },
      ),
    );
  }

  void _openImportDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ImportUsersDialog(
        onImport: (parsedUsers) async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot sync imported users.', isError: true);
            return;
          }

          int updated = 0;
          int skipped = 0;
          for (final u in parsedUsers) {
            try {
              final existing = await client
                  .from('profiles')
                  .select('id')
                  .ilike('email', u.email)
                  .maybeSingle();
              if (existing != null && existing['id'] != null) {
                final uid = existing['id'].toString();
                await client
                    .from('profiles')
                    .update(u.toProfileUpdateMap())
                    .eq('id', uid);
                await _syncUserRoleInDb(client, uid, u.role);
                updated++;
              } else {
                skipped++;
              }
            } catch (_) {
              skipped++;
            }
          }
          if (!mounted) return;
          await _loadFromSupabase();
          _showSnack(
            'Synced $updated existing user(s)${skipped > 0 ? ", skipped $skipped unregistered email(s)" : ""}.',
          );
        },
      ),
    );
  }

  void _openManageRolesDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => const ManageRolesDialog(),
    );
  }

  void _openSendNotificationDialog([UserManagementItem? singleUser]) {
    final studentsCount = _allUsers.where((u) => u.role == UserRole.student).length;
    final premiumCount = _allUsers.where((u) => u.role == UserRole.premium).length;

    AppModalDialog.show(
      context: context,
      builder: (ctx) => SendNotificationDialog(
        totalUsersCount: _allUsers.length,
        studentsCount: studentsCount,
        premiumCount: premiumCount,
        selectedUserIds: singleUser != null
            ? [singleUser.id]
            : _selectedIds.toList(),
      ),
    );
  }

  void _openExportDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ExportUsersDialog(
        allUsers: _allUsers,
        filteredUsers: _filteredUsers,
        selectedIds: _selectedIds,
      ),
    );
  }

  void _openBulkActionsDialog() {
    if (_selectedIds.isEmpty) {
      _showSnack(
        'Please select at least one user first to apply bulk actions.',
        bg: const Color(0xFFF59E0B),
      );
      return;
    }

    final ids = _selectedIds.toList();

    AppModalDialog.show(
      context: context,
      builder: (ctx) => BulkActionsDialog(
        selectedCount: ids.length,
        onChangeRole: (newRole) async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot update roles.', isError: true);
            return;
          }

          try {
            await client
                .from('profiles')
                .update({
                  'subscription_status': newRole == UserRole.premium ? 'premium' : 'free',
                  'updated_at': DateTime.now().toUtc().toIso8601String(),
                })
                .inFilter('id', ids);

            for (final uid in ids) {
              await _syncUserRoleInDb(client, uid, newRole);
            }

            if (!mounted) return;
            await _loadFromSupabase();
            _showSnack('Updated role to ${newRole.label} for ${ids.length} user(s).');
          } catch (e) {
            _showSnack('Failed to update roles: $e', isError: true);
          }
        },
        onChangeStatus: (newStatus) async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot update status.', isError: true);
            return;
          }

          try {
            await client
                .from('profiles')
                .update({
                  'status': newStatus.dbStatusValue,
                  'updated_at': DateTime.now().toUtc().toIso8601String(),
                })
                .inFilter('id', ids);

            if (!mounted) return;
            await _loadFromSupabase();
            _showSnack('Updated status to ${newStatus.label} for ${ids.length} user(s).');
          } catch (e) {
            _showSnack('Failed to update status: $e', isError: true);
          }
        },
        onExportSelected: _openExportDialog,
        onDeleteSelected: () async {
          final client = SupabaseConfig.clientSafe;
          if (client == null) {
            _showSnack('Database not connected. Cannot delete users.', isError: true);
            return;
          }

          try {
            await client.from('profiles').delete().inFilter('id', ids);
            if (!mounted) return;
            _selectedIds.clear();
            await _loadFromSupabase();
            _showSnack('Removed ${ids.length} user profile(s).', bg: const Color(0xFFF43F5E));
          } catch (e) {
            _showSnack('Failed to delete selected users: $e', isError: true);
          }
        },
      ),
    );
  }

  void _openViewDialog(UserManagementItem user) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ViewUserDialog(
        user: user,
        onEdit: () => _openAddUserDialog(user),
        onManageCoins: () {
          Navigator.of(ctx).pop();
          _openAdjustCoinsDialog(user);
        },
      ),
    );
  }

  void _openAdjustCoinsDialog(UserManagementItem user) {
    AdjustCoinsDialog.show(
      context,
      user: user,
      onCoinsUpdated: (newCoins) {
        setState(() {
          final idx = _allUsers.indexWhere((e) => e.id == user.id);
          if (idx >= 0) {
            _allUsers[idx] = _allUsers[idx].copyWith(coins: newCoins);
          }
        });
      },
    );
  }

  Future<void> _toggleUserStatus(UserManagementItem user) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      _showSnack('Database not connected. Cannot update status.', isError: true);
      return;
    }

    final nextStatus =
        user.status == UserStatus.active ? UserStatus.inactive : UserStatus.active;

    try {
      await client
          .from('profiles')
          .update({
            'status': nextStatus.dbStatusValue,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', user.id);

      if (!mounted) return;
      setState(() {
        final idx = _allUsers.indexWhere((e) => e.id == user.id);
        if (idx >= 0) {
          _allUsers[idx] = user.copyWith(status: nextStatus);
        }
      });
      _showSnack(
        '"${user.name}" status changed to ${nextStatus.label}!',
        bg: nextStatus.color,
      );
    } catch (e) {
      _showSnack('Failed to update user status: $e', isError: true);
    }
  }

  void _deleteUser(UserManagementItem user) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => AppModalDialog(
        title: 'Delete User Account',
        subtitle: 'Permanent deletion warning',
        iconData: Icons.delete_outline_rounded,
        gradientColors: const [Color(0xFFDC2626), Color(0xFFEF4444)],
        maxWidth: 440,
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final client = SupabaseConfig.clientSafe;
              if (client == null) {
                _showSnack('Database not connected. Cannot delete user.', isError: true);
                return;
              }
              try {
                await client.from('profiles').delete().eq('id', user.id);
                if (!mounted) return;
                setState(() {
                  _allUsers.removeWhere((e) => e.id == user.id);
                  _selectedIds.remove(user.id);
                });
                _showSnack('User "${user.name}" permanently deleted.');
              } catch (e) {
                _showSnack('Failed to delete user: $e', isError: true);
              }
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
        child: Text(
          'Are you sure you want to permanently delete "${user.name}"? This action cannot be undone and will delete user records.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.45),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: const Color(0xFFFDA4AF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9F1239),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _loadFromSupabase,
            icon: const Icon(Icons.refresh_rounded, size: 15),
            label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1100;

    final now = DateTime.now();
    final activeList = _allUsers.where((u) => u.status == UserStatus.active).toList();
    final inactiveList = _allUsers.where((u) => u.status != UserStatus.active).toList();
    final monthList = _allUsers
        .where((u) => u.joinedAt.year == now.year && u.joinedAt.month == now.month)
        .toList();
    final premiumList = _allUsers.where((u) => u.role == UserRole.premium).toList();

    final totalTrend = _computeGrowthAndSparkline(
      _allUsers.map((u) => u.joinedAt).toList(),
      totalCount: _allUsers.length,
    );
    final activeTrend = _computeGrowthAndSparkline(
      activeList.map((u) => u.joinedAt).toList(),
      totalCount: activeList.length,
    );
    final monthTrend = _computeGrowthAndSparkline(
      monthList.map((u) => u.joinedAt).toList(),
      totalCount: monthList.length,
    );
    final inactiveTrend = _computeGrowthAndSparkline(
      inactiveList.map((u) => u.joinedAt).toList(),
      totalCount: inactiveList.length,
    );
    final premiumTrend = _computeGrowthAndSparkline(
      premiumList.map((u) => u.joinedAt).toList(),
      totalCount: premiumList.length,
    );

    final quickActions = UsersQuickActions(
      onAddUser: () => _openAddUserDialog(),
      onImportUsers: _openImportDialog,
      onManageRoles: _openManageRolesDialog,
      onSendNotification: () => _openSendNotificationDialog(),
      onExportUsers: _openExportDialog,
      onBulkActions: _openBulkActionsDialog,
    );

    final usersTable = UsersTableCard(
      items: _paginatedUsers,
      totalCount: _filteredUsers.length,
      selectedIds: _selectedIds,
      isLoading: _isLoading,
      onSelectionChanged: (ids) => setState(() {
        _selectedIds.clear();
        _selectedIds.addAll(ids);
      }),
      searchQuery: _searchQuery,
      onSearchChanged: (q) => setState(() {
        _searchQuery = q;
        _currentPage = 1;
      }),
      roleFilter: _roleFilter,
      onRoleFilterChanged: (r) => setState(() {
        _roleFilter = r;
        _currentPage = 1;
      }),
      statusFilter: _statusFilter,
      onStatusFilterChanged: (s) => setState(() {
        _statusFilter = s;
        _currentPage = 1;
      }),
      registrationFilter: _registrationFilter,
      onRegistrationFilterChanged: (reg) => setState(() {
        _registrationFilter = reg;
        _currentPage = 1;
      }),
      currentPage: _currentPage,
      pageSize: _pageSize,
      onPageChanged: (p) => setState(() => _currentPage = p),
      onPageSizeChanged: (sz) => setState(() {
        _pageSize = sz;
        _currentPage = 1;
      }),
      onView: _openViewDialog,
      onEdit: _openAddUserDialog,
      onManageCoins: _openAdjustCoinsDialog,
      onToggleStatus: _toggleUserStatus,
      onDelete: _deleteUser,
      onSendNotification: _openSendNotificationDialog,
    );

    final donutCard = RoleWiseUsersDonutCard(
      totalUsers: _allUsers.length,
      slices: _roleSlices,
      isLoading: _isLoading,
      onViewAll: () => setState(() => _roleFilter = 'all'),
    );

    final growthCard = UserGrowthBarChartCard(
      bars: _growthBars,
      isLoading: _isLoading,
    );

    final activityCard = UsersRecentActivityCard(
      activities: _recentActivities,
      isLoading: _isLoading,
    );

    return Container(
      color: const Color(0xFFF4F7FF),
      child: SingleChildScrollView(
        padding: AppSpacing.pagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) _buildErrorBanner(),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 63, child: UsersHeroCard()),
                  const SizedBox(width: 14),
                  Expanded(flex: 37, child: quickActions),
                ],
              )
            else
              Column(
                children: [
                  const UsersHeroCard(),
                  const SizedBox(height: 14),
                  quickActions,
                ],
              ),
            const SizedBox(height: 16),
            UsersMetricsRow(
              totalUsers: _allUsers.length,
              activeUsers: activeList.length,
              newUsersThisMonth: monthList.length,
              inactiveUsers: inactiveList.length,
              premiumUsers: premiumList.length,
              isLoading: _isLoading,
              totalGrowth: totalTrend.growth,
              totalPositive: totalTrend.isPositive,
              totalSparkline: totalTrend.sparkline,
              activeGrowth: activeTrend.growth,
              activePositive: activeTrend.isPositive,
              activeSparkline: activeTrend.sparkline,
              newUsersGrowth: monthTrend.growth,
              newUsersPositive: monthTrend.isPositive,
              newUsersSparkline: monthTrend.sparkline,
              inactiveGrowth: inactiveTrend.growth,
              inactivePositive: inactiveTrend.isPositive,
              inactiveSparkline: inactiveTrend.sparkline,
              premiumGrowth: premiumTrend.growth,
              premiumPositive: premiumTrend.isPositive,
              premiumSparkline: premiumTrend.sparkline,
            ),
            const SizedBox(height: 16),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: usersTable),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 295,
                    child: Column(
                      children: [
                        donutCard,
                        const SizedBox(height: 12),
                        growthCard,
                        const SizedBox(height: 12),
                        activityCard,
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  usersTable,
                  const SizedBox(height: 16),
                  donutCard,
                  const SizedBox(height: 12),
                  growthCard,
                  const SizedBox(height: 12),
                  activityCard,
                ],
              ),
          ],
        ),
      ),
    );
  }
}
