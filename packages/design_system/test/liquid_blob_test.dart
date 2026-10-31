import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LiquidBlobWidget (Design 07) Tests', () {
    testWidgets('Renders default static LiquidBlobWidget without overflow',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LiquidBlobWidget(
                width: 320,
                height: 190,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LiquidBlobWidget), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Renders animated LiquidBlobWidget with testing guard',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LiquidBlobWidget(
                width: 320,
                height: 190,
                isAnimated: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LiquidBlobWidget), findsOneWidget);
    });

    testWidgets('Renders with child widget inside blob', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LiquidBlobWidget(
                width: 320,
                height: 190,
                child: Text('Rankearn Liquid Blob'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rankearn Liquid Blob'), findsOneWidget);
    });

    testWidgets('Renders with custom colors and toggles', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LiquidBlobWidget(
                width: 280,
                height: 160,
                gradientColors: [
                  Color(0xFFFFE65C),
                  Color(0xFFFFB800),
                  Color(0xFFFF7800),
                ],
                showHalftoneDots: false,
                showFloatingDroplets: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LiquidBlobWidget), findsOneWidget);
    });
  });
}

