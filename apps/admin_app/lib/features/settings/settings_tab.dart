import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  // 1. Worker Settings
  final _workerUrlController = TextEditingController(text: 'https://testkarlo.alleduupdated.workers.dev');

  // 2. Feature Flags
  bool _showSubscriptionTab = true;

  // 3. Rankearn PRO Configuration
  final _proPriceController = TextEditingController(text: '5000');
  final _proDurationController = TextEditingController(text: '30');
  final _proDiscountController = TextEditingController(text: '50');
  bool _isProActive = true;

  // 4. Social Links
  final _whatsappController = TextEditingController(text: 'https://wa.me/919876543210');
  final _telegramController = TextEditingController(text: 'https://t.me/rankearn_official');
  final _youtubeController = TextEditingController(text: 'https://youtube.com/@rankearn');

  // 5. APK URL
  final _apkUrlController = TextEditingController(text: 'https://rankearn.com/downloads/rankearn-latest.apk');

  // 6. Security
  bool _requireEmailVerification = true;

  @override
  void dispose() {
    _workerUrlController.dispose();
    _proPriceController.dispose();
    _proDurationController.dispose();
    _proDiscountController.dispose();
    _whatsappController.dispose();
    _telegramController.dispose();
    _youtubeController.dispose();
    _apkUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Master Header
            _buildMasterHeader(),
            const SizedBox(height: 24),

            // 1. AI Worker Settings
            _buildWorkerSettingsCard(),
            const SizedBox(height: 24),

            // 2. App Feature Flags
            _buildFeatureFlagsCard(),
            const SizedBox(height: 24),

            // 3. Rankearn PRO Subscription Model
            _buildProSettingsCard(),
            const SizedBox(height: 24),

            // 4. Social Media Links
            _buildSocialLinksCard(),
            const SizedBox(height: 24),

            // 5. APK Download Settings
            _buildApkSettingsCard(),
            const SizedBox(height: 24),

            // 6. Security & Authentication
            _buildSecuritySettingsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF64748B),
              borderRadius: AppRadii.borderLg,
              boxShadow: const [
                BoxShadow(color: Color(0x2064748B), blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('System & Platform Settings', style: AppTypography.displayMedium),
              SizedBox(height: 2),
              Text('Configure Global AI Proxy, Pro Membership Economy, APK Links, and Security', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.hub_outlined, color: AppColors.brandPrimary),
              SizedBox(width: 10),
              Text('Cloudflare Worker / Gemini Proxy API', style: AppTypography.titleLarge),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'This URL acts as an edge gateway proxy to Gemini API. The AI Creator dispatches structured prompt payloads to this endpoint.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _workerUrlController,
            label: 'Edge Worker URL',
            hintText: 'https://testkarlo.alleduupdated.workers.dev',
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Save Worker Configuration',
            size: AppButtonSize.small,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('AI Worker URL saved successfully!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureFlagsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.toggle_on_outlined, color: Color(0xFF6366F1)),
              SizedBox(width: 10),
              Text('App Feature Flags', style: AppTypography.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Subscription Tab Visibility', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 2),
                  Text('Show the PRO Subscription tab in candidate mobile navigation.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              Switch(
                value: _showSubscriptionTab,
                activeTrackColor: const Color(0xFF6366F1),
                onChanged: (val) {
                  setState(() => _showSubscriptionTab = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Subscription tab visibility updated to $val.')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.workspace_premium_outlined, color: Color(0xFFF59E0B)),
              SizedBox(width: 10),
              Text('Rankearn PRO Configuration', style: AppTypography.titleLarge),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Configure Coin-based subscription pricing and tournament entry discounts.', style: AppTypography.bodySmall),
          const SizedBox(height: 20),

          Wrap(
            spacing: 20,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 240,
                child: AppTextField(
                  controller: _proPriceController,
                  label: 'Price (in Coins)',
                  hintText: '5000',
                ),
              ),
              SizedBox(
                width: 240,
                child: AppTextField(
                  controller: _proDurationController,
                  label: 'Duration (Days)',
                  hintText: '30',
                ),
              ),
              SizedBox(
                width: 240,
                child: AppTextField(
                  controller: _proDiscountController,
                  label: 'Contest Discount (%)',
                  hintText: '50',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Is PRO Pass Active?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 2),
                  Text('Allow candidates to purchase or upgrade to PRO.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              Switch(
                value: _isProActive,
                activeTrackColor: const Color(0xFFF59E0B),
                onChanged: (val) => setState(() => _isProActive = val),
              ),
            ],
          ),
          const SizedBox(height: 20),

          AppButton(
            label: 'Save PRO Settings',
            size: AppButtonSize.small,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PRO subscription parameters updated successfully!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinksCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.public, color: Color(0xFF2563EB)),
              SizedBox(width: 10),
              Text('Official Social Media Channels', style: AppTypography.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(controller: _whatsappController, label: 'WhatsApp Community Link'),
          const SizedBox(height: 12),
          AppTextField(controller: _telegramController, label: 'Telegram Channel Link'),
          const SizedBox(height: 12),
          AppTextField(controller: _youtubeController, label: 'YouTube Channel Link'),
          const SizedBox(height: 20),
          AppButton(
            label: 'Save Social Channels',
            size: AppButtonSize.small,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Social channels updated successfully.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApkSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.android, color: Color(0xFF059669)),
              SizedBox(width: 10),
              Text('Android APK Distribution', style: AppTypography.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _apkUrlController,
            label: 'Latest Release Direct APK Download URL',
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Save APK URL',
            size: AppButtonSize.small,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('APK download link updated.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.shield_outlined, color: Color(0xFFEF4444)),
              SizedBox(width: 10),
              Text('Security & Authentication Policy', style: AppTypography.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Mandatory Email Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 2),
                  Text('Require email link verification before accessing live tests and wallet.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              Switch(
                value: _requireEmailVerification,
                activeTrackColor: const Color(0xFFEF4444),
                onChanged: (val) {
                  setState(() => _requireEmailVerification = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email verification requirement set to $val.')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
