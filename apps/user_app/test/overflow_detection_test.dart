import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/main.dart';

void main() {
  testWidgets('Check for ANY RenderFlex overflow across all screens and screen sizes', (WidgetTester tester) async {
    final List<String> overflowErrors = [];

    // Capture all Flutter layout/rendering errors
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('overflowed by') ||
          details.exceptionAsString().contains('RenderFlex')) {
        overflowErrors.add('${details.exceptionAsString()} in ${details.context?.toDescription()} \n ${details.summary}');
      }
      originalOnError?.call(details);
    };

    final sizes = [
      const Size(1920, 1080),
      const Size(1440, 900),
      const Size(1200, 800),
      const Size(1024, 768),
      const Size(768, 1024),
      const Size(414, 896),
      const Size(375, 667),
      const Size(320, 568),
    ];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: RankearnUserApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Check all tabs if desktop top nav or bottom nav
      for (final tab in ['Tests', 'Live', 'Battle', 'Rewards', 'Home']) {
        final finder = find.text(tab);
        if (finder.evaluate().isNotEmpty) {
          await tester.tap(finder.first);
          await tester.pumpAndSettle();
        }
      }
    }

    tester.view.resetPhysicalSize();
    FlutterError.onError = originalOnError;

    if (overflowErrors.isNotEmpty) {
      // ignore: avoid_print
      print('FOUND OVERFLOWS:');
      for (final err in overflowErrors) {
        // ignore: avoid_print
        print('--- $err');
      }
    }
    expect(overflowErrors, isEmpty, reason: 'Found RenderFlex overflows: ${overflowErrors.join("\n")}');
  });
}
