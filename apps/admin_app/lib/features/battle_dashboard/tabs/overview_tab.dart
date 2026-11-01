import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart' hide BattleType;
import '../../overview/banner_image_data.dart';
import '../../overview/overview_charts.dart';
import '../models/battle_dashboard_models.dart';
import '../services/battle_dashboard_service.dart';
import '../widgets/live_players_chart.dart';
import '../dialogs/create_battle_dialog.dart';
import '../dialogs/create_room_dialog.dart';
import '../dialogs/manage_games_dialog.dart';
import '../dialogs/broadcast_dialog.dart';
import '../dialogs/battle_detail_dialog.dart';
import '../dialogs/confirm_action_dialog.dart';

class BattleOverviewTab extends StatefulWidget {
  final VoidCallback onGoToRooms;
  final VoidCallback? onGoToOneVsOne;
  final VoidCallback? onGoToMultiplayer;
  final VoidCallback? onGoToPlayers;
  final VoidCallback? onGoToSettings;
  final VoidCallback? onGoToReports;

  const BattleOverviewTab({
    super.key,
    required this.onGoToRooms,
    this.onGoToOneVsOne,
    this.onGoToMultiplayer,
    this.onGoToPlayers,
    this.onGoToSettings,
    this.onGoToReports,
  });

  @override
  State<BattleOverviewTab> createState() => _BattleOverviewTabState();
}

class _BattleOverviewTabState extends State<BattleOverviewTab> {
  final _service = BattleDashboardService();
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1100;
        final isMid = constraints.maxWidth > 980;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // ROW 1: HERO BANNER (Left) + QUICK ACTIONS (Right)
              // (Identical Pattern to Admin Side Dashboard)
              // ==========================================
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

              // ==========================================
              // ROW 2: 5 METRIC KPI CARDS WITH SPARKLINES
              // ==========================================
              _buildMetricCardsRow(),
              const SizedBox(height: 20),

              // ==========================================
              // ROW 3: LIVE BATTLES TABLE + CONTROL & CHART
              // ==========================================
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Live Battles Monitoring Table (approx 68% width)
                    Expanded(
                      flex: 68,
                      child: _buildLiveBattlesCard(),
                    ),
                    const SizedBox(width: 20),

                    // Right Column: Battle Control Center + Live Players Chart (approx 32% width)
                    Expanded(
                      flex: 32,
                      child: Column(
                        children: [
                          _buildBattleControlCard(),
                          const SizedBox(height: 20),
                          _buildLiveChartCard(),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildLiveBattlesCard(),
                    const SizedBox(height: 20),
                    _buildBattleControlCard(),
                    const SizedBox(height: 20),
                    _buildLiveChartCard(),
                  ],
                ),
              const SizedBox(height: 20),

              // ==========================================
              // ROW 4: TODAY'S SUMMARY + ONGOING ROOMS
              // ==========================================
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 42, child: _buildTodaySummaryCard()),
                    const SizedBox(width: 20),
                    Expanded(flex: 58, child: _buildOngoingRoomsCard()),
                  ],
                )
              else
                Column(
                  children: [
                    _buildTodaySummaryCard(),
                    const SizedBox(height: 20),
                    _buildOngoingRoomsCard(),
                  ],
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // ROW 1: HERO BANNER (Left)
  // ==========================================
  Widget _buildBattleHeroBanner(bool isSmall) {
    return Container(
      height: 124,
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
                  width: isSmall ? 220 : 360,
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

  // ==========================================
  // ROW 1: QUICK ACTIONS (Right)
  // ==========================================
  Widget _buildQuickActionsCard() {
    final battleActions = [
      QuickActionItemData(
        label: '+ Create\nBattle',
        icon: Icons.add_circle_outline_rounded,
        iconColor: const Color(0xFF7C3AED),
        cardColor: const Color(0xFFF3E8FF),
        onTap: () => showDialog(context: context, builder: (_) => const CreateBattleDialog()),
      ),
      QuickActionItemData(
        label: 'Create\nRoom',
        icon: Icons.meeting_room_outlined,
        iconColor: const Color(0xFF0EA5E9),
        cardColor: const Color(0xFFE0F2FE),
        onTap: () => showDialog(context: context, builder: (_) => const CreateRoomDialog()),
      ),
      QuickActionItemData(
        label: 'Manage\nGames',
        icon: Icons.tune_rounded,
        iconColor: const Color(0xFFF59E0B),
        cardColor: const Color(0xFFFEF3C7),
        onTap: () => showDialog(context: context, builder: (_) => const ManageGamesDialog()),
      ),
      QuickActionItemData(
        label: 'Broadcast\nNotice',
        icon: Icons.campaign_outlined,
        iconColor: const Color(0xFF10B981),
        cardColor: const Color(0xFFD1FAE5),
        onTap: () => showDialog(context: context, builder: (_) => const BroadcastDialog()),
      ),
      QuickActionItemData(
        label: '1 vs 1\nBattles',
        icon: Icons.sports_kabaddi_rounded,
        iconColor: const Color(0xFFEC4899),
        cardColor: const Color(0xFFFCE7F3),
        onTap: widget.onGoToOneVsOne ?? () {},
      ),
      QuickActionItemData(
        label: 'Audit\nReports',
        icon: Icons.bar_chart_rounded,
        iconColor: const Color(0xFF6366F1),
        cardColor: const Color(0xFFEEF2FF),
        onTap: widget.onGoToReports ?? () {},
      ),
    ];

    return QuickActionsCard(
      height: 124,
      compact: true,
      actions: battleActions,
    );
  }

  // ==========================================
  // ROW 2: 5 METRIC KPI CARDS WITH SPARKLINES
  // ==========================================
  Widget _buildMetricCardsRow() {
    final metrics = [
      (
        title: 'Active Players',
        value: '12,840',
        growth: '+12%',
        subtitle: '+1,420 joined today',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF7C3AED),
        sparklineData: const [10.0, 12.0, 14.5, 13.0, 16.5, 19.0, 24.0],
        isLive: false,
      ),
      (
        title: '1 vs 1 Battles',
        value: '4,326',
        growth: '+18%',
        subtitle: '+180 active today',
        icon: Icons.sports_kabaddi_rounded,
        color: const Color(0xFFEC4899),
        sparklineData: const [8.0, 11.0, 10.0, 13.5, 15.0, 17.5, 22.0],
        isLive: false,
      ),
      (
        title: 'Multiplayer Battles',
        value: '682',
        growth: '+9%',
        subtitle: '+45 running today',
        icon: Icons.groups_rounded,
        color: const Color(0xFFF59E0B),
        sparklineData: const [5.0, 6.0, 7.5, 8.0, 9.5, 11.0, 14.0],
        isLive: false,
      ),
      (
        title: 'Active Rooms',
        value: '316',
        growth: '',
        subtitle: '28 rooms active now',
        icon: Icons.storefront_rounded,
        color: const Color(0xFF0EA5E9),
        sparklineData: const [4.0, 6.0, 5.5, 7.0, 6.8, 8.5, 9.0],
        isLive: true,
      ),
      (
        title: 'Overall Win Rate',
        value: '91%',
        growth: '+3%',
        subtitle: 'Fair play verified',
        icon: Icons.sports_esports_rounded,
        color: const Color(0xFF10B981),
        sparklineData: const [85.0, 87.0, 88.0, 89.5, 90.0, 90.5, 91.0],
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
            return Container(
              width: cardWidth,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
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
              child: Row(
                children: [
                  // Icon Circular Badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: m.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(m.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),

                  // Middle Value and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                m.value,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (m.growth.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  m.growth,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                            if (m.isLive) ...[
                              const SizedBox(width: 6),
                              _buildRedLivePill(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          m.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.subtitle,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Right Sparkline Chart
                  SparklineChart(
                    data: m.sparklineData,
                    color: m.color,
                    width: 58,
                    height: 28,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRedLivePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: const BoxDecoration(
        color: AppColors.liveRedLight,
        borderRadius: AppRadii.badge,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppColors.liveRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Live',
            style: AppTypography.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.liveRed,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ROW 3: LIVE BATTLES MONITORING TABLE CARD
  // ==========================================
  Widget _buildLiveBattlesCard() {
    final battles = _service.filteredBattles;

    return Container(
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
          // Table Card Header
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.brandPurpleLight,
                  borderRadius: AppRadii.borderMd,
                ),
                child: const Icon(Icons.sports_kabaddi_rounded, color: AppColors.brandPurple, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Live Battles (Real-time)',
                style: AppTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              _buildRedLivePill(),
              const Spacer(),
              // View Fullscreen Button
              InkWell(
                onTap: () {
                  setState(() => _isFullscreen = !_isFullscreen);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isFullscreen ? 'Fullscreen table mode enabled' : 'Normal view restored'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: AppRadii.button,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: AppRadii.button,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                        size: 16,
                        color: AppColors.brandPurple,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'View Fullscreen',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sub-Filter Tabs: All (1,324), 1 vs 1 (856), Multiplayer (328), Rooms (140)
          Row(
            children: [
              _buildSubFilterTab('All (1,324)', 'All'),
              const SizedBox(width: 8),
              _buildSubFilterTab('1 vs 1 (856)', '1 vs 1'),
              const SizedBox(width: 8),
              _buildSubFilterTab('Multiplayer (328)', 'Multiplayer'),
              const SizedBox(width: 8),
              _buildSubFilterTab('Rooms (140)', 'Rooms'),
            ],
          ),
          const SizedBox(height: 18),

          // The Table
          ClipRRect(
            borderRadius: AppRadii.borderLg,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderSubtle),
                borderRadius: AppRadii.borderLg,
              ),
              child: Column(
                children: [
                  // Table Column Header
                  Container(
                    height: 42,
                    color: AppColors.surfaceSubtle,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const SizedBox(width: 30, child: Text('#', style: _headerStyle)),
                        const SizedBox(width: 90, child: Text('Type', style: _headerStyle)),
                        const SizedBox(width: 95, child: Text('Battle ID', style: _headerStyle)),
                        const Expanded(flex: 3, child: Text('Players / Room', style: _headerStyle)),
                        const Expanded(flex: 3, child: Text('Subject', style: _headerStyle)),
                        const SizedBox(width: 60, child: Text('Players', textAlign: TextAlign.center, style: _headerStyle)),
                        const SizedBox(width: 80, child: Text('Status', textAlign: TextAlign.center, style: _headerStyle)),
                        const SizedBox(width: 75, child: Text('Time Left', textAlign: TextAlign.center, style: _headerStyle)),
                        const SizedBox(width: 60, child: Text('Actions', textAlign: TextAlign.center, style: _headerStyle)),
                      ],
                    ),
                  ),

                  // Table Rows
                  if (battles.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Text('No battles found matching criteria.', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                    )
                  else
                    ...battles.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final b = entry.value;
                      return _buildTableRow(index, b);
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _headerStyle = AppTypography.labelSmall;

  Widget _buildSubFilterTab(String label, String key) {
    final isSelected = _service.currentFilter == key;
    return InkWell(
      onTap: () => _service.setFilter(key),
      borderRadius: AppRadii.borderSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.battleAdminPurple : AppColors.surfaceSubtle,
          borderRadius: AppRadii.borderSm,
          border: Border.all(
            color: isSelected ? AppColors.battleAdminPurple : AppColors.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(int index, BattleItem b) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // # Index
          SizedBox(
            width: 30,
            child: Text(
              '$index',
              style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),

          // Type Badge
          SizedBox(
            width: 90,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  color: b.type.bgColor,
                  borderRadius: AppRadii.badge,
                ),
                child: Text(
                  b.type.label,
                  style: AppTypography.captionBold.copyWith(
                    fontSize: 10.5,
                    color: b.type.color,
                  ),
                ),
              ),
            ),
          ),

          // Battle ID
          SizedBox(
            width: 95,
            child: Text(
              b.id,
              style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),

          // Players / Room
          Expanded(
            flex: 3,
            child: _buildPlayersCell(b),
          ),

          // Subject Pill with Icon
          Expanded(
            flex: 3,
            child: _buildSubjectPill(b.subject),
          ),

          // Players Count
          SizedBox(
            width: 60,
            child: Text(
              '${b.totalPlayers}',
              textAlign: TextAlign.center,
              style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ),

          // Status Badge
          SizedBox(
            width: 80,
            child: Center(
              child: _buildRedLivePill(),
            ),
          ),

          // Time Left
          SizedBox(
            width: 75,
            child: Text(
              b.formattedTimeLeft,
              textAlign: TextAlign.center,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontFamily: 'monospace',
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: 60,
            child: Center(
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => BattleDetailDialog(battle: b),
                  );
                },
                borderRadius: AppRadii.borderSm,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.brandPurpleLight,
                    borderRadius: AppRadii.borderSm,
                  ),
                  child: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.brandPurple),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersCell(BattleItem b) {
    if (b.type == BattleType.oneVOne && b.participants.length >= 2) {
      final p1 = b.participants[0];
      final p2 = b.participants[1];
      return Row(
        children: [
          CircleAvatar(radius: 11, backgroundImage: NetworkImage(p1.avatarUrl)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              p1.name,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text('vs', style: AppTypography.labelSmall.copyWith(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
          ),
          CircleAvatar(radius: 11, backgroundImage: NetworkImage(p2.avatarUrl)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              p2.name,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
        ],
      );
    } else if (b.type == BattleType.room) {
      return Row(
        children: [
          const Icon(Icons.meeting_room_outlined, size: 15, color: AppColors.brandBlue),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              b.roomName ?? 'Custom Room',
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
        ],
      );
    } else {
      return Text(
        '${b.totalPlayers} Players',
        style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      );
    }
  }

  Widget _buildSubjectPill(String subject) {
    Color bg;
    Color fg;
    IconData icon;

    if (subject.toLowerCase().contains('science')) {
      bg = AppColors.brandGreenLight;
      fg = AppColors.brandGreenDark;
      icon = Icons.science_outlined;
    } else if (subject.toLowerCase().contains('reasoning')) {
      bg = AppColors.brandPurpleLight;
      fg = AppColors.brandPurple;
      icon = Icons.psychology_outlined;
    } else if (subject.toLowerCase().contains('math')) {
      bg = AppColors.brandBlueLight;
      fg = AppColors.brandBlueDark;
      icon = Icons.calculate_outlined;
    } else if (subject.toLowerCase().contains('awareness')) {
      bg = AppColors.brandOrangeLight;
      fg = AppColors.brandOrange;
      icon = Icons.menu_book_outlined;
    } else {
      bg = AppColors.brandPurpleLight;
      fg = AppColors.brandPurpleDark;
      icon = Icons.style_outlined;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
        decoration: BoxDecoration(color: bg, borderRadius: AppRadii.chip),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                subject,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.captionBold.copyWith(fontSize: 10.5, color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ROW 3: BATTLE CONTROL CARD
  // ==========================================
  Widget _buildBattleControlCard() {
    return Container(
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
              const Icon(Icons.sports_esports_rounded, color: AppColors.battleAdminPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Battle Control',
                style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 1: Start (soft green) | Pause (soft amber) | End (soft red)
          Row(
            children: [
              Expanded(
                child: _buildControlBtn(
                  label: 'Start',
                  icon: Icons.play_arrow_rounded,
                  bg: AppColors.brandGreenLight,
                  fg: AppColors.brandGreenDark,
                  onTap: () => _service.startAllWaiting(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildControlBtn(
                  label: 'Pause',
                  icon: Icons.pause_rounded,
                  bg: AppColors.coinGoldLight,
                  fg: AppColors.warning,
                  onTap: () => _service.pauseAllLive(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildControlBtn(
                  label: 'End',
                  icon: Icons.stop_rounded,
                  bg: AppColors.liveRedLight,
                  fg: AppColors.liveRedDark,
                  onTap: () => _service.endAllLive(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Force End (red border) | Add Time (purple border) | Clear Room (red border)
          Row(
            children: [
              Expanded(
                child: _buildOutlinedControlBtn(
                  label: 'Force End',
                  icon: Icons.power_settings_new_rounded,
                  color: AppColors.liveRed,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => ConfirmActionDialog(
                        title: 'Force End All Active Battles?',
                        description: 'This will immediately abort all ongoing matches and record an administrative override in audit logs.',
                        confirmLabel: 'Force End',
                        isDestructive: true,
                        onConfirm: (reason) async {
                          _service.forceEndLive(reason);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOutlinedControlBtn(
                  label: 'Add Time',
                  icon: Icons.timer_outlined,
                  color: AppColors.battleAdminPurple,
                  onTap: () => _service.addTimeToAll(30),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOutlinedControlBtn(
                  label: 'Clear Room',
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.liveRed,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => ConfirmActionDialog(
                        title: 'Clear All Active Rooms?',
                        description: 'This will disconnect all room participants and reset active rooms state.',
                        confirmLabel: 'Clear All Rooms',
                        isDestructive: true,
                        onConfirm: (reason) async {
                          _service.clearAllRooms(reason);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn({
    required String label,
    required IconData icon,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.borderSm,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(color: bg, borderRadius: AppRadii.borderSm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 4),
            Text(label, style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: fg)),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedControlBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.borderSm,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.borderSm,
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Text(label, style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ROW 3: PLAYERS IN LIVE BATTLES (AREA CHART)
  // ==========================================
  Widget _buildLiveChartCard() {
    return Container(
      height: 240,
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
              const Icon(Icons.person_outline_rounded, color: AppColors.battleAdminPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Players in Live Battles',
                style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Expanded(child: LivePlayersChart()),
        ],
      ),
    );
  }

  // ==========================================
  // ROW 4: TODAY'S BATTLE SUMMARY CARD
  // ==========================================
  Widget _buildTodaySummaryCard() {
    return Container(
      height: 280,
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
              const Icon(Icons.bar_chart_rounded, color: AppColors.battleAdminPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                "Today's Battle Summary",
                style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 18),

          _buildSummaryRow(
            icon: Icons.sports_kabaddi_rounded,
            iconColor: AppColors.battleAdminPurple,
            label: '1 vs 1 Battles',
            count: '3,120',
            growth: '↑ +20%',
          ),
          const Divider(height: 20, color: AppColors.borderSubtle),

          _buildSummaryRow(
            icon: Icons.groups_rounded,
            iconColor: AppColors.coinGold,
            label: 'Multiplayer Battles',
            count: '682',
            growth: '↑ +9%',
          ),
          const Divider(height: 20, color: AppColors.borderSubtle),

          _buildSummaryRow(
            icon: Icons.storefront_rounded,
            iconColor: AppColors.battleAdminPurple,
            label: 'Rooms Created',
            count: '316',
            growth: '↑ +14%',
          ),
          const Divider(height: 20, color: AppColors.borderSubtle),

          _buildSummaryRow(
            icon: Icons.sports_esports_rounded,
            iconColor: AppColors.brandGreen,
            label: 'Total Players Participated',
            count: '8,742',
            growth: '↑ +16%',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String count,
    required String growth,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ),
        Text(
          count,
          style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 8),
        Text(
          growth,
          style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.brandGreen),
        ),
      ],
    );
  }

  // ==========================================
  // ROW 4: ONGOING ROOMS CARD
  // ==========================================
  Widget _buildOngoingRoomsCard() {
    final rooms = _service.ongoingRooms;

    return Container(
      height: 280,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.meeting_room_outlined, color: AppColors.battleAdminPurple, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Ongoing Rooms (316)',
                    style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
              InkWell(
                onTap: widget.onGoToRooms,
                child: Row(
                  children: [
                    Text('View All', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.battleAdminPurple)),
                    const SizedBox(width: 3),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.battleAdminPurple),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: rooms.isEmpty
                ? Center(child: Text('No active rooms found', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)))
                : ListView.separated(
                    itemCount: rooms.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final r = rooms[idx];
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
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: idx == 0
                                    ? AppColors.brandBlueLight
                                    : idx == 1
                                        ? AppColors.brandPurpleLight
                                        : AppColors.brandGreenLight,
                                borderRadius: AppRadii.borderMd,
                              ),
                              child: Icon(
                                idx == 0
                                    ? Icons.groups_rounded
                                    : idx == 1
                                        ? Icons.group_work_rounded
                                        : Icons.sports_esports_rounded,
                                size: 16,
                                color: idx == 0
                                    ? AppColors.brandBlueDark
                                    : idx == 1
                                        ? AppColors.brandPurple
                                        : AppColors.brandGreenDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${r.currentPlayers} / ${r.maxPlayers}',
                                    style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            _buildSubjectPill(r.subject),
                            const SizedBox(width: 8),
                            _buildRedLivePill(),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.more_horiz_rounded, size: 18, color: AppColors.textMuted),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Room ${r.code} selected'), duration: const Duration(seconds: 1)),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
