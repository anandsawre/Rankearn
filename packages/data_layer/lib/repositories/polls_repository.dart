import 'dart:async';
import '../models/poll_model.dart';
import '../supabase/supabase_config.dart';

class PollsRepository {
  static final PollsRepository _instance = PollsRepository._internal();
  factory PollsRepository() => _instance;
  PollsRepository._internal();

  /// Fetch the currently active live poll from Supabase
  Future<PollModel?> getActiveLivePoll() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return null;

    try {
      final res = await client
          .from('polls')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (res == null) return null;
      final poll = PollModel.fromJson(res);

      // Check expiration
      if (poll.isExpired) {
        // Mark inactive in background
        client.from('polls').update({'is_active': false}).eq('id', poll.id).catchError((_) {});
        return null;
      }
      return poll;
    } catch (_) {
      return null;
    }
  }

  /// Real-time stream of the active live poll
  Stream<PollModel?> streamActivePoll() {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      return Stream.value(null);
    }

    try {
      return client
          .from('polls')
          .stream(primaryKey: ['id'])
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(1)
          .map((list) {
            if (list.isEmpty) return null;
            final poll = PollModel.fromJson(list.first);
            if (poll.isExpired) {
              client.from('polls').update({'is_active': false}).eq('id', poll.id).catchError((_) {});
              return null;
            }
            return poll;
          });
    } catch (_) {
      // Fallback polling stream if stream fails
      return Stream.periodic(const Duration(seconds: 3))
          .asyncMap((_) => getActiveLivePoll());
    }
  }

  /// Create and launch a real live poll into Supabase
  Future<PollModel?> createAndLaunchPoll({
    required String question,
    required List<String> options,
    int durationSeconds = 30,
    String targetSegment = 'all',
  }) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return null;

    try {
      // 1. Mark any previously active polls as inactive
      await client.from('polls').update({'is_active': false}).eq('is_active', true);

      // 2. Prepare new poll
      final pollId = 'poll_${DateTime.now().millisecondsSinceEpoch}';
      final expiresAt = DateTime.now().toUtc().add(Duration(seconds: durationSeconds));
      final optionsList = options.map((opt) => {'text': opt}).toList();
      final Map<String, int> initialVotes = {};
      for (int i = 0; i < options.length; i++) {
        initialVotes['$i'] = 0;
      }

      final payload = {
        'id': pollId,
        'question': question.trim(),
        'options': optionsList,
        'votes': initialVotes,
        'target_segment': targetSegment,
        'is_active': true,
        'expires_at': expiresAt.toIso8601String(),
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };

      await client.from('polls').insert(payload);
      return PollModel.fromJson(payload);
    } catch (e) {
      return null;
    }
  }

  /// End an active poll immediately
  Future<bool> endPoll(String pollId) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return false;

    try {
      await client.from('polls').update({'is_active': false}).eq('id', pollId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Restart a poll with fresh duration
  Future<bool> restartPoll(String pollId, int durationSeconds) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return false;

    try {
      final expiresAt = DateTime.now().toUtc().add(Duration(seconds: durationSeconds));
      await client.from('polls').update({
        'is_active': true,
        'expires_at': expiresAt.toIso8601String(),
      }).eq('id', pollId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Check which option the user voted for (or null if not voted)
  Future<int?> getUserVotedOption(String pollId, String userId) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return null;

    try {
      final res = await client
          .from('poll_votes')
          .select('option_index')
          .eq('poll_id', pollId)
          .eq('user_id', userId)
          .maybeSingle();

      if (res != null && res['option_index'] != null) {
        return (res['option_index'] as num).toInt();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Cast vote: records in poll_votes and updates votes count in polls table
  Future<bool> castVote({
    required String pollId,
    required String userId,
    required int optionIndex,
  }) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return false;

    try {
      // 1. Record single vote in poll_votes table
      await client.from('poll_votes').upsert({
        'poll_id': pollId,
        'user_id': userId,
        'option_index': optionIndex,
        'voted_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'poll_id,user_id');

      // 2. Fetch current votes jsonb to increment count
      final pollRes = await client.from('polls').select('votes').eq('id', pollId).maybeSingle();
      final Map<String, dynamic> currentVotes = (pollRes != null && pollRes['votes'] is Map)
          ? Map<String, dynamic>.from(pollRes['votes'])
          : {};

      final optKey = '$optionIndex';
      final currentCount = (currentVotes[optKey] is num) ? (currentVotes[optKey] as num).toInt() : 0;
      currentVotes[optKey] = currentCount + 1;

      // 3. Update polls table with incremented votes
      await client.from('polls').update({'votes': currentVotes}).eq('id', pollId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Fetch history of past and current polls
  Future<List<PollModel>> getPollHistory() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return [];

    try {
      final res = await client.from('polls').select().order('created_at', ascending: false);
      return (res as List).map((row) => PollModel.fromJson(row)).toList();
    } catch (_) {
      return [];
    }
  }
}
