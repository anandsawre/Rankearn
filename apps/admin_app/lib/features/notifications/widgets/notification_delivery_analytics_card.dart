import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class NotificationDeliveryAnalyticsCard extends StatelessWidget {
  final int totalReads;
  final int totalClicks;
  final int totalUnopened;
  final void Function(String actionId)? onQuickAction;

  const NotificationDeliveryAnalyticsCard({
    super.key,
    this.totalReads = 36800,
    this.totalClicks = 12400,
    this.totalUnopened = 7350,
    this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalReads + totalClicks + totalUnopened;
    final readPct = total > 0 ? (totalReads / total) * 100 : 65.0;
    final clickPct = total > 0 ? (totalClicks / total) * 100 : 22.0;
    final unopenedPct = total > 0 ? (totalUnopened / total) * 100 : 13.0;

    final slices = [
      DonutSlice(
        label: 'Read',
        percentage: readPct,
        color: AppColors.adminSuccess,
        count: totalReads,
      ),
      DonutSlice(
        label: 'Clicked',
        percentage: clickPct,
        color: AppColors.adminPurple,
        count: totalClicks,
      ),
      DonutSlice(
        label: 'Unopened',
        percentage: unopenedPct,
        color: AppColors.adminNeutral.withValues(alpha: 0.35),
        count: totalUnopened,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Delivery Analytics Card with Donut Chart
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.adminCardBackground,
            borderRadius: AppRadii.adminCard,
            border: Border.fromBorderSide(BorderSide(color: AppColors.adminBorder)),
            boxShadow: AppShadows.adminCard,
          ),
          padding: AppSpacing.adminCardPaddingCompact,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.pie_chart_rounded, size: 20, color: AppColors.adminPurple),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Delivery Analytics',
                            style: AppTypography.adminSectionTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.adminPurpleLight,
                      borderRadius: AppRadii.adminRoundPill,
                    ),
                    child: Text(
                      'Last 30 Days',
                      style: AppTypography.adminBadge.copyWith(color: AppColors.adminPurple),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Donut Chart
              Center(
                child: AppDonutChart(
                  slices: slices,
                  totalCount: total > 0 ? total : 56550,
                  totalLabel: 'Dispatches',
                  chartSize: 130,
                  strokeWidth: 16,
                ),
              ),
              const SizedBox(height: 18),

              // Metric breakdowns
              _buildMetricBreakdown(
                label: 'Read Rate',
                value: '${readPct.toStringAsFixed(1)}%',
                count: '${(totalReads / 1000).toStringAsFixed(1)}k users',
                color: AppColors.adminSuccess,
              ),
              const SizedBox(height: 10),
              _buildMetricBreakdown(
                label: 'Click Rate (CTR)',
                value: '${clickPct.toStringAsFixed(1)}%',
                count: '${(totalClicks / 1000).toStringAsFixed(1)}k clicks',
                color: AppColors.adminPurple,
              ),
              const SizedBox(height: 10),
              _buildMetricBreakdown(
                label: 'Unopened Rate',
                value: '${unopenedPct.toStringAsFixed(1)}%',
                count: '${(totalUnopened / 1000).toStringAsFixed(1)}k users',
                color: AppColors.adminSecondaryText,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. Quick Actions Card
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.adminCardBackground,
            borderRadius: AppRadii.adminCard,
            border: Border.fromBorderSide(BorderSide(color: AppColors.adminBorder)),
            boxShadow: AppShadows.adminCard,
          ),
          padding: AppSpacing.adminCardPaddingCompact,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt_rounded, size: 20, color: AppColors.adminWarning),
                  SizedBox(width: 8),
                  Text(
                    'Quick Actions',
                    style: AppTypography.adminSectionTitle,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildQuickActionTile(
                icon: Icons.campaign_rounded,
                title: 'Send to All Users',
                subtitle: 'Immediate global push notification',
                color: AppColors.adminPurple,
                onTap: () => onQuickAction?.call('send_all'),
              ),
              _buildQuickActionTile(
                icon: Icons.person_search_rounded,
                title: 'Send to Specific Users',
                subtitle: 'Target by user ID or mobile number',
                color: AppColors.adminBlue,
                onTap: () => onQuickAction?.call('send_specific'),
              ),
              _buildQuickActionTile(
                icon: Icons.schedule_rounded,
                title: 'Manage Scheduled',
                subtitle: 'View upcoming automated queue',
                color: AppColors.adminTeal,
                onTap: () => onQuickAction?.call('manage_scheduled'),
              ),
              _buildQuickActionTile(
                icon: Icons.drafts_rounded,
                title: 'View Drafts',
                subtitle: 'Edit pending saved notifications',
                color: AppColors.adminOrange,
                onTap: () => onQuickAction?.call('view_drafts'),
              ),
              _buildQuickActionTile(
                icon: Icons.history_rounded,
                title: 'Notification History',
                subtitle: 'Full audit log and delivery reports',
                color: AppColors.adminViolet,
                onTap: () => onQuickAction?.call('history'),
              ),
              _buildQuickActionTile(
                icon: Icons.settings_suggest_rounded,
                title: 'Notification Settings',
                subtitle: 'FCM keys, templates & rate limits',
                color: AppColors.adminNeutral,
                onTap: () => onQuickAction?.call('settings'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBreakdown({
    required String label,
    required String value,
    required String count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.adminBackground,
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: AppTypography.adminTablePrimary.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTypography.adminTableNumber.copyWith(color: color),
              ),
              const SizedBox(width: 6),
              Text(
                '($count)',
                style: AppTypography.adminTableSecondary.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
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
                    style: AppTypography.adminTablePrimary.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.adminTableSecondary.copyWith(fontSize: 11),
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
