import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class ReferralQuickActionsCard extends StatelessWidget {
  final void Function(String actionId)? onAction;

  const ReferralQuickActionsCard({super.key, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: AppShadows.adminCard,
      ),
      padding: AppSpacing.adminCardPaddingCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 20, color: AppColors.adminWarning),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: AppTypography.adminSectionTitle,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildActionItem(
            icon: Icons.file_download_outlined,
            title: 'Export Referral Data',
            subtitle: 'Download CSV / Excel audit records',
            color: AppColors.adminTeal,
            onTap: () => onAction?.call('export'),
          ),
          _buildActionItem(
            icon: Icons.card_giftcard_rounded,
            title: 'Manage Rewards',
            subtitle: 'Adjust coin conversion & tiers',
            color: AppColors.adminPurple,
            onTap: () => onAction?.call('rewards'),
          ),
          _buildActionItem(
            icon: Icons.payments_outlined,
            title: 'Payout Requests',
            subtitle: 'Review & approve pending payouts',
            color: AppColors.adminBlue,
            onTap: () => onAction?.call('payouts'),
          ),
          _buildActionItem(
            icon: Icons.image_outlined,
            title: 'Referral Banners',
            subtitle: 'Update promotional share graphics',
            color: AppColors.adminOrange,
            onTap: () => onAction?.call('banners'),
          ),
          _buildActionItem(
            icon: Icons.add_circle_outline_rounded,
            title: 'Create Referral Campaign',
            subtitle: 'Launch targeted double-reward event',
            color: AppColors.adminViolet,
            onTap: () => onAction?.call('campaign'),
          ),
          _buildActionItem(
            icon: Icons.send_rounded,
            title: 'Send Referral Broadcast',
            subtitle: 'Notify users about referral bonuses',
            color: AppColors.adminSuccess,
            onTap: () => onAction?.call('broadcast'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.adminControl,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: AppRadii.adminControl,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.adminTablePrimary,
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.adminTableSecondary,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.adminSecondaryText),
          ],
        ),
      ),
    );
  }
}
