import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart';
import 'models/lucky_wheel_item.dart';
import 'widgets/lucky_wheel_hero_card.dart';
import 'widgets/lucky_wheel_quick_actions.dart';
import 'widgets/lucky_wheel_metrics_row.dart';
import 'widgets/lucky_wheel_table_card.dart';
import 'widgets/wheel_reward_donut_card.dart';
import 'widgets/spins_trend_bar_card.dart';
import 'widgets/lucky_wheel_recent_activity_card.dart';
import 'dialogs/create_campaign_dialog.dart';
import 'dialogs/set_rewards_dialog.dart';
import 'dialogs/manage_campaigns_dialog.dart';
import 'dialogs/spin_history_dialog.dart';
import 'dialogs/send_wheel_notification_dialog.dart';
import 'dialogs/export_wheel_reports_dialog.dart';

class LuckyWheelTab extends StatefulWidget {
  final VoidCallback? onGoToUsers;
  final VoidCallback? onGoToFinance;

  const LuckyWheelTab({
    super.key,
    this.onGoToUsers,
    this.onGoToFinance,
  });

  @override
  State<LuckyWheelTab> createState() => _LuckyWheelTabState();
}

class _LuckyWheelTabState extends State<LuckyWheelTab> {
  List<LuckyWheelCampaignItem> _allCampaigns = List.from(kDefaultLuckyWheelCampaigns);
  String _searchQuery = '';
  String _selectedStatus = 'All Status';
  String _selectedRewardType = 'All Reward Types';
  DateTimeRange? _selectedDateRange;
  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchSupabaseCampaigns();
  }

  Future<void> _fetchSupabaseCampaigns() async {
    try {
      final client = SupabaseConfig.clientSafe;
      if (client == null) return;
      final response = await client
          .from('lucky_wheel_campaigns')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      if (response.isNotEmpty && mounted) {
        final List<LuckyWheelCampaignItem> loaded = [];
        for (int i = 0; i < response.length; i++) {
          loaded.add(LuckyWheelCampaignItem.fromJson(response[i], i));
        }
        setState(() {
          _allCampaigns = loaded;
        });
      }
    } catch (e) {
      debugPrint('Supabase fetch notice (using robust local dataset): $e');
    }
  }

  List<LuckyWheelCampaignItem> get _filteredItems {
    return _allCampaigns.where((item) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = item.title.toLowerCase().contains(q) ||
            item.subtitle.toLowerCase().contains(q) ||
            item.rewardType.label.toLowerCase().contains(q);
        if (!match) return false;
      }
      if (_selectedStatus != 'All Status' &&
          item.status.label.toLowerCase() != _selectedStatus.toLowerCase()) {
        return false;
      }
      if (_selectedRewardType != 'All Reward Types' &&
          item.rewardType.label.toLowerCase() != _selectedRewardType.toLowerCase()) {
        return false;
      }
      if (_selectedDateRange != null) {
        if (item.startDate.isBefore(_selectedDateRange!.start) ||
            item.startDate.isAfter(_selectedDateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _openCreateDialog([LuckyWheelCampaignItem? editItem]) {
    showDialog(
      context: context,
      builder: (ctx) => CreateLuckyWheelDialog(
        editItem: editItem,
        onCampaignCreated: (newCamp) {
          setState(() {
            if (editItem != null) {
              final idx = _allCampaigns.indexWhere((c) => c.id == editItem.id);
              if (idx != -1) _allCampaigns[idx] = newCamp;
            } else {
              _allCampaigns.insert(0, newCamp);
            }
          });
        },
      ),
    );
  }

  void _openSetRewardsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => const SetRewardsDialog(),
    );
  }

  void _openManageCampaignsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ManageCampaignsDialog(
        campaigns: _allCampaigns,
        onToggleStatus: (updated) {
          setState(() {
            final idx = _allCampaigns.indexWhere((c) => c.id == updated.id);
            if (idx != -1) _allCampaigns[idx] = updated;
          });
        },
      ),
    );
  }

  void _openSpinHistoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => const SpinHistoryDialog(),
    );
  }

  void _openNotificationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => const SendWheelNotificationDialog(),
    );
  }

  void _openExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => const ExportWheelReportsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth >= 1050;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Section: Hero Banner + Quick Actions
              if (isDesktop) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 7,
                      child: LuckyWheelHeroCard(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 5,
                      child: LuckyWheelQuickActions(
                        onCreateLuckyWheel: () => _openCreateDialog(),
                        onSetRewards: _openSetRewardsDialog,
                        onManageCampaigns: _openManageCampaignsDialog,
                        onSpinHistory: _openSpinHistoryDialog,
                        onSendNotification: _openNotificationDialog,
                        onExportReports: _openExportDialog,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const LuckyWheelHeroCard(),
                const SizedBox(height: 12),
                LuckyWheelQuickActions(
                  onCreateLuckyWheel: () => _openCreateDialog(),
                  onSetRewards: _openSetRewardsDialog,
                  onManageCampaigns: _openManageCampaignsDialog,
                  onSpinHistory: _openSpinHistoryDialog,
                  onSendNotification: _openNotificationDialog,
                  onExportReports: _openExportDialog,
                ),
              ],
              const SizedBox(height: 14),

              // 2. Statistics Cards Row (5 Cards)
              LuckyWheelMetricsRow(
                totalCampaigns: _allCampaigns.length < 18 ? 18 : _allCampaigns.length,
                totalParticipants: 24560,
                totalRewardsGiven: 12450,
                activeCampaigns: _allCampaigns.where((c) => c.status == WheelCampaignStatus.active).length < 5
                    ? 5
                    : _allCampaigns.where((c) => c.status == WheelCampaignStatus.active).length,
                totalSpins: 78320,
              ),
              const SizedBox(height: 14),

              // 3. Main Section: Table (Left) + Analytics (Right)
              if (isDesktop) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Table
                    Expanded(
                      child: LuckyWheelTableCard(
                        items: filtered,
                        totalCount: 18,
                        currentPage: _currentPage,
                        rowsPerPage: _rowsPerPage,
                        searchQuery: _searchQuery,
                        selectedStatus: _selectedStatus,
                        selectedRewardType: _selectedRewardType,
                        dateRange: _selectedDateRange,
                        onSearchChanged: (q) => setState(() => _searchQuery = q),
                        onStatusChanged: (st) => setState(() => _selectedStatus = st),
                        onRewardTypeChanged: (rt) => setState(() => _selectedRewardType = rt),
                        onDateRangeChanged: (r) => setState(() => _selectedDateRange = r),
                        onPageChanged: (p) => setState(() => _currentPage = p),
                        onRowsPerPageChanged: (r) => setState(() => _rowsPerPage = r),
                        onViewCampaign: (item) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Viewing campaign "${item.title}" (${item.totalSpins} spins)')),
                          );
                        },
                        onAnalyticsCampaign: (item) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Analytics for "${item.title}": ${item.participants} distinct users')),
                          );
                        },
                        onEditCampaign: (item) => _openCreateDialog(item),
                        onDeleteCampaign: (item) {
                          setState(() {
                            _allCampaigns.removeWhere((c) => c.id == item.id);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Campaign "${item.title}" deleted')),
                          );
                        },
                        onDuplicateCampaign: (item) {
                          final duplicated = item.copyWith(
                            title: '${item.title} (Copy)',
                          );
                          setState(() {
                            _allCampaigns.insert(0, duplicated);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Duplicated "${item.title}"')),
                          );
                        },
                        onTogglePauseCampaign: (item) {
                          final updatedStatus = item.status == WheelCampaignStatus.paused
                              ? WheelCampaignStatus.active
                              : WheelCampaignStatus.paused;
                          setState(() {
                            final idx = _allCampaigns.indexWhere((c) => c.id == item.id);
                            if (idx != -1) {
                              _allCampaigns[idx] = item.copyWith(status: updatedStatus);
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                updatedStatus == WheelCampaignStatus.paused
                                    ? 'Paused "${item.title}"'
                                    : 'Resumed "${item.title}"',
                              ),
                            ),
                          );
                        },
                        onFiltersTap: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedStatus = 'All Status';
                            _selectedRewardType = 'All Reward Types';
                            _selectedDateRange = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Right Column: Analytics (Donut, Spins Trend, Recent Activity)
                    SizedBox(
                      width: 295,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          WheelRewardDonutCard(
                            totalCount: 18,
                            onViewAll: _openManageCampaignsDialog,
                          ),
                          const SizedBox(height: 12),
                          SpinsTrendBarCard(
                            onViewAll: _openSpinHistoryDialog,
                          ),
                          const SizedBox(height: 12),
                          LuckyWheelRecentActivityCard(
                            onViewAll: _openSpinHistoryDialog,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Tablet/Mobile: Stacked layout
                LuckyWheelTableCard(
                  items: filtered,
                  totalCount: 18,
                  currentPage: _currentPage,
                  rowsPerPage: _rowsPerPage,
                  searchQuery: _searchQuery,
                  selectedStatus: _selectedStatus,
                  selectedRewardType: _selectedRewardType,
                  dateRange: _selectedDateRange,
                  onSearchChanged: (q) => setState(() => _searchQuery = q),
                  onStatusChanged: (st) => setState(() => _selectedStatus = st),
                  onRewardTypeChanged: (rt) => setState(() => _selectedRewardType = rt),
                  onDateRangeChanged: (r) => setState(() => _selectedDateRange = r),
                  onPageChanged: (p) => setState(() => _currentPage = p),
                  onRowsPerPageChanged: (r) => setState(() => _rowsPerPage = r),
                  onViewCampaign: (item) {},
                  onAnalyticsCampaign: (item) {},
                  onEditCampaign: (item) => _openCreateDialog(item),
                  onDeleteCampaign: (item) {},
                ),
                const SizedBox(height: 14),
                WheelRewardDonutCard(
                  totalCount: 18,
                  onViewAll: _openManageCampaignsDialog,
                ),
                const SizedBox(height: 12),
                SpinsTrendBarCard(
                  onViewAll: _openSpinHistoryDialog,
                ),
                const SizedBox(height: 12),
                LuckyWheelRecentActivityCard(
                  onViewAll: _openSpinHistoryDialog,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
