import 'dart:convert';
import 'package:shared_core/shared_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/user_profile.dart';
import '../supabase/supabase_config.dart';

/// Authentication & User Profile Repository
class AuthRepository {
  static const String _localProfileKey = 'rankearn_user_profile_cache';
  static const String _rememberMeKey = 'rankearn_user_remember_me';

  final supa.SupabaseClient? _explicitClient;

  AuthRepository({supa.SupabaseClient? client}) : _explicitClient = client;

  supa.SupabaseClient? get _client => _explicitClient ?? SupabaseConfig.clientSafe;

  supa.User? get currentUser => _client?.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<supa.AuthState> get authStateChanges =>
      _client?.auth.onAuthStateChange ?? const Stream.empty();

  /// Persist authenticated user profile in local storage for instant offline / APK reopen
  Future<void> saveLocalProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localProfileKey, jsonEncode(profile.toMap()));
      await prefs.setBool(_rememberMeKey, true);
    } catch (_) {}
  }

  /// Retrieve locally persisted user profile
  Future<UserProfile?> getLocalProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_rememberMeKey) ?? true;
      if (!rememberMe) return null;
      final raw = prefs.getString(_localProfileKey);
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return UserProfile.fromMap(map);
      }
    } catch (_) {}
    return null;
  }

  /// Clear locally persisted user profile on explicit logout
  Future<void> clearLocalProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localProfileKey);
      await prefs.remove(_rememberMeKey);
    } catch (_) {}
  }

  /// Restore user session seamlessly on app launch (guarantees session persistence across APK restarts)
  Future<Result<UserProfile>> restoreSession() async {
    final client = _client;
    final cachedProfile = await getLocalProfile();

    if (client == null) {
      if (cachedProfile != null) {
        return Success(cachedProfile);
      }
      return const Failure('Database not connected');
    }

    try {
      // 1. Check if Supabase has a valid or refreshable session
      final currentSession = client.auth.currentSession;
      if (currentSession != null) {
        if (currentSession.isExpired) {
          try {
            await client.auth.refreshSession();
          } catch (_) {}
        }

        final currentUserId = client.auth.currentUser?.id ?? currentSession.user.id;
        final profileRes = await getProfile(currentUserId);
        if (profileRes is Success<UserProfile>) {
          await saveLocalProfile(profileRes.data);
          return profileRes;
        }
      }

      final currentUser = client.auth.currentUser;
      if (currentUser != null) {
        final profileRes = await getProfile(currentUser.id);
        if (profileRes is Success<UserProfile>) {
          await saveLocalProfile(profileRes.data);
          return profileRes;
        }
      }
    } catch (_) {}

    // Fallback to locally cached profile so user is NEVER logged out due to network latency on app launch
    if (cachedProfile != null) {
      return Success(cachedProfile);
    }

    return const Failure('No authenticated session found');
  }

  /// Register new user with Email, Phone, Password, Name, and optional Referral Code
  Future<Result<UserProfile>> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? examGoal,
    String? referralCode,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      final cleanPhone = phone != null && phone.trim().isNotEmpty
          ? (phone.trim().replaceAll(RegExp(r'\D'), '').length == 10
              ? '+91${phone.trim().replaceAll(RegExp(r'\D'), '')}'
              : phone.trim())
          : null;

      final trimmedEmail = email.trim();
      final hasEmail = trimmedEmail.isNotEmpty;

      // In Supabase GoTrue, signUp expects EITHER email OR phone, not both.
      // When email is provided, phone is saved in metadata and stored in profiles.
      final response = await client.auth.signUp(
        email: hasEmail ? trimmedEmail : null,
        phone: hasEmail ? null : cleanPhone,
        password: password,
        data: {
          'name': name.trim(),
          'phone': ?cleanPhone,
          if (examGoal != null && examGoal.trim().isNotEmpty) 'exam_goal': examGoal.trim(),
          if (referralCode != null && referralCode.trim().isNotEmpty)
            'referral_code': referralCode.trim().toUpperCase(),
        },
      );

      final user = response.user;
      if (user == null) {
        return const Failure('Signup failed: No user returned');
      }

      final profileRes = await getProfile(user.id);
      if (profileRes is Success<UserProfile>) {
        return profileRes;
      }

      // Fallback profile if database trigger is slightly delayed or session is pending confirmation
      final fallbackProfile = UserProfile(
        id: user.id,
        name: name.trim(),
        email: user.email ?? trimmedEmail,
        phone: cleanPhone,
        coins: 100,
        subscriptionStatus: 'free',
        examPreparingFor: examGoal ?? 'Competitive Aspirant',
        state: 'India',
        referralCode: referralCode?.trim().toUpperCase(),
        createdAt: DateTime.now(),
      );

      try {
        await client.from('profiles').upsert(fallbackProfile.toMap());
      } catch (_) {}

      return Success(fallbackProfile);
    } on supa.AuthException catch (e) {
      return Failure(e.message, e.statusCode);
    } catch (e) {
      return Failure(e.toString(), e);
    }
  }

  /// Register new user with Email, Password, Name, and optional Referral Code
  Future<Result<UserProfile>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? referralCode,
  }) async {
    return signUp(
      email: email,
      password: password,
      name: name,
      referralCode: referralCode,
    );
  }

  /// Sign In with Email OR Mobile Number & Password
  Future<Result<UserProfile>> signInWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    final trimmed = identifier.trim();
    final isPhone = !trimmed.contains('@') && RegExp(r'^[+0-9\s\-]+$').hasMatch(trimmed);

    try {
      final supa.AuthResponse response;
      if (isPhone) {
        final digits = trimmed.replaceAll(RegExp(r'\D'), '');
        final phoneE164 = digits.length == 10 ? '+91$digits' : (trimmed.startsWith('+') ? trimmed : '+$trimmed');

        // Check if there is an account linked with this phone number to sign in via email
        String? linkedEmail;
        try {
          final profileRow = await client
              .from('profiles')
              .select('email')
              .or('phone.eq.$trimmed,phone.eq.$phoneE164,phone.eq.$digits')
              .maybeSingle();
          if (profileRow != null && profileRow['email'] != null) {
            linkedEmail = profileRow['email'] as String?;
          }
        } catch (_) {}

        if (linkedEmail != null && linkedEmail.isNotEmpty) {
          response = await client.auth.signInWithPassword(
            email: linkedEmail,
            password: password,
          );
        } else {
          response = await client.auth.signInWithPassword(
            phone: phoneE164,
            password: password,
          );
        }
      } else {
        response = await client.auth.signInWithPassword(
          email: trimmed,
          password: password,
        );
      }

      final user = response.user;
      if (user == null) {
        return const Failure('Login failed: Invalid credentials');
      }

      final profileRes = await getProfile(user.id);
      if (profileRes is Success<UserProfile>) {
        await saveLocalProfile(profileRes.data);
      }
      return profileRes;
    } on supa.AuthException catch (e) {
      return Failure(e.message, e.statusCode);
    } catch (e) {
      return Failure(e.toString(), e);
    }
  }

  /// Sign In with Email & Password
  Future<Result<UserProfile>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return signInWithIdentifier(identifier: email, password: password);
  }

  /// Sign In with Google OAuth ID Token
  Future<Result<UserProfile>> signInWithGoogleIdToken({
    required String idToken,
    String? accessToken,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      final response = await client.auth.signInWithIdToken(
        provider: supa.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user == null) {
        return const Failure('Google login failed');
      }

      return await getProfile(user.id);
    } on supa.AuthException catch (e) {
      return Failure(e.message, e.statusCode);
    } catch (e) {
      return Failure(e.toString(), e);
    }
  }

  /// Launch Google OAuth sign in flow
  Future<bool> signInWithGoogleOAuth({String? redirectTo}) async {
    final client = _client;
    if (client == null) return false;
    try {
      return await client.auth.signInWithOAuth(
        supa.OAuthProvider.google,
        redirectTo: redirectTo,
      );
    } catch (_) {
      return false;
    }
  }

  /// Send Phone SMS OTP
  Future<Result<bool>> sendPhoneOtp(String phone) async {
    final client = _client;
    if (client == null) return const Failure('Database not connected');
    try {
      final clean = phone.trim().replaceAll(RegExp(r'\D'), '');
      final phoneE164 = clean.length == 10 ? '+91$clean' : (phone.trim().startsWith('+') ? phone.trim() : '+$clean');
      await client.auth.signInWithOtp(phone: phoneE164);
      return const Success(true);
    } on supa.AuthException catch (e) {
      return Failure(e.message, e.statusCode);
    } catch (e) {
      return Failure(e.toString(), e);
    }
  }

  /// Verify Phone SMS OTP
  Future<Result<UserProfile>> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    final client = _client;
    if (client == null) return const Failure('Database not connected');
    try {
      final clean = phone.trim().replaceAll(RegExp(r'\D'), '');
      final phoneE164 = clean.length == 10 ? '+91$clean' : (phone.trim().startsWith('+') ? phone.trim() : '+$clean');
      final response = await client.auth.verifyOTP(
        phone: phoneE164,
        token: token.trim(),
        type: supa.OtpType.sms,
      );
      final user = response.user;
      if (user == null) {
        return const Failure('Verification failed: invalid OTP code');
      }
      final profileRes = await getProfile(user.id);
      if (profileRes is Success<UserProfile>) {
        await saveLocalProfile(profileRes.data);
      }
      return profileRes;
    } on supa.AuthException catch (e) {
      return Failure(e.message, e.statusCode);
    } catch (e) {
      return Failure(e.toString(), e);
    }
  }

  /// Request Password Recovery Email
  Future<Result<bool>> sendPasswordResetEmail(String email) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      await client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'com.rankearn.app://reset-password',
      );
      return const Success(true);
    } on supa.AuthException catch (e) {
      return Failure(e.message, e.statusCode);
    } catch (e) {
      return Failure(e.toString(), e);
    }
  }

  /// Sign Out
  Future<Result<bool>> signOut() async {
    await clearLocalProfile();
    final client = _client;
    if (client == null) {
      return const Success(true);
    }
    try {
      await client.auth.signOut();
      return const Success(true);
    } catch (e) {
      return Failure(e.toString(), e);
    }
  }

  /// Fetch User Profile
  Future<Result<UserProfile>> getProfile(String userId) async {
    final client = _client;
    if (client == null) {
      final cached = await getLocalProfile();
      if (cached != null && cached.id == userId) {
        return Success(cached);
      }
      return const Failure('Database not connected');
    }
    try {
      final data = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        // If profile row was not yet created by database trigger, provision it from auth metadata
        final currentAuthUser = _client?.auth.currentUser;
        if (currentAuthUser != null && currentAuthUser.id == userId) {
          final metadata = currentAuthUser.userMetadata ?? {};
          final defaultName = metadata['name']?.toString() ??
              metadata['full_name']?.toString() ??
              (currentAuthUser.email != null && currentAuthUser.email!.isNotEmpty
                  ? currentAuthUser.email!.split('@').first
                  : 'Rankearn Aspirant');

          final provisionedProfile = UserProfile(
            id: userId,
            name: defaultName,
            email: currentAuthUser.email ?? '',
            phone: currentAuthUser.phone ?? metadata['phone']?.toString(),
            coins: 10,
            subscriptionStatus: 'free',
            examPreparingFor: metadata['exam_goal']?.toString() ?? 'Competitive Aspirant',
            state: 'India',
            referralCode: metadata['referral_code']?.toString(),
            createdAt: DateTime.now(),
          );

          try {
            await client.from('profiles').upsert(provisionedProfile.toMap());
          } catch (_) {}
          await saveLocalProfile(provisionedProfile);
          return Success(provisionedProfile);
        }

        final cached = await getLocalProfile();
        if (cached != null && cached.id == userId) {
          return Success(cached);
        }
        return const Failure('Profile not found');
      }

      final profile = UserProfile.fromMap(data);
      await saveLocalProfile(profile);
      return Success(profile);
    } catch (e) {
      final cached = await getLocalProfile();
      if (cached != null && cached.id == userId) {
        return Success(cached);
      }
      return Failure('Error fetching profile: $e', e);
    }
  }

  /// Update Profile Details
  Future<Result<UserProfile>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? state,
    String? examPreparingFor,
    String? photoUrl,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        if (name != null) 'name': name.trim(),
        if (phone != null) 'phone': phone.trim(),
        if (state != null) 'state': state.trim(),
        if (examPreparingFor != null) 'exam_preparing_for': examPreparingFor.trim(),
      };
      if (photoUrl != null) {
        updates['profile_photo_url'] = photoUrl;
      }

      final data = await client
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return Success(UserProfile.fromMap(data));
    } catch (e) {
      return Failure('Error updating profile: $e', e);
    }
  }

  /// Check Server-Enforced Admin Authorization
  Future<bool> checkIsAdmin(String userId) async {
    final client = _client;
    if (client == null) {
      return false;
    }
    try {
      final res = await client.rpc('is_admin');
      return res == true;
    } catch (_) {
      return false;
    }
  }
}
