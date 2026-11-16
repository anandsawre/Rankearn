import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
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

  void _resetToDefault() {
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings reset to platform defaults.')),
    );
  }

  void _updateSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System configuration and platform settings updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                onToggleMaintenance: () {
                  setState(() => _maintenanceMode = !_maintenanceMode);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_maintenanceMode
                          ? 'Maintenance Mode activated'
                          : 'Maintenance Mode deactivated'),
                    ),
                  );
                },
                onBackupDatabase: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starting full platform backup export...')),
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
