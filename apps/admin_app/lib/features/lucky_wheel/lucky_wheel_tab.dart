import 'package:flutter/material.dart';
import 'package:data_layer/data_layer.dart'
    hide WheelRewardType, WheelCampaignStatus, WheelRewardSegment;
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
  List<LuckyWheelCampaignItem> _allCampaigns = [];
  bool _isLoading = true;
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
    setState(() => _isLoading = true);
    try {
      final res = await LuckyWheelRepository().getAllCampaigns();
      if (res.isSuccess && res.dataOrNull != null && mounted) {
        final list = res.dataOrNull!;
        setState(() {
          _allCampaigns = list
              .map((m) => LuckyWheelCampaignItem(
                    id: m.id,
                    rowNumber: m.rowNumber,
                    title: m.title,
                    subtitle: m.subtitle,
                    rewardType: m.rewardType,
                    startDate: m.startDate,
                    endDate: m.endDate,
                    totalSpins: m.totalSpins,
                    participants: m.participants,
                    status: m.status,
                    createdBy: m.createdBy,
                    spinCost: m.spinCost,
                    dailyLimit: m.dailyLimit,
                    campaignLimit: m.campaignLimit,
                    slices: m.slices,
                  ))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Supabase fetch error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        onCampaignCreated: (newCamp) async {
          setState(() {
            if (editItem != null) {
              final idx = _allCampaigns.indexWhere((c) => c.id == editItem.id);
              if (idx != -1) _allCampaigns[idx] = newCamp;
            } else {
              _allCampaigns.insert(0, newCamp);
            }
          });

          // Sync to database
          await LuckyWheelRepository().upsertCampaign(
            LuckyWheelCampaignModel(
              id: newCamp.id,
              title: newCamp.title,
              subtitle: newCamp.subtitle,
              rewardType: newCamp.rewardType,
              startDate: newCamp.startDate,
              endDate: newCamp.endDate,
              totalSpins: newCamp.totalSpins,
              participants: newCamp.participants,
              status: newCamp.status,
              createdBy: newCamp.createdBy,
              spinCost: newCamp.spinCost,
              dailyLimit: newCamp.dailyLimit,
              campaignLimit: newCamp.campaignLimit,
              slices: newCamp.slices,
            ),
          );
        },
      ),
    );
  }

  void _openSetRewardsDialog() {
    if (_allCampaigns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No campaigns found. Please create a campaign first.')),
      );
      return;
    }
    final active = _allCampaigns.firstWhere(
      (c) => c.status == WheelCampaignStatus.active,
      orElse: () => _allCampaigns.first,
    );

    showDialog(
      context: context,
      builder: (ctx) => SetRewardsDialog(
        initialSlices: active.slices.isNotEmpty ? active.slices : null,
        initialDailyLimit: active.dailyLimit,
        onSave: (newSlices, newDailyLimit) async {
          await LuckyWheelRepository().saveCampaignSlices(
            campaignId: active.id,
            slices: newSlices,
          );
          await LuckyWheelRepository().updateCampaignDailyLimit(
            campaignId: active.id,
            dailyLimit: newDailyLimit,
          );
          if (mounted) {
            setState(() {
              final idx = _allCampaigns.indexWhere((c) => c.id == active.id);
              if (idx != -1) {
                _allCampaigns[idx] = _allCampaigns[idx].copyWith(
                  slices: newSlices,
                  dailyLimit: newDailyLimit,
                );
              }
            });
          }
        },
      ),
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
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: Color(0xFFF1F5F9),
                    color: Color(0xFF10B981),
                  ),
                ),

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
                totalCampaigns: _allCampaigns.length,
                totalParticipants: _allCampaigns.fold<int>(0, (sum, c) => sum + c.participants),
                totalRewardsGiven: _allCampaigns.fold<int>(0, (sum, c) => sum + (c.totalSpins > 0 ? c.totalSpins * 10 : 0)),
                activeCampaigns: _allCampaigns.where((c) => c.status == WheelCampaignStatus.active).length,
                totalSpins: _allCampaigns.fold<int>(0, (sum, c) => sum + c.totalSpins),
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
                        totalCount: filtered.length,
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
                            totalCount: _allCampaigns.length,
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
                  totalCount: filtered.length,
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
                  totalCount: _allCampaigns.length,
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
