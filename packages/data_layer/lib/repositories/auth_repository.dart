import 'dart:async';
import 'dart:convert';
import 'package:shared_core/shared_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/user_profile.dart';
import '../supabase/supabase_config.dart';
import '../supabase/auth_logger.dart';
import '../services/push_notification_service.dart';

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

  void _safeSyncDeviceToken(String userId) {
    unawaited(() async {
      try {
        await PushNotificationService.syncDeviceToken(userId: userId);
      } catch (_) {}
    }());
  }

  /// Persist authenticated user profile in local storage for instant offline / APK reopen
  Future<void> saveLocalProfile(UserProfile profile, {bool rememberMe = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localProfileKey, jsonEncode(profile.toMap()));
      await prefs.setBool(_rememberMeKey, rememberMe);
      AuthLogger.log('Local profile cached', {
        'userId': profile.id,
        'email': profile.email,
        'rememberMe': rememberMe,
      });
    } catch (e) {
      AuthLogger.log('saveLocalProfile error', {'error': e.toString()});
    }
  }

  /// Retrieve locally persisted user profile for display convenience (NOT authentication proof)
  Future<UserProfile?> getLocalProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localProfileKey);
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final profile = UserProfile.fromMap(map);
        return profile;
      }
    } catch (e) {
      AuthLogger.log('getLocalProfile error', {'error': e.toString()});
    }
    return null;
  }

  /// Clear locally persisted user profile on explicit logout
  Future<void> clearLocalProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localProfileKey);
      await prefs.remove(_rememberMeKey);
      AuthLogger.log('Local profile cleared from SharedPreferences');
    } catch (e) {
      AuthLogger.log('clearLocalProfile error', {'error': e.toString()});
    }
  }

  /// Restore user session on app launch.
  ///
  /// CRITICAL SECURITY REQUIREMENT:
  /// Only an actual, verified Supabase SDK session (`currentSession != null`)
  /// establishes authenticated status. A cached user profile in SharedPreferences
  /// is NEVER treated as proof of authentication.
  Future<Result<UserProfile>> restoreSession() async {
    final client = _client;
    if (client == null || !SupabaseConfig.isInitialized) {
      AuthLogger.logSessionRestore(
        source: 'uninitialized_client',
        hasSession: false,
        error: 'Supabase client is null or uninitialized',
      );
      return const Failure('Supabase client not initialized');
    }

    // 1. Ensure the Supabase SDK session is ready (safely awaiting refresh if expired)
    supa.Session? session;
    try {
      session = await SupabaseConfig.ensureSessionReady();
    } catch (e) {
      AuthLogger.log('ensureSessionReady error in restoreSession', {'error': e.toString()});
    }
    session ??= client.auth.currentSession;
    final supaUser = client.auth.currentUser;

    // 2. The ONLY source of truth for authentication is the verified Supabase SDK session!
    if (session == null || supaUser == null) {
      AuthLogger.logSessionRestore(
        source: 'supabase_sdk_session_check',
        hasSession: false,
        userId: null,
      );
      return const Failure('No authenticated Supabase session found');
    }

    final userId = supaUser.id;
    AuthLogger.logSessionRestore(
      source: 'supabase_sdk_session_verified',
      hasSession: true,
      userId: userId,
      isExpired: session.isExpired,
    );

    // 3. Read cached profile for fast UI display if it matches the authenticated user
    final cachedProfile = await getLocalProfile();
    if (cachedProfile != null && cachedProfile.id == userId) {
      _safeSyncDeviceToken(userId);

      // Asynchronously synchronize fresh profile from DB in the background without blocking UI
      unawaited(() async {
        try {
          final fresh = await getProfile(userId);
          if (fresh is Success<UserProfile>) {
            await saveLocalProfile(fresh.data);
          }
        } catch (_) {}
      }());

      return Success(cachedProfile);
    }

    // 4. If cache missing or user mismatch, fetch from database:
    try {
      final profileRes = await getProfile(userId);
      if (profileRes is Success<UserProfile>) {
        await saveLocalProfile(profileRes.data);
        _safeSyncDeviceToken(profileRes.data.id);
        return profileRes;
      }
    } catch (e) {
      AuthLogger.log('getProfile database fetch error; using metadata', {'error': e.toString()});
    }

    // 5. Fallback: If DB query fails (e.g. offline), construct profile from verified SDK user metadata
    final meta = supaUser.userMetadata ?? {};
    final fallback = UserProfile(
      id: userId,
      name: meta['name']?.toString() ??
          meta['full_name']?.toString() ??
          supaUser.email?.split('@').first ??
          'Rankearn Aspirant',
      email: supaUser.email ?? 'aspirant@rankearn.in',
      phone: supaUser.phone ?? meta['phone']?.toString(),
      coins: 100,
      subscriptionStatus: 'free',
      examPreparingFor: meta['exam_goal']?.toString() ?? 'Competitive Aspirant',
      state: 'India',
      createdAt: DateTime.now(),
    );
    await saveLocalProfile(fallback);
    _safeSyncDeviceToken(fallback.id);
    return Success(fallback);
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
      ).timeout(const Duration(seconds: 15));

      final user = response.user;
      if (user == null) {
        return const Failure('Signup failed: No user returned');
      }

      // Explicitly upsert profile into database so user row ALWAYS exists
      final newProfile = UserProfile(
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
        await client.from('profiles').upsert(newProfile.toMap()).timeout(const Duration(seconds: 8));
      } catch (_) {}

      final profileRes = await getProfile(user.id);
      if (profileRes is Success<UserProfile>) {
        await saveLocalProfile(profileRes.data);
        return profileRes;
      }

      await saveLocalProfile(newProfile);
      return Success(newProfile);
    } on TimeoutException {
      return const Failure('Server request timed out. Please check if your Supabase project is active or paused.');
    } on supa.AuthException catch (e) {
      return Failure(e.message, e.statusCode);
    } catch (e) {
      final str = e.toString().toLowerCase();
      if (str.contains('timeout') || str.contains('timeoutexception') || str.contains('504')) {
        return const Failure('Server request timed out. Please check if your Supabase project is active or paused.');
      }
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
    bool rememberMe = true,
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
              .maybeSingle()
              .timeout(const Duration(seconds: 8));
          if (profileRow != null && profileRow['email'] != null) {
            linkedEmail = profileRow['email'] as String?;
          }
        } catch (_) {}

        if (linkedEmail != null && linkedEmail.isNotEmpty) {
          response = await client.auth.signInWithPassword(
            email: linkedEmail,
            password: password,
          ).timeout(const Duration(seconds: 15));
        } else {
          response = await client.auth.signInWithPassword(
            phone: phoneE164,
            password: password,
          ).timeout(const Duration(seconds: 15));
        }
      } else {
        response = await client.auth.signInWithPassword(
          email: trimmed,
          password: password,
        ).timeout(const Duration(seconds: 15));
      }

      final user = response.user;
      if (user == null) {
        return const Failure('Login failed: Invalid credentials');
      }

      final profileRes = await getProfile(user.id);
      if (profileRes is Success<UserProfile>) {
        await saveLocalProfile(profileRes.data, rememberMe: rememberMe);
        return profileRes;
      }

      final meta = user.userMetadata ?? {};
      final fallbackProfile = UserProfile(
        id: user.id,
        name: meta['name']?.toString() ?? meta['full_name']?.toString() ?? user.email?.split('@').first ?? 'Rankearn Aspirant',
        email: user.email ?? 'aspirant@rankearn.in',
        phone: user.phone ?? meta['phone']?.toString(),
        coins: 100,
        subscriptionStatus: 'free',
        examPreparingFor: meta['exam_goal']?.toString() ?? 'Competitive Aspirant',
        state: 'India',
        createdAt: DateTime.now(),
      );
      try {
        await client.from('profiles').upsert(fallbackProfile.toMap()).timeout(const Duration(seconds: 8));
      } catch (_) {}
      await saveLocalProfile(fallbackProfile, rememberMe: rememberMe);
      return Success(fallbackProfile);
    } on TimeoutException {
      return const Failure('Server request timed out. Please check your internet connection or verify if the Supabase project is active/unpaused.');
    } on supa.AuthException catch (e) {
      return Failure(e.message, e.statusCode);
    } catch (e) {
      final str = e.toString().toLowerCase();
      if (str.contains('timeout') || str.contains('timeoutexception') || str.contains('504')) {
        return const Failure('Server request timed out. Please verify that your Supabase project is active.');
      }
      return Failure(e.toString(), e);
    }
  }

  /// Sign In with Email & Password
  Future<Result<UserProfile>> signInWithEmail({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    return signInWithIdentifier(identifier: email, password: password, rememberMe: rememberMe);
  }

  /// Sign In with Google OAuth ID Token
  Future<Result<UserProfile>> signInWithGoogleIdToken({
    required String idToken,
    String? accessToken,
    bool rememberMe = true,
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

      final profileRes = await getProfile(user.id);
      if (profileRes is Success<UserProfile>) {
        await saveLocalProfile(profileRes.data, rememberMe: rememberMe);
        return profileRes;
      }

      final meta = user.userMetadata ?? {};
      final fallbackProfile = UserProfile(
        id: user.id,
        name: meta['name']?.toString() ?? meta['full_name']?.toString() ?? user.email?.split('@').first ?? 'Rankearn Aspirant',
        email: user.email ?? 'aspirant@rankearn.in',
        phone: user.phone ?? meta['phone']?.toString(),
        coins: 100,
        subscriptionStatus: 'free',
        examPreparingFor: meta['exam_goal']?.toString() ?? 'Competitive Aspirant',
        state: 'India',
        createdAt: DateTime.now(),
      );
      try {
        await client.from('profiles').upsert(fallbackProfile.toMap());
      } catch (_) {}
      await saveLocalProfile(fallbackProfile, rememberMe: rememberMe);
      return Success(fallbackProfile);
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
    bool rememberMe = true,
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
        await saveLocalProfile(profileRes.data, rememberMe: rememberMe);
        return profileRes;
      }

      final meta = user.userMetadata ?? {};
      final fallbackProfile = UserProfile(
        id: user.id,
        name: meta['name']?.toString() ?? meta['full_name']?.toString() ?? user.email?.split('@').first ?? 'Rankearn Aspirant',
        email: user.email ?? 'aspirant@rankearn.in',
        phone: user.phone ?? meta['phone']?.toString(),
        coins: 100,
        subscriptionStatus: 'free',
        examPreparingFor: meta['exam_goal']?.toString() ?? 'Competitive Aspirant',
        state: 'India',
        createdAt: DateTime.now(),
      );
      try {
        await client.from('profiles').upsert(fallbackProfile.toMap());
      } catch (_) {}
      await saveLocalProfile(fallbackProfile, rememberMe: rememberMe);
      return Success(fallbackProfile);
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

  /// Resend Email Signup Verification Link
  Future<Result<bool>> resendVerificationEmail(String email) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      return const Failure('Please enter a valid email address first.');
    }
    try {
      await client.auth.resend(
        type: supa.OtpType.signup,
        email: trimmedEmail,
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
    AuthLogger.logLogoutTrigger(trigger: 'explicit_sign_out', userInitiated: true);
    await clearLocalProfile();
    final client = _client;
    if (client == null) {
      return const Success(true);
    }
    try {
      await client.auth.signOut();
      return const Success(true);
    } catch (e) {
      AuthLogger.log('signOut error', {'error': e.toString()});
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
          .maybeSingle()
          .timeout(const Duration(seconds: 8));

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

      final updated = UserProfile.fromMap(data);
      await saveLocalProfile(updated);
      return Success(updated);
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
      final res = await client.rpc('is_admin').timeout(const Duration(seconds: 8));
      return res == true;
    } catch (_) {
      return false;
    }
  }
}
