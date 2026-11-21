import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/components/cards/exam_category_card.dart';

void main() {
  testWidgets('ExamCategoryCard renders horizontally by default', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExamCategoryCard(
            index: 0,
            id: 'railway',
            name: 'Railway Technician',
            badgeText: '2 Mock • 0 Sec',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    // Verify Title and Badge Text
    expect(find.text('Railway Technician'), findsOneWidget);
    expect(find.text('2 Mock • 0 Sec'), findsOneWidget);

    // Verify horizontal dimensions (width: 190, height: 66)
    final RenderBox box = tester.renderObject(find.byType(ExamCategoryCard));
    expect(box.size.width, 190.0);
    expect(box.size.height, 66.0);

    // Verify tap callback
    await tester.tap(find.byType(ExamCategoryCard));
    expect(tapped, isTrue);
  });
}
