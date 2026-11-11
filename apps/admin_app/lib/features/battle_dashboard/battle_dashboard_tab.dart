import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'services/battle_dashboard_service.dart';
import 'tabs/overview_tab.dart';
import 'tabs/one_vs_one_tab.dart';
import 'tabs/multiplayer_tab.dart';
import 'tabs/rooms_tab.dart';
import 'tabs/players_tab.dart';
import 'tabs/settings_tab.dart';
import 'tabs/reports_tab.dart';

enum BattleNavSubTab {
  overview,
  oneVsOne,
  multiplayer,
  rooms,
  players,
  settings,
  reports,
}

class BattleDashboardTab extends StatefulWidget {
  const BattleDashboardTab({super.key});

  @override
  State<BattleDashboardTab> createState() => _BattleDashboardTabState();
}

class _BattleDashboardTabState extends State<BattleDashboardTab> {
  final _service = BattleDashboardService();
  BattleNavSubTab _activeTab = BattleNavSubTab.overview;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceChange);
    _service.ensureLoaded();
  }

  @override
  void reassemble() {
    super.reassemble();
    _service.refresh();
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChange);
    super.dispose();
  }

  void _onServiceChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      width: double.infinity,
      child: Column(
        children: [
          // 1. HORIZONTAL SUB-NAVIGATION BAR (Strictly following Centralized Design System)
          _buildHorizontalNavigationBar(context),

          // 2. MAIN BATTLE CONTENT AREA (FULL DESKTOP WIDTH)
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: switch (_activeTab) {
                BattleNavSubTab.overview => BattleOverviewTab(
                    onGoToRooms: () => setState(() => _activeTab = BattleNavSubTab.rooms),
                    onGoToOneVsOne: () => setState(() => _activeTab = BattleNavSubTab.oneVsOne),
                    onGoToMultiplayer: () => setState(() => _activeTab = BattleNavSubTab.multiplayer),
                    onGoToPlayers: () => setState(() => _activeTab = BattleNavSubTab.players),
                    onGoToSettings: () => setState(() => _activeTab = BattleNavSubTab.settings),
                    onGoToReports: () => setState(() => _activeTab = BattleNavSubTab.reports),
                  ),
                BattleNavSubTab.oneVsOne => const BattleOneVsOneTab(),
                BattleNavSubTab.multiplayer => const BattleMultiplayerTab(),
                BattleNavSubTab.rooms => const BattleRoomsTab(),
                BattleNavSubTab.players => const BattlePlayersTab(),
                BattleNavSubTab.settings => const BattleSettingsTab(),
                BattleNavSubTab.reports => const BattleReportsTab(),
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 1. HORIZONTAL NAVIGATION BAR (7 SUB-TABS)
  // ==========================================
  Widget _buildHorizontalNavigationBar(BuildContext context) {
    final hp = AppSpacing.horizontalPagePadding(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(hp, 16, hp, 12),
      child: Row(
        children: [
          // Horizontal Sub-Tab Bar
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.borderMd,
                border: Border.all(color: AppColors.borderSubtle, width: 1.2),
                boxShadow: AppShadows.subtle,
              ),
              child: Row(
                children: [
                  _buildNavTab(
                    tab: BattleNavSubTab.overview,
                    label: 'Overview',
                    icon: Icons.auto_awesome_rounded,
                  ),
                  _buildNavTab(
                    tab: BattleNavSubTab.oneVsOne,
                    label: '1 vs 1 Battles',
                    icon: Icons.sports_kabaddi_rounded,
                  ),
                  _buildNavTab(
                    tab: BattleNavSubTab.multiplayer,
                    label: 'Multiplayer',
                    icon: Icons.groups_rounded,
                  ),
                  _buildNavTab(
                    tab: BattleNavSubTab.rooms,
                    label: 'Rooms',
                    icon: Icons.storefront_rounded,
                  ),
                  _buildNavTab(
                    tab: BattleNavSubTab.players,
                    label: 'Players',
                    icon: Icons.people_outline_rounded,
                  ),
                  _buildNavTab(
                    tab: BattleNavSubTab.settings,
                    label: 'Settings',
                    icon: Icons.settings_outlined,
                  ),
                  _buildNavTab(
                    tab: BattleNavSubTab.reports,
                    label: 'Reports',
                    icon: Icons.bar_chart_rounded,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Live DB Connection / Maintenance Status Badge + Sync Button
          _buildSystemStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildSystemStatusBadge() {
    final bool isLoading = _service.isLoading;
    final bool hasError = _service.errorMessage != null;
    final bool offline = !_service.hasDbConnection;
    final bool maintenance = _service.settings.maintenanceMode;

    final Color bg;
    final Color border;
    final Color fg;
    final String label;

    if (isLoading) {
      bg = AppColors.brandBlueLight;
      border = AppColors.brandBlue.withValues(alpha: 0.3);
      fg = AppColors.brandBlueDark;
      label = 'Syncing DB…';
    } else if (offline) {
      bg = AppColors.surfaceSubtle;
      border = AppColors.borderSubtle;
      fg = AppColors.textSecondary;
      label = 'Supabase Offline';
    } else if (hasError) {
      bg = AppColors.liveRedLight;
      border = AppColors.liveRed.withValues(alpha: 0.35);
      fg = AppColors.liveRedDark;
      label = 'Sync Error';
    } else if (maintenance) {
      bg = AppColors.coinGoldLight;
      border = AppColors.warning.withValues(alpha: 0.4);
      fg = AppColors.warning;
      label = 'Maintenance Mode';
    } else {
      bg = AppColors.brandGreenLight;
      border = AppColors.brandGreenMuted;
      fg = AppColors.brandGreenDark;
      label = 'Supabase Live';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadii.borderSm,
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                )
              else
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
                ),
              const SizedBox(width: 7),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Refresh from Supabase',
          child: InkWell(
            onTap: isLoading ? null : () => _service.refresh(),
            borderRadius: AppRadii.borderSm,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.borderSm,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 16,
                color: isLoading ? AppColors.textMuted : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavTab({
    required BattleNavSubTab tab,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _activeTab == tab;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = tab),
        borderRadius: AppRadii.borderSm,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppColors.battleAdminPurple, AppColors.battleAdminPurpleSecondary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            borderRadius: AppRadii.borderSm,
            boxShadow: isSelected ? AppShadows.purpleGlow : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
