import 'package:shared_core/shared_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/test_model.dart';
import '../supabase/supabase_config.dart';

/// Contests & Tournaments Repository
class ContestsRepository {
  final SupabaseClient? _explicitClient;

  ContestsRepository({SupabaseClient? client}) : _explicitClient = client;

  SupabaseClient? get _client => _explicitClient ?? SupabaseConfig.clientSafe;

  /// Fetch Tournaments by status
  Future<Result<List<TestModel>>> getTournaments() async {
    final client = _client;
    if (client == null) {
      return const Success([]);
    }
    try {
      final data = await client
          .from('tests')
          .select()
          .eq('is_tournament', true)
          .eq('status', 'published')
          .order('scheduled_start_time', ascending: true);

      final list = (data as List).map((m) => TestModel.fromMap(m)).toList();
      return Success(list);
    } catch (e) {
      return Failure('Error fetching tournaments: $e', e);
    }
  }

  /// Join Tournament via atomic RPC
  Future<Result<Map<String, dynamic>>> joinTournament({
    required String testId,
    required String userId,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    try {
      final res = await client.rpc(
        'join_tournament',
        params: {'p_test_id': testId, 'p_user_id': userId},
      );

      return Success(Map<String, dynamic>.from(res));
    } catch (e) {
      return Failure('Failed to join contest: $e', e);
    }
  }

  /// Submit Quiz / Test Attempt
  Future<Result<String>> submitAttempt({
    required String testId,
    required String userId,
    required Map<String, int?> answers,
    required DateTime startTime,
    required DateTime endTime,
    required int timeTakenSeconds,
    required double score,
    required double accuracy,
    bool isTournament = false,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database not connected');
    }
    final attemptId = 'ATT_${DateTime.now().millisecondsSinceEpoch}';
    try {
      // If user is in demo/preview mode or userId is not a valid UUID format (e.g. 'usr_vikram_70'),
      // or if there is no active Supabase auth session, return local Success without triggering a 403 Forbidden network error.
      final isUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(userId);

      if (!isUuid || client.auth.currentUser == null) {
        return Success(attemptId);
      }

      await client.from('attempts').insert({
        'id': attemptId,
        'test_id': testId,
        'user_id': userId,
        'answers': answers,
        'start_time': startTime.toUtc().toIso8601String(),
        'end_time': endTime.toUtc().toIso8601String(),
        'time_taken_seconds': timeTakenSeconds,
        'score': score,
        'accuracy': accuracy,
        'is_tournament': isTournament,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      return Success(attemptId);
    } catch (e) {
      return Failure('Failed to record attempt: $e', e);
    }
  }
}
