import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Account & Settings + Legal & About + Logout Section:
/// - Pure white rounded cards with distinct circular icons and subtitles
/// - Terms, Privacy, Version v1.0.0
/// - Vibrant pink/coral Logout Button with confirmation dialog
/// - Responsive: Stacks on mobile, dual-column on desktop
class ProfileSettingsList extends StatelessWidget {
  final VoidCallback onPersonalInformation;
  final VoidCallback onNotificationSettings;
  final VoidCallback onAppSettings;
  final VoidCallback onHelpSupport;
  final VoidCallback onInviteFriends;
  final VoidCallback onTermsConditions;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onAboutRankearn;
  final VoidCallback onLogout;
  final String appVersion;
  final bool isDesktop;
  final bool isSidebar;

  const ProfileSettingsList({
    super.key,
    required this.onPersonalInformation,
    required this.onNotificationSettings,
    required this.onAppSettings,
    required this.onHelpSupport,
    required this.onInviteFriends,
    required this.onTermsConditions,
    required this.onPrivacyPolicy,
    required this.onAboutRankearn,
    required this.onLogout,
    this.appVersion = 'v1.0.0',
    this.isDesktop = false,
    this.isSidebar = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktop && !isSidebar) {
      // Desktop full-width: 2-column layout (Left: Account & Settings | Right: Legal & About + Logout)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: _buildAccountSettingsSection()),
          const SizedBox(width: 24),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegalAboutSection(),
                const SizedBox(height: 18),
                _buildLogoutButton(context),
              ],
            ),
          ),
        ],
      );
    }

    // Mobile: Vertical stack
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAccountSettingsSection(),
        const SizedBox(height: 20),
        _buildLegalAboutSection(),
        const SizedBox(height: 20),
        _buildLogoutButton(context),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 1: Account & Settings
  // ---------------------------------------------------------------------------
  Widget _buildAccountSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: AppShadows.subtle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header Inside
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.settings_rounded,
                    size: 22,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Account & Settings',
                      style: AppTypography.cardHeading,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            _buildDivider(),
            _buildSettingRow(
              icon: Icons.person_outline_rounded,
              iconColor: const Color(0xFF2563EB),
              iconBg: const Color(0xFFEFF6FF),
              title: 'Personal Information',
              subtitle: 'View and update your profile details',
              onTap: onPersonalInformation,
            ),
            _buildDivider(),
            _buildSettingRow(
              icon: Icons.notifications_none_rounded,
              iconColor: const Color(0xFF0284C7),
              iconBg: const Color(0xFFF0F9FF),
              title: 'Notification Settings',
              subtitle: 'Manage your push notifications',
              onTap: onNotificationSettings,
            ),
            _buildDivider(),
            _buildSettingRow(
              icon: Icons.tune_rounded,
              iconColor: const Color(0xFF4F46E5),
              iconBg: const Color(0xFFEEF2FF),
              title: 'App Settings',
              subtitle: 'Theme, language and other preferences',
              onTap: onAppSettings,
            ),
            _buildDivider(),
            _buildSettingRow(
              icon: Icons.help_outline_rounded,
              iconColor: const Color(0xFF7C3AED),
              iconBg: const Color(0xFFF5F3FF),
              title: 'Help & Support',
              subtitle: 'Get help, contact support or view FAQs',
              onTap: onHelpSupport,
            ),
            _buildDivider(),
            _buildSettingRow(
              icon: Icons.people_outline_rounded,
              iconColor: const Color(0xFF059669),
              iconBg: const Color(0xFFECFDF5),
              title: 'Invite Friends',
              subtitle: 'Share Rankearn and earn free coins',
              onTap: onInviteFriends,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 2: Legal & About
  // ---------------------------------------------------------------------------
  Widget _buildLegalAboutSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: AppShadows.subtle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header Inside
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Legal & About',
                      style: AppTypography.cardHeading,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            _buildDivider(),
            _buildSimpleNavRow(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              onTap: onTermsConditions,
            ),
            _buildDivider(),
            _buildSimpleNavRow(
              icon: Icons.shield_outlined,
              title: 'Privacy Policy',
              onTap: onPrivacyPolicy,
            ),
            _buildDivider(),
            _buildSimpleNavRow(
              icon: Icons.info_outline_rounded,
              title: 'About Rankearn',
              trailingText: appVersion,
              onTap: onAboutRankearn,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 3: Full-width Pink/Coral Logout Button
  // ---------------------------------------------------------------------------
  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('profile_logout_button'),
        onTap: () => _confirmLogout(context),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF4778), // Coral pink from reference
                Color(0xFFF43F5E), // Vibrant rose
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x28FF4778),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_open_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('Logout', style: AppTypography.buttonText),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                color: AppColors.brandPink,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text('Logout', style: AppTypography.titleLarge),
            ],
          ),
          content: Text(
            'Are you sure you want to sign out from your Rankearn account?',
            style: AppTypography.bodyMedium,
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTypography.labelLarge),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                onLogout();
              },
              child: Text('Sign Out', style: AppTypography.buttonText),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Row Builders
  // ---------------------------------------------------------------------------
  Widget _buildSettingRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleSmall),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.supporting),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleNavRow({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 22),
              const SizedBox(width: 14),
              Expanded(child: Text(title, style: AppTypography.titleSmall)),
              if (trailingText != null)
                Text(trailingText, style: AppTypography.supporting)
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderSubtle,
      indent: 64,
    );
  }
}
