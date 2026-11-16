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
  final ValueChanged<int> onPageChanged;

  const SupportDataTable({
    super.key,
    required this.tickets,
    required this.activeTab,
    required this.onTabChanged,
    required this.onViewTicket,
    required this.onReplyTicket,
    this.currentPage = 1,
    this.totalCount = 1248,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title and Tabs
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.confirmation_number_outlined, size: 20, color: AppColors.adminPurple),
                    const SizedBox(width: 10),
                    Text(
                      'Support Tickets ($totalCount)',
                      style: AppTypography.adminCardTitle,
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabPill('all', 'All ($totalCount)'),
                      const SizedBox(width: 8),
                      _buildTabPill('open', 'Open (96)'),
                      const SizedBox(width: 8),
                      _buildTabPill('in_progress', 'In Progress (218)'),
                      const SizedBox(width: 8),
                      _buildTabPill('resolved', 'Resolved (846)'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.adminBorder),

          // Table Content
          if (tickets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: Text('No support tickets match current filters.', style: AppTypography.adminTableSecondary),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 800),
                child: DataTable(
                  horizontalMargin: 20,
                  columnSpacing: 18,
                  headingRowHeight: 44,
                  dataRowMinHeight: 64,
                  dataRowMaxHeight: 74,
                  headingRowColor: WidgetStateProperty.all(AppColors.adminBackground),
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
                        DataCell(Text('${idx + 1}', style: AppTypography.adminTableNumber)),
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
                                radius: 16,
                                backgroundColor: AppColors.adminPurpleLight,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.adminPurple),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(name, style: AppTypography.adminTablePrimary),
                                  SizedBox(
                                    width: 190,
                                    child: Text(
                                      subject,
                                      style: AppTypography.adminTableSecondary.copyWith(fontSize: 11),
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
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.adminPurple),
                                tooltip: 'View Ticket',
                                onPressed: () => onViewTicket(t),
                              ),
                              IconButton(
                                icon: const Icon(Icons.reply_rounded, size: 18, color: AppColors.adminSuccess),
                                tooltip: 'Reply',
                                onPressed: () => onReplyTicket(t),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

          const Divider(height: 1, color: AppColors.adminBorder),

          // Pagination Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing 1 – ${tickets.length} of $totalCount tickets',
                  style: AppTypography.adminTableSecondary.copyWith(fontSize: 12),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.chevron_left_rounded, size: 18, color: AppColors.adminSecondaryText),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.adminPurple,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$currentPage',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => onPageChanged(currentPage + 1),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.adminSecondaryText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.adminPurple : AppColors.adminBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.adminPurple : AppColors.adminBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.adminSecondaryText,
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
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
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
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
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
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
          ),
        ],
      ),
    );
  }
}
