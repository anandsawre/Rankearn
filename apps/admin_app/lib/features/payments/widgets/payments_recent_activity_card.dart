import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class PaymentActivityItem {
  final String title;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const PaymentActivityItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

/// Recent Activity Card for Payments Management
/// Displays 5 payment events with color-coded square icon badges.
class PaymentsRecentActivityCard extends StatelessWidget {
  final VoidCallback? onViewAll;
  final List<PaymentActivityItem> activities;

  const PaymentsRecentActivityCard({
    super.key,
    this.onViewAll,
    this.activities = const [
      PaymentActivityItem(
        title: 'Payment received: ₹199 (Test Series)',
        time: '5 minutes ago',
        icon: Icons.check_circle_rounded,
        iconColor: Color(0xFF10B981),
        iconBgColor: Color(0xFFECFDF5),
      ),
      PaymentActivityItem(
        title: 'Refund processed: ₹49 (Live Quiz)',
        time: '22 minutes ago',
        icon: Icons.replay_rounded,
        iconColor: Color(0xFF2587F8),
        iconBgColor: Color(0xFFEFF6FF),
      ),
      PaymentActivityItem(
        title: 'New subscription: ₹499',
        time: '1 hour ago',
        icon: Icons.card_giftcard_rounded,
        iconColor: Color(0xFFFF9F0A),
        iconBgColor: Color(0xFFFFFBEB),
      ),
      PaymentActivityItem(
        title: 'Payment failed: ₹149 (Test Series)',
        time: '2 hours ago',
        icon: Icons.cancel_rounded,
        iconColor: Color(0xFFF43F5E),
        iconBgColor: Color(0xFFFFF1F2),
      ),
      PaymentActivityItem(
        title: 'Payout initiated: ₹12,450 (Commission)',
        time: '5 hours ago',
        icon: Icons.account_balance_wallet_rounded,
        iconColor: Color(0xFF6B4EFF),
        iconBgColor: Color(0xFFF5F3FF),
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.1),
        boxShadow: AppShadows.subtle,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Icon + Title + "View All"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2587F8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.history_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              MouseRegion(
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
            ],
          ),
          const SizedBox(height: 12),

          // Activity List
          ...activities.map((item) => _buildActivityRow(item)),
        ],
      ),
    );
  }

  Widget _buildActivityRow(PaymentActivityItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: item.iconBgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: item.iconColor.withAlpha(40), width: 0.8),
            ),
            alignment: Alignment.center,
            child: Icon(
              item.icon,
              size: 13,
              color: item.iconColor,
            ),
          ),
          const SizedBox(width: 9),

          // Title & Time in row
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
