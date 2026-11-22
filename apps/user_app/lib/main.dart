import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'features/quiz/quiz_screen.dart';
import 'features/spin/lucky_wheel_screen.dart';
import 'features/battle/battle_hub_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/tests/test_series_screen.dart';
import 'features/tests/screens/test_result_screen.dart';
import 'features/live/live_tests_screen.dart';
import 'features/wallet/wallet_screen.dart';
import 'features/wallet/components/buy_coins_modal.dart';
import 'features/profile/profile_screen.dart';
import 'features/rewards/rewards_hub_screen.dart';
import 'features/auth/user_auth_screen.dart';
import 'features/leaderboard/leaderboard_screen.dart';
import 'features/tournament/screens/tournament_screen.dart';
import 'features/notifications/web_notification_helper.dart';
import 'features/notifications/in_app_notification_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Initialize Push & In-App Notification Service
  try {
    await PushNotificationService.initialize();
  } catch (e) {
    debugPrint('PushNotificationService initialization: $e');
  }

  // Restore authenticated user session before runApp to eliminate re-login on APK reopen
  UserProfile? initialProfile;
  try {
    final authRepo = AuthRepository();
    // 1. Instantly check local profile cache FIRST (1ms disk read, zero network dependency)
    initialProfile = await authRepo.getLocalProfile();
    if (initialProfile == null) {
      // 2. Fallback to Supabase session recovery only if no local cache exists
      await SupabaseConfig.ensureSessionReady();
      final res = await authRepo.restoreSession();
      if (res case Success(:final data)) {
        initialProfile = data;
      }
    } else {
      // Asynchronously ensure Supabase session is synchronized without blocking app startup
      unawaited(SupabaseConfig.ensureSessionReady());
    }
  } catch (_) {}

  runApp(
    ProviderScope(
      child: RankearnUserApp(
        initialProfile: initialProfile,
        showAuthInitially: initialProfile == null,
      ),
    ),
  );
}

class RankearnUserApp extends StatefulWidget {
  final List<TestModel>? initialTests;
  final bool? showAuthInitially;
  final bool autoCheckSession;
  final UserProfile? initialProfile;

  const RankearnUserApp({
    super.key,
    this.initialTests,
    this.showAuthInitially,
    this.autoCheckSession = true,
    this.initialProfile,
  });

  @override
  State<RankearnUserApp> createState() => _RankearnUserAppState();
}

class _RankearnUserAppState extends State<RankearnUserApp> {
  final AuthRepository _authRepository = AuthRepository();
  StreamSubscription<dynamic>? _authSubscription;
  late bool _showAuth;
  bool _isCheckingSession = false;
  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.initialProfile;

    if (_currentUser != null) {
      _showAuth = false;
      _isCheckingSession = false;
    } else {
      _isCheckingSession = widget.autoCheckSession;
      _showAuth = !_isCheckingSession;
      if (widget.autoCheckSession) {
        _checkSession();
      }
    }

    _subscribeAuth();
  }

  Future<void> _checkSession() async {
    try {
      final res = await _authRepository.restoreSession();
      if (mounted) {
        if (res case Success(:final data)) {
          setState(() {
            _currentUser = data;
            _showAuth = false;
            _isCheckingSession = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Session check error: $e');
    }
    if (mounted) {
      final cached = await _authRepository.getLocalProfile();
      if (cached != null) {
        setState(() {
          _currentUser = cached;
          _showAuth = false;
          _isCheckingSession = false;
        });
        return;
      }

      // 3. Fallback to Supabase current user
      final supaUser = SupabaseConfig.clientSafe?.auth.currentUser;
      if (supaUser != null) {
        final meta = supaUser.userMetadata ?? {};
        final fallback = UserProfile(
          id: supaUser.id,
          name: meta['name']?.toString() ??
              meta['full_name']?.toString() ??
              supaUser.email?.split('@').first ??
              'Rankearn Aspirant',
          email: supaUser.email ?? 'aspirant@rankearn.in',
          phone: supaUser.phone ?? meta['phone']?.toString(),
          coins: 100,
          subscriptionStatus: 'free',
          examPreparingFor: meta['exam_goal']?.toString() ?? 'Competitive Aspirant',
          state: 'India',
          createdAt: DateTime.now(),
        );
        await _authRepository.saveLocalProfile(fallback);
        setState(() {
          _currentUser = fallback;
          _showAuth = false;
          _isCheckingSession = false;
        });
        return;
      }

      setState(() {
        _currentUser = null;
        _showAuth = true;
        _isCheckingSession = false;
      });
    }
  }

  void _subscribeAuth() {
    _authSubscription = _authRepository.authStateChanges.listen((
      authState,
    ) async {
      final session = authState.session;
      final event = authState.event;

      if (session != null &&
          (event == AuthChangeEvent.initialSession ||
           event == AuthChangeEvent.signedIn ||
           event == AuthChangeEvent.tokenRefreshed)) {
        final res = await _authRepository.getProfile(session.user.id);
        if (mounted) {
          if (res case Success(:final data)) {
            await _authRepository.saveLocalProfile(data);
            setState(() {
              _currentUser = data;
              _showAuth = false;
              _isCheckingSession = false;
            });
          } else {
            final cached = await _authRepository.getLocalProfile();
            if (cached != null) {
              setState(() {
                _currentUser = cached;
                _showAuth = false;
                _isCheckingSession = false;
              });
            } else {
              final meta = session.user.userMetadata ?? {};
              final fallback = UserProfile(
                id: session.user.id,
                name: meta['name']?.toString() ??
                    meta['full_name']?.toString() ??
                    session.user.email?.split('@').first ??
                    'Rankearn Aspirant',
                email: session.user.email ?? 'aspirant@rankearn.in',
                phone: session.user.phone ?? meta['phone']?.toString(),
                coins: 100,
                subscriptionStatus: 'free',
                examPreparingFor: meta['exam_goal']?.toString() ?? 'Competitive Aspirant',
                state: 'India',
                createdAt: DateTime.now(),
              );
              await _authRepository.saveLocalProfile(fallback);
              setState(() {
                _currentUser = fallback;
                _showAuth = false;
                _isCheckingSession = false;
              });
            }
          }
        }
      } else if (event == AuthChangeEvent.signedOut) {
        // ONLY clear local profile if the logout was explicitly user-initiated (never on cold start / background timeout)
        if (authState.signOutReason == SignOutReason.userInitiated) {
          await _authRepository.clearLocalProfile();
          if (mounted) {
            setState(() {
              _currentUser = null;
              _showAuth = true;
              _isCheckingSession = false;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return MaterialApp(
        title: 'Rankearn',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF059669).withAlpha(60),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'R',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Rankearn',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Learn • Practice • Earn',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Rankearn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _showAuth
          ? UserAuthScreen(
              initialMode: AuthScreenMode.login,
              onAuthSuccess: (profile) async {
                await _authRepository.saveLocalProfile(profile);
                if (mounted) {
                  setState(() {
                    _currentUser = profile;
                    _showAuth = false;
                  });
                }
              },
            )
          : UserAppShell(
              initialTests: widget.initialTests,
              initialProfile: _currentUser,
              onLogout: () async {
                try {
                  await _authRepository.signOut();
                } catch (e) {
                  debugPrint('Logout error: $e');
                }
                await _authRepository.clearLocalProfile();
                if (mounted) {
                  setState(() {
                    _showAuth = true;
                    _currentUser = null;
                  });
                }
              },
            ),
    );
  }
}

class UserAppShell extends StatefulWidget {
  final List<TestModel>? initialTests;
  final UserProfile? initialProfile;
  final VoidCallback? onLogout;

  const UserAppShell({
    super.key,
    this.initialTests,
    this.initialProfile,
    this.onLogout,
  });

  @override
  State<UserAppShell> createState() => _UserAppShellState();
}

class _UserAppShellState extends State<UserAppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserNavTab _activeTab = UserNavTab.home;
  late UserProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile =
        widget.initialProfile ??
        UserProfile(
          id: 'usr_vikram_70',
          name: 'Vikram Singh',
          email: 'vikram.singh@rankearn.in',
          phone: '+91 98765 43210',
          coins: 1450,
          subscriptionStatus: 'premium',
          examPreparingFor: '70th BPSC Aspirant',
          state: 'Bihar, India',
          createdAt: DateTime(2026, 10, 1),
        );
    _syncProfileWithDatabase();
    _syncPlatformConfigs();
    _loadNotifications();
    _subscribeRealtimeNotifications();
    _flagsSub = _flagsRepo.streamFeatureFlags().listen(
      (updated) {
        if (mounted) setState(() => _featureFlags = updated);
      },
      onError: (_) {},
    );
  }

  bool _isUnderMaintenance = false;
  final FeatureFlagsRepository _flagsRepo = FeatureFlagsRepository();
  StreamSubscription<Map<String, bool>>? _flagsSub;
  Map<String, bool> _featureFlags = Map<String, bool>.from(FeatureFlagsRepository.defaultFlags);

  final NotificationsRepository _notificationsRepo = NotificationsRepository();
  StreamSubscription<Map<String, dynamic>>? _notificationsSub;
  List<Map<String, dynamic>> _notificationsList = [];

  @override
  void dispose() {
    _flagsSub?.cancel();
    _notificationsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final list = await _notificationsRepo.fetchNotifications(limit: 25);
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = SupabaseConfig.clientSafe?.auth.currentUser?.id ?? _profile.id;
      final clearedAtMillis = prefs.getInt('notifications_cleared_at_$currentUserId') ?? 0;

      final filteredList = list.where((n) {
        final createdAtStr = n['created_at']?.toString();
        if (createdAtStr != null && clearedAtMillis > 0) {
          final createdAt = DateTime.tryParse(createdAtStr)?.millisecondsSinceEpoch ?? 0;
          if (createdAt <= clearedAtMillis) {
            return false;
          }
        }
        return true;
      }).toList();

      if (mounted) {
        final unreadCount = filteredList.where((n) {
          final isRead = n['is_read'] == true;
          final readBy = n['read_by'] is List ? (n['read_by'] as List) : [];
          if (currentUserId.isNotEmpty && readBy.contains(currentUserId)) {
            return false;
          }
          return !isRead;
        }).length;

        setState(() {
          _notificationsList = filteredList;
          _unreadNotifications = unreadCount;
        });
      }
    } catch (_) {}
  }

  Future<void> _clearAllNotifications() async {
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = SupabaseConfig.clientSafe?.auth.currentUser?.id ?? _profile.id;
      await prefs.setInt('notifications_cleared_at_$currentUserId', nowMillis);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _notificationsList.clear();
        _unreadNotifications = 0;
      });
    }
  }

  void _subscribeRealtimeNotifications() {
    _notificationsSub?.cancel();
    _notificationsSub = _notificationsRepo.streamIncomingNotifications().listen((notif) {
      if (!mounted) return;
      _handleIncomingNotification(notif);
    });

    // Also connect PushNotificationService foreground & click listeners
    PushNotificationService.initialize(
      onForegroundNotification: (notif) {
        if (!mounted) return;
        _handleIncomingNotification(notif);
      },
      onNotificationTap: (data) {
        final actionUrl = data['actionUrl']?.toString() ?? data['action_url']?.toString();
        if (actionUrl != null && actionUrl.isNotEmpty) {
          _handleNotificationUrl(actionUrl);
        }
      },
    );
  }

  void _handleIncomingNotification(Map<String, dynamic> notif) {
    setState(() {
      _notificationsList.removeWhere((item) => item['id'] == notif['id']);
      _notificationsList.insert(0, notif);
      _unreadNotifications++;
    });

    final title = notif['title']?.toString() ?? 'New Announcement';
    final message = notif['message']?.toString() ?? '';
    final actionUrl = notif['action_url']?.toString();
    final channel = (notif['channel'] ?? 'push').toString().toLowerCase();

    // Trigger local system heads-up notification in Android notification bar
    triggerBrowserNotification(title, message, actionUrl);

    // If notification has image or is an in-app popup, show rich pop-up dialog!
    final hasImage = notif['image_url'] != null && notif['image_url'].toString().trim().isNotEmpty;
    if (hasImage || channel == 'inapp') {
      InAppNotificationDialog.show(
        context: context,
        notification: notif,
        onAction: (url) {
          _notificationsRepo.recordClick(notif['id']?.toString() ?? '');
          _handleNotificationUrl(url);
        },
      );
    } else {
      // Trigger Floating In-App Banner on user screen
      _showInAppNotificationBanner(notif);
    }
  }

  void _showInAppNotificationBanner(Map<String, dynamic> notif) {
    final title = notif['title']?.toString() ?? 'Rankearn Alert';
    final message = notif['message']?.toString() ?? '';
    final actionUrl = notif['action_url']?.toString();
    final rawActionLabel = notif['action_label']?.toString().trim();
    final actionLabel = (rawActionLabel != null && rawActionLabel.isNotEmpty) ? rawActionLabel : 'Open';
    final notifId = notif['id']?.toString() ?? '';
    final imageUrl = notif['image_url']?.toString().trim();
    final hasImg = imageUrl != null && imageUrl.isNotEmpty;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 7),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(14),
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (hasImg) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    width: 44,
                    height: 44,
                    color: const Color(0xFFF0FDF4),
                    child: const Icon(Icons.campaign_rounded, color: Color(0xFF059669), size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFF059669),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (actionUrl != null && actionUrl.isNotEmpty) ...[
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _notificationsRepo.recordClick(notifId);
                  _handleNotificationUrl(actionUrl);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleNotificationUrl(String rawUrl) async {
    final url = rawUrl.trim();
    if (url.isEmpty) return;

    final lower = url.toLowerCase();

    // 1. External Web & App URLs (http, https, www, mailto, tel, whatsapp, tg)
    if (lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        lower.startsWith('www.') ||
        lower.startsWith('mailto:') ||
        lower.startsWith('tel:') ||
        lower.startsWith('whatsapp:') ||
        lower.startsWith('tg:')) {
      final launchUri = lower.startsWith('www.')
          ? Uri.parse('https://$url')
          : Uri.parse(url);
      try {
        if (await canLaunchUrl(launchUri)) {
          await launchUrl(launchUri, mode: LaunchMode.externalApplication);
          return;
        } else {
          await launchUrl(launchUri);
          return;
        }
      } catch (e) {
        debugPrint('Could not launch external URL: $e');
      }
      return;
    }

    // 2. Fallback check for domain without protocol (e.g. "google.com", "t.me/channel")
    if (lower.contains('.') && !lower.startsWith('/') && !lower.contains(' ')) {
      try {
        final uri = Uri.parse('https://$url');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }

    // 3. Internal User App Tabs & Routes
    if (lower.contains('spin') || lower.contains('wheel')) {
      _navigateToTab(UserNavTab.spin);
    } else if (lower.contains('live') || lower.contains('contest')) {
      _navigateToTab(UserNavTab.live);
    } else if (lower.contains('test')) {
      _navigateToTab(UserNavTab.tests);
    } else if (lower.contains('battle')) {
      _navigateToTab(UserNavTab.battle);
    } else if (lower.contains('tournament')) {
      _navigateToTab(UserNavTab.tournament);
    } else if (lower.contains('reward') || lower.contains('earn')) {
      _navigateToTab(UserNavTab.rewards);
    } else if (lower.contains('leaderboard')) {
      _navigateToTab(UserNavTab.leaderboard);
    } else if (lower.contains('profile')) {
      _navigateToTab(UserNavTab.profile);
    } else if (lower.contains('wallet') || lower.contains('coin')) {
      _navigateToTab(UserNavTab.wallet);
    } else if (lower.contains('home')) {
      _navigateToTab(UserNavTab.home);
    }
  }

  Future<void> _syncPlatformConfigs() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return;
    try {
      final flags = await _flagsRepo.getFeatureFlags();
      if (mounted) setState(() => _featureFlags = flags);

      final res = await client.from('app_configs').select();
      if (res.isNotEmpty) {
        for (final row in res) {
          final key = row['key']?.toString();
          final val = row['value'];
          if (val is Map && key == 'advanced_settings') {
            final isMaint = val['maintenance_mode'] == true;
            if (mounted) setState(() => _isUnderMaintenance = isMaint);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _syncProfileWithDatabase() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return;
    try {
      final currentAuthId = client.auth.currentUser?.id;
      final targetId = (currentAuthId != null && currentAuthId.isNotEmpty)
          ? currentAuthId
          : _profile.id;

      final data = await client
          .from('profiles')
          .select()
          .eq('id', targetId)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _profile = _profile.copyWith(
            coins: (data['coins'] as num?)?.toInt() ?? _profile.coins,
            totalEarned: (data['total_earned'] as num?)?.toInt() ?? _profile.totalEarned,
            totalSpent: (data['total_spent'] as num?)?.toInt() ?? _profile.totalSpent,
            name: data['name']?.toString() ?? _profile.name,
          );
        });
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant UserAppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialProfile != null &&
        widget.initialProfile != oldWidget.initialProfile) {
      setState(() {
        _profile = widget.initialProfile!;
      });
    }
  }

  int _unreadNotifications = 2;

  // Sample Mock Test for Quick Launch
  final TestModel _defaultMockTest = const TestModel(
    id: 'test_bpsc_01',
    title: '70th BPSC Prelims Grand Mock 1',
    categoryId: 'BPSC',
    durationMinutes: 120,
    totalQuestions: 150,
    negativeMarking: 0.33,
    isProOnly: false,
    unlockPriceCoins: 0,
  );

  final List<QuestionModel> _sampleQuestions = const [
    QuestionModel(
      id: 'q_01',
      testId: 'test_bpsc_01',
      questionNumber: 1,
      questionTextEnglish:
          'When was the state of Bihar carved out from the Bengal Presidency?',
      questionTextHindi:
          'बिहार राज्य को बंगाल प्रेसीडेंसी से कब अलग किया गया था?',
      options: [
        QuestionOption(textEnglish: '1912', textHindi: '1912'),
        QuestionOption(textEnglish: '1905', textHindi: '1905'),
        QuestionOption(textEnglish: '1936', textHindi: '1936'),
        QuestionOption(textEnglish: '1947', textHindi: '1947'),
      ],
      correctAnswer: 0,
      explanationEnglish:
          'Bihar was carved out of the Bengal Presidency on 22 March 1912 (celebrated as Bihar Diwas).',
    ),
    QuestionModel(
      id: 'q_02',
      testId: 'test_bpsc_01',
      questionNumber: 2,
      questionTextEnglish:
          'Which river is historically known as the "Sorrow of Bihar"?',
      questionTextHindi:
          'किस नदी को ऐतिहासिक रूप से "बिहार का शोक" कहा जाता है?',
      options: [
        QuestionOption(textEnglish: 'Gandak River', textHindi: 'गंडक नदी'),
        QuestionOption(textEnglish: 'Kosi River', textHindi: 'कोसी नदी'),
        QuestionOption(textEnglish: 'Son River', textHindi: 'सोन नदी'),
        QuestionOption(textEnglish: 'Ghaghara River', textHindi: 'घाघरा नदी'),
      ],
      correctAnswer: 1,
      explanationEnglish:
          'The Kosi river is called the Sorrow of Bihar due to its frequent course shifts and devastating floods.',
    ),
    QuestionModel(
      id: 'q_03',
      testId: 'test_bpsc_01',
      questionNumber: 3,
      questionTextEnglish:
          'What is the minimum age required to become the Governor of an Indian state?',
      questionTextHindi:
          'भारत के किसी राज्य का राज्यपाल बनने के लिए न्यूनतम आयु क्या है?',
      options: [
        QuestionOption(textEnglish: '25 Years', textHindi: '25 वर्ष'),
        QuestionOption(textEnglish: '30 Years', textHindi: '30 वर्ष'),
        QuestionOption(textEnglish: '35 Years', textHindi: '35 वर्ष'),
        QuestionOption(textEnglish: '40 Years', textHindi: '40 वर्ष'),
      ],
      correctAnswer: 2,
      explanationEnglish:
          'Under Article 157 of the Indian Constitution, the minimum age is 35 years.',
    ),
    QuestionModel(
      id: 'q_04',
      testId: 'test_bpsc_01',
      questionNumber: 4,
      questionTextEnglish:
          'Who founded the Nalanda Mahavihara in ancient India?',
      questionTextHindi:
          'प्राचीन भारत में नालंदा महाविहार की स्थापना किसने की थी?',
      options: [
        QuestionOption(textEnglish: 'Harshavardhana', textHindi: 'हर्षवर्धन'),
        QuestionOption(
          textEnglish: 'Kumaragupta I',
          textHindi: 'कुमारगुप्त प्रथम',
        ),
        QuestionOption(textEnglish: 'Samudragupta', textHindi: 'समुद्रगुप्त'),
        QuestionOption(textEnglish: 'Ashoka', textHindi: 'अशोक'),
      ],
      correctAnswer: 1,
      explanationEnglish:
          'Nalanda was founded during the 5th century CE by Gupta Emperor Kumaragupta I.',
    ),
    QuestionModel(
      id: 'q_05',
      testId: 'test_bpsc_01',
      questionNumber: 5,
      questionTextEnglish:
          'In the Indian Rupee coin system on Rankearn, how many coins equal ₹1.00?',
      questionTextHindi:
          'Rankearn के कॉइन सिस्टम में कितने कॉइन ₹1.00 के बराबर होते हैं?',
      options: [
        QuestionOption(textEnglish: '10 Coins', textHindi: '10 कॉइन'),
        QuestionOption(textEnglish: '20 Coins', textHindi: '20 कॉइन'),
        QuestionOption(textEnglish: '50 Coins', textHindi: '50 कॉइन'),
        QuestionOption(textEnglish: '100 Coins', textHindi: '100 कॉइन'),
      ],
      correctAnswer: 1,
      explanationEnglish:
          'On Rankearn, 20 Coins equal ₹1.00 for withdrawal and test entries.',
    ),
  ];

  Future<void> _startQuiz(
    TestModel test, [
    List<QuestionModel>? customQuestions,
    Map<String, int>? initialAnswers,
    int? initialSecondsRemaining,
    int? initialIndex,
  ]) async {
    List<QuestionModel> questions = customQuestions ?? [];

    if (questions.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Loading questions...',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        final qRes = await TestsRepository().getQuestions(test.id);
        if (qRes is Success<List<QuestionModel>> && qRes.data.isNotEmpty) {
          questions = qRes.data;
        }
      } catch (e) {
        debugPrint('Error loading questions: $e');
      }

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (questions.isEmpty) {
      questions = (test.title.toLowerCase().contains('science') || test.id.contains('sci')
          ? TestResultModel.sampleGeneralScienceMock(
              studentName: _profile.name,
              photoUrl: _profile.profilePhotoUrl,
            ).questionItems.map((e) => e.question).toList()
          : _sampleQuestions);
    }

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          test: test,
          questions: questions,
          userProfile: _profile,
          initialAnswers: initialAnswers,
          initialSecondsRemaining: initialSecondsRemaining,
          initialIndex: initialIndex,
          onExit: () {
            Navigator.of(context).pop();
            if (mounted) setState(() {});
          },
          onSubmitted: (score, accuracy) {
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  void _openTestResult([TestResultModel? result]) {
    final res =
        result ??
        TestResultModel.sampleGeneralScienceMock(
          studentName: _profile.name,
          photoUrl: _profile.profilePhotoUrl,
        );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TestResultScreen(
          result: res,
          userProfile: _profile,
          userCoins: _profile.coins,
          onBackToTests: () => Navigator.of(context).pop(),
          onPracticeAgain: () {
            Navigator.of(context).pop();
            _startQuiz(_defaultMockTest);
          },
          onMoreTests: () {
            Navigator.of(context).pop();
            setState(() => _activeTab = UserNavTab.tests);
          },
          onNavTabSelected: (tab) {
            Navigator.of(context).pop();
            setState(() => _activeTab = tab);
          },
        ),
      ),
    );
  }


  void _openNotificationsModal() {
    setState(() => _unreadNotifications = 0);
    AppBottomSheet.show(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AppBottomSheet(
              showDragHandle: true,
              showCloseButton: false,
              scrollable: false,
              maxHeightRatio: 0.85,
              title: 'Notifications',
              subtitle: _notificationsList.isNotEmpty
                  ? '${_notificationsList.length} updates & alerts'
                  : 'All caught up',
              leadingIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: AppRadii.borderMd,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              headerTrailing: _notificationsList.isNotEmpty
                  ? InkWell(
                      onTap: () async {
                        await _clearAllNotifications();
                        setModalState(() {});
                      },
                      borderRadius: AppRadii.borderSm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: AppRadii.borderSm,
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cleaning_services_rounded, size: 14, color: AppColors.textSecondary),
                            SizedBox(width: 5),
                            Text(
                              'Clear All',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : null,
              bottomAction: null,
              child: _notificationsList.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text(
                              'No notifications',
                              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'You have cleared all alerts',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _notificationsList.length,
                      separatorBuilder: (_, _) => const Divider(
                        color: AppColors.borderSubtle,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                    final n = _notificationsList[index];
                    final title = n['title']?.toString() ?? 'Announcement';
                    final message = n['message']?.toString() ?? '';
                    final actionUrl = n['action_url']?.toString();
                    final rawActionLabel = n['action_label']?.toString().trim();
                    final actionLabel = (rawActionLabel != null && rawActionLabel.isNotEmpty) ? rawActionLabel : 'View';
                    final imageUrl = n['image_url']?.toString();
                    final notifId = n['id']?.toString() ?? '';
                    final isRead = n['is_read'] == true;
                    final type = n['type']?.toString() ?? 'alert';

                    IconData icon = Icons.notifications_rounded;
                    Color iconColor = AppColors.primary;
                    Color iconBg = AppColors.primarySubtle;

                    if (type == 'alert' || type == 'high') {
                      icon = Icons.campaign_rounded;
                      iconColor = const Color(0xFFD97706);
                      iconBg = const Color(0xFFFEF3C7);
                    } else if (type == 'system') {
                      icon = Icons.info_outline_rounded;
                      iconColor = const Color(0xFF2563EB);
                      iconBg = const Color(0xFFEFF6FF);
                    }

                    Widget leadingWidget;
                    if (imageUrl != null && imageUrl.isNotEmpty) {
                      leadingWidget = ClipRRect(
                        borderRadius: AppRadii.borderMd,
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              padding: const EdgeInsets.all(8),
                              color: iconBg,
                              child: Icon(icon, color: iconColor, size: 20),
                            ),
                          ),
                        ),
                      );
                    } else {
                      leadingWidget = Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: AppRadii.borderMd,
                        ),
                        child: Icon(icon, color: iconColor, size: 20),
                      );
                    }

                    return InkWell(
                      onTap: () {
                        _notificationsRepo.markRead(notifId, userId: _profile.id);
                        Navigator.pop(context);
                        InAppNotificationDialog.show(
                          context: context,
                          notification: n,
                          onAction: (url) {
                            _notificationsRepo.recordClick(notifId);
                            _handleNotificationUrl(url);
                          },
                        );
                      },
                      borderRadius: AppRadii.borderMd,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            leadingWidget,
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                                            fontSize: 14,
                                            color: AppColors.textPrimary,
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (!isRead) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (message.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      message,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        height: 1.35,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (actionUrl != null && actionUrl.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              AppButton(
                                label: actionLabel,
                                size: AppButtonSize.small,
                                variant: AppButtonVariant.primary,
                                onPressed: () {
                                  Navigator.pop(context);
                                  _notificationsRepo.recordClick(notifId);
                                  _handleNotificationUrl(actionUrl);
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
            );
          },
        );
      },
    );
  }

  void _openSupportDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => _UserSupportChatDialog(profile: _profile),
    );
  }

  void _openFeedbackDialog() {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: const [
                  Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
                  SizedBox(width: 8),
                  Text(
                    'Rate Your Experience',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'How would you rate your mock tests and study experience on Rankearn?',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNumber = index + 1;
                      final isSelected = starNumber <= selectedRating;
                      return IconButton(
                        icon: Icon(
                          isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 32,
                        ),
                        onPressed: () => setModalState(() => selectedRating = starNumber),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Share your suggestions or feature requests...',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final comment = commentController.text.trim();
                    Navigator.pop(dialogCtx);

                    final client = SupabaseConfig.clientSafe;
                    if (client != null) {
                      final currentAuthId = client.auth.currentUser?.id;
                      final targetUserId = (currentAuthId != null && currentAuthId.isNotEmpty)
                          ? currentAuthId
                          : _profile.id;

                      try {
                        await client.from('feedbacks').insert({
                          'id': 'fb_${DateTime.now().millisecondsSinceEpoch}',
                          'user_id': targetUserId,
                          'user_name': _profile.name,
                          'rating': selectedRating,
                          'comment': comment.isNotEmpty ? comment : 'Rated $selectedRating stars on Rankearn platform.',
                          'created_at': DateTime.now().toIso8601String(),
                        });
                      } catch (_) {}
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Thank you for rating us $selectedRating ⭐! Your feedback has been recorded.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Submit Feedback', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openAuthScreen({AuthScreenMode mode = AuthScreenMode.login}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserAuthScreen(
          initialMode: mode,
          onAuthSuccess: (profile) async {
            await AuthRepository().saveLocalProfile(profile);
            if (mounted) {
              setState(() {
                _profile = profile;
                _activeTab = UserNavTab.home;
              });
            }
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Welcome back, ${profile.name}!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _handleLogout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signed out successfully. Session closed.'),
        backgroundColor: Color(0xFFE11D48),
      ),
    );
    if (widget.onLogout != null) {
      widget.onLogout!();
    } else {
      _openAuthScreen(mode: AuthScreenMode.login);
    }
  }

  void _openBuyCoinsModal() {
    BuyCoinsModal.show(
      context,
      profile: _profile,
      onTopUpSubmitted: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF00B96B),
            content: Text('Top-up request submitted! Your coins will be credited within 2-5 minutes once verified by admin.'),
          ),
        );
      },
    );
  }

  void _navigateToTab(UserNavTab tab) {
    if (tab == UserNavTab.spin && !(_featureFlags['fortune_wheel'] ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Fortune Wheel is currently paused by administrator.'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }
    if (tab == UserNavTab.battle &&
        !(_featureFlags['1v1_battle'] ?? true) &&
        !(_featureFlags['multiplayer_battle'] ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Battle Arena is currently paused by administrator.'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }
    if ((tab == UserNavTab.tests || tab == UserNavTab.categories) &&
        !(_featureFlags['mock_test_series'] ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Mock Test Series are currently paused by administrator.'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }
    if ((tab == UserNavTab.live || tab == UserNavTab.tournament) &&
        !(_featureFlags['live_quiz'] ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Live Contests are currently paused by administrator.'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }
    setState(() => _activeTab = tab);
    if (tab == UserNavTab.wallet || tab == UserNavTab.home) {
      _syncProfileWithDatabase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPro = _profile.subscriptionStatus == 'premium';
    final isDesktop = MediaQuery.of(context).size.width >= 850;
    final isSpinTab = _activeTab == UserNavTab.spin && !isDesktop;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isSpinTab
          ? const SystemUiOverlayStyle(
              statusBarColor: Color(0xFF00B96B),
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
            )
          : const SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _buildDrawer(),
        appBar: isSpinTab
            ? null
            : AppHeader(
                coins: _profile.coins,
                userName: _profile.name,
                isPro: isPro,
                unreadNotifications: _unreadNotifications,
                showMenuButton: true,
                currentTab: _activeTab,
                onTabSelected: _navigateToTab,
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                onNotificationTap: _openNotificationsModal,
                onSupportTap: _openSupportDialog,
                onCoinsTap: () {
                  _navigateToTab(UserNavTab.wallet);
                },
                onAddCoinsTap: _openBuyCoinsModal,
                onProfileTap: () =>
                    _navigateToTab(UserNavTab.profile),
              ),
        bottomNavigationBar: isDesktop
            ? null
            : AppBottomNav(
                currentTab: _activeTab,
                onTabSelected: _navigateToTab,
              ),
        body: Column(
          children: [
            if (_isUnderMaintenance)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFFEF3C7),
                child: Row(
                  children: const [
                    Icon(Icons.build_rounded, size: 16, color: Color(0xFFD97706)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '⚠️ Maintenance Notice: Platform upgrades in progress. Some features may be temporarily limited.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: switch (_activeTab) {
          UserNavTab.home => DashboardScreen(
            profile: _profile,
            featureFlags: _featureFlags,
            onStartTest: () => _startQuiz(_defaultMockTest),
            onStartTestModel: (test) => _startQuiz(test),
            onResumeTest: (
              test, {
              customQuestions,
              initialAnswers,
              initialSecondsRemaining,
              initialIndex,
            }) {
              _startQuiz(
                test,
                customQuestions,
                initialAnswers,
                initialSecondsRemaining,
                initialIndex,
              );
            },
            onExploreTests: () => _navigateToTab(UserNavTab.tests),
            onJoinContest: () => _navigateToTab(UserNavTab.live),
            onSpinWheel: () => _navigateToTab(UserNavTab.spin),
            onOpenWallet: () => _navigateToTab(UserNavTab.wallet),
            onOpenBattle: () => _navigateToTab(UserNavTab.battle),
          ),
          UserNavTab.categories => TestSeriesScreen(
            userCoins: _profile.coins,
            userId: _profile.id,
            onStartTest: (test) => _startQuiz(test),
            initialTests: widget.initialTests,
            onOpenBattle: () => setState(() => _activeTab = UserNavTab.battle),
            onSpinWheel: () => setState(() => _activeTab = UserNavTab.spin),
            onOpenLive: () => setState(() => _activeTab = UserNavTab.live),
            onOpenWallet: () => setState(() => _activeTab = UserNavTab.wallet),
            onCoinDeducted: (fee) {
              setState(() {
                _profile = _profile.copyWith(
                  coins: (_profile.coins - fee).clamp(0, 999999999),
                );
              });
            },
            onOpenLeaderboard: () =>
                setState(() => _activeTab = UserNavTab.leaderboard),
            onViewLastResult: _openTestResult,
          ),
          UserNavTab.tests => TestSeriesScreen(
            userCoins: _profile.coins,
            userId: _profile.id,
            onStartTest: (test) => _startQuiz(test),
            initialTests: widget.initialTests,
            onOpenBattle: () => setState(() => _activeTab = UserNavTab.battle),
            onSpinWheel: () => setState(() => _activeTab = UserNavTab.spin),
            onOpenLive: () => setState(() => _activeTab = UserNavTab.live),
            onOpenWallet: () => setState(() => _activeTab = UserNavTab.wallet),
            onCoinDeducted: (fee) {
              setState(() {
                _profile = _profile.copyWith(
                  coins: (_profile.coins - fee).clamp(0, 999999999),
                );
              });
            },
            onOpenLeaderboard: () =>
                setState(() => _activeTab = UserNavTab.leaderboard),
            onViewLastResult: _openTestResult,
          ),
          UserNavTab.live || UserNavTab.earn => LiveTestsScreen(
            userCoins: _profile.coins,
            userId: _profile.id,
            onStartTest: (test) => _startQuiz(test),
            onOpenBattle: () => setState(() => _activeTab = UserNavTab.battle),
            onOpenLeaderboard: () =>
                setState(() => _activeTab = UserNavTab.leaderboard),
            onExploreSeries: () =>
                setState(() => _activeTab = UserNavTab.tests),
            onOpenWallet: () => setState(() => _activeTab = UserNavTab.wallet),
            onCoinDeducted: (fee) {
              setState(() {
                _profile = _profile.copyWith(coins: (_profile.coins - fee).clamp(0, 999999999));
              });
            },
          ),
          UserNavTab.leaderboard => LeaderboardScreen(
            profile: _profile,
            onOpenWallet: () => setState(() => _activeTab = UserNavTab.wallet),
            onOpenProfile: () =>
                setState(() => _activeTab = UserNavTab.profile),
            onOpenTests: () => setState(() => _activeTab = UserNavTab.tests),
            onOpenBattle: () => setState(() => _activeTab = UserNavTab.battle),
            onOpenRewards: () =>
                setState(() => _activeTab = UserNavTab.rewards),
          ),
          UserNavTab.battle => BattleHubScreen(
            userCoins: _profile.coins,
            profile: _profile,
            onCoinUpdate: (delta) {
              setState(() {
                _profile = _profile.copyWith(coins: _profile.coins + delta);
              });
            },
            onOpenWallet: () => setState(() => _activeTab = UserNavTab.wallet),
          ),
          UserNavTab.tournament => TournamentScreen(
            profile: _profile,
            onStartTest: (test) => _startQuiz(test),
            onOpenBattle: () => setState(() => _activeTab = UserNavTab.battle),
            onOpenLeaderboard: () =>
                setState(() => _activeTab = UserNavTab.leaderboard),
            onOpenRewards: () =>
                setState(() => _activeTab = UserNavTab.rewards),
            onCoinDeducted: (fee) {
              setState(() {
                _profile = _profile.copyWith(
                  coins: (_profile.coins - fee).clamp(0, 999999999),
                );
              });
            },
          ),
          UserNavTab.rewards => RewardsHubScreen(
            userCoins: _profile.coins,
            profile: _profile,
            onCoinUpdate: (delta) {
              setState(() {
                _profile = _profile.copyWith(coins: _profile.coins + delta);
              });
            },
            onOpenWallet: () => setState(() => _activeTab = UserNavTab.wallet),
            onOpenTests: () => setState(() => _activeTab = UserNavTab.tests),
            onOpenBattle: () => setState(() => _activeTab = UserNavTab.battle),
            onOpenSpinWheel: () => setState(() => _activeTab = UserNavTab.spin),
          ),
          UserNavTab.spin => LuckyWheelScreen(
            currentCoins: _profile.coins,
            userId: _profile.id,
            onBack: () => setState(() => _activeTab = UserNavTab.rewards),
            onRewardClaimed: (coinsWon) {
              setState(() {
                _profile = _profile.copyWith(coins: _profile.coins + coinsWon);
              });
            },
            onOpenWallet: () => setState(() => _activeTab = UserNavTab.wallet),
          ),
          UserNavTab.wallet => WalletScreen(
            profile: _profile,
            onCoinsUpdated: () => setState(() {}),
            onBuyCoins: _openBuyCoinsModal,
            onNavigateToTab: (tab) => setState(() => _activeTab = tab),
            onCoinUpdate: (delta) {
              setState(() {
                _profile = _profile.copyWith(coins: _profile.coins + delta);
              });
            },
          ),
          UserNavTab.profile => ProfileScreen(
            profile: _profile,
            onUpdateProfile: (updated) => setState(() => _profile = updated),
            onLogout: _handleLogout,
            onOpenSupport: _openSupportDialog,
            onOpenFeedback: _openFeedbackDialog,
            onNavigateToTab: (tab) => setState(() => _activeTab = tab),
          ),
        },
      ),
    ],
  ),
),
);
}

  // --- Slide-out Navigation Drawer matching React App.tsx:1150-1258 ---
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header with Rankearn Brand
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'R',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rankearn',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Learning with Earning',
                        style: TextStyle(
                          color: Colors.white.withAlpha(210),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable List of Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                children: [
                  _buildDrawerNavItem(
                    icon: Icons.home_rounded,
                    label: 'Home Dashboard',
                    tab: UserNavTab.home,
                  ),
                  if (_featureFlags['mock_test_series'] ?? true)
                    _buildDrawerNavItem(
                      icon: Icons.feed_outlined,
                      label: 'Test Series & Mocks',
                      tab: UserNavTab.tests,
                    ),
                  if (_featureFlags['live_quiz'] ?? true)
                    _buildDrawerNavItem(
                      icon: Icons.sensors_rounded,
                      label: 'Live Tests & Contests',
                      tab: UserNavTab.live,
                    ),
                  if ((_featureFlags['1v1_battle'] ?? true) || (_featureFlags['multiplayer_battle'] ?? true))
                    _buildDrawerNavItem(
                      icon: Icons.sports_kabaddi_rounded,
                      label: '1v1 Quiz Battle',
                      tab: UserNavTab.battle,
                    ),
                  if (_featureFlags['live_quiz'] ?? true)
                    _buildDrawerNavItem(
                      icon: Icons.emoji_events_rounded,
                      label: 'Live Contests',
                      tab: UserNavTab.tournament,
                    ),
                  _buildDrawerNavItem(
                    icon: Icons.emoji_events_outlined,
                    label: 'Leaderboard Rankings',
                    tab: UserNavTab.leaderboard,
                  ),
                  if ((_featureFlags['fortune_wheel'] ?? true) || (_featureFlags['referral_earn'] ?? true))
                    _buildDrawerNavItem(
                      icon: Icons.card_giftcard_rounded,
                      label: 'Fortune Wheel & Rewards',
                      tab: UserNavTab.rewards,
                    ),
                  _buildDrawerNavItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Wallet & Coins',
                    tab: UserNavTab.wallet,
                  ),
                  _buildDrawerNavItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Candidate Profile',
                    tab: UserNavTab.profile,
                  ),

                  const SizedBox(height: 12),
                  const Divider(),

                  // Stats Box (Matching React App.tsx:1186-1200)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.canvasDark,
                      borderRadius: AppRadii.borderMd,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.bolt,
                                  color: Color(0xFFF59E0B),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_profile.coins} Coins',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'LEVEL 4',
                                style: TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.68,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFF59E0B),
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'HELP & SUPPORT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),

                  _buildDrawerActionTile(
                    icon: Icons.chat_bubble_outline,
                    label: 'Support Chat',
                    onTap: () {
                      Navigator.pop(context);
                      _openSupportDialog();
                    },
                  ),
                  _buildDrawerActionTile(
                    icon: Icons.star_outline,
                    label: 'Give Feedback',
                    onTap: () {
                      Navigator.pop(context);
                      _openFeedbackDialog();
                    },
                  ),
                  _buildDrawerActionTile(
                    icon: Icons.mail_outline,
                    label: 'Contact Us',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reach us at support@rankearn.in'),
                        ),
                      );
                    },
                  ),
                  _buildDrawerActionTile(
                    icon: Icons.shield_outlined,
                    label: 'Privacy Policy',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening Platform Privacy Policy...'),
                        ),
                      );
                    },
                  ),
                  _buildDrawerActionTile(
                    icon: Icons.description_outlined,
                    label: 'Terms of Use',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening Terms of Use...'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Auth actions row at drawer bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.borderMd,
                    ),
                    leading: const Icon(
                      Icons.login_rounded,
                      color: AppColors.primary,
                    ),
                    title: const Text(
                      'Sign In / Switch Account',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _openAuthScreen(mode: AuthScreenMode.login);
                    },
                  ),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.borderMd,
                    ),
                    leading: const Icon(Icons.logout, color: Color(0xFFE11D48)),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE11D48),
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _handleLogout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerNavItem({
    required IconData icon,
    required String label,
    required UserNavTab tab,
  }) {
    final isSelected = _activeTab == tab;

    return ListTile(
      dense: true,
      selected: isSelected,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
      selectedTileColor: AppColors.primarySubtle,
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
          fontSize: 13,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        _navigateToTab(tab);
      },
    );
  }

  Widget _buildDrawerActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
      leading: Icon(icon, color: AppColors.textSecondary, size: 18),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _UserSupportChatDialog extends StatefulWidget {
  final UserProfile profile;
  const _UserSupportChatDialog({required this.profile});

  @override
  State<_UserSupportChatDialog> createState() => _UserSupportChatDialogState();
}

class _UserSupportChatDialogState extends State<_UserSupportChatDialog> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  StreamSubscription<List<Map<String, dynamic>>>? _messagesSub;
  List<Map<String, dynamic>> _messages = [];
  String? _activeTicketId;
  bool _isLoading = true;
  late final String _targetUserId;

  @override
  void initState() {
    super.initState();
    final client = SupabaseConfig.clientSafe;
    final currentAuthId = client?.auth.currentUser?.id;
    _targetUserId = (currentAuthId != null && currentAuthId.isNotEmpty)
        ? currentAuthId
        : widget.profile.id;

    _initChat();
  }

  Future<void> _initChat() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final ticketRes = await client
          .from('support_tickets')
          .select()
          .eq('user_id', _targetUserId)
          .order('last_updated', ascending: false)
          .limit(1)
          .maybeSingle();

      if (ticketRes != null) {
        _activeTicketId = ticketRes['id']?.toString();
        if (_activeTicketId != null) {
          _subscribeToMessages(_activeTicketId!);
          return;
        }
      }
    } catch (e) {
      debugPrint('Support initChat error: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _subscribeToMessages(String ticketId) {
    _messagesSub?.cancel();
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    _messagesSub = client
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true)
        .handleError((err) {
          debugPrint('User app support messages stream notice: $err');
        })
        .listen(
      (data) {
        if (!mounted) return;
        final updated = data.map<Map<String, dynamic>>((m) => <String, dynamic>{
          'isUser': m['role'] == 'user',
          'text': m['text']?.toString() ?? '',
          'time': m['created_at'] != null
              ? m['created_at'].toString().split('T').last.substring(0, 5)
              : '',
        }).toList();

        setState(() {
          _messages = updated;
          _isLoading = false;
        });

        _scrollToBottom();
      },
      onError: (err) {
        debugPrint('Support messages stream error: $err');
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final client = SupabaseConfig.clientSafe;
    final timeNow =
        '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages = [
        ..._messages,
        <String, dynamic>{
          'isUser': true,
          'text': text,
          'time': timeNow,
        },
      ];
    });
    _messageController.clear();
    _scrollToBottom();

    if (client != null) {
      try {
        final nowIso = DateTime.now().toIso8601String();
        final currentAuthId = client.auth.currentUser?.id;

        if (_activeTicketId == null) {
          _activeTicketId = 'tk_${DateTime.now().millisecondsSinceEpoch}';
          await client.from('support_tickets').insert({
            'id': _activeTicketId,
            'user_id': _targetUserId,
            'user_name': widget.profile.name,
            'user_email': widget.profile.email,
            'last_message': text,
            'status': 'open',
            'unread_count': 1,
            'created_at': nowIso,
            'last_updated': nowIso,
          });

          _subscribeToMessages(_activeTicketId!);
        } else {
          await client.from('support_tickets').update({
            'last_message': text,
            'status': 'open',
            'last_updated': nowIso,
          }).eq('id', _activeTicketId!);
        }

        await client.from('support_messages').insert({
          'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
          'ticket_id': _activeTicketId!,
          'sender_id': (currentAuthId != null && currentAuthId.isNotEmpty)
              ? currentAuthId
              : _targetUserId,
          'sender_name': widget.profile.name,
          'text': text,
          'role': 'user',
          'created_at': nowIso,
        });
      } catch (e) {
        debugPrint('Support sendMessage error: $e');
      }
    }
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        height: 520,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.support_agent_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Live Support Chat',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 16)),
                      Row(
                        children: [
                          Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF10B981))),
                          const SizedBox(width: 5),
                          const Text('Rankearn Helpdesk Online',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary))
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chat_bubble_outline_rounded,
                                  size: 40, color: AppColors.textMuted),
                              const SizedBox(height: 8),
                              Text(
                                'Hello ${widget.profile.name}! 👋',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Need help with tests, wallets, or payouts?\nSend a message below to start a live support ticket.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _messages.length,
                          itemBuilder: (context, idx) {
                            final m = _messages[idx];
                            final isUser = m['isUser'] == true;
                            return Align(
                              alignment: isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                constraints: const BoxConstraints(maxWidth: 320),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? AppColors.primary
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: isUser
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m['text'] ?? '',
                                      style: TextStyle(
                                        color: isUser
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                    if ((m['time'] ?? '').isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        m['time'] ?? '',
                                        style: TextStyle(
                                          color: isUser
                                              ? Colors.white70
                                              : Colors.black45,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: const TextStyle(fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
