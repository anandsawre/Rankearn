import 'dart:convert';
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
import '../payments/dialogs/payment_settings_dialog.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String _activeCategory = 'all';
  bool _isLoading = true;
  bool _isSaving = false;
  String? _togglingFeatureKey;

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
  String _questionTime = '10Seconds';
  String _battleDuration = '2Minutes';
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
  final _coinLimitController = TextEditingController(text: '1000');
  final _withdrawalLimitController = TextEditingController(text: '5000');
  final _suspensionThresholdController = TextEditingController(text: '3 Violations');

  // 8. Appearance & Branding
  final _primaryColorController = TextEditingController(text: '#7C3AED');
  final _secondaryColorController = TextEditingController(text: '#A855F7');
  final _logoUrlController = TextEditingController();
  final _faviconUrlController = TextEditingController();

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

  Future<void> _loadSettingsFromSupabase({bool showFeedback = false}) async {
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
            if (map['question_time'] != null) {
              _questionTime = map['question_time'].toString();
            } else if (map['timePerQuestion'] != null) {
              _questionTime = '${map['timePerQuestion']}Seconds';
            }
            if (map['battle_duration'] != null) _battleDuration = map['battle_duration'].toString();
            if (map['max_players'] != null) _maxPlayersController.text = map['max_players'].toString();
            if (map['entry_fee'] != null) _entryFeeController.text = map['entry_fee'].toString();
            if (map['winning_reward'] != null) _winningRewardController.text = map['winning_reward'].toString();
          } else if (key == 'payment_settings') {
            if (map['enable_payments'] is bool) _enablePayments = map['enable_payments'] as bool;
            if (map['default_gateway'] != null) _defaultGateway = map['default_gateway'].toString();
            if (map['enable_razorpay'] is bool) {
              _enableRazorpay = map['enable_razorpay'] as bool;
            } else if (map['enableRazorpay'] is bool) {
              _enableRazorpay = map['enableRazorpay'] as bool;
            }
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
            if (map['logo_url'] != null) _logoUrlController.text = map['logo_url'].toString();
            if (map['favicon_url'] != null) _faviconUrlController.text = map['favicon_url'].toString();
          } else if (key == 'advanced_settings') {
            if (map['maintenance_mode'] is bool) _maintenanceMode = map['maintenance_mode'] as bool;
            if (map['debug_mode'] is bool) _debugMode = map['debug_mode'] as bool;
            if (map['auto_backup'] is bool) _autoBackup = map['auto_backup'] as bool;
            if (map['activity_logs'] is bool) _activityLogs = map['activity_logs'] as bool;
            if (map['worker_url'] != null) _workerUrlController.text = map['worker_url'].toString();
          }
        }
      }
      if (mounted) {
        setState(() => _isLoading = false);
        if (showFeedback) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔄 Latest configuration synced from Supabase database!'),
              backgroundColor: AppColors.adminSuccess,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (showFeedback) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error loading configuration: $e'),
              backgroundColor: AppColors.adminDanger,
            ),
          );
        }
      }
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
    _logoUrlController.dispose();
    _faviconUrlController.dispose();
    _workerUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveSingleSetting(String key, Map<String, dynamic> data, String friendlyName) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database client not connected'), backgroundColor: AppColors.adminDanger),
      );
      return;
    }

    try {
      // Merge with existing document if present so partial updates do not overwrite other keys
      final existingRes = await client.from('app_configs').select('value').eq('key', key).maybeSingle();
      final existingMap = (existingRes != null && existingRes['value'] is Map)
          ? Map<String, dynamic>.from(existingRes['value'] as Map)
          : <String, dynamic>{};

      existingMap.addAll(data);

      await client.from('app_configs').upsert({
        'key': key,
        'value': existingMap,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $friendlyName saved to Supabase!'),
            backgroundColor: AppColors.adminSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to save $friendlyName: $e'),
            backgroundColor: AppColors.adminDanger,
          ),
        );
      }
    }
  }

  Future<void> _resetToDefault() async {
    final confirmed = await AppModalDialog.confirm(
      context: context,
      title: 'Reset All Settings to Defaults?',
      subtitle: 'System configuration reset',
      message: 'This will overwrite all active system configurations in the database with standard default parameters. Are you sure you want to proceed?',
      confirmLabel: 'Reset to Defaults',
      cancelLabel: 'Cancel',
      isDestructive: true,
      iconData: Icons.restore_rounded,
      gradientColors: const [Color(0xFFD97706), Color(0xFFF59E0B)],
    );

    if (!confirmed) return;

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
      _questionTime = '10Seconds';
      _battleDuration = '2Minutes';
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
      _battleLimitController.text = '20';
      _coinLimitController.text = '1000';
      _withdrawalLimitController.text = '5000';
      _suspensionThresholdController.text = '3 Violations';
      _primaryColorController.text = '#7C3AED';
      _secondaryColorController.text = '#A855F7';
      _logoUrlController.clear();
      _faviconUrlController.clear();
      _maintenanceMode = false;
      _debugMode = false;
      _autoBackup = true;
      _activityLogs = true;
      _workerUrlController.text = 'https://testkarlo.alleduupdated.workers.dev';
    });

    await _updateSettings();
  }

  Future<void> _updateSettings() async {
    setState(() => _isSaving = true);
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Database connection not initialized'),
            backgroundColor: AppColors.adminDanger,
          ),
        );
      }
      return;
    }

    final now = DateTime.now().toUtc().toIso8601String();
    try {
      // 1. Prepare merged payment settings preserving existing UPI/gateway fields
      final paymentRes = await client.from('app_configs').select('value').eq('key', 'payment_settings').maybeSingle();
      final paymentMap = (paymentRes != null && paymentRes['value'] is Map)
          ? Map<String, dynamic>.from(paymentRes['value'] as Map)
          : <String, dynamic>{};

      paymentMap['enable_payments'] = _enablePayments;
      paymentMap['default_gateway'] = _defaultGateway;
      paymentMap['enable_razorpay'] = _enableRazorpay;
      paymentMap['enable_cashfree'] = _enableCashfree;
      paymentMap['enable_payu'] = _enablePayU;

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
          'value': paymentMap,
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
            'logo_url': _logoUrlController.text.trim(),
            'favicon_url': _faviconUrlController.text.trim(),
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

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ All platform configuration documents successfully saved to Supabase!'),
            backgroundColor: AppColors.adminSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving platform configurations: $e'),
            backgroundColor: AppColors.adminDanger,
          ),
        );
      }
    }
  }

  Future<void> _exportDatabaseConfig() async {
    final client = SupabaseConfig.clientSafe;
    Map<String, dynamic> exportData = {};

    try {
      if (client != null) {
        final rows = await client.from('app_configs').select();
        for (final row in rows) {
          final key = row['key']?.toString();
          if (key != null) {
            exportData[key] = row['value'];
          }
        }
      }
    } catch (_) {}

    // If database query is empty, export active in-memory configurations
    if (exportData.isEmpty) {
      exportData = {
        'platform_info': {
          'name': _nameController.text.trim(),
          'tagline': _taglineController.text.trim(),
          'email': _emailController.text.trim(),
          'whatsapp': _whatsappController.text.trim(),
        },
        'feature_flags': _features,
        'rewards_settings': {
          'signup_bonus': _signupBonusController.text.trim(),
          'referral_reward': _referralRewardController.text.trim(),
          'battle_reward': _battleRewardController.text.trim(),
          'spin_min': _spinMinController.text.trim(),
          'spin_max': _spinMaxController.text.trim(),
          'min_withdrawal': _minWithdrawalController.text.trim(),
          'coin_rate': _coinRateController.text.trim(),
        },
        'battle_settings': {
          'question_time': _questionTime,
          'battle_duration': _battleDuration,
          'max_players': _maxPlayersController.text.trim(),
          'entry_fee': _entryFeeController.text.trim(),
          'winning_reward': _winningRewardController.text.trim(),
        },
        'payment_settings': {
          'enable_payments': _enablePayments,
          'default_gateway': _defaultGateway,
          'enable_razorpay': _enableRazorpay,
          'enable_cashfree': _enableCashfree,
          'enable_payu': _enablePayU,
        },
        'notification_settings': {
          'enable_push': _enablePush,
          'enable_in_app': _enableInApp,
          'enable_email': _enableEmail,
          'enable_sms': _enableSms,
        },
        'limits_rules': {
          'battle_limit': _battleLimitController.text.trim(),
          'coin_limit': _coinLimitController.text.trim(),
          'withdrawal_limit': _withdrawalLimitController.text.trim(),
          'suspension_threshold': _suspensionThresholdController.text.trim(),
        },
        'appearance_branding': {
          'primary_color': _primaryColorController.text.trim(),
          'secondary_color': _secondaryColorController.text.trim(),
          'logo_url': _logoUrlController.text.trim(),
          'favicon_url': _faviconUrlController.text.trim(),
        },
        'advanced_settings': {
          'maintenance_mode': _maintenanceMode,
          'debug_mode': _debugMode,
          'auto_backup': _autoBackup,
          'activity_logs': _activityLogs,
          'worker_url': _workerUrlController.text.trim(),
        },
      };
    }

    final fullSnapshot = {
      'metadata': {
        'platform': 'Rankearn',
        'exported_at': DateTime.now().toUtc().toIso8601String(),
        'source': 'Supabase public.app_configs',
        'sections_count': exportData.length,
      },
      'configurations': exportData,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(fullSnapshot);
    await Clipboard.setData(ClipboardData(text: jsonString));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📋 System configuration exported to clipboard (${exportData.length} sections, valid JSON)!'),
          backgroundColor: AppColors.adminSuccess,
        ),
      );
    }
  }

  void _openPaymentSettingsDialog() async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => const PaymentSettingsDialog(),
    );
    if (updated == true && mounted) {
      _loadSettingsFromSupabase();
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
                    onRefresh: () => _loadSettingsFromSupabase(showFeedback: true),
                  );
                  final quickActions = SettingsQuickActions(
                    onUpdateSettings: _updateSettings,
                    onResetDefaults: _resetToDefault,
                    onConfigurePayments: _openPaymentSettingsDialog,
                    onToggleMaintenance: () async {
                      final newVal = !_maintenanceMode;
                      setState(() => _maintenanceMode = newVal);
                      await _saveSingleSetting(
                        'advanced_settings',
                        {
                          'maintenance_mode': newVal,
                          'debug_mode': _debugMode,
                          'auto_backup': _autoBackup,
                          'activity_logs': _activityLogs,
                          'worker_url': _workerUrlController.text.trim(),
                        },
                        newVal ? 'Maintenance Mode (ACTIVATED)' : 'Maintenance Mode (DEACTIVATED)',
                      );
                    },
                    onBackupDatabase: _exportDatabaseConfig,
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
                  final int columns = width >= 1150
                      ? 3
                      : (width >= 720
                          ? 2
                          : 1);

                  final List<Widget> cards;
                  switch (_activeCategory) {
                    case 'platform':
                      cards = [_buildPlatformInfoCard()];
                      break;
                    case 'features':
                      cards = [_buildFeaturesControlCard()];
                      break;
                    case 'rewards':
                      cards = [_buildRewardsSettingsCard()];
                      break;
                    case 'battles':
                      cards = [_buildBattleSettingsCard()];
                      break;
                    case 'payments':
                      cards = [_buildPaymentSettingsCard()];
                      break;
                    case 'notifications':
                      cards = [_buildNotificationSettingsCard()];
                      break;
                    case 'limits':
                      cards = [_buildLimitsRulesCard()];
                      break;
                    case 'appearance':
                      cards = [_buildAppearanceBrandingCard()];
                      break;
                    case 'advanced':
                      cards = [_buildAdvancedSettingsCard()];
                      break;
                    case 'all':
                    default:
                      cards = [
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
                      break;
                  }

                  final List<List<Widget>> cardRows = [];
                  for (int i = 0; i < cards.length; i += columns) {
                    final end = (i + columns < cards.length) ? i + columns : cards.length;
                    cardRows.add(cards.sublist(i, end));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int r = 0; r < cardRows.length; r++) ...[
                        if (r > 0) const SizedBox(height: 16),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (int c = 0; c < cardRows[r].length; c++) ...[
                                if (c > 0) const SizedBox(width: 14),
                                Expanded(child: cardRows[r][c]),
                              ],
                              for (int c = cardRows[r].length; c < columns; c++) ...[
                                const SizedBox(width: 14),
                                const Expanded(child: SizedBox.shrink()),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // 4. Bottom Footer Bar
              LayoutBuilder(
                builder: (context, footerConstraints) {
                  final isNarrow = footerConstraints.maxWidth < 780;
                  if (isNarrow) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.adminCardBackground,
                        borderRadius: AppRadii.adminCard,
                        border: Border.all(color: AppColors.adminBorder),
                        boxShadow: AppShadows.adminCard,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.adminSecondaryText),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Changes will be applied across the platform for all users.',
                                  style: AppTypography.adminTableSecondary.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton.adminSecondary(
                                  label: 'Reset to Default',
                                  leadingIcon: const Icon(Icons.refresh_rounded, size: 16),
                                  onPressed: _resetToDefault,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppButton.adminPrimary(
                                  label: 'Update Settings',
                                  leadingIcon: const Icon(Icons.save_rounded, size: 16),
                                  onPressed: _updateSettings,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.adminCardBackground,
                      borderRadius: AppRadii.adminCard,
                      border: Border.all(color: AppColors.adminBorder),
                      boxShadow: AppShadows.adminCard,
                    ),
                    child: Row(
                      children: [
                        AppButton.adminSecondary(
                          label: 'Reset to Default',
                          leadingIcon: const Icon(Icons.refresh_rounded, size: 16),
                          onPressed: _resetToDefault,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.adminSecondaryText),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Changes will be applied across the platform for all users.',
                                  style: AppTypography.adminTableSecondary.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        AppButton.adminPrimary(
                          label: 'Update Settings',
                          leadingIcon: const Icon(Icons.save_rounded, size: 16),
                          onPressed: _updateSettings,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (_isSaving)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.2),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.adminCardBackground,
                    borderRadius: AppRadii.adminCardInner,
                    border: Border.all(color: AppColors.adminBorder),
                    boxShadow: AppShadows.adminCard,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.adminPurple),
                      ),
                      SizedBox(width: 12),
                      Text('Saving all configurations to Supabase...', style: AppTypography.adminTablePrimary),
                    ],
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
      onSave: () => _saveSingleSetting(
        'platform_info',
        {
          'name': _nameController.text.trim(),
          'tagline': _taglineController.text.trim(),
          'email': _emailController.text.trim(),
          'whatsapp': _whatsappController.text.trim(),
        },
        'Platform Information',
      ),
    );
  }

  Future<void> _handleFeatureToggle(String key, bool val) async {
    setState(() {
      _features[key] = val;
      _togglingFeatureKey = key;
    });

    final featureMeta = FeaturesControlCard.featuresList.firstWhere(
      (f) => f['key'] == key,
      orElse: () => {'label': key},
    );
    final featureName = featureMeta['label']?.toString() ?? key;

    final success = await FeatureFlagsRepository().setFeatureFlag(key, val);

    if (mounted) {
      setState(() {
        _togglingFeatureKey = null;
        if (!success) {
          _features[key] = !val;
        }
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ $featureName is now ${val ? "ENABLED" : "DISABLED"} (synced to live Supabase)'
                : '❌ Failed to update $featureName. Please check connection.',
          ),
          backgroundColor: success ? AppColors.adminSuccess : AppColors.adminDanger,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildFeaturesControlCard() {
    return FeaturesControlCard(
      featureStates: _features,
      togglingKey: _togglingFeatureKey,
      onFeatureToggled: _handleFeatureToggle,
      onSave: () async {
        final success = await FeatureFlagsRepository().setAllFeatureFlags(_features);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? '✅ All App Feature Flags saved to Supabase!'
                    : '❌ Failed to save Feature Flags',
              ),
              backgroundColor: success ? AppColors.adminSuccess : AppColors.adminDanger,
            ),
          );
        }
      },
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
      onSave: () => _saveSingleSetting(
        'rewards_settings',
        {
          'signup_bonus': _signupBonusController.text.trim(),
          'referral_reward': _referralRewardController.text.trim(),
          'battle_reward': _battleRewardController.text.trim(),
          'spin_min': _spinMinController.text.trim(),
          'spin_max': _spinMaxController.text.trim(),
          'min_withdrawal': _minWithdrawalController.text.trim(),
          'coin_rate': _coinRateController.text.trim(),
        },
        'Rewards & Coin Settings',
      ),
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
      onSave: () => _saveSingleSetting(
        'battle_settings',
        {
          'question_time': _questionTime,
          'battle_duration': _battleDuration,
          'max_players': _maxPlayersController.text.trim(),
          'entry_fee': _entryFeeController.text.trim(),
          'winning_reward': _winningRewardController.text.trim(),
        },
        'Battle & Game Settings',
      ),
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
      onConfigureKeys: _openPaymentSettingsDialog,
      onSave: () => _saveSingleSetting(
        'payment_settings',
        {
          'enable_payments': _enablePayments,
          'default_gateway': _defaultGateway,
          'enable_razorpay': _enableRazorpay,
          'enable_cashfree': _enableCashfree,
          'enable_payu': _enablePayU,
        },
        'Payment Settings',
      ),
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
      onSave: () => _saveSingleSetting(
        'notification_settings',
        {
          'enable_push': _enablePush,
          'enable_in_app': _enableInApp,
          'enable_email': _enableEmail,
          'enable_sms': _enableSms,
        },
        'Notification Settings',
      ),
    );
  }

  Widget _buildLimitsRulesCard() {
    return LimitsRulesCard(
      battleLimitController: _battleLimitController,
      coinLimitController: _coinLimitController,
      withdrawalLimitController: _withdrawalLimitController,
      suspensionThresholdController: _suspensionThresholdController,
      onSave: () => _saveSingleSetting(
        'limits_rules',
        {
          'battle_limit': _battleLimitController.text.trim(),
          'coin_limit': _coinLimitController.text.trim(),
          'withdrawal_limit': _withdrawalLimitController.text.trim(),
          'suspension_threshold': _suspensionThresholdController.text.trim(),
        },
        'Limits & Rules',
      ),
    );
  }

  Widget _buildAppearanceBrandingCard() {
    return AppearanceBrandingCard(
      primaryColorController: _primaryColorController,
      secondaryColorController: _secondaryColorController,
      logoUrlController: _logoUrlController,
      faviconUrlController: _faviconUrlController,
      onSave: () => _saveSingleSetting(
        'appearance_branding',
        {
          'primary_color': _primaryColorController.text.trim(),
          'secondary_color': _secondaryColorController.text.trim(),
          'logo_url': _logoUrlController.text.trim(),
          'favicon_url': _faviconUrlController.text.trim(),
        },
        'Appearance & Branding',
      ),
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
      onSaveWorkerUrl: () => _saveSingleSetting(
        'advanced_settings',
        {
          'maintenance_mode': _maintenanceMode,
          'debug_mode': _debugMode,
          'auto_backup': _autoBackup,
          'activity_logs': _activityLogs,
          'worker_url': _workerUrlController.text.trim(),
        },
        'Edge Worker / AI Proxy URL',
      ),
      onSave: () => _saveSingleSetting(
        'advanced_settings',
        {
          'maintenance_mode': _maintenanceMode,
          'debug_mode': _debugMode,
          'auto_backup': _autoBackup,
          'activity_logs': _activityLogs,
          'worker_url': _workerUrlController.text.trim(),
        },
        'Advanced Settings',
      ),
    );
  }
}
