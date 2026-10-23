import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'package:user_app/features/auth/user_auth_screen.dart';

void main() {
  Widget buildAuthApp({
    AuthScreenMode initialMode = AuthScreenMode.login,
    void Function(UserProfile)? onAuthSuccess,
  }) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: UserAuthScreen(
          initialMode: initialMode,
          onAuthSuccess: onAuthSuccess,
        ),
      ),
    );
  }

  group('Rankearn Auth Screen - Login Mode Tests', () {
    testWidgets('Desktop: Renders all Login UI components matching reference image', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAuthApp(initialMode: AuthScreenMode.login));
      await tester.pumpAndSettle();

      // 1. Hero Pill Badge
      expect(find.text('👋 Welcome Back!'), findsOneWidget);

      // 2. Hero Headings & Subtitles
      expect(
        find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Learning Journey')),
        findsWidgets,
      );
      expect(find.text('Practice Tests • Compete Live • Earn Coins'), findsOneWidget);
      expect(find.text('Same account. More learning. Bigger rewards.'), findsOneWidget);

      // 3. 5 Hero Feature Items
      expect(find.text('Mock Tests & PYQs'), findsOneWidget);
      expect(find.text('Practice with real exam pattern'), findsOneWidget);
      expect(find.text('Live Tests'), findsOneWidget);
      expect(find.text('Compete with students across India'), findsOneWidget);
      expect(find.text('1v1 Quiz Battle'), findsOneWidget);
      expect(find.text('Challenge real players'), findsOneWidget);
      expect(find.text('Earn Coins'), findsOneWidget);
      expect(find.text('Complete tests, tasks and more'), findsOneWidget);
      expect(find.text('Win Exciting Rewards'), findsOneWidget);
      expect(find.text('Redeem coins and get rewards'), findsOneWidget);

      // 4. Hero Statistics
      expect(find.text('1L+'), findsOneWidget);
      expect(find.text('Active Learners'), findsOneWidget);
      expect(find.text('10,000+'), findsOneWidget);
      expect(find.text('Practice Questions'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('User Rating'), findsOneWidget);

      // 5. Auth Card Header & Speech Bubble Badge
      expect(find.text('Welcome Back!'), findsWidgets);
      expect(find.text('Good To See You Again!'), findsOneWidget);
      expect(find.text('Login to your Rankearn account and continue learning, practicing and earning.'), findsOneWidget);

      // 6. Social Buttons
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Phone'), findsOneWidget);

      // 8. Divider
      expect(find.text('OR'), findsOneWidget);

      // 9. Input Form Fields
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Enter your email address'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      expect(find.text('Keep me logged in'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);

      // 10. Login Action Button
      expect(find.text('Login'), findsOneWidget);

      // 11. Mode Switcher
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('Tapping Sign Up switches to Create Your Account form', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAuthApp(initialMode: AuthScreenMode.login));
      await tester.pumpAndSettle();

      // Tap Sign Up link at the bottom
      final signUpFinder = find.text('Sign Up');
      await tester.ensureVisible(signUpFinder);
      await tester.tap(signUpFinder);
      await tester.pumpAndSettle();

      // Now we should be in Sign Up mode
      expect(find.text('Create Your Account'), findsOneWidget);
      expect(find.text("It's Free to Join!"), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Class / Exam Goal (Optional)'), findsOneWidget);
      expect(find.text('Already have an account? '), findsOneWidget);

      // Tap Login to switch back
      final loginFinder = find.text('Login').last;
      await tester.ensureVisible(loginFinder);
      await tester.tap(loginFinder);
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsWidgets);
    });



    testWidgets('Phone dialog opens on clicking Continue with Phone', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAuthApp(initialMode: AuthScreenMode.login));
      await tester.pumpAndSettle();

      final phoneFinder = find.text('Continue with Phone');
      await tester.ensureVisible(phoneFinder);
      await tester.tap(phoneFinder);
      await tester.pumpAndSettle();

      expect(find.text('Continue with Phone'), findsWidgets);
      expect(find.text('Enter your mobile number to receive a secure login OTP.'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your mobile number to receive a secure login OTP.'), findsNothing);
    });

    testWidgets('Forgot password modal opens on clicking Forgot Password?', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAuthApp(initialMode: AuthScreenMode.login));
      await tester.pumpAndSettle();

      final forgotFinder = find.text('Forgot Password?');
      await tester.ensureVisible(forgotFinder);
      await tester.tap(forgotFinder);
      await tester.pumpAndSettle();

      expect(find.text('Reset Your Password'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);

      // Close modal
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Reset Your Password'), findsNothing);
    });
  });

  group('Rankearn Auth Screen - Sign Up Mode Tests', () {
    testWidgets('Desktop: Renders all Sign Up UI components matching reference image', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAuthApp(initialMode: AuthScreenMode.signUp));
      await tester.pumpAndSettle();

      // 1. Hero Title for Sign Up
      expect(
        find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Earn Rewards')),
        findsWidgets,
      );
      expect(find.text('Take tests, improve your skills and earn real coins with Rankearn.'), findsOneWidget);

      // 2. Auth Card Header & Badge
      expect(find.text('Create Your Account'), findsOneWidget);
      expect(find.text("It's Free to Join!"), findsOneWidget);
      expect(find.text('Join Rankearn and start your learning journey today!'), findsOneWidget);

      // 3. Form Fields
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Enter your full name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Create a password'), findsOneWidget);
      expect(find.text('Class / Exam Goal (Optional)'), findsOneWidget);
      expect(find.text('Select your goal'), findsOneWidget);

      // 5. Terms Checkbox
      expect(find.textContaining('I agree to the'), findsOneWidget);
      expect(find.textContaining('Terms of Service'), findsOneWidget);
      expect(find.textContaining('Privacy Policy'), findsOneWidget);

      // 6. Action Button
      expect(find.text('Sign Up'), findsWidgets);
    });

    testWidgets('Shows error if email is invalid on Login', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAuthApp(initialMode: AuthScreenMode.login));
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.widgetWithText(TextFormField, 'Enter your email address'), 'not-an-email');
      await tester.enterText(find.widgetWithText(TextFormField, 'Enter your password'), '123456');

      // Tap Login
      final loginBtn = find.text('Login');
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });
  });

  group('Rankearn Auth Screen - Responsive Layout Tests (Zero Overflow Guarantee)', () {
    final viewports = <String, Size>{
      'Mobile 320px (iPhone SE narrow)': const Size(320, 640),
      'Mobile 360px (Standard Android)': const Size(360, 740),
      'Mobile 412px (Pixel / Galaxy)': const Size(412, 892),
      'Tablet 768px (iPad Portrait)': const Size(768, 1024),
      'Tablet 1024px (iPad Landscape)': const Size(1024, 768),
      'Laptop 1280px': const Size(1280, 800),
      'Desktop 1440px': const Size(1440, 900),
      'Large Desktop 1920px': const Size(1920, 1080),
    };

    for (final entry in viewports.entries) {
      testWidgets('Renders Login cleanly at ${entry.key} with zero overflow', (WidgetTester tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildAuthApp(initialMode: AuthScreenMode.login));
        await tester.pumpAndSettle();

        expect(find.byType(UserAuthScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Renders Sign Up cleanly at ${entry.key} with zero overflow', (WidgetTester tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildAuthApp(initialMode: AuthScreenMode.signUp));
        await tester.pumpAndSettle();

        expect(find.byType(UserAuthScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
