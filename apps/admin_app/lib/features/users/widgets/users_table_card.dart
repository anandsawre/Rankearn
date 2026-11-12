import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/user_management_item.dart';

/// Users Table Card powered by the unified [AdminDataTableCard] from the design system.
class UsersTableCard extends StatefulWidget {
  final List<UserManagementItem> items;
  final int totalCount;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String roleFilter;
  final ValueChanged<String> onRoleFilterChanged;
  final String statusFilter;
  final ValueChanged<String> onStatusFilterChanged;
  final String registrationFilter;
  final ValueChanged<String> onRegistrationFilterChanged;
  final int currentPage;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;
  final ValueChanged<UserManagementItem> onView;
  final ValueChanged<UserManagementItem> onEdit;
  final ValueChanged<UserManagementItem>? onManageCoins;
  final ValueChanged<UserManagementItem> onToggleStatus;
  final ValueChanged<UserManagementItem> onDelete;
  final ValueChanged<UserManagementItem> onSendNotification;
  final bool isLoading;

  const UsersTableCard({
    super.key,
    required this.items,
    required this.totalCount,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.roleFilter,
    required this.onRoleFilterChanged,
    required this.statusFilter,
    required this.onStatusFilterChanged,
    required this.registrationFilter,
    required this.onRegistrationFilterChanged,
    required this.currentPage,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    required this.onView,
    required this.onEdit,
    this.onManageCoins,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onSendNotification,
    this.isLoading = false,
  });

  @override
  State<UsersTableCard> createState() => _UsersTableCardState();
}

class _UsersTableCardState extends State<UsersTableCard> {
  bool _isGridView = false;

  void _toggleSelectAll(bool? selectAll) {
    if (selectAll == true) {
      final allOnPage = widget.items.map((e) => e.id).toSet();
      widget.onSelectionChanged({...widget.selectedIds, ...allOnPage});
    } else {
      final currentOnPage = widget.items.map((e) => e.id).toSet();
      widget.onSelectionChanged(
        widget.selectedIds.where((id) => !currentOnPage.contains(id)).toSet(),
      );
    }
  }

  void _openFilterDialog() {
    String tempRole = widget.roleFilter;
    String tempStatus = widget.statusFilter;

    AppModalDialog.show(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AppModalDialog(
              title: 'Filter Users',
              subtitle: 'Refine table by role and user account status',
              iconData: Icons.tune_rounded,
              gradientColors: const [Color(0xFF5636F5), Color(0xFF7C3AED)],
              maxWidth: 440,
              actions: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () {
                    widget.onRoleFilterChanged('all');
                    widget.onStatusFilterChanged('all');
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Reset', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12.5)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onRoleFilterChanged(tempRole);
                    widget.onStatusFilterChanged(tempStatus);
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    elevation: 0,
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                ),
              ],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Role', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  const SizedBox(height: 6),
                  AppDropdown<String>(
                    value: tempRole,
                    items: const [
                      AppDropdownItem(value: 'all', label: 'All Roles'),
                      AppDropdownItem(value: 'student', label: 'Student'),
                      AppDropdownItem(value: 'premium', label: 'Premium'),
                      AppDropdownItem(value: 'teacher', label: 'Teacher'),
                      AppDropdownItem(value: 'moderator', label: 'Moderator'),
                    ],
                    onChanged: (v) {
                      if (v != null) setModalState(() => tempRole = v);
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  const SizedBox(height: 6),
                  AppDropdown<String>(
                    value: tempStatus,
                    items: const [
                      AppDropdownItem(value: 'all', label: 'All Status'),
                      AppDropdownItem(value: 'active', label: 'Active'),
                      AppDropdownItem(value: 'inactive', label: 'Inactive'),
                      AppDropdownItem(value: 'blocked', label: 'Blocked'),
                    ],
                    onChanged: (v) {
                      if (v != null) setModalState(() => tempStatus = v);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allSelected = widget.items.isNotEmpty &&
        widget.items.every((item) => widget.selectedIds.contains(item.id));
    final hasActiveFilter = widget.roleFilter != 'all' || widget.statusFilter != 'all' || widget.registrationFilter != 'all';
    final totalPages = math.max(1, (widget.totalCount / widget.pageSize).ceil());

    return AdminDataTableCard(
      title: 'Users List',
      totalCount: widget.totalCount,
      icon: Icons.people_rounded,
      iconBgColor: AppColors.brandBlue,
      searchQuery: widget.searchQuery,
      searchHint: 'Search users by name, email, or phone...',
      onSearchChanged: widget.onSearchChanged,
      currentPage: widget.currentPage,
      totalPages: totalPages,
      rowsPerPage: widget.pageSize,
      onPageChanged: widget.onPageChanged,
      onRowsPerPageChanged: widget.onPageSizeChanged,
      itemLabel: 'users',
      isLoading: widget.isLoading,
      customBody: _isGridView ? _buildGridView() : null,
      filterControls: [
        _buildRoleDropdown(),
        _buildStatusDropdown(),
        _buildRegistrationDropdown(),
        _buildViewToggles(),
        _buildFilterButton(hasActiveFilter),
      ],
      columns: [
        DataColumn(
          label: SizedBox(
            width: 20,
            child: Checkbox(
              value: allSelected,
              onChanged: _toggleSelectAll,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              activeColor: AppColors.brandPurple,
            ),
          ),
        ),
        const DataColumn(label: Text('#', style: _colHeaderStyle)),
        const DataColumn(label: Text('User Details', style: _colHeaderStyle)),
        const DataColumn(
          label: Row(
            children: [
              Text('Role', style: _colHeaderStyle),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textMuted),
            ],
          ),
        ),
        const DataColumn(label: Text('Enrollments', style: _colHeaderStyle)),
        const DataColumn(label: Text('Tests Attempted', style: _colHeaderStyle)),
        const DataColumn(label: Text('Last Active', style: _colHeaderStyle)),
        const DataColumn(
          label: Row(
            children: [
              Text('Status', style: _colHeaderStyle),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textMuted),
            ],
          ),
        ),
        const DataColumn(label: Text('Joined On', style: _colHeaderStyle)),
        const DataColumn(label: Text('Actions', style: _colHeaderStyle)),
      ],
      rows: widget.items.map((user) {
        final isSelected = widget.selectedIds.contains(user.id);
        return DataRow(
          selected: isSelected,
          onSelectChanged: (v) {
            final newSet = Set<String>.from(widget.selectedIds);
            if (v == true) {
              newSet.add(user.id);
            } else {
              newSet.remove(user.id);
            }
            widget.onSelectionChanged(newSet);
          },
          cells: [
            DataCell(
              SizedBox(
                width: 20,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (v) {
                    final newSet = Set<String>.from(widget.selectedIds);
                    if (v == true) {
                      newSet.add(user.id);
                    } else {
                      newSet.remove(user.id);
                    }
                    widget.onSelectionChanged(newSet);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  activeColor: AppColors.brandPurple,
                ),
              ),
            ),
            DataCell(Text(user.rowNumber.toString(), style: _cellStyle)),
            DataCell(
              Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: user.role.color.withValues(alpha: 0.12),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontFamily: AppTypography.fontHeading,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: user.role.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DataCell(
              AdminTableStatusBadge(
                label: user.role.label,
                backgroundColor: user.role.bgColor,
                textColor: user.role.color,
              ),
            ),
            DataCell(Center(child: Text(user.enrollmentsCount.toString(), style: _cellStyle))),
            DataCell(Center(child: Text(user.testsAttemptedCount.toString(), style: _cellStyle))),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: user.lastActive.toLowerCase().contains('online')
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    user.lastActive,
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 11.5,
                      color: user.lastActive.toLowerCase().contains('online')
                          ? const Color(0xFF10B981)
                          : AppColors.textSecondary,
                      fontWeight: user.lastActive.toLowerCase().contains('online')
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(
              AdminTableStatusBadge(
                label: user.status.label,
                backgroundColor: user.status.bgColor,
                textColor: user.status.color,
              ),
            ),
            DataCell(Text(user.joinedDateFormatted, style: _cellStyle)),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminTableActionButton(
                    icon: Icons.visibility_outlined,
                    tooltip: 'View User',
                    onTap: () => widget.onView(user),
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit User',
                    onTap: () => widget.onEdit(user),
                  ),
                  if (widget.onManageCoins != null) ...[
                    const SizedBox(width: 4),
                    AdminTableActionButton(
                      icon: Icons.monetization_on_outlined,
                      tooltip: 'Manage Coins',
                      onTap: () => widget.onManageCoins!(user),
                      color: AppColors.coinGold,
                    ),
                  ],
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onSelected: (val) {
                      if (val == 'coins') widget.onManageCoins?.call(user);
                      if (val == 'status') widget.onToggleStatus(user);
                      if (val == 'notify') widget.onSendNotification(user);
                      if (val == 'delete') widget.onDelete(user);
                    },
                    itemBuilder: (context) => [
                      if (widget.onManageCoins != null)
                        PopupMenuItem(
                          value: 'coins',
                          child: Row(
                            children: [
                              const Icon(Icons.toll_rounded, size: 16, color: AppColors.coinGold),
                              const SizedBox(width: 8),
                              Text(
                                'Manage Coins',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontHeading,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'status',
                        child: Text(
                          user.status == UserStatus.active ? 'Deactivate User' : 'Activate User',
                          style: TextStyle(fontFamily: AppTypography.fontHeading, fontSize: 12),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'notify',
                        child: Text(
                          'Send Notification',
                          style: TextStyle(fontFamily: AppTypography.fontHeading, fontSize: 12),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete Account',
                          style: TextStyle(
                            fontFamily: AppTypography.fontHeading,
                            fontSize: 12,
                            color: Color(0xFFF43F5E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRoleDropdown() {
    const roles = {
      'all': 'All Roles',
      'student': 'Student',
      'premium': 'Premium',
      'teacher': 'Teacher',
      'moderator': 'Moderator',
    };
    return AdminTableDropdown(
      value: roles[widget.roleFilter] ?? 'All Roles',
      items: roles.values.toList(),
      onChanged: (v) {
        final key = roles.entries.firstWhere((e) => e.value == v, orElse: () => roles.entries.first).key;
        widget.onRoleFilterChanged(key);
      },
    );
  }

  Widget _buildStatusDropdown() {
    const statuses = {
      'all': 'All Status',
      'active': 'Active',
      'inactive': 'Inactive',
      'blocked': 'Blocked',
    };
    return AdminTableDropdown(
      value: statuses[widget.statusFilter] ?? 'All Status',
      items: statuses.values.toList(),
      onChanged: (v) {
        final key = statuses.entries.firstWhere((e) => e.value == v, orElse: () => statuses.entries.first).key;
        widget.onStatusFilterChanged(key);
      },
    );
  }

  Widget _buildRegistrationDropdown() {
    const registrations = {
      'all': 'All Registration',
      'today': 'Today',
      'week': 'This Week',
      'month': 'This Month',
      'year': 'This Year',
    };
    return AdminTableDropdown(
      value: registrations[widget.registrationFilter] ?? 'All Registration',
      items: registrations.values.toList(),
      onChanged: (v) {
        final key = registrations.entries.firstWhere((e) => e.value == v, orElse: () => registrations.entries.first).key;
        widget.onRegistrationFilterChanged(key);
      },
    );
  }

  Widget _buildViewToggles() {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleBtn(
            icon: Icons.format_list_bulleted_rounded,
            isSelected: !_isGridView,
            onTap: () => setState(() => _isGridView = false),
          ),
          _buildToggleBtn(
            icon: Icons.grid_view_rounded,
            isSelected: _isGridView,
            onTap: () => setState(() => _isGridView = true),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn({required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 15, color: isSelected ? Colors.white : AppColors.textSecondary),
      ),
    );
  }

  Widget _buildFilterButton(bool hasActiveFilter) {
    return AdminTableFiltersButton(
      onTap: _openFilterDialog,
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisExtent: 200,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, i) {
        final user = widget.items[i];
        final isSelected = widget.selectedIds.contains(user.id);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.brandPurple : AppColors.borderSubtle,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: user.role.color.withValues(alpha: 0.12),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontFamily: AppTypography.fontHeading,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: user.role.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontFamily: AppTypography.fontHeading,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontFamily: AppTypography.fontHeading,
                            fontSize: 10.5,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: isSelected,
                    activeColor: AppColors.brandPurple,
                    onChanged: (v) {
                      final newSet = Set<String>.from(widget.selectedIds);
                      if (v == true) {
                        newSet.add(user.id);
                      } else {
                        newSet.remove(user.id);
                      }
                      widget.onSelectionChanged(newSet);
                    },
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  AdminTableStatusBadge(
                    label: user.role.label,
                    backgroundColor: user.role.bgColor,
                    textColor: user.role.color,
                  ),
                  const SizedBox(width: 6),
                  AdminTableStatusBadge(
                    label: user.status.label,
                    backgroundColor: user.status.bgColor,
                    textColor: user.status.color,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enrollments: ${user.enrollmentsCount}',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Tests: ${user.testsAttemptedCount}',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AdminTableActionButton(
                    icon: Icons.visibility_outlined,
                    tooltip: 'View User',
                    onTap: () => widget.onView(user),
                  ),
                  const SizedBox(width: 6),
                  AdminTableActionButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit User',
                    onTap: () => widget.onEdit(user),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static const _colHeaderStyle = TextStyle(
    fontFamily: AppTypography.fontHeading,
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  static const _cellStyle = TextStyle(
    fontFamily: AppTypography.fontHeading,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
}
