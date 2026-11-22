import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized Supabase Configuration & Client Provider
class SupabaseConfig {
  SupabaseConfig._();

  static const String defaultUrl = 'https://jybjomgwmabouahvvcuo.supabase.co';
  static const String defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5YmpvbWd3bWFib3VhaHZ2Y3VvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0MzIwNDksImV4cCI6MjA5MDAwODA0OX0.Bc8Bw-vGJ3gCrEzV-YsMEl-6PLFSAPBg1hEOM15lKX4';

  static String _activeUrl = defaultUrl;
  static bool _initialized = false;

  /// Dynamic session storage key matching Supabase Flutter standard: `sb-<project-ref>-auth-token`
  static String get sessionKey {
    try {
      final host = Uri.parse(_activeUrl).host;
      final ref = host.split('.').first;
      if (ref.isNotEmpty) return 'sb-$ref-auth-token';
    } catch (_) {}
    return 'sb-jybjomgwmabouahvvcuo-auth-token';
  }

  static Future<void> initialize({
    String url = defaultUrl,
    String anonKey = defaultAnonKey,
  }) async {
    if (_initialized && clientSafe != null) return;

    if (url.isEmpty || anonKey.isEmpty) {
      throw StateError('Supabase URL and Anon Key must not be empty.');
    }

    _activeUrl = url;

    try {
      await Supabase.initialize(
        url: url,
        publishableKey: anonKey,
        authOptions: const FlutterAuthClientOptions(
          autoRefreshToken: true,
          detectSessionInUri: true,
          persistSession: true,
        ),
      );
      _initialized = true;
    } catch (e) {
      if (clientSafe != null) {
        _initialized = true;
      } else {
        rethrow;
      }
    }
  }

  static bool get isInitialized => _initialized || clientSafe != null;

  static SupabaseClient? get clientSafe {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static SupabaseClient get client {
    return Supabase.instance.client;
  }

  static GoTrueClient get auth => client.auth;

  /// Retrieves the raw stringified session token from SharedPreferences if stored
  static Future<String?> getPersistedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(sessionKey);
      if (token != null && token.isNotEmpty) {
        return token;
      }
      // Fallback check for static default key in case project URL format differed
      const fallbackKey = 'sb-jybjomgwmabouahvvcuo-auth-token';
      if (sessionKey != fallbackKey) {
        final fallbackToken = prefs.getString(fallbackKey);
        if (fallbackToken != null && fallbackToken.isNotEmpty) {
          return fallbackToken;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Ensures the authenticated Supabase session is recovered and available across APK cold starts
  static Future<Session?> ensureSessionReady() async {
    if (!isInitialized) return null;
    final supaClient = clientSafe;
    if (supaClient == null) return null;

    // 1. If active session is valid and not expired, return immediately
    final current = supaClient.auth.currentSession;
    if (current != null && !current.isExpired) {
      return current;
    }

    // 2. If session exists but is expired, safely refresh using refreshSession()
    // Do NOT call recoverSession(rawToken) as it consumes the refresh token out-of-band
    // and causes invalid_grant token-rotation race conditions that log the user out!
    if (current != null && current.isExpired) {
      try {
        final res = await supaClient.auth.refreshSession().timeout(const Duration(seconds: 8));
        return res.session ?? supaClient.auth.currentSession;
      } catch (_) {
        // Return existing session on network failure so user stays logged in offline
        return supaClient.auth.currentSession;
      }
    }

    // 3. If current is null, attempt restoration from SharedPreferences
    final rawToken = await getPersistedToken();
    if (rawToken != null && rawToken.isNotEmpty) {
      if (supaClient.auth.currentSession == null) {
        try {
          await supaClient.auth.setInitialSession(rawToken);
        } catch (_) {}
      }

      final restored = supaClient.auth.currentSession;
      if (restored != null) {
        if (restored.isExpired) {
          try {
            final res = await supaClient.auth.refreshSession().timeout(const Duration(seconds: 8));
            return res.session ?? supaClient.auth.currentSession;
          } catch (_) {
            return supaClient.auth.currentSession;
          }
        }
        return restored;
      }
    }

    return supaClient.auth.currentSession;
  }
}
