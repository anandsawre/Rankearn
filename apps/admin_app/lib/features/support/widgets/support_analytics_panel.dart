import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SupportAnalyticsPanel extends StatelessWidget {
  const SupportAnalyticsPanel({super.key});

  @override
  Widget build(BuildContext context) {
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
                totalCount: 1248,
                totalLabel: 'Total',
                slices: const [
                  DonutSlice(
                    label: 'Resolved',
                    percentage: 67.8,
                    color: AppColors.adminSuccess,
                  ),
                  DonutSlice(
                    label: 'In Progress',
                    percentage: 17.5,
                    color: Color(0xFF0284C7),
                  ),
                  DonutSlice(
                    label: 'Open',
                    percentage: 7.7,
                    color: Color(0xFFF59E0B),
                  ),
                  DonutSlice(
                    label: 'On Hold',
                    percentage: 7.0,
                    color: AppColors.adminPurple,
                  ),
                ],
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
              _buildCategoryRow('Payment & Coins', 362, const Color(0xFFD97706), Icons.monetization_on_outlined),
              const SizedBox(height: 10),
              _buildCategoryRow('Account & Verification', 248, const Color(0xFF0284C7), Icons.verified_user_outlined),
              const SizedBox(height: 10),
              _buildCategoryRow('Referral & Rewards', 186, AppColors.adminPurple, Icons.share_rounded),
              const SizedBox(height: 10),
              _buildCategoryRow('Technical Issue', 172, const Color(0xFF6366F1), Icons.build_outlined),
              const SizedBox(height: 10),
              _buildCategoryRow('Withdrawal', 128, AppColors.adminSuccess, Icons.account_balance_wallet_outlined),
              const SizedBox(height: 10),
              _buildCategoryRow('Other', 152, AppColors.adminSecondaryText, Icons.help_outline_rounded),
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
