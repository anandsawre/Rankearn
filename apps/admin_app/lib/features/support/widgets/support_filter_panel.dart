import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SupportFilterPanel extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedStatus;
  final String selectedCategory;
  final String selectedPriority;
  final String selectedDateRange;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onPriorityChanged;
  final ValueChanged<String?> onDateRangeChanged;
  final VoidCallback onApplyFilters;
  final VoidCallback onReset;
  final VoidCallback onCreateTicket;
  final VoidCallback onBulkReply;
  final VoidCallback onManageCategories;
  final VoidCallback onHelpCenter;

  const SupportFilterPanel({
    super.key,
    required this.searchController,
    required this.selectedStatus,
    required this.selectedCategory,
    required this.selectedPriority,
    required this.selectedDateRange,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onDateRangeChanged,
    required this.onApplyFilters,
    required this.onReset,
    required this.onCreateTicket,
    required this.onBulkReply,
    required this.onManageCategories,
    required this.onHelpCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Ticket Filters
        Container(
          padding: const EdgeInsets.all(20),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.tune_rounded, size: 18, color: AppColors.adminPurple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ticket Filters',
                            style: AppTypography.adminCardTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onReset,
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.adminPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search
              AppTextField(
                controller: searchController,
                hintText: 'Search Ticket / User...',
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.adminSecondaryText),
              ),
              const SizedBox(height: 14),

              // Status
              Text('Status', style: AppTypography.adminFieldLabelSmall),
              const SizedBox(height: 6),
              AppDropdown<String>(
                inlineLabel: true,
                value: selectedStatus,
                items: const [
                  AppDropdownItem(value: 'all', label: 'All Status'),
                  AppDropdownItem(value: 'open', label: 'Open'),
                  AppDropdownItem(value: 'in_progress', label: 'In Progress'),
                  AppDropdownItem(value: 'resolved', label: 'Resolved'),
                  AppDropdownItem(value: 'on_hold', label: 'On Hold'),
                ],
                onChanged: onStatusChanged,
              ),
              const SizedBox(height: 14),

              // Category
              Text('Category', style: AppTypography.adminFieldLabelSmall),
              const SizedBox(height: 6),
              AppDropdown<String>(
                inlineLabel: true,
                value: selectedCategory,
                items: const [
                  AppDropdownItem(value: 'all', label: 'All Categories'),
                  AppDropdownItem(value: 'Payment', label: 'Payment & Coins'),
                  AppDropdownItem(value: 'Verification', label: 'Account & Verification'),
                  AppDropdownItem(value: 'Referral', label: 'Referral & Rewards'),
                  AppDropdownItem(value: 'Technical', label: 'Technical Issue'),
                  AppDropdownItem(value: 'Withdrawal', label: 'Withdrawal'),
                  AppDropdownItem(value: 'Other', label: 'Other Query'),
                ],
                onChanged: onCategoryChanged,
              ),
              const SizedBox(height: 14),

              // Priority & Date Range in Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Priority', style: AppTypography.adminFieldLabelSmall),
                        const SizedBox(height: 6),
                        AppDropdown<String>(
                          inlineLabel: true,
                          value: selectedPriority,
                          items: const [
                            AppDropdownItem(value: 'all', label: 'All Priorities'),
                            AppDropdownItem(value: 'high', label: 'High Priority'),
                            AppDropdownItem(value: 'medium', label: 'Medium Priority'),
                            AppDropdownItem(value: 'low', label: 'Low Priority'),
                          ],
                          onChanged: onPriorityChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date Range', style: AppTypography.adminFieldLabelSmall),
                        const SizedBox(height: 6),
                        AppDropdown<String>(
                          inlineLabel: true,
                          value: selectedDateRange,
                          prefixIcon: const Icon(Icons.date_range_rounded, size: 16, color: AppColors.adminPurple),
                          items: const [
                            AppDropdownItem(value: '30days', label: 'Last 30 Days'),
                            AppDropdownItem(value: '7days', label: 'Last 7 Days'),
                            AppDropdownItem(value: 'today', label: 'Today'),
                            AppDropdownItem(value: 'all', label: 'All Time'),
                          ],
                          onChanged: onDateRangeChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Apply Filters
              AppButton.adminPrimary(
                label: 'Apply Filters',
                leadingIcon: const Icon(Icons.filter_list_rounded, size: 16),
                onPressed: onApplyFilters,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. Quick Actions
        Container(
          padding: const EdgeInsets.all(20),
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
              Row(
                children: [
                  const Icon(Icons.flash_on_rounded, size: 18, color: AppColors.adminPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Quick Actions',
                      style: AppTypography.adminCardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildActionTile(
                icon: Icons.person_add_alt_1_rounded,
                title: 'Create Ticket for User',
                color: AppColors.adminPurple,
                onTap: onCreateTicket,
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                icon: Icons.mark_chat_read_rounded,
                title: 'Bulk Reply',
                color: const Color(0xFF0284C7),
                onTap: onBulkReply,
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                icon: Icons.category_rounded,
                title: 'Manage Categories',
                color: const Color(0xFFF59E0B),
                onTap: onManageCategories,
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                icon: Icons.menu_book_rounded,
                title: 'FAQ / Help Center',
                color: AppColors.adminSuccess,
                onTap: onHelpCenter,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.adminControl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.adminBackground,
          borderRadius: AppRadii.adminControl,
          border: Border.all(color: AppColors.adminBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.adminPrimaryText),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.adminSecondaryText),
          ],
        ),
      ),
    );
  }
}
