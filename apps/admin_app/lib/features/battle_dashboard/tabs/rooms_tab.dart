import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import '../models/battle_dashboard_models.dart';
import '../services/battle_dashboard_service.dart';
import '../dialogs/create_room_dialog.dart';
import '../dialogs/confirm_action_dialog.dart';

class BattleRoomsTab extends StatefulWidget {
  const BattleRoomsTab({super.key});

  @override
  State<BattleRoomsTab> createState() => _BattleRoomsTabState();
}

class _BattleRoomsTabState extends State<BattleRoomsTab> {
  final _service = BattleDashboardService();
  String _search = '';
  String _filter = 'All'; // 'All', 'Live', 'Waiting'

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
    final allRooms = _service.ongoingRooms;
    final liveRooms = allRooms.where((r) => r.status == BattleStatus.live).length;
    final waitingRooms = allRooms.where((r) => r.status == BattleStatus.waiting).length;
    final totalPlayersInRooms = allRooms.fold<int>(0, (sum, r) => sum + r.currentPlayers);
    final totalStakesInRooms = allRooms.fold<int>(0, (sum, r) => sum + r.prizePool);

    final filtered = allRooms.where((r) {
      if (_filter == 'Live' && r.status != BattleStatus.live) return false;
      if (_filter == 'Waiting' && r.status != BattleStatus.waiting) return false;

      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final matchName = r.name.toLowerCase().contains(q);
        final matchCode = r.code.toLowerCase().contains(q);
        final matchSubject = r.subject.toLowerCase().contains(q);
        if (!matchName && !matchCode && !matchSubject) return false;
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
                    title: 'Active Rooms',
                    value: '${allRooms.length}',
                    subtitle: '$liveRooms rooms currently in-match',
                    icon: Icons.storefront_rounded,
                    color: AppColors.battleAdminPurple,
                    bg: AppColors.brandPurpleLight,
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Players in Rooms',
                    value: '$totalPlayersInRooms',
                    subtitle: 'Participants competing live',
                    icon: Icons.groups_rounded,
                    color: AppColors.brandBlue,
                    bg: AppColors.brandBlueLight,
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Total Prize Pools',
                    value: '$totalStakesInRooms',
                    subtitle: 'Combined coin stakes',
                    icon: Icons.monetization_on_rounded,
                    color: AppColors.coinGold,
                    bg: AppColors.coinGoldLight,
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Waiting for Players',
                    value: '$waitingRooms',
                    subtitle: 'Rooms awaiting min threshold',
                    icon: Icons.hourglass_empty_rounded,
                    color: AppColors.brandGreen,
                    bg: AppColors.brandGreenLight,
                    width: cardWidth,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // 2. HEADER BAR (Title, Search, Create Room Button)
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Custom Room Management',
                    style: AppTypography.headingSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Inspect active public and private custom rooms, participant thresholds and room lifecycle',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              // Search Input
              SizedBox(
                width: 240,
                child: TextField(
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search Room / Code...',
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
                  AppModalDialog.show(context: context, builder: (_) => const CreateRoomDialog());
                },
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(
                  '+ Create Room',
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
              _buildFilterPill('All Rooms', allRooms.length),
              const SizedBox(width: 8),
              _buildFilterPill('Live', liveRooms),
              const SizedBox(width: 8),
              _buildFilterPill('Waiting', waitingRooms),
            ],
          ),
          const SizedBox(height: 18),

          // 4. ROOM CARDS LIST
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
                  const Icon(Icons.meeting_room_outlined, size: 40, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    'No rooms found matching filter.',
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
                final r = filtered[index];
                return _buildRoomTile(r);
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
    final isSelected = _filter == title || (_filter == 'All' && title == 'All Rooms');
    return InkWell(
      onTap: () => setState(() => _filter = title == 'All Rooms' ? 'All' : title),
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

  Widget _buildRoomTile(OngoingRoomItem r) {
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.brandBlueLight,
              borderRadius: AppRadii.borderMd,
            ),
            child: const Icon(Icons.meeting_room_rounded, color: AppColors.brandBlue, size: 24),
          ),
          const SizedBox(width: 16),

          // Name & Code
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        r.name,
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: r.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Room code ${r.code} copied!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      borderRadius: AppRadii.badge,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: const BoxDecoration(
                          color: AppColors.brandPurpleLight,
                          borderRadius: AppRadii.badge,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              r.code,
                              style: AppTypography.captionBold.copyWith(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.battleAdminPurple,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(Icons.copy_rounded, size: 10, color: AppColors.battleAdminPurple),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Subject: ${r.subject} • Host: Admin',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Capacity Progress
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Occupancy: ${r.currentPlayers} / ${r.maxPlayers}',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: AppRadii.borderSm,
                  child: LinearProgressIndicator(
                    value: r.currentPlayers / r.maxPlayers,
                    backgroundColor: AppColors.surfaceSubtle,
                    color: AppColors.brandBlue,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Stakes
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fee: ${r.entryFee} Coins',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Prize: ${r.prizePool} Coins',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.brandGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: r.status == BattleStatus.live
                  ? AppColors.liveRedLight
                  : AppColors.surfaceSubtle,
              borderRadius: AppRadii.badge,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: r.status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  r.status.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: r.status.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Actions
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.liveRed, size: 20),
            tooltip: 'Clear & Close Room',
            onPressed: () {
              AppModalDialog.show(
                context: context,
                builder: (_) => ConfirmActionDialog(
                  title: 'Clear Room "${r.name}" (${r.code})?',
                  description: 'This will eject all participants, close the room, and log the action in audit records.',
                  confirmLabel: 'Clear Room',
                  isDestructive: true,
                  onConfirm: (reason) async {
                    _service.clearAllRooms(reason);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
