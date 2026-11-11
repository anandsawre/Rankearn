import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/battle_dashboard_models.dart';
import '../services/battle_dashboard_service.dart';
import '../tabs/settings_tab.dart';

class BattleSettingsDialog extends StatefulWidget {
  const BattleSettingsDialog({super.key});

  @override
  State<BattleSettingsDialog> createState() => _BattleSettingsDialogState();
}

class _BattleSettingsDialogState extends State<BattleSettingsDialog> {
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

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      await _service.updateSettings(_settings);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Battle settings saved to Supabase app_configs!'),
          backgroundColor: AppColors.brandGreen,
          duration: Duration(seconds: 2),
        ),
      );
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
    return AppModalDialog(
      title: 'Global Battle System Settings',
      subtitle: 'Tune matchmaking timeout, bot fallback parameters, prize ratios & maintenance state',
      iconData: Icons.settings_outlined,
      gradientColors: const [
        AppColors.battleAdminPurple,
        AppColors.battleAdminPurpleSecondary,
      ],
      maxWidth: 860,
      maxHeight: 680,
      scrollable: true,
      footerLeft: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            fontSize: 11,
            color: _service.hasPersistedSettings
                ? AppColors.brandGreenDark
                : AppColors.warning,
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
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
            minimumSize: const Size(0, 40),
            backgroundColor: AppColors.battleAdminPurple,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
        ),
      ],
      child: BattleSettingsCards(
        settings: _settings,
        onChanged: (next) => setState(() {
          _settings = next;
          _hasUnsavedEdits = true;
        }),
      ),
    );
  }
}

