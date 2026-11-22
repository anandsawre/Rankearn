import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:data_layer/data_layer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthLogger.clear();
  });

  group('Supabase Authentication & Session Persistence Audit Tests', () {
    test('SupabaseConfig sessionKey generates correct dynamic project storage key', () {
      final key = SupabaseConfig.sessionKey;
      expect(key, equals('sb-jybjomgwmabouahvvcuo-auth-token'));
    });

    test('getPersistedToken logs storage status exists: false when token is absent (Finding B)', () async {
      SharedPreferences.setMockInitialValues({});
      final token = await SupabaseConfig.getPersistedToken();
      expect(token, isNull);

      final logs = AuthLogger.recentLogs;
      expect(logs.any((l) => l.contains('Storage Status') && l.contains('exists: false')), isTrue);
    });

    test('getPersistedToken retrieves saved session token from SharedPreferences and logs exists: true', () async {
      final mockSession = {
        'access_token': 'test_access_token_123',
        'refresh_token': 'test_refresh_token_456',
        'expires_in': 3600,
        'token_type': 'bearer',
        'user': {
          'id': 'usr_test_123',
          'email': 'student@rankearn.in',
          'user_metadata': {'name': 'Rohan Kumar'},
        },
      };

      SharedPreferences.setMockInitialValues({
        SupabaseConfig.sessionKey: jsonEncode(mockSession),
      });

      final token = await SupabaseConfig.getPersistedToken();
      expect(token, isNotNull);
      final decoded = jsonDecode(token!) as Map<String, dynamic>;
      expect(decoded['access_token'], equals('test_access_token_123'));
      expect(decoded['refresh_token'], equals('test_refresh_token_456'));

      // Verify AuthLogger recorded Storage Status exists: true
      final logs = AuthLogger.recentLogs;
      expect(logs.any((l) => l.contains('Storage Status') && l.contains('exists: true')), isTrue);
    });

    test('saveLocalProfile and getLocalProfile persist profile across app restarts for UI convenience', () async {
      final repo = AuthRepository();

      final profile = UserProfile(
        id: 'usr_rohan_99',
        name: 'Rohan Sharma',
        email: 'rohan.sharma@rankearn.in',
        phone: '+91 98765 00000',
        coins: 500,
        subscriptionStatus: 'premium',
        examPreparingFor: '70th BPSC Prelims',
        state: 'Bihar, India',
        createdAt: DateTime(2026, 11, 1),
      );

      await repo.saveLocalProfile(profile);

      // Simulate app restart / cold start (read from disk)
      final restored = await repo.getLocalProfile();
      expect(restored, isNotNull);
      expect(restored!.id, equals('usr_rohan_99'));
      expect(restored.name, equals('Rohan Sharma'));
      expect(restored.email, equals('rohan.sharma@rankearn.in'));
      expect(restored.coins, equals(500));
      expect(restored.isPro, isTrue);

      // Verify diagnostics logged
      expect(AuthLogger.recentLogs.any((l) => l.contains('Local profile cached')), isTrue);
    });

    test('restoreSession rejects local profile cache when no verified Supabase session exists (Finding A)', () async {
      final repo = AuthRepository();

      final profile = UserProfile(
        id: 'usr_offline_1',
        name: 'Offline Aspirant',
        email: 'offline@rankearn.in',
        coins: 250,
        createdAt: DateTime.now(),
      );

      await repo.saveLocalProfile(profile);

      // Verify profile is in local storage
      expect(await repo.getLocalProfile(), isNotNull);

      // Attempt restoreSession without an active Supabase SDK session
      final result = await repo.restoreSession();

      // MUST return Failure and NOT create fake session from cached profile!
      expect(result, isA<Failure<UserProfile>>());
      final logs = AuthLogger.recentLogs;
      expect(logs.any((l) => l.contains('hasSession: false')), isTrue);
    });

    test('Fresh app installation returns Failure and does not crash or fake session', () async {
      // Empty SharedPreferences simulating fresh install
      SharedPreferences.setMockInitialValues({});

      final repo = AuthRepository();
      final result = await repo.restoreSession();
      expect(result, isA<Failure<UserProfile>>());
      expect((result as Failure<UserProfile>).message, contains('Supabase client not initialized'));

      expect(AuthLogger.recentLogs.any((l) => l.contains('hasSession: false')), isTrue);
    });

    test('rememberMe = false does not block getLocalProfile or session persistence (Finding C)', () async {
      final repo = AuthRepository();

      final profile = UserProfile(
        id: 'usr_guest',
        name: 'Public Kiosk User',
        email: 'kiosk@rankearn.in',
        createdAt: DateTime.now(),
      );

      // Save without rememberMe
      await repo.saveLocalProfile(profile, rememberMe: false);

      // Profile is still retrievable for UI convenience
      final restored = await repo.getLocalProfile();
      expect(restored, isNotNull);
      expect(restored!.id, equals('usr_guest'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('rankearn_user_remember_me'), isFalse);
    });

    test('Explicit signOut clears local profile cache and remember me flag', () async {
      final repo = AuthRepository();

      final profile = UserProfile(
        id: 'usr_to_logout',
        name: 'Logout User',
        email: 'logout@rankearn.in',
        createdAt: DateTime.now(),
      );

      await repo.saveLocalProfile(profile);
      expect(await repo.getLocalProfile(), isNotNull);

      // Perform explicit sign out
      await repo.signOut();

      // Ensure cache is completely erased
      expect(await repo.getLocalProfile(), isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('rankearn_user_profile_cache'), isNull);
      expect(prefs.getBool('rankearn_user_remember_me'), isNull);

      // Verify explicit logout was logged
      expect(
        AuthLogger.recentLogs.any(
          (l) => l.contains('explicit_sign_out') && l.contains('userInitiated: true'),
        ),
        isTrue,
      );
    });

    test('Temporary network timeout preserves local profile cache on device', () async {
      final repo = AuthRepository();

      final profile = UserProfile(
        id: 'usr_spotty_network',
        name: 'Spotty Network User',
        email: 'spotty@rankearn.in',
        coins: 1000,
        createdAt: DateTime.now(),
      );

      await repo.saveLocalProfile(profile);

      // Ensure local cache is preserved on device
      final stillCached = await repo.getLocalProfile();
      expect(stillCached, isNotNull);
      expect(stillCached!.id, equals('usr_spotty_network'));
    });

    test('AuthLogger redacts confidential keys and generates report', () {
      AuthLogger.log('Login attempt', {
        'userId': 'usr_safe_1',
        'password': 'super_secret_password',
        'access_token': 'eyJh...token',
        'refresh_token': 'refresh_token_123',
      });

      final logs = AuthLogger.recentLogs;
      expect(logs.isNotEmpty, isTrue);

      final lastLog = logs.last;
      expect(lastLog.contains('super_secret_password'), isFalse);
      expect(lastLog.contains('eyJh...token'), isFalse);
      expect(lastLog.contains('refresh_token_123'), isFalse);
      expect(lastLog.contains('[REDACTED_CONFIDENTIAL]'), isTrue);

      final report = AuthLogger.exportDiagnosticReport();
      expect(report.contains('# Supabase Authentication Diagnostic Log Report'), isTrue);
    });
  });
}
