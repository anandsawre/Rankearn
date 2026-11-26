import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/battle_dashboard_models.dart';
import '../services/battle_dashboard_service.dart';

class BattleSettingsTab extends StatefulWidget {
  final bool inDialog;

  const BattleSettingsTab({super.key, this.inDialog = false});

  @override
  State<BattleSettingsTab> createState() => _BattleSettingsTabState();
}

class _BattleSettingsTabState extends State<BattleSettingsTab> {
  final _service = BattleDashboardService();
  late BattleSettingsData _settings;
  bool _hasUnsavedEdits = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _settings = _service.settings;
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (!mounted) return;
    if (!_hasUnsavedEdits) {
      setState(() => _settings = _service.settings);
    } else {
      setState(() {});
    }
  }

  void _updateDraft(BattleSettingsData next) {
    setState(() {
      _settings = next;
      _hasUnsavedEdits = true;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      await _service.updateSettings(_settings);
      if (!mounted) return;
      setState(() => _hasUnsavedEdits = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Battle settings saved to Supabase app_configs!'),
          backgroundColor: AppColors.brandGreen,
          duration: Duration(seconds: 2),
        ),
      );
      if (widget.inDialog) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings: $e'),
          backgroundColor: AppColors.liveRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. HEADER / SYNC STATUS BAR
        Row(
          children: [
            if (!widget.inDialog) ...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Global Battle System Settings',
                            style: AppTypography.headingSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildSyncBadge(),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tune matchmaking queue timeout, bot fallback parameters, prize ratios and maintenance state',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ] else ...[
              _buildSyncBadge(),
              const Spacer(),
            ],
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSettings,
              icon: _isSaving
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_rounded, size: 16),
              label: Text(
                _isSaving ? 'Saving…' : 'Save Settings',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOnPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.battleAdminPurple,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderSm),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 2. SETTINGS CARDS (Responsive 2-col or stacked inside dialogs)
        BattleSettingsCards(
          settings: _settings,
          onChanged: _updateDraft,
        ),
      ],
    );
  }

  Widget _buildSyncBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _service.hasPersistedSettings
            ? AppColors.brandGreenLight
            : AppColors.coinGoldLight,
        borderRadius: AppRadii.badge,
      ),
      child: Text(
        _service.hasPersistedSettings
            ? 'Synced with app_configs'
            : 'Not saved in DB yet',
        style: AppTypography.captionBold.copyWith(
          fontSize: 10.5,
          color: _service.hasPersistedSettings
              ? AppColors.brandGreenDark
              : AppColors.warning,
        ),
      ),
    );
  }
}

/// Reusable settings configuration cards used in both [BattleSettingsTab] and [BattleSettingsDialog].
class BattleSettingsCards extends StatelessWidget {
  final BattleSettingsData settings;
  final ValueChanged<BattleSettingsData> onChanged;

  const BattleSettingsCards({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTwoCol = constraints.maxWidth >= 680;
        final col1 = _buildMatchmakingCard();
        final col2 = _buildEconomyCard();
        final botsCard = _CustomArenaBotsCard(
          settings: settings,
          onChanged: onChanged,
        );

        if (isTwoCol) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: col1),
                  const SizedBox(width: 20),
                  Expanded(child: col2),
                ],
              ),
              const SizedBox(height: 18),
              botsCard,
            ],
          );
        }

        return Column(
          children: [
            col1,
            const SizedBox(height: 16),
            col2,
            const SizedBox(height: 16),
            botsCard,
          ],
        );
      },
    );
  }

  Widget _buildMatchmakingCard() {
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
              const Icon(Icons.smart_toy_outlined, color: AppColors.battleAdminPurple, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Matchmaking & Bot Engine',
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headingSmall.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Matchmaking Search Timeout: ${settings.matchmakingTimeout}s',
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Slider(
            value: settings.matchmakingTimeout.toDouble(),
            min: 5,
            max: 30,
            divisions: 25,
            activeColor: AppColors.battleAdminPurple,
            onChanged: (v) => onChanged(settings.copyWith(matchmakingTimeout: v.toInt())),
          ),
          const SizedBox(height: 12),
          Text(
            'Bot Accuracy Target: ${(settings.botAccuracy * 100).toInt()}%',
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Slider(
            value: settings.botAccuracy,
            min: 0.3,
            max: 0.95,
            divisions: 13,
            activeColor: AppColors.battleAdminPurple,
            onChanged: (v) => onChanged(settings.copyWith(botAccuracy: v)),
          ),
          const SizedBox(height: 12),
          AppSwitchTile(
            title: 'Bot Fallback Mode',
            subtitle: 'Pair against simulated AI bot if no real user matches within timeout',
            value: settings.botFallback,
            variant: AppSwitchVariant.primary,
            contentPadding: EdgeInsets.zero,
            onChanged: (v) => onChanged(settings.copyWith(botFallback: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildEconomyCard() {
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
              const Icon(Icons.security_rounded, color: AppColors.brandGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Economy & Integrity',
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headingSmall.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '1v1 Prize Multiplier: ${settings.prizeMultiplier.toStringAsFixed(1)}x (${(settings.prizeMultiplier * 100).toInt()}% Return)',
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Slider(
            value: settings.prizeMultiplier,
            min: 1.2,
            max: 2.0,
            divisions: 8,
            activeColor: AppColors.brandGreen,
            onChanged: (v) => onChanged(settings.copyWith(prizeMultiplier: v)),
          ),
          const SizedBox(height: 12),
          Text(
            'Anti-Cheat Minimum Answer Time: ${settings.speedCheckThreshold}s',
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Slider(
            value: settings.speedCheckThreshold,
            min: 0.5,
            max: 3.0,
            divisions: 25,
            activeColor: AppColors.liveRed,
            onChanged: (v) => onChanged(settings.copyWith(speedCheckThreshold: v)),
          ),
          const SizedBox(height: 12),
          AppSwitchTile(
            title: 'Battle Arena Maintenance Mode',
            subtitle: 'Temporarily flag new battle creation as paused in config',
            value: settings.maintenanceMode,
            titleColor: AppColors.liveRed,
            activeTrackColor: AppColors.liveRed,
            contentPadding: EdgeInsets.zero,
            onChanged: (v) => onChanged(settings.copyWith(maintenanceMode: v)),
          ),
        ],
      ),
    );
  }
}

class _CustomArenaBotsCard extends StatefulWidget {
  final BattleSettingsData settings;
  final ValueChanged<BattleSettingsData> onChanged;

  const _CustomArenaBotsCard({
    required this.settings,
    required this.onChanged,
  });

  @override
  State<_CustomArenaBotsCard> createState() => _CustomArenaBotsCardState();
}

class _CustomArenaBotsCardState extends State<_CustomArenaBotsCard> {
  final Set<String> _selectedIds = <String>{};

  void _toggleSelectAll(bool? checked) {
    setState(() {
      _selectedIds.clear();
      if (checked == true) {
        _selectedIds.addAll(widget.settings.bots.map((b) => b.id));
      }
    });
  }

  void _bulkSetActive(bool isActive) {
    final updated = widget.settings.bots
        .map((b) => _selectedIds.contains(b.id) ? b.copyWith(isActive: isActive) : b)
        .toList();
    widget.onChanged(widget.settings.copyWith(bots: updated));
  }

  void _bulkDelete() {
    final updated = widget.settings.bots
        .where((b) => !_selectedIds.contains(b.id))
        .toList();
    setState(() => _selectedIds.clear());
    widget.onChanged(widget.settings.copyWith(bots: updated));
  }

  @override
  Widget build(BuildContext context) {
    final bots = widget.settings.bots;
    final allSelected = bots.isNotEmpty && _selectedIds.length == bots.length;

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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (bots.isNotEmpty) ...[
                    Checkbox(
                      value: allSelected,
                      activeColor: AppColors.battleAdminPurple,
                      onChanged: _toggleSelectAll,
                    ),
                    const SizedBox(width: 4),
                  ],
                  const Icon(
                    Icons.precision_manufacturing_outlined,
                    color: AppColors.battleAdminPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Custom Arena Bots (${bots.length})',
                          style: AppTypography.headingSmall.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Edit, enable/disable, or bulk manage bots for Bot Fallback Mode.',
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
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedIds.isNotEmpty) ...[
                      OutlinedButton.icon(
                        onPressed: () => _bulkSetActive(true),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
                        label: const Text('Enable', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brandGreenDark,
                          side: const BorderSide(color: AppColors.brandGreen),
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      OutlinedButton.icon(
                        onPressed: () => _bulkSetActive(false),
                        icon: const Icon(Icons.pause_circle_outline_rounded, size: 14),
                        label: const Text('Disable', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          side: const BorderSide(color: AppColors.warning),
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton.icon(
                        onPressed: _bulkDelete,
                        icon: const Icon(Icons.delete_sweep_rounded, size: 14),
                        label: Text(
                          'Delete (${_selectedIds.length})',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.liveRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    ElevatedButton.icon(
                      onPressed: () => _openBotDialog(context),
                      icon: const Icon(Icons.add_rounded, size: 15),
                      label: const Text(
                        'Add Bot',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.battleAdminPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                        minimumSize: const Size(0, 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (bots.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: AppRadii.button,
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'No custom bots added yet. Click "+ Add Bot" to create bots with custom accuracy, or default "AI Practice Bot" (${(widget.settings.botAccuracy * 100).toInt()}%) will be used.',
                style: AppTypography.bodySmall.copyWith(fontSize: 12, color: AppColors.textSecondary),
              ),
            )
          else
            Column(
              children: bots.asMap().entries.map((entry) {
                final idx = entry.key;
                final bot = entry.value;
                final isSelected = _selectedIds.contains(bot.id);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.battleAdminPurple.withValues(alpha: 0.05)
                        : AppColors.surfaceSubtle,
                    borderRadius: AppRadii.button,
                    border: Border.all(
                      color: isSelected ? AppColors.battleAdminPurple : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        activeColor: AppColors.battleAdminPurple,
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedIds.add(bot.id);
                            } else {
                              _selectedIds.remove(bot.id);
                            }
                          });
                        },
                      ),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.battleAdminPurple.withValues(alpha: 0.14),
                        child: (bot.avatarUrl != null && bot.avatarUrl!.isNotEmpty)
                            ? ClipOval(
                                child: Image.network(
                                  bot.avatarUrl!,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.smart_toy_rounded,
                                    size: 16,
                                    color: AppColors.battleAdminPurple,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.smart_toy_rounded,
                                size: 16,
                                color: AppColors.battleAdminPurple,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    bot.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.labelMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: bot.isActive
                                        ? AppColors.brandGreenLight
                                        : AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    bot.isActive ? 'Enabled' : 'Disabled',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: bot.isActive
                                          ? AppColors.brandGreenDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${bot.rank} • Accuracy: ${(bot.accuracy * 100).round()}%',
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSwitch.small(
                        value: bot.isActive,
                        onChanged: (val) {
                          final updated = List<BattleBotConfig>.from(bots);
                          updated[idx] = bot.copyWith(isActive: val);
                          widget.onChanged(widget.settings.copyWith(bots: updated));
                        },
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: 'Edit Bot',
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.battleAdminPurple),
                        onPressed: () => _openBotDialog(context, existingBot: bot, editIndex: idx),
                      ),
                      IconButton(
                        tooltip: 'Delete Bot',
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.liveRed),
                        onPressed: () {
                          final updated = List<BattleBotConfig>.from(bots)..removeAt(idx);
                          setState(() => _selectedIds.remove(bot.id));
                          widget.onChanged(widget.settings.copyWith(bots: updated));
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _openBotDialog(
    BuildContext context, {
    BattleBotConfig? existingBot,
    int? editIndex,
  }) {
    final isEdit = existingBot != null && editIndex != null;
    final nameCtrl = TextEditingController(text: existingBot?.name ?? '');
    final rankCtrl = TextEditingController(text: existingBot?.rank ?? 'AI Bot');
    final avatarCtrl = TextEditingController(text: existingBot?.avatarUrl ?? '');
    double accuracy = existingBot?.accuracy ?? widget.settings.botAccuracy;
    bool isActive = existingBot?.isActive ?? true;

    AppModalDialog.show(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AppModalDialog(
          title: isEdit ? 'Edit Custom Battle Bot' : 'Add Custom Battle Bot',
          subtitle: 'Configure bot name, profile picture, rank & target accuracy',
          iconData: Icons.smart_toy_outlined,
          gradientColors: const [
            AppColors.battleAdminPurple,
            AppColors.battleAdminPurpleSecondary,
          ],
          maxWidth: 460,
          actions: [
            AppModalDialog.cancelButton(ctx),
            AppModalDialog.primaryButton(
              backgroundColor: AppColors.battleAdminPurple,
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final avatar = avatarCtrl.text.trim();
                final updatedBot = BattleBotConfig(
                  id: existingBot?.id ?? 'bot_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  rank: rankCtrl.text.trim().isNotEmpty ? rankCtrl.text.trim() : 'AI Bot',
                  avatarUrl: avatar.isNotEmpty ? avatar : null,
                  accuracy: accuracy,
                  isActive: isActive,
                );
                final list = List<BattleBotConfig>.from(widget.settings.bots);
                if (isEdit) {
                  list[editIndex] = updatedBot;
                } else {
                  list.add(updatedBot);
                }
                widget.onChanged(widget.settings.copyWith(bots: list));
                Navigator.pop(ctx);
              },
              child: Text(
                isEdit ? 'Save Bot' : 'Add Bot',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.battleAdminPurple.withValues(alpha: 0.14),
                    child: avatarCtrl.text.trim().isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              avatarCtrl.text.trim(),
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.smart_toy_rounded,
                                size: 24,
                                color: AppColors.battleAdminPurple,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.smart_toy_rounded,
                            size: 24,
                            color: AppColors.battleAdminPurple,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppModalDialog.textField(
                      controller: avatarCtrl,
                      hint: 'Profile Picture URL (Optional)',
                      onChanged: (_) => setDialogState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppModalDialog.textField(
                controller: nameCtrl,
                hint: 'Bot Name * (e.g. Alpha Quizzer)',
              ),
              const SizedBox(height: 12),
              AppModalDialog.textField(
                controller: rankCtrl,
                hint: 'Rank / Tag (e.g. Rank #5 or AI Bot)',
              ),
              const SizedBox(height: 14),
              Text(
                'Bot Accuracy Target: ${(accuracy * 100).round()}%',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Slider(
                value: accuracy,
                min: 0.30,
                max: 0.95,
                divisions: 13,
                activeColor: AppColors.battleAdminPurple,
                onChanged: (v) => setDialogState(() => accuracy = v),
              ),
              const SizedBox(height: 6),
              AppSwitchTile(
                title: 'Enable Bot',
                subtitle: 'Allow matchmaking to pick this bot when fallback triggers',
                value: isActive,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setDialogState(() => isActive = v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
