import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SupportCategoriesDialog extends StatefulWidget {
  const SupportCategoriesDialog({super.key});

  @override
  State<SupportCategoriesDialog> createState() => _SupportCategoriesDialogState();
}

class _SupportCategoriesDialogState extends State<SupportCategoriesDialog> {
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Payment & Coins',
      'icon': Icons.payment_rounded,
      'color': AppColors.adminSuccess,
      'sla': '1 Hour SLA',
      'desc': 'UPI issues, payment gateway delays, missing coin credits',
      'enabled': true,
    },
    {
      'name': 'Verification & KYC',
      'icon': Icons.verified_user_rounded,
      'color': AppColors.adminBlue,
      'sla': '4 Hours SLA',
      'desc': 'Aadhaar/PAN verification, profile authenticity reviews',
      'enabled': true,
    },
    {
      'name': 'Withdrawal & Payouts',
      'icon': Icons.account_balance_wallet_rounded,
      'color': AppColors.adminPurple,
      'sla': '2 Hours SLA',
      'desc': 'Bank account changes, IMPS transfer issues, payout status',
      'enabled': true,
    },
    {
      'name': 'Technical & Test Bugs',
      'icon': Icons.bug_report_rounded,
      'color': AppColors.adminDanger,
      'sla': '3 Hours SLA',
      'desc': 'Question timer glitches, crash reports, app performance',
      'enabled': true,
    },
    {
      'name': 'Referral & Bonus',
      'icon': Icons.card_giftcard_rounded,
      'color': const Color(0xFFF59E0B),
      'sla': '6 Hours SLA',
      'desc': 'Referral milestone tracking and referee verification',
      'enabled': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AppModalDialog(
      title: 'Support Ticket Categories',
      subtitle: 'Manage routing rules, SLA timeframes & category assignment',
      iconData: Icons.category_rounded,
      maxWidth: 620,
      actions: [
        AppModalDialog.cancelButton(context, label: 'Close'),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, idx) {
              final cat = _categories[idx];
              final color = cat['color'] as Color;
              final bool isEnabled = cat['enabled'] as bool;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: AppRadii.adminCardInner,
                  border: Border.all(color: AppColors.adminBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        borderRadius: AppRadii.adminControl,
                      ),
                      child: Icon(cat['icon'] as IconData, size: 20, color: color),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                cat['name'] as String,
                                style: AppTypography.adminCardTitle.copyWith(fontSize: 13),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withAlpha(20),
                                  borderRadius: AppRadii.badge,
                                ),
                                child: Text(
                                  cat['sla'] as String,
                                  style: AppTypography.labelSmall.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            cat['desc'] as String,
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11.5,
                              color: AppColors.adminSecondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isEnabled,
                      activeTrackColor: AppColors.adminPurple,
                      onChanged: (val) {
                        setState(() {
                          cat['enabled'] = val;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
