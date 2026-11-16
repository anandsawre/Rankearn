import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import 'features/battle_dashboard/battle_dashboard_tab.dart';

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

  // Restore authenticated admin session across browser page reloads (F5)
  bool startLoggedIn = false;
  try {
    final client = SupabaseConfig.clientSafe;
    final currentSession = client?.auth.currentSession;
    final prefs = await SharedPreferences.getInstance();
    final wasLoggedIn = prefs.getBool('rankearn_admin_logged_in') ?? false;
    startLoggedIn = currentSession != null || (wasLoggedIn && client?.auth.currentUser != null);
  } catch (_) {}

  runApp(
    ProviderScope(
      child: RankearnAdminApp(startLoggedIn: startLoggedIn),
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
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Plus Jakarta Sans',
        fontFamilyFallback: const ['Inter', 'Noto Sans Devanagari', 'Roboto', 'sans-serif'],
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
  final ScrollController _navScrollController = ScrollController();
  StreamSubscription<AuthState>? _authSubscription;

  String _adminDisplayName = 'Admin User';
  String _adminEmail = '';
  String _adminRoleLabel = 'Super Admin';

  @override
  void initState() {
    super.initState();
    _checkAndRestoreSession();
    _setupAuthListener();
    _syncCurrentAdminProfile();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _navScrollController.dispose();
    super.dispose();
  }

  Future<void> _checkAndRestoreSession() async {
    try {
      final client = SupabaseConfig.clientSafe;
      final prefs = await SharedPreferences.getInstance();
      final wasLoggedIn = prefs.getBool('rankearn_admin_logged_in') ?? false;

      if (client != null && (client.auth.currentSession != null || (wasLoggedIn && client.auth.currentUser != null))) {
        if (mounted && !_isLoggedIn) {
          setState(() {
            _isLoggedIn = true;
          });
        }
        _syncCurrentAdminProfile();
      }
    } catch (_) {}
  }

  void _setupAuthListener() {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return;

    _authSubscription = client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn || (session != null && event == AuthChangeEvent.tokenRefreshed)) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('rankearn_admin_logged_in', true);
        } catch (_) {}
        if (mounted && !_isLoggedIn) {
          setState(() {
            _isLoggedIn = true;
          });
          _syncCurrentAdminProfile();
        }
      } else if (event == AuthChangeEvent.signedOut) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('rankearn_admin_logged_in', false);
        } catch (_) {}
        if (mounted && _isLoggedIn) {
          setState(() {
            _isLoggedIn = false;
            _adminDisplayName = 'Admin User';
            _adminEmail = '';
          });
        }
      }
    });
  }

  Future<void> _syncCurrentAdminProfile() async {
    final client = SupabaseConfig.clientSafe;
    final user = client?.auth.currentUser;
    if (user == null) return;

    final fallbackName = (user.userMetadata?['name']?.toString().trim().isNotEmpty ?? false)
        ? user.userMetadata!['name'].toString().trim()
        : (user.email?.split('@').first ?? 'Admin User');

    if (mounted) {
      setState(() {
        _adminDisplayName = fallbackName;
        _adminEmail = user.email ?? '';
        _adminRoleLabel = 'Super Admin';
      });
    }

    try {
      final profile = await client!
          .from('profiles')
          .select('name, email')
          .eq('id', user.id)
          .maybeSingle();
      if (profile != null && mounted) {
        final dbName = profile['name']?.toString().trim();
        final dbEmail = profile['email']?.toString().trim();
        setState(() {
          if (dbName != null && dbName.isNotEmpty) _adminDisplayName = dbName;
          if (dbEmail != null && dbEmail.isNotEmpty) _adminEmail = dbEmail;
        });
      }
    } catch (_) {
      // Auth metadata fallback already applied cleanly.
    }
  }

  String get _adminInitials {
    final parts = _adminDisplayName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'AD';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _handleSignOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rankearn_admin_logged_in', false);
    } catch (_) {}
    try {
      await SupabaseConfig.clientSafe?.auth.signOut();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _isLoggedIn = false;
      _adminDisplayName = 'Admin User';
      _adminEmail = '';
    });
  }

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
    final isNarrow = screenWidth < 800;

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
                child: _buildPixelPerfectHeaderBar(context, isNarrow, screenWidth),
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
                  AdminNavTab.battles => const BattleDashboardTab(),
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
  Widget _buildPixelPerfectHeaderBar(BuildContext context, bool isNarrow, double screenWidth) {
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
        children: [
          // LEFT: (Hamburger menu if narrow) + Brand Trophy + Rankearn & Admin Panel
          if (isNarrow)
            Flexible(child: _buildBrandHeaderLeft(isNarrow))
          else
            _buildBrandHeaderLeft(isNarrow),

          // MIDDLE: Horizontal Navigation Pills (Left-aligned right after logo)
          if (!isNarrow) ...[
            const SizedBox(width: 18),
            Expanded(
              child: SingleChildScrollView(
                controller: _navScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                      tab: AdminNavTab.battles,
                      label: 'Live Battles',
                      icon: Icons.sports_kabaddi_rounded,
                      isActive: _activeTab == AdminNavTab.battles,
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
                      tab: AdminNavTab.aiCreator,
                      label: 'AI Test Creator',
                      icon: Icons.auto_awesome_rounded,
                      isActive: _activeTab == AdminNavTab.aiCreator,
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
                      tab: AdminNavTab.wheel,
                      label: 'Lucky Wheel',
                      icon: Icons.donut_large_rounded,
                      customIcon: LuckyWheelIcon(
                        size: 16,
                        color: _activeTab == AdminNavTab.wheel
                            ? const Color(0xFF5636F5)
                            : const Color(0xFF475569),
                      ),
                      isActive: _activeTab == AdminNavTab.wheel,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.polls,
                      label: 'Live Polls',
                      icon: Icons.poll_outlined,
                      isActive: _activeTab == AdminNavTab.polls,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.posts,
                      label: 'Community Posts',
                      icon: Icons.article_outlined,
                      isActive: _activeTab == AdminNavTab.posts,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.finance,
                      label: 'Payments',
                      icon: Icons.credit_card_outlined,
                      isActive: _activeTab == AdminNavTab.finance,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.banners,
                      label: 'Promo Banners',
                      icon: Icons.view_carousel_outlined,
                      isActive: _activeTab == AdminNavTab.banners,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.referrals,
                      label: 'Referrals',
                      icon: Icons.share_outlined,
                      isActive: _activeTab == AdminNavTab.referrals,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.notifications,
                      label: 'Notifications',
                      icon: Icons.notifications_none_rounded,
                      isActive: _activeTab == AdminNavTab.notifications,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.support,
                      label: 'Support Tickets',
                      icon: Icons.headset_mic_outlined,
                      isActive: _activeTab == AdminNavTab.support,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.feedback,
                      label: 'User Feedback',
                      icon: Icons.feedback_outlined,
                      isActive: _activeTab == AdminNavTab.feedback,
                    ),
                    _buildNavPill(
                      tab: AdminNavTab.settings,
                      label: 'Settings',
                      icon: Icons.settings_outlined,
                      isActive: _activeTab == AdminNavTab.settings,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
          ] else
            const Spacer(),

          // RIGHT: Notifications Bell + User Profile Avatar
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notification Bell with Red Badge "3"
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF64748B),
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => setState(() => _activeTab = AdminNavTab.notifications),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
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
                  AppModalDialog.show(
                    context: context,
                    builder: (ctx) => AppModalDialog(
                      title: 'Admin Session',
                      subtitle: 'Active administrative session',
                      iconData: Icons.account_circle_rounded,
                      gradientColors: const [Color(0xFF5636F5), Color(0xFF7C3AED)],
                      maxWidth: 420,
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                          ),
                          child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _handleSignOut();
                          },
                          icon: const Icon(Icons.logout_rounded, size: 16),
                          label: const Text('Sign Out'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFF5636F5),
                              child: Text(_adminInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _adminDisplayName,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    _adminEmail.isNotEmpty ? _adminEmail : _adminRoleLabel,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      if (!isNarrow && screenWidth >= 1200) ...[
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _adminDisplayName,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _adminRoleLabel,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
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
  // BRAND HEADER LEFT (LOGO & BADGE)
  // ==========================================
  Widget _buildBrandHeaderLeft(bool isNarrow) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Rank',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
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
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isNarrow ? 16 : 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5636F5),
                      letterSpacing: -0.4,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Admin Panel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 1.5),
      child: InkWell(
        onTap: () => _navigateToTab(tab),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF5636F5) : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              customIcon ??
                  Icon(
                    icon,
                    size: 16,
                    color: isActive ? const Color(0xFF5636F5) : const Color(0xFF64748B),
                  ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                  color: isActive ? const Color(0xFF5636F5) : const Color(0xFF334155),
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
              ),
            ],
          ),
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
                          children: [
                            Text(
                              _adminDisplayName,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _adminRoleLabel,
                              style: const TextStyle(
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
                  _buildDrawerItem(AdminNavTab.battles, 'Battle Management', Icons.sports_kabaddi_rounded),
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
      onLoginSuccess: () async {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('rankearn_admin_logged_in', true);
        } catch (_) {}
        if (mounted) {
          setState(() => _isLoggedIn = true);
          _syncCurrentAdminProfile();
        }
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
