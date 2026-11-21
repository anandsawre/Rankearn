import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';
import 'package:admin_app/features/notifications/widgets/notifications_data_table.dart';
import 'package:admin_app/features/notifications/notifications_tab.dart';
import 'package:admin_app/features/referrals/referrals_tab.dart';
import 'package:admin_app/features/banners/banners_tab.dart';
import 'package:admin_app/features/settings/settings_tab.dart';
import 'package:admin_app/features/feedback/feedback_tab.dart';
import 'package:admin_app/features/support/support_tab.dart';
import 'package:admin_app/features/posts/posts_tab.dart';
import 'package:admin_app/features/polls/polls_tab.dart';

void main() {
  testWidgets('NotificationsTab renders Hero banner, 5 KPI cards, Create Card, Delivery Analytics & Table', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockHistory = [
      {
        'id': 'notif-1',
        'title': 'Grand Scholarship Test',
        'body': 'Win up to 100% scholarship on all courses',
        'segment': 'All Users',
        'type': 'alert',
        'status': 'sent',
        'date': '2026-11-15',
        'reads': '1.8k (92%)',
        'ctr': '28.4%',
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationsTab(initialHistory: mockHistory),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Header Banner
    expect(find.text('Notification Management'), findsOneWidget);
    expect(find.textContaining('Create, schedule and manage cross-channel notifications'), findsOneWidget);

    // Verify 5 KPI cards
    expect(find.text('Total Sent'), findsOneWidget);
    expect(find.text('Total Recipients'), findsOneWidget);
    expect(find.text('Total Reads'), findsOneWidget);
    expect(find.text('Total Clicks'), findsOneWidget);
    expect(find.text('CTR (Click Rate)'), findsOneWidget);

    // Verify Create Notification Card & Channel selector
    expect(find.text('Create Notification'), findsOneWidget);
    expect(find.textContaining('Notification Title *'), findsOneWidget);
    expect(find.text('Push Notification'), findsOneWidget);

    // Verify Delivery Analytics & Quick Actions
    expect(find.text('Delivery Analytics'), findsOneWidget);
    expect(find.text('Quick Actions'), findsWidgets);
    expect(find.text('Send to All Users'), findsOneWidget);

    // Verify Table
    expect(find.text('Grand Scholarship Test'), findsOneWidget);
    expect(find.text('All'), findsWidgets);
    expect(find.text('SENT'), findsWidgets);
  });

  testWidgets('ReferralsTab renders Hero banner, KPI row, Settings, Share preview, Trends & Table', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockReferrals = [
      {
        'id': 'ref-1',
        'refereeName': 'Aarav Sharma',
        'refereeEmail': 'aarav@rankearn.in',
        'referrerName': 'Priya Singh',
        'code': 'RANK-WIN50',
        'bonusCoins': 50,
        'status': 'credited',
        'date': '2026-11-15',
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReferralsTab(initialReferralLogs: mockReferrals),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Header Banner
    expect(find.text('Refer & Earn Management'), findsOneWidget);

    // Verify 5 KPI cards
    expect(find.text('Total Referrals'), findsOneWidget);
    expect(find.text('Successful Signups'), findsOneWidget);
    expect(find.text('Rewards Given'), findsOneWidget);
    expect(find.text('Redeemed / Paid'), findsOneWidget);
    expect(find.text('Conversion Rate'), findsOneWidget);

    // Verify Referral Settings Card
    expect(find.text('Referral Program Settings'), findsOneWidget);
    expect(find.text('Enable Referral Program'), findsOneWidget);
    expect(find.text('Auto Credit Reward'), findsOneWidget);

    // Verify Referral Link & Share Preview
    expect(find.text('Referral Link & Share Preview'), findsOneWidget);
    expect(find.text('Invite Friends & Earn ₹50 Cash!'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Telegram'), findsOneWidget);

    // Verify Table
    expect(find.text('Aarav Sharma'), findsOneWidget);
    expect(find.text('RANK-WIN50'), findsWidgets);
  });

  testWidgets('BannersTab renders Hero banner, 7 KPI cards, Create Banner Card & Data Table', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockBanners = [
      {
        'id': 'banner-1',
        'title': 'Mega Diwali Scholarship Test',
        'link': '/contests',
        'priority': 1,
        'isActive': true,
        'imageUrl': '',
        'display': 'Home Carousel',
        'schedule': 'Always Active',
        'isScheduled': false,
        'views': '42.5k',
        'clicks': '8.1k',
        'ctr': '19.1%',
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BannersTab(initialBanners: mockBanners),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Header Banner
    expect(find.text('Promo Banner Management'), findsOneWidget);

    // Verify 7 KPI Cards
    expect(find.text('Total Banners'), findsOneWidget);
    expect(find.text('Active Banners'), findsOneWidget);
    expect(find.text('Scheduled'), findsWidgets);
    expect(find.text('Inactive'), findsWidgets);
    expect(find.text('Total Views'), findsOneWidget);
    expect(find.text('Total Clicks'), findsOneWidget);
    expect(find.text('Click-Through (CTR)'), findsOneWidget);

    // Verify Create Banner Card
    expect(find.text('Create / Update Promo Banner'), findsOneWidget);
    expect(find.text('Preview Banner'), findsOneWidget);
    expect(find.text('Save Banner'), findsOneWidget);

    // Verify Table
    expect(find.text('Mega Diwali Scholarship Test'), findsOneWidget);
    expect(find.text('/contests'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
  });

  testWidgets('SettingsTab renders Hero, category navigation, 9 configuration cards & footer', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SettingsTab(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Hero Banner
    expect(find.text('System Settings'), findsOneWidget);

    // Verify Category Pills
    expect(find.text('Platform Info'), findsOneWidget);
    expect(find.text('Features'), findsOneWidget);
    expect(find.text('Rewards & Coins'), findsOneWidget);
    expect(find.text('Battles & Games'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);

    // Verify Cards
    expect(find.text('Platform Information'), findsOneWidget);
    expect(find.text('App Features Control'), findsOneWidget);
    expect(find.text('Rewards & Coins Settings'), findsOneWidget);
    expect(find.text('Battle & Game Settings'), findsOneWidget);
    expect(find.text('Payment Settings'), findsOneWidget);
    expect(find.text('Notification Settings'), findsOneWidget);
    expect(find.text('Limits & Rules'), findsWidgets);
    expect(find.text('Appearance & Branding'), findsOneWidget);
    expect(find.text('Advanced Settings'), findsOneWidget);

    // Verify Footer
    expect(find.text('Reset to Default'), findsOneWidget);
    expect(find.text('Update Settings'), findsOneWidget);
  });

  testWidgets('FeedbackTab renders Hero, 5 KPI cards, filter panel, table & analytics', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockFeedbacks = [
      {
        'id': 'fb-1',
        'name': 'Rohit Kumar',
        'uid': 'UID: RK10234',
        'email': 'rohit@test.com',
        'rating': 5,
        'comment': 'Awesome test series!',
        'type': 'Feedback',
        'feature': 'Mock Test',
        'date': 'Nov 11, 2026',
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeedbackTab(initialFeedbacks: mockFeedbacks),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Hero
    expect(find.text('User Feedback Management'), findsOneWidget);

    // Verify KPI Cards
    expect(find.text('Average Rating'), findsOneWidget);
    expect(find.text('Total Feedbacks'), findsOneWidget);
    expect(find.text('Positive'), findsWidgets);

    // Verify Filter Panel & Table
    expect(find.text('Feedback Filters'), findsOneWidget);
    expect(find.text('Rohit Kumar'), findsOneWidget);
    expect(find.text('Awesome test series!'), findsOneWidget);

    // Verify Analytics
    expect(find.text('Rating Distribution'), findsOneWidget);
    expect(find.text('Feedback Sentiment'), findsOneWidget);
  });

  testWidgets('SupportTab renders Hero, 6 KPI cards, filters, data table & analytics', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockTickets = [
      {
        'id': 'TK-20261148',
        'name': 'Rohit Kumar',
        'email': 'rohit@test.com',
        'subject': 'Coins not credited after payment',
        'category': 'Payment',
        'priority': 'High',
        'status': 'open',
        'lastTime': 'Nov 11',
        'lastMsg': 'Deposited ₹500 via UPI',
        'messages': [],
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SupportTab(initialTickets: mockTickets),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Hero
    expect(find.text('Support Ticket Management'), findsOneWidget);

    // Verify KPI Cards
    expect(find.text('Total Tickets'), findsOneWidget);
    expect(find.text('Resolved'), findsWidgets);
    expect(find.text('In Progress'), findsWidgets);
    expect(find.text('Support Rating'), findsOneWidget);

    // Verify Filter Panel & Table
    expect(find.text('Ticket Filters'), findsOneWidget);
    expect(find.text('TK-20261148'), findsOneWidget);
    expect(find.text('Coins not credited after payment'), findsOneWidget);

    // Verify Analytics
    expect(find.text('Ticket Analytics'), findsOneWidget);
    expect(find.text('Top Categories'), findsOneWidget);
  });

  testWidgets('PostsTab renders Sub-nav header, Create Post card, Feed stream & Overview', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockPosts = [
      {
        'id': 'post-1',
        'title': 'RRB Technician Grade 3 – Daily Practice Set 🔥',
        'content': '10 महत्वपूर्ण MCQs के साथ अभी प्रैक्टिस करें।',
        'category': 'RRB',
        'type': 'announcement',
        'date': 'Nov 11, 2026',
        'isPinned': true,
        'views': '12,480',
        'likes': '1,426',
        'comments': '278',
        'shares': '86',
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostsTab(initialPosts: mockPosts),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Sub-nav Header
    expect(find.text('Community Management'), findsOneWidget);

    // Verify Left Create Card
    expect(find.text('Create Community Post'), findsOneWidget);
    expect(find.text('Post Now'), findsOneWidget);

    // Verify Center Feed
    expect(find.text('RRB Technician Grade 3 – Daily Practice Set 🔥'), findsOneWidget);

    // Verify 4 KPI Cards
    expect(find.text('Total Members'), findsOneWidget);
    expect(find.text('Growth (7 Days)'), findsOneWidget);
    expect(find.text('Total Posts'), findsOneWidget);
    expect(find.text('Total Comments'), findsOneWidget);
  });

  testWidgets('PollsTab renders with full-width layout matching Dashboard page padding and cards', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PollsTab(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify sub-header bar
    expect(find.text('Live Poll Dashboard'), findsOneWidget);
    expect(find.textContaining('Polls History'), findsOneWidget);

    // Verify Create Poll panel
    expect(find.text('Create Poll'), findsOneWidget);
    expect(find.text('Launch Live Poll'), findsOneWidget);

    // Verify Live Preview panel
    expect(find.text('LIVE POLL'), findsOneWidget);

    // Verify Live Results panel
    expect(find.text('Live Results'), findsOneWidget);
    expect(find.text('Poll Controls'), findsOneWidget);
  });

  testWidgets('NotificationsDataTable renders search and dropdown filter on mobile without overflow', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockHistory = [
      {
        'id': 'notif-1',
        'title': 'Grand Scholarship Test',
        'body': 'Win up to 100% scholarship',
        'segment': 'All Users',
        'type': 'alert',
        'status': 'sent',
        'date': '2026-11-15',
        'reads': '1.8k',
        'ctr': '28.4%',
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NotificationsDataTable(
              notifications: mockHistory,
              isLoading: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppDropdown<String>), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('NotificationsDataTable supports checkbox selection and bulk delete action', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockHistory = [
      {
        'id': 'notif-1',
        'title': 'Grand Scholarship Test',
        'body': 'Win up to 100% scholarship',
        'segment': 'All Users',
        'type': 'alert',
        'status': 'sent',
        'date': '2026-11-15',
        'reads': '1.8k',
        'ctr': '28.4%',
      },
      {
        'id': 'notif-2',
        'title': 'Weekend Mock Exam',
        'body': 'Compete with peers',
        'segment': 'Students',
        'type': 'contest',
        'status': 'scheduled',
        'date': '2026-11-16',
        'reads': '0',
        'ctr': '0.0%',
      },
    ];

    List<String>? deletedIds;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NotificationsDataTable(
              notifications: mockHistory,
              isLoading: false,
              onBulkDelete: (ids) {
                deletedIds = ids;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Checkboxes are rendered (1 header + 2 rows = 3 checkboxes)
    final checkboxes = find.byType(Checkbox);
    expect(checkboxes, findsNWidgets(3));

    // Initially bulk actions are not visible
    expect(find.text('Delete Selected (1)'), findsNothing);

    // Tap first row checkbox (index 1 is the first row checkbox, index 0 is header)
    await tester.tap(checkboxes.at(1));
    await tester.pumpAndSettle();

    // Bulk actions should appear with "1 Selected" and "Delete Selected (1)"
    expect(find.text('1 Selected'), findsOneWidget);
    expect(find.text('Delete Selected (1)'), findsOneWidget);

    // Tap header checkbox (index 0) to select all
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    // Now all 2 items are selected
    expect(find.text('2 Selected'), findsOneWidget);
    expect(find.text('Delete Selected (2)'), findsOneWidget);

    // Tap Delete Selected button
    await tester.tap(find.text('Delete Selected (2)'));
    await tester.pumpAndSettle();

    // Verify callback was called with both IDs
    expect(deletedIds, isNotNull);
    expect(deletedIds, containsAll(['notif-1', 'notif-2']));

    expect(tester.takeException(), isNull);
  });
}
