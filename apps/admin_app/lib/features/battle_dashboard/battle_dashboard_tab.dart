import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../overview/banner_image_data.dart';
import 'dialogs/battle_players_dialog.dart';
import 'dialogs/battle_reports_dialog.dart';
import 'dialogs/battle_settings_dialog.dart';
import 'dialogs/broadcast_dialog.dart';
import 'dialogs/create_battle_dialog.dart';
import 'dialogs/create_room_dialog.dart';
import 'dialogs/manage_games_dialog.dart';
import 'services/battle_dashboard_service.dart';
import 'tabs/overview_tab.dart';

class BattleDashboardTab extends StatefulWidget {
  const BattleDashboardTab({super.key});

  @override
  State<BattleDashboardTab> createState() => _BattleDashboardTabState();
}

class _BattleDashboardTabState extends State<BattleDashboardTab> {
  final _service = BattleDashboardService();
  final ValueNotifier<String> _battleTypeFilter = ValueNotifier<String>('All Types');

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
    _battleTypeFilter.dispose();
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMid = constraints.maxWidth > 980;

          return SingleChildScrollView(
            padding: AppSpacing.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_service.errorMessage != null) ...[
                  _buildStatusBanner(
                    message: _service.errorMessage!,
                    isError: true,
                  ),
                  const SizedBox(height: 16),
                ] else if (_service.isLoading && !_service.hasLoadedOnce) ...[
                  _buildStatusBanner(
                    message: 'Syncing live battle data from Supabase…',
                    isError: false,
                  ),
                  const SizedBox(height: 16),
                ],

                // 1. HERO BANNER + QUICK ACTIONS
                if (isMid)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 57,
                        child: _buildBattleHeroBanner(constraints.maxWidth < 1200),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 43,
                        child: _buildQuickActionsCard(),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildBattleHeroBanner(true),
                      const SizedBox(height: 16),
                      _buildQuickActionsCard(),
                    ],
                  ),
                const SizedBox(height: 20),

                // 2. 5 METRIC KPI CARDS
                _buildMetricCardsRow(),
                const SizedBox(height: 20),

                // 3. LIVE BATTLES TABLE + SIDEBAR (Battle Control, Chart, Summary, Rooms)
                SizedBox(
                  width: double.infinity,
                  child: BattleOverviewTab(
                    battleTypeFilterNotifier: _battleTypeFilter,
                    onGoToRooms: () => _battleTypeFilter.value = 'Rooms',
                    onGoToOneVsOne: () => _battleTypeFilter.value = '1 vs 1',
                    onGoToMultiplayer: () => _battleTypeFilter.value = 'Multiplayer',
                    onGoToPlayers: _openPlayersDialog,
                    onGoToSettings: _openSettingsDialog,
                    onGoToReports: _openReportsDialog,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openPlayersDialog() {
    AppModalDialog.show(context: context, builder: (_) => const BattlePlayersDialog());
  }

  void _openSettingsDialog() {
    AppModalDialog.show(context: context, builder: (_) => const BattleSettingsDialog());
  }

  void _openReportsDialog() {
    AppModalDialog.show(context: context, builder: (_) => const BattleReportsDialog());
  }

  Widget _buildStatusBanner({required String message, required bool isError}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isError ? AppColors.liveRedLight : AppColors.brandBlueLight,
        borderRadius: AppRadii.borderMd,
        border: Border.all(
          color: isError
              ? AppColors.liveRed.withValues(alpha: 0.35)
              : AppColors.brandBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.sync_rounded,
            size: 18,
            color: isError ? AppColors.liveRedDark : AppColors.brandBlueDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: isError ? AppColors.liveRedDark : AppColors.brandBlueDark,
              ),
            ),
          ),
          if (isError)
            TextButton.icon(
              onPressed: _service.isLoading ? null : () => _service.refresh(),
              icon: const Icon(Icons.refresh_rounded, size: 15),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.liveRedDark,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBattleHeroBanner(bool isSmall) {
    return Container(
      height: isSmall ? null : 124,
      constraints: isSmall ? const BoxConstraints(minHeight: 124) : null,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEEF2FF),
            Color(0xFFE0E7FF),
            Color(0xFFF0FDF4),
          ],
        ),
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.battleAdminPurple.withValues(alpha: 0.12),
                        borderRadius: AppRadii.badge,
                        border: Border.all(
                          color: AppColors.battleAdminPurple.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.battleAdminPurple,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'LIVE ARENA CONTROL',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.battleAdminPurple,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildSystemStatusBadge(),
                  ],
                ),
                const SizedBox(height: 6),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Battle & Live Games, ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          height: 1.15,
                        ),
                      ),
                      TextSpan(
                        text: 'Real-time ⚔️',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7C3AED),
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: isSmall ? double.infinity : 360,
                  child: const Text(
                    'Monitor 1 vs 1, multiplayer matches, rooms, player activity and control live game states.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.3,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (!isSmall)
            Positioned(
              right: 8,
              bottom: 0,
              top: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Image.memory(
                  kBannerCharacterBytes,
                  height: 124,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    final battleActions = [
      QuickActionItemData(
        label: '+ Create\nBattle',
        icon: Icons.add_circle_outline_rounded,
        iconColor: const Color(0xFF7C3AED),
        cardColor: const Color(0xFFF3E8FF),
        onTap: () => AppModalDialog.show(context: context, builder: (_) => const CreateBattleDialog()),
      ),
      QuickActionItemData(
        label: 'Create\nRoom',
        icon: Icons.meeting_room_outlined,
        iconColor: const Color(0xFF0EA5E9),
        cardColor: const Color(0xFFE0F2FE),
        onTap: () => AppModalDialog.show(context: context, builder: (_) => const CreateRoomDialog()),
      ),
      QuickActionItemData(
        label: 'Manage\nGames',
        icon: Icons.tune_rounded,
        iconColor: const Color(0xFFF59E0B),
        cardColor: const Color(0xFFFEF3C7),
        onTap: () => AppModalDialog.show(context: context, builder: (_) => const ManageGamesDialog()),
      ),
      QuickActionItemData(
        label: 'Broadcast\nNotice',
        icon: Icons.campaign_outlined,
        iconColor: const Color(0xFF10B981),
        cardColor: const Color(0xFFD1FAE5),
        onTap: () => AppModalDialog.show(context: context, builder: (_) => const BroadcastDialog()),
      ),
      QuickActionItemData(
        label: '1 vs 1\nBattles',
        icon: Icons.sports_kabaddi_rounded,
        iconColor: const Color(0xFFEC4899),
        cardColor: const Color(0xFFFCE7F3),
        onTap: () => _battleTypeFilter.value = '1 vs 1',
      ),
      QuickActionItemData(
        label: 'Audit\nReports',
        icon: Icons.bar_chart_rounded,
        iconColor: const Color(0xFF6366F1),
        cardColor: const Color(0xFFEEF2FF),
        onTap: _openReportsDialog,
      ),
    ];

    return QuickActionsCard(
      height: 124,
      compact: true,
      onCustomize: () => AppModalDialog.show(
        context: context,
        builder: (_) => const BattleSettingsDialog(),
      ),
      actions: battleActions,
    );
  }

  Widget _buildMetricCardsRow() {
    final metrics = [
      (
        title: 'Active Players',
        value: '${_service.activePlayersCount}',
        growth: _service.playersGrowthLabel,
        subtitle: '+${_service.todayJoinedPlayersCount} joined today',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF7C3AED),
        sparklineData: _service.sevenDayPlayersSparkline,
        isLive: false,
      ),
      (
        title: '1 vs 1 Battles',
        value: '${_service.oneVsOneCount}',
        growth: _service.battlesGrowthLabel,
        subtitle: '+${_service.todayBattlesCount} created today',
        icon: Icons.sports_kabaddi_rounded,
        color: const Color(0xFFEC4899),
        sparklineData: _service.sevenDayBattlesSparkline,
        isLive: false,
      ),
      (
        title: 'Live Arenas',
        value: '${_service.liveBattlesCount}',
        growth: '',
        subtitle: '${_service.waitingBattlesCount} waiting in queue',
        icon: Icons.flash_on_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: _service.sevenDayBattlesSparkline,
        isLive: _service.liveBattlesCount > 0,
      ),
      (
        title: 'Question Bank',
        value: '${_service.battleQuestionsCount}',
        growth: '',
        subtitle: '${_service.questionTopicCounts.length} active topics',
        icon: Icons.quiz_outlined,
        color: const Color(0xFF0EA5E9),
        sparklineData: const <double>[],
        isLive: false,
      ),
      (
        title: 'Completion Rate',
        value: '${_service.completionRatePct.round()}%',
        growth: '',
        subtitle: '${_service.completedBattlesCount} completed • ${_service.cancelledBattlesCount} cancelled',
        icon: Icons.sports_esports_rounded,
        color: const Color(0xFF10B981),
        sparklineData: const <double>[],
        isLive: false,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth > 1100
            ? (constraints.maxWidth - (16 * 4)) / 5
            : constraints.maxWidth > 700
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: metrics.map((m) {
            return AdminMetricCard(
              width: cardWidth,
              title: m.title,
              value: m.value,
              growth: m.growth,
              subtitle: m.subtitle,
              badge: m.isLive ? const AppLivePill() : null,
              icon: m.icon,
              color: m.color,
              sparklineData: m.sparklineData,
            );
          }).toList(),
        );
      },
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadii.badge,
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 9,
                  height: 9,
                  child: CircularProgressIndicator(strokeWidth: 1.8, color: fg),
                )
              else
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
                ),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: 'Refresh from Supabase',
          child: InkWell(
            onTap: isLoading ? null : () => _service.refresh(),
            borderRadius: AppRadii.badge,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: AppRadii.badge,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 13,
                color: isLoading ? AppColors.textMuted : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
