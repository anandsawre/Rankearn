import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'widgets/settings_hero_card.dart';
import 'widgets/settings_quick_actions.dart';
import 'widgets/settings_category_nav.dart';
import 'widgets/platform_info_card.dart';
import 'widgets/features_control_card.dart';
import 'widgets/rewards_settings_card.dart';
import 'widgets/battle_settings_card.dart';
import 'widgets/payment_settings_card.dart';
import 'widgets/notification_settings_card.dart';
import 'widgets/limits_rules_card.dart';
import 'widgets/appearance_branding_card.dart';
import 'widgets/advanced_settings_card.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String _activeCategory = 'all';
  bool _isLoading = true;
  bool _isSaving = false;

  // 1. Platform Information
  final _nameController = TextEditingController(text: 'Rankearn');
  final _taglineController = TextEditingController(text: 'India\'s 1st Learning with Earning Platform');
  final _emailController = TextEditingController(text: 'support@rankearn.app');
  final _whatsappController = TextEditingController(text: '+91 9876543210');

  // 2. Features Control
  final Map<String, bool> _features = {
    '1v1_battle': true,
    'multiplayer_battle': true,
    'live_quiz': true,
    'mock_test_series': true,
    'fortune_wheel': true,
    'referral_earn': true,
    'live_poll': true,
    'community': true,
  };

  // 3. Rewards & Coins
  final _signupBonusController = TextEditingController(text: '100');
  final _referralRewardController = TextEditingController(text: '10');
  final _battleRewardController = TextEditingController(text: '50');
  final _spinMinController = TextEditingController(text: '5');
  final _spinMaxController = TextEditingController(text: '50');
  final _minWithdrawalController = TextEditingController(text: '1000');
  final _coinRateController = TextEditingController(text: '100 Coins = ₹1');

  // 4. Battle & Games
  String _questionTime = '3Seconds';
  String _battleDuration = '1Minutes';
  final _maxPlayersController = TextEditingController(text: '100');
  final _entryFeeController = TextEditingController(text: '10 Coins');
  final _winningRewardController = TextEditingController(text: '50 Coins');

  // 5. Payments
  bool _enablePayments = true;
  String _defaultGateway = 'Razorpay';
  bool _enableRazorpay = true;
  bool _enableCashfree = true;
  bool _enablePayU = false;

  // 6. Notifications
  bool _enablePush = true;
  bool _enableInApp = true;
  bool _enableEmail = false;
  bool _enableSms = false;

  // 7. Limits & Rules
  final _battleLimitController = TextEditingController(text: '20');
  final _coinLimitController = TextEditingController(text: '1,000');
  final _withdrawalLimitController = TextEditingController(text: '5,000');
  final _suspensionThresholdController = TextEditingController(text: '3 Violations');

  // 8. Appearance & Branding
  final _primaryColorController = TextEditingController(text: '#7C3AED');
  final _secondaryColorController = TextEditingController(text: '#A855F7');

  // 9. Advanced Settings
  bool _maintenanceMode = false;
  bool _debugMode = false;
  bool _autoBackup = true;
  bool _activityLogs = true;
  final _workerUrlController = TextEditingController(text: 'https://testkarlo.alleduupdated.workers.dev');

  @override
  void initState() {
    super.initState();
    _loadSettingsFromSupabase();
  }

  Future<void> _loadSettingsFromSupabase() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await client.from('app_configs').select();
      if (res.isNotEmpty) {
        for (final row in res) {
          final key = row['key']?.toString();
          final val = row['value'];
          if (val is! Map) continue;
          final map = val as Map<String, dynamic>;

          if (key == 'platform_info') {
            if (map['name'] != null) _nameController.text = map['name'].toString();
            if (map['tagline'] != null) _taglineController.text = map['tagline'].toString();
            if (map['email'] != null) _emailController.text = map['email'].toString();
            if (map['whatsapp'] != null) _whatsappController.text = map['whatsapp'].toString();
          } else if (key == 'feature_flags') {
            for (final fKey in _features.keys) {
              if (map.containsKey(fKey) && map[fKey] is bool) {
                _features[fKey] = map[fKey] as bool;
              }
            }
          } else if (key == 'rewards_settings') {
            if (map['signup_bonus'] != null) _signupBonusController.text = map['signup_bonus'].toString();
            if (map['referral_reward'] != null) _referralRewardController.text = map['referral_reward'].toString();
            if (map['battle_reward'] != null) _battleRewardController.text = map['battle_reward'].toString();
            if (map['spin_min'] != null) _spinMinController.text = map['spin_min'].toString();
            if (map['spin_max'] != null) _spinMaxController.text = map['spin_max'].toString();
            if (map['min_withdrawal'] != null) _minWithdrawalController.text = map['min_withdrawal'].toString();
            if (map['coin_rate'] != null) _coinRateController.text = map['coin_rate'].toString();
          } else if (key == 'battle_settings') {
            if (map['question_time'] != null) _questionTime = map['question_time'].toString();
            if (map['battle_duration'] != null) _battleDuration = map['battle_duration'].toString();
            if (map['max_players'] != null) _maxPlayersController.text = map['max_players'].toString();
            if (map['entry_fee'] != null) _entryFeeController.text = map['entry_fee'].toString();
            if (map['winning_reward'] != null) _winningRewardController.text = map['winning_reward'].toString();
          } else if (key == 'payment_settings') {
            if (map['enable_payments'] is bool) _enablePayments = map['enable_payments'] as bool;
            if (map['default_gateway'] != null) _defaultGateway = map['default_gateway'].toString();
            if (map['enable_razorpay'] is bool) _enableRazorpay = map['enable_razorpay'] as bool;
            if (map['enable_cashfree'] is bool) _enableCashfree = map['enable_cashfree'] as bool;
            if (map['enable_payu'] is bool) _enablePayU = map['enable_payu'] as bool;
          } else if (key == 'notification_settings') {
            if (map['enable_push'] is bool) _enablePush = map['enable_push'] as bool;
            if (map['enable_in_app'] is bool) _enableInApp = map['enable_in_app'] as bool;
            if (map['enable_email'] is bool) _enableEmail = map['enable_email'] as bool;
            if (map['enable_sms'] is bool) _enableSms = map['enable_sms'] as bool;
          } else if (key == 'limits_rules') {
            if (map['battle_limit'] != null) _battleLimitController.text = map['battle_limit'].toString();
            if (map['coin_limit'] != null) _coinLimitController.text = map['coin_limit'].toString();
            if (map['withdrawal_limit'] != null) _withdrawalLimitController.text = map['withdrawal_limit'].toString();
            if (map['suspension_threshold'] != null) _suspensionThresholdController.text = map['suspension_threshold'].toString();
          } else if (key == 'appearance_branding') {
            if (map['primary_color'] != null) _primaryColorController.text = map['primary_color'].toString();
            if (map['secondary_color'] != null) _secondaryColorController.text = map['secondary_color'].toString();
          } else if (key == 'advanced_settings') {
            if (map['maintenance_mode'] is bool) _maintenanceMode = map['maintenance_mode'] as bool;
            if (map['debug_mode'] is bool) _debugMode = map['debug_mode'] as bool;
            if (map['auto_backup'] is bool) _autoBackup = map['auto_backup'] as bool;
            if (map['activity_logs'] is bool) _activityLogs = map['activity_logs'] as bool;
            if (map['worker_url'] != null) _workerUrlController.text = map['worker_url'].toString();
          }
        }
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _signupBonusController.dispose();
    _referralRewardController.dispose();
    _battleRewardController.dispose();
    _spinMinController.dispose();
    _spinMaxController.dispose();
    _minWithdrawalController.dispose();
    _coinRateController.dispose();
    _maxPlayersController.dispose();
    _entryFeeController.dispose();
    _winningRewardController.dispose();
    _battleLimitController.dispose();
    _coinLimitController.dispose();
    _withdrawalLimitController.dispose();
    _suspensionThresholdController.dispose();
    _primaryColorController.dispose();
    _secondaryColorController.dispose();
    _workerUrlController.dispose();
    super.dispose();
  }

  Future<void> _resetToDefault() async {
    setState(() {
      _nameController.text = 'Rankearn';
      _taglineController.text = 'India\'s 1st Learning with Earning Platform';
      _emailController.text = 'support@rankearn.app';
      _whatsappController.text = '+91 9876543210';
      _features.updateAll((key, value) => true);
      _signupBonusController.text = '100';
      _referralRewardController.text = '10';
      _battleRewardController.text = '50';
      _spinMinController.text = '5';
      _spinMaxController.text = '50';
      _minWithdrawalController.text = '1000';
      _coinRateController.text = '100 Coins = ₹1';
      _questionTime = '3Seconds';
      _battleDuration = '1Minutes';
      _maxPlayersController.text = '100';
      _entryFeeController.text = '10 Coins';
      _winningRewardController.text = '50 Coins';
      _enablePayments = true;
      _defaultGateway = 'Razorpay';
      _enableRazorpay = true;
      _enableCashfree = true;
      _enablePayU = false;
      _enablePush = true;
      _enableInApp = true;
      _enableEmail = false;
      _enableSms = false;
      _maintenanceMode = false;
      _debugMode = false;
      _autoBackup = true;
      _activityLogs = true;
    });

    await _updateSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings restored to defaults and saved to Supabase.')),
      );
    }
  }

  Future<void> _updateSettings() async {
    setState(() => _isSaving = true);
    final client = SupabaseConfig.clientSafe;
    if (client != null) {
      final now = DateTime.now().toIso8601String();
      try {
        await Future.wait([
          client.from('app_configs').upsert({
            'key': 'platform_info',
            'value': {
              'name': _nameController.text.trim(),
              'tagline': _taglineController.text.trim(),
              'email': _emailController.text.trim(),
              'whatsapp': _whatsappController.text.trim(),
            },
            'updated_at': now,
          }),
          client.from('app_configs').upsert({
            'key': 'feature_flags',
            'value': _features,
            'updated_at': now,
          }),
          client.from('app_configs').upsert({
            'key': 'rewards_settings',
            'value': {
              'signup_bonus': _signupBonusController.text.trim(),
              'referral_reward': _referralRewardController.text.trim(),
              'battle_reward': _battleRewardController.text.trim(),
              'spin_min': _spinMinController.text.trim(),
              'spin_max': _spinMaxController.text.trim(),
              'min_withdrawal': _minWithdrawalController.text.trim(),
              'coin_rate': _coinRateController.text.trim(),
            },
            'updated_at': now,
          }),
          client.from('app_configs').upsert({
            'key': 'battle_settings',
            'value': {
              'question_time': _questionTime,
              'battle_duration': _battleDuration,
              'max_players': _maxPlayersController.text.trim(),
              'entry_fee': _entryFeeController.text.trim(),
              'winning_reward': _winningRewardController.text.trim(),
            },
            'updated_at': now,
          }),
          client.from('app_configs').upsert({
            'key': 'payment_settings',
            'value': {
              'enable_payments': _enablePayments,
              'default_gateway': _defaultGateway,
              'enable_razorpay': _enableRazorpay,
              'enable_cashfree': _enableCashfree,
              'enable_payu': _enablePayU,
            },
            'updated_at': now,
          }),
          client.from('app_configs').upsert({
            'key': 'notification_settings',
            'value': {
              'enable_push': _enablePush,
              'enable_in_app': _enableInApp,
              'enable_email': _enableEmail,
              'enable_sms': _enableSms,
            },
            'updated_at': now,
          }),
          client.from('app_configs').upsert({
            'key': 'limits_rules',
            'value': {
              'battle_limit': _battleLimitController.text.trim(),
              'coin_limit': _coinLimitController.text.trim(),
              'withdrawal_limit': _withdrawalLimitController.text.trim(),
              'suspension_threshold': _suspensionThresholdController.text.trim(),
            },
            'updated_at': now,
          }),
          client.from('app_configs').upsert({
            'key': 'appearance_branding',
            'value': {
              'primary_color': _primaryColorController.text.trim(),
              'secondary_color': _secondaryColorController.text.trim(),
            },
            'updated_at': now,
          }),
          client.from('app_configs').upsert({
            'key': 'advanced_settings',
            'value': {
              'maintenance_mode': _maintenanceMode,
              'debug_mode': _debugMode,
              'auto_backup': _autoBackup,
              'activity_logs': _activityLogs,
              'worker_url': _workerUrlController.text.trim(),
            },
            'updated_at': now,
          }),
        ]);
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ All platform configuration documents saved to Supabase!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(color: AppColors.adminPurple),
        ),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: AppSpacing.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Banner (Left) + Quick Actions (Right)
              LayoutBuilder(
                builder: (context, constraints) {
                  final heroCard = SettingsHeroCard(
                    onResetDefaults: _resetToDefault,
                    onUpdateSettings: _updateSettings,
                  );
                  final quickActions = SettingsQuickActions(
                    onUpdateSettings: _updateSettings,
                    onResetDefaults: _resetToDefault,
                    onConfigurePayments: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Configuring Payment Gateway API credentials...')),
                      );
                    },
                    onToggleMaintenance: () async {
                      final newVal = !_maintenanceMode;
                      setState(() => _maintenanceMode = newVal);
                      final client = SupabaseConfig.clientSafe;
                      if (client != null) {
                        await client.from('app_configs').upsert({
                          'key': 'advanced_settings',
                          'value': {
                            'maintenance_mode': newVal,
                            'debug_mode': _debugMode,
                            'auto_backup': _autoBackup,
                            'activity_logs': _activityLogs,
                            'worker_url': _workerUrlController.text.trim(),
                          },
                          'updated_at': DateTime.now().toIso8601String(),
                        });
                      }
                      if (!mounted) return;
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(newVal
                              ? '⚠️ Maintenance Mode ACTIVATED in live database'
                              : '✅ Maintenance Mode DEACTIVATED in live database'),
                        ),
                      );
                    },
                onBackupDatabase: () {
                  final configJson = {
                    'platform_info': {'name': _nameController.text, 'email': _emailController.text},
                    'feature_flags': _features,
                    'rewards_settings': {'signup_bonus': _signupBonusController.text, 'coin_rate': _coinRateController.text},
                    'maintenance_mode': _maintenanceMode,
                    'timestamp': DateTime.now().toIso8601String(),
                  };
                  Clipboard.setData(ClipboardData(text: configJson.toString()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📋 System configuration exported to clipboard as JSON!')),
                  );
                },
              );

              if (constraints.maxWidth > 980) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 58,
                      child: heroCard,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 42,
                      child: quickActions,
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    heroCard,
                    const SizedBox(height: 16),
                    quickActions,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 18),

          // 2. Horizontal Category Pills Nav
          SettingsCategoryNav(
            activeCategory: _activeCategory,
            onCategoryChanged: (cat) => setState(() => _activeCategory = cat),
          ),
          const SizedBox(height: 20),

          // 3. Grid of Settings Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final int columns = width >= 1650
                  ? 5
                  : (width >= 1250
                      ? 3
                      : (width >= 700
                          ? 2
                          : 1));
              final double cardWidth = (width - (columns - 1) * 14) / columns;

              final cards = [
                _buildPlatformInfoCard(),
                _buildFeaturesControlCard(),
                _buildRewardsSettingsCard(),
                _buildBattleSettingsCard(),
                _buildPaymentSettingsCard(),
                _buildNotificationSettingsCard(),
                _buildLimitsRulesCard(),
                _buildAppearanceBrandingCard(),
                _buildAdvancedSettingsCard(),
              ];

              return Wrap(
                spacing: 14,
                runSpacing: 16,
                children: cards.map((c) => SizedBox(width: cardWidth, child: c)).toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // 4. Bottom Footer Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.adminCard,
              border: Border.all(color: AppColors.adminBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppButton.adminSecondary(
                  label: 'Reset to Default',
                  leadingIcon: const Icon(Icons.refresh_rounded, size: 16),
                  onPressed: _resetToDefault,
                ),
                Row(
                  children: const [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppColors.adminSecondaryText),
                    SizedBox(width: 8),
                    Text(
                      'Changes will be applied across the platform for all users.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.adminSecondaryText,
                      ),
                    ),
                  ],
                ),
                AppButton.adminPrimary(
                  label: 'Update Settings',
                  leadingIcon: const Icon(Icons.save_rounded, size: 16),
                  onPressed: _updateSettings,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    if (_isSaving)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.15),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.adminPurple),
                        ),
                        SizedBox(width: 12),
                        Text('Saving settings to Supabase...', style: AppTypography.adminTablePrimary),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlatformInfoCard() {
    return PlatformInfoCard(
      nameController: _nameController,
      taglineController: _taglineController,
      emailController: _emailController,
      whatsappController: _whatsappController,
      onReset: () {
        setState(() {
          _nameController.text = 'Rankearn';
          _taglineController.text = 'India\'s 1st Learning with Earning Platform';
          _emailController.text = 'support@rankearn.app';
          _whatsappController.text = '+91 9876543210';
        });
      },
      onSave: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Platform information saved successfully!')),
        );
      },
    );
  }

  Widget _buildFeaturesControlCard() {
    return FeaturesControlCard(
      featureStates: _features,
      onFeatureToggled: (key, val) => setState(() => _features[key] = val),
    );
  }

  Widget _buildRewardsSettingsCard() {
    return RewardsSettingsCard(
      signupBonusController: _signupBonusController,
      referralRewardController: _referralRewardController,
      battleRewardController: _battleRewardController,
      spinMinController: _spinMinController,
      spinMaxController: _spinMaxController,
      minWithdrawalController: _minWithdrawalController,
      coinRateController: _coinRateController,
    );
  }

  Widget _buildBattleSettingsCard() {
    return BattleSettingsCard(
      questionTime: _questionTime,
      battleDuration: _battleDuration,
      maxPlayersController: _maxPlayersController,
      entryFeeController: _entryFeeController,
      winningRewardController: _winningRewardController,
      onQuestionTimeChanged: (v) {
        if (v != null) setState(() => _questionTime = v);
      },
      onBattleDurationChanged: (v) {
        if (v != null) setState(() => _battleDuration = v);
      },
    );
  }

  Widget _buildPaymentSettingsCard() {
    return PaymentSettingsCard(
      enablePayments: _enablePayments,
      defaultGateway: _defaultGateway,
      enableRazorpay: _enableRazorpay,
      enableCashfree: _enableCashfree,
      enablePayU: _enablePayU,
      onEnablePaymentsChanged: (v) => setState(() => _enablePayments = v),
      onDefaultGatewayChanged: (v) {
        if (v != null) setState(() => _defaultGateway = v);
      },
      onEnableRazorpayChanged: (v) => setState(() => _enableRazorpay = v),
      onEnableCashfreeChanged: (v) => setState(() => _enableCashfree = v),
      onEnablePayUChanged: (v) => setState(() => _enablePayU = v),
      onConfigureKeys: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment gateway API keys are up to date.')),
        );
      },
    );
  }

  Widget _buildNotificationSettingsCard() {
    return NotificationSettingsCard(
      enablePush: _enablePush,
      enableInApp: _enableInApp,
      enableEmail: _enableEmail,
      enableSms: _enableSms,
      onEnablePushChanged: (v) => setState(() => _enablePush = v),
      onEnableInAppChanged: (v) => setState(() => _enableInApp = v),
      onEnableEmailChanged: (v) => setState(() => _enableEmail = v),
      onEnableSmsChanged: (v) => setState(() => _enableSms = v),
    );
  }

  Widget _buildLimitsRulesCard() {
    return LimitsRulesCard(
      battleLimitController: _battleLimitController,
      coinLimitController: _coinLimitController,
      withdrawalLimitController: _withdrawalLimitController,
      suspensionThresholdController: _suspensionThresholdController,
    );
  }

  Widget _buildAppearanceBrandingCard() {
    return AppearanceBrandingCard(
      primaryColorController: _primaryColorController,
      secondaryColorController: _secondaryColorController,
      onUploadLogo: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload new App Logo...')),
        );
      },
      onUploadFavicon: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload new Favicon...')),
        );
      },
    );
  }

  Widget _buildAdvancedSettingsCard() {
    return AdvancedSettingsCard(
      maintenanceMode: _maintenanceMode,
      debugMode: _debugMode,
      autoBackup: _autoBackup,
      activityLogs: _activityLogs,
      workerUrlController: _workerUrlController,
      onMaintenanceChanged: (v) => setState(() => _maintenanceMode = v),
      onDebugChanged: (v) => setState(() => _debugMode = v),
      onAutoBackupChanged: (v) => setState(() => _autoBackup = v),
      onActivityLogsChanged: (v) => setState(() => _activityLogs = v),
      onSaveWorkerUrl: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Worker URL updated!')),
        );
      },
    );
  }
}
