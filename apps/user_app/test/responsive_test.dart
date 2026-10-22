import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/main.dart';

void main() {
  const viewports = [
    ('Compact Mobile (320x568)', Size(320, 568)),
    ('Standard Mobile (360x780)', Size(360, 780)),
    ('Large Mobile (412x915)', Size(412, 915)),
    ('Tablet Portrait (768x1024)', Size(768, 1024)),
    ('Tablet Landscape (1024x768)', Size(1024, 768)),
    ('Desktop / Web (1440x900)', Size(1440, 900)),
    ('Full HD Desktop (1920x1080)', Size(1920, 1080)),
  ];

  for (final vp in viewports) {
    testWidgets('Dashboard renders with zero overflow on ${vp.$1}', (WidgetTester tester) async {
      tester.view.physicalSize = vp.$2;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: RankearnUserApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify essential sections exist without layout exception
      expect(find.text('Rankearn'), findsWidgets);
      expect(find.text('Start Learning'), findsOneWidget);
      expect(find.text('Mock Tests'), findsOneWidget);
      expect(find.text('Explore by Subject'), findsOneWidget);
    });
  }
}
