import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:data_layer/data_layer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Supabase Authentication & Session Persistence Audit Tests', () {
    test('SupabaseConfig sessionKey generates correct dynamic project storage key', () {
      final key = SupabaseConfig.sessionKey;
      expect(key, equals('sb-jybjomgwmabouahvvcuo-auth-token'));
    });

    test('getPersistedToken retrieves saved session token from SharedPreferences', () async {
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
    });

    test('saveLocalProfile and getLocalProfile persist profile across app restarts', () async {
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
    });

    test('restoreSession restores instantly from local profile cache without network delay', () async {
      final repo = AuthRepository();

      final profile = UserProfile(
        id: 'usr_offline_1',
        name: 'Offline Aspirant',
        email: 'offline@rankearn.in',
        coins: 250,
        createdAt: DateTime.now(),
      );

      await repo.saveLocalProfile(profile);

      final result = await repo.restoreSession();
      expect(result, isA<Success<UserProfile>>());
      final restored = (result as Success<UserProfile>).data;
      expect(restored.id, equals('usr_offline_1'));
      expect(restored.name, equals('Offline Aspirant'));
    });

    test('restoreSession parses raw Supabase token when local profile cache is missing', () async {
      final mockSession = {
        'access_token': 'dummy_access_token',
        'refresh_token': 'dummy_refresh_token',
        'expires_in': 3600,
        'user': {
          'id': 'usr_supabase_recovered_42',
          'email': 'recovered@rankearn.in',
          'phone': '+91 91234 56789',
          'user_metadata': {
            'name': 'Priya Patel',
            'exam_goal': 'UPSC Civil Services',
          },
        },
      };

      SharedPreferences.setMockInitialValues({
        SupabaseConfig.sessionKey: jsonEncode(mockSession),
      });

      final repo = AuthRepository();
      final result = await repo.restoreSession();
      expect(result, isA<Success<UserProfile>>());
      final restored = (result as Success<UserProfile>).data;
      expect(restored.id, equals('usr_supabase_recovered_42'));
      expect(restored.name, equals('Priya Patel'));
      expect(restored.email, equals('recovered@rankearn.in'));
      expect(restored.examPreparingFor, equals('UPSC Civil Services'));
    });

    test('Fresh app installation returns Failure and does not crash or fake session', () async {
      // Empty SharedPreferences simulating fresh install
      SharedPreferences.setMockInitialValues({});

      final repo = AuthRepository();
      final result = await repo.restoreSession();
      expect(result, isA<Failure<UserProfile>>());
      expect((result as Failure<UserProfile>).message, contains('No authenticated session found'));
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
    });

    test('Temporary network timeout does not wipe cached authentication data', () async {
      final repo = AuthRepository();

      final profile = UserProfile(
        id: 'usr_spotty_network',
        name: 'Spotty Network User',
        email: 'spotty@rankearn.in',
        coins: 1000,
        createdAt: DateTime.now(),
      );

      await repo.saveLocalProfile(profile);

      // Attempt restoreSession (simulating offline / network timeout)
      final result = await repo.restoreSession();
      expect(result, isA<Success<UserProfile>>());
      expect((result as Success<UserProfile>).data.name, equals('Spotty Network User'));

      // Ensure cached profile is NOT deleted
      final stillCached = await repo.getLocalProfile();
      expect(stillCached, isNotNull);
      expect(stillCached!.id, equals('usr_spotty_network'));
    });

    test('rememberMe = false prevents automatic session recovery when explicitly requested', () async {
      final repo = AuthRepository();

      final profile = UserProfile(
        id: 'usr_guest',
        name: 'Public Kiosk User',
        email: 'kiosk@rankearn.in',
        createdAt: DateTime.now(),
      );

      // Save without rememberMe
      await repo.saveLocalProfile(profile, rememberMe: false);

      // Next app launch should not restore from cache
      final restored = await repo.getLocalProfile();
      expect(restored, isNull);
    });
  });
}
