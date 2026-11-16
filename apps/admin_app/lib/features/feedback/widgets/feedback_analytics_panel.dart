import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class FeedbackAnalyticsPanel extends StatelessWidget {
  final VoidCallback onReplyAll;
  final VoidCallback onManageRatings;
  final VoidCallback onExportCsv;

  const FeedbackAnalyticsPanel({
    super.key,
    required this.onReplyAll,
    required this.onManageRatings,
    required this.onExportCsv,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Rating Distribution Card
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
                  const Icon(Icons.star_half_rounded, size: 18, color: AppColors.adminPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rating Distribution',
                      style: AppTypography.adminCardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStarRow(5, 0.527, '1,498 (52.7%)'),
              const SizedBox(height: 10),
              _buildStarRow(4, 0.170, '484 (17.0%)'),
              const SizedBox(height: 10),
              _buildStarRow(3, 0.110, '312 (11.0%)'),
              const SizedBox(height: 10),
              _buildStarRow(2, 0.076, '216 (7.6%)'),
              const SizedBox(height: 10),
              _buildStarRow(1, 0.116, '330 (11.6%)'),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. Feedback Sentiment Donut Chart Card
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
                  const Icon(Icons.pie_chart_rounded, size: 18, color: AppColors.adminPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Feedback Sentiment',
                      style: AppTypography.adminCardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppDonutChart(
                chartSize: 110,
                totalCount: 2840,
                totalLabel: 'Total',
                slices: const [
                  DonutSlice(
                    label: 'Positive',
                    percentage: 69.8,
                    color: AppColors.adminSuccess,
                  ),
                  DonutSlice(
                    label: 'Neutral',
                    percentage: 20.6,
                    color: Color(0xFFF59E0B),
                  ),
                  DonutSlice(
                    label: 'Negative',
                    percentage: 9.6,
                    color: AppColors.adminDanger,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 3. Quick Actions Card
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
              _buildQuickActionTile(
                icon: Icons.mail_outline_rounded,
                title: 'Reply to Feedbacks',
                color: AppColors.adminPurple,
                onTap: onReplyAll,
              ),
              const SizedBox(height: 8),
              _buildQuickActionTile(
                icon: Icons.star_border_rounded,
                title: 'Manage Ratings & Reviews',
                color: const Color(0xFFF59E0B),
                onTap: onManageRatings,
              ),
              const SizedBox(height: 8),
              _buildQuickActionTile(
                icon: Icons.download_rounded,
                title: 'Export Feedbacks (CSV)',
                color: const Color(0xFF0284C7),
                onTap: onExportCsv,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStarRow(int stars, double progress, String label) {
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$stars', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.adminPrimaryText)),
            const SizedBox(width: 2),
            const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.adminBackground,
              valueColor: const AlwaysStoppedAnimation(AppColors.adminPurple),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.adminSecondaryText),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionTile({
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
