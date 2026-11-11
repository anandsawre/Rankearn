import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import '../services/battle_dashboard_service.dart';

class BattleReportsTab extends StatefulWidget {
  const BattleReportsTab({super.key});

  @override
  State<BattleReportsTab> createState() => _BattleReportsTabState();
}

class _BattleReportsTabState extends State<BattleReportsTab> {
  final _service = BattleDashboardService();
  String _timeRange = 'Last 7 Days';

  @override
  void initState() {
    super.initState();
    _service.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _exportCSV(BattleReportSummary summary) async {
    if (summary.filteredBattles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No battle records in selected period to export.'),
          backgroundColor: AppColors.textSecondary,
        ),
      );
      return;
    }

    final csv = _service.buildCsvReport(_timeRange);
    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied CSV report (${summary.filteredBattles.length} matches) to clipboard.',
        ),
        backgroundColor: AppColors.brandGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = _service.buildReportSummary(_timeRange);
    final total = summary.totalMatches;
    final oneVOneRatio = total == 0 ? 0.0 : summary.oneVsOneMatches / total;
    final multiRatio = total == 0 ? 0.0 : summary.multiplayerMatches / total;
    final roomsRatio = total == 0 ? 0.0 : summary.customRoomsCount / total;

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER BAR
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Battle Analytics & Performance Reports',
                      style: AppTypography.headingSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Computed directly from live Supabase battles, wallet payouts and audit logs',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.borderSm,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _timeRange,
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Today', child: Text('Today')),
                      DropdownMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days')),
                      DropdownMenuItem(value: 'Last 30 Days', child: Text('Last 30 Days')),
                      DropdownMenuItem(value: 'All Time', child: Text('All Time')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _timeRange = v);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _exportCSV(summary),
                icon: const Icon(Icons.copy_all_rounded, size: 16),
                label: Text(
                  'Copy CSV',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.battleAdminPurple,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderSm),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. OVERVIEW METRICS ROW
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth > 1000
                  ? (constraints.maxWidth - (16 * 3)) / 4
                  : constraints.maxWidth > 600
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  AdminMetricCard(
                    width: cardWidth,
                    title: 'Total Matches Hosted',
                    value: '${summary.totalMatches}',
                    subtitle: 'In $_timeRange',
                    icon: Icons.sports_kabaddi_rounded,
                    color: AppColors.battleAdminPurple,
                    sparklineData: _service.sevenDayBattlesSparkline,
                  ),
                  AdminMetricCard(
                    width: cardWidth,
                    title: 'Total Coin Volume',
                    value: '${summary.totalCoinVolume}',
                    subtitle: 'Combined entry stakes',
                    icon: Icons.monetization_on_rounded,
                    color: AppColors.coinGold,
                  ),
                  AdminMetricCard(
                    width: cardWidth,
                    title: 'Estimated Net Rake',
                    value: '${summary.platformRakeCoins} Coins',
                    subtitle: 'Entry pot minus payouts/refunds',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.brandGreen,
                  ),
                  AdminMetricCard(
                    width: cardWidth,
                    title: 'Completion Rate',
                    value: '${summary.completionRatePct.toStringAsFixed(1)}%',
                    subtitle: 'Of closed battles',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.brandBlue,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // 3. CHARTS ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Battle Volume Breakdown
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.card,
                    border: Border.all(color: AppColors.borderSubtle, width: 1.2),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Battle Volume Distribution (1v1 vs Multi vs Rooms)',
                        style: AppTypography.headingSmall.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildDistributionBar(
                        '1 vs 1 Battles',
                        oneVOneRatio,
                        '${(oneVOneRatio * 100).round()}% (${summary.oneVsOneMatches} Matches)',
                        AppColors.battleAdminPurple,
                      ),
                      const SizedBox(height: 14),
                      _buildDistributionBar(
                        'Multiplayer Competitions',
                        multiRatio,
                        '${(multiRatio * 100).round()}% (${summary.multiplayerMatches} Matches)',
                        AppColors.coinGold,
                      ),
                      const SizedBox(height: 14),
                      _buildDistributionBar(
                        'Custom User Rooms',
                        roomsRatio,
                        '${(roomsRatio * 100).round()}% (${summary.customRoomsCount} Rooms)',
                        AppColors.brandBlue,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Peak Battle Hours
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.card,
                    border: Border.all(color: AppColors.borderSubtle, width: 1.2),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peak Battle Hours ($_timeRange)',
                        style: AppTypography.headingSmall.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (summary.topPeakWindows.isEmpty)
                        Text(
                          'No battle timestamps recorded in $_timeRange.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        )
                      else
                        ...summary.topPeakWindows.asMap().entries.map((entry) {
                          final colors = [
                            AppColors.battleAdminPurple,
                            AppColors.brandGreen,
                            AppColors.warning,
                          ];
                          final w = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: entry.key == summary.topPeakWindows.length - 1 ? 0 : 10,
                            ),
                            child: _buildPeakHour(
                              w.windowLabel,
                              '${w.matchCount} battle${w.matchCount == 1 ? '' : 's'} started',
                              colors[entry.key % colors.length],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4. ADMIN AUDIT TRAIL LOG
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.card,
              border: Border.all(color: AppColors.borderSubtle, width: 1.2),
              boxShadow: AppShadows.subtle,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history_edu_rounded, color: AppColors.battleAdminPurple, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Administrative Audit Log (Persisted in Supabase)',
                      style: AppTypography.headingSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_service.auditLogs.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Text(
                      'No administrative actions recorded yet.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _service.auditLogs.length.clamp(0, 10),
                    separatorBuilder: (_, _) => const Divider(height: 16, color: AppColors.borderSubtle),
                    itemBuilder: (context, idx) {
                      final log = _service.auditLogs[idx];
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: const BoxDecoration(
                              color: AppColors.brandPurpleLight,
                              borderRadius: AppRadii.badge,
                            ),
                            child: Text(
                              log['time'] as String? ?? 'Recorded',
                              style: AppTypography.captionBold.copyWith(
                                fontSize: 10,
                                color: AppColors.battleAdminPurple,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            log['action'] as String? ?? 'Admin Action',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              log['details'] as String? ?? '',
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionBar(String title, double pct, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: AppRadii.borderSm,
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.surfaceSubtle,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildPeakHour(String time, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: AppRadii.cardSubtle,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              desc,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
