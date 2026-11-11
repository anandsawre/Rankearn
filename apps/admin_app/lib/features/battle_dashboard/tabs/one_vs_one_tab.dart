import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart' hide BattleType;
import '../models/battle_dashboard_models.dart';
import '../services/battle_dashboard_service.dart';
import '../widgets/battle_player_avatar.dart';
import '../dialogs/battle_detail_dialog.dart';
import '../dialogs/confirm_action_dialog.dart';
import '../dialogs/create_battle_dialog.dart';

class BattleOneVsOneTab extends StatefulWidget {
  const BattleOneVsOneTab({super.key});

  @override
  State<BattleOneVsOneTab> createState() => _BattleOneVsOneTabState();
}

class _BattleOneVsOneTabState extends State<BattleOneVsOneTab> {
  final _service = BattleDashboardService();
  String _activeSubTab = 'Live'; // 'All', 'Live', 'Waiting Queue', 'Completed', 'Cancelled'
  String _search = '';

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

  @override
  Widget build(BuildContext context) {
    final allOneVOne = _service.battles.where((b) => b.type == BattleType.oneVOne).toList();
    final liveCount = allOneVOne.where((b) => b.status == BattleStatus.live).length;
    final waitingCount = allOneVOne.where((b) => b.status == BattleStatus.waiting).length;
    final completedCount = allOneVOne.where((b) => b.status == BattleStatus.completed).length;
    final cancelledCount = allOneVOne.where((b) => b.status == BattleStatus.cancelled).length;

    final filtered = allOneVOne.where((b) {
      if (_activeSubTab == 'Live' && b.status != BattleStatus.live) return false;
      if (_activeSubTab == 'Waiting Queue' && b.status != BattleStatus.waiting) return false;
      if (_activeSubTab == 'Completed' && b.status != BattleStatus.completed) return false;
      if (_activeSubTab == 'Cancelled' && b.status != BattleStatus.cancelled) return false;

      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final matchId = b.id.toLowerCase().contains(q);
        final matchSubject = b.subject.toLowerCase().contains(q);
        final matchP = b.participants.any((p) => p.name.toLowerCase().contains(q));
        if (!matchId && !matchSubject && !matchP) return false;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOP KPI METRICS ROW
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth > 980
                  ? (constraints.maxWidth - (16 * 3)) / 4
                  : constraints.maxWidth > 600
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  AdminMetricCard(
                    title: 'Live 1v1 Duels',
                    value: '$liveCount',
                    subtitle: 'Active now in arena',
                    icon: Icons.sports_kabaddi_rounded,
                    color: AppColors.battleAdminPurple,
                    iconBgColor: AppColors.brandPurpleLight,
                    iconColor: AppColors.battleAdminPurple,
                    width: cardWidth,
                  ),
                  AdminMetricCard(
                    title: 'Waiting in Queue',
                    value: '$waitingCount',
                    subtitle: 'Seeking opponents',
                    icon: Icons.hourglass_top_rounded,
                    color: AppColors.coinGold,
                    iconBgColor: AppColors.coinGoldLight,
                    iconColor: AppColors.coinGold,
                    width: cardWidth,
                  ),
                  AdminMetricCard(
                    title: 'Completed 1v1',
                    value: '$completedCount',
                    subtitle: 'Settled in Supabase',
                    icon: Icons.task_alt_rounded,
                    color: AppColors.brandGreen,
                    iconBgColor: AppColors.brandGreenLight,
                    iconColor: AppColors.brandGreen,
                    width: cardWidth,
                  ),
                  AdminMetricCard(
                    title: 'Cancelled Matches',
                    value: '$cancelledCount',
                    subtitle: 'Aborted or expired',
                    icon: Icons.cancel_outlined,
                    color: AppColors.liveRed,
                    iconBgColor: AppColors.liveRedLight,
                    iconColor: AppColors.liveRed,
                    width: cardWidth,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // 2. HEADER BAR (Title, Search, Create Battle Button)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1 vs 1 Battle Management',
                      style: AppTypography.headingSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Real-time head-to-head match inspection, matchmaking queue and dispute controls',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Search Input
              SizedBox(
                width: 260,
                child: TextField(
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search ID, Subject, Player...',
                    hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: AppRadii.borderSm,
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadii.borderSm,
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadii.borderSm,
                      borderSide: const BorderSide(color: AppColors.battleAdminPurple, width: 1.5),
                    ),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  AppModalDialog.show(context: context, builder: (_) => const CreateBattleDialog());
                },
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(
                  '+ New 1v1 Battle',
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
          const SizedBox(height: 16),

          // 3. SUB FILTER PILLS
          Row(
            children: [
              _buildFilterPill('Live', liveCount),
              const SizedBox(width: 8),
              _buildFilterPill('Waiting Queue', waitingCount),
              const SizedBox(width: 8),
              _buildFilterPill('Completed', completedCount),
              const SizedBox(width: 8),
              _buildFilterPill('Cancelled', cancelledCount),
              const SizedBox(width: 8),
              _buildFilterPill('All', allOneVOne.length),
            ],
          ),
          const SizedBox(height: 18),

          // 4. MATCH CARDS LIST
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(48),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.card,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  const Icon(Icons.sports_kabaddi_rounded, size: 40, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    'No 1v1 battles found in this state.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final b = filtered[index];
                return _build1v1Card(b);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String title, int count) {
    final isSelected = _activeSubTab == title;
    return InkWell(
      onTap: () => setState(() => _activeSubTab = title),
      borderRadius: AppRadii.borderSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.battleAdminPurple : AppColors.surface,
          borderRadius: AppRadii.borderSm,
          border: Border.all(
            color: isSelected ? AppColors.battleAdminPurple : AppColors.borderSubtle,
          ),
        ),
        child: Text(
          '$title ($count)',
          style: AppTypography.labelSmall.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _build1v1Card(BattleItem b) {
    final p1 = b.participants.isNotEmpty
        ? b.participants[0]
        : const BattleParticipant(
            id: 'unknown',
            name: 'Unknown Creator',
            avatarUrl: '',
          );
    final p2 = b.participants.length > 1
        ? b.participants[1]
        : const BattleParticipant(
            id: 'waiting',
            name: 'Waiting for Opponent',
            avatarUrl: '',
          );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          // Battle ID & Subject
          Container(
            width: 145,
            padding: const EdgeInsets.only(right: 14),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.id,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  b.subject,
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.battleAdminPurple,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: b.status == BattleStatus.live
                        ? AppColors.liveRedLight
                        : AppColors.surfaceSubtle,
                    borderRadius: AppRadii.badge,
                  ),
                  child: Text(
                    b.status.label,
                    style: AppTypography.captionBold.copyWith(
                      fontSize: 10,
                      color: b.status.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Player 1
          Expanded(
            flex: 3,
            child: Row(
              children: [
                BattlePlayerAvatar(name: p1.name, avatarUrl: p1.avatarUrl, radius: 19),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p1.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Score: ${p1.score} • Rank #${p1.rank}',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // VS Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: const BoxDecoration(
              color: AppColors.brandPurpleLight,
              borderRadius: AppRadii.badge,
            ),
            child: Text(
              'VS',
              style: AppTypography.captionBold.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppColors.battleAdminPurple,
              ),
            ),
          ),

          // Player 2
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  BattlePlayerAvatar(name: p2.name, avatarUrl: p2.avatarUrl, radius: 19),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p2.name,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: b.participants.length > 1
                                ? AppColors.textPrimary
                                : AppColors.warning,
                          ),
                        ),
                        Text(
                          b.participants.length > 1
                              ? 'Score: ${p2.score} • Rank #${p2.rank}'
                              : 'Queue open',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Timer & Stakes
          Container(
            width: 135,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: AppColors.liveRed),
                    const SizedBox(width: 4),
                    Text(
                      b.formattedTimeLeft,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Fee: ${b.entryFee} / Win: ${b.prizePool}',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Admin Actions
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.battleAdminPurple),
                tooltip: 'View Match Details',
                onPressed: () {
                  AppModalDialog.show(context: context, builder: (_) => BattleDetailDialog(battle: b));
                },
              ),
              if (b.status == BattleStatus.waiting)
                IconButton(
                  icon: const Icon(Icons.play_arrow_rounded, size: 18, color: AppColors.brandGreen),
                  tooltip: 'Start Match',
                  onPressed: () async {
                    try {
                      await _service.startSingleBattle(b.id);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Started battle ${b.id}'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: AppColors.brandGreen,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.liveRed),
                      );
                    }
                  },
                )
              else if (b.status == BattleStatus.live)
                IconButton(
                  icon: const Icon(Icons.task_alt_rounded, size: 18, color: AppColors.brandGreen),
                  tooltip: 'Complete Match',
                  onPressed: () {
                    AppModalDialog.show(
                      context: context,
                      builder: (_) => ConfirmActionDialog(
                        title: 'Complete Match ${b.id}?',
                        description: 'Mark this active 1v1 battle as completed in Supabase.',
                        confirmLabel: 'Mark Completed',
                        isDestructive: false,
                        onConfirm: (reason) async {
                          await _service.completeSingleBattle(b.id, reason: reason);
                        },
                      ),
                    );
                  },
                ),
              if (b.status == BattleStatus.live || b.status == BattleStatus.waiting)
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.liveRed),
                  tooltip: 'Cancel Match',
                  onPressed: () {
                    AppModalDialog.show(
                      context: context,
                      builder: (_) => ConfirmActionDialog(
                        title: 'Cancel Match ${b.id}?',
                        description: 'This will set status to cancelled in Supabase and record an audit log entry.',
                        confirmLabel: 'Cancel Match',
                        isDestructive: true,
                        onConfirm: (reason) async {
                          await _service.cancelSingleBattle(b.id, reason);
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
