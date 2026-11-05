import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Payments Metrics Row
/// Displays 5 responsive statistics cards powered by the unified [AdminMetricCard]
/// from the Rankearn design system.
class PaymentsMetricsRow extends StatelessWidget {
  final double totalRevenue;
  final int totalTransactions;
  final int successfulPayments;
  final int failedPayments;
  final int pendingPayments;

  const PaymentsMetricsRow({
    super.key,
    this.totalRevenue = 1245780,
    this.totalTransactions = 5842,
    this.successfulPayments = 5621,
    this.failedPayments = 221,
    this.pendingPayments = 48,
  });

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write(',');
        count = 0;
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (
        title: 'Total Revenue',
        value: '₹ ${_formatNumber(totalRevenue.toInt())}',
        growth: '+28%',
        isGrowthPositive: true,
        subtitle: '+₹ 2,75,430 this month',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF3B82F6),
        sparklineData: const [20.0, 40.0, 35.0, 65.0, 50.0, 85.0, 100.0],
      ),
      (
        title: 'Total Transactions',
        value: _formatNumber(totalTransactions),
        growth: '+18%',
        isGrowthPositive: true,
        subtitle: '+862 this month',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF10B981),
        sparklineData: const [15.0, 35.0, 30.0, 60.0, 55.0, 80.0, 100.0],
      ),
      (
        title: 'Successful Payments',
        value: _formatNumber(successfulPayments),
        growth: '+22%',
        isGrowthPositive: true,
        subtitle: '95.2% success rate',
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF00C48C),
        sparklineData: const [30.0, 40.0, 50.0, 45.0, 70.0, 85.0, 100.0],
      ),
      (
        title: 'Failed Payments',
        value: failedPayments.toString(),
        growth: '-15%',
        isGrowthPositive: false,
        subtitle: '3.8% failure rate',
        icon: Icons.cancel_rounded,
        color: const Color(0xFFEF4444),
        sparklineData: const [80.0, 65.0, 70.0, 45.0, 50.0, 30.0, 20.0],
      ),
      (
        title: 'Pending Payments',
        value: pendingPayments.toString(),
        growth: '+12%',
        isGrowthPositive: true,
        subtitle: '+6 this month',
        icon: Icons.sync_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: const [20.0, 30.0, 40.0, 55.0, 50.0, 80.0, 100.0],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth > 1100
            ? (constraints.maxWidth - (16 * 4)) / 5
            : constraints.maxWidth > 700
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: metrics.map((m) {
            return AdminMetricCard(
              width: cardWidth,
              title: m.title,
              value: m.value,
              growth: m.growth,
              isGrowthPositive: m.isGrowthPositive,
              subtitle: m.subtitle,
              icon: m.icon,
              color: m.color,
              sparklineData: m.sparklineData,
            );
          }).toList(),
        );
      },
    );
  }
}
