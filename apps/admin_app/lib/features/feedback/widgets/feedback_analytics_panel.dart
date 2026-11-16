import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class FeedbackAnalyticsPanel extends StatelessWidget {
  final int totalCount;
  final int positiveCount;
  final int neutralCount;
  final int negativeCount;
  final Map<int, int>? ratingCounts;
  final VoidCallback onReplyAll;
  final VoidCallback onManageRatings;
  final VoidCallback onExportCsv;

  const FeedbackAnalyticsPanel({
    super.key,
    this.totalCount = 0,
    this.positiveCount = 0,
    this.neutralCount = 0,
    this.negativeCount = 0,
    this.ratingCounts,
    required this.onReplyAll,
    required this.onManageRatings,
    required this.onExportCsv,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTotal = totalCount > 0 ? totalCount : 1;
    final r5 = ratingCounts?[5] ?? (totalCount > 0 ? positiveCount : 0);
    final r4 = ratingCounts?[4] ?? 0;
    final r3 = ratingCounts?[3] ?? neutralCount;
    final r2 = ratingCounts?[2] ?? 0;
    final r1 = ratingCounts?[1] ?? negativeCount;

    final p5 = totalCount > 0 ? r5 / effectiveTotal : 0.0;
    final p4 = totalCount > 0 ? r4 / effectiveTotal : 0.0;
    final p3 = totalCount > 0 ? r3 / effectiveTotal : 0.0;
    final p2 = totalCount > 0 ? r2 / effectiveTotal : 0.0;
    final p1 = totalCount > 0 ? r1 / effectiveTotal : 0.0;

    final positivePct = totalCount > 0 ? (positiveCount / effectiveTotal * 100) : 0.0;
    final neutralPct = totalCount > 0 ? (neutralCount / effectiveTotal * 100) : 0.0;
    final negativePct = totalCount > 0 ? (negativeCount / effectiveTotal * 100) : 0.0;

    final slices = totalCount > 0
        ? [
            DonutSlice(
              label: 'Positive',
              percentage: double.parse(positivePct.toStringAsFixed(1)),
              color: AppColors.adminSuccess,
            ),
            DonutSlice(
              label: 'Neutral',
              percentage: double.parse(neutralPct.toStringAsFixed(1)),
              color: const Color(0xFFF59E0B),
            ),
            DonutSlice(
              label: 'Negative',
              percentage: double.parse(negativePct.toStringAsFixed(1)),
              color: AppColors.adminDanger,
            ),
          ]
        : const [
            DonutSlice(
              label: 'No Feedback',
              percentage: 100.0,
              color: AppColors.adminNeutralLight,
            ),
          ];

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
              _buildStarRow(5, p5, '$r5 (${(p5 * 100).toStringAsFixed(1)}%)'),
              const SizedBox(height: 10),
              _buildStarRow(4, p4, '$r4 (${(p4 * 100).toStringAsFixed(1)}%)'),
              const SizedBox(height: 10),
              _buildStarRow(3, p3, '$r3 (${(p3 * 100).toStringAsFixed(1)}%)'),
              const SizedBox(height: 10),
              _buildStarRow(2, p2, '$r2 (${(p2 * 100).toStringAsFixed(1)}%)'),
              const SizedBox(height: 10),
              _buildStarRow(1, p1, '$r1 (${(p1 * 100).toStringAsFixed(1)}%)'),
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
                totalCount: totalCount,
                totalLabel: 'Total',
                slices: slices,
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
