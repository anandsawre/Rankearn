import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Structured, security-hardened authentication diagnostic logger for Rankearn.
///
/// Records diagnostic events to console and memory ring buffer without ever
/// storing or printing passwords, tokens, or sensitive credentials.
class AuthLogger {
  AuthLogger._();

  static const int _maxLogHistory = 100;
  static final ListQueue<String> _history = ListQueue<String>(_maxLogHistory);

  /// Sensitive key patterns that MUST NEVER be logged in plain text
  static final RegExp _sensitivePattern = RegExp(
    r'(password|token|secret|access_token|refresh_token|anon_key|jwt|auth)',
    caseSensitive: false,
  );

  /// General diagnostic logger with redaction
  static void log(String event, [Map<String, dynamic>? details]) {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final sanitizedDetails = <String, dynamic>{};

    if (details != null) {
      for (final entry in details.entries) {
        if (_sensitivePattern.hasMatch(entry.key)) {
          sanitizedDetails[entry.key] = '[REDACTED_CONFIDENTIAL]';
        } else {
          sanitizedDetails[entry.key] = entry.value;
        }
      }
    }

    final detailString = sanitizedDetails.isEmpty
        ? ''
        : ' => ${sanitizedDetails.entries.map((e) => '${e.key}: ${e.value}').join(', ')}';

    final message = '[$timestamp][AuthDiag] $event$detailString';
    debugPrint(message);

    if (_history.length >= _maxLogHistory) {
      _history.removeFirst();
    }
    _history.add(message);
  }

  /// 1. Supabase Initialization Diagnostic
  static void logInit({
    required bool success,
    String? url,
    String? storageKey,
    String? error,
  }) {
    log('Supabase Initialization', {
      'status': success ? 'SUCCESS' : 'FAILED',
      'url': url ?? 'unknown',
      'storageKey': storageKey ?? 'unknown',
      'error': ?error,
    });
  }

  /// 2. Session Restoration Diagnostic
  static void logSessionRestore({
    required String source,
    required bool hasSession,
    String? userId,
    bool? isExpired,
    String? error,
  }) {
    log('Session Restoration', {
      'source': source,
      'hasSession': hasSession,
      'userId': ?userId,
      'isExpired': ?isExpired,
      'error': ?error,
    });
  }

  /// 3. Storage Availability Diagnostic
  static void logStorageStatus({
    required String key,
    required bool exists,
    int? dataLength,
  }) {
    log('Storage Status', {
      'key': key,
      'exists': exists,
      'byteLength': ?dataLength,
    });
  }

  /// 4. Token Refresh Diagnostic
  static void logTokenRefresh({
    required String trigger,
    required bool success,
    bool? isOfflineFallback,
    String? error,
  }) {
    log('Token Refresh', {
      'trigger': trigger,
      'success': success,
      'offlineFallback': ?isOfflineFallback,
      'error': ?error,
    });
  }

  /// 5. Auth State Event Diagnostic
  static void logAuthStateEvent({
    required String event,
    String? userId,
    String? signOutReason,
  }) {
    log('Auth State Event', {
      'event': event,
      'userId': ?userId,
      'signOutReason': ?signOutReason,
    });
  }

  /// 6. Logout Trigger Diagnostic
  static void logLogoutTrigger({
    required String trigger,
    required bool userInitiated,
  }) {
    log('Logout Trigger', {
      'trigger': trigger,
      'userInitiated': userInitiated,
    });
  }

  /// 7. Navigation Decision Diagnostic
  static void logNavigationDecision({
    required String screen,
    required String reason,
    String? userId,
  }) {
    log('Navigation Decision', {
      'screen': screen,
      'reason': reason,
      'userId': ?userId,
    });
  }

  /// Returns full history of recent logs for artifact export
  static List<String> get recentLogs => List.unmodifiable(_history);

  /// Clears in-memory log buffer (useful between tests)
  static void clear() {
    _history.clear();
  }

  /// Formats all diagnostics into a markdown summary report
  static String exportDiagnosticReport() {
    final buffer = StringBuffer();
    buffer.writeln('# Supabase Authentication Diagnostic Log Report');
    buffer.writeln('Generated at: ${DateTime.now().toUtc().toIso8601String()}');
    buffer.writeln('Total recorded entries: ${_history.length}');
    buffer.writeln();
    buffer.writeln('```');
    for (final line in _history) {
      buffer.writeln(line);
    }
    buffer.writeln('```');
    return buffer.toString();
  }
}
