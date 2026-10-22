import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'package:user_app/features/battle/battle_hub_screen.dart';

void main() {
  final testProfile = UserProfile(
    id: 'test-user-123',
    name: 'Rahul Sharma',
    email: 'rahul@example.com',
    coins: 1250,
    createdAt: DateTime(2024, 1, 1),
  );

  Widget buildBattleTabScreen() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: BattleHubScreen(
          userCoins: 1250,
          profile: testProfile,
        ),
      ),
    );
  }

  group('1v1 Quiz Battle Tab - Reference Specification Tests', () {
    testWidgets('Renders all required sections matching reference image', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildBattleTabScreen());
      await tester.pumpAndSettle();

      // 1. Hero Banner
      expect(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Quiz Battle')), findsOneWidget);
      expect(find.textContaining('Challenge real players'), findsOneWidget);
      expect(find.text('Start Battle'), findsOneWidget);
      expect(find.text('Real Players\nOnline'), findsOneWidget);
      expect(find.text('Instant\nMatch'), findsOneWidget);
      expect(find.text('Win\nCoins'), findsOneWidget);
      expect(find.text('Play\nCompete\nEarn'), findsOneWidget);

      // 2. Battle Statistics (4 cards)
      expect(find.text('Players Online'), findsOneWidget);
      expect(find.text('Battles Played'), findsOneWidget);
      expect(find.text('Your Wins'), findsOneWidget);
      expect(find.text('Win Rate'), findsOneWidget);

      // 3. Battle Navigation Tabs
      expect(find.text('1v1 Battle'), findsWidgets);
      expect(find.text('2 Players'), findsOneWidget);
      expect(find.text('Custom Room'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);

      // 4. Choose Battle Type (3 Cards)
      expect(find.text('Choose Battle Type'), findsOneWidget);
      expect(find.text('Quick Battle'), findsWidgets);
      expect(find.text('Win 50 Coins'), findsOneWidget);
      expect(find.text('Ranked Battle'), findsOneWidget);
      expect(find.text('Win 100 Coins'), findsOneWidget);
      expect(find.text('Friends Battle'), findsOneWidget);
      expect(find.text('Win Custom Coins'), findsOneWidget);
      expect(find.text('Play Now'), findsWidgets);
      expect(find.text('Create Room'), findsOneWidget);

      // 5. Top Players (Leaderboard Preview)
      expect(find.text('Top Players'), findsOneWidget);
      expect(find.text('Aman Kumar'), findsOneWidget);
      expect(find.text('Priya Singh'), findsOneWidget);
      expect(find.text('Rohit Raj'), findsOneWidget);
      expect(find.text('Sneha Patel'), findsOneWidget);

      // 6. Daily Battle Mission
      expect(find.text('Daily Battle Mission'), findsOneWidget);
      expect(find.text('Play 3 Battles'), findsOneWidget);
      expect(find.text('Win 2 Battles'), findsOneWidget);
      expect(find.text('Score 80%+'), findsOneWidget);
      expect(find.text('Battle with Friend'), findsOneWidget);
      expect(find.text('+100 Coins'), findsWidgets);
      expect(find.text('+150 Coins'), findsOneWidget);
      expect(find.text('+200 Coins'), findsOneWidget);
    });

    testWidgets('Interactive Tab Switching: Switches to History and renders history cards', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildBattleTabScreen());
      await tester.pumpAndSettle();

      // Tap on History tab
      final historyTabFinder = find.text('History');
      expect(historyTabFinder, findsOneWidget);
      await tester.ensureVisible(historyTabFinder);
      await tester.pumpAndSettle();
      await tester.tap(historyTabFinder);
      await tester.pumpAndSettle();

      // Verify history section is rendered
      expect(find.text('Recent Battle History'), findsOneWidget);
      expect(find.textContaining('Vikram Joshi'), findsWidgets);
    });

    testWidgets('Interactive Matchmaking Flow: Opens matchmaking radar modal dialog', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildBattleTabScreen());
      await tester.pumpAndSettle();

      // Tap Start Battle CTA on Hero Banner
      final startBattleCta = find.text('Start Battle');
      expect(startBattleCta, findsOneWidget);
      await tester.tap(startBattleCta);
      await tester.pump(); // Start animation dialog

      // Verify Matchmaking dialog appears
      expect(find.text('Searching Opponent...'), findsOneWidget);
      expect(find.text('Cancel Matchmaking'), findsOneWidget);

      // Cancel matchmaking to close dialog cleanly
      await tester.tap(find.text('Cancel Matchmaking'));
      await tester.pumpAndSettle();
      expect(find.text('Searching Opponent...'), findsNothing);
    });

    testWidgets('Interactive Custom Room: Opens Custom Room Dialog', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildBattleTabScreen());
      await tester.pumpAndSettle();

      // Tap Custom Room tab in navigation
      final customRoomTab = find.text('Custom Room');
      expect(customRoomTab, findsOneWidget);
      await tester.ensureVisible(customRoomTab);
      await tester.pumpAndSettle();
      await tester.tap(customRoomTab);
      await tester.pumpAndSettle();

      // Verify custom room dialog
      expect(find.text('Custom Battle Room'), findsOneWidget);
      expect(find.text('Create Room'), findsWidgets);
      expect(find.text('Join Room'), findsWidgets);

      // Close dialog
      Navigator.of(tester.element(find.text('Custom Battle Room'))).pop();
      await tester.pumpAndSettle();
    });

    testWidgets('Responsive Layout: Renders with zero overflow across Mobile, Tablet, and Desktop', (WidgetTester tester) async {
      final viewports = [
        const Size(360, 780),  // Compact Mobile
        const Size(412, 915),  // Modern Android
        const Size(768, 1024), // Tablet Portrait
        const Size(1024, 768), // Tablet Landscape / Small Desktop
        const Size(1280, 800), // Desktop HD
        const Size(1440, 900), // Large Desktop
      ];

      for (final size in viewports) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(buildBattleTabScreen());
        await tester.pumpAndSettle();

        // Verify key components exist without crashing or overflowing
        expect(find.textContaining('1v1'), findsWidgets);
        expect(find.text('Players Online'), findsOneWidget);
        expect(find.text('Choose Battle Type'), findsOneWidget);

        // Verify no RenderFlex overflow error
        expect(tester.takeException(), isNull, reason: 'Overflow detected at size $size');
      }

      tester.view.resetPhysicalSize();
    });
  });
}
