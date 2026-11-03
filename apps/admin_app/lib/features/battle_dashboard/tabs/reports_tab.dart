import 'package:flutter/material.dart';
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

  void _exportCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading battle_report_2026.csv... Export successful!'),
        backgroundColor: AppColors.brandGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER BAR
          Row(
            children: [
              Column(
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
                    'Evaluate battle engagement, revenue commissions, coin sinks and retention velocity',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              // Range Filter
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
                    ],
                    onChanged: (v) => setState(() => _timeRange = v!),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _exportCSV,
                icon: const Icon(Icons.download_rounded, size: 16),
                label: Text(
                  'Export CSV',
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
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Total Matches Hosted',
                  _timeRange == 'Today' ? '3,802' : '28,490',
                  '↑ +24%',
                  AppColors.battleAdminPurple,
                  AppColors.brandPurpleLight,
                  Icons.sports_kabaddi_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricTile(
                  'Total Coin Volume',
                  _timeRange == 'Today' ? '184,200' : '1,420,500',
                  '↑ +19%',
                  AppColors.coinGold,
                  AppColors.coinGoldLight,
                  Icons.monetization_on_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricTile(
                  'Platform Rake (15%)',
                  _timeRange == 'Today' ? '27,630 Coins' : '213,075 Coins',
                  '↑ +18%',
                  AppColors.brandGreen,
                  AppColors.brandGreenLight,
                  Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricTile(
                  'Completion Rate',
                  '98.4%',
                  '↑ +1.2%',
                  AppColors.brandBlue,
                  AppColors.brandBlueLight,
                  Icons.check_circle_outline_rounded,
                ),
              ),
            ],
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
                      _buildDistributionBar('1 vs 1 Battles', 0.65, '65% (18,518 Matches)', AppColors.battleAdminPurple),
                      const SizedBox(height: 14),
                      _buildDistributionBar('Multiplayer Competitions', 0.23, '23% (6,552 Matches)', AppColors.coinGold),
                      const SizedBox(height: 14),
                      _buildDistributionBar('Custom User Rooms', 0.12, '12% (3,420 Rooms)', AppColors.brandBlue),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Hourly Traffic
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
                        'Peak Battle Hours',
                        style: AppTypography.headingSmall.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPeakHour('12:00 PM - 02:00 PM', 'High Activity (Lunch Hour)', AppColors.brandGreen),
                      const SizedBox(height: 10),
                      _buildPeakHour('06:00 PM - 10:00 PM', 'Prime Peak Traffic (Evening Clashes)', AppColors.battleAdminPurple),
                      const SizedBox(height: 10),
                      _buildPeakHour('10:00 PM - 12:00 AM', 'Late Night Tournament Rush', AppColors.warning),
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
                      'Administrative Audit Log (Real-time)',
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
                      'No administrative overrides recorded yet in this session.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _service.auditLogs.length.clamp(0, 5),
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
                              log['time'] as String? ?? 'Just now',
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

  Widget _buildMetricTile(String label, String value, String growth, Color color, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      growth,
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandGreen,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
