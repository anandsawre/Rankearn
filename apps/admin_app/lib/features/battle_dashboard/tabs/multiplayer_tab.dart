import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart' hide BattleType;
import '../models/battle_dashboard_models.dart';
import '../services/battle_dashboard_service.dart';
import '../dialogs/create_battle_dialog.dart';
import '../dialogs/confirm_action_dialog.dart';
import '../dialogs/battle_detail_dialog.dart';

class BattleMultiplayerTab extends StatefulWidget {
  const BattleMultiplayerTab({super.key});

  @override
  State<BattleMultiplayerTab> createState() => _BattleMultiplayerTabState();
}

class _BattleMultiplayerTabState extends State<BattleMultiplayerTab> {
  final _service = BattleDashboardService();
  String _activeFilter = 'All'; // 'All', 'Live', 'Waiting', 'Completed'
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
    final multiplayerBattles = _service.battles.where((b) => b.type == BattleType.multiplayer).toList();
    final liveArenas = multiplayerBattles.where((b) => b.status == BattleStatus.live).length;
    final waitingArenas = multiplayerBattles.where((b) => b.status == BattleStatus.waiting).length;
    final totalPlayersInMulti = multiplayerBattles.fold<int>(0, (sum, b) => sum + b.totalPlayers);
    final totalPrizePool = multiplayerBattles.fold<int>(0, (sum, b) => sum + b.prizePool);

    final filtered = multiplayerBattles.where((b) {
      if (_activeFilter == 'Live' && b.status != BattleStatus.live) return false;
      if (_activeFilter == 'Waiting' && b.status != BattleStatus.waiting) return false;
      if (_activeFilter == 'Completed' && b.status != BattleStatus.completed) return false;

      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final matchId = b.id.toLowerCase().contains(q);
        final matchTitle = b.title.toLowerCase().contains(q);
        final matchSubject = b.subject.toLowerCase().contains(q);
        if (!matchId && !matchTitle && !matchSubject) return false;
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
                    title: 'Active Arenas',
                    value: '$liveArenas',
                    subtitle: 'Multiplayer competitions live',
                    icon: Icons.groups_rounded,
                    color: AppColors.battleAdminPurple,
                    iconBgColor: AppColors.brandPurpleLight,
                    iconColor: AppColors.battleAdminPurple,
                    width: cardWidth,
                  ),
                  AdminMetricCard(
                    title: 'Total Contestants',
                    value: '$totalPlayersInMulti',
                    subtitle: 'Players in arenas right now',
                    icon: Icons.person_pin_circle_rounded,
                    color: AppColors.brandBlue,
                    iconBgColor: AppColors.brandBlueLight,
                    iconColor: AppColors.brandBlue,
                    width: cardWidth,
                  ),
                  AdminMetricCard(
                    title: 'Total Prize Pool',
                    value: '$totalPrizePool',
                    subtitle: 'Coins distributed to winners',
                    icon: Icons.monetization_on_rounded,
                    color: AppColors.coinGold,
                    iconBgColor: AppColors.coinGoldLight,
                    iconColor: AppColors.coinGold,
                    width: cardWidth,
                  ),
                  AdminMetricCard(
                    title: 'Waiting for Launch',
                    value: '$waitingArenas',
                    subtitle: 'Filling player capacity',
                    icon: Icons.schedule_rounded,
                    color: AppColors.brandGreen,
                    iconBgColor: AppColors.brandGreenLight,
                    iconColor: AppColors.brandGreen,
                    width: cardWidth,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // 2. SCHEMA STATUS NOTICE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.brandBlueLight,
              borderRadius: AppRadii.borderMd,
              border: Border.all(color: AppColors.brandBlue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.brandBlueDark),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Supabase table public.battles currently stores 1 vs 1 matches only. Multiplayer arena counts reflect live database rows (0 active).',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandBlueDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. HEADER BAR (Title, Search, Create Arena Button)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Multiplayer Competition Management (3–100 Players)',
                      style: AppTypography.headingSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Monitor large participant arenas, capacity scaling, question pace and live leaderboards',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Search Input
              SizedBox(
                width: 240,
                child: TextField(
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search Arena / Subject...',
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
                  '+ Create Arena',
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
              _buildFilterPill('All Arenas', multiplayerBattles.length),
              const SizedBox(width: 8),
              _buildFilterPill('Live', liveArenas),
              const SizedBox(width: 8),
              _buildFilterPill('Waiting', waitingArenas),
              const SizedBox(width: 8),
              _buildFilterPill('Completed', multiplayerBattles.where((b) => b.status == BattleStatus.completed).length),
            ],
          ),
          const SizedBox(height: 18),

          // 4. ARENA CARDS LIST
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
                  const Icon(Icons.groups_rounded, size: 40, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    'No multiplayer competitions found matching criteria.',
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
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final b = filtered[index];
                return _buildMultiplayerCard(b);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String title, int count) {
    final isSelected = _activeFilter == title || (_activeFilter == 'All' && title == 'All Arenas');
    return InkWell(
      onTap: () => setState(() => _activeFilter = title == 'All Arenas' ? 'All' : title),
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

  Widget _buildMultiplayerCard(BattleItem b) {
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
          // Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: const BoxDecoration(
                  color: AppColors.coinGoldLight,
                  borderRadius: AppRadii.badge,
                ),
                child: Text(
                  'Multiplayer',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                b.title,
                style: AppTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${b.id})',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: b.status == BattleStatus.live
                      ? AppColors.liveRedLight
                      : AppColors.surfaceSubtle,
                  borderRadius: AppRadii.badge,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: b.status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      b.status.label,
                      style: AppTypography.labelSmall.copyWith(
                        color: b.status.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Details Grid
          Row(
            children: [
              // Capacity & Progress
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Player Capacity: ${b.totalPlayers} / ${b.maxPlayers}',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${((b.totalPlayers / b.maxPlayers) * 100).toInt()}% Full',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: AppRadii.borderSm,
                      child: LinearProgressIndicator(
                        value: b.totalPlayers / b.maxPlayers,
                        backgroundColor: AppColors.surfaceSubtle,
                        color: AppColors.coinGold,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Subject Pill
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subject & Category', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Text(
                      '${b.subject} (${b.category})',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Question Progress
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Question', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Text(
                      'Q ${b.currentQuestion} / ${b.totalQuestions}',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.battleAdminPurple,
                      ),
                    ),
                  ],
                ),
              ),

              // Remaining Time
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time Left', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Text(
                      b.formattedTimeLeft,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.liveRed,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              // Prize Pool
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prize Pool', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Text(
                      '${b.prizePool} Coins',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bottom Action Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  AppModalDialog.show(context: context, builder: (_) => BattleDetailDialog(battle: b));
                },
                icon: const Icon(Icons.leaderboard_rounded, size: 16, color: AppColors.battleAdminPurple),
                label: Text(
                  'Live Leaderboard',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.battleAdminPurple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.battleAdminPurple),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              const SizedBox(width: 8),
              if (b.status == BattleStatus.waiting) ...[
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await _service.startSingleBattle(b.id);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Arena ${b.id} started'),
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
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: Text('Start Arena', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textOnPrimary)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (b.status == BattleStatus.live) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    AppModalDialog.show(
                      context: context,
                      builder: (_) => ConfirmActionDialog(
                        title: 'Complete Arena ${b.id}?',
                        description: 'Mark this competition as completed in Supabase.',
                        confirmLabel: 'Complete',
                        isDestructive: false,
                        onConfirm: (reason) async {
                          await _service.completeSingleBattle(b.id, reason: reason);
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.task_alt_rounded, size: 16),
                  label: Text('Complete', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textOnPrimary)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              ElevatedButton.icon(
                onPressed: () {
                  AppModalDialog.show(
                    context: context,
                    builder: (_) => ConfirmActionDialog(
                      title: 'Cancel Competition ${b.id}?',
                      description: 'This will cancel the competition in Supabase and log the audit reason.',
                      confirmLabel: 'Cancel Match',
                      isDestructive: true,
                      onConfirm: (reason) async {
                        await _service.cancelSingleBattle(b.id, reason);
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.stop_rounded, size: 16),
                label: Text(
                  'Cancel Competition',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.liveRed,
                  foregroundColor: AppColors.textOnPrimary,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
