import 'package:data_layer/data_layer.dart';

void triggerBrowserNotification(String title, String body, String? url) {
  PushNotificationService.showLocalNotification(
    title: title,
    body: body,
    payload: url,
  );
}
