import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';

/// Repository for In-App & Push Notifications management
class NotificationsRepository {
  final SupabaseClient? _client;

  NotificationsRepository([this._client]);

  SupabaseClient? get _effectiveClient => _client ?? SupabaseConfig.clientSafe;

  /// Fetch notifications history for user/global
  Future<List<Map<String, dynamic>>> fetchNotifications({int limit = 25, bool onlyActive = true}) async {
    final client = _effectiveClient;
    if (client == null) return [];

    try {
      var query = client.from('notifications').select();
      if (onlyActive) {
        query = query.neq('status', 'scheduled').neq('status', 'draft');
      }
      final res = await query.order('created_at', ascending: false).limit(limit);

      return List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  /// Realtime Stream of incoming notifications
  Stream<Map<String, dynamic>> streamIncomingNotifications() {
    final client = _effectiveClient;
    if (client == null) return const Stream.empty();

    final controller = StreamController<Map<String, dynamic>>.broadcast();

    try {
      final channel = client.channel('public:notifications_realtime');
      channel.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'notifications',
        callback: (payload) {
          final record = payload.newRecord;
          if (record.isNotEmpty && !controller.isClosed) {
            final status = (record['status'] ?? 'sent').toString().toLowerCase();
            // Only deliver active sent broadcasts (ignore scheduled / drafts)
            if (status != 'scheduled' && status != 'draft') {
              controller.add(Map<String, dynamic>.from(record));
            }
          }
        },
      ).subscribe();

      controller.onCancel = () {
        channel.unsubscribe();
      };
    } catch (e) {
      debugPrint('Realtime notification stream error: $e');
    }

    return controller.stream;
  }

  /// Mark notification read
  Future<void> markRead(String notificationId, {String? userId}) async {
    final client = _effectiveClient;
    if (client == null || notificationId.isEmpty) return;

    try {
      if (userId != null && userId.isNotEmpty) {
        await client.rpc('mark_notification_read', params: {
          'p_notification_id': notificationId,
          'p_user_id': userId,
        });
      } else {
        await client
            .from('notifications')
            .update({'is_read': true})
            .eq('id', notificationId);
      }
    } catch (_) {}
  }

  /// Record Click on CTA button
  Future<void> recordClick(String notificationId) async {
    final client = _effectiveClient;
    if (client == null || notificationId.isEmpty) return;

    try {
      await client.rpc('increment_notification_clicks', params: {
        'p_notification_id': notificationId,
      });
    } catch (_) {
      try {
        final res = await client
            .from('notifications')
            .select('clicks')
            .eq('id', notificationId)
            .maybeSingle();
        final current = (res?['clicks'] as num?)?.toInt() ?? 0;
        await client
            .from('notifications')
            .update({'clicks': current + 1})
            .eq('id', notificationId);
      } catch (_) {}
    }
  }
}
