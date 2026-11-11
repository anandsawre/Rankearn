import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/battle_dashboard_models.dart';
import '../services/battle_dashboard_service.dart';

class CreateBattleDialog extends StatefulWidget {
  const CreateBattleDialog({super.key});

  @override
  State<CreateBattleDialog> createState() => _CreateBattleDialogState();
}

class _CreateBattleDialogState extends State<CreateBattleDialog> {
  final _service = BattleDashboardService();
  String? _creatorId;
  String _opponentId = '';
  int _entryFee = 20;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final activePlayers = _service.players
        .where((p) => p.status.toLowerCase() == 'active')
        .toList();
    if (activePlayers.isNotEmpty) {
      _creatorId = activePlayers.first.id;
    }
  }

  int get _estimatedPrize =>
      (_entryFee * _service.settings.prizeMultiplier).round();

  Future<void> _handleCreate() async {
    final creatorId = _creatorId;
    if (creatorId == null || creatorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select an active creator profile to create a battle.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_opponentId.isNotEmpty && _opponentId == creatorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Creator and opponent must be different players.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _service.createOneVOneBattle(
        creatorId: creatorId,
        opponentId: _opponentId.isEmpty ? null : _opponentId,
        entryFee: _entryFee,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _opponentId.isEmpty
                ? '1v1 Battle queued in Supabase!'
                : '1v1 Battle launched as Live in Supabase!',
          ),
          backgroundColor: AppColors.brandGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create battle: $e'),
          backgroundColor: AppColors.liveRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePlayers = _service.players
        .where((p) => p.status.toLowerCase() == 'active')
        .toList();

    final opponentChoices = <AppDropdownItem<String>>[
      const AppDropdownItem(value: '', label: 'Open Queue (Waiting for Opponent)'),
      ...activePlayers
          .where((p) => p.id != _creatorId)
          .map(
            (p) => AppDropdownItem(
              value: p.id,
              label: '${p.username} (${p.coins} Coins)',
            ),
          ),
    ];

    final effectiveOpponent =
        opponentChoices.any((i) => i.value == _opponentId) ? _opponentId : '';

    return AppModalDialog(
      title: 'Create 1 vs 1 Live Battle',
      subtitle: 'Inserts a verified 1v1 match record into Supabase public.battles',
      iconData: Icons.flash_on_rounded,
      gradientColors: const [
        AppColors.battleAdminPurple,
        AppColors.battleAdminPurpleSecondary,
      ],
      maxWidth: 560,
      scrollable: true,
      actions: [
        OutlinedButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 40),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: (_isSubmitting || activePlayers.isEmpty) ? null : _handleCreate,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 40),
            backgroundColor: AppColors.battleAdminPurple,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'Create Battle',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                ),
        ),
      ],
      child: activePlayers.isEmpty
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: AppRadii.borderMd,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _service.hasDbConnection
                          ? 'No active player profiles found in public.profiles. Ensure at least one active user exists before creating a battle.'
                          : 'Database connection is offline. Connect to Supabase to select players and create battles.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live schema note
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.brandPurpleLight,
                    borderRadius: AppRadii.borderSm,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.quiz_outlined,
                        size: 16,
                        color: AppColors.battleAdminPurple,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Question Bank synced: ${_service.battleQuestionsCount} battle questions across ${_service.questionTopicCounts.length} topic(s)',
                          style: AppTypography.captionBold.copyWith(
                            color: AppColors.battleAdminPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Creator Player
                const Text(
                  'Creator Player',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 42,
                  child: AppDropdown<String>(
                    height: 42,
                    value: _creatorId ?? activePlayers.first.id,
                    items: activePlayers
                        .map(
                          (PlayerBattleRecord p) => AppDropdownItem<String>(
                            value: p.id,
                            label: '${p.username} (${p.coins} Coins)',
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _creatorId = v;
                          if (_opponentId == v) _opponentId = '';
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Opponent Player (Optional)
                const Text(
                  'Opponent Player (Optional)',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 42,
                  child: AppDropdown<String>(
                    height: 42,
                    value: effectiveOpponent,
                    items: opponentChoices,
                    onChanged: (v) {
                      if (v != null) setState(() => _opponentId = v);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Entry Fee & Prize Preview
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Entry Fee (Coins)',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 42,
                            child: AppDropdown<int>(
                              height: 42,
                              value: _entryFee,
                              items: const [
                                AppDropdownItem(value: 10, label: '10 Coins'),
                                AppDropdownItem(value: 20, label: '20 Coins'),
                                AppDropdownItem(value: 50, label: '50 Coins'),
                                AppDropdownItem(value: 100, label: '100 Coins'),
                                AppDropdownItem(value: 250, label: '250 Coins'),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _entryFee = v);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Winner Prize (${_service.settings.prizeMultiplier.toStringAsFixed(1)}x)',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: AppColors.brandGreenLight,
                              borderRadius: AppRadii.borderSm,
                              border: Border.all(color: AppColors.brandGreenMuted),
                            ),
                            child: Text(
                              '$_estimatedPrize Coins',
                              style: AppTypography.labelMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.brandGreenDark,
                              ),
                            ),
                          ),
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
