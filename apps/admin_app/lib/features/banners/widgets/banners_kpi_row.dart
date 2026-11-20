import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class BannersKpiRow extends StatelessWidget {
  final int totalBanners;
  final int activeBanners;
  final int scheduledBanners;
  final int inactiveBanners;
  final int totalViews;
  final int totalClicks;
  final double ctr;

  const BannersKpiRow({
    super.key,
    required this.totalBanners,
    required this.activeBanners,
    required this.scheduledBanners,
    required this.inactiveBanners,
    required this.totalViews,
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
    final statusCards = [
      AdminMetricCard(
        title: 'Total Banners',
        value: totalBanners.toString(),
        subtitle: 'All created assets',
        icon: Icons.photo_library_rounded,
        color: AppColors.adminPurple,
        iconBgColor: AppColors.adminPurpleLight,
        iconColor: AppColors.adminPurple,
        growth: '+8.3%',
        isGrowthPositive: true,
        sparklineData: const [16, 18, 19, 21, 22, 23, 24],
      ),
      AdminMetricCard(
        title: 'Active Banners',
        value: activeBanners.toString(),
        subtitle: 'Currently serving',
        icon: Icons.check_circle_rounded,
        color: AppColors.adminSuccess,
        iconBgColor: AppColors.adminSuccessLight,
        iconColor: AppColors.adminSuccess,
        growth: '+12.5%',
        isGrowthPositive: true,
        sparklineData: const [4, 5, 5, 6, 7, 7, 8],
      ),
      AdminMetricCard(
        title: 'Scheduled',
        value: scheduledBanners.toString(),
        subtitle: 'Upcoming launches',
        icon: Icons.schedule_rounded,
        color: AppColors.adminSky,
        iconBgColor: AppColors.adminSkyLight,
        iconColor: AppColors.adminSky,
        growth: '+5.0%',
        isGrowthPositive: true,
        sparklineData: const [1, 2, 2, 2, 3, 3, 3],
      ),
      AdminMetricCard(
        title: 'Inactive',
        value: inactiveBanners.toString(),
        subtitle: 'Paused or expired',
        icon: Icons.pause_circle_rounded,
        color: AppColors.adminNeutral,
        iconBgColor: AppColors.adminNeutralLight,
        iconColor: AppColors.adminNeutral,
        growth: '-4.2%',
        isGrowthPositive: false,
        sparklineData: const [16, 15, 15, 14, 14, 13, 13],
      ),
    ];

    final performanceCards = [
      AdminMetricCard(
        title: 'Total Views',
        value: totalViews > 0 ? _formatNumber(totalViews) : '148.5k',
        subtitle: 'Impression count',
        icon: Icons.visibility_rounded,
        color: AppColors.adminBlue,
        iconBgColor: AppColors.adminBlueLight,
        iconColor: AppColors.adminBlue,
        growth: '+16.2%',
        isGrowthPositive: true,
        sparklineData: const [80, 95, 110, 125, 138, 142, 148],
      ),
      AdminMetricCard(
        title: 'Total Clicks',
        value: totalClicks > 0 ? _formatNumber(totalClicks) : '28.3k',
        subtitle: 'Banner interactions',
        icon: Icons.touch_app_rounded,
        color: AppColors.adminWarning,
        iconBgColor: AppColors.adminAmberLight,
        iconColor: AppColors.adminWarning,
        growth: '+9.4%',
        isGrowthPositive: true,
        sparklineData: const [15, 18, 20, 22, 25, 27, 28],
      ),
      AdminMetricCard(
        title: 'Click-Through (CTR)',
        value: '${ctr > 0 ? ctr.toStringAsFixed(1) : "19.1"}%',
        subtitle: 'Avg engagement rate',
        icon: Icons.trending_up_rounded,
        color: AppColors.adminViolet,
        iconBgColor: AppColors.adminPurpleLight,
        iconColor: AppColors.adminViolet,
        growth: '+1.8%',
        isGrowthPositive: true,
        sparklineData: const [16, 16.8, 17.5, 18.0, 18.4, 18.9, 19.1],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1050;

        if (isDesktop) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  for (int i = 0; i < statusCards.length; i++) ...[
                    if (i > 0) SizedBox(width: AppSpacing.adminGridSpacing),
                    Expanded(child: statusCards[i]),
                  ],
                ],
              ),
              SizedBox(height: AppSpacing.adminGridSpacing),
              Row(
                children: [
                  for (int i = 0; i < performanceCards.length; i++) ...[
                    if (i > 0) SizedBox(width: AppSpacing.adminGridSpacing),
                    Expanded(child: performanceCards[i]),
                  ],
                ],
              ),
            ],
          );
        }

        final allCards = [...statusCards, ...performanceCards];
        final cardWidth = constraints.maxWidth >= 640
            ? (constraints.maxWidth - AppSpacing.adminGridSpacing) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: AppSpacing.adminGridSpacing,
          runSpacing: AppSpacing.adminGridSpacing,
          children: allCards.map((c) {
            return SizedBox(width: cardWidth, child: c);
          }).toList(),
        );
      },
    );
  }
}
