import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart' hide BattleType;
import '../models/battle_dashboard_models.dart';
import '../services/battle_dashboard_service.dart';
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
                  _buildKpiCard(
                    title: 'Live 1v1 Duels',
                    value: '$liveCount',
                    subtitle: 'Active now in arena',
                    icon: Icons.sports_kabaddi_rounded,
                    color: AppColors.battleAdminPurple,
                    bg: AppColors.brandPurpleLight,
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Waiting in Queue',
                    value: '$waitingCount',
                    subtitle: 'Seeking opponents',
                    icon: Icons.hourglass_top_rounded,
                    color: AppColors.coinGold,
                    bg: AppColors.coinGoldLight,
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Completed Today',
                    value: '$completedCount',
                    subtitle: 'Rewards settled',
                    icon: Icons.task_alt_rounded,
                    color: AppColors.brandGreen,
                    bg: AppColors.brandGreenLight,
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Cancelled / Disputed',
                    value: '$cancelledCount',
                    subtitle: 'Coins refunded',
                    icon: Icons.cancel_outlined,
                    color: AppColors.liveRed,
                    bg: AppColors.liveRedLight,
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
              Column(
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
                  ),
                ],
              ),
              const Spacer(),
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

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bg,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
            id: 'p1',
            name: 'Player 1',
            avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&auto=format&fit=crop&q=80',
          );
    final p2 = b.participants.length > 1
        ? b.participants[1]
        : const BattleParticipant(
            id: 'p2',
            name: 'Matching Opponent...',
            avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=100&auto=format&fit=crop&q=80',
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
                CircleAvatar(radius: 19, backgroundImage: NetworkImage(p1.avatarUrl)),
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
                        'Score: ${p1.score} • Correct: ${p1.correctAnswers}',
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
                  CircleAvatar(radius: 19, backgroundImage: NetworkImage(p2.avatarUrl)),
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Score: ${p2.score} • Correct: ${p2.correctAnswers}',
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
              IconButton(
                icon: const Icon(Icons.add_alarm_rounded, size: 18, color: AppColors.brandGreen),
                tooltip: 'Add Extra Time (+30s)',
                onPressed: () {
                  _service.addTimeToBattle(b.id, 30);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added +30s to match ${b.id}'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: AppColors.brandGreen,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.liveRed),
                tooltip: 'Cancel Match & Refund',
                onPressed: () {
                  AppModalDialog.show(
                    context: context,
                    builder: (_) => ConfirmActionDialog(
                      title: 'Cancel Match ${b.id}?',
                      description: 'This will cancel the match, trigger entry fee refund transactions, and record audit logs.',
                      confirmLabel: 'Cancel & Refund',
                      isDestructive: true,
                      onConfirm: (reason) async {
                        _service.endSingleBattle(b.id, true, reason);
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
