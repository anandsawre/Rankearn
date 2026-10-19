import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized Supabase Configuration & Client Provider
class SupabaseConfig {
  SupabaseConfig._();

  static const String defaultUrl = 'https://jybjomgwmabouahvvcuo.supabase.co';
  static const String defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5YmpvbWd3bWFib3VhaHZ2Y3VvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0MzIwNDksImV4cCI6MjA5MDAwODA0OX0.Bc8Bw-vGJ3gCrEzV-YsMEl-6PLFSAPBg1hEOM15lKX4';

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
      publishableKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _initialized = true;
  }

  static SupabaseClient get client {
    if (!_initialized) {
      // Fallback for tests or direct access
      return Supabase.instance.client;
    }
    return Supabase.instance.client;
  }

  static GoTrueClient get auth => client.auth;
}
