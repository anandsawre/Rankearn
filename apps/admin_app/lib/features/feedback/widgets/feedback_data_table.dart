import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class FeedbackDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> feedbacks;
  final String activeTab;
  final ValueChanged<String> onTabChanged;
  final void Function(Map<String, dynamic> feedback) onViewFeedback;
  final void Function(Map<String, dynamic> feedback) onReplyFeedback;
  final int currentPage;
  final int totalCount;
  final ValueChanged<int> onPageChanged;

  const FeedbackDataTable({
    super.key,
    required this.feedbacks,
    required this.activeTab,
    required this.onTabChanged,
    required this.onViewFeedback,
    required this.onReplyFeedback,
    this.currentPage = 1,
    this.totalCount = 2840,
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
                    const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: AppColors.adminPurple),
                    const SizedBox(width: 10),
                    Text(
                      'User Feedbacks ($totalCount)',
                      style: AppTypography.adminCardTitle,
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabPill('all', 'All ($totalCount)', null),
                      const SizedBox(width: 8),
                      _buildTabPill('positive', 'Positive', Icons.thumb_up_alt_rounded),
                      const SizedBox(width: 8),
                      _buildTabPill('neutral', 'Neutral', Icons.remove_circle_outline_rounded),
                      const SizedBox(width: 8),
                      _buildTabPill('negative', 'Negative', Icons.thumb_down_alt_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.adminBorder),

          // Table Content
          if (feedbacks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: Text('No feedback entries match current filters.', style: AppTypography.adminTableSecondary),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 780),
                child: DataTable(
                  horizontalMargin: 20,
                  columnSpacing: 18,
                  headingRowHeight: 44,
                  dataRowMinHeight: 64,
                  dataRowMaxHeight: 74,
                  headingRowColor: WidgetStateProperty.all(AppColors.adminBackground),
                  columns: const [
                    DataColumn(label: Text('#', style: AppTypography.adminTableHead)),
                    DataColumn(label: Text('User', style: AppTypography.adminTableHead)),
                    DataColumn(label: Text('Rating', style: AppTypography.adminTableHead)),
                    DataColumn(label: Text('Feedback / Comment', style: AppTypography.adminTableHead)),
                    DataColumn(label: Text('Type', style: AppTypography.adminTableHead)),
                    DataColumn(label: Text('Feature', style: AppTypography.adminTableHead)),
                    DataColumn(label: Text('Date & Time', style: AppTypography.adminTableHead)),
                    DataColumn(label: Text('Action', style: AppTypography.adminTableHead)),
                  ],
                  rows: feedbacks.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final fb = entry.value;
                    final rating = (fb['rating'] as num?)?.toInt() ?? 5;
                    final name = fb['name']?.toString() ?? 'Candidate';
                    final uid = fb['uid']?.toString() ?? 'UID: ${fb['id'] ?? 'RK$idx'}';
                    final comment = fb['comment']?.toString() ?? '';
                    final type = fb['type']?.toString() ?? 'Feedback';
                    final feature = fb['feature']?.toString() ?? 'Mock Test';
                    final date = fb['date']?.toString() ?? 'Recent';

                    return DataRow(
                      cells: [
                        DataCell(Text('${idx + 1}', style: AppTypography.adminTableNumber)),
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
                                  Text(uid, style: AppTypography.adminTableSecondary.copyWith(fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (starIdx) {
                              return Icon(
                                starIdx < rating ? Icons.star_rounded : Icons.star_border_rounded,
                                size: 14,
                                color: const Color(0xFFF59E0B),
                              );
                            }),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 220,
                            child: Text(
                              comment,
                              style: AppTypography.adminTablePrimary.copyWith(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(_buildTypeBadge(type)),
                        DataCell(_buildFeatureBadge(feature)),
                        DataCell(Text(date, style: AppTypography.adminTableSecondary.copyWith(fontSize: 11))),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.adminPurple),
                                tooltip: 'View Feedback',
                                onPressed: () => onViewFeedback(fb),
                              ),
                              IconButton(
                                icon: const Icon(Icons.reply_rounded, size: 18, color: AppColors.adminSuccess),
                                tooltip: 'Reply to User',
                                onPressed: () => onReplyFeedback(fb),
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
                  'Showing 1 – ${feedbacks.length} of $totalCount feedbacks',
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

  Widget _buildTabPill(String id, String label, IconData? icon) {
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.adminSecondaryText),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.adminSecondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color bg;
    Color fg;
    if (type.toLowerCase().contains('suggest')) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
    } else if (type.toLowerCase().contains('issue') || type.toLowerCase().contains('bug')) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFEF4444);
    } else {
      bg = AppColors.adminPurpleLight;
      fg = AppColors.adminPurple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _buildFeatureBadge(String feature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        feature,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
      ),
    );
  }
}
