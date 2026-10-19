import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'features/quiz/quiz_screen.dart';
import 'features/spin/lucky_wheel_screen.dart';
import 'features/battle/battle_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase initialization with safety fallback
  // In production, SUPABASE_URL and SUPABASE_ANON_KEY are passed via --dart-define
  runApp(
    const ProviderScope(
      child: RankearnUserApp(),
    ),
  );
}

class RankearnUserApp extends StatelessWidget {
  const RankearnUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rankearn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const UserAppShell(),
    );
  }
}

class UserAppShell extends StatefulWidget {
  const UserAppShell({super.key});

  @override
  State<UserAppShell> createState() => _UserAppShellState();
}

class _UserAppShellState extends State<UserAppShell> {
  UserNavTab _activeTab = UserNavTab.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        coins: 1450,
        userName: 'Vikram Singh',
        isPro: true,
        unreadNotifications: 2,
        onNotificationTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications Drawer (2 unread alerts)')),
          );
        },
        onCoinsTap: () => setState(() => _activeTab = UserNavTab.wallet),
        onProfileTap: () => setState(() => _activeTab = UserNavTab.profile),
      ),
      bottomNavigationBar: AppBottomNav(
        currentTab: _activeTab,
        onTabSelected: (tab) => setState(() => _activeTab = tab),
      ),
      body: switch (_activeTab) {
        UserNavTab.home => _buildDashboardView(),
        UserNavTab.tests => _buildTestsView(),
        UserNavTab.earn => _buildEarnView(),
        UserNavTab.spin => _buildSpinView(),
        UserNavTab.wallet => _buildWalletView(),
        UserNavTab.profile => _buildProfileView(),
      },
    );
  }

  // --- 1. Dashboard View ---
  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Carousel Simulation
          AppCard(
            padding: EdgeInsets.zero,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: AppRadii.borderLg,
                gradient: AppColors.brandGradient,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppProBadge(),
                  const SizedBox(height: 8),
                  const Text(
                    '70th BPSC Grand Mock League 🏆',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Win up to 5,000 Coins in the Live Tournament',
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Join Tournament Now →',
                    size: AppButtonSize.small,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => setState(() => _activeTab = UserNavTab.earn),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Stat Cards
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  label: 'Wallet Balance',
                  value: '1,450 Coins',
                  icon: Icons.monetization_on,
                  iconColor: AppColors.coinGold,
                  iconBgColor: AppColors.coinGoldLight,
                  onTap: () => setState(() => _activeTab = UserNavTab.wallet),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: AppStatCard(
                  label: 'Tests Completed',
                  value: '18 Attempts',
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Popular Test Series', style: AppTypography.titleLarge),
              TextButton(
                onPressed: () => setState(() => _activeTab = UserNavTab.tests),
                child: const Text('View All →'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Test Cards
          _buildTestCard(
            title: 'BPSC 70th Prelims Full Mock Test 1',
            examName: 'BPSC',
            questions: 150,
            durationMins: 120,
            negativeMark: '0.25',
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            title: 'SSC CGL Tier 1 Quantitative Practice',
            examName: 'SSC CGL',
            questions: 25,
            durationMins: 30,
            negativeMark: '0.50',
          ),
        ],
      ),
    );
  }

  // --- 2. Tests View ---
  Widget _buildTestsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Test Series Explorer', style: AppTypography.displayMedium),
          const SizedBox(height: 6),
          Text('Select from full mock tests, sectional, and previous years.', style: AppTypography.bodyMedium),
          const SizedBox(height: 16),
          const AppTextField(
            hintText: 'Search mock tests by topic or exam...',
            prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          _buildTestCard(
            title: 'UPSC Prelims GS Paper 1 Mock Exam',
            examName: 'UPSC CSE',
            questions: 100,
            durationMins: 120,
            negativeMark: '0.66',
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            title: 'Railway RRB NTPC General Awareness',
            examName: 'RRB',
            questions: 40,
            durationMins: 45,
            negativeMark: '0.33',
          ),
        ],
      ),
    );
  }

  // --- 3. Earn / Contests View ---
  Widget _buildEarnView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contests & Tournaments', style: AppTypography.displayMedium),
          const SizedBox(height: 4),
          Text('Compete in timed battles and win real coin prizes.', style: AppTypography.bodyMedium),
          const SizedBox(height: 16),

          // 1v1 Speed Battle Arena Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppStatusPill.active(label: 'Instant Match ⚔️'),
                    const AppCoinPill(coins: 20),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  '1v1 Speed Battle Arena',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Challenge random candidates in rapid 5-question live head-to-head quizzes.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Enter 1v1 Arena (Stake 20 Coins)',
                  variant: AppButtonVariant.secondary,
                  width: double.infinity,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BattleScreen(
                          onExit: () => Navigator.of(context).pop(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Live Tournament Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppStatusPill.active(label: 'Live Tournament'),
                    const AppCoinPill(coins: 20),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Daily Current Affairs Super League ⚡',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Prize Pool: 1,000 Coins • 58 Participants Joined',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Join Contest (20 Coins)',
                  width: double.infinity,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Joined Contest successfully!')),
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

  // --- 4. Spin / Lucky Wheel View ---
  Widget _buildSpinView() {
    return LuckyWheelScreen(
      currentCoins: 1450,
      onBack: () => setState(() => _activeTab = UserNavTab.home),
      onRewardClaimed: (coinsWon) {
        if (coinsWon > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('🎉 Credited $coinsWon Coins to your wallet!')),
          );
        }
      },
    );
  }

  // --- 5. Wallet View ---
  Widget _buildWalletView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet Emerald Master Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: AppRadii.borderXl,
              boxShadow: AppShadows.emeraldGlow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.monetization_on, color: AppColors.coinGold, size: 30),
                    SizedBox(width: 8),
                    Text('1,450', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
                    SizedBox(width: 8),
                    Text('Coins', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Equivalent Value: ₹72.50 (20 Coins = ₹1.00)', style: TextStyle(color: Colors.white60, fontSize: 11)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: '+ Top-up Coins',
                        variant: AppButtonVariant.secondary,
                        size: AppButtonSize.small,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('UPI QR Top-up Modal: Scan to pay and submit UTR')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        label: 'Withdraw (₹)',
                        variant: AppButtonVariant.outlined,
                        size: AppButtonSize.small,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Withdrawal Modal: Enter UPI ID or Bank Account')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Recent Transactions', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          _buildTransactionRow(title: 'Welcome Bonus 🎁', amount: '+10', isEarn: true, date: 'Today'),
          _buildTransactionRow(title: 'Daily Wheel Spin', amount: '+25', isEarn: true, date: 'Yesterday'),
          _buildTransactionRow(title: 'Tournament Join Fee', amount: '-20', isEarn: false, date: '2 days ago'),
        ],
      ),
    );
  }

  // --- 6. Profile View ---
  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingMobile),
      child: Column(
        children: [
          const Center(
            child: CircleAvatar(
              radius: 46,
              backgroundColor: AppColors.brandPrimaryLight,
              child: Icon(Icons.person, color: AppColors.brandPrimary, size: 48),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Vikram Singh', style: AppTypography.displayMedium),
          const SizedBox(height: 2),
          Text('vikram@example.com', style: AppTypography.bodySmall),
          const SizedBox(height: 6),
          const AppProBadge(),
          const SizedBox(height: 24),
          const AppTextField(label: 'Full Name', hintText: 'Vikram Singh'),
          const SizedBox(height: 12),
          const AppTextField(label: 'Target Exam', hintText: 'BPSC 70th CCE'),
          const SizedBox(height: 12),
          const AppTextField(label: 'State', hintText: 'Bihar'),
          const SizedBox(height: 24),
          AppButton(
            label: 'Save Profile Updates',
            width: double.infinity,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard({
    required String title,
    required String examName,
    required int questions,
    required int durationMins,
    required String negativeMark,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppStatusPill(label: examName, bg: AppColors.infoBlueLight, fg: AppColors.infoBlue),
              Text('$durationMins mins', style: AppTypography.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTypography.titleMedium),
          const SizedBox(height: 6),
          Text(
            '$questions Questions • -$negativeMark Negative Marking',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Start Test Now',
            width: double.infinity,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    test: TestModel(
                      id: 'test_demo_${examName.toLowerCase()}',
                      title: title,
                      categoryId: examName,
                      durationMinutes: durationMins,
                      totalQuestions: questions,
                      negativeMarking: double.tryParse(negativeMark) ?? 0.25,
                    ),
                    questions: [
                      const QuestionModel(
                        id: 'q_demo_1',
                        testId: 'test_demo_1',
                        questionNumber: 1,
                        questionTextEnglish: 'Which Mauryan ruler embraced Buddhism after the Kalinga War?',
                        questionTextHindi: 'कलिंग युद्ध के बाद किस मौर्य शासक ने बौद्ध धर्म अपनाया था?',
                        options: [
                          QuestionOption(textEnglish: 'Chandragupta Maurya', textHindi: 'चन्द्रगुप्त मौर्य'),
                          QuestionOption(textEnglish: 'Ashoka the Great', textHindi: 'महान अशोक'),
                          QuestionOption(textEnglish: 'Bindusara', textHindi: 'बिन्दुसार'),
                          QuestionOption(textEnglish: 'Brihadratha', textHindi: 'बृहद्रथ'),
                        ],
                        correctAnswer: 1,
                      ),
                      const QuestionModel(
                        id: 'q_demo_2',
                        testId: 'test_demo_1',
                        questionNumber: 2,
                        questionTextEnglish: 'What is the official currency of the Republic of India?',
                        questionTextHindi: 'भारत गणराज्य की आधिकारिक मुद्रा क्या है?',
                        options: [
                          QuestionOption(textEnglish: 'United States Dollar (USD)', textHindi: 'अमेरिकी डॉलर'),
                          QuestionOption(textEnglish: 'Indian Rupee (INR)', textHindi: 'भारतीय रुपया (INR)'),
                          QuestionOption(textEnglish: 'Japanese Yen (JPY)', textHindi: 'जापानी येन'),
                          QuestionOption(textEnglish: 'British Pound (GBP)', textHindi: 'ब्रिटिश पाउंड'),
                        ],
                        correctAnswer: 1,
                      ),
                    ],
                    onExit: () => Navigator.of(context).pop(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow({
    required String title,
    required String amount,
    required bool isEarn,
    required String date,
  }) {
    final color = isEarn ? AppColors.brandPrimary : AppColors.errorRose;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isEarn ? AppColors.brandPrimaryLight : AppColors.errorRoseLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isEarn ? Icons.arrow_downward : Icons.arrow_upward,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleSmall),
                  Text(date, style: AppTypography.bodySmall),
                ],
              ),
            ],
          ),
          Text(
            '$amount Coins',
            style: AppTypography.titleMedium.copyWith(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
