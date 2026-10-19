import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_app/main.dart';

void main() {
  testWidgets('RankearnAdminApp renders shell and admin navigation successfully', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify admin header and branding elements exist
    expect(find.text('Rankearn Admin Portal'), findsOneWidget);

    // Verify admin overview statistics and actions exist
    expect(find.text('Dashboard Overview'), findsOneWidget);
    expect(find.text('Registered Users'), findsOneWidget);
    expect(find.text('Published Tests'), findsOneWidget);
    expect(find.text('Pending Top-ups'), findsOneWidget);
  });

  testWidgets('AdminApp navigation tab switching to Finance works', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Finance tab in rail
    final financeTab = find.text('Finance');
    await tester.ensureVisible(financeTab);
    await tester.tap(financeTab);
    await tester.pumpAndSettle();

    // Verify Finance view is rendered
    expect(find.text('Finance & UPI Verification'), findsOneWidget);
    expect(find.text('Pending Top-Up Verification Queue'), findsOneWidget);
    expect(find.text('Anjali Kumari'), findsOneWidget);
  });

  testWidgets('AdminApp navigation tab switching to AI Test Creator works', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Tap AI Test Creator tab in rail
    final aiTab = find.text('AI Test Creator');
    await tester.ensureVisible(aiTab);
    await tester.tap(aiTab);
    await tester.pumpAndSettle();

    // Verify AI Generator form is rendered
    expect(find.text('AI Test & Question Generator 🤖'), findsOneWidget);
    expect(find.text('✨ Generate Paper with Gemini AI'), findsOneWidget);
  });

  testWidgets('AdminApp navigation tab switching to Push Notifications works', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Notifications tab in rail
    final notifTab = find.text('Notifications');
    await tester.ensureVisible(notifTab);
    await tester.tap(notifTab);
    await tester.pumpAndSettle();

    // Verify Notifications console is rendered
    expect(find.text('Push Notification Broadcast Console 📢'), findsOneWidget);
    expect(find.text('🚀 Dispatch Broadcast via FCM'), findsOneWidget);
  });
}
