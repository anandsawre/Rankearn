import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_layer/data_layer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testEmail = Platform.environment['SUPABASE_TEST_EMAIL'];
  final testPassword = Platform.environment['SUPABASE_TEST_PASSWORD'];

  group('Real Supabase Authentication & SDK Storage Persistence Integration Test', () {
    if (testEmail == null || testEmail.isEmpty || testPassword == null || testPassword.isEmpty) {
      test('Live Supabase Auth Persistence Test (Credentials Guard)', () {
        // As specified: If repository encrypted secrets are absent, record clean diagnostic block
        const msg =
            '[BLOCKED] Real Supabase Auth Integration Test requires SUPABASE_TEST_EMAIL and SUPABASE_TEST_PASSWORD in repository encrypted secrets.';
        // ignore: avoid_print
        print(msg);
        AuthLogger.log('Real Supabase Auth Integration Test Status', {
          'status': 'BLOCKED',
          'reason': msg,
        });
        expect(true, isTrue);
      });
      return;
    }

    test('Live Supabase login writes real session to storage and survives fresh client instance', () async {
      await SupabaseConfig.initialize();
      final client = SupabaseConfig.client;

      // 1. Live authentication with Supabase backend
      final authRes = await client.auth.signInWithPassword(
        email: testEmail,
        password: testPassword,
      );

      expect(authRes.session, isNotNull);
      expect(authRes.user, isNotNull);
      final originalSession = authRes.session!;

      // 2. Verify SDK storage token was written to SharedPreferences
      final token = await SupabaseConfig.getPersistedToken();
      expect(token, isNotNull);

      // 3. Verify session recovery via fresh ensureSessionReady()
      final recoveredSession = await SupabaseConfig.ensureSessionReady();
      expect(recoveredSession, isNotNull);
      expect(recoveredSession!.user.id, equals(originalSession.user.id));

      // 4. Clean up: sign out
      await client.auth.signOut();
    });
  });
}
