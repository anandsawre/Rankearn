import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart' hide BattleType;
import '../models/battle_dashboard_models.dart';
import '../services/battle_dashboard_service.dart';
import '../widgets/battle_player_avatar.dart';
import '../widgets/live_players_chart.dart';
import '../dialogs/battle_players_dialog.dart';
import '../dialogs/battle_reports_dialog.dart';
import '../dialogs/battle_settings_dialog.dart';
import '../dialogs/create_battle_dialog.dart';
import '../dialogs/broadcast_dialog.dart';
import '../dialogs/battle_detail_dialog.dart';
import '../dialogs/confirm_action_dialog.dart';

class BattleOverviewTab extends StatefulWidget {
  final VoidCallback? onGoToRooms;
  final VoidCallback? onGoToOneVsOne;
  final VoidCallback? onGoToMultiplayer;
  final VoidCallback? onGoToPlayers;
  final VoidCallback? onGoToSettings;
  final VoidCallback? onGoToReports;
  final ValueNotifier<String>? battleTypeFilterNotifier;

  const BattleOverviewTab({
    super.key,
    this.onGoToRooms,
    this.onGoToOneVsOne,
    this.onGoToMultiplayer,
    this.onGoToPlayers,
    this.onGoToSettings,
    this.onGoToReports,
    this.battleTypeFilterNotifier,
  });

  @override
  State<BattleOverviewTab> createState() => _BattleOverviewTabState();
}

class _BattleOverviewTabState extends State<BattleOverviewTab> {
  final _service = BattleDashboardService();
  String _battleSearchQuery = '';
  late String _selectedBattleType = widget.battleTypeFilterNotifier?.value ?? 'All Types';
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
    widget.battleTypeFilterNotifier?.addListener(_onExternalTypeFilter);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    widget.battleTypeFilterNotifier?.removeListener(_onExternalTypeFilter);
    super.dispose();
  }

  void _onExternalTypeFilter() {
    final next = widget.battleTypeFilterNotifier?.value;
    if (next != null && next != _selectedBattleType && mounted) {
      setState(() {
        _selectedBattleType = next;
        _battleCurrentPage = 1;
      });
    }
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1100;

        if (isWide) {
          return Row(
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
          );
        }

        return Column(
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
        );
      },
    );
  }

  // ==========================================
  // LIVE BATTLES MONITORING TABLE CARD
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
            'Completed',
            'Cancelled',
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
            setState(() {
              _selectedBattleType = 'All Types';
              _selectedBattleStatus = 'All Status';
              _battleSearchQuery = '';
              _battleCurrentPage = 1;
            });
            _service.refresh();
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
        DataColumn(label: Text('Subject', style: _headerStyle)),
        DataColumn(label: Text('Players', style: _headerStyle)),
        DataColumn(label: Text('Status', style: _headerStyle)),
        DataColumn(label: Text('Duration', style: _headerStyle)),
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
                    icon: Icons.play_circle_outline_rounded,
                    tooltip: 'Start Battle',
                    onTap: b.status == BattleStatus.waiting
                        ? () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await _service.startSingleBattle(b.id);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Battle ${b.id} moved to Live'),
                                  backgroundColor: AppColors.brandGreen,
                                ),
                              );
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Failed to start battle: $e'),
                                  backgroundColor: AppColors.liveRed,
                                ),
                              );
                            }
                          }
                        : () {
                            AppModalDialog.show(
                              context: context,
                              builder: (_) => BattleDetailDialog(battle: b),
                            );
                          },
                  ),
                  const SizedBox(width: 4),
                  AdminTableActionButton(
                    icon: Icons.stop_circle_outlined,
                    tooltip: 'Cancel Battle',
                    color: AppColors.error,
                    onTap: () {
                      final messenger = ScaffoldMessenger.of(context);
                      AppModalDialog.show(
                        context: context,
                        builder: (_) => ConfirmActionDialog(
                          title: 'Cancel Battle',
                          description:
                              'Are you sure you want to cancel Battle ${b.id} in Supabase?',
                          confirmLabel: 'Cancel Battle',
                          isDestructive: true,
                          onConfirm: (reason) async {
                            await _service.cancelSingleBattle(
                              b.id,
                              reason.isEmpty ? 'Cancelled by admin' : reason,
                            );
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Battle ${b.id} cancelled'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
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
    if (b.type == BattleType.oneVOne && b.participants.isNotEmpty) {
      final p1 = b.participants[0];
      final p2 = b.participants.length >= 2 ? b.participants[1] : null;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BattlePlayerAvatar(
            name: p1.name,
            avatarUrl: p1.avatarUrl,
            radius: 11,
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
          if (p2 != null) ...[
            BattlePlayerAvatar(
              name: p2.name,
              avatarUrl: p2.avatarUrl,
              radius: 11,
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
          ] else
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 96),
              child: Text(
                'Waiting Queue',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.fontHeading,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
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

          // Row 1: Start Waiting | Complete Live | Cancel Open
          Row(
            children: [
              Expanded(
                child: _buildControlBtn(
                  label: 'Start Matched',
                  icon: Icons.play_arrow_rounded,
                  bg: AppColors.brandGreenLight,
                  fg: AppColors.brandGreenDark,
                  onTap: () async {
                    try {
                      final count = await _service.startAllWaiting();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            count == 0
                                ? 'No matched waiting battles to start'
                                : 'Started $count matched battles',
                          ),
                          backgroundColor: count == 0 ? AppColors.textSecondary : AppColors.brandGreen,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to start waiting battles: $e'), backgroundColor: AppColors.liveRed),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildControlBtn(
                  label: 'Complete Live',
                  icon: Icons.check_circle_outline_rounded,
                  bg: AppColors.coinGoldLight,
                  fg: AppColors.warning,
                  onTap: () {
                    AppModalDialog.show(
                      context: context,
                      builder: (_) => ConfirmActionDialog(
                        title: 'Complete All Active Battles?',
                        description: 'This updates all currently active 1v1 battles in Supabase to completed.',
                        confirmLabel: 'Complete Live',
                        isDestructive: false,
                        onConfirm: (reason) async {
                          await _service.completeAllActive(reason);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildControlBtn(
                  label: 'Cancel Open',
                  icon: Icons.stop_rounded,
                  bg: AppColors.liveRedLight,
                  fg: AppColors.liveRedDark,
                  onTap: () {
                    AppModalDialog.show(
                      context: context,
                      builder: (_) => ConfirmActionDialog(
                        title: 'Cancel All Open Battles?',
                        description: 'This cancels all waiting and active battles in Supabase and logs the reason.',
                        confirmLabel: 'Cancel Open',
                        isDestructive: true,
                        onConfirm: (reason) async {
                          await _service.cancelAllOpen(reason);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Refresh Sync | Create 1v1 | Broadcast
          Row(
            children: [
              Expanded(
                child: _buildOutlinedControlBtn(
                  label: 'Refresh DB',
                  icon: Icons.refresh_rounded,
                  color: AppColors.brandBlue,
                  onTap: () => _service.refresh(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOutlinedControlBtn(
                  label: 'New Battle',
                  icon: Icons.add_circle_outline_rounded,
                  color: AppColors.battleAdminPurple,
                  onTap: () => AppModalDialog.show(
                    context: context,
                    builder: (_) => const CreateBattleDialog(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOutlinedControlBtn(
                  label: 'Broadcast',
                  icon: Icons.campaign_outlined,
                  color: AppColors.brandGreenDark,
                  onTap: () => AppModalDialog.show(
                    context: context,
                    builder: (_) => const BroadcastDialog(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 3: Players | Settings | Reports (Modal Dialogs)
          Row(
            children: [
              Expanded(
                child: _buildControlBtn(
                  label: 'Players',
                  icon: Icons.people_outline_rounded,
                  bg: AppColors.brandPurpleLight,
                  fg: AppColors.battleAdminPurple,
                  onTap: widget.onGoToPlayers ??
                      () => AppModalDialog.show(
                            context: context,
                            builder: (_) => const BattlePlayersDialog(),
                          ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildControlBtn(
                  label: 'Settings',
                  icon: Icons.settings_outlined,
                  bg: AppColors.brandBlueLight,
                  fg: AppColors.brandBlueDark,
                  onTap: widget.onGoToSettings ??
                      () => AppModalDialog.show(
                            context: context,
                            builder: (_) => const BattleSettingsDialog(),
                          ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildControlBtn(
                  label: 'Reports',
                  icon: Icons.bar_chart_rounded,
                  bg: AppColors.surfaceSubtle,
                  fg: AppColors.textPrimary,
                  onTap: widget.onGoToReports ??
                      () => AppModalDialog.show(
                            context: context,
                            builder: (_) => const BattleReportsDialog(),
                          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
        decoration: BoxDecoration(color: bg, borderRadius: AppRadii.borderSm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: AppTypography.fontHeading, fontSize: 11, fontWeight: FontWeight.w700, color: fg),
              ),
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.borderSm,
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: AppTypography.fontHeading, fontSize: 11, fontWeight: FontWeight.w700, color: color),
              ),
            ),
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
          Expanded(
            child: Builder(
              builder: (_) {
                final series = _service.buildActivityChartSeries();
                return LivePlayersChart(
                  dates: series.labels,
                  values: series.values,
                  highlightedIndex: series.highlightedIndex,
                  tooltipValue: series.tooltipValue,
                  emptyText: 'No battle participant activity in last 7 days',
                );
              },
            ),
          ),
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
            label: '1 vs 1 Battles Today',
            count: '${_service.todayBattlesCount}',
            growth: _service.battlesGrowthLabel,
          ),
          const Divider(height: 20, color: AppColors.borderSubtle),
          _buildSummaryRow(
            icon: Icons.flash_on_rounded,
            iconColor: AppColors.liveRed,
            label: 'Currently Live Matches',
            count: '${_service.liveBattlesCount}',
            growth: '${_service.waitingBattlesCount} queued',
          ),
          const Divider(height: 20, color: AppColors.borderSubtle),
          _buildSummaryRow(
            icon: Icons.check_circle_outline_rounded,
            iconColor: AppColors.brandBlue,
            label: 'Completed All-Time',
            count: '${_service.completedBattlesCount}',
            growth: '${_service.completionRatePct.round()}% rate',
          ),
          const Divider(height: 20, color: AppColors.borderSubtle),
          _buildSummaryRow(
            icon: Icons.sports_esports_rounded,
            iconColor: AppColors.brandGreen,
            label: 'Unique Players Today',
            count: '${_service.todayParticipantsCount}',
            growth: _service.participantsGrowthLabel,
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
        if (growth.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(
            growth,
            style: TextStyle(
              fontFamily: AppTypography.fontHeading,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: growth.startsWith('-') ? AppColors.liveRed : AppColors.brandGreen,
            ),
          ),
        ],
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
                              icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.textMuted),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                              onPressed: widget.onGoToRooms,
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
