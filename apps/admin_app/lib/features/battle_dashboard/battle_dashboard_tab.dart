import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
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
  BattleNavSubTab _activeTab = BattleNavSubTab.overview;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      width: double.infinity,
      child: Column(
        children: [
          // 1. HORIZONTAL SUB-NAVIGATION BAR (Strictly following Centralized Design System)
          _buildHorizontalNavigationBar(),

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
  Widget _buildHorizontalNavigationBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
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

          // Integrated System Live Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.brandGreenLight,
              borderRadius: AppRadii.borderSm,
              border: Border.all(color: AppColors.brandGreenMuted),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.brandGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'System Live',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandGreenDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          padding: const EdgeInsets.symmetric(vertical: 8),
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
              const SizedBox(width: 7),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
