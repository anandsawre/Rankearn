import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';

void main() {
  testWidgets('Test individual cards and sections for bottom overflows', (WidgetTester tester) async {
    final List<String> errors = [];
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details.exceptionAsString());
      oldHandler?.call(details);
    };

    // Test SubjectCard inside various SizedBox heights
    for (double h = 100; h <= 180; h += 10) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: h,
              child: SubjectCard(
                title: 'General\nScience',
                questionCount: '1200+ Qs',
                icon: Icons.science,
                accentColor: Colors.blue,
                backgroundColor: Colors.blue.shade50,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // Test LiveEventCard inside various SizedBox heights
    for (double h = 140; h <= 200; h += 10) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: h,
              child: LiveEventCard(
                title: 'General Science Mega Test',
                dateTime: '21 Oct 2026 • 06:00 PM',
                questionCount: '120 Questions',
                icon: const Icon(Icons.star),
                actionType: LiveEventActionType.joinNow,
                onAction: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // Test PromoBannerCard inside various heights
    for (double h = 100; h <= 200; h += 10) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: h,
              child: PromoBannerCard.dailyChallenge(onPlay: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    FlutterError.onError = oldHandler;
    // ignore: avoid_print
    print('SECTION CARD TEST ERRORS: $errors');
  });
}
