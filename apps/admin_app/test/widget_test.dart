import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:admin_app/main.dart';

void main() {
  testWidgets('RankearnAdminApp renders shell, header and overview tab successfully', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify top fixed emerald header elements
    expect(find.text('Rankearn'), findsOneWidget);
    expect(find.text('Learning with Earning'), findsOneWidget);
    expect(find.text('Anand Sawre'), findsOneWidget);

    // Verify overview tab stats and health cards
    expect(find.text('TOTAL USERS'), findsOneWidget);
    expect(find.text('ACTIVE TESTS'), findsOneWidget);
    expect(find.text('REVENUE'), findsOneWidget);
    expect(find.text('AVG ACCURACY'), findsOneWidget);
    expect(find.text('Backend Infrastructure & Security Health'), findsOneWidget);
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

    // Tap Finance tab in sidebar
    final financeTab = find.text('Finance');
    await tester.ensureVisible(financeTab);
    await tester.tap(financeTab);
    await tester.pumpAndSettle();

    // Verify Finance view is rendered
    expect(find.text('Finance Management'), findsOneWidget);
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

    // Tap AI Test Creator tab in sidebar
    final aiTab = find.text('AI Test Creator');
    await tester.ensureVisible(aiTab);
    await tester.tap(aiTab);
    await tester.pumpAndSettle();

    // Verify AI Intelligence creator is rendered
    expect(find.text('AI Test Intelligence'), findsOneWidget);
    expect(find.text('✨ Generate Test Paper with Gemini AI'), findsOneWidget);
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

    // Tap Notifications tab in sidebar
    final notifTab = find.text('Notifications');
    await tester.ensureVisible(notifTab);
    await tester.tap(notifTab);
    await tester.pumpAndSettle();

    // Verify Notifications console is rendered
    expect(find.text('Broadcast Push Notification'), findsOneWidget);
    expect(find.text('AUDIENCE SEGMENT'), findsOneWidget);
  });

  testWidgets('AdminApp navigation tab switching to Lucky Wheel works', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Lucky Wheel tab in sidebar
    final wheelTab = find.text('Lucky Wheel');
    await tester.ensureVisible(wheelTab);
    await tester.tap(wheelTab);
    await tester.pumpAndSettle();

    // Verify Lucky Wheel console is rendered
    expect(find.text('Lucky Wheel Reward Engine'), findsOneWidget);
    expect(find.text('WHEEL SECTORS (8 REWARD SLICES)'), findsOneWidget);
  });

  testWidgets('AdminApp navigation tab switching to Test Series works', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    final tab = find.descendant(of: find.byType(AdminSidebar), matching: find.text('Test Series'));
    await tester.tap(tab);
    await tester.pumpAndSettle();

    expect(find.text('Test Repository'), findsOneWidget);
    expect(find.text('+ New Test'), findsOneWidget);
  });

  testWidgets('AdminApp navigation tab switching to Users works', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    final tab = find.descendant(of: find.byType(AdminSidebar), matching: find.text('Users'));
    await tester.tap(tab);
    await tester.pumpAndSettle();

    expect(find.text('Registered Users'), findsWidgets);
    expect(find.text('Ananya Sharma'), findsOneWidget);
  });

  testWidgets('AdminApp navigation tab switching to Contests works', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    final tab = find.descendant(of: find.byType(AdminSidebar), matching: find.text('Contests'));
    await tester.tap(tab);
    await tester.pumpAndSettle();

    expect(find.text('Contest Arena'), findsOneWidget);
    expect(find.text('+ Create Tournament'), findsOneWidget);
  });

  testWidgets('AdminApp navigation tab switching to Platform Settings works', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RankearnAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    final tab = find.descendant(of: find.byType(AdminSidebar), matching: find.text('Settings'));
    await tester.tap(tab);
    await tester.pumpAndSettle();

    expect(find.text('System & Platform Settings'), findsOneWidget);
    expect(find.text('Cloudflare Worker / Gemini Proxy API'), findsOneWidget);
  });
}
