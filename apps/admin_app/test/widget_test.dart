import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart' hide BattleType;
import 'package:data_layer/data_layer.dart';
import 'package:admin_app/main.dart';
import 'package:admin_app/features/overview/overview_tab.dart';
import 'package:admin_app/features/tests/tests_tab.dart';
import 'package:admin_app/features/tests/models/test_series_item.dart';
import 'package:admin_app/features/tests/widgets/subject_wise_chart_card.dart';
import 'package:admin_app/features/battle_dashboard/battle_dashboard_tab.dart';
import 'package:admin_app/features/battle_dashboard/models/battle_dashboard_models.dart';
import 'package:admin_app/features/battle_dashboard/services/battle_dashboard_service.dart';

void main() {
  testWidgets('QuizMaster Admin App renders header, welcome banner, and metrics', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify top header brand & badge
    expect(find.text('Rankearn'), findsOneWidget);
    expect(find.text('Admin Panel'), findsOneWidget);
    expect(find.text('Admin User'), findsOneWidget);
    expect(find.text('Super Admin'), findsOneWidget);

    // Verify Welcome Banner
    expect(find.textContaining('Welcome Back'), findsOneWidget);
    expect(find.textContaining('Admin! 👋'), findsOneWidget);

    // Verify Quick Actions
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Create Quiz'), findsOneWidget);
    expect(find.text('Add Question'), findsOneWidget);

    // Verify 5 Metric Cards
    expect(find.text('Total Users'), findsOneWidget);
    expect(find.text('Total Quizzes'), findsOneWidget);
    expect(find.text('Total Questions'), findsOneWidget);
    expect(find.text('Total Attempts'), findsOneWidget);
    expect(find.text('Active Live Quiz'), findsOneWidget);

    // Verify 3 Charts
    expect(find.text('Quiz Attempts Overview'), findsOneWidget);
    expect(find.text('User Growth'), findsOneWidget);
    expect(find.text('Category Wise Quizzes'), findsOneWidget);

    // Verify 4 Bottom Cards
    expect(find.text('Recent Quizzes'), findsOneWidget);
    expect(find.text('Recent Users'), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.text('Platform Status'), findsOneWidget);
  });

  testWidgets('Navigation pills switch tabs successfully', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Test Series tab
    final testSeriesPill = find.widgetWithText(InkWell, 'Test Series').first;
    await tester.tap(testSeriesPill);
    await tester.pumpAndSettle();

    expect(find.textContaining('Test Series List'), findsOneWidget);

    // Switch back to Dashboard
    final dashboardPill = find.widgetWithText(InkWell, 'Dashboard').first;
    await tester.tap(dashboardPill);
    await tester.pumpAndSettle();

    expect(find.text('Quiz Attempts Overview'), findsOneWidget);

    // Verify Header 'More' dropdown menu containing all tabs
    expect(find.text('More'), findsOneWidget);
    await tester.ensureVisible(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    expect(find.text('CORE MODULES'), findsOneWidget);
    expect(find.text('LIVE & COMMUNITY'), findsOneWidget);
    expect(find.text('Users Management'), findsOneWidget);
    expect(find.text('AI Test Creator'), findsAtLeastNWidgets(1));
    expect(find.text('Lucky Wheel'), findsAtLeastNWidgets(1));
  });

  testWidgets('Platform status honestly reports disconnected state without mock 99.9% fallback', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Connection Error'), findsOneWidget);
    expect(find.text('Database Connection'), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('99.9%'), findsNothing);
    expect(find.text('12,458'), findsNothing);
  });

  testWidgets('OverviewTab renders injected production snapshot cleanly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final snapshot = AdminDashboardSnapshot(
      usersMetric: const DashboardMetricSummary(
        total: 420,
        currentWeekCount: 18,
        previousWeekCount: 12,
        growthLabel: '+50%',
        isGrowthPositive: true,
        subtitle: '+18 this week',
        sparklineData: [2, 3, 1, 4, 2, 3, 3],
      ),
      quizzesMetric: const DashboardMetricSummary(
        total: 35,
        currentWeekCount: 4,
        previousWeekCount: 2,
        growthLabel: '+100%',
        isGrowthPositive: true,
        subtitle: '+4 this week',
        sparklineData: [0, 1, 0, 1, 1, 0, 1],
      ),
      questionsMetric: const DashboardMetricSummary(
        total: 1250,
        currentWeekCount: 90,
        previousWeekCount: 60,
        growthLabel: '+50%',
        isGrowthPositive: true,
        subtitle: '+90 this week',
        sparklineData: [10, 15, 12, 18, 10, 15, 10],
      ),
      attemptsMetric: const DashboardMetricSummary(
        total: 890,
        currentWeekCount: 45,
        previousWeekCount: 30,
        growthLabel: '+50%',
        isGrowthPositive: true,
        subtitle: '+45 this week',
        sparklineData: [5, 7, 6, 8, 5, 7, 7],
      ),
      activeLiveQuizzesCount: 2,
      activeLiveQuizzesSparkline: const [0, 1, 1, 0, 1, 1, 2],
      attemptsChart: const DashboardSeriesData(
        labels: ['Nov 05', 'Nov 06', 'Nov 07', 'Nov 08', 'Nov 09', 'Nov 10', 'Nov 11'],
        values: [12, 18, 9, 25, 14, 19, 22],
        highlightedIndex: 3,
        tooltipDate: 'Nov 08, 2026',
        tooltipValue: '25 attempts',
      ),
      userGrowthChart: const DashboardSeriesData(
        labels: ['Nov 05', 'Nov 06', 'Nov 07', 'Nov 08', 'Nov 09', 'Nov 10', 'Nov 11'],
        values: [3, 4, 2, 5, 1, 2, 1],
      ),
      totalCategoriesQuizzesCount: 35,
      categoryBreakdown: const [
        DashboardCategoryBreakdown(label: 'General Science', count: 20, percentage: 57.14, hexColor: '#3B82F6'),
        DashboardCategoryBreakdown(label: 'Mathematics', count: 15, percentage: 42.86, hexColor: '#8B5CF6'),
      ],
      recentQuizzes: [
        DashboardRecentQuiz(
          id: 't-1',
          title: 'Production Mock Test',
          subjectLabel: 'General Science',
          totalQuestions: 50,
          status: 'Published',
          isPublished: true,
          createdAt: DateTime(2026, 11, 11, 10, 0),
        ),
      ],
      recentUsers: [
        DashboardRecentUser(
          id: 'u-1',
          name: 'Aarav Mehta',
          email: 'aarav@rankearn.in',
          status: 'active',
          createdAt: DateTime(2026, 11, 11, 9, 30),
        ),
      ],
      recentActivities: [
        DashboardActivityEvent(
          id: 'a-1',
          type: DashboardActivityType.quizCreated,
          title: 'Quiz: Production Mock Test',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ],
      services: const [
        DashboardSystemService(name: 'Database (Profiles)', status: 'Operational', isHealthy: true, latencyMs: 42),
        DashboardSystemService(name: 'Quizzes & Question Bank', status: 'Operational', isHealthy: true, latencyMs: 38),
      ],
      apiLatencyMs: 42,
      fetchedAt: DateTime(2026, 11, 11, 18, 45),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OverviewTab(
            onGoToTests: () {},
            onGoToFinance: () {},
            onGoToUsers: () {},
            onGoToAiCreator: () {},
            onGoToNotifications: () {},
            initialSnapshot: snapshot,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('420'), findsOneWidget);
    expect(find.text('1,250'), findsOneWidget);
    expect(find.text('Production Mock Test'), findsOneWidget);
    expect(find.text('Aarav Mehta'), findsOneWidget);
    expect(find.text('All Systems Operational'), findsOneWidget);
    expect(find.text('42ms'), findsOneWidget);
    expect(find.text('2/2 Passed'), findsOneWidget);
  });

  testWidgets('AdminLoginScreen renders all visual elements from reference design', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(startLoggedIn: false),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Brand & Back to website
    expect(find.text('Back to Website'), findsOneWidget);
    expect(find.text('Admin Panel'), findsWidgets);

    // Verify Left Hero Section
    expect(find.text('LEARNING  •  PRACTICE  •  COMPETE  •  GROW'), findsOneWidget);
    expect(find.textContaining('Powerful Admin Panel'), findsOneWidget);
    expect(find.textContaining('Smarter Learning'), findsOneWidget);
    expect(
      find.text('Manage test series, questions, users, live quizzes, tournaments and track platform performance — all in one place.'),
      findsOneWidget,
    );

    // Verify 6 Feature Tiles
    expect(find.text('Test Series'), findsOneWidget);
    expect(find.text('Question Bank'), findsOneWidget);
    expect(find.text('User Management'), findsOneWidget);
    expect(find.text('Live Quiz & Tournaments'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Platform Settings'), findsOneWidget);

    // Verify 4 Statistics Cards
    expect(find.text('12,458'), findsOneWidget);
    expect(find.text('386'), findsOneWidget);
    expect(find.text('28,731'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Total Users'), findsOneWidget);
    expect(find.text('Total Quizzes'), findsOneWidget);
    expect(find.text('Total Attempts'), findsOneWidget);
    expect(find.text('Live Quiz'), findsOneWidget);

    // Verify Quote
    expect(find.text('“Better Quizzes. Brighter Futures.”'), findsOneWidget);
    expect(find.text('— Rankearn Admin Panel'), findsOneWidget);

    // Verify Right Login Card Elements
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to access your admin dashboard'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Sign In to Admin Panel'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Authorized Access Only'), findsOneWidget);
  });

  testWidgets('AdminLoginScreen blocks hardcoded bypass when offline and sign out returns to login', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(startLoggedIn: false),
      ),
    );
    await tester.pumpAndSettle();

    // Verify on login screen with empty (no hardcoded) input controllers
    expect(find.text('Sign In to Admin Panel'), findsOneWidget);
    final textFields = find.byType(TextFormField);
    expect(tester.widget<TextFormField>(textFields.at(0)).controller?.text, isEmpty);
    expect(tester.widget<TextFormField>(textFields.at(1)).controller?.text, isEmpty);

    // Enter credentials and submit while Supabase is uninitialized
    await tester.enterText(textFields.at(0), 'rankearnhelp@gmail.com');
    await tester.enterText(textFields.at(1), '123456');
    await tester.tap(find.text('Sign In to Admin Panel'));
    await tester.pumpAndSettle();

    // Verify honest error instead of hardcoded bypass
    expect(
      find.text('Database connection is not initialized. Please check Supabase configuration.'),
      findsOneWidget,
    );
    expect(find.text('Sign In to Admin Panel'), findsOneWidget);

    // Verify Sign Out returns to login screen from an active session
    await tester.pumpWidget(
      const ProviderScope(
        key: ValueKey('logged_in_app'),
        child: RankearnAdminApp(startLoggedIn: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Admin User'), findsOneWidget);
    await tester.tap(find.text('Admin User'));
    await tester.pumpAndSettle();
    expect(find.text('Sign Out'), findsOneWidget);
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    expect(find.text('Sign In to Admin Panel'), findsOneWidget);
  });

  testWidgets('Test Series Management screen renders reference layout and interactive controls', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(
          startLoggedIn: true,
          initialTab: AdminNavTab.tests,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Hero Card
    expect(find.textContaining('Test Series'), findsWidgets);
    expect(find.text('Management'), findsOneWidget);
    expect(find.text('Create, manage and organize test series for your platform.'), findsOneWidget);

    // 2. Verify Quick Actions
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Customize'), findsOneWidget);
    expect(find.text('Create\nTest Series'), findsOneWidget);
    expect(find.text('Add\nTest Paper'), findsOneWidget);
    expect(find.text('Manage\nSubjects'), findsOneWidget);
    expect(find.text('Import\nTests'), findsOneWidget);
    expect(find.text('AI Generate\nTest Series'), findsOneWidget);

    // 3. Verify 5 Metric Cards (zero fake mock growth %)
    expect(find.text('Total Test Series'), findsOneWidget);
    expect(find.text('Published'), findsWidgets);
    expect(find.text('Drafts'), findsOneWidget);
    expect(find.text('Total Tests'), findsWidgets);
    expect(find.text('Total Enrollments'), findsOneWidget);
    expect(find.text('+12%'), findsNothing);
    expect(find.text('+22%'), findsNothing);

    // 4. Verify Table Card & Honest Disconnected/Empty State (no hardcoded mock data)
    expect(find.textContaining('Test Series List'), findsOneWidget);
    expect(find.text('No test series found'), findsOneWidget);
    expect(find.text('RRB Technician Grade 3'), findsNothing);

    // 5. Verify Right Column (Subject Wise Donut Chart + Recent Activity)
    expect(find.text('Subject Wise Test Series'), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.text('No recent activity recorded'), findsOneWidget);
  });

  testWidgets('TestsTab renders real injected items and filters cleanly without dummy data', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final sampleItems = [
      TestSeriesItem(
        id: 'live-ts-1',
        title: 'BPSC Prelims Mock',
        description: 'Live DB syllabus',
        subject: 'General Science',
        totalTests: 10,
        totalQuestions: 150,
        priceInr: 99,
        enrollments: 42,
        status: TestSeriesStatus.published,
        createdAt: DateTime.now(),
        icon: Icons.science_rounded,
        iconColor: const Color(0xFF6366F1),
      ),
      TestSeriesItem(
        id: 'live-ts-2',
        title: 'Quantitative Draft Set',
        description: 'Arithmetic draft',
        subject: 'Mathematics',
        totalTests: 5,
        totalQuestions: 50,
        priceInr: 0,
        enrollments: 0,
        status: TestSeriesStatus.draft,
        createdAt: DateTime.now(),
        icon: Icons.calculate_rounded,
        iconColor: const Color(0xFFF43F5E),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TestsTab(initialItems: sampleItems),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BPSC Prelims Mock'), findsOneWidget);
    expect(find.text('Quantitative Draft Set'), findsOneWidget);
    expect(find.text('Test Series List (2)'), findsOneWidget);
    expect(find.text('42'), findsNWidgets(2));
  });

  testWidgets('SubjectWiseChartCard loading state inside SingleChildScrollView does not throw RenderFlex error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SubjectWiseChartCard(
                  isLoading: true,
                  slices: [],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Mobile layout renders Bottom Navigation Bar and Drawer', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(
          startLoggedIn: true,
          initialTab: AdminNavTab.tests,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Mobile Bottom Navigation Bar items
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Test Series'), findsWidgets);
    expect(find.text('Questions'), findsWidgets);
    expect(find.text('Users'), findsWidgets);
    expect(find.text('Menu'), findsOneWidget);

    // Verify Hamburger Menu button
    expect(find.byIcon(Icons.menu_rounded), findsWidgets);

    // Tap Hamburger button to open Drawer
    await tester.tap(find.byTooltip('Open Menu').first);
    await tester.pumpAndSettle();

    // Verify Drawer content
    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('CORE MODULES'), findsOneWidget);
    expect(find.text('LIVE & GAMIFICATION'), findsOneWidget);
    expect(find.text('Admin User'), findsWidgets);
    expect(find.text('Super Admin'), findsWidgets);
  });

  testWidgets('Questions Management screen renders reference layout, metrics, table, and charts', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(
          startLoggedIn: true,
          initialTab: AdminNavTab.battleQs,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Top Navigation Questions Tab is Active
    expect(find.text('Questions'), findsWidgets);

    // 2. Verify Hero Card
    expect(find.text('Questions Management'), findsOneWidget);
    expect(find.text('Create, manage and organize questions for your platform.'), findsOneWidget);
    expect(find.text('Keep your question bank updated with high quality content.'), findsOneWidget);

    // 3. Verify Quick Actions (6 actions + Customize)
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Customize'), findsOneWidget);
    expect(find.text('Add\nQuestion'), findsOneWidget);
    expect(find.text('Import\nQuestions'), findsOneWidget);
    expect(find.text('AI Generate\nQuestions'), findsOneWidget);
    expect(find.text('Manage\nQuestion Sets'), findsOneWidget);
    expect(find.text('Duplicate\nQuestions'), findsOneWidget);
    expect(find.text('Bulk\nActions'), findsOneWidget);

    // 4. Verify 5 Metric Cards
    expect(find.text('Total Questions'), findsOneWidget);
    expect(find.text('9,842'), findsWidgets); // metric + list title + chart center
    expect(find.text('Active Questions'), findsOneWidget);
    expect(find.text('8,936'), findsOneWidget);
    expect(find.text('Draft Questions'), findsOneWidget);
    expect(find.text('542'), findsOneWidget);
    expect(find.text('Archived Questions'), findsOneWidget);
    expect(find.text('364'), findsOneWidget);
    expect(find.text('Question Sets'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);

    // 5. Verify Questions Table Card & Filters
    expect(find.textContaining('Questions List'), findsOneWidget);
    expect(find.text('All Test Series'), findsOneWidget);
    expect(find.text('All Subjects'), findsOneWidget);
    expect(find.text('All Types'), findsOneWidget);
    expect(find.text('All Difficulty'), findsOneWidget);
    expect(find.text('Search questions...'), findsOneWidget);
    expect(find.text('Filters'), findsOneWidget);

    // 6. Verify Reference Question Rows
    expect(find.text('What is the SI unit of force?'), findsOneWidget);
    expect(find.text('The capital of Australia is?'), findsOneWidget);
    expect(find.textContaining('Find the missing number'), findsWidgets);
    expect(find.textContaining('Which gas is known as'), findsOneWidget);
    expect(find.text('Who discovered the cell?'), findsOneWidget);
    expect(find.textContaining('Select the odd one out'), findsOneWidget);
    expect(find.textContaining('Right to Education'), findsOneWidget);

    // 7. Verify Pagination
    expect(find.text('Showing 1 to 7 of 9,842 questions'), findsOneWidget);
    expect(find.text('1,406'), findsOneWidget);

    // 8. Verify Right Analytics Column
    expect(find.text('Question Type Distribution'), findsOneWidget);
    expect(find.text('MCQ'), findsWidgets);
    expect(find.text('68%'), findsOneWidget);
    expect(find.text('True/False'), findsOneWidget);
    expect(find.text('12%'), findsOneWidget);
    expect(find.text('Fill in the Blanks'), findsOneWidget);
    expect(find.text('8%'), findsOneWidget);
    expect(find.text('Match the Following'), findsOneWidget);
    expect(find.text('6%'), findsOneWidget);
    expect(find.text('Assertion & Reason'), findsOneWidget);
    expect(find.text('4%'), findsOneWidget);
    expect(find.text('Subjective'), findsOneWidget);
    expect(find.text('2%'), findsOneWidget);

    // 9. Verify Difficulty Wise Questions
    expect(find.text('Difficulty Wise Questions'), findsOneWidget);
    expect(find.text('3,624'), findsOneWidget);
    expect(find.text('4,128'), findsOneWidget);
    expect(find.text('1,680'), findsOneWidget);
    expect(find.text('410'), findsOneWidget);

    // 10. Verify Recent Activity
    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.text('New question added: What is the SI unit of force?'), findsOneWidget);
    expect(find.text('Question updated: Find the missing number?'), findsOneWidget);
    expect(find.text('50 questions imported from CSV'), findsOneWidget);
    expect(find.text('Question archived: Old current affairs set'), findsOneWidget);
  });

  testWidgets('Questions Management interactive dialogs open and dismiss correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(
          startLoggedIn: true,
          initialTab: AdminNavTab.battleQs,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Test Add Question dialog
    await tester.tap(find.text('Add\nQuestion'));
    await tester.pumpAndSettle();
    expect(find.text('Create Question'), findsOneWidget);
    expect(find.text('Question Text (English) *'), findsOneWidget);
    expect(find.text('Answer Options (Select the correct answer button)'), findsOneWidget);
    // Dismiss
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Create Question'), findsNothing);

    // 2. Test Import Questions dialog
    await tester.tap(find.text('Import\nQuestions'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Import Questions'), findsWidgets);
    expect(find.text('Validate & Parse Data'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Validate & Parse Data'), findsNothing);

    // 3. Test AI Generate Questions dialog
    await tester.tap(find.text('AI Generate\nQuestions'));
    await tester.pumpAndSettle();
    expect(find.text('AI Question Generator'), findsOneWidget);
    expect(find.text('Generate Questions with AI'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('AI Question Generator'), findsNothing);

    // 4. Test Manage Question Sets dialog
    await tester.tap(find.text('Manage\nQuestion Sets'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Manage Question Sets'), findsWidgets);
    expect(find.text('Create New Question Set'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Create New Question Set'), findsNothing);

    // 5. Test Bulk Actions dialog (select a question first)
    final tableCheckbox = find.byType(Checkbox).first;
    await tester.tap(tableCheckbox);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bulk\nActions'));
    await tester.pumpAndSettle();
    expect(find.text('Bulk Actions'), findsWidgets);
    expect(find.text('Apply Action'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Apply Action'), findsNothing);
  });

  testWidgets('Categories Management screen renders hero, quick actions, 5 metric cards, table, donut chart, bar chart, and recent activity', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(
          startLoggedIn: true,
          initialTab: AdminNavTab.patterns,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Top Navigation Pill active state
    expect(find.widgetWithText(InkWell, 'Categories'), findsOneWidget);

    // 2. Verify Hero Banner
    expect(find.textContaining('Categories'), findsWidgets);
    expect(find.textContaining('Management'), findsWidgets);
    expect(find.textContaining('Create, manage and organize categories for your platform.'), findsOneWidget);

    // 3. Verify Quick Actions (6 buttons)
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Add\nCategory'), findsOneWidget);
    expect(find.text('Import\nCategories'), findsOneWidget);
    expect(find.text('Manage\nSubcategories'), findsOneWidget);
    expect(find.text('Reorder\nCategories'), findsOneWidget);
    expect(find.text('Duplicate\nCategory'), findsOneWidget);
    expect(find.text('Bulk\nActions'), findsOneWidget);

    // 4. Verify 5 Metric Cards
    expect(find.text('Total Categories'), findsOneWidget);
    expect(find.text('48'), findsWidgets);
    expect(find.text('Active Categories'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Draft Categories'), findsOneWidget);
    expect(find.text('4'), findsWidgets);
    expect(find.text('Archived Categories'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(find.text('Total Subjects'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);

    // 5. Verify Categories Table Card Header
    expect(find.textContaining('Categories List (48)'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Filters'), findsOneWidget);

    // 6. Verify Table Content
    expect(find.text('Competitive Exams'), findsWidgets);
    expect(find.text('School Education'), findsWidgets);
    expect(find.text('State Level Exams'), findsWidgets);
    expect(find.text('Entrance Exams'), findsWidgets);
    expect(find.text('Skill Development'), findsWidgets);
    expect(find.text('General Awareness'), findsWidgets);
    expect(find.text('Practice & Mock Tests'), findsWidgets);

    // 7. Verify Pagination Footer
    expect(find.text('Showing 1 to 7 of 48 categories'), findsOneWidget);

    // 8. Verify Right Column: Category Wise Test Series Donut Chart
    expect(find.text('Category Wise Test Series'), findsOneWidget);
    expect(find.text('320'), findsWidgets);

    // 9. Verify Right Column: Top Categories by Questions Bar Chart
    expect(find.text('Top Categories by Questions'), findsOneWidget);
    expect(find.text('4,850'), findsWidgets);
    expect(find.text('3,420'), findsWidgets);

    // 10. Verify Right Column: Recent Activity
    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.text('New category created: Skill Development'), findsOneWidget);
    expect(find.text('Category updated: General Awareness'), findsOneWidget);
    expect(find.text('Subject added to Competitive Exams'), findsOneWidget);
    expect(find.text('Category archived: Practice & Mock Tests'), findsOneWidget);
  });

  testWidgets('Categories Management interactive dialogs open and dismiss correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(
          startLoggedIn: true,
          initialTab: AdminNavTab.patterns,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Test Add Category dialog
    await tester.tap(find.text('Add\nCategory'));
    await tester.pumpAndSettle();
    expect(find.text('Create Category'), findsWidgets);
    expect(find.text('Category Name *'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Category Name *'), findsNothing);

    // 2. Test Import Categories dialog
    await tester.tap(find.text('Import\nCategories'));
    await tester.pumpAndSettle();
    expect(find.text('Import Categories (CSV / JSON)'), findsOneWidget);
    expect(find.text('Validate & Parse Data'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Import Categories (CSV / JSON)'), findsNothing);

    // 3. Test Manage Subcategories dialog
    await tester.tap(find.text('Manage\nSubcategories'));
    await tester.pumpAndSettle();
    expect(find.text('Manage Subcategories'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Manage Subcategories'), findsNothing);

    // 4. Test Reorder Categories dialog
    await tester.tap(find.text('Reorder\nCategories'));
    await tester.pumpAndSettle();
    expect(find.text('Reorder Categories'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Reorder Categories'), findsNothing);

    // 5. Test Bulk Actions dialog
    final tableCheckbox = find.byType(Checkbox).first;
    await tester.tap(tableCheckbox);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bulk\nActions'));
    await tester.pumpAndSettle();
    expect(find.text('Bulk Actions'), findsWidgets);
    expect(find.text('Apply Action'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Apply Action'), findsNothing);
  });

  testWidgets('Users Management tab renders hero, quick actions, metric cards, table, and right analytics', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(
          startLoggedIn: true,
          initialTab: AdminNavTab.users,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Hero Card
    expect(find.text('Users Management'), findsWidgets);
    expect(find.textContaining('Manage platform users, view their activity'), findsOneWidget);
    expect(find.textContaining('Keep your user base engaged and growing.'), findsOneWidget);

    // 2. Verify 6 Quick Actions
    expect(find.text('Add\nUser'), findsOneWidget);
    expect(find.text('Import\nUsers'), findsOneWidget);
    expect(find.text('Manage\nRoles'), findsOneWidget);
    expect(find.text('Send\nNotification'), findsOneWidget);
    expect(find.text('Export\nUsers'), findsOneWidget);
    expect(find.text('Bulk\nActions'), findsOneWidget);

    // 3. Verify 5 Metric Cards
    expect(find.text('Total Users'), findsOneWidget);
    expect(find.text('Active Users'), findsOneWidget);
    expect(find.text('New Users (This Month)'), findsOneWidget);
    expect(find.text('Inactive Users'), findsOneWidget);
    expect(find.text('Premium Users'), findsOneWidget);

    // 4. Verify Users List Table Header & Sample Users
    expect(find.textContaining('Users List'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsOneWidget);
    expect(find.text('rahul.sharma@example.com'), findsOneWidget);
    expect(find.text('Priya Verma'), findsOneWidget);
    expect(find.text('priya.verma@example.com'), findsOneWidget);
    expect(find.text('Amit Kumar'), findsOneWidget);

    // 5. Verify Right Analytics Column
    expect(find.text('Role Wise Users'), findsOneWidget);
    expect(find.text('User Growth (Last 7 Days)'), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.textContaining('New user registered:'), findsOneWidget);
    expect(find.textContaining('User upgraded to premium:'), findsOneWidget);
  });

  testWidgets('Users Management search and filtering work correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(
          startLoggedIn: true,
          initialTab: AdminNavTab.users,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Search for Amit
    final searchInput = find.byType(TextField).first;
    await tester.enterText(searchInput, 'Amit');
    await tester.pumpAndSettle();

    expect(find.text('Amit Kumar'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsNothing);

    // Clear search
    await tester.enterText(searchInput, '');
    await tester.pumpAndSettle();

    expect(find.text('Rahul Sharma'), findsOneWidget);
  });

  testWidgets('Users Management interactive dialogs open and dismiss correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(
          startLoggedIn: true,
          initialTab: AdminNavTab.users,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Test Add User dialog
    await tester.tap(find.text('Add\nUser'));
    await tester.pumpAndSettle();
    expect(find.text('Add New User'), findsOneWidget);
    expect(find.text('Full Name *'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Add New User'), findsNothing);

    // 2. Test Import Users dialog
    await tester.tap(find.text('Import\nUsers'));
    await tester.pumpAndSettle();
    expect(find.text('Import Users (CSV / JSON)'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Import Users (CSV / JSON)'), findsNothing);

    // 3. Test Manage Roles dialog
    await tester.tap(find.text('Manage\nRoles'));
    await tester.pumpAndSettle();
    expect(find.text('Roles & Permissions Matrix'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Roles & Permissions Matrix'), findsNothing);

    // 4. Test Send Notification dialog
    await tester.tap(find.text('Send\nNotification'));
    await tester.pumpAndSettle();
    expect(find.text('Send Broadcast Notification'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Send Broadcast Notification'), findsNothing);

    // 5. Test Export Users dialog
    await tester.tap(find.text('Export\nUsers'));
    await tester.pumpAndSettle();
    expect(find.text('Export Users Dataset'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Export Users Dataset'), findsNothing);

    // 6. Test View User dialog from table action
    final viewBtn = find.byIcon(Icons.visibility_outlined).first;
    await tester.tap(viewBtn);
    await tester.pumpAndSettle();
    expect(find.text('Enrollments'), findsWidgets);
    expect(find.text('Done'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsNothing);
  });

  testWidgets('Live Quiz Management tab renders hero, quick actions, 5 metric cards, table, and analytics', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(
          startLoggedIn: true,
          initialTab: AdminNavTab.contests,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Top Navigation Pill active state
    expect(find.widgetWithText(InkWell, 'Live Quiz'), findsOneWidget);

    // 2. Verify Hero Banner
    expect(find.text('Live Quiz '), findsOneWidget);
    expect(find.text('Management'), findsWidgets);
    expect(find.text('Create, manage and conduct live quiz sessions for your platform.'), findsOneWidget);
    expect(find.text('LIVE'), findsOneWidget);

    // 3. Verify Quick Actions
    expect(find.text('Create\nLive Quiz'), findsOneWidget);
    expect(find.text('Schedule\nQuiz'), findsOneWidget);
    expect(find.text('Manage\nQuestions'), findsOneWidget);
    expect(find.text('Live Now\nDashboard'), findsOneWidget);
    expect(find.text('Send\nNotification'), findsOneWidget);
    expect(find.text('Export\nReports'), findsOneWidget);

    // 4. Verify 5 Metric Cards
    expect(find.text('Total Live Quiz'), findsOneWidget);
    expect(find.text('Total Participants'), findsOneWidget);
    expect(find.text('Completed Quiz'), findsOneWidget);
    expect(find.text('Ongoing Quiz'), findsOneWidget);
    expect(find.text('Total Rewards Given'), findsOneWidget);

    // 5. Verify Table Card & Content
    expect(find.textContaining('Live Quiz List'), findsOneWidget);
    expect(find.text('RRB Technician Mega Quiz'), findsOneWidget);
    expect(find.text('General Science Live Quiz'), findsOneWidget);
    expect(find.text('Maths Challenge Live'), findsOneWidget);
    expect(find.text('Current Affairs Live Quiz'), findsOneWidget);
    expect(find.text('Live Now'), findsOneWidget);

    // 6. Verify Right Column Analytics Cards
    expect(find.text('Quiz Category Distribution'), findsOneWidget);
    expect(find.text('Participants Trend (Last 7 Days)'), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.text('128'), findsWidgets);

    // 7. Test Create Live Quiz dialog
    await tester.tap(find.text('Create\nLive Quiz'));
    await tester.pumpAndSettle();
    expect(find.text('Quiz Title'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Quiz Title'), findsNothing);

    // 8. Test Schedule Quiz dialog
    await tester.tap(find.text('Schedule\nQuiz'));
    await tester.pumpAndSettle();
    expect(find.text('Schedule Live Quiz'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Schedule Live Quiz'), findsNothing);

    // 9. Test Live Now Dashboard dialog
    await tester.tap(find.text('Live Now\nDashboard'));
    await tester.pumpAndSettle();
    expect(find.text('LIVE NOW'), findsOneWidget);
    expect(find.text('Connected Users'), findsOneWidget);
    expect(find.text('Serving Question'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Serving Question'), findsNothing);
  });

  testWidgets('Tournaments Management tab renders hero, quick actions, 5 metric cards, table, and analytics', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(
          startLoggedIn: true,
          initialTab: AdminNavTab.leaderboard,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Active Tab
    expect(find.text('Tournaments'), findsWidgets);

    // 2. Verify Hero Banner
    expect(find.text('Tournaments '), findsOneWidget);
    expect(find.text('Management'), findsWidgets);
    expect(find.text('Create and manage quiz tournaments for your platform.'), findsOneWidget);

    // 3. Verify 6 Quick Actions
    expect(find.text('Create\nTournament'), findsOneWidget);
    expect(find.text('Schedule\nTournament'), findsOneWidget);
    expect(find.text('Manage\nRewards'), findsOneWidget);
    expect(find.text('View\nRegistrations'), findsOneWidget);
    expect(find.text('Send\nNotification'), findsOneWidget);
    expect(find.text('Export\nReport'), findsOneWidget);

    // 4. Verify 5 Metric Cards
    expect(find.text('Total Tournaments'), findsOneWidget);
    expect(find.text('Total Participants'), findsOneWidget);
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('Ongoing'), findsWidgets);
    expect(find.text('Upcoming'), findsWidgets);

    // 5. Verify Table Card & Content
    expect(find.textContaining('Tournaments List'), findsOneWidget);
    expect(find.text('RRB Technician Grand Quiz'), findsOneWidget);
    expect(find.text('General Science Champion'), findsOneWidget);
    expect(find.text('Maths Master Tournament'), findsOneWidget);
    expect(find.text('Current Affairs Cup'), findsOneWidget);
    expect(find.text('Bihar State Mega Quiz'), findsOneWidget);

    // 6. Verify Right Column Analytics Cards
    expect(find.text('Tournament Category Distribution'), findsOneWidget);
    expect(find.text('Participants Trend (Last 7 Days)'), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);

    // 7. Test Create Tournament dialog
    await tester.tap(find.text('Create\nTournament'));
    await tester.pumpAndSettle();
    expect(find.text('Tournament Title *'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Tournament Title *'), findsNothing);

    // 8. Test Manage Rewards dialog
    await tester.tap(find.text('Manage\nRewards'));
    await tester.pumpAndSettle();
    expect(find.text('Prize Pool & Rewards'), findsOneWidget);
    expect(find.text('Rank 1'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Prize Pool & Rewards'), findsNothing);

    // 9. Test View Registrations dialog
    await tester.tap(find.text('View\nRegistrations'));
    await tester.pumpAndSettle();
    expect(find.text('All Tournament Registrations'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('All Tournament Registrations'), findsNothing);
  });

  testWidgets('Payments Management tab renders hero, quick actions, 5 metric cards, table, and analytics', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(
          startLoggedIn: true,
          initialTab: AdminNavTab.finance,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Active Tab
    expect(find.text('Payments'), findsWidgets);

    // 2. Verify Hero Banner
    expect(find.text('Payments '), findsOneWidget);
    expect(find.text('Management'), findsWidgets);
    expect(find.text('Track and manage all platform payments, transactions and revenue.'), findsOneWidget);

    // 3. Verify 6 Quick Actions
    expect(find.text('View\nTransactions'), findsOneWidget);
    expect(find.text('Process\nRefund'), findsOneWidget);
    expect(find.text('Subscription\nManagement'), findsOneWidget);
    expect(find.text('Payout\nReports'), findsOneWidget);
    expect(find.text('Export\nPayments'), findsOneWidget);
    expect(find.text('Payment\nSettings'), findsOneWidget);

    // 4. Verify 5 Metric Cards
    expect(find.text('Total Revenue'), findsOneWidget);
    expect(find.text('Total Transactions'), findsOneWidget);
    expect(find.text('Successful Payments'), findsOneWidget);
    expect(find.text('Failed Payments'), findsOneWidget);
    expect(find.text('Pending Payments'), findsOneWidget);

    // 5. Verify Table Card & Content
    expect(find.textContaining('Payments List'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsOneWidget);
    expect(find.text('Priya Verma'), findsOneWidget);
    expect(find.text('Amit Kumar'), findsOneWidget);
    expect(find.text('Neha Singh'), findsOneWidget);
    expect(find.text('Vikash Yadav'), findsOneWidget);

    // 6. Verify Right Column Analytics Cards
    expect(find.text('Payment Method Distribution'), findsOneWidget);
    expect(find.text('Revenue Trend (Last 7 Days)'), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);

    // 7. Test Process Refund dialog
    await tester.tap(find.text('Process\nRefund'));
    await tester.pumpAndSettle();
    expect(find.text('Process Refund'), findsWidgets);
    expect(find.text('Full Refund'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Full Refund'), findsNothing);

    // 8. Test Subscription Management dialog
    await tester.tap(find.text('Subscription\nManagement'));
    await tester.pumpAndSettle();
    expect(find.text('Subscription Management'), findsWidgets);
    expect(find.text('Monthly MRR'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Monthly MRR'), findsNothing);

    // 9. Test Payout Reports dialog
    await tester.tap(find.text('Payout\nReports'));
    await tester.pumpAndSettle();
    expect(find.text('Payout & Settlement Reports'), findsOneWidget);
    expect(find.text('Gross Transaction Volume'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Gross Transaction Volume'), findsNothing);

    // 10. Test Payment Settings dialog
    await tester.tap(find.text('Payment\nSettings'));
    await tester.pumpAndSettle();
    expect(find.text('Payment Settings'), findsWidgets);
    expect(find.text('Razorpay Public Key ID'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Razorpay Public Key ID'), findsNothing);
  });

  testWidgets('AI Test Creator tab renders hero, quick actions, 5 metric cards, table, and analytics', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(
          startLoggedIn: true,
          initialTab: AdminNavTab.aiCreator,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Active Tab
    expect(find.text('AI Test Creator'), findsWidgets);

    // 2. Verify Hero Banner
    expect(find.text('AI Test '), findsOneWidget);
    expect(find.text('Creator'), findsWidgets);
    expect(find.text('Generate high-quality tests instantly using AI.'), findsOneWidget);

    // 3. Verify 6 Quick Actions
    expect(find.text('Generate\nTest'), findsOneWidget);
    expect(find.text('Custom\nPrompt'), findsOneWidget);
    expect(find.text('Manage\nTemplates'), findsOneWidget);
    expect(find.text('Saved\nTests'), findsOneWidget);
    expect(find.text('Question\nBank'), findsOneWidget);
    expect(find.text('Export\nTest'), findsOneWidget);

    // 4. Verify 5 Metric Cards
    expect(find.text('Tests Generated'), findsOneWidget);
    expect(find.text('Questions Created'), findsOneWidget);
    expect(find.text('Saved Tests'), findsWidgets);
    expect(find.text('Times Used'), findsOneWidget);
    expect(find.text('Avg. Creation Time (AI Speed)'), findsOneWidget);

    // 5. Verify Table Card & Content
    expect(find.textContaining('AI Generated Tests'), findsOneWidget);
    expect(find.text('RRB Technician Mock Test'), findsOneWidget);
    expect(find.text('Railway Maths Practice Test'), findsOneWidget);
    expect(find.text('Reasoning Speed Test'), findsOneWidget);
    expect(find.text('Current Affairs Weekly Test'), findsOneWidget);
    expect(find.text('Chemistry Chapter Test'), findsOneWidget);
    expect(find.text('Biology NEET Practice Test'), findsOneWidget);
    expect(find.text('Full Syllabus Combined Test'), findsOneWidget);

    // 6. Verify Right Column Analytics Cards
    expect(find.text('Subject Wise Test Distribution'), findsOneWidget);
    expect(find.text('Test Difficulty Distribution'), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);

    // 7. Test Custom Prompt dialog
    await tester.tap(find.text('Custom\nPrompt'));
    await tester.pumpAndSettle();
    expect(find.text('Custom Prompt & Model Config'), findsOneWidget);
    expect(find.text('AI System Prompt (Role Definition)'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('AI System Prompt (Role Definition)'), findsNothing);

    // 8. Test Manage Templates dialog
    await tester.tap(find.text('Manage\nTemplates'));
    await tester.pumpAndSettle();
    expect(find.text('Manage Test Templates'), findsOneWidget);
    expect(find.text('RRB Technician Full Mock'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Manage Test Templates'), findsNothing);

    // 9. Test Saved Tests dialog
    await tester.tap(find.text('Saved\nTests'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Saved AI Tests'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Inspect, review or resume publishing drafted tests'), findsNothing);

    // 10. Test Export Test dialog
    await tester.tap(find.text('Export\nTest'));
    await tester.pumpAndSettle();
    expect(find.text('Export AI Test'), findsOneWidget);
    expect(find.text('Select Test to Export'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Export AI Test'), findsNothing);
  });

  testWidgets('Lucky Wheel Management renders hero, 6 quick actions, 5 metrics, table, and analytics', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(
          initialTab: AdminNavTab.wheel,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Top Navigation Lucky Wheel Pill is active
    expect(find.text('Lucky Wheel'), findsAtLeastNWidgets(1));

    // 2. Verify Hero Banner
    expect(find.textContaining('Lucky Wheel'), findsWidgets);
    expect(find.text('Create and manage lucky wheel campaigns for your platform.'), findsOneWidget);
    expect(find.text('Set rewards, spin rules, track participation and boost user engagement.'), findsOneWidget);

    // 3. Verify 6 Quick Actions
    expect(find.text('Create\nLucky Wheel'), findsOneWidget);
    expect(find.text('Set\nRewards'), findsOneWidget);
    expect(find.text('Manage\nCampaigns'), findsOneWidget);
    expect(find.text('Spin\nHistory'), findsOneWidget);
    expect(find.text('Send\nNotification'), findsOneWidget);
    expect(find.text('Export\nReports'), findsOneWidget);

    // 4. Verify 5 Metric Cards
    expect(find.text('Total Campaigns'), findsOneWidget);
    expect(find.text('Total Participants'), findsOneWidget);
    expect(find.text('Total Rewards Given'), findsOneWidget);
    expect(find.text('Active Campaigns'), findsOneWidget);
    expect(find.text('Total Spins'), findsWidgets);

    // 5. Verify Table Card & Primary 7 Campaigns
    expect(find.textContaining('Lucky Wheel Campaigns (18)'), findsOneWidget);
    expect(find.text('Daily Spin Rewards'), findsOneWidget);
    expect(find.text('Festive Mega Spin'), findsOneWidget);
    expect(find.text('New User Bonus Spin'), findsOneWidget);
    expect(find.text('Weekend Lucky Draw'), findsOneWidget);
    expect(find.text('Exam Prep Spin'), findsOneWidget);
    expect(find.text('Mega Reward Spin'), findsOneWidget);
    expect(find.text('Referral Spin'), findsOneWidget);

    // 6. Verify Right Column Analytics Cards
    expect(find.text('Reward Type Distribution'), findsOneWidget);
    expect(find.text('Spins Trend (Last 7 Days)'), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);

    // 7. Test Create Lucky Wheel Dialog
    await tester.tap(find.text('Create\nLucky Wheel'));
    await tester.pumpAndSettle();
    expect(find.text('Create Lucky Wheel Campaign'), findsOneWidget);
    expect(find.text('Campaign Name *'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Create Lucky Wheel Campaign'), findsNothing);

    // 8. Test Set Rewards Dialog
    await tester.tap(find.text('Set\nRewards'));
    await tester.pumpAndSettle();
    expect(find.text('Set Wheel Rewards & Probabilities'), findsOneWidget);
    expect(find.textContaining('Total Probability: 100%'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Set Wheel Rewards & Probabilities'), findsNothing);

    // 9. Test Spin History Dialog
    await tester.tap(find.text('Spin\nHistory'));
    await tester.pumpAndSettle();
    expect(find.text('Authoritative Spin & Reward Ledger'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsOneWidget);
    await tester.tap(find.text('Close Ledger'));
    await tester.pumpAndSettle();
    expect(find.text('Authoritative Spin & Reward Ledger'), findsNothing);
  });

  testWidgets('BattleDashboardTab shows honest offline state with zero mock data', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final service = BattleDashboardService();
    addTearDown(service.resetForTest);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BattleDashboardTab(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Supabase Offline'), findsOneWidget);
    expect(find.text('Database connection is not initialized.'), findsOneWidget);
    expect(find.text('No battle participant activity in last 7 days'), findsOneWidget);
    // Ensure old hardcoded mock numbers never appear
    expect(find.text('12,840'), findsNothing);
    expect(find.text('8,742 Live'), findsNothing);
    expect(find.text('3,120'), findsNothing);
  });

  testWidgets('BattleDashboardTab renders populated live battle records, players, and reports accurately', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final service = BattleDashboardService();
    addTearDown(service.resetForTest);

    final now = DateTime.now();
    service.configureForTest(
      hasDbConnection: true,
      hasPersistedSettings: true,
      battleQuestionsCount: 42,
      questionTopicCounts: const {'General Science': 24, 'Mathematics': 18},
      settings: const BattleSettingsData(
        matchmakingTimeout: 15,
        prizeMultiplier: 1.8,
        maintenanceMode: false,
      ),
      battles: [
        BattleItem(
          id: 'btl_prod_1',
          title: 'Riya vs Kabir',
          type: BattleType.oneVOne,
          status: BattleStatus.live,
          subject: 'Mixed Topics',
          category: '1 vs 1 Arena',
          participants: const [
            BattleParticipant(id: 'u1', name: 'Riya Verma', avatarUrl: '', score: 40, rank: 1),
            BattleParticipant(id: 'u2', name: 'Kabir Sen', avatarUrl: '', score: 20, rank: 2),
          ],
          totalPlayers: 2,
          maxPlayers: 2,
          entryFee: 50,
          prizePool: 90,
          createdAt: now.subtract(const Duration(minutes: 4)),
          creatorId: 'u1',
          opponentId: 'u2',
        ),
        BattleItem(
          id: 'btl_prod_2',
          title: 'Arjun (Queue)',
          type: BattleType.oneVOne,
          status: BattleStatus.completed,
          subject: 'Mixed Topics',
          category: '1 vs 1 Arena',
          participants: const [
            BattleParticipant(id: 'u3', name: 'Arjun Nair', avatarUrl: '', score: 50, rank: 1),
            BattleParticipant(id: 'u2', name: 'Kabir Sen', avatarUrl: '', score: 30, rank: 2),
          ],
          totalPlayers: 2,
          maxPlayers: 2,
          entryFee: 20,
          prizePool: 36,
          createdAt: now.subtract(const Duration(hours: 2)),
          completedAt: now.subtract(const Duration(hours: 1, minutes: 56)),
          creatorId: 'u3',
          opponentId: 'u2',
          winnerId: 'u3',
        ),
      ],
      players: [
        PlayerBattleRecord(
          id: 'u3',
          username: 'Arjun Nair',
          avatarUrl: '',
          rank: '#1',
          totalBattles: 1,
          wins: 1,
          losses: 0,
          winRate: 100,
          coins: 520,
          status: 'active',
          joinedAt: now,
        ),
        PlayerBattleRecord(
          id: 'u1',
          username: 'Riya Verma',
          avatarUrl: '',
          rank: '#2',
          totalBattles: 1,
          wins: 0,
          losses: 0,
          winRate: 0,
          coins: 310,
          status: 'active',
          joinedAt: now,
        ),
      ],
      auditLogs: const [
        {
          'time': '2026-11-11 20:00',
          'action': 'Battle Created',
          'details': 'Created 1v1 battle btl_prod_1 (fee: 50 coins)',
        },
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BattleDashboardTab(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Supabase Live'), findsOneWidget);
    expect(find.text('btl_prod_1'), findsOneWidget);
    expect(find.text('42'), findsOneWidget); // Question Bank count
    expect(find.text('100%'), findsOneWidget); // Completion rate (1 completed / 0 cancelled)

    // Verify redundant sub-navigation bar was removed (table dropdown already filters types)
    expect(find.text('Overview'), findsNothing);
    expect(find.text('Multiplayer'), findsNothing);

    // Open Players dialog from Battle Control card and close
    await tester.tap(find.text('Players').last);
    await tester.pumpAndSettle();
    expect(find.text('Player Management & Moderation'), findsOneWidget);
    expect(find.text('Arjun Nair'), findsWidgets);
    expect(find.text('520 Coins'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Player Management & Moderation'), findsNothing);

    // Open Reports dialog from Battle Control card and close
    await tester.tap(find.text('Reports').first);
    await tester.pumpAndSettle();
    expect(find.text('Battle Analytics & Performance Reports'), findsOneWidget);
    expect(find.text('140'), findsOneWidget); // 50*2 + 20*2 coin volume
    expect(find.text('Battle Created'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Battle Analytics & Performance Reports'), findsNothing);

    // Open Settings dialog from Battle Control card and close
    await tester.tap(find.text('Settings').first);
    await tester.pumpAndSettle();
    expect(find.text('Global Battle System Settings'), findsOneWidget);
    expect(find.text('Synced with app_configs'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Global Battle System Settings'), findsNothing);
  });
}




