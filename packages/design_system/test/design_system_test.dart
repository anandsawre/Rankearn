import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

void main() {
  group('Design System Tokens', () {
    test('Brand colors are correctly defined', () {
      expect(AppColors.brandPrimary, const Color(0xFF10B981));
      expect(AppColors.background, const Color(0xFFF8FAF9));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.coinGold, const Color(0xFFF59E0B));
      expect(AppColors.errorRose, const Color(0xFFF43F5E));
    });

    test('Spacing and radii scales are valid', () {
      expect(AppSpacing.pagePaddingMobile, 16.0);
      expect(AppRadii.md, 12.0);
      expect(AppRadii.lg, 16.0);
    });

    test('AppTheme generates valid light ThemeData', () {
      final theme = AppTheme.lightTheme;
      expect(theme.primaryColor, AppColors.brandPrimary);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.brandPrimary);
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

    testWidgets('AppCoinPill renders coin count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AppCoinPill(coins: 500),
          ),
        ),
      );

      expect(find.text('500'), findsOneWidget);
      expect(find.byIcon(Icons.monetization_on), findsOneWidget);
    });
  });
}
