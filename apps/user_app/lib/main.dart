import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'features/quiz/quiz_screen.dart';
import 'features/spin/lucky_wheel_screen.dart';
import 'features/battle/battle_screen.dart';
import 'features/battle/battle_hub_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/tests/test_series_screen.dart';
import 'features/live/live_tests_screen.dart';
import 'features/earn/earn_screen.dart';
import 'features/wallet/wallet_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/rewards/rewards_hub_screen.dart';
import 'features/auth/user_auth_screen.dart';

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
      child: RankearnUserApp(showAuthInitially: true),
    ),
  );
}

class RankearnUserApp extends StatefulWidget {
  final List<TestModel>? initialTests;
  final bool showAuthInitially;

  const RankearnUserApp({
    super.key,
    this.initialTests,
    this.showAuthInitially = false,
  });

  @override
  State<RankearnUserApp> createState() => _RankearnUserAppState();
}

class _RankearnUserAppState extends State<RankearnUserApp> {
  late bool _showAuth;
  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _showAuth = widget.showAuthInitially;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rankearn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _showAuth
          ? UserAuthScreen(
              initialMode: AuthScreenMode.login,
              onAuthSuccess: (profile) {
                setState(() {
                  _currentUser = profile;
                  _showAuth = false;
                });
              },
            )
          : UserAppShell(
              initialTests: widget.initialTests,
              initialProfile: _currentUser,
              onLogout: () {
                setState(() {
                  _showAuth = true;
                  _currentUser = null;
                });
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
    _profile = widget.initialProfile ??
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
      questionTextEnglish: 'When was the state of Bihar carved out from the Bengal Presidency?',
      questionTextHindi: 'बिहार राज्य को बंगाल प्रेसीडेंसी से कब अलग किया गया था?',
      options: [
        QuestionOption(textEnglish: '1912', textHindi: '1912'),
        QuestionOption(textEnglish: '1905', textHindi: '1905'),
        QuestionOption(textEnglish: '1936', textHindi: '1936'),
        QuestionOption(textEnglish: '1947', textHindi: '1947'),
      ],
      correctAnswer: 0,
      explanationEnglish: 'Bihar was carved out of the Bengal Presidency on 22 March 1912 (celebrated as Bihar Diwas).',
    ),
    QuestionModel(
      id: 'q_02',
      testId: 'test_bpsc_01',
      questionNumber: 2,
      questionTextEnglish: 'Which river is historically known as the "Sorrow of Bihar"?',
      questionTextHindi: 'किस नदी को ऐतिहासिक रूप से "बिहार का शोक" कहा जाता है?',
      options: [
        QuestionOption(textEnglish: 'Gandak River', textHindi: 'गंडक नदी'),
        QuestionOption(textEnglish: 'Kosi River', textHindi: 'कोसी नदी'),
        QuestionOption(textEnglish: 'Son River', textHindi: 'सोन नदी'),
        QuestionOption(textEnglish: 'Ghaghara River', textHindi: 'घाघरा नदी'),
      ],
      correctAnswer: 1,
      explanationEnglish: 'The Kosi river is called the Sorrow of Bihar due to its frequent course shifts and devastating floods.',
    ),
    QuestionModel(
      id: 'q_03',
      testId: 'test_bpsc_01',
      questionNumber: 3,
      questionTextEnglish: 'What is the minimum age required to become the Governor of an Indian state?',
      questionTextHindi: 'भारत के किसी राज्य का राज्यपाल बनने के लिए न्यूनतम आयु क्या है?',
      options: [
        QuestionOption(textEnglish: '25 Years', textHindi: '25 वर्ष'),
        QuestionOption(textEnglish: '30 Years', textHindi: '30 वर्ष'),
        QuestionOption(textEnglish: '35 Years', textHindi: '35 वर्ष'),
        QuestionOption(textEnglish: '40 Years', textHindi: '40 वर्ष'),
      ],
      correctAnswer: 2,
      explanationEnglish: 'Under Article 157 of the Indian Constitution, the minimum age is 35 years.',
    ),
    QuestionModel(
      id: 'q_04',
      testId: 'test_bpsc_01',
      questionNumber: 4,
      questionTextEnglish: 'Who founded the Nalanda Mahavihara in ancient India?',
      questionTextHindi: 'प्राचीन भारत में नालंदा महाविहार की स्थापना किसने की थी?',
      options: [
        QuestionOption(textEnglish: 'Harshavardhana', textHindi: 'हर्षवर्धन'),
        QuestionOption(textEnglish: 'Kumaragupta I', textHindi: 'कुमारगुप्त प्रथम'),
        QuestionOption(textEnglish: 'Samudragupta', textHindi: 'समुद्रगुप्त'),
        QuestionOption(textEnglish: 'Ashoka', textHindi: 'अशोक'),
      ],
      correctAnswer: 1,
      explanationEnglish: 'Nalanda was founded during the 5th century CE by Gupta Emperor Kumaragupta I.',
    ),
    QuestionModel(
      id: 'q_05',
      testId: 'test_bpsc_01',
      questionNumber: 5,
      questionTextEnglish: 'In the Indian Rupee coin system on Rankearn, how many coins equal ₹1.00?',
      questionTextHindi: 'Rankearn के कॉइन सिस्टम में कितने कॉइन ₹1.00 के बराबर होते हैं?',
      options: [
        QuestionOption(textEnglish: '10 Coins', textHindi: '10 कॉइन'),
        QuestionOption(textEnglish: '20 Coins', textHindi: '20 कॉइन'),
        QuestionOption(textEnglish: '50 Coins', textHindi: '50 कॉइन'),
        QuestionOption(textEnglish: '100 Coins', textHindi: '100 कॉइन'),
      ],
      correctAnswer: 1,
      explanationEnglish: 'On Rankearn, 20 Coins equal ₹1.00 for withdrawal and test entries.',
    ),
  ];

  void _startQuiz(TestModel test) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          test: test,
          questions: _sampleQuestions,
          onExit: () => Navigator.of(context).pop(),
          onSubmitted: (score, accuracy) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Quiz submitted! Score: $score | Accuracy: ${accuracy.toStringAsFixed(1)}%'),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 4),
              ),
            );
          },
        ),
      ),
    );
  }

  void _startBattle([int entryFee = 100]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FindingOpponentScreen(
          userCoins: _profile.coins,
          profile: _profile,
          entryFee: entryFee,
          onCoinUpdate: (coinsWon) {
            setState(() {
              _profile = _profile.copyWith(coins: _profile.coins + coinsWon);
            });
          },
        ),
      ),
    );
  }

  void _openNotificationsModal() {
    setState(() => _unreadNotifications = 0);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.notifications_active, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Notifications', style: AppTypography.titleLarge),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: AppRadii.borderMd,
                  ),
                  child: const Icon(Icons.emoji_events, color: AppColors.primary),
                ),
                title: const Text('BPSC Grand League Winner!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('You won 250 Coins in the 70th BPSC Prelims Mega Contest.', style: TextStyle(fontSize: 12)),
                trailing: const Text('2h ago', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: AppRadii.borderMd,
                  ),
                  child: const Icon(Icons.bolt, color: Color(0xFFD97706)),
                ),
                title: const Text('Live Battle Challenge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('New 1v1 Arena is live with 2x coin multiplier.', style: TextStyle(fontSize: 12)),
                trailing: const Text('5h ago', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Mark All as Read',
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSupportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.chat_bubble_outline, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Support Chat', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Need help with mock tests, withdrawal verification, or tournament prize distribution?',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              SizedBox(height: 12),
              Text('📧 Email: support@rankearn.in\n💬 Telegram: @RankearnSupport\n⏰ Hours: 9:00 AM - 9:00 PM IST', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support ticket created. Our team will contact you shortly!')),
                );
              },
              child: const Text('Submit Ticket', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _openFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.star_outline, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Text('Give Feedback', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How would you rate your mock test experience on Rankearn?'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => const Icon(Icons.star, color: Color(0xFFF59E0B), size: 28)),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Any suggestions or feature requests...',
                  border: OutlineInputBorder(borderRadius: AppRadii.borderMd),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you for your valuable feedback!')),
                );
              },
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _openAuthScreen({AuthScreenMode mode = AuthScreenMode.login}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserAuthScreen(
          initialMode: mode,
          onAuthSuccess: (profile) {
            setState(() {
              _profile = profile;
              _activeTab = UserNavTab.home;
            });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back, ${profile.name}!'),
                backgroundColor: AppColors.primary,
              ),
            );
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

  @override
  Widget build(BuildContext context) {
    final isPro = _profile.subscriptionStatus == 'premium';
    final isDesktop = MediaQuery.of(context).size.width >= 850;
    final isSpinTab = _activeTab == UserNavTab.spin;

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
        drawer: isDesktop ? null : _buildDrawer(),
        appBar: isSpinTab
            ? null
            : AppHeader(
                coins: _profile.coins,
                userName: _profile.name,
                isPro: isPro,
                unreadNotifications: _unreadNotifications,
                showMenuButton: !isDesktop,
                currentTab: _activeTab,
                onTabSelected: (tab) => setState(() => _activeTab = tab),
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                onNotificationTap: _openNotificationsModal,
                onCoinsTap: () => setState(() => _activeTab = UserNavTab.wallet),
                onProfileTap: () => setState(() => _activeTab = UserNavTab.profile),
              ),
        bottomNavigationBar: isDesktop
            ? null
            : AppBottomNav(
                currentTab: _activeTab,
                onTabSelected: (tab) => setState(() => _activeTab = tab),
              ),
        body: switch (_activeTab) {
          UserNavTab.home => DashboardScreen(
              profile: _profile,
              onStartTest: () => _startQuiz(_defaultMockTest),
              onExploreTests: () => setState(() => _activeTab = UserNavTab.tests),
              onJoinContest: () => setState(() => _activeTab = UserNavTab.live),
              onSpinWheel: () => setState(() => _activeTab = UserNavTab.spin),
              onOpenWallet: () => setState(() => _activeTab = UserNavTab.wallet),
              onOpenBattle: () => setState(() => _activeTab = UserNavTab.battle),
            ),
        UserNavTab.tests => TestSeriesScreen(
            userCoins: _profile.coins,
            onStartTest: (test) => _startQuiz(test),
            initialTests: widget.initialTests,
            onOpenBattle: () => setState(() => _activeTab = UserNavTab.battle),
            onSpinWheel: () => setState(() => _activeTab = UserNavTab.spin),
            onOpenLive: () => setState(() => _activeTab = UserNavTab.live),
            onOpenLeaderboard: () => setState(() => _activeTab = UserNavTab.home),
          ),
        UserNavTab.live => LiveTestsScreen(
            userCoins: _profile.coins,
            onStartTest: (test) => _startQuiz(test),
            onOpenBattle: () => setState(() => _activeTab = UserNavTab.battle),
            onOpenLeaderboard: () => setState(() => _activeTab = UserNavTab.home),
            onExploreSeries: () => setState(() => _activeTab = UserNavTab.tests),
          ),
        UserNavTab.earn => EarnScreen(
            userCoins: _profile.coins,
            onOpenBattle: () => _startBattle(20),
            onJoinContest: (title, fee) => _startBattle(fee),
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
                        BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                children: [
                  _buildDrawerNavItem(
                    icon: Icons.home_rounded,
                    label: 'Home Dashboard',
                    tab: UserNavTab.home,
                  ),
                  _buildDrawerNavItem(
                    icon: Icons.feed_outlined,
                    label: 'Test Series & Mocks',
                    tab: UserNavTab.tests,
                  ),
                  _buildDrawerNavItem(
                    icon: Icons.sensors_rounded,
                    label: 'Live Tests & Contests',
                    tab: UserNavTab.live,
                  ),
                  _buildDrawerNavItem(
                    icon: Icons.sports_kabaddi_rounded,
                    label: '1v1 Quiz Battle',
                    tab: UserNavTab.battle,
                  ),
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
                                const Icon(Icons.bolt, color: Color(0xFFF59E0B), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${_profile.coins} Coins',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
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
                        const SnackBar(content: Text('Reach us at support@rankearn.in')),
                      );
                    },
                  ),
                  _buildDrawerActionTile(
                    icon: Icons.shield_outlined,
                    label: 'Privacy Policy',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening Platform Privacy Policy...')),
                      );
                    },
                  ),
                  _buildDrawerActionTile(
                    icon: Icons.description_outlined,
                    label: 'Terms of Use',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening Terms of Use...')),
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
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
                    leading: const Icon(Icons.login_rounded, color: AppColors.primary),
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
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
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
        setState(() => _activeTab = tab);
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
