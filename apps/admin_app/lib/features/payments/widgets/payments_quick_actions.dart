import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Rankearn Quick Actions Card for the Payments Management tab.
/// Uses the centralized QuickActionsCard from the design system at fixed height: 124.
/// Includes Top-ups, Withdrawals, and Settings actions alongside transaction controls.
class PaymentsQuickActions extends StatelessWidget {
  final VoidCallback onTopups;
  final VoidCallback onWithdrawals;
  final VoidCallback onSettings;
  final VoidCallback onViewTransactions;
  final VoidCallback onProcessRefund;
  final VoidCallback onPayoutReports;
  final VoidCallback onExportPayments;
  final VoidCallback? onSubscriptionManagement;
  final VoidCallback? onCustomize;
  final double? height;

  const PaymentsQuickActions({
    super.key,
    required this.onTopups,
    required this.onWithdrawals,
    required this.onSettings,
    required this.onViewTransactions,
    required this.onProcessRefund,
    required this.onPayoutReports,
    required this.onExportPayments,
    this.onSubscriptionManagement,
    this.onCustomize,
    this.height = 124,
  });

  @override
  Widget build(BuildContext context) {
    return QuickActionsCard(
      height: height,
      compact: true,
      onCustomize: onCustomize,
      actions: [
        QuickActionItemData(
          label: 'Verify\nTop-ups',
          icon: Icons.add_circle_outline_rounded,
          iconColor: const Color(0xFF00B96B),
          cardColor: const Color(0xFFE8FAF2),
          onTap: onTopups,
        ),
        QuickActionItemData(
          label: 'Process\nWithdrawal',
          icon: Icons.arrow_outward_rounded,
          iconColor: const Color(0xFFFF9F0A),
          cardColor: const Color(0xFFFFFBEB),
          onTap: onWithdrawals,
        ),
        QuickActionItemData(
          label: 'Finance\nSettings',
          icon: Icons.tune_rounded,
          iconColor: const Color(0xFF6C5CE7),
          cardColor: const Color(0xFFF3F0FF),
          onTap: onSettings,
        ),
        QuickActionItemData(
          label: 'View\nTransactions',
          icon: Icons.receipt_long_rounded,
          iconColor: const Color(0xFF0084FF),
          cardColor: const Color(0xFFEFF6FF),
          onTap: onViewTransactions,
        ),
        QuickActionItemData(
          label: 'Process\nRefund',
          icon: Icons.replay_rounded,
          iconColor: const Color(0xFFEF4444),
          cardColor: const Color(0xFFFEF2F2),
          onTap: onProcessRefund,
        ),
        QuickActionItemData(
          label: 'Payout\nReports',
          icon: Icons.bar_chart_rounded,
          iconColor: const Color(0xFF06B6D4),
          cardColor: const Color(0xFFECFEFF),
          onTap: onPayoutReports,
        ),
        QuickActionItemData(
          label: 'Export\nPayments',
          icon: Icons.description_outlined,
          iconColor: const Color(0xFFF04483),
          cardColor: const Color(0xFFFFF1F2),
          onTap: onExportPayments,
        ),
      ],
    );
  }
}
