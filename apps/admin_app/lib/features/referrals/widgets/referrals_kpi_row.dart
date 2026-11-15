import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class ReferralsKpiRow extends StatelessWidget {
  final int totalReferrals;
  final int successfulSignups;
  final int rewardsGiven;
  final int redeemedPaid;
  final double conversionRate;

  const ReferralsKpiRow({
    super.key,
    required this.totalReferrals,
    required this.successfulSignups,
    required this.rewardsGiven,
    required this.redeemedPaid,
    required this.conversionRate,
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
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    final cards = [
      AdminMetricCard(
        title: 'Total Referrals',
        value: totalReferrals > 0 ? _formatNumber(totalReferrals) : '3,420',
        subtitle: 'Invites shared',
        icon: Icons.share_rounded,
        color: AppColors.adminPurple,
        growth: '+18.2%',
        isGrowthPositive: true,
        sparklineData: const [25, 34, 45, 52, 68, 75, 92],
      ),
      AdminMetricCard(
        title: 'Successful Signups',
        value: successfulSignups > 0 ? _formatNumber(successfulSignups) : '2,845',
        subtitle: 'Activated new users',
        icon: Icons.person_add_alt_1_rounded,
        color: AppColors.adminSuccess,
        growth: '+14.6%',
        isGrowthPositive: true,
        sparklineData: const [20, 28, 38, 45, 58, 65, 82],
      ),
      AdminMetricCard(
        title: 'Rewards Given',
        value: rewardsGiven > 0 ? '₹${_formatNumber(rewardsGiven)}' : '₹142,250',
        subtitle: 'Referral coins & cash',
        icon: Icons.monetization_on_rounded,
        color: AppColors.adminWarning,
        growth: '+22.4%',
        isGrowthPositive: true,
        sparklineData: const [40, 52, 60, 78, 90, 115, 142],
      ),
      AdminMetricCard(
        title: 'Redeemed / Paid',
        value: redeemedPaid > 0 ? '₹${_formatNumber(redeemedPaid)}' : '₹98,400',
        subtitle: 'Disbursed payouts',
        icon: Icons.account_balance_wallet_rounded,
        color: AppColors.adminBlue,
        growth: '+11.8%',
        isGrowthPositive: true,
        sparklineData: const [30, 40, 50, 62, 70, 85, 98],
      ),
      AdminMetricCard(
        title: 'Conversion Rate',
        value: '${conversionRate > 0 ? conversionRate.toStringAsFixed(1) : "83.2"}%',
        subtitle: 'Lead to active ratio',
        icon: Icons.percent_rounded,
        color: AppColors.adminViolet,
        growth: '+4.5%',
        isGrowthPositive: true,
        sparklineData: const [75, 78, 80, 81, 82, 82.8, 83.2],
      ),
    ];

    if (isDesktop) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 14),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }

    if (isTablet) {
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: cards.map((c) {
          final width = (screenWidth - 48 - 14) / 2;
          return SizedBox(width: width, child: c);
        }).toList(),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          cards[i],
        ],
      ],
    );
  }
}
