import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Payment Method Distribution Card
/// Powered by the centralized, reusable [AppDonutChartCard] from the design system.
class PaymentsMethodDonutCard extends StatelessWidget {
  final int totalCount;
  final VoidCallback? onViewAll;
  final List<DonutSlice> slices;
  final double? height;
  final bool fillHeight;

  const PaymentsMethodDonutCard({
    super.key,
    this.totalCount = 5842,
    this.onViewAll,
    this.height,
    this.fillHeight = false,
    this.slices = const [
      DonutSlice(label: 'UPI', percentage: 42, color: Color(0xFF2587F8), count: 2452),
      DonutSlice(label: 'Credit Card', percentage: 24, color: Color(0xFF6B4EFF), count: 1402),
      DonutSlice(label: 'Debit Card', percentage: 12, color: Color(0xFF06B6D4), count: 701),
      DonutSlice(label: 'Net Banking', percentage: 10, color: Color(0xFF10B981), count: 584),
      DonutSlice(label: 'Wallet', percentage: 8, color: Color(0xFFFF9F0A), count: 467),
      DonutSlice(label: 'Others', percentage: 4, color: Color(0xFF64748B), count: 236),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return AppDonutChartCard(
      title: 'Payment Method Distribution',
      icon: Icons.account_balance_wallet_rounded,
      iconBg: const Color(0xFF2587F8),
      totalCount: totalCount,
      totalLabel: 'Total',
      slices: slices,
      height: height ?? (fillHeight ? null : 205),
      fillHeight: fillHeight,
      chartSize: 92,
      strokeWidth: 13.5,
      strokeCap: StrokeCap.round,
      trailingHeader: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onViewAll,
          child: const Text(
            'View All',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2587F8),
            ),
          ),
        ),
      ),
    );
  }
}
