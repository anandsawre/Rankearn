import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_layer/data_layer.dart';
import 'package:user_app/main.dart';

void main() {
  testWidgets('RankearnUserApp renders shell, header, and all 6 navigation tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnUserApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app header and branding elements exist
    expect(find.text('Rankearn'), findsWidgets);
    expect(find.text('START LEARNING WITH EARNING'), findsOneWidget);

    // Verify all 6 bottom navigation tabs are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tests'), findsOneWidget);
    expect(find.text('Earn'), findsOneWidget);
    expect(find.text('Spin'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Verify Dashboard home screen contents
    expect(find.text('Popular Mock Tests'), findsOneWidget);
    expect(find.text('Avg Score'), findsOneWidget);
  });

  testWidgets('UserApp Wallet tab renders stats, actions, and transaction ledger', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnUserApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to Wallet tab
    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();

    // Verify wallet content is displayed with pixel parity to React Wallet.tsx
    expect(find.text('BALANCE'), findsOneWidget);
    expect(find.text('TOTAL EARNED'), findsOneWidget);
    expect(find.text('TOTAL SPENT'), findsOneWidget);
    expect(find.text('WITHDRAW'), findsOneWidget);
    expect(find.text('Add Coins'), findsOneWidget);
    expect(find.text('Withdraw (₹)'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
  });

  testWidgets('UserApp Spin tab renders LuckyWheelScreen with custom canvas wheel and spin button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnUserApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to Spin tab
    await tester.tap(find.text('Spin'));
    await tester.pumpAndSettle();

    // Verify Lucky Wheel UI is rendered
    expect(find.text('Daily Lucky Wheel 🎡'), findsOneWidget);
    expect(find.text('Spin the Wheel to Win Coins!'), findsOneWidget);
    expect(find.text('SPIN FOR FREE'), findsOneWidget);
    expect(find.text('SPIN'), findsOneWidget);
  });

  testWidgets('UserApp Profile tab renders candidate header, pro pass, and account details', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnUserApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Verify profile contents matching React Profile.tsx
    expect(find.text('Vikram Singh'), findsOneWidget);
    expect(find.text('70th BPSC Aspirant'), findsOneWidget);
    expect(find.text('Rankearn PRO Pass'), findsOneWidget);
    expect(find.text('Account Details'), findsOneWidget);
    expect(find.text('Sign Out from Account'), findsOneWidget);
  });

  testWidgets('Tests tab clicking Start Test Now opens QuizScreen', (WidgetTester tester) async {
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

    // Switch to Tests tab
    await tester.tap(find.text('Tests'));
    await tester.pumpAndSettle();

    // Click Start Test Now on the first available test
    final startButton = find.text('Start Test Now').first;
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pumpAndSettle();

    // Verify QuizScreen is rendered with question text, options, and timer
    expect(find.text('Question 1 of 5'), findsOneWidget);
    expect(find.text('When was the state of Bihar carved out from the Bengal Presidency?'), findsOneWidget);
    expect(find.text('Save & Next →'), findsOneWidget);
  });

  testWidgets('Earn tab clicking 1v1 Battle then Find Opponent opens BattleScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnUserApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to Earn tab
    await tester.tap(find.text('Earn'));
    await tester.pumpAndSettle();

    // Switch to 1v1 Battle subtab
    await tester.tap(find.text('1v1 Battle ⚔️'));
    await tester.pumpAndSettle();

    // Tap Find Random Opponent button
    final battleButton = find.text('Find Random Opponent ⚔️');
    await tester.ensureVisible(battleButton);
    await tester.tap(battleButton);
    await tester.pumpAndSettle();

    // Verify BattleScreen is active
    expect(find.text('1v1 Live Arena ⚔️'), findsOneWidget);
    expect(find.text('VS'), findsOneWidget);
    expect(find.text('Round 1 of 5'), findsOneWidget);
  });
}
