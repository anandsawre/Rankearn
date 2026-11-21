import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';
import 'package:admin_app/features/notifications/widgets/create_notification_card.dart';
import 'package:admin_app/features/notifications/widgets/notification_preview_card.dart';

void main() {
  testWidgets('NotificationPreviewCard in 427px constrained height does not overflow', (tester) async {
    final titleController = TextEditingController(text: 'Special Diwali Bonus');
    final messageController = TextEditingController(text: 'Spin the wheel now and earn up to 500 coins instantly!');
    final imageUrlController = TextEditingController();
    final actionLabelController = TextEditingController(text: 'Spin Now');
    final actionUrlController = TextEditingController(text: '/spin');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 362, maxHeight: 427),
              child: NotificationPreviewCard(
                titleController: titleController,
                messageController: messageController,
                imageUrlController: imageUrlController,
                actionLabelController: actionLabelController,
                actionUrlController: actionUrlController,
                hasImage: false,
                hasActionButton: true,
                selectedChannel: 'inapp',
                notificationType: 'alert',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Live Device Simulator'), findsOneWidget);
  });

  testWidgets('Clicking Preview Device opens modal with switcher right of Close Preview button', (tester) async {
    final titleController = TextEditingController(text: 'Special Diwali Bonus');
    final messageController = TextEditingController(text: 'Spin the wheel now and earn up to 500 coins instantly!');
    final imageUrlController = TextEditingController();
    final actionLabelController = TextEditingController(text: 'Spin Now');
    final actionUrlController = TextEditingController(text: '/spin');

    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CreateNotificationCard(
              titleController: titleController,
              messageController: messageController,
              actionLabelController: actionLabelController,
              actionUrlController: actionUrlController,
              selectedChannel: 'inapp',
              onChannelChanged: (_) {},
              targetAudience: 'all',
              onAudienceChanged: (_) {},
              notificationType: 'alert',
              onTypeChanged: (_) {},
              isScheduled: false,
              onScheduleToggled: (_) {},
              scheduledDateTime: null,
              onDateTimeChanged: (_) {},
              hasImage: false,
              onImageToggled: (_) {},
              imageUrlController: imageUrlController,
              hasActionButton: true,
              onActionButtonToggled: (_) {},
              isSubmitting: false,
              onSendNow: () {},
              onSaveDraft: () {},
              onReset: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final previewButton = find.text('Preview Device');
    expect(previewButton, findsOneWidget);
    await tester.tap(previewButton);
    await tester.pumpAndSettle();

    expect(find.text('Candidate Device Simulator'), findsOneWidget);
    expect(find.text('Live Device Simulator'), findsOneWidget);
    expect(find.text('Close Preview'), findsOneWidget);

    // Switcher is in modal actions to the right of Close Preview button
    final pushModeBtn = find.descendant(
      of: find.byType(AppModalDialog),
      matching: find.text('Push Notification'),
    );
    expect(pushModeBtn, findsOneWidget);
    await tester.tap(pushModeBtn);
    await tester.pumpAndSettle();

    expect(find.text('RANKEARN'), findsOneWidget);
  });

  testWidgets('NotificationPreviewCard renders at narrow 320px width without any overflow', (tester) async {
    final titleController = TextEditingController(text: 'Super Megapack Alert');
    final messageController = TextEditingController(text: 'Short description text here for testing simulation.');
    final imageUrlController = TextEditingController();
    final actionLabelController = TextEditingController(text: 'View Details');
    final actionUrlController = TextEditingController(text: '/tests');

    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 320,
              child: NotificationPreviewCard(
                titleController: titleController,
                messageController: messageController,
                imageUrlController: imageUrlController,
                actionLabelController: actionLabelController,
                actionUrlController: actionUrlController,
                hasImage: false,
                hasActionButton: true,
                selectedChannel: 'push',
                notificationType: 'contest',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Live Device Simulator'), findsOneWidget);
    expect(find.text('RANKEARN'), findsOneWidget);
  });
}
