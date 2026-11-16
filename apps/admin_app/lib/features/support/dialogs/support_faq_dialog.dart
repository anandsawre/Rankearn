import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';

class SupportFaqDialog extends StatefulWidget {
  const SupportFaqDialog({super.key});

  @override
  State<SupportFaqDialog> createState() => _SupportFaqDialogState();
}

class _SupportFaqDialogState extends State<SupportFaqDialog> {
  final _searchController = TextEditingController();
  String _filterQuery = '';

  static const List<Map<String, String>> _cannedResponses = [
    {
      'title': 'UPI Payment Delayed / Deducted',
      'category': 'Payment',
      'query': 'Payment deducted from bank but coins not reflected',
      'template': 'Dear Candidate, banking servers sometimes take up to 15-30 minutes to confirm UPI transaction settlements. If your coins do not reflect within 1 hour, please share your UTR / Transaction ID and we will manually credit your wallet immediately.',
    },
    {
      'title': 'Test Series Access & Validity',
      'category': 'Tests',
      'query': 'How to start enrolled test series or live mock?',
      'template': 'Dear Candidate, once unlocked, test series are instantly accessible from the Test Series tab on your Home Dashboard. You can attempt sectional and full-length mock tests anytime before the validity expiry date.',
    },
    {
      'title': 'Coin Withdrawal & Bank Transfer',
      'category': 'Withdrawal',
      'query': 'Withdrawal requested but money not in account',
      'template': 'Dear Candidate, withdrawal payouts are processed automatically via IMPS/NEFT within 24 to 48 business hours after security verification. Please ensure your UPI ID or IFSC code entered in your profile is accurate.',
    },
    {
      'title': 'Referral Reward Credit',
      'category': 'Referral',
      'query': 'Friend used referral code but bonus coins not added',
      'template': 'Dear Candidate, referral reward coins are credited automatically once your referred friend successfully registers and completes their first mock test or coin recharge.',
    },
    {
      'title': 'App Crashing / Technical Bug',
      'category': 'Technical',
      'query': 'Test stopped unexpectedly or question loading error',
      'template': 'Dear Candidate, we apologize for the inconvenience. Please try clearing the app cache or updating to the latest version. We have flagged this test attempt to our engineering team for manual review.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _cannedResponses.where((item) {
      if (_filterQuery.isEmpty) return true;
      final q = _filterQuery.toLowerCase();
      return item['title']!.toLowerCase().contains(q) ||
          item['category']!.toLowerCase().contains(q) ||
          item['template']!.toLowerCase().contains(q);
    }).toList();

    return AppModalDialog(
      title: 'Support Help Center & FAQs',
      subtitle: 'Standard quick canned responses and resolution templates for support agents',
      iconData: Icons.help_outline_rounded,
      maxWidth: 680,
      actions: [
        AppModalDialog.cancelButton(context, label: 'Close'),
      ],
      child: SizedBox(
        height: 480,
        child: Column(
          children: [
            AppModalDialog.textField(
              controller: _searchController,
              hint: 'Search standard responses by issue or keyword...',
              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.adminSecondaryText),
              onChanged: (val) => setState(() => _filterQuery = val.trim()),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('No canned templates found.', style: AppTypography.adminTableSecondary),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, idx) {
                        final item = filtered[idx];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: AppRadii.adminCardInner,
                            border: Border.all(color: AppColors.adminBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.adminPurpleLight,
                                      borderRadius: AppRadii.badge,
                                    ),
                                    child: Text(
                                      item['category']!,
                                      style: AppTypography.adminBadge.copyWith(color: AppColors.adminPurple),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      item['title']!,
                                      style: AppTypography.adminCardTitle.copyWith(fontSize: 13),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.adminPurple),
                                    tooltip: 'Copy Template Response',
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: item['template']!));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('📋 Copied "${item['title']}" template to clipboard!')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['template']!,
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: 12,
                                  color: AppColors.adminSecondaryText,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
