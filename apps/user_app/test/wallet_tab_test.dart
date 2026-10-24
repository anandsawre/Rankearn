import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import 'package:user_app/features/wallet/wallet_screen.dart';
import 'package:user_app/features/wallet/components/wallet_hero_card.dart';
import 'package:user_app/features/wallet/components/wallet_summary_card.dart';
import 'package:user_app/features/wallet/components/wallet_transaction_filters.dart';
import 'package:user_app/features/wallet/components/wallet_transaction_table.dart';
import 'package:user_app/features/wallet/components/wallet_transaction_tile.dart';
import 'package:user_app/features/wallet/withdrawal/withdrawal_panel_web.dart';
import 'package:user_app/features/wallet/components/wallet_quick_actions.dart';
import 'package:user_app/features/wallet/components/earnings_summary_card.dart';
import 'package:user_app/features/wallet/components/promotional_banners.dart';

void main() {
  final sampleProfile = UserProfile(
    id: 'usr_vikram_70',
    name: 'Vikram Singh',
    email: 'vikram.singh@rankearn.in',
    phone: '+91 98765 43210',
    coins: 1250,
    totalEarned: 12500,
    totalSpent: 5000,
    subscriptionStatus: 'premium',
    examPreparingFor: '70th BPSC Aspirant',
    state: 'Bihar, India',
    referralCode: 'VIKRAM2026',
    createdAt: DateTime(2026, 10, 1),
  );

  final sampleTxs = [
    WalletTransactionModel(
      id: 'tx_01',
      userId: 'usr_vikram_70',
      amount: 50,
      type: 'earn',
      category: 'quiz_reward',
      title: 'Quiz Test Reward',
      referenceId: 'Completed Full Test (RRB)',
      balanceAfter: 1250,
      createdAt: DateTime(2026, 10, 24, 18, 15),
    ),
    WalletTransactionModel(
      id: 'tx_02',
      userId: 'usr_vikram_70',
      amount: 100,
      type: 'earn',
      category: 'battle_win',
      title: '1v1 Battle Win',
      referenceId: 'Won against Rohit',
      balanceAfter: 1200,
      createdAt: DateTime(2026, 10, 24, 17, 40),
    ),
    WalletTransactionModel(
      id: 'tx_03',
      userId: 'usr_vikram_70',
      amount: 20,
      type: 'earn',
      category: 'lucky_wheel_win',
      title: 'Spin & Win',
      referenceId: 'Daily Spin Reward',
      balanceAfter: 1100,
      createdAt: DateTime(2026, 10, 24, 16, 12),
    ),
    WalletTransactionModel(
      id: 'tx_06',
      userId: 'usr_vikram_70',
      amount: -1000,
      type: 'spend',
      category: 'withdrawal',
      title: 'Withdrawal to UPI',
      referenceId: 'UPI: vikram@upi',
      balanceAfter: 830,
      createdAt: DateTime(2026, 10, 21, 15, 10),
    ),
  ];

  Widget buildWalletTestScreen({
    UserProfile? profile,
    List<WalletTransactionModel>? txs,
    ValueChanged<UserNavTab>? onNavigateToTab,
    ValueChanged<int>? onCoinUpdate,
    VoidCallback? onCoinsUpdated,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: WalletScreen(
          profile: profile ?? sampleProfile,
          initialTransactions: txs ?? sampleTxs,
          onCoinsUpdated: onCoinsUpdated ?? () {},
          onNavigateToTab: onNavigateToTab,
          onCoinUpdate: onCoinUpdate,
        ),
      ),
    );
  }

  group('Desktop Full-Width Wallet Dashboard Tests', () {
    testWidgets(
      'Renders full-width desktop layout with two columns and promotional banners at 1440px',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(buildWalletTestScreen());
        await tester.pumpAndSettle();

        // Verify Desktop Hero Banner
        expect(find.byType(DesktopWalletHeroBanner), findsOneWidget);
        expect(find.text('My Wallet'), findsOneWidget);
        expect(
          find.text('Your coins, earnings and rewards in one place.'),
          findsOneWidget,
        );

        // Verify Desktop Summary Row (3 Cards)
        expect(find.byType(DesktopWalletSummaryRow), findsOneWidget);
        expect(find.text('Total Coins'), findsOneWidget);
        expect(find.text('Total Earned'), findsWidgets);
        expect(find.text('Total Withdrawn'), findsWidgets);
        expect(find.text('1,250'), findsWidgets);
        expect(find.text('12,500'), findsWidgets);
        expect(find.text('5,000'), findsWidgets);

        // Verify Desktop Transaction Filters (Native Compliant, no Withdrawals)
        expect(find.byType(WalletTransactionFilters), findsOneWidget);
        expect(find.text('All Transactions'), findsOneWidget);
        expect(find.text('Earned'), findsOneWidget);
        expect(find.text('Withdrawals'), findsNothing);
        expect(find.text('Rewards'), findsOneWidget);
        expect(find.text('Offers'), findsOneWidget);

        // Verify Desktop Full-Width Transaction Table
        expect(find.byType(WalletTransactionTable), findsOneWidget);
        expect(find.text('#'), findsOneWidget);
        expect(find.text('Type'), findsOneWidget);
        expect(find.text('Description'), findsOneWidget);
        expect(find.text('Date & Time'), findsOneWidget);
        expect(find.text('Coins'), findsOneWidget);
        expect(find.text('Balance'), findsOneWidget);
        expect(find.text('Quiz Test Reward'), findsOneWidget);
        expect(find.text('1v1 Battle Win'), findsOneWidget);

        // Verify Right Column: In Native APK build, Withdraw to UPI panel is absent
        expect(find.text('Withdraw to UPI'), findsNothing);
        expect(find.text('Withdraw Now'), findsNothing);

        // Verify Right Column: Quick Actions Card (shows compliant learning actions)
        expect(find.byType(DesktopQuickActionsCard), findsOneWidget);
        expect(find.text('Quick Actions'), findsOneWidget);
        expect(find.text('Withdraw'), findsNothing);
        expect(find.text('Guide'), findsOneWidget);
        expect(find.text('History'), findsOneWidget);
        expect(find.text('Earn More'), findsOneWidget);
        expect(find.text('Redeem'), findsOneWidget);

        // Verify Right Column: Your Earnings Card
        expect(find.byType(EarningsSummaryCard), findsOneWidget);
        expect(find.text('Your Earnings'), findsOneWidget);
        expect(find.text('View Details'), findsOneWidget);

        // Verify Bottom Promotional Banners
        expect(find.byType(DesktopPromotionalBannersSection), findsOneWidget);
        expect(find.text('Complete Daily Tasks'), findsOneWidget);
        expect(find.text('View Tasks'), findsOneWidget);
        expect(find.text('Refer & Earn'), findsOneWidget);
        expect(find.text('Refer Now'), findsOneWidget);
      },
    );

    testWidgets(
      'Desktop Transaction Filters toggle displayed records correctly',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(buildWalletTestScreen());
        await tester.pumpAndSettle();

        // Initially all transactions visible
        expect(find.text('Quiz Test Reward'), findsOneWidget);
        expect(find.text('1v1 Battle Win'), findsOneWidget);

        // Tap "Earned" filter
        await tester.tap(find.text('Earned'));
        await tester.pumpAndSettle();

        expect(find.text('Quiz Test Reward'), findsOneWidget);

        // Tap "Rewards" filter
        await tester.tap(find.text('Rewards'));
        await tester.pumpAndSettle();

        // Tap back to "All Transactions"
        await tester.tap(find.text('All Transactions'));
        await tester.pumpAndSettle();

        expect(find.text('Quiz Test Reward'), findsOneWidget);
        expect(find.text('1v1 Battle Win'), findsOneWidget);
      },
    );

    testWidgets(
      'Web-Only Withdrawal Panel validates UPI and deducts coins on success',
      (tester) async {
        int? submittedCoins;
        String? submittedUpi;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: WithdrawalPanel(
                  userCoins: 1250,
                  onWithdraw: (
                    {required coins, required payoutAmount, required upiId}
                  ) async {
                    submittedCoins = coins;
                    submittedUpi = upiId;
                    return true;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify presets and UI
        expect(find.text('Withdraw to UPI'), findsOneWidget);
        expect(find.text('1 Coin = ₹0.10'), findsOneWidget);
        expect(find.text('1,000 Coins'), findsOneWidget);
        expect(find.text('2,500 Coins'), findsOneWidget);

        // Tap Withdraw Now without entering UPI ID
        await tester.tap(find.text('Withdraw Now'));
        await tester.pumpAndSettle();

        // Validation error message appears
        expect(
          find.text('Please enter a valid UPI ID (e.g. yourname@upi)'),
          findsOneWidget,
        );

        // Enter valid UPI ID
        await tester.enterText(find.byType(TextField).first, 'vikram@okaxis');
        await tester.pumpAndSettle();

        // Submit withdrawal
        await tester.tap(find.text('Withdraw Now'));
        await tester.pumpAndSettle();

        // Verify callback params
        expect(submittedCoins, 1000);
        expect(submittedUpi, 'vikram@okaxis');
      },
    );
  });

  group('Mobile Responsive Wallet Dashboard Tests', () {
    testWidgets('Renders faithful mobile single-column layout at 390px', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildWalletTestScreen());
      await tester.pumpAndSettle();

      // Verify Mobile Hero Section with "How it works?" button
      expect(find.byType(MobileWalletHeroSection), findsOneWidget);
      expect(find.text('My Wallet'), findsOneWidget);
      expect(find.text('How it works?'), findsOneWidget);
      expect(find.text('Total Coins'), findsOneWidget);
      expect(find.text('1 Coin = ₹0.10'), findsOneWidget);
      expect(find.text('Redeem for rewards'), findsOneWidget);
      expect(find.text('Unlock Test Series'), findsOneWidget);

      // Verify 4 Mobile Quick Actions (Clean Native APK Compliant)
      expect(find.byType(MobileQuickActionsRow), findsOneWidget);
      expect(find.text('Withdraw'), findsNothing);
      expect(find.text('Guide'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Earn More'), findsOneWidget);
      expect(find.text('Redeem'), findsOneWidget);

      // Verify Mobile Transaction Tiles
      expect(find.byType(WalletTransactionTile), findsWidgets);
      expect(find.text('Quiz Test Reward'), findsOneWidget);

      // Verify Daily Tasks Banner at bottom
      expect(find.byType(DailyTasksBanner), findsOneWidget);
    });

    testWidgets('Tapping How it works button opens informational modal', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildWalletTestScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('How it works?'));
      await tester.pumpAndSettle();

      expect(find.text('How Wallet Works'), findsOneWidget);
      expect(find.text('Coin Value & Rate'), findsOneWidget);
      expect(find.text('Fast UPI Withdrawals'), findsOneWidget);

      await tester.tap(find.text('Got It'));
      await tester.pumpAndSettle();

      expect(find.text('How Wallet Works'), findsNothing);
    });

    testWidgets('Tapping Refer Now opens Refer & Earn modal with user code', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildWalletTestScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Refer Now'));
      await tester.pumpAndSettle();

      expect(find.text('Invite Friends & Earn Coins'), findsOneWidget);
      expect(find.text('VIKRAM2026'), findsOneWidget);
    });
  });

  group('Full-Width & Zero Overflow Responsive Verification', () {
    const viewports = [
      Size(360, 640),
      Size(390, 844),
      Size(430, 932),
      Size(768, 1024),
      Size(1024, 768),
      Size(1366, 768),
      Size(1440, 900),
      Size(1920, 1080),
    ];

    for (final size in viewports) {
      testWidgets(
        'Renders with zero RenderFlex overflow on viewport ${size.width}x${size.height}',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          await tester.pumpWidget(buildWalletTestScreen());
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
