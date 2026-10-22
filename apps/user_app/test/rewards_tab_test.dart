import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_layer/data_layer.dart';
import 'package:user_app/features/rewards/rewards_hub_screen.dart';

void main() {
  final mockProfile = UserProfile(
    id: 'user-rewards-123',
    name: 'Aman Kumar',
    email: 'aman@rankearn.in',
    coins: 1250,
    totalEarned: 12500,
    referralCode: 'RANK123',
    createdAt: DateTime(2026, 1, 1),
  );

  Widget buildRewardsScreen({
    VoidCallback? onOpenWallet,
    VoidCallback? onOpenTests,
    VoidCallback? onOpenBattle,
    VoidCallback? onOpenSpinWheel,
    void Function(int delta)? onCoinUpdate,
  }) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        home: Scaffold(
          body: RewardsHubScreen(
            userCoins: 1250,
            profile: mockProfile,
            onOpenWallet: onOpenWallet,
            onOpenTests: onOpenTests,
            onOpenBattle: onOpenBattle,
            onOpenSpinWheel: onOpenSpinWheel,
            onCoinUpdate: onCoinUpdate,
          ),
        ),
      ),
    );
  }

  group('Rewards Tab - Reference Specification Tests', () {
    testWidgets('Desktop: Renders all required sections and right sidebar matching reference image', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildRewardsScreen());
      await tester.pumpAndSettle();

      // 1. Hero Banner
      expect(find.textContaining('Earn'), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('More Rewards'),
        ),
        findsOneWidget,
      );
      expect(find.text('How to Earn?'), findsOneWidget);
      expect(find.text('Complete tasks, play tests and\nrefer friends to earn coins.'), findsOneWidget);

      // 2. 4 Summary Statistics Cards
      expect(find.text('My Coins'), findsOneWidget);
      expect(find.text('1250'), findsOneWidget);
      expect(find.text('Daily Streak'), findsWidgets);
      expect(find.text('7 Days'), findsWidgets);
      expect(find.text('My Rank'), findsOneWidget);
      expect(find.text('#1256'), findsOneWidget);
      expect(find.text('Total Earned'), findsOneWidget);
      expect(find.text('12500'), findsOneWidget);

      // 3. Category Filter Tabs
      expect(find.text('All Tasks'), findsOneWidget);
      expect(find.text('Daily Tasks'), findsWidgets);
      expect(find.text('Weekly Tasks'), findsWidgets);
      expect(find.text('Special Tasks'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);

      // 4. Daily Tasks List
      expect(find.text('Attempt 1 Test'), findsOneWidget);
      expect(find.text('Complete any test (Mock, Chapter or Daily)'), findsOneWidget);
      expect(find.text('+50'), findsOneWidget);
      expect(find.text('Score 70% or above'), findsOneWidget);
      expect(find.text('+75'), findsOneWidget);
      expect(find.text('Watch 1 Educational Video'), findsOneWidget);
      expect(find.text('+30'), findsOneWidget);
      expect(find.text('Refer 1 Friend'), findsOneWidget);
      expect(find.text('+100'), findsOneWidget);
      expect(find.text('Go Now'), findsNWidgets(2));
      expect(find.text('0/1'), findsNWidgets(2));

      // 5. Weekly Tasks List
      expect(find.text('Attempt 10 Tests'), findsOneWidget);
      expect(find.text('0/10'), findsOneWidget);
      expect(find.text('+300'), findsOneWidget);
      expect(find.text('Maintain 70% Avg Score'), findsOneWidget);
      expect(find.text('0/70%'), findsOneWidget);
      expect(find.text('Refer 5 Friends'), findsOneWidget);
      expect(find.text('0/5'), findsOneWidget);
      expect(find.text('+500'), findsNWidgets(2));

      // 6. Refer & Earn Banner
      expect(find.text('Refer & Earn'), findsOneWidget);
      expect(find.text('Invite your friends and earn 100 coins for each successful signup!'), findsOneWidget);
      expect(find.text('Your Referral Code'), findsOneWidget);
      expect(find.text('RANK123'), findsOneWidget);
      expect(find.text('Invite Now'), findsOneWidget);

      // 7. Right Sidebar
      // A. Today's Goal
      expect(find.text("Today's Goal"), findsWidgets);
      expect(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('3/5')), findsOneWidget);
      expect(find.text('Complete 5 tests today to earn 50 coins!'), findsOneWidget);

      // B. Quick Actions & Rewards
      expect(find.text('Quick Actions & Rewards'), findsOneWidget);
      expect(find.text('Spin Lucky Wheel'), findsOneWidget);
      expect(find.text('Win up to 500 Coins today'), findsOneWidget);
      expect(find.text('1v1 Quiz Battle'), findsOneWidget);
      expect(find.text('Challenge live aspirants now'), findsOneWidget);

      // C. Top Rewards
      expect(find.text('Top Rewards'), findsOneWidget);
      expect(find.text('Coins'), findsWidgets);
      expect(find.text('Instant Rewards'), findsOneWidget);
      expect(find.text('Rank Badges'), findsOneWidget);
      expect(find.text('Climb the Rank'), findsOneWidget);
      expect(find.text('Certificates'), findsOneWidget);
      expect(find.text('Show Your Skills'), findsOneWidget);
      expect(find.text('Exciting Prizes'), findsOneWidget);
      expect(find.text('Special Gifts'), findsOneWidget);
    });

    testWidgets('Interactive: Tapping How to Earn opens modal sheet', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildRewardsScreen());
      await tester.pumpAndSettle();

      final howToEarnBtn = find.text('How to Earn?');
      expect(howToEarnBtn, findsOneWidget);
      await tester.tap(howToEarnBtn);
      await tester.pumpAndSettle();

      expect(find.text('How to Earn Coins?'), findsOneWidget);
      expect(find.text('Attempt Daily Tests'), findsOneWidget);
      expect(find.text('Win 1v1 Quiz Battles'), findsOneWidget);

      // Close modal
      final gotItBtn = find.text('Got It!');
      expect(gotItBtn, findsOneWidget);
      await tester.tap(gotItBtn);
      await tester.pumpAndSettle();

      expect(find.text('How to Earn Coins?'), findsNothing);
    });

    testWidgets('Interactive: Quick Action navigation callbacks trigger properly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool spinWheelTapped = false;
      bool quizBattleTapped = false;

      await tester.pumpWidget(buildRewardsScreen(
        onOpenSpinWheel: () => spinWheelTapped = true,
        onOpenBattle: () => quizBattleTapped = true,
      ));
      await tester.pumpAndSettle();

      // Tap Spin Lucky Wheel
      await tester.tap(find.text('Spin Lucky Wheel'));
      await tester.pumpAndSettle();
      expect(spinWheelTapped, isTrue);

      // Tap 1v1 Quiz Battle
      await tester.tap(find.text('1v1 Quiz Battle'));
      await tester.pumpAndSettle();
      expect(quizBattleTapped, isTrue);
    });

    testWidgets('Responsive Layout: Renders with zero overflow across 8 distinct viewports', (WidgetTester tester) async {
      final viewports = [
        const Size(320, 568),  // Compact Mobile (iPhone SE)
        const Size(360, 780),  // Android compact
        const Size(412, 915),  // Modern Android standard
        const Size(768, 1024), // Tablet portrait
        const Size(1024, 768), // Tablet landscape / Small laptop
        const Size(1280, 800), // Desktop HD
        const Size(1440, 900), // Large Desktop
        const Size(1920, 1080), // FHD Desktop
      ];

      for (final size in viewports) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(buildRewardsScreen());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Overflow detected at size $size');
      }

      tester.view.resetPhysicalSize();
    });
  });
}
