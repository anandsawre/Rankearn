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
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0810143A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt_rounded, size: 20, color: AppColors.adminWarning),
              SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.adminPrimaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildActionItem(
            icon: Icons.file_download_outlined,
            title: 'Export Referral Data',
            subtitle: 'Download CSV / Excel audit records',
            color: const Color(0xFF0D9488),
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
            color: const Color(0xFF2563EB),
            onTap: () => onAction?.call('payouts'),
          ),
          _buildActionItem(
            icon: Icons.image_outlined,
            title: 'Referral Banners',
            subtitle: 'Update promotional share graphics',
            color: const Color(0xFFF97316),
            onTap: () => onAction?.call('banners'),
          ),
          _buildActionItem(
            icon: Icons.add_circle_outline_rounded,
            title: 'Create Referral Campaign',
            subtitle: 'Launch targeted double-reward event',
            color: const Color(0xFF8B5CF6),
            onTap: () => onAction?.call('campaign'),
          ),
          _buildActionItem(
            icon: Icons.send_rounded,
            title: 'Send Referral Broadcast',
            subtitle: 'Notify users about referral bonuses',
            color: const Color(0xFF10B981),
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
      borderRadius: AppRadii.borderMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
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
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.adminPrimaryText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.adminSecondaryText,
                    ),
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
