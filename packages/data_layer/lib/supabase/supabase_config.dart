import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized Supabase Configuration & Client Provider
class SupabaseConfig {
  SupabaseConfig._();

  static const String defaultUrl = 'https://jybjomgwmabouahvvcuo.supabase.co';
  static const String defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5YmpvbWd3bWFib3VhaHZ2Y3VvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0MzIwNDksImV4cCI6MjA5MDAwODA0OX0.Bc8Bw-vGJ3gCrEzV-YsMEl-6PLFSAPBg1hEOM15lKX4';

  static const String sessionKey = 'sb-jybjomgwmabouahvvcuo-auth-token';

  static bool _initialized = false;

  static Future<void> initialize({
    String url = defaultUrl,
    String anonKey = defaultAnonKey,
  }) async {
    if (_initialized) return;

    if (url.isEmpty || anonKey.isEmpty) {
      throw StateError('Supabase URL and Anon Key must not be empty.');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        detectSessionInUri: false,
      ),
    );
    _initialized = true;
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

    // 2. Check SharedPreferences for persisted Supabase auth token
    final rawToken = await getPersistedToken();
    if (rawToken != null && rawToken.isNotEmpty) {
      // Restore initial session to client if not yet set
      if (supaClient.auth.currentSession == null) {
        try {
          await supaClient.auth.setInitialSession(rawToken);
        } catch (_) {}
      }

      // If expired, attempt recovery/refresh without throwing or crashing
      final session = supaClient.auth.currentSession;
      if (session != null && session.isExpired) {
        try {
          final res = await supaClient.auth.recoverSession(rawToken).timeout(const Duration(seconds: 8));
          return res.session ?? supaClient.auth.currentSession;
        } catch (_) {
          return supaClient.auth.currentSession;
        }
      }
      return supaClient.auth.currentSession;
    }

    return supaClient.auth.currentSession;
  }
}
