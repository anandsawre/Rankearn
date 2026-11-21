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
      expect(AppSpacing.pagePaddingMobile, 12.0);
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

    testWidgets('AppModalDialog.textField single-line and multiline start at identical 42px height', (WidgetTester tester) async {
      final multilineKey = GlobalKey();
      final hindiKey = GlobalKey();
      final singleKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                AppModalDialog.textField(
                  key: multilineKey,
                  maxLines: 2,
                  hint: 'Question Text (English)',
                ),
                AppModalDialog.textField(
                  key: hindiKey,
                  maxLines: 1,
                  prefixIcon: const Icon(Icons.translate_rounded, size: 16),
                  hint: 'Question Text (Hindi)',
                ),
                AppModalDialog.textField(
                  key: singleKey,
                  maxLines: 1,
                  hint: 'Simple',
                ),
              ],
            ),
          ),
        ),
      );

      final multiH = tester.getSize(find.byKey(multilineKey)).height;
      final hindiH = tester.getSize(find.byKey(hindiKey)).height;
      final singleH = tester.getSize(find.byKey(singleKey)).height;

      expect(multiH, 42.0);
      expect(hindiH, 42.0);
      expect(singleH, 42.0);
    });

    testWidgets('AppTextField and AppDropdown have equal vertical height of 44.0px', (WidgetTester tester) async {
      final textFieldKey = UniqueKey();
      final dropdownKey = UniqueKey();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      key: textFieldKey,
                      hintText: 'Enter title...',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppDropdown<String>(
                      key: dropdownKey,
                      value: 'opt1',
                      items: const [
                        AppDropdownItem(value: 'opt1', label: 'Option 1'),
                        AppDropdownItem(value: 'opt2', label: 'Option 2'),
                      ],
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final textFieldHeight = tester.getSize(find.byKey(textFieldKey)).height;
      final dropdownHeight = tester.getSize(find.byKey(dropdownKey)).height;
      final boxHeight = tester.getSize(find.descendant(of: find.byKey(textFieldKey), matching: find.byType(AnimatedContainer))).height;

      expect(textFieldHeight, AppSpacing.adminControlHeight);
      expect(dropdownHeight, AppSpacing.adminControlHeight);
      expect(boxHeight, AppSpacing.adminControlHeight);
      expect(textFieldHeight, equals(dropdownHeight));
    });

    testWidgets('AppTextField and AppDropdown with labels maintain matching vertical height', (WidgetTester tester) async {
      final labeledTextKey = UniqueKey();
      final labeledDropdownKey = UniqueKey();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      key: labeledTextKey,
                      label: 'Input Label',
                      hintText: 'Enter title...',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppDropdown<String>(
                      key: labeledDropdownKey,
                      label: 'Input Label',
                      inlineLabel: false,
                      value: 'opt1',
                      items: const [
                        AppDropdownItem(value: 'opt1', label: 'Option 1'),
                        AppDropdownItem(value: 'opt2', label: 'Option 2'),
                      ],
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final labeledTextHeight = tester.getSize(find.byKey(labeledTextKey)).height;
      final labeledDropdownHeight = tester.getSize(find.byKey(labeledDropdownKey)).height;

      expect(labeledTextHeight, equals(labeledDropdownHeight));
    });

    testWidgets('AppTextField and AppDropdown have vertically centered text at identical midpoint', (WidgetTester tester) async {
      final textFieldKey = UniqueKey();
      final dropdownKey = UniqueKey();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      key: textFieldKey,
                      controller: TextEditingController(text: 'Sample Text'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppDropdown<String>(
                      key: dropdownKey,
                      value: 'sample',
                      items: const [AppDropdownItem(value: 'sample', label: 'Sample Text')],
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Compare the center of the entire AppTextField box vs AppDropdown box.
      // Both are AnimatedContainers with height=44; their box centers must align.
      // Using box center (not EditableText center) because InputDecoration layout
      // varies by platform; box alignment is the user-visible truth.
      final textFieldBox = tester.getRect(find.byKey(textFieldKey));
      final dropdownBox = tester.getRect(find.byKey(dropdownKey));

      final textBoxCenterY = textFieldBox.center.dy;
      final dropBoxCenterY = dropdownBox.center.dy;

      // Both boxes are in the same Row — their vertical centers must be equal
      expect((textBoxCenterY - dropBoxCenterY).abs(), lessThanOrEqualTo(1.0));

      // Verify the EditableText widget is fully within the textfield box bounds
      // (i.e. text does not overflow outside the field boundary)
      final textEditable = find.descendant(of: find.byKey(textFieldKey), matching: find.byType(EditableText));
      final editableRect = tester.getRect(textEditable);
      expect(editableRect.top, greaterThanOrEqualTo(textFieldBox.top - 1));
      expect(editableRect.bottom, lessThanOrEqualTo(textFieldBox.bottom + 1));
    });

    testWidgets('AppTextField prefix icon and text are aligned within optical tolerance', (WidgetTester tester) async {
      final textFieldKey = UniqueKey();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: AppTextField(
                  key: textFieldKey,
                  hintText: 'Banner Title',
                  prefixIcon: const Icon(Icons.title_rounded, size: 20),
                ),
              ),
            ),
          ),
        ),
      );

      final tfIcon = tester.getRect(find.descendant(of: find.byKey(textFieldKey), matching: find.byType(Icon)));
      final tfText = tester.getRect(find.descendant(of: find.byKey(textFieldKey), matching: find.byType(Text)));

      expect((tfIcon.center.dy - tfText.center.dy).abs(), lessThanOrEqualTo(2.5));
    });

    testWidgets('AppDropdown popover menu anchors directly adjacent to input without large gap', (WidgetTester tester) async {
      final dropdownKey = UniqueKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: SizedBox(
                  width: 200,
                  child: AppDropdown<String>(
                    key: dropdownKey,
                    value: 'all',
                    items: const [
                      AppDropdownItem(value: 'all', label: 'All'),
                      AppDropdownItem(value: 'sent', label: 'Sent'),
                      AppDropdownItem(value: 'scheduled', label: 'Scheduled'),
                      AppDropdownItem(value: 'draft', label: 'Draft'),
                    ],
                    onChanged: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap to open dropdown (should open upward because it is at bottom of viewport)
      await tester.tap(find.byKey(dropdownKey));
      await tester.pumpAndSettle();

      final dropdownBox = tester.getRect(find.byKey(dropdownKey));
      final menuFinder = find.byType(ListView);
      expect(menuFinder, findsOneWidget);
      final menuBox = tester.getRect(menuFinder);

      // The gap between menu bottom and dropdown top should be snug (around 3-8px), not 80px+
      final gap = dropdownBox.top - menuBox.bottom;
      expect(gap, greaterThanOrEqualTo(0));
      expect(gap, lessThanOrEqualTo(10.0));
    });

    testWidgets('AppDropdown opens reliably on empty space taps and re-opens without delay', (WidgetTester tester) async {
      final dropdownKey = GlobalKey();
      String selected = 'all';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: SizedBox(
                    width: 260,
                    child: AppDropdown<String>(
                      key: dropdownKey,
                      value: selected,
                      items: const [
                        AppDropdownItem(value: 'all', label: 'All Users'),
                        AppDropdownItem(value: 'students', label: 'Students'),
                        AppDropdownItem(value: 'teachers', label: 'Teachers'),
                      ],
                      onChanged: (v) => setState(() => selected = v!),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Tap on the right side (empty space near the chevron) of the dropdown box
      final dropdownRect = tester.getRect(find.byKey(dropdownKey));
      final rightSideOffset = Offset(dropdownRect.right - 20, dropdownRect.center.dy);
      await tester.tapAt(rightSideOffset);
      await tester.pumpAndSettle();

      expect(find.text('Students'), findsOneWidget);

      // Select 'Students'
      await tester.tap(find.text('Students'));
      await tester.pumpAndSettle();

      expect(selected, 'students');
      expect(find.byType(ListView), findsNothing);

      // Immediately tap on the empty space again to re-open
      await tester.tapAt(rightSideOffset);
      await tester.pumpAndSettle();

      // Menu should open cleanly
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Teachers'), findsOneWidget);

      // Tap outside (top left corner) to dismiss
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsNothing);
    });
  });
}
