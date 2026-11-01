import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SubscriptionPlanItem {
  final String name;
  final String price;
  final int activeSubscribers;
  final String interval;
  final Color badgeColor;

  const SubscriptionPlanItem({
    required this.name,
    required this.price,
    required this.activeSubscribers,
    required this.interval,
    required this.badgeColor,
  });
}

class SubscriptionManagementDialog extends StatelessWidget {
  const SubscriptionManagementDialog({super.key});

  static const List<SubscriptionPlanItem> _plans = [
    SubscriptionPlanItem(
      name: 'Rankearn Pro Monthly',
      price: '₹499',
      activeSubscribers: 1240,
      interval: 'Monthly',
      badgeColor: Color(0xFF5636F5),
    ),
    SubscriptionPlanItem(
      name: 'Test Series Pass',
      price: '₹299',
      activeSubscribers: 2850,
      interval: 'Quarterly',
      badgeColor: Color(0xFF2587F8),
    ),
    SubscriptionPlanItem(
      name: 'Ultimate Scholar Annual',
      price: '₹1,999',
      activeSubscribers: 840,
      interval: 'Annual',
      badgeColor: Color(0xFFFF9F0A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Subscription Management',
      subtitle: 'Overview of active subscription tiers and recurring billing',
      iconData: Icons.card_giftcard_rounded,
      gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
      maxWidth: 620,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
          child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // KPI Row
          Row(
            children: [
              _buildKpiCard('Total Active', '4,930', const Color(0xFF10B981)),
              const SizedBox(width: 10),
              _buildKpiCard('Monthly MRR', '₹ 14,85,200', const Color(0xFF5636F5)),
              const SizedBox(width: 10),
              _buildKpiCard('Renewal Rate', '94.2%', const Color(0xFF2587F8)),
            ],
          ),
          const SizedBox(height: 18),

          // Plans List
          const Text('Active Plans', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF101A3A))),
          const SizedBox(height: 8),
          ..._plans.map((p) => _buildPlanTile(p)),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 3),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanTile(SubscriptionPlanItem plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 32,
                decoration: BoxDecoration(color: plan.badgeColor, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text('${plan.interval} billing cycle', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(plan.price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF101A3A))),
              Text('${plan.activeSubscribers} subscribers', style: const TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
