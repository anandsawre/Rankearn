import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_app/features/notifications/notifications_tab.dart';
import 'package:admin_app/features/referrals/referrals_tab.dart';
import 'package:admin_app/features/banners/banners_tab.dart';

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

    // Verify Create Notification Card & Channel pills
    expect(find.text('Create Notification'), findsOneWidget);
    expect(find.text('Push Notification'), findsOneWidget);
    expect(find.text('In-App Notification'), findsOneWidget);
    expect(find.text('Email Alert'), findsOneWidget);

    // Verify Delivery Analytics & Quick Actions
    expect(find.text('Delivery Analytics'), findsOneWidget);
    expect(find.text('Quick Actions'), findsWidgets);
    expect(find.text('Send to All Users'), findsOneWidget);

    // Verify Table
    expect(find.text('Grand Scholarship Test'), findsOneWidget);
    expect(find.text('All'), findsWidgets);
    expect(find.text('Sent'), findsWidgets);
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
}
