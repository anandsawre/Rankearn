import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/user_management_item.dart';

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
  final ValueChanged<UserManagementItem> onToggleStatus;
  final ValueChanged<UserManagementItem> onDelete;
  final ValueChanged<UserManagementItem> onSendNotification;

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
    required this.onToggleStatus,
    required this.onDelete,
    required this.onSendNotification,
  });

  @override
  State<UsersTableCard> createState() => _UsersTableCardState();
}

class _UsersTableCardState extends State<UsersTableCard> {
  bool _isGridView = false;
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant UsersTableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery && _searchCtrl.text != widget.searchQuery) {
      _searchCtrl.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
    showDialog(
      context: context,
      builder: (ctx) {
        String tempRole = widget.roleFilter;
        String tempStatus = widget.statusFilter;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.tune_rounded, color: Color(0xFF5636F5), size: 20),
                  SizedBox(width: 8),
                  Text('Filter Users', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppDropdown<String>.simple(
                    label: 'Role',
                    value: tempRole,
                    isDense: true,
                    items: const ['all', 'student', 'premium', 'teacher', 'moderator'],
                    itemLabel: (v) => {
                      'all': 'All Roles',
                      'student': 'Student',
                      'premium': 'Premium',
                      'teacher': 'Teacher',
                      'moderator': 'Moderator',
                    }[v] ?? v,
                    onChanged: (v) {
                      if (v != null) setModalState(() => tempRole = v);
                    },
                  ),
                  const SizedBox(height: 14),
                  AppDropdown<String>.simple(
                    label: 'Status',
                    value: tempStatus,
                    isDense: true,
                    items: const ['all', 'active', 'inactive', 'blocked'],
                    itemLabel: (v) => {
                      'all': 'All Status',
                      'active': 'Active',
                      'inactive': 'Inactive',
                      'blocked': 'Blocked',
                    }[v] ?? v,
                    onChanged: (v) {
                      if (v != null) setModalState(() => tempStatus = v);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    widget.onRoleFilterChanged('all');
                    widget.onStatusFilterChanged('all');
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Reset', style: TextStyle(color: Color(0xFF64748B))),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onRoleFilterChanged(tempRole);
                    widget.onStatusFilterChanged(tempStatus);
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5636F5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ],
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          LayoutBuilder(
            builder: (context, cardConstraints) {
              final isNarrow = cardConstraints.maxWidth < 1180;

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0084FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.description_rounded, color: Colors.white, size: 14),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Users List (${_formatNumber(widget.totalCount)})',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101A3A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          width: 240,
                          height: 36,
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: _searchDecoration(),
                            onChanged: widget.onSearchChanged,
                          ),
                        ),
                        _buildRoleDropdown(),
                        _buildStatusDropdown(),
                        _buildRegistrationDropdown(),
                        _buildViewToggles(),
                        _buildFilterButton(hasActiveFilter),
                      ],
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0084FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.description_rounded, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Users List (${_formatNumber(widget.totalCount)})',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101A3A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: 280,
                        height: 36,
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: _searchDecoration(),
                          onChanged: widget.onSearchChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildRoleDropdown(),
                      const SizedBox(width: 8),
                      _buildStatusDropdown(),
                      const SizedBox(width: 8),
                      _buildRegistrationDropdown(),
                      const SizedBox(width: 8),
                      _buildViewToggles(),
                      const SizedBox(width: 8),
                      _buildFilterButton(hasActiveFilter),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Main Table or Grid View
          if (_isGridView)
            _buildGridView()
          else
            _buildTableView(allSelected),

          const SizedBox(height: 14),

          // Pagination Footer
          _buildPaginationFooter(),
        ],
      ),
    );
  }

  InputDecoration _searchDecoration() {
    return InputDecoration(
      hintText: 'Search users by name, email, or phone...',
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF5636F5)),
      ),
      isDense: true,
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
    return AppDropdownFilter<String>(
      height: 36,
      value: widget.roleFilter,
      items: roles.keys.toList(),
      itemLabel: (v) => roles[v] ?? v,
      onChanged: (v) {
        if (v != null) widget.onRoleFilterChanged(v);
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
    return AppDropdownFilter<String>(
      height: 36,
      value: widget.statusFilter,
      items: statuses.keys.toList(),
      itemLabel: (v) => statuses[v] ?? v,
      onChanged: (v) {
        if (v != null) widget.onStatusFilterChanged(v);
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
    return AppDropdownFilter<String>(
      height: 36,
      value: widget.registrationFilter,
      items: registrations.keys.toList(),
      itemLabel: (v) => registrations[v] ?? v,
      onChanged: (v) {
        if (v != null) widget.onRegistrationFilterChanged(v);
      },
    );
  }

  Widget _buildViewToggles() {
    return Container(
      height: 36,
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildFilterButton(bool hasActiveFilter) {
    return InkWell(
      onTap: _openFilterDialog,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: hasActiveFilter ? const Color(0xFFEDE9FE) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasActiveFilter ? const Color(0xFF8B5CF6) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 16,
              color: hasActiveFilter ? const Color(0xFF6B4EFF) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              'Filters',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasActiveFilter ? const Color(0xFF6B4EFF) : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableView(bool allSelected) {
    if (widget.items.isEmpty) {
      return Container(
        height: 280,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline_rounded, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            const Text(
              'No users found',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try adjusting your search query or filters',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: math.max(constraints.maxWidth, 960)),
            child: DataTable(
              onSelectAll: _toggleSelectAll,
              headingRowHeight: 40,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 58,
              horizontalMargin: 12,
              columnSpacing: 16,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: [
                const DataColumn(label: Text('#', style: _colHeaderStyle)),
                const DataColumn(label: Text('User Details', style: _colHeaderStyle)),
                const DataColumn(
                  label: Row(
                    children: [
                      Text('Role', style: _colHeaderStyle),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF94A3B8)),
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
                      Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF94A3B8)),
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
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF101A3A),
                                ),
                              ),
                              Text(
                                user.email,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: user.role.bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: user.role.color,
                          ),
                        ),
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
                              fontSize: 11.5,
                              color: user.lastActive.toLowerCase().contains('online')
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF64748B),
                              fontWeight: user.lastActive.toLowerCase().contains('online')
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: user.status.bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.status.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: user.status.color,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(user.joinedDateFormatted, style: _cellStyle)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionIconBtn(
                            icon: Icons.visibility_outlined,
                            onTap: () => widget.onView(user),
                          ),
                          const SizedBox(width: 4),
                          _buildActionIconBtn(
                            icon: Icons.edit_outlined,
                            onTap: () => widget.onEdit(user),
                          ),
                          const SizedBox(width: 4),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, size: 16, color: Color(0xFF64748B)),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            onSelected: (val) {
                              if (val == 'status') widget.onToggleStatus(user);
                              if (val == 'notify') widget.onSendNotification(user);
                              if (val == 'delete') widget.onDelete(user);
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'status',
                                child: Text(
                                  user.status == UserStatus.active ? 'Deactivate User' : 'Activate User',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'notify',
                                child: Text('Send Notification', style: TextStyle(fontSize: 12)),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete Account', style: TextStyle(fontSize: 12, color: Color(0xFFF43F5E))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionIconBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: const Color(0xFF64748B)),
      ),
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
              color: isSelected ? const Color(0xFF5636F5) : const Color(0xFFE2E8F0),
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
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: user.role.color),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        Text(user.email, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: isSelected,
                    activeColor: const Color(0xFF5636F5),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: user.role.bgColor, borderRadius: BorderRadius.circular(4)),
                    child: Text(user.role.label, style: TextStyle(fontSize: 10, color: user.role.color, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: user.status.bgColor, borderRadius: BorderRadius.circular(4)),
                    child: Text(user.status.label, style: TextStyle(fontSize: 10, color: user.status.color, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Enrollments: ${user.enrollmentsCount}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                  Text('Tests: ${user.testsAttemptedCount}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionIconBtn(icon: Icons.visibility_outlined, onTap: () => widget.onView(user)),
                  const SizedBox(width: 6),
                  _buildActionIconBtn(icon: Icons.edit_outlined, onTap: () => widget.onEdit(user)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaginationFooter() {
    final start = widget.totalCount == 0 ? 0 : (widget.currentPage - 1) * widget.pageSize + 1;
    final end = math.min(widget.currentPage * widget.pageSize, widget.totalCount);
    final totalPages = math.max(1, (widget.totalCount / widget.pageSize).ceil());

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 650;

        final infoText = Text(
          'Showing $start to $end of ${_formatNumber(widget.totalCount)} users',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        );

        final pageControls = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPageNavBtn(
              icon: Icons.chevron_left_rounded,
              onTap: widget.currentPage > 1 ? () => widget.onPageChanged(widget.currentPage - 1) : null,
            ),
            const SizedBox(width: 4),
            ..._generatePageButtons(totalPages),
            const SizedBox(width: 4),
            _buildPageNavBtn(
              icon: Icons.chevron_right_rounded,
              onTap: widget.currentPage < totalPages ? () => widget.onPageChanged(widget.currentPage + 1) : null,
            ),
          ],
        );

        final pageSizeDropdown = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Show ', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            AppDropdownFilter<int>(
              value: widget.pageSize,
              items: const [7, 10, 20, 50],
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              borderRadius: BorderRadius.circular(6),
              onChanged: (v) {
                if (v != null) widget.onPageSizeChanged(v);
              },
            ),
            const Text(' per page', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        );

        if (isNarrow) {
          return Column(
            children: [
              infoText,
              const SizedBox(height: 10),
              pageControls,
              const SizedBox(height: 10),
              pageSizeDropdown,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            infoText,
            pageControls,
            pageSizeDropdown,
          ],
        );
      },
    );
  }

  List<Widget> _generatePageButtons(int totalPages) {
    final list = <Widget>[];

    // Reference displays pages 1, 2, 3, 4, 5, ..., 1780
    final maxToShow = math.min(5, totalPages);
    for (int i = 1; i <= maxToShow; i++) {
      list.add(_buildPageNumberBtn(i, i == widget.currentPage));
      list.add(const SizedBox(width: 4));
    }

    if (totalPages > 6) {
      list.add(
        const SizedBox(
          width: 24,
          child: Center(
            child: Text('...', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ),
        ),
      );
      list.add(const SizedBox(width: 4));
      list.add(_buildPageNumberBtn(totalPages, widget.currentPage == totalPages));
    }

    return list;
  }

  Widget _buildPageNumberBtn(int pageNum, bool isSelected) {
    return InkWell(
      onTap: () => widget.onPageChanged(pageNum),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5636F5) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        alignment: Alignment.center,
        child: Text(
          pageNum.toString(),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildPageNavBtn({required IconData icon, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }

  static const _colHeaderStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Color(0xFF64748B),
  );

  static const _cellStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF101A3A),
  );

  static String _formatNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write(',');
        count = 0;
      }
    }
    return buffer.toString().split('').reversed.join('');
  }
}
