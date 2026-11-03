import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/battle_dashboard_models.dart';
import '../services/battle_dashboard_service.dart';
import '../dialogs/confirm_action_dialog.dart';

class BattlePlayersTab extends StatefulWidget {
  const BattlePlayersTab({super.key});

  @override
  State<BattlePlayersTab> createState() => _BattlePlayersTabState();
}

class _BattlePlayersTabState extends State<BattlePlayersTab> {
  final _service = BattleDashboardService();
  String _search = '';
  String _statusFilter = 'All'; // 'All', 'Active', 'Restricted', 'Suspended'

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
    final allPlayers = _service.players;
    final activeCount = allPlayers.where((p) => p.status == 'active').length;
    final restrictedCount = allPlayers.where((p) => p.status == 'restricted').length;
    final suspendedCount = allPlayers.where((p) => p.status == 'suspended').length;

    final filtered = allPlayers.where((p) {
      if (_statusFilter == 'Active' && p.status != 'active') return false;
      if (_statusFilter == 'Restricted' && p.status != 'restricted') return false;
      if (_statusFilter == 'Suspended' && p.status != 'suspended') return false;

      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final matchUser = p.username.toLowerCase().contains(q);
        final matchRank = p.rank.toLowerCase().contains(q);
        final matchId = p.id.toLowerCase().contains(q);
        if (!matchUser && !matchRank && !matchId) return false;
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
                    title: 'Total Players',
                    value: '${allPlayers.length}',
                    subtitle: 'Registered battle competitors',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.battleAdminPurple,
                    bg: AppColors.brandPurpleLight,
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Active Duellists',
                    value: '$activeCount',
                    subtitle: 'Clean standing accounts',
                    icon: Icons.verified_user_rounded,
                    color: AppColors.brandGreen,
                    bg: AppColors.brandGreenLight,
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Restricted Players',
                    value: '$restrictedCount',
                    subtitle: 'Under 24h duel restrictions',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    bg: AppColors.coinGoldLight,
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Suspended Accounts',
                    value: '$suspendedCount',
                    subtitle: 'Flagged for integrity review',
                    icon: Icons.block_rounded,
                    color: AppColors.liveRed,
                    bg: AppColors.liveRedLight,
                    width: cardWidth,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // 2. HEADER BAR (Title, Search)
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Player Management & Moderation',
                    style: AppTypography.headingSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Audit player win rates, duel ratings, disciplinary restrictions and account suspension',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                child: TextField(
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search Player / Rank / ID...',
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
            ],
          ),
          const SizedBox(height: 16),

          // 3. SUB FILTER PILLS
          Row(
            children: [
              _buildFilterPill('All Players', allPlayers.length),
              const SizedBox(width: 8),
              _buildFilterPill('Active', activeCount),
              const SizedBox(width: 8),
              _buildFilterPill('Restricted', restrictedCount),
              const SizedBox(width: 8),
              _buildFilterPill('Suspended', suspendedCount),
            ],
          ),
          const SizedBox(height: 18),

          // 4. PLAYER CARDS LIST
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
                  const Icon(Icons.person_off_rounded, size: 40, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    'No players found matching filter.',
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
                final p = filtered[index];
                return _buildPlayerCard(p);
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
    final isSelected = _statusFilter == title || (_statusFilter == 'All' && title == 'All Players');
    return InkWell(
      onTap: () => setState(() => _statusFilter = title == 'All Players' ? 'All' : title),
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

  Widget _buildPlayerCard(PlayerBattleRecord p) {
    Color statusBg;
    Color statusFg;
    if (p.status == 'active') {
      statusBg = AppColors.brandGreenLight;
      statusFg = AppColors.brandGreenDark;
    } else if (p.status == 'restricted') {
      statusBg = AppColors.coinGoldLight;
      statusFg = AppColors.warning;
    } else {
      statusBg = AppColors.liveRedLight;
      statusFg = AppColors.liveRedDark;
    }

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
          CircleAvatar(radius: 22, backgroundImage: NetworkImage(p.avatarUrl)),
          const SizedBox(width: 14),

          // Player Name & Rank
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        p.username,
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: statusBg, borderRadius: AppRadii.badge),
                      child: Text(
                        p.status.toUpperCase(),
                        style: AppTypography.captionBold.copyWith(fontSize: 9.5, color: statusFg),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Rank: ${p.rank} • ID: ${p.id}',
                  style: AppTypography.bodySmall.copyWith(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Total Battles & Win/Loss
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${p.totalBattles} Total Battles',
                  style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                Text(
                  'Wins: ${p.wins} • Losses: ${p.losses}',
                  style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Win Rate Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: const BoxDecoration(color: AppColors.brandPurpleLight, borderRadius: AppRadii.badge),
            child: Text(
              '${p.winRate}% Win Rate',
              style: AppTypography.captionBold.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.battleAdminPurple,
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Coin Balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${p.coins} Coins',
                style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.coinGold),
              ),
              Text(
                'Wallet Balance',
                style: AppTypography.labelSmall.copyWith(fontSize: 10.5, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Moderation Actions Popup
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
            shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
            onSelected: (val) {
              if (val == 'restrict') {
                AppModalDialog.show(
                  context: context,
                  builder: (_) => ConfirmActionDialog(
                    title: 'Restrict Battle Access: ${p.username}?',
                    description: 'Temporarily prevent this user from entering battles for 24 hours.',
                    confirmLabel: 'Restrict for 24h',
                    isDestructive: false,
                    onConfirm: (reason) async {
                      _service.restrictPlayer(p.id, 24, reason);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${p.username} restricted for 24 hours'), backgroundColor: AppColors.warning),
                      );
                    },
                  ),
                );
              } else if (val == 'suspend') {
                AppModalDialog.show(
                  context: context,
                  builder: (_) => ConfirmActionDialog(
                    title: 'Suspend Account: ${p.username}?',
                    description: 'This will lock the account and bar all quiz participation until manually reviewed.',
                    confirmLabel: 'Suspend Account',
                    isDestructive: true,
                    onConfirm: (reason) async {
                      _service.suspendPlayer(p.id, true, reason);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${p.username} suspended!'), backgroundColor: AppColors.liveRed),
                      );
                    },
                  ),
                );
              } else if (val == 'unsuspend') {
                _service.suspendPlayer(p.id, false, 'Admin restored');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${p.username} account restored to active'), backgroundColor: AppColors.brandGreen),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'restrict',
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text('Restrict 24h', style: AppTypography.labelSmall),
                  ],
                ),
              ),
              if (p.status == 'suspended')
                PopupMenuItem(
                  value: 'unsuspend',
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.brandGreen),
                      const SizedBox(width: 8),
                      Text('Unsuspend Player', style: AppTypography.labelSmall.copyWith(color: AppColors.brandGreenDark)),
                    ],
                  ),
                )
              else
                PopupMenuItem(
                  value: 'suspend',
                  child: Row(
                    children: [
                      const Icon(Icons.block_rounded, size: 16, color: AppColors.liveRed),
                      const SizedBox(width: 8),
                      Text('Suspend Account', style: AppTypography.labelSmall.copyWith(color: AppColors.liveRed)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
