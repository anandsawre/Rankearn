import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Rankearn Quick Actions Card for the Payments Management tab.
/// Uses the centralized QuickActionsCard from the design system at fixed height: 124.
class PaymentsQuickActions extends StatelessWidget {
  final VoidCallback onViewTransactions;
  final VoidCallback onProcessRefund;
  final VoidCallback onSubscriptionManagement;
  final VoidCallback onPayoutReports;
  final VoidCallback onExportPayments;
  final VoidCallback onPaymentSettings;
  final VoidCallback? onCustomize;
  final double? height;

  const PaymentsQuickActions({
    super.key,
    required this.onViewTransactions,
    required this.onProcessRefund,
    required this.onSubscriptionManagement,
    required this.onPayoutReports,
    required this.onExportPayments,
    required this.onPaymentSettings,
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
          label: 'View\nTransactions',
          icon: Icons.receipt_long_rounded,
          iconColor: const Color(0xFF6C5CE7),
          cardColor: const Color(0xFFF3F0FF),
          onTap: onViewTransactions,
        ),
        QuickActionItemData(
          label: 'Process\nRefund',
          icon: Icons.replay_rounded,
          iconColor: const Color(0xFF0084FF),
          cardColor: const Color(0xFFEFF6FF),
          onTap: onProcessRefund,
        ),
        QuickActionItemData(
          label: 'Subscription\nManagement',
          icon: Icons.card_giftcard_rounded,
          iconColor: const Color(0xFF00C48C),
          cardColor: const Color(0xFFECFDF5),
          onTap: onSubscriptionManagement,
        ),
        QuickActionItemData(
          label: 'Payout\nReports',
          icon: Icons.bar_chart_rounded,
          iconColor: const Color(0xFFFF9F0A),
          cardColor: const Color(0xFFFFFBEB),
          onTap: onPayoutReports,
        ),
        QuickActionItemData(
          label: 'Export\nPayments',
          icon: Icons.description_outlined,
          iconColor: const Color(0xFFF04483),
          cardColor: const Color(0xFFFFF1F2),
          onTap: onExportPayments,
        ),
        QuickActionItemData(
          label: 'Payment\nSettings',
          icon: Icons.settings_outlined,
          iconColor: const Color(0xFFE11D48),
          cardColor: const Color(0xFFFFF1F2),
          onTap: onPaymentSettings,
        ),
      ],
    );
  }
}
