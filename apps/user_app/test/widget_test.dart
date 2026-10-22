import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import 'package:user_app/main.dart';
import 'package:user_app/features/live/live_tests_screen.dart';

void main() {
  testWidgets('RankearnUserApp renders reference top bar, header tagline, and all 6 navigation tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnUserApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app header and branding elements exist
    expect(find.text('Rankearn'), findsWidgets);
    expect(find.text('Learn • Practice • Earn'), findsOneWidget);

    // Verify all 6 bottom navigation tabs matching reference image inside AppBottomNav
    final bottomNav = find.byType(AppBottomNav);
    expect(find.descendant(of: bottomNav, matching: find.text('Home')), findsOneWidget);
    expect(find.descendant(of: bottomNav, matching: find.text('Tests')), findsOneWidget);
    expect(find.descendant(of: bottomNav, matching: find.text('Live')), findsOneWidget);
    expect(find.descendant(of: bottomNav, matching: find.text('Battle')), findsOneWidget);
    expect(find.descendant(of: bottomNav, matching: find.text('Rewards')), findsOneWidget);
    expect(find.descendant(of: bottomNav, matching: find.text('Profile')), findsOneWidget);

    // Verify Home Dashboard hero banner
    expect(find.text('Start Learning'), findsOneWidget);

    // Verify 4 statistics cards
    expect(find.text('My Coins'), findsWidgets);
    expect(find.text('Daily Streak'), findsOneWidget);
    expect(find.text('Tests Attempted'), findsOneWidget);
    expect(find.text('My Rank'), findsOneWidget);

    // Verify 6 Feature Shortcuts
    expect(find.text('Mock Tests'), findsOneWidget);
    expect(find.text('Live Test'), findsOneWidget);
    expect(find.text('Fortune Wheel'), findsWidgets);
    expect(find.text('Tournaments'), findsOneWidget);

    // Verify Continue Learning & Today's Goal
    expect(find.text('Continue Learning'), findsOneWidget);
    expect(find.text("Today's Goal"), findsOneWidget);

    // Verify Explore by Subject
    expect(find.text('Explore by Subject'), findsOneWidget);
    expect(find.text('Mathematics'), findsOneWidget);

    // Verify Daily Challenge & Upcoming Live Tests
    expect(find.text('Daily Challenge'), findsOneWidget);
    expect(find.text('Upcoming Live Tests'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches seamlessly between reference tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnUserApp(),
      ),
    );

    await tester.pumpAndSettle();
    final bottomNav = find.byType(AppBottomNav);

    // Tap on Tests tab in AppBottomNav
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Tests')));
    await tester.pumpAndSettle();
    expect(find.text('Test Categories'), findsOneWidget);

    // Tap on Live tab in AppBottomNav
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Live')));
    await tester.pumpAndSettle();
    expect(find.byType(LiveTestsScreen), findsOneWidget);

    // Tap on Battle tab in AppBottomNav
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Battle')));
    await tester.pumpAndSettle();
    expect(find.text('1v1 Live Arena ⚔️'), findsOneWidget);

    // Tap on Rewards tab in AppBottomNav
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Rewards')));
    await tester.pumpAndSettle();
    expect(find.text('Daily Lucky Wheel 🎡'), findsOneWidget);

    // Tap on Profile tab in AppBottomNav
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Profile')));
    await tester.pumpAndSettle();
    expect(find.text('Vikram Singh'), findsOneWidget);
    expect(find.text('70th BPSC Aspirant'), findsOneWidget);

    // Return to Home tab in AppBottomNav
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Home')));
    await tester.pumpAndSettle();
    expect(find.text('Start Learning'), findsOneWidget);
  });

  testWidgets('Tests tab clicking Start Test opens QuizScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnUserApp(
          initialTests: [
            TestModel(
              id: 'test_demo',
              title: '70th BPSC Prelims Test',
              durationMinutes: 120,
              totalQuestions: 150,
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    final bottomNav = find.byType(AppBottomNav);

    // Switch to Tests tab via AppBottomNav
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Tests')));
    await tester.pumpAndSettle();

    // Click Start Test on the first available test
    final startButton = find.text('Start Test').first;
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pumpAndSettle();

    // Verify QuizScreen is rendered with question text, options, and timer
    expect(find.text('Question 1 of 5'), findsOneWidget);
    expect(find.text('When was the state of Bihar carved out from the Bengal Presidency?'), findsOneWidget);
    expect(find.text('Save & Next →'), findsOneWidget);
  });
}
