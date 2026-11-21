import 'dart:js_interop';

@JS('showBrowserNotification')
external void _showBrowserNotification(JSString title, JSString body, JSString? url);

void triggerBrowserNotification(String title, String body, String? url) {
  try {
    _showBrowserNotification(title.toJS, body.toJS, url?.toJS);
  } catch (_) {}
}
