import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';
import 'package:user_app/features/live/live_tests_screen.dart';

void main() {
  Widget createTestWidget({Size? surfaceSize}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: LiveTestsScreen(
          userCoins: 1250,
        ),
      ),
    );
  }

  group('Live Tests Tab UI Tests', () {
    testWidgets('Renders all required sections matching reference screenshot', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. Hero Banner
      expect(find.byType(LiveTestsHeroBanner), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(LiveTestsHeroBanner),
          matching: find.byWidgetPredicate(
            (w) => w is RichText && w.text.toPlainText().trim() == 'Live Tests',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('Join Live Test'), findsOneWidget);
      expect(find.text('Real-time\nRanking'), findsOneWidget);
      expect(find.text('Win\nCoins'), findsOneWidget);
      expect(find.text('Compete\nAcross India'), findsOneWidget);

      // 2. Four Statistics Cards
      expect(find.byType(LiveTestMetricsRow), findsOneWidget);
      expect(find.text('Participants'), findsOneWidget);
      expect(find.text('5.2K'), findsOneWidget);
      expect(find.text('Coins Earned'), findsOneWidget);
      expect(find.text('Rank Position'), findsOneWidget);
      expect(find.text('#1256'), findsOneWidget);

      // 3. Filter Navigation
      expect(find.byType(LiveTestNavigation), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Live Now'), findsWidgets);
      expect(find.text('My Participations'), findsOneWidget);
      expect(find.text('Leaderboards'), findsOneWidget);

      // 4. Live Now Cards
      expect(find.text('RRB Technician Special Live Test'), findsOneWidget);
      expect(find.text('All India Mega Quiz'), findsOneWidget);
      expect(find.text('Maths Speed Test'), findsOneWidget);
      expect(find.text('Join Now'), findsWidgets);

      // 5. Upcoming Live Tests Cards
      expect(find.text('Upcoming Live Tests'), findsOneWidget);
      expect(find.text('General Science Mega Test'), findsOneWidget);
      expect(find.text('Current Affairs Live Test'), findsOneWidget);
      expect(find.text('Reasoning Challenge'), findsOneWidget);
      expect(find.text('Notify Me'), findsWidgets);

      // 6. Promotional Banners
      expect(find.byType(LiveTestPromoBanners), findsOneWidget);
      expect(find.text('Live Test Series'), findsOneWidget);
      expect(find.text('Create a Live Test'), findsOneWidget);
      expect(find.text('View Series'), findsOneWidget);
      expect(find.text('Create Now'), findsOneWidget);

      // 7. Right Sidebar Components
      expect(find.byType(TodayGoalCard), findsOneWidget);
      expect(find.text('Daily Streak'), findsOneWidget);
      expect(find.text('7 Days'), findsOneWidget);
      expect(find.byType(DailyStreakCard), findsOneWidget);
      expect(find.byType(WeeklyLeaderboardCard), findsOneWidget);
      expect(find.text('Weekly Leaderboard'), findsOneWidget);
      expect(find.text('Aarav Sharma'), findsOneWidget);
      expect(find.text('Priya Patel'), findsOneWidget);
      expect(find.text('Karan Mehta'), findsOneWidget);
      expect(find.byType(TopRewardsCard), findsOneWidget);
      expect(find.text('Top Rewards'), findsOneWidget);
      expect(find.text('Rank Badges'), findsOneWidget);
      expect(find.text('Certificates'), findsOneWidget);
      expect(find.text('Exciting Prizes'), findsOneWidget);
    });

    testWidgets('Tapping Upcoming filter hides Live Now section and shows only upcoming', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap 'Upcoming' tab
      await tester.ensureVisible(find.text('Upcoming'));
      await tester.tap(find.text('Upcoming'));
      await tester.pumpAndSettle();

      // Live Now should be hidden
      expect(find.text('RRB Technician Special Live Test'), findsNothing);

      // Upcoming tests should still be visible
      expect(find.text('General Science Mega Test'), findsOneWidget);
    });

    testWidgets('Tapping Notify Me toggles state to Notified', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final notifyButtons = find.text('Notify Me');
      expect(notifyButtons, findsWidgets);

      await tester.ensureVisible(notifyButtons.first);
      await tester.tap(notifyButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Notified'), findsOneWidget);
    });

    testWidgets('Renders with zero overflow across multiple screen viewports', (tester) async {
      final viewports = [
        const Size(320, 568),  // Compact Mobile
        const Size(360, 780),  // Standard Mobile
        const Size(412, 915),  // Large Mobile
        const Size(768, 1024), // Tablet Portrait
        const Size(1024, 768), // Tablet Landscape
        const Size(1440, 900), // Desktop Web
      ];

      for (final size in viewports) {
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Overflow detected at ${size.width}x${size.height}');
      }

      tester.view.resetPhysicalSize();
    });

    testWidgets('Desktop viewport renders two-column layout (~72% main, ~28% sidebar)', (tester) async {
      tester.view.physicalSize = const Size(1440 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final rowFinder = find.byWidgetPredicate(
        (w) =>
            w is Row &&
            w.children.any((c) => c is Expanded && c.flex == 72) &&
            w.children.any((c) => c is Expanded && c.flex == 28),
      );
      expect(rowFinder, findsOneWidget);
    });
  });
}
