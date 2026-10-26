import 'package:shared_core/shared_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/user_profile.dart';
import '../supabase/supabase_config.dart';

/// Authentication & User Profile Repository
class AuthRepository {
  final supa.SupabaseClient? _explicitClient;

  AuthRepository({supa.SupabaseClient? client}) : _explicitClient = client;

  supa.SupabaseClient? get _client => _explicitClient ?? SupabaseConfig.clientSafe;

  supa.User? get currentUser => _client?.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<supa.AuthState> get authStateChanges =>
      _client?.auth.onAuthStateChange ?? const Stream.empty();

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

      return await getProfile(user.id);
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
      return await getProfile(user.id);
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
          return Success(provisionedProfile);
        }
        return const Failure('Profile not found');
      }

      return Success(UserProfile.fromMap(data));
    } catch (e) {
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
