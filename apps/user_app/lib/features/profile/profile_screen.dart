import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'components/profile_hero_card.dart';
import 'components/profile_stats_grid.dart';
import 'components/profile_streak_banner.dart';
import 'components/profile_shortcuts_grid.dart';
import 'components/profile_premium_banner.dart';
import 'components/profile_settings_list.dart';
import 'components/profile_modals.dart';

/// Rankearn Profile Dashboard Tab
/// Full responsive architecture supporting both Mobile native app experience
/// and Desktop 1200px dashboard experience.
class ProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final void Function(UserProfile updatedProfile) onUpdateProfile;
  final VoidCallback onLogout;
  final VoidCallback onOpenSupport;
  final VoidCallback onOpenFeedback;
  final void Function(UserNavTab tab)? onNavigateToTab;

  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onUpdateProfile,
    required this.onLogout,
    required this.onOpenSupport,
    required this.onOpenFeedback,
    this.onNavigateToTab,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _currentProfile;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile != oldWidget.profile) {
      _currentProfile = widget.profile;
    }
  }

  void _handleProfileUpdate(UserProfile updated) {
    setState(() => _currentProfile = updated);
    widget.onUpdateProfile(updated);
  }

  // ---------------------------------------------------------------------------
  // INTERACTION HANDLERS
  // ---------------------------------------------------------------------------
  void _openEditProfile() {
    ProfileModals.showEditProfile(
      context: context,
      profile: _currentProfile,
      onSave: _handleProfileUpdate,
    );
  }

  void _openAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Change Profile Photo', style: AppTypography.cardHeading),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFF0F766E),
                ),
                title: const Text(
                  'Take a photo from camera',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Camera opened — avatar updated!'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: Color(0xFF2563EB),
                ),
                title: const Text(
                  'Choose from gallery',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gallery photo selected!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.face_rounded,
                  color: Color(0xFF7C3AED),
                ),
                title: const Text(
                  'Use Rankearn 3D Avatar (Default)',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  final updated = _currentProfile.copyWith(profilePhotoUrl: '');
                  _handleProfileUpdate(updated);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openRoleSelector() {
    ProfileModals.showRoleSelector(
      context: context,
      profile: _currentProfile,
      onSave: _handleProfileUpdate,
    );
  }

  void _showRankDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEFF6FF),
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  color: Color(0xFF1D4ED8),
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text('All-India Rank #1256', style: AppTypography.sectionHeading),
              const SizedBox(height: 6),
              Text(
                'Top 5% of all active test aspirants in India. Earn 744 more points to unlock Rank #1000 and enter the Elite League!',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onNavigateToTab?.call(UserNavTab.tests);
                  },
                  child: const Text(
                    'Take Tests to Boost Rank',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStreakDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 42)),
              const SizedBox(height: 10),
              Text(
                '7 Days Active Streak!',
                style: AppTypography.sectionHeading,
              ),
              const SizedBox(height: 6),
              Text(
                'Amazing dedication! You have practiced every day this week. Complete Saturday and Sunday quizzes to claim the Weekly 50-Coin Streak Bonus!',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onNavigateToTab?.call(UserNavTab.tests);
                  },
                  child: const Text(
                    'Practice Today\'s Quiz',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProgress() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Learning Progress',
                    style: AppTypography.sectionHeading,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildMetricTile(
                title: 'Tests Attempted',
                value: '28 Tests',
                icon: Icons.feed_rounded,
                color: const Color(0xFF10B981),
              ),
              _buildMetricTile(
                title: 'Average Accuracy',
                value: '78%',
                icon: Icons.track_changes_rounded,
                color: const Color(0xFFF43F5E),
              ),
              _buildMetricTile(
                title: '1v1 Battle Win Rate',
                value: '64%',
                icon: Icons.sports_kabaddi_rounded,
                color: const Color(0xFF0284C7),
              ),
              _buildMetricTile(
                title: 'Total Study Time',
                value: '34 Hours',
                icon: Icons.timer_rounded,
                color: const Color(0xFF8B5CF6),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAchievements() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final badges = [
          ('Quiz Master', 'Scored 90%+ in 5 consecutive tests', '🏆', true),
          (
            'Streak Champion',
            'Completed 7-day daily learning streak',
            '🔥',
            true,
          ),
          ('1v1 Gladiator', 'Won 10 arena battles against peers', '⚔️', true),
          ('Fast Solver', 'Answered all questions in under 30s', '⚡', true),
          (
            'PRO Gold Member',
            'Active premium subscription tier',
            '👑',
            _currentProfile.isPro,
          ),
        ];

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Achievements & Badges',
                    style: AppTypography.sectionHeading,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...badges.map(
                (b) => ListTile(
                  leading: Text(b.$3, style: AppTypography.displayMedium),
                  title: Text(b.$1, style: AppTypography.titleSmall),
                  subtitle: Text(b.$2, style: AppTypography.metricLabel),
                  trailing: Icon(
                    b.$4
                        ? Icons.check_circle_rounded
                        : Icons.lock_outline_rounded,
                    color: b.$4
                        ? const Color(0xFF10B981)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDownloads() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFECFDF5),
                ),
                child: const Icon(
                  Icons.download_done_rounded,
                  color: Color(0xFF059669),
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Downloaded Tests & Notes',
                style: AppTypography.sectionHeading,
              ),
              const SizedBox(height: 6),
              Text(
                '3 full-length mock tests and 14 quick revision notes available offline.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onNavigateToTab?.call(UserNavTab.tests);
                  },
                  child: const Text(
                    'Open Offline Tests',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWishlist() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFE4E6),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFE11D48),
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Saved Tests (Wishlist)',
                style: AppTypography.sectionHeading,
              ),
              const SizedBox(height: 6),
              Text(
                'You have 5 bookmarked test series saved to practice later.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onNavigateToTab?.call(UserNavTab.tests);
                  },
                  child: const Text(
                    'Browse Saved Tests',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpgradePass() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👑', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 10),
              Text(
                'Upgrade to Rankearn PRO',
                style: AppTypography.sectionHeading,
              ),
              const SizedBox(height: 8),
              Text(
                '• Unlimited Mock Tests & Solution Analytics\n• Free Entry to Weekly Paid Battle Tournaments\n• Gold VIP Crown Badge on Leaderboard\n• Priority 24/7 Expert Doubt Support',
                style: AppTypography.bodyMedium.copyWith(height: 1.6),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final updated = _currentProfile.copyWith(
                      subscriptionStatus: 'premium',
                    );
                    _handleProfileUpdate(updated);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '🎉 Congratulations! You are now a PRO Gold Member!',
                        ),
                        backgroundColor: Color(0xFFF59E0B),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  child: Text(
                    'Activate PRO (5,000 Coins) →',
                    style: AppTypography.buttonText.copyWith(
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: AppTypography.titleSmall)),
          Text(value, style: AppTypography.metricValue),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;
        final hPadding = isDesktop ? 24.0 : 16.0;

        if (isDesktop) {
          // Desktop: 2-Column Dashboard Layout
          // Left: Hero Section, Statistics, Streak, Shortcuts, Premium
          // Right: Account & Settings, Legal & About, Logout
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN (Starts with Hero Section)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Profile Hero Card (Iridescent mesh gradient + Student Avatar + Rank Card)
                      ProfileHeroCard(
                        profile: _currentProfile,
                        onEditProfile: _openEditProfile,
                        onChangeAvatar: _openAvatarPicker,
                        onSelectRole: _openRoleSelector,
                        onRankTap: _showRankDetails,
                        isDesktop: true,
                      ),
                      const SizedBox(height: 16),

                      // 2. Statistics Grid (Coins, Tests, Average Score, Badges)
                      ProfileStatsGrid(
                        coins: _currentProfile.coins,
                        testsAttempted: 28,
                        averageScore: 78,
                        badgesEarned: _currentProfile.badges.isNotEmpty
                            ? _currentProfile.badges.length
                            : 12,
                        onCoinsTap: () =>
                            widget.onNavigateToTab?.call(UserNavTab.wallet),
                        onTestsTap: () =>
                            widget.onNavigateToTab?.call(UserNavTab.tests),
                        onScoreTap: _showProgress,
                        onBadgesTap: _showAchievements,
                        isDesktop: true,
                      ),
                      const SizedBox(height: 16),

                      // 3. Daily Streak Banner (Deep Navy + Flame + Weekday Indicators)
                      ProfileStreakBanner(
                        streakDays: 7,
                        completedDays: 5,
                        onTap: _showStreakDetails,
                      ),
                      const SizedBox(height: 16),

                      // 4. Six Shortcut Cards (Edit, Progress, Achievements, History, Downloads, Wishlist)
                      ProfileShortcutsGrid(
                        onEditProfile: _openEditProfile,
                        onMyProgress: _showProgress,
                        onMyAchievements: _showAchievements,
                        onTestHistory: () =>
                            widget.onNavigateToTab?.call(UserNavTab.tests),
                        onDownloads: _showDownloads,
                        onMyWishlist: _showWishlist,
                        isDesktop: true,
                      ),
                      const SizedBox(height: 16),

                      // 5. Premium Upgrade Banner (Soft Gold Gradient + Crown Illustration)
                      ProfilePremiumBanner(
                        isPro: _currentProfile.isPro,
                        onUpgrade: _showUpgradePass,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // RIGHT COLUMN (Directly to the right of Hero Section)
                SizedBox(
                  width: constraints.maxWidth > 1250 ? 440 : 380,
                  child: ProfileSettingsList(
                    onPersonalInformation: _openEditProfile,
                    onNotificationSettings: () =>
                        ProfileModals.showNotificationSettings(
                          context: context,
                        ),
                    onAppSettings: () =>
                        ProfileModals.showAppSettings(context: context),
                    onHelpSupport: widget.onOpenSupport,
                    onInviteFriends: () => ProfileModals.showInviteFriends(
                      context: context,
                      referralCode: _currentProfile.referralCode ?? 'RANK100',
                    ),
                    onTermsConditions: () => ProfileModals.showInfoModal(
                      context: context,
                      title: 'Terms & Conditions',
                      content:
                          'Welcome to Rankearn. By accessing our platform, test series, 1v1 battle arena, and coin rewards, you agree to abide by our code of conduct, fair-play policies, and academic integrity standards.',
                    ),
                    onPrivacyPolicy: () => ProfileModals.showInfoModal(
                      context: context,
                      title: 'Privacy Policy',
                      content:
                          'Rankearn is committed to safeguarding your privacy. Your personal information, phone number, and performance statistics are encrypted and securely stored. We never sell your personal data to third parties.',
                    ),
                    onAboutRankearn: () => ProfileModals.showInfoModal(
                      context: context,
                      title: 'About Rankearn',
                      content:
                          'Rankearn is India\'s premier competitive learning platform where students learn, practice with high-yield test series, and earn rewards for academic excellence.',
                    ),
                    onLogout: widget.onLogout,
                    appVersion: 'v1.0.0',
                    isDesktop: true,
                    isSidebar: true,
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile / Tablet: Stack vertically
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Profile Hero Card (Iridescent mesh gradient + Student Avatar + Rank Card)
              ProfileHeroCard(
                profile: _currentProfile,
                onEditProfile: _openEditProfile,
                onChangeAvatar: _openAvatarPicker,
                onSelectRole: _openRoleSelector,
                onRankTap: _showRankDetails,
                isDesktop: false,
              ),
              const SizedBox(height: 16),

              // 2. Statistics Grid (Coins, Tests, Average Score, Badges)
              ProfileStatsGrid(
                coins: _currentProfile.coins,
                testsAttempted: 28,
                averageScore: 78,
                badgesEarned: _currentProfile.badges.isNotEmpty
                    ? _currentProfile.badges.length
                    : 12,
                onCoinsTap: () =>
                    widget.onNavigateToTab?.call(UserNavTab.wallet),
                onTestsTap: () =>
                    widget.onNavigateToTab?.call(UserNavTab.tests),
                onScoreTap: _showProgress,
                onBadgesTap: _showAchievements,
                isDesktop: false,
              ),
              const SizedBox(height: 16),

              // 3. Daily Streak Banner (Deep Navy + Flame + Weekday Indicators)
              ProfileStreakBanner(
                streakDays: 7,
                completedDays: 5,
                onTap: _showStreakDetails,
              ),
              const SizedBox(height: 16),

              // 4. Six Shortcut Cards (Edit, Progress, Achievements, History, Downloads, Wishlist)
              ProfileShortcutsGrid(
                onEditProfile: _openEditProfile,
                onMyProgress: _showProgress,
                onMyAchievements: _showAchievements,
                onTestHistory: () =>
                    widget.onNavigateToTab?.call(UserNavTab.tests),
                onDownloads: _showDownloads,
                onMyWishlist: _showWishlist,
                isDesktop: false,
              ),
              const SizedBox(height: 16),

              // 5. Premium Upgrade Banner (Soft Gold Gradient + Crown Illustration)
              ProfilePremiumBanner(
                isPro: _currentProfile.isPro,
                onUpgrade: _showUpgradePass,
              ),
              const SizedBox(height: 22),

              // 6. Account & Settings + Legal & About + Pink Logout Button
              ProfileSettingsList(
                onPersonalInformation: _openEditProfile,
                onNotificationSettings: () =>
                    ProfileModals.showNotificationSettings(context: context),
                onAppSettings: () =>
                    ProfileModals.showAppSettings(context: context),
                onHelpSupport: widget.onOpenSupport,
                onInviteFriends: () => ProfileModals.showInviteFriends(
                  context: context,
                  referralCode: _currentProfile.referralCode ?? 'RANK100',
                ),
                onTermsConditions: () => ProfileModals.showInfoModal(
                  context: context,
                  title: 'Terms & Conditions',
                  content:
                      'Welcome to Rankearn. By accessing our platform, test series, 1v1 battle arena, and coin rewards, you agree to abide by our code of conduct, fair-play policies, and academic integrity standards.',
                ),
                onPrivacyPolicy: () => ProfileModals.showInfoModal(
                  context: context,
                  title: 'Privacy Policy',
                  content:
                      'Rankearn is committed to safeguarding your privacy. Your personal information, phone number, and performance statistics are encrypted and securely stored. We never sell your personal data to third parties.',
                ),
                onAboutRankearn: () => ProfileModals.showInfoModal(
                  context: context,
                  title: 'About Rankearn',
                  content:
                      'Rankearn is India\'s premier competitive learning platform where students learn, practice with high-yield test series, and earn rewards for academic excellence.',
                ),
                onLogout: widget.onLogout,
                appVersion: 'v1.0.0',
                isDesktop: false,
                isSidebar: false,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
