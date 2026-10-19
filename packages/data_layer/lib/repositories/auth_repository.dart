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

  /// Register new user with Email, Password, Name, and optional Referral Code
  Future<Result<UserProfile>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? referralCode,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name.trim(),
          if (referralCode != null && referralCode.trim().isNotEmpty)
            'referral_code': referralCode.trim().toUpperCase(),
        },
      );

      final user = response.user;
      if (user == null) {
        return const Failure('Signup failed: No user returned');
      }

      // Allow trigger to execute and fetch created profile
      final profileResult = await getProfile(user.id);
      return profileResult;
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
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

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
