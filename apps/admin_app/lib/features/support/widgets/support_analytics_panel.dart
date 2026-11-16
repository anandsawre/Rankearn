import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SupportAnalyticsPanel extends StatelessWidget {
  final int totalCount;
  final int resolvedCount;
  final int inProgressCount;
  final int openCount;
  final int onHoldCount;
  final Map<String, int>? categoryCounts;

  const SupportAnalyticsPanel({
    super.key,
    this.totalCount = 0,
    this.resolvedCount = 0,
    this.inProgressCount = 0,
    this.openCount = 0,
    this.onHoldCount = 0,
    this.categoryCounts,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTotal = totalCount > 0 ? totalCount : 1;
    final resolvedPct = totalCount > 0 ? (resolvedCount / effectiveTotal * 100) : 0.0;
    final inProgressPct = totalCount > 0 ? (inProgressCount / effectiveTotal * 100) : 0.0;
    final openPct = totalCount > 0 ? (openCount / effectiveTotal * 100) : 0.0;
    final onHoldPct = totalCount > 0 ? (onHoldCount / effectiveTotal * 100) : 0.0;

    final slices = totalCount > 0
        ? [
            DonutSlice(
              label: 'Resolved',
              percentage: double.parse(resolvedPct.toStringAsFixed(1)),
              color: AppColors.adminSuccess,
            ),
            DonutSlice(
              label: 'In Progress',
              percentage: double.parse(inProgressPct.toStringAsFixed(1)),
              color: const Color(0xFF0284C7),
            ),
            DonutSlice(
              label: 'Open',
              percentage: double.parse(openPct.toStringAsFixed(1)),
              color: const Color(0xFFF59E0B),
            ),
            if (onHoldCount > 0)
              DonutSlice(
                label: 'On Hold',
                percentage: double.parse(onHoldPct.toStringAsFixed(1)),
                color: AppColors.adminPurple,
              ),
          ]
        : const [
            DonutSlice(
              label: 'No Tickets',
              percentage: 100.0,
              color: AppColors.adminNeutralLight,
            ),
          ];

    return Column(
      children: [
        // 1. Ticket Analytics Donut Chart
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
                      'Ticket Analytics',
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

        // 2. Top Categories Card
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
                  const Icon(Icons.sell_outlined, size: 18, color: AppColors.adminPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Top Categories',
                      style: AppTypography.adminCardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCategoryRow('Payment & Coins', categoryCounts?['Payment'] ?? (openCount > 0 ? openCount : 0), const Color(0xFFD97706), Icons.monetization_on_outlined),
              const SizedBox(height: 10),
              _buildCategoryRow('Account & Verification', categoryCounts?['Verification'] ?? 0, const Color(0xFF0284C7), Icons.verified_user_outlined),
              const SizedBox(height: 10),
              _buildCategoryRow('Referral & Rewards', categoryCounts?['Referral'] ?? 0, AppColors.adminPurple, Icons.share_rounded),
              const SizedBox(height: 10),
              _buildCategoryRow('Technical Issue', categoryCounts?['Technical'] ?? 0, const Color(0xFF6366F1), Icons.build_outlined),
              const SizedBox(height: 10),
              _buildCategoryRow('Withdrawal', categoryCounts?['Withdrawal'] ?? 0, AppColors.adminSuccess, Icons.account_balance_wallet_outlined),
              const SizedBox(height: 10),
              _buildCategoryRow('General Query', categoryCounts?['General'] ?? resolvedCount, AppColors.adminSecondaryText, Icons.help_outline_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(String name, int count, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.adminPrimaryText),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.adminBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.adminSecondaryText),
          ),
        ),
      ],
    );
  }
}
