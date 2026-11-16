import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class FeedbackFilterPanel extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedRating;
  final String selectedType;
  final String selectedSentiment;
  final String selectedFeature;
  final String selectedDateRange;
  final ValueChanged<String?> onRatingChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onSentimentChanged;
  final ValueChanged<String?> onFeatureChanged;
  final ValueChanged<String?> onDateRangeChanged;
  final VoidCallback onApplyFilters;
  final VoidCallback onReset;

  const FeedbackFilterPanel({
    super.key,
    required this.searchController,
    required this.selectedRating,
    required this.selectedType,
    required this.selectedSentiment,
    required this.selectedFeature,
    required this.selectedDateRange,
    required this.onRatingChanged,
    required this.onTypeChanged,
    required this.onSentimentChanged,
    required this.onFeatureChanged,
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
                        'Feedback Filters',
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
            hintText: 'Search by keyword, user or ID...',
            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.adminSecondaryText),
          ),
          const SizedBox(height: 14),

          // Rating
          Text('Rating', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppDropdown<String>(
            inlineLabel: true,
            value: selectedRating,
            items: const [
              AppDropdownItem(value: 'all', label: 'All Ratings'),
              AppDropdownItem(value: '5', label: '5 Stars ⭐⭐⭐⭐⭐'),
              AppDropdownItem(value: '4', label: '4 Stars ⭐⭐⭐⭐'),
              AppDropdownItem(value: '3', label: '3 Stars ⭐⭐⭐'),
              AppDropdownItem(value: '2', label: '2 Stars ⭐⭐'),
              AppDropdownItem(value: '1', label: '1 Star ⭐'),
            ],
            onChanged: onRatingChanged,
          ),
          const SizedBox(height: 14),

          // Feedback Type
          Text('Feedback Type', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppDropdown<String>(
            inlineLabel: true,
            value: selectedType,
            items: const [
              AppDropdownItem(value: 'all', label: 'All Types'),
              AppDropdownItem(value: 'Feedback', label: 'Feedback'),
              AppDropdownItem(value: 'Suggestion', label: 'Suggestion'),
              AppDropdownItem(value: 'Issue', label: 'Issue / Bug'),
            ],
            onChanged: onTypeChanged,
          ),
          const SizedBox(height: 14),

          // Sentiment
          Text('Sentiment', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppDropdown<String>(
            inlineLabel: true,
            value: selectedSentiment,
            items: const [
              AppDropdownItem(value: 'all', label: 'All (Positive / Neutral / Negative)'),
              AppDropdownItem(value: 'positive', label: 'Positive (4-5 Stars)'),
              AppDropdownItem(value: 'neutral', label: 'Neutral (3 Stars)'),
              AppDropdownItem(value: 'negative', label: 'Negative (1-2 Stars)'),
            ],
            onChanged: onSentimentChanged,
          ),
          const SizedBox(height: 14),

          // Module / Feature
          Text('Module / Feature', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppDropdown<String>(
            inlineLabel: true,
            value: selectedFeature,
            items: const [
              AppDropdownItem(value: 'all', label: 'All Features'),
              AppDropdownItem(value: 'Mock Test', label: 'Mock Test Series'),
              AppDropdownItem(value: 'Study Material', label: 'Study Material / PDF'),
              AppDropdownItem(value: 'Live Quiz', label: 'Live Quiz & Contests'),
              AppDropdownItem(value: 'Referral', label: 'Referral & Earnings'),
              AppDropdownItem(value: 'App UI', label: 'App UI & Experience'),
            ],
            onChanged: onFeatureChanged,
          ),
          const SizedBox(height: 14),

          // Date Range
          Text('Date Range', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 6),
          AppDropdown<String>(
            inlineLabel: true,
            value: selectedDateRange,
            prefixIcon: const Icon(Icons.date_range_rounded, size: 18, color: AppColors.adminPurple),
            items: const [
              AppDropdownItem(value: '30days', label: 'Last 30 Days'),
              AppDropdownItem(value: '7days', label: 'Last 7 Days'),
              AppDropdownItem(value: 'today', label: 'Today'),
              AppDropdownItem(value: 'all', label: 'All Time'),
            ],
            onChanged: onDateRangeChanged,
          ),
          const SizedBox(height: 20),

          // Apply Button
          AppButton.adminPrimary(
            label: 'Apply Filters',
            leadingIcon: const Icon(Icons.send_rounded, size: 15),
            onPressed: onApplyFilters,
          ),
        ],
      ),
    );
  }
}
