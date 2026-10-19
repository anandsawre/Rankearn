import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: RankearnAdminApp(),
    ),
  );
}

class RankearnAdminApp extends StatelessWidget {
  const RankearnAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rankearn Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AdminAppShell(),
    );
  }
}

class AdminAppShell extends StatefulWidget {
  const AdminAppShell({super.key});

  @override
  State<AdminAppShell> createState() => _AdminAppShellState();
}

class _AdminAppShellState extends State<AdminAppShell> {
  AdminNavTab _activeTab = AdminNavTab.overview;
  bool _isLoggedIn = true;

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return _buildAdminLoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.borderMd,
              ),
              alignment: Alignment.center,
              child: const Text('R', style: TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.w900, fontSize: 20)),
            ),
            const SizedBox(width: 10),
            const Text('Rankearn Admin Portal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: AppRadii.borderPill,
              ),
              child: Text(
                _getTabTitle(_activeTab).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white24,
            child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          AdminSidebar(
            currentTab: _activeTab,
            onTabSelected: (tab) => setState(() => _activeTab = tab),
            onLogout: () => setState(() => _isLoggedIn = false),
          ),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: switch (_activeTab) {
                AdminNavTab.overview => _buildOverviewTab(),
                AdminNavTab.finance => _buildFinanceTab(),
                AdminNavTab.tests => _buildTestsTab(),
                AdminNavTab.users => _buildUsersTab(),
                AdminNavTab.contests => _buildContestsTab(),
                AdminNavTab.aiCreator => _buildAiCreatorTab(),
                AdminNavTab.wheel => _buildWheelConfigTab(),
                AdminNavTab.notifications => _buildNotificationsTab(),
                _ => _buildPlaceholderTab(_getTabTitle(_activeTab)),
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Admin Login Screen ---
  Widget _buildAdminLoginScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AppCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.brandPrimary,
                    ),
                    alignment: Alignment.center,
                    child: const Text('R', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(height: 16),
                  const Text('Rankearn Admin', style: AppTypography.displayMedium),
                  const SizedBox(height: 4),
                  Text('Management Portal Access', style: AppTypography.bodySmall),
                  const SizedBox(height: 24),
                  const AppTextField(
                    label: 'Admin Email',
                    hintText: 'admin@rankearn.com',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 14),
                  const AppTextField(
                    label: 'Password',
                    hintText: '••••••••',
                    isPassword: true,
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Sign In to Portal',
                    width: double.infinity,
                    onPressed: () => setState(() => _isLoggedIn = true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 1. Overview Tab ---
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingDesktop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dashboard Overview', style: AppTypography.displayMedium),
          const SizedBox(height: 4),
          Text('Key performance indicators across all users, tests, and financial activity.', style: AppTypography.bodyMedium),
          const SizedBox(height: 24),

          // Stat Cards Grid
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  label: 'Registered Users',
                  value: '12,480',
                  icon: Icons.people_outline,
                  iconColor: AppColors.infoBlue,
                  iconBgColor: AppColors.infoBlueLight,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppStatCard(
                  label: 'Published Tests',
                  value: '184 Series',
                  icon: Icons.menu_book_outlined,
                  iconColor: AppColors.brandPrimary,
                  iconBgColor: AppColors.brandPrimaryLight,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppStatCard(
                  label: 'Pending Top-ups',
                  value: '8 Requests',
                  icon: Icons.currency_rupee,
                  iconColor: AppColors.coinGold,
                  iconBgColor: AppColors.coinGoldLight,
                  onTap: () => setState(() => _activeTab = AdminNavTab.finance),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Action Cards
          const Text('Administrative Actions', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton(
                label: '+ Create New Test Series',
                onPressed: () => setState(() => _activeTab = AdminNavTab.tests),
              ),
              AppButton(
                label: '⚡ Review Pending UTRs',
                variant: AppButtonVariant.secondary,
                onPressed: () => setState(() => _activeTab = AdminNavTab.finance),
              ),
              AppButton(
                label: '📢 Broadcast Push Alert',
                variant: AppButtonVariant.outlined,
                onPressed: () => setState(() => _activeTab = AdminNavTab.notifications),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. Finance Tab ---
  Widget _buildFinanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingDesktop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Finance & UPI Verification', style: AppTypography.displayMedium),
          const SizedBox(height: 4),
          Text('Review manual UPI payment top-ups and coin withdrawal requests.', style: AppTypography.bodyMedium),
          const SizedBox(height: 24),

          const Text('Pending Top-Up Verification Queue', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          _buildTopupRow('Anjali Kumari', 'anjali@test.com', '₹250.00', '5,000 Coins', 'UTR: 349102847192'),
          _buildTopupRow('Manish Kumar', 'manish@test.com', '₹100.00', '2,000 Coins', 'UTR: 492019385721'),
          _buildTopupRow('Suresh Patil', 'suresh@test.com', '₹500.00', '10,000 Coins', 'UTR: 593019284719'),
        ],
      ),
    );
  }

  Widget _buildTopupRow(String name, String email, String rupee, String coins, String utr) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: AppTypography.titleMedium),
                  const SizedBox(width: 8),
                  AppStatusPill.pending(),
                ],
              ),
              const SizedBox(height: 4),
              Text('$email • $utr', style: AppTypography.bodySmall),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(rupee, style: AppTypography.titleLarge.copyWith(color: AppColors.brandPrimaryDark)),
                  Text(coins, style: AppTypography.bodySmall.copyWith(color: AppColors.coinGold)),
                ],
              ),
              const SizedBox(width: 20),
              AppButton(
                label: 'Approve',
                size: AppButtonSize.small,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Approved $utr! Credited $coins.')),
                  );
                },
              ),
              const SizedBox(width: 8),
              AppButton(
                label: 'Reject',
                variant: AppButtonVariant.destructive,
                size: AppButtonSize.small,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Rejected $utr.')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  // --- 3. Tests Tab ---
  Widget _buildTestsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingDesktop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Test Series Catalog', style: AppTypography.displayMedium),
              AppButton(label: '+ Create Test', onPressed: () {}),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('70th BPSC Prelims Mock 1', style: AppTypography.titleLarge),
                const SizedBox(height: 4),
                Text('150 Questions • 120 Minutes • Negative Marking: 0.25', style: AppTypography.bodySmall),
                const SizedBox(height: 14),
                Row(
                  children: [
                    AppStatusPill.active(label: 'Published'),
                    const Spacer(),
                    AppButton(label: 'Edit Questions (150)', variant: AppButtonVariant.outlined, size: AppButtonSize.small, onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Users Tab ---
  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingDesktop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Directory & Roles', style: AppTypography.displayMedium),
          const SizedBox(height: 16),
          const AppTextField(
            hintText: 'Search user by name, email, or phone...',
            prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vikram Singh (vikram@example.com)', style: AppTypography.titleMedium),
                    SizedBox(height: 2),
                    Text('Role: User • Balance: 1,450 Coins • Status: Active', style: AppTypography.bodySmall),
                  ],
                ),
                Row(
                  children: [
                    AppButton(label: 'Adjust Coins', variant: AppButtonVariant.secondary, size: AppButtonSize.small, onPressed: () {}),
                    const SizedBox(width: 8),
                    AppButton(label: 'Suspend', variant: AppButtonVariant.destructive, size: AppButtonSize.small, onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Contests Tab ---
  Widget _buildContestsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingDesktop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tournaments & Contest Scheduler', style: AppTypography.displayMedium),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SSC CGL Grand Championship 2026', style: AppTypography.titleLarge),
                const SizedBox(height: 4),
                Text('Scheduled: 10:00 AM - 11:00 AM • Entry Fee: 20 Coins • Prize Pool: 5,000 Coins', style: AppTypography.bodySmall),
                const SizedBox(height: 14),
                Row(
                  children: [
                    AppStatusPill.active(label: 'Live Now (48 Participants)'),
                    const Spacer(),
                    AppButton(label: 'Declare Results & Payout', size: AppButtonSize.small, onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. AI Test Creator Tab ---
  Widget _buildAiCreatorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingDesktop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI Test & Question Generator 🤖', style: AppTypography.displayMedium),
          const SizedBox(height: 4),
          Text('Automate syllabus-aligned question generation using Gemini 1.5 Flash.', style: AppTypography.bodyMedium),
          const SizedBox(height: 20),

          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Generate New Test Paper', style: AppTypography.titleLarge),
                const SizedBox(height: 16),
                const AppTextField(
                  label: 'Target Examination',
                  hintText: 'e.g. 70th BPSC Prelims, SSC CGL Tier 1',
                ),
                const SizedBox(height: 14),
                const AppTextField(
                  label: 'Subject / Syllabus Focus',
                  hintText: 'e.g. Ancient & Medieval History of Bihar',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: AppTextField(
                        label: 'Number of Questions',
                        hintText: '25',
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: AppTextField(
                        label: 'Difficulty Level',
                        hintText: 'Moderate (Standard PSC Pattern)',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: '✨ Generate Paper with Gemini AI',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dispatched AI generation request to Edge Function...')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. Lucky Wheel Config Tab ---
  Widget _buildWheelConfigTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingDesktop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lucky Wheel Reward Configuration 🎡', style: AppTypography.displayMedium),
          const SizedBox(height: 4),
          Text('Configure coin payout slices, free spin limits, and drop probability weights.', style: AppTypography.bodyMedium),
          const SizedBox(height: 20),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Active Wheel Slices (8 Sectors)', style: AppTypography.titleLarge),
                const SizedBox(height: 12),
                _buildSliceRow('Sector 1: 50 Coins', 'Probability: 25%', 'Reward: 50 Coins', true),
                _buildSliceRow('Sector 2: Try Again', 'Probability: 30%', 'Reward: 0 Coins', true),
                _buildSliceRow('Sector 3: 100 Coins', 'Probability: 15%', 'Reward: 100 Coins', true),
                _buildSliceRow('Sector 4: 250 Coins (Jackpot)', 'Probability: 5%', 'Reward: 250 Coins', true),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Save Configuration',
                  size: AppButtonSize.small,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Updated Lucky Wheel Configuration.')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliceRow(String name, String prob, String reward, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTypography.titleSmall),
              Text(prob, style: AppTypography.bodySmall),
            ],
          ),
          Text(reward, style: const TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- 8. Push Notifications Tab ---
  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingDesktop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Push Notification Broadcast Console 📢', style: AppTypography.displayMedium),
          const SizedBox(height: 4),
          Text('Send targeted native device notifications via FCM to all or segmented candidate audiences.', style: AppTypography.bodyMedium),
          const SizedBox(height: 20),

          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Broadcast Notification', style: AppTypography.titleLarge),
                const SizedBox(height: 16),
                const AppTextField(
                  label: 'Notification Title',
                  hintText: 'e.g. 70th BPSC Grand League starts in 30 mins! 🏆',
                ),
                const SizedBox(height: 14),
                const AppTextField(
                  label: 'Message Body',
                  hintText: 'Join the contest now to claim your share of the 5,000 Coin prize pool.',
                ),
                const SizedBox(height: 14),
                const AppTextField(
                  label: 'Audience Topic / Segment',
                  hintText: 'all_users (or topic: exam_bpsc)',
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: '🚀 Dispatch Broadcast via FCM',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Push broadcast successfully dispatched via Edge Function!')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, size: 48, color: AppColors.brandPrimary.withAlpha(128)),
          const SizedBox(height: 16),
          Text(title, style: AppTypography.titleLarge),
          const SizedBox(height: 6),
          Text('Admin workspace ready for $title configuration.', style: AppTypography.bodySmall),
        ],
      ),
    );
  }

  String _getTabTitle(AdminNavTab tab) {
    switch (tab) {
      case AdminNavTab.overview:
        return 'Overview';
      case AdminNavTab.tests:
        return 'Test Series';
      case AdminNavTab.users:
        return 'Users';
      case AdminNavTab.patterns:
        return 'Exam Patterns';
      case AdminNavTab.aiCreator:
        return 'AI Test Creator';
      case AdminNavTab.finance:
        return 'Finance';
      case AdminNavTab.contests:
        return 'Contests';
      case AdminNavTab.banners:
        return 'Banners';
      case AdminNavTab.notifications:
        return 'Notifications';
      case AdminNavTab.wheel:
        return 'Lucky Wheel';
      case AdminNavTab.leaderboard:
        return 'Leaderboard';
      case AdminNavTab.referrals:
        return 'Referrals';
      case AdminNavTab.posts:
        return 'Updates';
      case AdminNavTab.support:
        return 'Support Chat';
      case AdminNavTab.feedback:
        return 'Give Feedback';
      case AdminNavTab.battleQs:
        return 'Battle Questions';
      case AdminNavTab.polls:
        return 'Community Polls';
      case AdminNavTab.settings:
        return 'Settings';
    }
  }
}
