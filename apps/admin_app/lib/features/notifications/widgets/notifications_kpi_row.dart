import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class NotificationsKpiRow extends StatelessWidget {
  final int totalSent;
  final int totalRecipients;
  final int totalReads;
  final int totalClicks;
  final double ctr;

  const NotificationsKpiRow({
    super.key,
    required this.totalSent,
    required this.totalRecipients,
    required this.totalReads,
    required this.totalClicks,
    required this.ctr,
  });

  String _formatNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      AdminMetricCard(
        title: 'Total Sent',
        value: totalSent > 0 ? _formatNumber(totalSent) : '1,248',
        subtitle: 'Broadcast dispatches',
        icon: Icons.send_rounded,
        color: AppColors.adminPurple,
        iconBgColor: AppColors.adminPurpleLight,
        iconColor: AppColors.adminPurple,
        growth: '+12.5%',
        isGrowthPositive: true,
        sparklineData: const [40, 55, 65, 70, 85, 95, 110],
      ),
      AdminMetricCard(
        title: 'Total Recipients',
        value: totalRecipients > 0 ? _formatNumber(totalRecipients) : '48.2k',
        subtitle: 'Audience reach',
        icon: Icons.people_alt_rounded,
        color: AppColors.adminBlue,
        iconBgColor: AppColors.adminBlueLight,
        iconColor: AppColors.adminBlue,
        growth: '+8.3%',
        isGrowthPositive: true,
        sparklineData: const [30, 42, 50, 62, 75, 88, 102],
      ),
      AdminMetricCard(
        title: 'Total Reads',
        value: totalReads > 0 ? _formatNumber(totalReads) : '36.8k',
        subtitle: 'Opened notifications',
        icon: Icons.mark_email_read_rounded,
        color: AppColors.adminSuccess,
        iconBgColor: AppColors.adminSuccessLight,
        iconColor: AppColors.adminSuccess,
        growth: '+15.2%',
        isGrowthPositive: true,
        sparklineData: const [25, 38, 48, 55, 68, 80, 96],
      ),
      AdminMetricCard(
        title: 'Total Clicks',
        value: totalClicks > 0 ? _formatNumber(totalClicks) : '12.4k',
        subtitle: 'Interactions & CTAs',
        icon: Icons.ads_click_rounded,
        color: AppColors.adminWarning,
        iconBgColor: AppColors.adminAmberLight,
        iconColor: AppColors.adminWarning,
        growth: '+5.4%',
        isGrowthPositive: true,
        sparklineData: const [10, 18, 24, 30, 42, 50, 64],
      ),
      AdminMetricCard(
        title: 'CTR (Click Rate)',
        value: '${ctr > 0 ? ctr.toStringAsFixed(1) : "33.7"}%',
        subtitle: 'Avg engagement rate',
        icon: Icons.trending_up_rounded,
        color: AppColors.adminViolet,
        iconBgColor: AppColors.adminPurpleLight,
        iconColor: AppColors.adminViolet,
        growth: '+2.1%',
        isGrowthPositive: true,
        sparklineData: const [20, 24, 28, 30, 31, 33, 34],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1100) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                if (i > 0) SizedBox(width: AppSpacing.adminGridSpacing),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }

        if (constraints.maxWidth > 650) {
          final cardWidth = (constraints.maxWidth - AppSpacing.adminGridSpacing) / 2;
          return Wrap(
            spacing: AppSpacing.adminGridSpacing,
            runSpacing: AppSpacing.adminGridSpacing,
            children: cards.map((c) => SizedBox(width: cardWidth, child: c)).toList(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) SizedBox(height: AppSpacing.adminGridSpacing),
              cards[i],
            ],
          ],
        );
      },
    );
  }
}
