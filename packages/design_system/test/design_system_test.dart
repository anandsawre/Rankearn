import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

void main() {
  group('Design System Tokens', () {
    test('Brand colors are correctly defined matching reference design', () {
      expect(AppColors.brandPurple, const Color(0xFF5636F5));
      expect(AppColors.brandGreen, const Color(0xFF10B981));
      expect(AppColors.brandYellow, const Color(0xFFFFD633));
      expect(AppColors.background, const Color(0xFFF4F7FF));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.textPrimary, const Color(0xFF101A3A));
      expect(AppColors.border, const Color(0xFFE3EAF7));
    });

    test('Spacing and radii scales are valid', () {
      expect(AppSpacing.pagePaddingMobile, 16.0);
      expect(AppRadii.md, 12.0);
      expect(AppRadii.lg, 16.0);
      expect(AppRadii.xl, 24.0);
    });

    test('AppTheme generates valid light ThemeData', () {
      final theme = AppTheme.lightTheme;
      expect(theme.primaryColor, AppColors.brandPurple);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.brandPurple);
      expect(theme.colorScheme.secondary, AppColors.brandGreen);
    });
  });

  group('Design System Widgets', () {
    testWidgets('AppButton renders label and responds to tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppButton(
              label: 'Test Button',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      await tester.tap(find.text('Test Button'));
      expect(tapped, isTrue);
    });

    testWidgets('AppCoinPill renders coin count and add button', (WidgetTester tester) async {
      bool addTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppCoinPill(
              coins: 1250,
              onAddTap: () => addTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('1,250'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      expect(addTapped, isTrue);
    });

    testWidgets('MetricCard renders label, value and responds to tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: MetricCard(
              icon: const Icon(Icons.monetization_on_rounded),
              label: 'My Coins',
              value: '1,250',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('My Coins'), findsOneWidget);
      expect(find.text('1,250'), findsOneWidget);
      await tester.tap(find.text('My Coins'));
      expect(tapped, isTrue);
    });

    testWidgets('FeatureShortcutCard renders label and responds to tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FeatureShortcutCard(
              icon: Icons.feed_rounded,
              label: 'Mock Tests',
              iconBackgroundColor: AppColors.brandPurple,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Mock Tests'), findsOneWidget);
      await tester.tap(find.text('Mock Tests'));
      expect(tapped, isTrue);
    });
  });
}
