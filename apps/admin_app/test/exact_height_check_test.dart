import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_app/features/banners/widgets/create_banner_card.dart';
import 'package:design_system/design_system.dart';

void main() {
  testWidgets('Measure exact rendered height of Title field vs Banner Type dropdown in CreateBannerCard', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final titleController = TextEditingController();
    final linkController = TextEditingController();
    final priorityController = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: CreateBannerCard(
              titleController: titleController,
              linkController: linkController,
              priorityController: priorityController,
              imageUrl: null,
              onImageUrlChanged: (_) {},
              bannerType: 'promotional',
              displayMode: 'home_carousel',
              isActive: true,
              isScheduled: false,
              startDate: null,
              onStartDateChanged: (_) {},
              endDate: null,
              onEndDateChanged: (_) {},
              isSaving: false,
              onBannerTypeChanged: (_) {},
              onDisplayModeChanged: (_) {},
              onActiveToggled: (_) {},
              onScheduleToggled: (_) {},
              onSave: () {},
              onReset: () {},
              onPreview: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find the text fields
    final textFields = find.byType(AppTextField);
    debugPrint('Found ${textFields.evaluate().length} AppTextFields');
    for (int i = 0; i < textFields.evaluate().length; i++) {
      final field = textFields.at(i);
      final size = tester.getSize(field);
      debugPrint('AppTextField[$i] size: $size');

      // Find the inner InputDecorator
      final decorator = find.descendant(of: field, matching: find.byType(InputDecorator));
      if (decorator.evaluate().isNotEmpty) {
        debugPrint('  InputDecorator[$i] size: ${tester.getSize(decorator)}');
      }
    }

    // Find the dropdowns
    final dropdowns = find.byType(AppDropdown<String>);
    debugPrint('Found ${dropdowns.evaluate().length} AppDropdowns');
    for (int i = 0; i < dropdowns.evaluate().length; i++) {
      final drop = dropdowns.at(i);
      final size = tester.getSize(drop);
      debugPrint('AppDropdown[$i] size: $size');

      // Find the inner AnimatedContainer
      final container = find.descendant(of: drop, matching: find.byType(AnimatedContainer));
      if (container.evaluate().isNotEmpty) {
        debugPrint('  AnimatedContainer[$i] size: ${tester.getSize(container.first)}');
      }
    }
  });
}
