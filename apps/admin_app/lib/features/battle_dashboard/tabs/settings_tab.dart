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

        if (isTwoCol) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: col1),
              const SizedBox(width: 20),
              Expanded(child: col2),
            ],
          );
        }

        return Column(
          children: [
            col1,
            const SizedBox(height: 16),
            col2,
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
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Bot Fallback Mode',
                style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              subtitle: Text(
                'Pair against simulated AI bot if no real user matches within timeout',
                style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
              ),
              value: settings.botFallback,
              activeThumbColor: AppColors.battleAdminPurple,
              onChanged: (v) => onChanged(settings.copyWith(botFallback: v)),
            ),
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
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Battle Arena Maintenance Mode',
                style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.liveRed),
              ),
              subtitle: Text(
                'Temporarily flag new battle creation as paused in config',
                style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
              ),
              value: settings.maintenanceMode,
              activeThumbColor: AppColors.liveRed,
              onChanged: (v) => onChanged(settings.copyWith(maintenanceMode: v)),
            ),
          ),
        ],
      ),
    );
  }
}
