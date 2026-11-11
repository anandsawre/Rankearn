import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart' hide BattleType;
import '../../overview/banner_image_data.dart';
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
  String _battleSearchQuery = '';
  String _selectedBattleType = 'All Types';
  String _selectedBattleStatus = 'All Status';
  final Set<String> _selectedBattleIds = {};
  int _battleCurrentPage = 1;
  static const int _battleRowsPerPage = 8;

  List<BattleItem> get _filteredBattles {
    return _service.battles.where((b) {
      if (_selectedBattleType == '1 vs 1' && b.type != BattleType.oneVOne) return false;
      if (_selectedBattleType == 'Multiplayer' && b.type != BattleType.multiplayer) return false;
      if (_selectedBattleType == 'Rooms' && b.type != BattleType.room) return false;

      if (_selectedBattleStatus != 'All Status') {
        if (b.status.label.toLowerCase() != _selectedBattleStatus.toLowerCase()) return false;
      }

      if (_battleSearchQuery.isNotEmpty) {
        final q = _battleSearchQuery.toLowerCase();
        final matchesId = b.id.toLowerCase().contains(q);
        final matchesSubject = b.subject.toLowerCase().contains(q);
        final matchesPlayer = b.participants.any((p) => p.name.toLowerCase().contains(q));
        final matchesRoom = b.roomName?.toLowerCase().contains(q) ?? false;
        if (!matchesId && !matchesSubject && !matchesPlayer && !matchesRoom) {
          return false;
        }
      }

      return true;
    }).toList();
  }

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
          padding: AppSpacing.pagePadding(context),
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
              // ROW 3: LIVE BATTLES TABLE + RIGHT SIDEBAR CARDS
              // ==========================================
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Live Battles Monitoring Table (approx 65% width)
                    Expanded(
                      flex: 65,
                      child: _buildLiveBattlesCard(),
                    ),
                    const SizedBox(width: 20),

                    // Right Column: Battle Control, Live Chart, Today's Summary, Ongoing Rooms (approx 35% width)
                    Expanded(
                      flex: 35,
                      child: Column(
                        children: [
                          _buildBattleControlCard(),
                          const SizedBox(height: 16),
                          _buildLiveChartCard(),
                          const SizedBox(height: 16),
                          _buildTodaySummaryCard(),
                          const SizedBox(height: 16),
                          _buildOngoingRoomsCard(),
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
                    const SizedBox(height: 20),
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
            return AdminMetricCard(
              width: cardWidth,
              title: m.title,
              value: m.value,
              growth: m.growth,
              subtitle: m.subtitle,
              badge: m.isLive ? _buildRedLivePill() : null,
              icon: m.icon,
              color: m.color,
              sparklineData: m.sparklineData,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRedLivePill() {
    return const AppLivePill();
  }

  // ==========================================
  // ROW 3: LIVE BATTLES MONITORING TABLE CARD
  // Powered by unified AdminDataTableCard from design_system
  // ==========================================
  Widget _buildLiveBattlesCard() {
    final allBattles = _filteredBattles;
    final totalCount = allBattles.length;
    final totalPages = math.max(1, (totalCount / _battleRowsPerPage).ceil());
    final safePage = _battleCurrentPage.clamp(1, totalPages);
    final startIndex = (safePage - 1) * _battleRowsPerPage;
    final endIndex = math.min(startIndex + _battleRowsPerPage, totalCount);
    final pagedBattles = (startIndex < totalCount)
        ? allBattles.sublist(startIndex, endIndex)
        : <BattleItem>[];
    final allSelected = pagedBattles.isNotEmpty &&
        pagedBattles.every((b) => _selectedBattleIds.contains(b.id));

    return AdminDataTableCard(
      title: 'Live Battles List',
      totalCount: totalCount,
      icon: Icons.sports_kabaddi_rounded,
      iconBgColor: AppColors.battleAdminPurple,
      searchQuery: _battleSearchQuery,
      searchHint: 'Search live battles...',
      onSearchChanged: (q) {
        setState(() {
          _battleSearchQuery = q;
          _battleCurrentPage = 1;
        });
      },
      currentPage: safePage,
      totalPages: totalPages,
      onPageChanged: (p) => setState(() => _battleCurrentPage = p),
      itemLabel: 'live battles',
      minWidth: 840,
      filterControls: [
        AdminTableDropdown(
          value: _selectedBattleType,
          items: const [
            'All Types',
            '1 vs 1',
            'Multiplayer',
            'Rooms',
          ],
          onChanged: (val) {
            setState(() {
              _selectedBattleType = val;
              _battleCurrentPage = 1;
            });
          },
        ),
        AdminTableDropdown(
          value: _selectedBattleStatus,
          items: const [
            'All Status',
            'Live',
            'Waiting',
            'Paused',
            'Completed',
          ],
          onChanged: (val) {
            setState(() {
              _selectedBattleStatus = val;
              _battleCurrentPage = 1;
            });
          },
        ),
        AdminTableFiltersButton(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Filter drawer opened with advanced battle criteria.'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
      columns: [
        DataColumn(
          label: SizedBox(
            width: 20,
            child: Checkbox(
              value: allSelected,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedBattleIds.addAll(pagedBattles.map((b) => b.id));
                  } else {
                    for (final b in pagedBattles) {
                      _selectedBattleIds.remove(b.id);
                    }
                  }
                });
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              activeColor: AppColors.battleAdminPurple,
            ),
          ),
        ),
        DataColumn(label: Text('#', style: _headerStyle)),
        DataColumn(label: Text('Type', style: _headerStyle)),
        DataColumn(label: Text('Battle ID', style: _headerStyle)),
        DataColumn(label: Text('Players / Room', style: _headerStyle)),
        DataColumn(label: Text('• Subject', style: _headerStyle)),
        DataColumn(label: Text('Players', style: _headerStyle)),
        DataColumn(label: Text('• Status', style: _headerStyle)),
        DataColumn(label: Text('Time Left', style: _headerStyle)),
        DataColumn(label: Text('Actions', style: _headerStyle)),
      ],
      rows: List.generate(pagedBattles.length, (index) {
        final b = pagedBattles[index];
        final isSelected = _selectedBattleIds.contains(b.id);
        final rowIndex = startIndex + index + 1;

        return DataRow(
          selected: isSelected,
          onSelectChanged: (_) {
            setState(() {
              if (isSelected) {
                _selectedBattleIds.remove(b.id);
              } else {
                _selectedBattleIds.add(b.id);
              }
            });
          },
          color: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return const Color(0xFFF8FAFC);
            }
            if (isSelected) {
              return const Color(0xFFEEF2FF);
            }
            return Colors.white;
          }),
          cells: [
            DataCell(
              SizedBox(
                width: 20,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) {
                    setState(() {
                      if (isSelected) {
                        _selectedBattleIds.remove(b.id);
                      } else {
                        _selectedBattleIds.add(b.id);
                      }
                    });
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  activeColor: AppColors.battleAdminPurple,
                ),
              ),
            ),
            DataCell(
              Text(
                '$rowIndex',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            DataCell(_buildTypeBadge(b.type)),
            DataCell(
              Text(
                b.id,
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            DataCell(_buildPlayersCell(b)),
            DataCell(_buildSubjectBadge(b.subject)),
            DataCell(
              Text(
                '${b.totalPlayers}',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            DataCell(
              b.status == BattleStatus.live
                  ? const AppLivePill()
                  : AdminTableStatusBadge(
                      label: b.status.label,
                      backgroundColor: b.status == BattleStatus.completed
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFEFF6FF),
                      textColor: b.status == BattleStatus.completed
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF3B82F6),
                    ),
            ),
            DataCell(
              Text(
                b.formattedTimeLeft,
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminTableActionButton(
                    icon: Icons.visibility_outlined,
                    tooltip: 'View Battle',
                    onTap: () {
                      AppModalDialog.show(
                        context: context,
                        builder: (_) => BattleDetailDialog(battle: b),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.bar_chart_rounded,
                    tooltip: 'Analytics',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Analytics opened for Battle ${b.id}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.stop_circle_outlined,
                    tooltip: 'End Battle',
                    color: AppColors.error,
                    onTap: () {
                      AppModalDialog.show(
                        context: context,
                        builder: (_) => ConfirmActionDialog(
                          title: 'End Battle',
                          description:
                              'Are you sure you want to forcibly terminate Battle ${b.id}?',
                          confirmLabel: 'End Battle',
                          isDestructive: true,
                          onConfirm: (reason) async {
                            _service.endSingleBattle(
                                b.id, true, reason.isEmpty ? 'Force ended by admin' : reason);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Battle ${b.id} ended'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  static TextStyle get _headerStyle => TextStyle(
        fontFamily: AppTypography.fontHeading,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
      );

  Widget _buildTypeBadge(BattleType type) {
    return AdminTableStatusBadge(
      label: type.label,
      backgroundColor: type.bgColor,
      textColor: type.color,
    );
  }

  Widget _buildSubjectBadge(String subject) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);

    final lower = subject.toLowerCase();
    if (lower.contains('science')) {
      bg = const Color(0xFFEEF2FF);
      text = const Color(0xFF6366F1);
    } else if (lower.contains('math')) {
      bg = const Color(0xFFFFF1F2);
      text = const Color(0xFFF43F5E);
    } else if (lower.contains('reasoning')) {
      bg = const Color(0xFFF0F9FF);
      text = const Color(0xFF0284C7);
    } else if (lower.contains('awareness') || lower.contains('current')) {
      bg = const Color(0xFFFFF7ED);
      text = const Color(0xFFEA580C);
    } else if (lower.contains('chemistry')) {
      bg = const Color(0xFFFDF2F8);
      text = const Color(0xFFDB2777);
    } else if (lower.contains('biology')) {
      bg = const Color(0xFFF0FDF4);
      text = const Color(0xFF16A34A);
    }

    return AdminTableStatusBadge(
      label: subject,
      backgroundColor: bg,
      textColor: text,
    );
  }

  Widget _buildPlayersCell(BattleItem b) {
    if (b.type == BattleType.oneVOne && b.participants.length >= 2) {
      final p1 = b.participants[0];
      final p2 = b.participants[1];
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: AppColors.borderSubtle,
            backgroundImage: NetworkImage(p1.avatarUrl),
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 80),
            child: Text(
              p1.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              'vs',
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
              ),
            ),
          ),
          CircleAvatar(
            radius: 11,
            backgroundColor: AppColors.borderSubtle,
            backgroundImage: NetworkImage(p2.avatarUrl),
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 80),
            child: Text(
              p2.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      );
    } else if (b.type == BattleType.room) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.meeting_room_outlined,
            size: 15,
            color: AppColors.brandBlue,
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              b.roomName ?? 'Custom Room',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.fontHeading,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.groups_rounded,
            size: 15,
            color: AppColors.coinGold,
          ),
          const SizedBox(width: 6),
          Text(
            '${b.totalPlayers} Players',
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildSubjectPill(String subject) {
    Color bg;
    Color fg;
    IconData icon;

    final lower = subject.toLowerCase();
    if (lower.contains('science')) {
      bg = AppColors.brandGreenLight;
      fg = AppColors.brandGreenDark;
      icon = Icons.science_outlined;
    } else if (lower.contains('reasoning')) {
      bg = AppColors.brandPurpleLight;
      fg = AppColors.brandPurple;
      icon = Icons.psychology_outlined;
    } else if (lower.contains('math')) {
      bg = AppColors.brandBlueLight;
      fg = AppColors.brandBlueDark;
      icon = Icons.calculate_outlined;
    } else if (lower.contains('awareness')) {
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
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
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
  Widget _buildBattleControlCard({double? height}) {
    return AppCard(
      height: height,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_esports_rounded, color: AppColors.battleAdminPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Battle Control',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
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
                    AppModalDialog.show(
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
                    AppModalDialog.show(
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
            Text(label, style: TextStyle(fontFamily: AppTypography.fontHeading, fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
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
            Text(label, style: TextStyle(fontFamily: AppTypography.fontHeading, fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ROW 3: PLAYERS IN LIVE BATTLES (AREA CHART)
  // ==========================================
  Widget _buildLiveChartCard({double? height}) {
    return AppCard(
      height: height ?? 240,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, color: AppColors.battleAdminPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Players in Live Battles',
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
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
  Widget _buildTodaySummaryCard({double? height}) {
    return AppCard(
      height: height ?? 260,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: AppColors.battleAdminPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                "Today's Battle Summary",
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
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
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          count,
          style: TextStyle(
            fontFamily: AppTypography.fontHeading,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          growth,
          style: TextStyle(
            fontFamily: AppTypography.fontHeading,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.brandGreen,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // ROW 4: ONGOING ROOMS CARD
  // ==========================================
  Widget _buildOngoingRoomsCard({double? height}) {
    final rooms = _service.ongoingRooms;

    return AppCard(
      height: height ?? 280,
      padding: const EdgeInsets.all(22),
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
                    'Ongoing Rooms (${rooms.length})',
                    style: TextStyle(
                      fontFamily: AppTypography.fontHeading,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: widget.onGoToRooms,
                borderRadius: AppRadii.button,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.battleAdminPurple,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.battleAdminPurple),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: rooms.isEmpty
                ? Center(
                    child: Text(
                      'No active rooms found',
                      style: TextStyle(
                        fontFamily: AppTypography.fontHeading,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: rooms.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final r = rooms[idx];
                      Color iconBg;
                      Color iconFg;
                      IconData iconData;

                      switch (idx % 3) {
                        case 0:
                          iconBg = AppColors.brandBlueLight;
                          iconFg = AppColors.brandBlueDark;
                          iconData = Icons.groups_rounded;
                          break;
                        case 1:
                          iconBg = AppColors.brandPurpleLight;
                          iconFg = AppColors.brandPurple;
                          iconData = Icons.group_work_rounded;
                          break;
                        default:
                          iconBg = AppColors.brandGreenLight;
                          iconFg = AppColors.brandGreenDark;
                          iconData = Icons.sports_esports_rounded;
                          break;
                      }

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
                                color: iconBg,
                                borderRadius: AppRadii.borderMd,
                              ),
                              alignment: Alignment.center,
                              child: Icon(iconData, size: 16, color: iconFg),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontHeading,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${r.currentPlayers} / ${r.maxPlayers}',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontHeading,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildSubjectPill(r.subject),
                            const SizedBox(width: 8),
                            const AppLivePill(),
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
