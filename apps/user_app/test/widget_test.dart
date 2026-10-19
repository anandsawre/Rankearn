import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/main.dart';

void main() {
  testWidgets('RankearnUserApp renders shell and tabs successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnUserApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app header and branding elements exist
    expect(find.text('Rankearn'), findsWidgets);
    expect(find.text('START LEARNING WITH EARNING'), findsOneWidget);

    // Verify bottom navigation tabs are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tests'), findsOneWidget);
    expect(find.text('Earn'), findsOneWidget);
    expect(find.text('Spin'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Verify home screen contents
    expect(find.text('Popular Test Series'), findsOneWidget);
    expect(find.text('Wallet Balance'), findsOneWidget);
  });

  testWidgets('UserApp navigation tab switching works', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnUserApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to Wallet tab
    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();

    // Verify wallet content is displayed
    expect(find.text('Available Balance'), findsOneWidget);
    expect(find.text('+ Top-up Coins'), findsOneWidget);
    expect(find.text('Withdraw (₹)'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
  });

  testWidgets('Spin tab renders LuckyWheelScreen with wheel and spin button', (WidgetTester tester) async {
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

  testWidgets('Tests tab clicking Start Test Now opens QuizScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnUserApp(),
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
    expect(find.text('Question 1 of 2'), findsOneWidget);
    expect(find.text('Which Mauryan ruler embraced Buddhism after the Kalinga War?'), findsOneWidget);
    expect(find.text('Save & Next →'), findsOneWidget);
  });

  testWidgets('Earn tab clicking Enter 1v1 Arena opens BattleScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnUserApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to Earn tab
    await tester.tap(find.text('Earn'));
    await tester.pumpAndSettle();

    // Tap Enter 1v1 Arena button
    final battleButton = find.text('Enter 1v1 Arena (Stake 20 Coins)');
    await tester.ensureVisible(battleButton);
    await tester.tap(battleButton);
    await tester.pumpAndSettle();

    // Verify BattleScreen is active
    expect(find.text('1v1 Live Arena ⚔️'), findsOneWidget);
    expect(find.text('VS'), findsOneWidget);
    expect(find.text('Round 1 of 5'), findsOneWidget);
  });
}
