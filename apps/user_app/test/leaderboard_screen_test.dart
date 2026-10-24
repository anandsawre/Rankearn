import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_layer/data_layer.dart';
import 'package:user_app/features/leaderboard/leaderboard_screen.dart';
import 'package:user_app/features/leaderboard/components/leaderboard_hero_banner.dart';
import 'package:user_app/features/leaderboard/components/leaderboard_filter_tabs.dart';
import 'package:user_app/features/leaderboard/components/leaderboard_podium.dart';
import 'package:user_app/features/leaderboard/components/leaderboard_table.dart';
import 'package:user_app/features/leaderboard/components/leaderboard_mobile_list.dart';
import 'package:user_app/features/leaderboard/components/personal_rank_summary.dart';
import 'package:user_app/features/leaderboard/components/leaderboard_sidebar.dart';
import 'package:user_app/main.dart';

Widget _buildLeaderboardApp({
  required double width,
  required double height,
  UserProfile? profile,
}) {
  final testProfile =
      profile ??
      UserProfile(
        id: 'usr_vikram_70',
        name: 'Vikram Singh',
        email: 'vikram.singh@rankearn.in',
        coins: 14200,
        subscriptionStatus: 'premium',
        examPreparingFor: '70th BPSC Aspirant',
        state: 'Bihar, India',
        createdAt: DateTime(2026, 10, 1),
      );

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, height),
        padding: const EdgeInsets.only(top: 24),
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: Scaffold(body: LeaderboardScreen(profile: testProfile)),
      ),
    ),
  );
}

void main() {
  group('Rankearn Leaderboard — Responsive Viewport & Overflow Tests', () {
    const viewports = [
      (name: 'Mobile 360px', width: 360.0, height: 740.0),
      (name: 'Mobile 390px (iPhone 14)', width: 390.0, height: 844.0),
      (name: 'Mobile 430px (iPhone 14 Pro Max)', width: 430.0, height: 932.0),
      (name: 'Tablet 768px (iPad Mini)', width: 768.0, height: 1024.0),
      (name: 'Desktop 1024px', width: 1024.0, height: 768.0),
      (
        name: 'Desktop 1440px (Reference Image 1)',
        width: 1440.0,
        height: 900.0,
      ),
    ];

    for (final vp in viewports) {
      testWidgets('Renders with zero RenderFlex overflow on ${vp.name}', (
        tester,
      ) async {
        tester.view.physicalSize = Size(vp.width, vp.height);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildLeaderboardApp(width: vp.width, height: vp.height),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LeaderboardScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Rankearn Leaderboard — Desktop View (Reference Image 1)', () {
    testWidgets(
      'Renders all desktop components, hero banner, table and sidebars',
      (tester) async {
        tester.view.physicalSize = const Size(1440.0, 900.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildLeaderboardApp(width: 1440.0, height: 900.0),
        );
        await tester.pumpAndSettle();

        // Hero banner
        expect(find.byType(LeaderboardHeroBanner), findsOneWidget);
        expect(find.text('Top Learners'), findsOneWidget);
        expect(find.text('Compete • Improve • Earn More'), findsOneWidget);

        // Desktop filter tabs
        expect(find.byType(LeaderboardFilterTabs), findsOneWidget);
        expect(find.text('Global'), findsWidgets);
        expect(find.text('Friends'), findsWidgets);
        expect(find.text('Weekly'), findsWidgets);
        expect(find.text('Monthly'), findsWidgets);
        expect(find.text('All Time'), findsWidgets);

        // Table
        expect(find.byType(LeaderboardTable), findsOneWidget);
        expect(find.text('Rohit Kumar'), findsWidgets);
        expect(find.text('Anjali Verma'), findsWidgets);
        expect(find.text('Vikram Singh'), findsWidgets);

        // Current user highlight row
        expect(find.text('You'), findsWidgets);

        // Sidebar cards
        expect(find.byType(LeaderboardSidebar), findsOneWidget);
        expect(find.text('Your Rank'), findsOneWidget);
        expect(find.text('Top 3 This Week'), findsOneWidget);
        expect(find.text('Leaderboard Filters'), findsOneWidget);
        expect(find.text('How to Climb Ranks?'), findsOneWidget);
      },
    );

    testWidgets('Desktop filter tabs switch cleanly without errors', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440.0, 900.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildLeaderboardApp(width: 1440.0, height: 900.0),
      );
      await tester.pumpAndSettle();

      // Tap 'Weekly' tab
      final weeklyFinder = find.widgetWithText(InkWell, 'Weekly');
      if (weeklyFinder.evaluate().isNotEmpty) {
        await tester.tap(weeklyFinder.first);
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
    });
  });

  group('Rankearn Leaderboard — Mobile View (Reference Image 2)', () {
    testWidgets(
      'Renders mobile header, 3D podium, ranked list, and sticky personal rank card',
      (tester) async {
        tester.view.physicalSize = const Size(390.0, 844.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildLeaderboardApp(width: 390.0, height: 844.0),
        );
        await tester.pumpAndSettle();

        // Mobile header
        expect(find.text('Leaderboard'), findsWidgets);
        expect(
          find.text('Compete, improve and earn more coins'),
          findsOneWidget,
        );

        // Mobile filter pills
        expect(find.byType(LeaderboardFilterTabs), findsOneWidget);

        // 3D Podium with Top 3
        expect(find.byType(LeaderboardPodium), findsOneWidget);
        expect(find.text('Rohit Kumar'), findsWidgets);
        expect(find.text('Anjali Verma'), findsWidgets);
        expect(find.text('Saurabh Yadav'), findsWidgets);

        // Mobile list for ranks 4+
        expect(find.byType(LeaderboardMobileList), findsOneWidget);
        expect(find.text('Priya Singh'), findsWidgets);

        // Personal rank summary card
        expect(find.byType(PersonalRankSummary), findsOneWidget);
        expect(find.text('#7'), findsWidgets);
        expect(find.text('720'), findsWidgets);
        expect(find.text('Tests'), findsWidgets);
        expect(find.text('76%'), findsWidgets);
        expect(find.text('Win Rate'), findsWidgets);
        expect(find.text('14,200'), findsWidgets);
      },
    );

    testWidgets('Mobile filter pill tap changes active period', (tester) async {
      tester.view.physicalSize = const Size(390.0, 844.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildLeaderboardApp(width: 390.0, height: 844.0),
      );
      await tester.pumpAndSettle();

      // Tap 'This Week' pill
      final weekPill = find.text('This Week');
      expect(weekPill, findsOneWidget);
      await tester.tap(weekPill);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('Rankearn App Integration — UserAppShell Navigation', () {
    testWidgets('Navigating to Leaderboard tab displays LeaderboardScreen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440.0, 900.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const RankearnUserApp(showAuthInitially: false));
      await tester.pumpAndSettle();

      // Look for Leaderboard in AppHeader
      final leaderboardTab = find.text('Leaderboard');
      expect(leaderboardTab, findsWidgets);

      await tester.ensureVisible(leaderboardTab.first);
      await tester.tap(leaderboardTab.first);
      await tester.pumpAndSettle();

      expect(find.byType(LeaderboardScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
