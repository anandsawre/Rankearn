import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SupportDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> tickets;
  final String activeTab;
  final ValueChanged<String> onTabChanged;
  final void Function(Map<String, dynamic> ticket) onViewTicket;
  final void Function(Map<String, dynamic> ticket) onReplyTicket;
  final int currentPage;
  final int totalCount;
  final int openCount;
  final int inProgressCount;
  final int resolvedCount;
  final ValueChanged<int> onPageChanged;
  final int rowsPerPage;

  const SupportDataTable({
    super.key,
    required this.tickets,
    required this.activeTab,
    required this.onTabChanged,
    required this.onViewTicket,
    required this.onReplyTicket,
    this.currentPage = 1,
    this.totalCount = 0,
    this.openCount = 0,
    this.inProgressCount = 0,
    this.resolvedCount = 0,
    required this.onPageChanged,
    this.rowsPerPage = 10,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalCount / rowsPerPage).ceil().clamp(1, 999);

    return AdminDataTableCard(
      title: 'Support Tickets',
      totalCount: totalCount,
      icon: Icons.confirmation_number_outlined,
      iconBgColor: AppColors.adminPurpleLight,
      iconColor: AppColors.adminPurple,
      currentPage: currentPage,
      totalPages: totalPages,
      rowsPerPage: rowsPerPage,
      onPageChanged: onPageChanged,
      itemLabel: 'tickets',
      minWidth: 880.0,
      filterControls: [
        _buildTabPill('all', 'All ($totalCount)'),
        _buildTabPill('open', 'Open ($openCount)'),
        _buildTabPill('in_progress', 'In Progress ($inProgressCount)'),
        _buildTabPill('resolved', 'Resolved ($resolvedCount)'),
      ],
      columns: const [
        DataColumn(label: Text('#', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('Ticket ID', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('User & Subject', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('Category', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('Priority', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('Status', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('Last Update', style: AppTypography.adminTableHead)),
        DataColumn(label: Text('Actions', style: AppTypography.adminTableHead)),
      ],
      rows: tickets.asMap().entries.map((entry) {
        final idx = entry.key;
        final t = entry.value;
        final ticketId = t['id']?.toString() ?? 'TK-202611${48 - idx}';
        final name = t['name']?.toString() ?? 'Candidate';
        final subject = t['subject']?.toString() ?? t['lastMsg']?.toString() ?? 'Support Query';
        final category = t['category']?.toString() ?? 'Payment';
        final priority = t['priority']?.toString() ?? 'High';
        final status = t['status']?.toString() ?? 'open';
        final lastTime = t['lastTime']?.toString() ?? 'Recent';

        return DataRow(
          cells: [
            DataCell(Text('${(currentPage - 1) * rowsPerPage + idx + 1}', style: AppTypography.adminTableNumber)),
            DataCell(
              Text(
                ticketId,
                style: AppTypography.adminTablePrimary.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.adminPrimaryText,
                  fontSize: 12,
                ),
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.adminPurpleLight,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.adminPurple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(name, style: AppTypography.adminTablePrimary.copyWith(fontSize: 12)),
                      SizedBox(
                        width: 170,
                        child: Text(
                          subject,
                          style: AppTypography.adminTableSecondary.copyWith(fontSize: 10.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DataCell(_buildCategoryPill(category)),
            DataCell(_buildPriorityPill(priority)),
            DataCell(_buildStatusPill(status)),
            DataCell(Text(lastTime, style: AppTypography.adminTableSecondary.copyWith(fontSize: 11))),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminTableActionButton(
                    icon: Icons.visibility_outlined,
                    tooltip: 'View & Chat',
                    color: AppColors.adminPurple,
                    onTap: () => onViewTicket(t),
                  ),
                  const SizedBox(width: 6),
                  AdminTableActionButton(
                    icon: Icons.reply_rounded,
                    tooltip: 'Reply to Ticket',
                    color: AppColors.adminSuccess,
                    onTap: () => onReplyTicket(t),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
      emptyWidget: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.confirmation_number_outlined, size: 40, color: AppColors.textMuted),
              SizedBox(height: 10),
              Text(
                'No support tickets match current filters',
                style: AppTypography.adminTableSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabPill(String id, String label) {
    final isSelected = activeTab == id;
    return InkWell(
      onTap: () => onTabChanged(id),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.adminPurple : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.adminPurple : AppColors.borderSubtle,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.fontHeading,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String category) {
    IconData icon;
    Color color;

    if (category.toLowerCase().contains('pay')) {
      icon = Icons.credit_card_rounded;
      color = const Color(0xFFD97706);
    } else if (category.toLowerCase().contains('verif')) {
      icon = Icons.verified_user_rounded;
      color = const Color(0xFF0284C7);
    } else if (category.toLowerCase().contains('refer')) {
      icon = Icons.share_rounded;
      color = AppColors.adminPurple;
    } else if (category.toLowerCase().contains('tech')) {
      icon = Icons.build_rounded;
      color = const Color(0xFF6366F1);
    } else {
      icon = Icons.account_balance_wallet_rounded;
      color = AppColors.adminSuccess;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(45), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityPill(String priority) {
    Color color;
    IconData icon;
    if (priority.toLowerCase().contains('high')) {
      color = AppColors.adminDanger;
      icon = Icons.keyboard_double_arrow_up_rounded;
    } else if (priority.toLowerCase().contains('med')) {
      color = const Color(0xFFF59E0B);
      icon = Icons.drag_handle_rounded;
    } else {
      color = AppColors.adminSuccess;
      icon = Icons.keyboard_arrow_down_rounded;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          priority,
          style: TextStyle(
            fontFamily: AppTypography.fontHeading,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(String status) {
    Color bg;
    Color fg;
    String label;

    if (status.toLowerCase().contains('res')) {
      bg = const Color(0xFFECFDF5);
      fg = const Color(0xFF059669);
      label = 'Resolved';
    } else if (status.toLowerCase().contains('prog')) {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF2563EB);
      label = 'In Progress';
    } else if (status.toLowerCase().contains('hold')) {
      bg = const Color(0xFFF3E8FF);
      fg = const Color(0xFF7C3AED);
      label = 'On Hold';
    } else {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
      label = 'Open';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withAlpha(50), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
