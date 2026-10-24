import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_layer/data_layer.dart';
import 'package:design_system/design_system.dart';
import 'package:user_app/features/profile/profile_screen.dart';

void main() {
  final testProfile = UserProfile(
    id: 'user-1',
    name: 'Aman Kumar',
    email: 'aman.kumar@example.com',
    phone: '+91 98765 43210',
    state: 'Patna, Bihar',
    examPreparingFor: 'Student',
    coins: 1250,
    badges: const ['b1', 'b2', 'b3'],
    createdAt: DateTime(2026, 10, 1),
  );

  Widget createTestWidget({
    UserProfile? profile,
    void Function(UserProfile)? onUpdateProfile,
    VoidCallback? onLogout,
    VoidCallback? onOpenSupport,
    VoidCallback? onOpenFeedback,
    void Function(UserNavTab)? onNavigateToTab,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ProfileScreen(
          profile: profile ?? testProfile,
          onUpdateProfile: onUpdateProfile ?? (_) {},
          onLogout: onLogout ?? () {},
          onOpenSupport: onOpenSupport ?? () {},
          onOpenFeedback: onOpenFeedback ?? () {},
          onNavigateToTab: onNavigateToTab,
        ),
      ),
    );
  }

  group('Rankearn Profile Dashboard — Responsive Viewport Tests', () {
    const responsiveViewports = [
      ('Mobile 360px', Size(360, 800)),
      ('Mobile 390px', Size(390, 844)),
      ('Mobile 430px', Size(430, 932)),
      ('Tablet 768px', Size(768, 1024)),
      ('Desktop 1024px', Size(1024, 768)),
      ('Desktop 1440px', Size(1440, 900)),
    ];

    for (final vp in responsiveViewports) {
      testWidgets(
        'Renders all Profile reference components with zero overflow on ${vp.$1}',
        (WidgetTester tester) async {
          tester.view.physicalSize = vp.$2;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // 1. Profile Hero Section
          expect(find.text('Aman Kumar'), findsOneWidget);
          expect(find.text('aman.kumar@example.com'), findsOneWidget);
          expect(find.text('+91 98765 43210'), findsOneWidget);
          expect(find.text('Patna, Bihar'), findsOneWidget);
          expect(find.text('Gold Member'), findsOneWidget);
          expect(find.text('#1256'), findsOneWidget);

          // 2. Statistics Cards
          expect(find.text('My Coins'), findsOneWidget);
          expect(find.text('Tests Attempted'), findsOneWidget);
          expect(find.text('Average Score'), findsOneWidget);
          expect(find.text('Badges Earned'), findsOneWidget);

          // 3. Streak Banner
          expect(find.text('7 Days'), findsOneWidget);
          expect(find.text('Current Streak'), findsOneWidget);
          expect(find.text('Keep Learning!'), findsOneWidget);

          // 4. Six Shortcuts
          expect(find.text('Edit Profile'), findsOneWidget);
          expect(find.text('My Progress'), findsOneWidget);
          expect(find.text('My Achievements'), findsOneWidget);
          expect(find.text('Test History'), findsOneWidget);
          expect(find.text('Downloads'), findsOneWidget);
          expect(find.text('My Wishlist'), findsOneWidget);

          // 5. Premium Upgrade Banner
          expect(find.text('Upgrade to Premium'), findsOneWidget);
          expect(find.text('Upgrade Now'), findsOneWidget);

          // 6. Account & Settings & Legal
          expect(find.text('Account & Settings'), findsOneWidget);
          expect(find.text('Personal Information'), findsOneWidget);
          expect(find.text('Notification Settings'), findsOneWidget);
          expect(find.text('App Settings'), findsOneWidget);
          expect(find.text('Help & Support'), findsOneWidget);
          expect(find.text('Invite Friends'), findsOneWidget);
          expect(find.text('Legal & About'), findsOneWidget);
          expect(find.text('Logout'), findsOneWidget);
        },
      );
    }
  });

  group('Profile Screen Interactions & Modals', () {
    testWidgets(
      'Tapping Logout shows confirmation dialog and invokes onLogout',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        bool loggedOut = false;
        await tester.pumpWidget(
          createTestWidget(onLogout: () => loggedOut = true),
        );
        await tester.pumpAndSettle();

        // Scroll to Logout button
        final logoutFinder = find.byKey(const Key('profile_logout_button'));
        await tester.ensureVisible(logoutFinder);
        await tester.tap(logoutFinder);
        await tester.pumpAndSettle();

        // Verify confirmation dialog
        expect(
          find.text(
            'Are you sure you want to sign out from your Rankearn account?',
          ),
          findsOneWidget,
        );
        final signOutBtn = find.widgetWithText(ElevatedButton, 'Sign Out');
        expect(signOutBtn, findsOneWidget);

        await tester.tap(signOutBtn);
        await tester.pumpAndSettle();
        expect(loggedOut, isTrue);
      },
    );

    testWidgets('Tapping My Coins navigates to wallet tab', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      UserNavTab? selectedTab;
      await tester.pumpWidget(
        createTestWidget(onNavigateToTab: (tab) => selectedTab = tab),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Coins'));
      await tester.pumpAndSettle();

      expect(selectedTab, equals(UserNavTab.wallet));
    });

    testWidgets('Tapping Notification Settings opens preferences modal', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final notifFinder = find.text('Notification Settings');
      await tester.ensureVisible(notifFinder);
      await tester.tap(notifFinder);
      await tester.pumpAndSettle();

      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Test & Quiz Alerts'), findsOneWidget);
    });
  });
}
