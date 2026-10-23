import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import '../components/buttons/app_button.dart';
import '../components/cards/app_card.dart';
import '../components/inputs/app_text_field.dart';
import '../components/inputs/app_dropdown.dart';
import '../components/display/badge_pill.dart';
import '../components/feedback/app_loading.dart';
import '../components/navigation/app_header.dart';
import '../components/navigation/app_bottom_nav.dart';

/// Rankearn Centralized Design System Interactive Showcase Screen
class DesignSystemShowcase extends StatefulWidget {
  const DesignSystemShowcase({super.key});

  @override
  State<DesignSystemShowcase> createState() => _DesignSystemShowcaseState();
}

class _DesignSystemShowcaseState extends State<DesignSystemShowcase> {
  UserNavTab _activeNavTab = UserNavTab.home;
  bool _isLoadingButton = false;
  final TextEditingController _testController = TextEditingController();
  String? _selectedCategory = 'SSC CGL';

  @override
  void dispose() {
    _testController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        coins: 1450,
        userName: 'Vikram Singh',
        isPro: true,
        unreadNotifications: 3,
        onNotificationTap: () {},
        onProfileTap: () {},
        onCoinsTap: () {},
      ),
      bottomNavigationBar: AppBottomNav(
        currentTab: _activeNavTab,
        onTabSelected: (tab) => setState(() => _activeNavTab = tab),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rankearn Design System', style: AppTypography.displayMedium),
            const SizedBox(height: 4),
            Text('Centralized UI Tokens & Components Showcase', style: AppTypography.bodyMedium),
            const SizedBox(height: 24),

            // --- 1. Colors ---
            _buildSectionTitle('1. Brand & Semantic Color Tokens'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildColorChip('Primary', AppColors.brandPrimary),
                _buildColorChip('Primary Dark', AppColors.brandPrimaryDark),
                _buildColorChip('Primary Light', AppColors.brandPrimaryLight, textColor: AppColors.brandPrimaryDark),
                _buildColorChip('Coin Gold', AppColors.coinGold),
                _buildColorChip('Error Rose', AppColors.errorRose),
                _buildColorChip('Slate Dark', AppColors.surfaceDark),
              ],
            ),
            const SizedBox(height: 28),

            // --- 2. Typography ---
            _buildSectionTitle('2. Typography & Bilingual Devanagari'),
            const AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Display Bold (Heading 1)', style: AppTypography.displayMedium),
                  SizedBox(height: 6),
                  Text('Title Large / Exam Series Title', style: AppTypography.titleLarge),
                  SizedBox(height: 6),
                  Text('Body Regular: Comprehensive mock test series for BPSC & SSC.', style: AppTypography.bodyMedium),
                  SizedBox(height: 8),
                  Text('हिन्दी प्रश्न: मौर्य साम्राज्य के संस्थापक कौन थे? (Hindi Devanagari Parity)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  SizedBox(height: 8),
                  Text('MICRO TAG / STATUS PILL', style: AppTypography.microTag),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // --- 3. Badges & Pills ---
            _buildSectionTitle('3. Badges, Pills & Indicators'),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const AppCoinPill(coins: 250),
                const AppProBadge(),
                AppStatusPill.active(label: 'Active Contest'),
                AppStatusPill.pending(label: 'Pending UTR'),
                AppStatusPill.rejected(label: 'Rejected'),
              ],
            ),
            const SizedBox(height: 28),

            // --- 4. Stat Cards ---
            _buildSectionTitle('4. Stat Cards (Dashboard & Overview)'),
            Row(
              children: [
                Expanded(
                  child: AppStatCard(
                    label: 'Available Coins',
                    value: '1,450',
                    icon: Icons.monetization_on,
                    iconColor: AppColors.coinGold,
                    iconBgColor: AppColors.coinGoldLight,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: AppStatCard(
                    label: 'Tests Attempted',
                    value: '42',
                    icon: Icons.checklist_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // --- 5. Buttons ---
            _buildSectionTitle('5. Buttons & Interactive States'),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                AppButton(
                  label: 'Start Mock Test',
                  leadingIcon: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                  onPressed: () {},
                ),
                AppButton(
                  label: 'Unlock with Coins',
                  variant: AppButtonVariant.outlined,
                  onPressed: () {},
                ),
                AppButton(
                  label: _isLoadingButton ? 'Verifying...' : 'Toggle Loading State',
                  variant: AppButtonVariant.secondary,
                  isLoading: _isLoadingButton,
                  onPressed: () {
                    setState(() => _isLoadingButton = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _isLoadingButton = false);
                    });
                  },
                ),
                AppButton(
                  label: 'Forfeit Match',
                  variant: AppButtonVariant.destructive,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 28),

            // --- 6. Form Fields & Dropdowns ---
            _buildSectionTitle('6. Form Fields & Centralized Dropdown Components'),
            const AppTextField(
              label: 'UTR / Transaction Reference (12 Digits)',
              hintText: 'Enter 12-digit UTR number',
              prefixIcon: Icon(Icons.qr_code, color: AppColors.textMuted, size: 20),
            ),
            const SizedBox(height: 12),
            const AppTextField(
              label: 'Password',
              hintText: '••••••••',
              isPassword: true,
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted, size: 20),
            ),
            const SizedBox(height: 12),
            AppDropdown<String>.simple(
              label: 'Class / Target Examination Goal',
              value: _selectedCategory,
              hint: 'Select target examination',
              prefixIcon: const Icon(Icons.school_outlined, color: AppColors.textSecondary, size: 20),
              items: const ['SSC CGL', 'UPSC Prelims', 'Banking PO', 'Railway RRB', 'Class 10th CBSE', 'Class 12th CBSE'],
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text('Table Filter Component:', style: AppTypography.labelLarge),
                const SizedBox(width: 10),
                AppDropdownFilter<String>(
                  value: _selectedCategory ?? 'SSC CGL',
                  items: const ['SSC CGL', 'UPSC Prelims', 'Banking PO', 'Railway RRB'],
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // --- 7. Loading Spinner ---
            _buildSectionTitle('7. Brand Logo Loader'),
            const AppCard(
              child: AppLogoLoader(fullScreen: false),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(color: AppColors.brandPrimaryDark),
      ),
    );
  }

  Widget _buildColorChip(String label, Color color, {Color textColor = Colors.white}) {
    return Container(
      width: 105,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
            style: TextStyle(color: textColor.withAlpha(200), fontSize: 9),
          ),
        ],
      ),
    );
  }
}
