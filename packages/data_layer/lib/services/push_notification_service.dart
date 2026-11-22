import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../supabase/supabase_config.dart';
import 'firebase_options.dart';

/// Top-level background message handler required by Firebase Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {}
  debugPrint('FCM Background Message: ${message.messageId} - ${message.notification?.title}');
}

/// Centralized Push & Local Notification Service for Android, iOS & Web
class PushNotificationService {
  PushNotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _broadcastChannel = AndroidNotificationChannel(
    'rankearn_broadcasts',
    'Rankearn Announcements & Alerts',
    description: 'High-importance notifications for alerts, tests, tournaments and broadcasts.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _alertsChannel = AndroidNotificationChannel(
    'rankearn_alerts',
    'Rankearn General Alerts',
    description: 'Instant alerts, coin rewards and battle challenges.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static bool _isInitialized = false;
  static String? _cachedFcmToken;
  static void Function(Map<String, dynamic> data)? _onTapCallback;
  static void Function(Map<String, dynamic> data)? _onForegroundCallback;

  static String? get fcmToken => _cachedFcmToken;

  /// Initialize Firebase & Local Notifications
  static Future<void> initialize({
    void Function(Map<String, dynamic> data)? onNotificationTap,
    void Function(Map<String, dynamic> data)? onForegroundNotification,
  }) async {
    _onTapCallback = onNotificationTap;
    _onForegroundCallback = onForegroundNotification;

    if (_isInitialized) return;

    try {
      // 1. Initialize Firebase Core
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // 2. Setup Background Handler (Mobile only)
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      }

      // 3. Request Notification Permissions
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('Notification permission status: ${settings.authorizationStatus}');

      // 4. Initialize Local Notifications Plugin
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            try {
              final map = jsonDecode(payload) as Map<String, dynamic>;
              _onTapCallback?.call(map);
            } catch (_) {
              _onTapCallback?.call({'action_url': payload});
            }
          }
        },
      );

      // 5. Create Android High-Priority Channels
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.createNotificationChannel(_broadcastChannel);
        await androidPlugin?.createNotificationChannel(_alertsChannel);

        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // 6. Obtain FCM Device Token
      try {
        _cachedFcmToken = await messaging.getToken();
        debugPrint('FCM Device Token: $_cachedFcmToken');
      } catch (e) {
        debugPrint('FCM getToken error: $e');
      }

      // 7. Subscribe to global broadcasts topic
      if (!kIsWeb) {
        try {
          await messaging.subscribeToTopic('all_users');
        } catch (_) {}
      }

      // 8. Listen to token refreshes
      messaging.onTokenRefresh.listen((newToken) {
        _cachedFcmToken = newToken;
        syncDeviceToken();
      });

      // 9. Handle Foreground Push Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notif = message.notification;
        final data = message.data;

        final title = notif?.title ?? data['title']?.toString() ?? 'Rankearn Alert';
        final body = notif?.body ?? data['message']?.toString() ?? data['body']?.toString() ?? '';
        final actionUrl = data['actionUrl']?.toString() ?? data['action_url']?.toString();
        final imageUrl = notif?.android?.imageUrl ?? data['imageUrl']?.toString() ?? data['image_url']?.toString();

        final fullPayload = {
          'id': data['notificationId'] ?? data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'title': title,
          'message': body,
          'action_url': actionUrl,
          'image_url': imageUrl,
          'type': data['type']?.toString() ?? 'alert',
          'channel': data['channel']?.toString() ?? 'push',
          'action_label': data['actionLabel']?.toString() ?? data['action_label']?.toString() ?? 'Open',
        };

        // Notify in-app listeners (to show bottom banner or modal popup)
        _onForegroundCallback?.call(fullPayload);

        // Also trigger native heads-up notification in system notification tray
        showLocalNotification(
          title: title,
          body: body,
          payload: jsonEncode(fullPayload),
        );
      });

      // 10. Handle App Open from Background Notification Click
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final data = Map<String, dynamic>.from(message.data);
        if (message.notification != null) {
          data['title'] ??= message.notification!.title;
          data['message'] ??= message.notification!.body;
        }
        _onTapCallback?.call(data);
      });

      // 11. Check Terminated Initial Message
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        final data = Map<String, dynamic>.from(initialMessage.data);
        if (initialMessage.notification != null) {
          data['title'] ??= initialMessage.notification!.title;
          data['message'] ??= initialMessage.notification!.body;
        }
        Future.delayed(const Duration(milliseconds: 600), () {
          _onTapCallback?.call(data);
        });
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('PushNotificationService initialization error: $e');
    }

    // Attempt token sync with Supabase
    await syncDeviceToken();
  }

  /// Show a local heads-up notification in Android / iOS system tray
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? notificationId,
  }) async {
    if (kIsWeb) return;

    try {
      final id = notificationId ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000).abs();

      const androidDetails = AndroidNotificationDetails(
        'rankearn_broadcasts',
        'Rankearn Announcements & Alerts',
        channelDescription: 'High-importance notifications for alerts, tests, tournaments and broadcasts.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error displaying local notification: $e');
    }
  }

  /// Register device FCM token in Supabase public.user_device_tokens table
  static Future<void> syncDeviceToken({String? userId}) async {
    String? token = _cachedFcmToken;
    if (token == null) {
      try {
        token = await FirebaseMessaging.instance.getToken().catchError((_) => null);
      } catch (_) {
        return;
      }
    }
    if (token == null || token.isEmpty) return;

    final client = SupabaseConfig.clientSafe;
    if (client == null) return;

    final effectiveUserId = userId ?? client.auth.currentUser?.id;
    if (effectiveUserId == null || effectiveUserId.isEmpty) return;

    try {
      final platform = kIsWeb ? 'web' : defaultTargetPlatform.name;
      await client.from('user_device_tokens').upsert(
        {
          'user_id': effectiveUserId,
          'token': token,
          'platform': platform,
          'last_seen_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'token',
      );
      debugPrint('Device token synced with Supabase for user: $effectiveUserId');
    } catch (e) {
      debugPrint('Device token sync error: $e');
    }
  }
}
