import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

import 'features/overview/overview_tab.dart';
import 'features/finance/finance_tab.dart';
import 'features/tests/tests_tab.dart';
import 'features/users/users_tab.dart';
import 'features/patterns/patterns_tab.dart';
import 'features/ai_creator/ai_creator_tab.dart';
import 'features/contests/contests_tab.dart';
import 'features/banners/banners_tab.dart';
import 'features/notifications/notifications_tab.dart';
import 'features/wheel/wheel_tab.dart';
import 'features/leaderboard/leaderboard_tab.dart';
import 'features/referrals/referrals_tab.dart';
import 'features/posts/posts_tab.dart';
import 'features/support/support_tab.dart';
import 'features/feedback/feedback_tab.dart';
import 'features/battle_qs/battle_qs_tab.dart';
import 'features/polls/polls_tab.dart';
import 'features/settings/settings_tab.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Supabase initialization: $e');
  }

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
      title: 'Rankearn Admin Portal',
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

  void _navigateToTab(AdminNavTab tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return _buildAdminLoginScreen();
    }

    final isNarrow = MediaQuery.of(context).size.width < 960;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      // Mobile Drawer if screen is narrow
      drawer: isNarrow
          ? Drawer(
              child: SafeArea(
                child: AdminSidebar(
                  currentTab: _activeTab,
                  onTabSelected: _navigateToTab,
                  onLogout: () => setState(() => _isLoggedIn = false),
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          // 1. Fixed Top Header Bar matching App.tsx:242-303
          _buildTopHeaderBar(context, isNarrow),

          // 2. Main Content Area + Desktop Sidebar
          Expanded(
            child: Row(
              children: [
                if (!isNarrow)
                  AdminSidebar(
                    currentTab: _activeTab,
                    onTabSelected: _navigateToTab,
                    onLogout: () => setState(() => _isLoggedIn = false),
                  ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8FAF9),
                    child: switch (_activeTab) {
                      AdminNavTab.overview => OverviewTab(
                          onGoToTests: () => setState(() => _activeTab = AdminNavTab.tests),
                          onGoToFinance: () => setState(() => _activeTab = AdminNavTab.finance),
                          onGoToUsers: () => setState(() => _activeTab = AdminNavTab.users),
                          onGoToAiCreator: () => setState(() => _activeTab = AdminNavTab.aiCreator),
                          onGoToNotifications: () => setState(() => _activeTab = AdminNavTab.notifications),
                        ),
                      AdminNavTab.tests => const TestsTab(),
                      AdminNavTab.users => const UsersTab(),
                      AdminNavTab.patterns => const PatternsTab(),
                      AdminNavTab.aiCreator => AiCreatorTab(
                          onSavedToTests: () => setState(() => _activeTab = AdminNavTab.tests),
                        ),
                      AdminNavTab.finance => const FinanceTab(),
                      AdminNavTab.contests => const ContestsTab(),
                      AdminNavTab.banners => const BannersTab(),
                      AdminNavTab.notifications => const NotificationsTab(),
                      AdminNavTab.wheel => const WheelTab(),
                      AdminNavTab.leaderboard => const LeaderboardTab(),
                      AdminNavTab.referrals => const ReferralsTab(),
                      AdminNavTab.posts => const PostsTab(),
                      AdminNavTab.support => const SupportTab(),
                      AdminNavTab.feedback => const FeedbackTab(),
                      AdminNavTab.battleQs => const BattleQsTab(),
                      AdminNavTab.polls => const PollsTab(),
                      AdminNavTab.settings => const SettingsTab(),
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Fixed 64px Top Header matching App.tsx:242-303 ---
  Widget _buildTopHeaderBar(BuildContext context, bool isNarrow) {
    return Container(
      height: 64,
      width: double.infinity,
      color: const Color(0xFF10B981),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Logo + Brand + Divider + Active Tab Title
            Row(
            children: [
              if (isNarrow) ...[
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF065F46).withAlpha(120),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withAlpha(50)),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'R',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Rankearn',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, height: 1.1),
                  ),
                  Text(
                    'Learning with Earning',
                    style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Container(
                height: 28,
                width: 1,
                color: Colors.white.withAlpha(60),
              ),
              const SizedBox(width: 20),
              Text(
                _getTabTitle(_activeTab),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ],
          ),

          // Right: Notifications + Divider + ADMIN badge + Name + Avatar
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Color(0xFFD1FAE5)),
                tooltip: 'System Alerts',
                onPressed: () {
                  setState(() => _activeTab = AdminNavTab.notifications);
                },
              ),
              const SizedBox(width: 8),
              Container(
                height: 28,
                width: 1,
                color: Colors.white.withAlpha(60),
              ),
              const SizedBox(width: 16),
              if (!isNarrow) ...[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: Color(0xFF065F46),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Anand Sawre',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'Super Admin • PRO Member',
                      style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
              ],
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Admin Session'),
                      content: const Text('Logged in as Anand Sawre (anand.sawre@rankearn.com).'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        AppButton(
                          label: 'Sign Out',
                          variant: AppButtonVariant.destructive,
                          onPressed: () {
                            Navigator.pop(ctx);
                            setState(() => _isLoggedIn = false);
                          },
                        ),
                      ],
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  child: Text(
                    'AS',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  }

  // --- Login Screen ---
  Widget _buildAdminLoginScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
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
                  const Text('Management Portal Access', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
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
