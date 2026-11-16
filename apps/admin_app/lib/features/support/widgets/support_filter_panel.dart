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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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

          // Search Field
          AppTextField(
            controller: searchController,
            hintText: 'Search Ticket / User...',
            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.adminSecondaryText),
          ),
          const SizedBox(height: 12),

          // 1. Status Dropdown (Full width, stacked, label on box)
          AppDropdown<String>(
            value: selectedStatus,
            prefixIcon: const Icon(Icons.adjust_rounded, size: 16, color: AppColors.adminPurple),
            items: const [
              AppDropdownItem(value: 'all', label: 'Status: All Statuses'),
              AppDropdownItem(value: 'open', label: 'Status: Open'),
              AppDropdownItem(value: 'in_progress', label: 'Status: In Progress'),
              AppDropdownItem(value: 'resolved', label: 'Status: Resolved'),
              AppDropdownItem(value: 'on_hold', label: 'Status: On Hold'),
            ],
            onChanged: onStatusChanged,
          ),
          const SizedBox(height: 10),

          // 2. Category Dropdown (Full width, stacked, label on box)
          AppDropdown<String>(
            value: selectedCategory,
            prefixIcon: const Icon(Icons.category_rounded, size: 16, color: AppColors.adminPurple),
            items: const [
              AppDropdownItem(value: 'all', label: 'Category: All Categories'),
              AppDropdownItem(value: 'payment', label: 'Category: Payment'),
              AppDropdownItem(value: 'verification', label: 'Category: Verification'),
              AppDropdownItem(value: 'referral', label: 'Category: Referral'),
              AppDropdownItem(value: 'technical', label: 'Category: Technical'),
              AppDropdownItem(value: 'general', label: 'Category: General'),
            ],
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: 10),

          // 3. Priority Dropdown (Full width, stacked, label on box)
          AppDropdown<String>(
            value: selectedPriority,
            prefixIcon: const Icon(Icons.flag_rounded, size: 16, color: AppColors.adminPurple),
            items: const [
              AppDropdownItem(value: 'all', label: 'Priority: All Priorities'),
              AppDropdownItem(value: 'high', label: 'Priority: High Priority'),
              AppDropdownItem(value: 'medium', label: 'Priority: Medium Priority'),
              AppDropdownItem(value: 'low', label: 'Priority: Low Priority'),
            ],
            onChanged: onPriorityChanged,
          ),
          const SizedBox(height: 10),

          // 4. Date Range Dropdown (Full width, stacked, label on box)
          AppDropdown<String>(
            value: selectedDateRange,
            prefixIcon: const Icon(Icons.date_range_rounded, size: 16, color: AppColors.adminPurple),
            items: const [
              AppDropdownItem(value: '30days', label: 'Date: Last 30 Days'),
              AppDropdownItem(value: '7days', label: 'Date: Last 7 Days'),
              AppDropdownItem(value: 'today', label: 'Date: Today'),
              AppDropdownItem(value: 'all', label: 'Date: All Time'),
            ],
            onChanged: onDateRangeChanged,
          ),
          const SizedBox(height: 16),

          // Apply Filters (Full width button)
          AppButton.adminPrimary(
            label: 'Apply Filters',
            leadingIcon: const Icon(Icons.filter_list_rounded, size: 16),
            fullWidth: true,
            onPressed: onApplyFilters,
          ),
        ],
      ),
    );
  }
}
