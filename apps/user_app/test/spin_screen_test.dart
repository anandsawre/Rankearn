import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/features/spin/lucky_wheel_screen.dart';
import 'package:user_app/features/spin/components/spin_header.dart';
import 'package:user_app/features/spin/components/spin_hero_banner.dart';
import 'package:user_app/features/spin/components/spin_stats_row.dart';
import 'package:user_app/features/spin/components/spin_wheel.dart';
import 'package:user_app/features/spin/components/spin_action_button.dart';
import 'package:user_app/features/spin/services/spin_service.dart';
import 'package:user_app/features/spin/models/spin_reward_model.dart';

final List<SpinRewardItem> _testRewards = List.generate(
  8,
  (i) => SpinRewardItem(
    id: 'test_reward_$i',
    title: '${(i + 1) * 10}',
    subtitle: 'Coins',
    coins: (i + 1) * 10,
    type: SpinRewardType.coins,
    badgeText: '+${(i + 1) * 10}',
    description: 'Test coins reward',
    cardTint: const Color(0xFFFEF3C7),
    accentColor: const Color(0xFFF59E0B),
  ),
);

Widget _buildTestApp({
  required double width,
  required double height,
  VoidCallback? onBack,
  VoidCallback? onOpenWallet,
  void Function(int)? onRewardClaimed,
}) {
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
        child: LuckyWheelScreen(
          currentCoins: 1250,
          onBack: onBack ?? () {},
          onOpenWallet: onOpenWallet,
          onRewardClaimed: onRewardClaimed,
          initialRewards: _testRewards,
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SpinService.resetForTesting();
    SpinService.setMockRewardsForTesting(_testRewards);
  });

  group('Rankearn Spin & Win — Responsive Viewport Tests', () {
    const viewports = [
      (name: 'Mobile 360px', width: 360.0, height: 740.0),
      (name: 'Mobile 390px (iPhone 14)', width: 390.0, height: 844.0),
      (name: 'Mobile 430px (iPhone 14 Pro Max)', width: 430.0, height: 932.0),
      (name: 'Tablet 768px (iPad Mini)', width: 768.0, height: 1024.0),
      (name: 'Desktop 1024px', width: 1024.0, height: 768.0),
      (name: 'Desktop 1440px', width: 1440.0, height: 900.0),
    ];

    for (final vp in viewports) {
      testWidgets(
        'Renders all reference components with zero overflow on ${vp.name}',
        (tester) async {
          tester.view.physicalSize = Size(vp.width, vp.height);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);

          await tester.pumpWidget(
            _buildTestApp(width: vp.width, height: vp.height),
          );
          await tester.pump();

          // 1. Verify Header
          expect(find.byType(SpinHeader), findsOneWidget);
          expect(find.text('Spin & Win'), findsOneWidget);
          expect(find.text('1,250'), findsOneWidget);

          // 2. Verify Hero Banner
          expect(find.byType(SpinHeroBanner), findsOneWidget);
          expect(find.text('Win coins, rewards and more!'), findsOneWidget);

          // 3. Verify Spin Stats Row
          expect(find.byType(SpinStatsRow), findsOneWidget);
          expect(find.text("Today's\nSpins"), findsOneWidget);
          expect(find.text('Next Spin In'), findsOneWidget);

          // 4. Verify Interactive Spin Wheel
          expect(find.byType(SpinWheel), findsOneWidget);
          expect(find.text('SPIN'), findsOneWidget);

          // 5. Verify Spin Action Button
          expect(find.byType(SpinActionButton), findsOneWidget);
          expect(find.text('Spin Now'), findsOneWidget);

          // 6. Verify Possible Rewards Showcase is removed
          expect(find.text('Possible Rewards'), findsNothing);

          // Assert 0 RenderFlex overflow errors
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('Spin & Win Screen Interactions & Callbacks', () {
    testWidgets('Tapping back button triggers onBack callback', (tester) async {
      bool backCalled = false;
      await tester.pumpWidget(
        _buildTestApp(width: 390, height: 844, onBack: () => backCalled = true),
      );
      await tester.pump();

      final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pump();

      expect(backCalled, isTrue);
    });

    testWidgets('Tapping coin balance chip triggers onOpenWallet callback', (
      tester,
    ) async {
      bool walletCalled = false;
      await tester.pumpWidget(
        _buildTestApp(
          width: 390,
          height: 844,
          onOpenWallet: () => walletCalled = true,
        ),
      );
      await tester.pump();

      final walletChip = find.text('1,250');
      expect(walletChip, findsOneWidget);

      await tester.tap(walletChip);
      await tester.pump();

      expect(walletCalled, isTrue);
    });

    testWidgets('Tapping Spin Now executes rotation and awards coins', (
      tester,
    ) async {
      int? coinsWon;
      await tester.pumpWidget(
        _buildTestApp(
          width: 390,
          height: 844,
          onRewardClaimed: (c) => coinsWon = c,
        ),
      );
      await tester.pump();

      final spinButton = find.text('Spin Now');
      expect(spinButton, findsOneWidget);

      // Tap Spin Now button
      await tester.tap(spinButton);
      await tester.pump();

      // State is spinning
      expect(find.text('Good Luck!'), findsOneWidget);

      // Advance animation through rotations (4200ms)
      await tester.pump(const Duration(milliseconds: 4400));
      await tester.pump(const Duration(milliseconds: 500));

      // Congratulations dialog appears
      expect(find.text('Congratulations! 🎉'), findsOneWidget);
      expect(find.text('Claim & Continue'), findsOneWidget);

      // Tap Claim & Continue
      await tester.tap(find.text('Claim & Continue'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Dialog dismisses
      expect(find.text('Congratulations! 🎉'), findsNothing);
      expect(coinsWon, isNotNull);
    });

    testWidgets(
      'Spin tab hides main AppHeader and only shows green SpinHeader',
      (tester) async {
        await tester.pumpWidget(_buildTestApp(width: 390, height: 844));
        await tester.pump();

        // Only SpinHeader is rendered
        expect(find.byType(SpinHeader), findsOneWidget);
        // Main header branding is not rendered on Spin tab
        expect(find.text('Learn • Practice • Earn'), findsNothing);
      },
    );
  });
}
