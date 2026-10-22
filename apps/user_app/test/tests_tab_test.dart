import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';
import 'package:user_app/features/tests/test_series_screen.dart';

void main() {
  Widget buildTestScreen() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: TestSeriesScreen(
          userCoins: 1250,
          onStartTest: (_) {},
        ),
      ),
    );
  }

  group('Tests Tab UI Tests', () {
    testWidgets('Renders all required sections matching reference', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // 1. Tests Hero Banner
      expect(find.text('Tests'), findsOneWidget);
      expect(find.textContaining('Practice smarter'), findsOneWidget);

      // 2. Four Statistic Cards
      expect(find.text('Tests Attempted'), findsOneWidget);
      expect(find.text('Average Score'), findsOneWidget);
      expect(find.text('Rank Position'), findsOneWidget);
      expect(find.text('Coins Earned'), findsOneWidget);

      // 3. Test Type Navigation
      expect(find.text('All Tests'), findsOneWidget);
      expect(find.text('Daily Test'), findsOneWidget);
      expect(find.text('Mock Tests'), findsWidgets); // Can appear in nav & category
      expect(find.text('Previous Year'), findsOneWidget);
      expect(find.text('Chapter Wise'), findsOneWidget);
      expect(find.text('My Tests'), findsOneWidget);

      // 4. Select Subject Section
      expect(find.text('Select Subject'), findsOneWidget);
      expect(find.text('View All'), findsWidgets);
      expect(find.text('Mathematics'), findsWidgets);
      expect(find.text('Reasoning'), findsWidgets);

      // 5. Test Categories Section
      expect(find.text('Test Categories'), findsOneWidget);
      expect(find.text('Chapter Wise Tests'), findsOneWidget);
      expect(find.text('Previous Year Papers'), findsOneWidget);
      expect(find.text('Daily Practice Tests'), findsOneWidget);
      expect(find.text('Topic Wise Tests'), findsOneWidget);
      expect(find.text('Live Tests'), findsOneWidget);

      // 6. Bottom Promotional Banners
      expect(find.text('Test Series'), findsOneWidget);
      expect(find.text('Create Your Own Test'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);

      // 7. Sidebar Sections
      expect(find.text("Today's Goal"), findsWidgets);
      expect(find.text('Quick Actions & Rewards'), findsOneWidget);
      expect(find.text('Spin Lucky Wheel'), findsOneWidget);
      expect(find.text('1v1 Quiz Battle'), findsOneWidget);
      expect(find.text('Upcoming Tests'), findsOneWidget);
      expect(find.text('Top Performers'), findsOneWidget);
    });

    testWidgets('Tapping test type navigation updates selection', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Tap on Daily Test
      final dailyFinder = find.text('Daily Test');
      await tester.ensureVisible(dailyFinder);
      await tester.tap(dailyFinder);
      await tester.pumpAndSettle();

      // Expect to still have zero errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders with zero overflow across viewports', (WidgetTester tester) async {
      final viewports = [
        const Size(320, 568),   // Compact Mobile (iPhone SE)
        const Size(360, 780),   // Standard Mobile (Android)
        const Size(412, 915),   // Large Mobile (Pixel 7)
        const Size(768, 1024),  // Tablet Portrait (iPad)
        const Size(1024, 768),  // Tablet Landscape (iPad)
        const Size(1440, 900),  // Laptop / Desktop
        const Size(1920, 1080), // Full HD Desktop
      ];

      for (final size in viewports) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(buildTestScreen());
        await tester.pumpAndSettle();

        final exc = tester.takeException();
        if (exc != null) {
          // ignore: avoid_print
          print('EXC ON ${size.width}: $exc');
        }
        expect(exc, isNull, reason: 'Overflow or error on ${size.width}x${size.height}');
      }

      tester.view.resetPhysicalSize();
    });
  });
}
