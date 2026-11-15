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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;

    final statusCards = [
      AdminMetricCard(
        title: 'Total Banners',
        value: totalBanners.toString(),
        subtitle: 'All created assets',
        icon: Icons.photo_library_rounded,
        color: AppColors.adminPurple,
      ),
      AdminMetricCard(
        title: 'Active Banners',
        value: activeBanners.toString(),
        subtitle: 'Currently serving',
        icon: Icons.check_circle_rounded,
        color: AppColors.adminSuccess,
      ),
      AdminMetricCard(
        title: 'Scheduled',
        value: scheduledBanners.toString(),
        subtitle: 'Upcoming launches',
        icon: Icons.schedule_rounded,
        color: AppColors.adminSky,
      ),
      AdminMetricCard(
        title: 'Inactive',
        value: inactiveBanners.toString(),
        subtitle: 'Paused or expired',
        icon: Icons.pause_circle_rounded,
        color: AppColors.adminNeutral,
      ),
    ];

    final performanceCards = [
      AdminMetricCard(
        title: 'Total Views',
        value: totalViews > 0 ? _formatNumber(totalViews) : '148.5k',
        subtitle: 'Impression count',
        icon: Icons.visibility_rounded,
        color: AppColors.adminBlue,
        growth: '+16.2%',
        isGrowthPositive: true,
        sparklineData: const [80, 95, 110, 125, 138, 142, 148],
      ),
      AdminMetricCard(
        title: 'Total Clicks',
        value: totalClicks > 0 ? _formatNumber(totalClicks) : '28.3k',
        subtitle: 'Banner interactions',
        icon: Icons.touch_app_rounded,
        color: AppColors.adminAmber,
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
        growth: '+1.8%',
        isGrowthPositive: true,
        sparklineData: const [16, 16.8, 17.5, 18.0, 18.4, 18.9, 19.1],
      ),
    ];

    if (isDesktop) {
      return Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < statusCards.length; i++) ...[
                if (i > 0) const SizedBox(width: 14),
                Expanded(child: statusCards[i]),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (int i = 0; i < performanceCards.length; i++) ...[
                if (i > 0) const SizedBox(width: 14),
                Expanded(child: performanceCards[i]),
              ],
            ],
          ),
        ],
      );
    }

    final allCards = [...statusCards, ...performanceCards];
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: allCards.map((c) {
        final width = screenWidth >= 768 ? (screenWidth - 48 - 14) / 2 : double.infinity;
        return SizedBox(width: width, child: c);
      }).toList(),
    );
  }
}
