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
        value: _formatNumber(totalSent),
        subtitle: 'Broadcast dispatches',
        icon: Icons.send_rounded,
        color: AppColors.adminPurple,
        iconBgColor: AppColors.adminPurpleLight,
        iconColor: AppColors.adminPurple,
      ),
      AdminMetricCard(
        title: 'Total Recipients',
        value: _formatNumber(totalRecipients),
        subtitle: 'Audience reach',
        icon: Icons.people_alt_rounded,
        color: AppColors.adminBlue,
        iconBgColor: AppColors.adminBlueLight,
        iconColor: AppColors.adminBlue,
      ),
      AdminMetricCard(
        title: 'Total Reads',
        value: _formatNumber(totalReads),
        subtitle: 'Opened notifications',
        icon: Icons.mark_email_read_rounded,
        color: AppColors.adminSuccess,
        iconBgColor: AppColors.adminSuccessLight,
        iconColor: AppColors.adminSuccess,
      ),
      AdminMetricCard(
        title: 'Total Clicks',
        value: _formatNumber(totalClicks),
        subtitle: 'Interactions & CTAs',
        icon: Icons.ads_click_rounded,
        color: AppColors.adminWarning,
        iconBgColor: AppColors.adminAmberLight,
        iconColor: AppColors.adminWarning,
      ),
      AdminMetricCard(
        title: 'CTR (Click Rate)',
        value: '${ctr.toStringAsFixed(1)}%',
        subtitle: 'Avg engagement rate',
        icon: Icons.trending_up_rounded,
        color: AppColors.adminViolet,
        iconBgColor: AppColors.adminPurpleLight,
        iconColor: AppColors.adminViolet,
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
