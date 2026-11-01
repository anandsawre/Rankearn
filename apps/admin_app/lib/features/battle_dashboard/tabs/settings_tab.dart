import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/battle_dashboard_models.dart';
import '../services/battle_dashboard_service.dart';

class BattleSettingsTab extends StatefulWidget {
  const BattleSettingsTab({super.key});

  @override
  State<BattleSettingsTab> createState() => _BattleSettingsTabState();
}

class _BattleSettingsTabState extends State<BattleSettingsTab> {
  final _service = BattleDashboardService();
  late BattleSettingsData _settings;

  @override
  void initState() {
    super.initState();
    _settings = _service.settings;
  }

  void _saveSettings() {
    _service.updateSettings(_settings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Global battle settings saved & broadcasted live!'),
        backgroundColor: AppColors.brandGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER BAR
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Global Battle System Settings',
                    style: AppTypography.headingSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tune matchmaking queue timeout, bot accuracy fallback, prize ratios and anti-cheat constraints',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save_rounded, size: 16),
                label: Text(
                  'Save Settings',
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

          // 2. SETTINGS CARDS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Matchmaking & Bot Engine
              Expanded(
                child: Container(
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
                          Text(
                            'Matchmaking & Bot Engine',
                            style: AppTypography.headingSmall.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Matchmaking Timeout
                      Text(
                        'Matchmaking Search Timeout: ${_settings.matchmakingTimeout}s',
                        style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Slider(
                        value: _settings.matchmakingTimeout.toDouble(),
                        min: 5,
                        max: 30,
                        divisions: 25,
                        activeColor: AppColors.battleAdminPurple,
                        onChanged: (v) => setState(() => _settings = _settings.copyWith(matchmakingTimeout: v.toInt())),
                      ),
                      const SizedBox(height: 12),

                      // Bot Accuracy
                      Text(
                        'Bot Accuracy Target: ${(_settings.botAccuracy * 100).toInt()}%',
                        style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Slider(
                        value: _settings.botAccuracy,
                        min: 0.3,
                        max: 0.95,
                        divisions: 13,
                        activeColor: AppColors.battleAdminPurple,
                        onChanged: (v) => setState(() => _settings = _settings.copyWith(botAccuracy: v)),
                      ),
                      const SizedBox(height: 12),

                      // Bot Fallback Switch
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Bot Fallback Mode',
                          style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        subtitle: Text(
                          'Pair against simulated AI bot if no real user matches within timeout',
                          style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        value: _settings.botFallback,
                        activeThumbColor: AppColors.battleAdminPurple,
                        onChanged: (v) => setState(() => _settings = _settings.copyWith(botFallback: v)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Column 2: Stakes & Anti-cheat
              Expanded(
                child: Container(
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
                          Text(
                            'Economy & Integrity',
                            style: AppTypography.headingSmall.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Prize Multiplier
                      Text(
                        '1v1 Prize Multiplier: ${_settings.prizeMultiplier.toStringAsFixed(1)}x (${(_settings.prizeMultiplier * 100).toInt()}% Return)',
                        style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Slider(
                        value: _settings.prizeMultiplier,
                        min: 1.2,
                        max: 2.0,
                        divisions: 8,
                        activeColor: AppColors.brandGreen,
                        onChanged: (v) => setState(() => _settings = _settings.copyWith(prizeMultiplier: v)),
                      ),
                      const SizedBox(height: 12),

                      // Anti-cheat speed check
                      Text(
                        'Anti-Cheat Minimum Answer Time: ${_settings.speedCheckThreshold}s',
                        style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Slider(
                        value: _settings.speedCheckThreshold,
                        min: 0.5,
                        max: 3.0,
                        divisions: 25,
                        activeColor: AppColors.liveRed,
                        onChanged: (v) => setState(() => _settings = _settings.copyWith(speedCheckThreshold: v)),
                      ),
                      const SizedBox(height: 12),

                      // Maintenance Mode
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Battle Arena Maintenance Mode',
                          style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.liveRed),
                        ),
                        subtitle: Text(
                          'Temporarily pause new battle creation platform-wide',
                          style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        value: _settings.maintenanceMode,
                        activeThumbColor: AppColors.liveRed,
                        onChanged: (v) => setState(() => _settings = _settings.copyWith(maintenanceMode: v)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
