import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_logger.dart';

/// Centralized Supabase Configuration & Client Provider
class SupabaseConfig {
  SupabaseConfig._();

  static const String defaultUrl = 'https://jybjomgwmabouahvvcuo.supabase.co';
  static const String defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5YmpvbWd3bWFib3VhaHZ2Y3VvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0MzIwNDksImV4cCI6MjA5MDAwODA0OX0.Bc8Bw-vGJ3gCrEzV-YsMEl-6PLFSAPBg1hEOM15lKX4';

  static String _activeUrl = defaultUrl;
  static bool _initialized = false;
  static Future<Session?>? _inFlightRecovery;

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
    if (_initialized && clientSafe != null) {
      AuthLogger.logInit(
        success: true,
        url: _activeUrl,
        storageKey: sessionKey,
      );
      return;
    }

    if (url.isEmpty || anonKey.isEmpty) {
      const error = 'Supabase URL and Anon Key must not be empty.';
      AuthLogger.logInit(success: false, error: error);
      throw StateError(error);
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
      AuthLogger.logInit(
        success: true,
        url: url,
        storageKey: sessionKey,
      );
    } catch (e) {
      if (clientSafe != null) {
        _initialized = true;
        AuthLogger.logInit(
          success: true,
          url: url,
          storageKey: sessionKey,
        );
      } else {
        AuthLogger.logInit(
          success: false,
          url: url,
          storageKey: sessionKey,
          error: e.toString(),
        );
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
        AuthLogger.logStorageStatus(
          key: sessionKey,
          exists: true,
          dataLength: token.length,
        );
        return token;
      }
      // Fallback check for static default key in case project URL format differed
      const fallbackKey = 'sb-jybjomgwmabouahvvcuo-auth-token';
      if (sessionKey != fallbackKey) {
        final fallbackToken = prefs.getString(fallbackKey);
        if (fallbackToken != null && fallbackToken.isNotEmpty) {
          AuthLogger.logStorageStatus(
            key: fallbackKey,
            exists: true,
            dataLength: fallbackToken.length,
          );
          return fallbackToken;
        }
      }
      AuthLogger.logStorageStatus(key: sessionKey, exists: false);
    } catch (e) {
      AuthLogger.log('Error reading persisted token', {'error': e.toString()});
    }
    return null;
  }

  /// Ensures the authenticated Supabase session is recovered and available across APK cold starts.
  ///
  /// Protected by a shared in-flight mutex so concurrent callers share a single recovery Future,
  /// preventing double refresh token requests and invalid_grant token-rotation race conditions.
  static Future<Session?> ensureSessionReady() async {
    if (_inFlightRecovery != null) {
      AuthLogger.log('ensureSessionReady deduplicated; awaiting existing in-flight recovery');
      return _inFlightRecovery;
    }
    _inFlightRecovery = _internalEnsureSessionReady();
    try {
      return await _inFlightRecovery;
    } finally {
      _inFlightRecovery = null;
    }
  }

  static Future<Session?> _internalEnsureSessionReady() async {
    if (!isInitialized) {
      AuthLogger.logSessionRestore(
        source: 'ensureSessionReady',
        hasSession: false,
        error: 'Supabase not initialized',
      );
      return null;
    }
    final supaClient = clientSafe;
    if (supaClient == null) return null;

    // 1. If active session is valid and not expired, return immediately
    final current = supaClient.auth.currentSession;
    if (current != null && !current.isExpired) {
      AuthLogger.logSessionRestore(
        source: 'memory_active',
        hasSession: true,
        userId: current.user.id,
        isExpired: false,
      );
      return current;
    }

    // 2. If session exists but is expired, safely refresh using refreshSession()
    // Do NOT call recoverSession(rawToken) as it consumes the refresh token out-of-band
    // and causes invalid_grant token-rotation race conditions that log the user out!
    if (current != null && current.isExpired) {
      try {
        AuthLogger.logTokenRefresh(trigger: 'expired_current_session', success: false);
        final res = await supaClient.auth.refreshSession().timeout(const Duration(seconds: 8));
        final refreshed = res.session ?? supaClient.auth.currentSession;
        AuthLogger.logTokenRefresh(
          trigger: 'expired_current_session',
          success: refreshed != null && !refreshed.isExpired,
        );
        return refreshed;
      } catch (e) {
        // Return existing session on network failure so user stays logged in offline
        AuthLogger.logTokenRefresh(
          trigger: 'expired_current_session',
          success: false,
          isOfflineFallback: true,
          error: e.toString(),
        );
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
            AuthLogger.logTokenRefresh(trigger: 'restored_expired_token', success: false);
            final res = await supaClient.auth.refreshSession().timeout(const Duration(seconds: 8));
            final refreshed = res.session ?? supaClient.auth.currentSession;
            AuthLogger.logTokenRefresh(
              trigger: 'restored_expired_token',
              success: refreshed != null && !refreshed.isExpired,
            );
            return refreshed;
          } catch (e) {
            AuthLogger.logTokenRefresh(
              trigger: 'restored_expired_token',
              success: false,
              isOfflineFallback: true,
              error: e.toString(),
            );
            return supaClient.auth.currentSession;
          }
        }
        AuthLogger.logSessionRestore(
          source: 'storage_restored',
          hasSession: true,
          userId: restored.user.id,
          isExpired: false,
        );
        return restored;
      }
    }

    AuthLogger.logSessionRestore(
      source: 'ensureSessionReady',
      hasSession: supaClient.auth.currentSession != null,
      userId: supaClient.auth.currentSession?.user.id,
    );
    return supaClient.auth.currentSession;
  }
}
