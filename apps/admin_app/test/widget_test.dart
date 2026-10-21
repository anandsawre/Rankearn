import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:admin_app/main.dart';
import 'package:admin_app/features/tests/widgets/test_series_table_card.dart';
import 'package:admin_app/features/tests/widgets/subject_wise_chart_card.dart';
import 'package:admin_app/features/tests/widgets/recent_activity_card.dart';

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

  testWidgets('Platform status shows operational checks', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All Systems Operational'), findsOneWidget);
    expect(find.text('Database'), findsOneWidget);
    expect(find.text('API Services'), findsOneWidget);
    expect(find.text('99.9%'), findsOneWidget);
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

  testWidgets('AdminLoginScreen sign in navigates to dashboard and sign out returns to login', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(startLoggedIn: false),
      ),
    );
    await tester.pumpAndSettle();

    // Verify on login screen
    expect(find.text('Sign In to Admin Panel'), findsOneWidget);

    // Tap Sign In button
    await tester.tap(find.text('Sign In to Admin Panel'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify transitioned to Admin Dashboard
    expect(find.text('Admin User'), findsOneWidget);
    expect(find.text('Quiz Attempts Overview'), findsOneWidget);

    // Sign out to verify return to login screen
    await tester.tap(find.text('Admin User'));
    await tester.pumpAndSettle();
    expect(find.text('Sign Out'), findsOneWidget);
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    // Verified back on login screen
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

    // 3. Verify 5 Metric Cards
    expect(find.text('Total Test Series'), findsOneWidget);
    expect(find.text('42'), findsWidgets);
    expect(find.text('Published'), findsWidgets);
    expect(find.text('38'), findsOneWidget);
    expect(find.text('Drafts'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
    expect(find.text('Total Tests'), findsWidgets);
    expect(find.text('428'), findsOneWidget);
    expect(find.text('Total Enrollments'), findsOneWidget);
    expect(find.text('12,458'), findsOneWidget);

    // 4. Verify Table Card & Sample Test Series
    expect(find.textContaining('Test Series List'), findsOneWidget);
    expect(find.text('RRB Technician Grade 3'), findsOneWidget);
    expect(find.text('Railway Maths Practice Series'), findsOneWidget);
    expect(find.text('Reasoning Special Series'), findsOneWidget);
    expect(find.text('Current Affairs Monthly Series'), findsOneWidget);
    expect(find.text('Chemistry Practice Series'), findsOneWidget);
    expect(find.text('Biology Marathon Series'), findsOneWidget);
    expect(find.text('Full Syllabus Mock Test Series'), findsOneWidget);

    // 5. Verify Right Column (Subject Wise Donut Chart + Recent Activity)
    expect(find.text('Subject Wise Test Series'), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.text('View All'), findsOneWidget);
    expect(find.text('New test series created: RRB Technician'), findsOneWidget);

    final tableSize = tester.getSize(find.byType(TestSeriesTableCard));
    final chartSize = tester.getSize(find.byType(SubjectWiseChartCard));
    final activitySize = tester.getSize(find.byType(RecentActivityCard));
    final rightTotalHeight = chartSize.height + 16.0 + activitySize.height;

    // Verify right column combined height exactly matches the test series table card height
    expect((rightTotalHeight - tableSize.height).abs() < 0.1, isTrue,
        reason: 'Combined right column height ($rightTotalHeight) must match table card height (${tableSize.height})');
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
    expect(find.text('Import Questions (CSV / JSON)'), findsOneWidget);
    expect(find.text('Validate & Parse Data'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Import Questions (CSV / JSON)'), findsNothing);

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
}




