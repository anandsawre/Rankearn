import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
// Hot reload: Matched Dashboard full width padding & removed duplicate left checkbox (2026-10-20)

import 'features/overview/overview_tab.dart';
import 'features/overview/banner_image_data.dart';
import 'features/tests/tests_tab.dart';
import 'features/users/users_tab.dart';
import 'features/categories/categories_tab.dart';
import 'features/ai_creator/ai_creator_tab.dart';
import 'features/contests/contests_tab.dart';
import 'features/banners/banners_tab.dart';
import 'features/notifications/notifications_tab.dart';
import 'features/lucky_wheel/lucky_wheel_tab.dart';
import 'features/lucky_wheel/widgets/lucky_wheel_icon.dart';
import 'features/tournaments/tournaments_tab.dart';
import 'features/payments/payments_tab.dart';
import 'features/referrals/referrals_tab.dart';
import 'features/posts/posts_tab.dart';
import 'features/support/support_tab.dart';
import 'features/feedback/feedback_tab.dart';
import 'features/questions/questions_tab.dart';
import 'package:flutter/services.dart';
import 'features/polls/polls_tab.dart';
import 'features/settings/settings_tab.dart';
import 'features/auth/admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Supabase initialization: $e');
  }

  runApp(
    const ProviderScope(
      // Launch Admin Login Screen with single-viewport responsive fit (no scrolling)
      child: RankearnAdminApp(startLoggedIn: false),
    ),
  );
}

class RankearnAdminApp extends StatelessWidget {
  final bool startLoggedIn;
  final AdminNavTab initialTab;

  const RankearnAdminApp({
    super.key,
    this.startLoggedIn = true,
    this.initialTab = AdminNavTab.overview,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rankearn Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5636F5),
          primary: const Color(0xFF5636F5),
          surface: Colors.white,
        ),
      ),
      home: AdminAppShell(startLoggedIn: startLoggedIn, initialTab: initialTab),
    );
  }
}

class AdminAppShell extends StatefulWidget {
  final bool startLoggedIn;
  final AdminNavTab initialTab;

  const AdminAppShell({
    super.key,
    this.startLoggedIn = true,
    this.initialTab = AdminNavTab.overview,
  });

  @override
  State<AdminAppShell> createState() => _AdminAppShellState();
}

class _AdminAppShellState extends State<AdminAppShell> {
  late AdminNavTab _activeTab = widget.initialTab;
  late bool _isLoggedIn = widget.startLoggedIn;

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

    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 1000;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        drawer: isNarrow ? _buildAdminDrawer(context) : null,
        bottomNavigationBar: isNarrow ? _buildMobileBottomNav(context) : null,
        body: Column(
          children: [
            // 1. Pixel-perfect Top Navigation Bar with Seamless Status Bar Integration
            Container(
              color: Colors.white,
              child: SafeArea(
                bottom: false,
                child: _buildPixelPerfectHeaderBar(context, isNarrow),
              ),
            ),

            // 2. Main Page Content (Full Width)
            Expanded(
              child: Container(
                color: const Color(0xFFF8FAFC),
                width: double.infinity,
                child: switch (_activeTab) {
                  AdminNavTab.overview => OverviewTab(
                      onGoToTests: () => setState(() => _activeTab = AdminNavTab.tests),
                      onGoToFinance: () => setState(() => _activeTab = AdminNavTab.finance),
                      onGoToUsers: () => setState(() => _activeTab = AdminNavTab.users),
                      onGoToAiCreator: () => setState(() => _activeTab = AdminNavTab.aiCreator),
                      onGoToNotifications: () => setState(() => _activeTab = AdminNavTab.notifications),
                      onGoToCategories: () => setState(() => _activeTab = AdminNavTab.patterns),
                      onGoToLiveQuiz: () => setState(() => _activeTab = AdminNavTab.contests),
                      onGoToTournaments: () => setState(() => _activeTab = AdminNavTab.leaderboard),
                    ),
                  AdminNavTab.tests => const TestsTab(),
                  AdminNavTab.users => const UsersTab(),
                  AdminNavTab.patterns => const CategoriesTab(),
                  AdminNavTab.aiCreator => AiCreatorTab(
                      onSavedToTests: () => setState(() => _activeTab = AdminNavTab.tests),
                    ),
                  AdminNavTab.finance => const PaymentsTab(),
                  AdminNavTab.contests => ContestsTab(
                      onManageQuestions: () => setState(() => _activeTab = AdminNavTab.battleQs),
                    ),
                  AdminNavTab.banners => const BannersTab(),
                  AdminNavTab.notifications => const NotificationsTab(),
                  AdminNavTab.wheel => const LuckyWheelTab(),
                  AdminNavTab.leaderboard => const TournamentsTab(),
                  AdminNavTab.referrals => const ReferralsTab(),
                  AdminNavTab.posts => const PostsTab(),
                  AdminNavTab.support => const SupportTab(),
                  AdminNavTab.feedback => const FeedbackTab(),
                  AdminNavTab.battleQs => const QuestionsTab(),
                  AdminNavTab.polls => const PollsTab(),
                  AdminNavTab.settings => const SettingsTab(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TOP NAVBAR MATCHING SCREENSHOT EXACTLY
  // ==========================================
  Widget _buildPixelPerfectHeaderBar(BuildContext context, bool isNarrow) {
    return Container(
      height: isNarrow ? 60 : 70,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT: (Hamburger menu if narrow) + Brand Trophy + Rankearn & Admin Panel
          Row(
            children: [
              if (isNarrow) ...[
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Color(0xFF101A3A),
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                    tooltip: 'Open Menu',
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Container(
                width: isNarrow ? 28 : 34,
                height: isNarrow ? 28 : 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: const Color(0xFFF59E0B),
                  size: isNarrow ? 18 : 22,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Rank',
                          style: TextStyle(
                            fontSize: isNarrow ? 16 : 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF101A3A),
                            letterSpacing: -0.4,
                            height: 1.15,
                          ),
                        ),
                        TextSpan(
                          text: 'earn',
                          style: TextStyle(
                            fontSize: isNarrow ? 16 : 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF5636F5),
                            letterSpacing: -0.4,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF0FF),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFE0E7FF), width: 0.8),
                    ),
                    child: const Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5636F5),
                        letterSpacing: 0.2,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),


          // MIDDLE: Horizontal Navigation Pills
          if (!isNarrow)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNavPill(
                      tab: AdminNavTab.overview,
                      label: 'Dashboard',
                      icon: Icons.dashboard_rounded,
                      isActive: _activeTab == AdminNavTab.overview,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.tests,
                      label: 'Test Series',
                      icon: Icons.menu_book_outlined,
                      isActive: _activeTab == AdminNavTab.tests,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.battleQs,
                      label: 'Questions',
                      icon: Icons.help_outline_rounded,
                      isActive: _activeTab == AdminNavTab.battleQs,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.patterns,
                      label: 'Exams',
                      icon: Icons.explore_outlined,
                      isActive: _activeTab == AdminNavTab.patterns,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.users,
                      label: 'Users',
                      icon: Icons.people_outline_rounded,
                      isActive: _activeTab == AdminNavTab.users,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.contests,
                      label: 'Live Quiz',
                      icon: Icons.podcasts_rounded,
                      isActive: _activeTab == AdminNavTab.contests,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.leaderboard,
                      label: 'Tournaments',
                      icon: Icons.emoji_events_outlined,
                      isActive: _activeTab == AdminNavTab.leaderboard,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.finance,
                      label: 'Payments',
                      icon: Icons.credit_card_outlined,
                      isActive: _activeTab == AdminNavTab.finance,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.wheel,
                      label: 'Lucky Wheel',
                      icon: Icons.donut_large_rounded,
                      customIcon: LuckyWheelIcon(
                        size: 16,
                        color: _activeTab == AdminNavTab.wheel
                            ? Colors.white
                            : const Color(0xFF475569),
                      ),
                      isActive: _activeTab == AdminNavTab.wheel,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.aiCreator,
                      label: 'AI Test Creator',
                      icon: Icons.auto_awesome_rounded,
                      isActive: _activeTab == AdminNavTab.aiCreator,
                    ),
                    const SizedBox(width: 4),
                    _buildMoreNavButton(),
                  ],
                ),
              ),
            ),

          // RIGHT: Notifications Bell + User Profile Avatar
          Row(
            children: [
              // Notification Bell with Red Badge "3"
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF64748B),
                      size: 23,
                    ),
                    onPressed: () => setState(() => _activeTab = AdminNavTab.notifications),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // User Profile Avatar & Title
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Admin Session'),
                      content: const Text('Logged in as Admin User (admin@quizmaster.com)'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Close'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            setState(() => _isLoggedIn = false);
                          },
                          child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          kAdminAvatarBytes,
                          width: isNarrow ? 32 : 38,
                          height: isNarrow ? 32 : 38,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (!isNarrow) ...[
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Admin User',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                                height: 1.15,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'Super Admin',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // NAVIGATION PILL WIDGET
  // ==========================================
  Widget _buildNavPill({
    required AdminNavTab tab,
    required String label,
    required IconData icon,
    Widget? customIcon,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: () => _navigateToTab(tab),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF5636F5) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              customIcon ??
                  Icon(
                    icon,
                    size: 16,
                    color: isActive ? Colors.white : const Color(0xFF475569),
                  ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : const Color(0xFF334155),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MORE BUTTON WITH ALL 18 SIDEBAR TABS
  // ==========================================
  Widget _buildMoreNavButton() {
    final directTabs = [
      AdminNavTab.overview,
      AdminNavTab.tests,
      AdminNavTab.battleQs,
      AdminNavTab.patterns,
      AdminNavTab.users,
      AdminNavTab.contests,
      AdminNavTab.leaderboard,
      AdminNavTab.finance,
      AdminNavTab.wheel,
      AdminNavTab.aiCreator,
    ];
    final isMoreActive = !directTabs.contains(_activeTab);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: PopupMenuButton<AdminNavTab>(
        tooltip: 'All Navigation Modules',
        offset: const Offset(0, 44),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        color: Colors.white,
        constraints: const BoxConstraints(maxHeight: 520, minWidth: 260, maxWidth: 300),
        onSelected: _navigateToTab,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: isMoreActive ? const Color(0xFF5636F5) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.more_horiz_rounded,
                size: 16,
                color: isMoreActive ? Colors.white : const Color(0xFF475569),
              ),
              const SizedBox(width: 6),
              Text(
                'More',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isMoreActive ? FontWeight.w700 : FontWeight.w500,
                  color: isMoreActive ? Colors.white : const Color(0xFF334155),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isMoreActive ? Colors.white : const Color(0xFF64748B),
              ),
            ],
          ),
        ),
        itemBuilder: (context) => [
          _buildPopupSectionTitle('CORE MODULES'),
          _buildPopupItem(AdminNavTab.overview, 'Dashboard', Icons.dashboard_rounded),
          _buildPopupItem(AdminNavTab.tests, 'Test Series', Icons.menu_book_outlined),
          _buildPopupItem(AdminNavTab.users, 'Users Management', Icons.people_outline_rounded),
          _buildPopupItem(AdminNavTab.patterns, 'Exam Patterns', Icons.layers_outlined),
          _buildPopupItem(
            AdminNavTab.aiCreator,
            'AI Test Creator',
            Icons.psychology_outlined,
            badgeText: 'AI',
            badgeColor: const Color(0xFF6366F1),
          ),

          const PopupMenuDivider(height: 12),
          _buildPopupSectionTitle('LIVE & COMMUNITY'),
          _buildPopupItem(
            AdminNavTab.contests,
            'Contests & Battles',
            Icons.sports_esports_outlined,
            badgeText: 'LIVE',
            badgeColor: const Color(0xFFEF4444),
          ),
          _buildPopupItem(AdminNavTab.leaderboard, 'Leaderboard', Icons.leaderboard_outlined),
          _buildPopupItem(AdminNavTab.posts, 'Community Posts', Icons.chat_bubble_outline_rounded),
          _buildPopupItem(
            AdminNavTab.wheel,
            'Lucky Wheel',
            Icons.donut_large_rounded,
            badgeText: 'NEW',
            badgeColor: const Color(0xFF10B981),
          ),
          _buildPopupItem(AdminNavTab.battleQs, 'Questions Management', Icons.help_outline_rounded),
          _buildPopupItem(AdminNavTab.polls, 'Live Polls', Icons.poll_outlined),

          const PopupMenuDivider(height: 12),
          _buildPopupSectionTitle('FINANCE & GROWTH'),
          _buildPopupItem(AdminNavTab.finance, 'Finance & Wallet', Icons.account_balance_wallet_outlined),
          _buildPopupItem(AdminNavTab.referrals, 'Referrals & Earnings', Icons.share_outlined),
          _buildPopupItem(AdminNavTab.banners, 'Promo Banners', Icons.image_outlined),
          _buildPopupItem(AdminNavTab.notifications, 'Notifications', Icons.notifications_active_outlined),

          const PopupMenuDivider(height: 12),
          _buildPopupSectionTitle('SYSTEM & SUPPORT'),
          _buildPopupItem(AdminNavTab.support, 'Support Tickets', Icons.confirmation_number_outlined),
          _buildPopupItem(AdminNavTab.feedback, 'User Feedback', Icons.rate_review_outlined),
          _buildPopupItem(AdminNavTab.settings, 'Platform Settings', Icons.settings_outlined),
        ],
      ),
    );
  }

  PopupMenuEntry<AdminNavTab> _buildPopupSectionTitle(String title) {
    return PopupMenuItem<AdminNavTab>(
      enabled: false,
      height: 26,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF94A3B8),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  PopupMenuEntry<AdminNavTab> _buildPopupItem(
    AdminNavTab tab,
    String title,
    IconData icon, {
    String? badgeText,
    Color? badgeColor,
  }) {
    final isSelected = _activeTab == tab;

    return PopupMenuItem<AdminNavTab>(
      value: tab,
      height: 38,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF1E293B),
                ),
              ),
            ),
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: (badgeColor ?? const Color(0xFF4F46E5)).withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: badgeColor ?? const Color(0xFF4F46E5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MOBILE BOTTOM NAVIGATION BAR
  // ==========================================
  Widget _buildMobileBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: _buildBottomNavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isSelected: _activeTab == AdminNavTab.overview,
                  onTap: () => _navigateToTab(AdminNavTab.overview),
                ),
              ),
              Expanded(
                child: _buildBottomNavItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Test Series',
                  isSelected: _activeTab == AdminNavTab.tests,
                  onTap: () => _navigateToTab(AdminNavTab.tests),
                ),
              ),
              Expanded(
                child: _buildBottomNavItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Questions',
                  isSelected: _activeTab == AdminNavTab.battleQs,
                  onTap: () => _navigateToTab(AdminNavTab.battleQs),
                ),
              ),
              Expanded(
                child: _buildBottomNavItem(
                  icon: Icons.people_outline_rounded,
                  label: 'Users',
                  isSelected: _activeTab == AdminNavTab.users,
                  onTap: () => _navigateToTab(AdminNavTab.users),
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (ctx) => _buildBottomNavItem(
                    icon: Icons.menu_rounded,
                    label: 'Menu',
                    isSelected: ![
                      AdminNavTab.overview,
                      AdminNavTab.tests,
                      AdminNavTab.battleQs,
                      AdminNavTab.users,
                    ].contains(_activeTab),
                    onTap: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? const Color(0xFF5636F5) : const Color(0xFF64748B);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MOBILE / TABLET SIDE NAVIGATION DRAWER
  // ==========================================
  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            // 1. Drawer Header (Brand + User Profile)
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFF59E0B),
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Text.rich(
                        const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Rank',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF101A3A),
                                letterSpacing: -0.4,
                              ),
                            ),
                            TextSpan(
                              text: 'earn',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF5636F5),
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          kAdminAvatarBytes,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Admin User',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'Super Admin',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF5636F5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Navigation Modules List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                children: [
                  _buildDrawerSectionHeader('CORE MODULES'),
                  _buildDrawerItem(AdminNavTab.overview, 'Dashboard', Icons.dashboard_rounded),
                  _buildDrawerItem(AdminNavTab.tests, 'Test Series', Icons.menu_book_rounded),
                  _buildDrawerItem(AdminNavTab.battleQs, 'Questions Management', Icons.help_outline_rounded),
                  _buildDrawerItem(AdminNavTab.patterns, 'Target Exams', Icons.explore_outlined),
                  _buildDrawerItem(AdminNavTab.users, 'Users & Students', Icons.people_outline_rounded),
                  _buildDrawerItem(AdminNavTab.aiCreator, 'AI Generator', Icons.auto_awesome_rounded),

                  const SizedBox(height: 10),
                  _buildDrawerSectionHeader('LIVE & GAMIFICATION'),
                  _buildDrawerItem(AdminNavTab.contests, 'Live Quiz', Icons.podcasts_rounded),
                  _buildDrawerItem(AdminNavTab.leaderboard, 'Tournaments & Leaderboard', Icons.emoji_events_outlined),
                  _buildDrawerItem(AdminNavTab.wheel, 'Lucky Spin Wheel', Icons.adjust_rounded),
                  _buildDrawerItem(AdminNavTab.polls, 'Live Polls', Icons.poll_outlined),
                  _buildDrawerItem(AdminNavTab.posts, 'Community Posts', Icons.article_outlined),

                  const SizedBox(height: 10),
                  _buildDrawerSectionHeader('FINANCE & MARKETING'),
                  _buildDrawerItem(AdminNavTab.finance, 'Payments & Revenue', Icons.credit_card_outlined),
                  _buildDrawerItem(AdminNavTab.banners, 'Promotional Banners', Icons.view_carousel_outlined),
                  _buildDrawerItem(AdminNavTab.referrals, 'Referral Program', Icons.share_outlined),
                  _buildDrawerItem(AdminNavTab.notifications, 'Push Notifications', Icons.notifications_none_rounded),

                  const SizedBox(height: 10),
                  _buildDrawerSectionHeader('SYSTEM & SUPPORT'),
                  _buildDrawerItem(AdminNavTab.support, 'Help Desk & Tickets', Icons.headset_mic_outlined),
                  _buildDrawerItem(AdminNavTab.feedback, 'User Feedback', Icons.feedback_outlined),
                  _buildDrawerItem(AdminNavTab.settings, 'Settings & Configuration', Icons.settings_outlined),
                ],
              ),
            ),

            // 3. Drawer Footer: Sign Out
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _isLoggedIn = false);
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: const [
                      Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(AdminNavTab tab, String title, IconData icon) {
    final isSelected = _activeTab == tab;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _navigateToTab(tab);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEEF0FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: isSelected ? const Color(0xFF5636F5) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF5636F5) : const Color(0xFF334155),
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF5636F5),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // LOGIN SCREEN
  // ==========================================
  Widget _buildAdminLoginScreen() {
    return AdminLoginScreen(
      onLoginSuccess: () {
        setState(() => _isLoggedIn = true);
      },
      onBackToWebsite: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Redirecting to Rankearn main site...'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
